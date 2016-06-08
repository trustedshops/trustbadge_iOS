//
//  TRSTrustcard.m
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

static NSString * const TRSCertLocalFallback = @"trustcardfallback"; // not used atm
static NSString * const TRSCertHTMLName = @"trustinfos"; // not used atm

#import "TRSTrustcard.h"
#import "TRSTrustbadge.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "NSURL+TRSURLExtensions.h"
#import "UIColor+TRSColors.h"
#import "TRSNetworkAgent+Trustbadge.h"
@import CoreText;
//@import WebKit;
#import "UIViewController+MaryPopin.h"

@interface TRSTrustcard () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *certButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
// TODO: switch to the newer WKWebView class, but beware of Interface Builder when doing so

@property (weak, nonatomic) TRSTrustbadge *displayedTrustbadge;
// this is weak to avoid a retain cycle (it's our owner), used for temporary stuff

@end

@implementation TRSTrustcard

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSString *colorString = @"F37000"; // fallback value: our orange
	if (self.themeColor) {
		colorString = [[self.themeColor hexString] capitalizedString];
	}
	
	NSMutableURLRequest *myrequest = [[TRSNetworkAgent sharedAgent] localizedURLRequestForTrustcardWithColorString:colorString];
	[self.webView loadRequest:myrequest];
	// TODO: ensure the caching works as expected, even for app-restart etc.
	
	// TODO: implement fallback mechanism if the URL is not reachable (means also including local files)

	// set the color of the buttons
	if (self.themeColor) {
		[self.okButton setTitleColor:self.themeColor forState:UIControlStateNormal];
		[self.certButton setTitleColor:self.themeColor forState:UIControlStateNormal];
	}
	
	self.webView.scrollView.scrollEnabled = NO;
}

- (IBAction)buttonTapped:(id)sender {
	if ([sender tag] == 1 && self.displayedTrustbadge) { // the tag is set in Interface Builder, it's the certButton
		NSURL *targetURL = [NSURL profileURLForShop:self.displayedTrustbadge.shop];
		[[UIApplication sharedApplication] openURL:targetURL];
	}
	// this does nothing unless the view is modally presented (otherwise presenting VC is nil)
//	[self.presentingViewController dismissViewControllerAnimated:YES completion:^{
//		self.displayedTrustbadge = nil; // not necessary, but we wanna be nice & cleaned up
//	}];
	[self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:^{
		self.displayedTrustbadge = nil;
	}];
}

- (void)showInLightboxForTrustbadge:(TRSTrustbadge *)trustbadge {	
	// this is always there, but what happens if I have more than one? multi screen apps? test that somehow...
	UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
	
	self.displayedTrustbadge = trustbadge;
//	self.modalPresentationStyle = UIModalPresentationPageSheet;
	UIViewController *rootVC = mainWindow.rootViewController;
	// TODO: check what happens if there is no root VC. work that out
//	[rootVC presentViewController:self animated:YES completion:nil];
	[self setPopinOptions:BKTPopinDisableAutoDismiss];
    
    
    if (rootVC.presentedViewController) {
        [rootVC.presentedViewController presentPopinController:self animated:YES completion:nil];
    }
    else {
        [rootVC presentPopinController:self animated:YES completion:nil];
    }
}

#pragma mark - UIWebViewDelegate

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//	NSLog(@"Web view's scroll contentsize width & height are: %f, %f",
//		  self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height);
	// this method can/should be used to resize the view in case the content in the webView is too small...
	// TODO: figure out a good size together with a designer, put mostly into the html & make it dynamic!
	
	// try out code:
	
//	NSString *heightJS = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"body\").scrollHeight;"];
//	NSLog(@"heightJS is: %@", heightJS);
//	NSString *widthJS = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"body\").scrollWidth;"];
//	NSLog(@"widthJS: %@", widthJS);
	
//	CGRect viewFrame = self.view.frame;
//	viewFrame.size.height = self.webView.scrollView.contentSize.height + 30; // 30 is the size of the buttons, i.e. bottom space
//	self.view.frame = viewFrame;
//}

#pragma mark - Font helper methods

// note, these are currently not used with the webView, but we will keep them for now.
// also, the font asset will be used by the webview, probably
+ (UIFont *)openFontAwesomeWithSize:(CGFloat)size
{
	// UIFont actually does accept negative sizes it seems, but the documentation says we shouldn't do this.
	if (size <= 0) {
		return nil;
	}
	NSString *fontName = @"fontawesome";
	UIFont *font = [UIFont fontWithName:fontName size:size];
	if (!font) {
		[TRSTrustcard dynamicallyLoadFontNamed:fontName];
		font = [UIFont fontWithName:fontName size:size];
		
		// safe fallback
		if (!font) font = [UIFont systemFontOfSize:size];
	}
	
	return font;
}

+ (void)dynamicallyLoadFontNamed:(NSString *)name
{
	NSURL *url = [TRSTrustbadgeBundle() URLForResource:name withExtension:@"ttf"];
	NSData *fontData = [NSData dataWithContentsOfURL:url];
	if (fontData) {
		CFErrorRef error;
		CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
		CGFontRef font = CGFontCreateWithDataProvider(provider);
		if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
			CFStringRef errorDescription = CFErrorCopyDescription(error);
			NSLog(@"Failed to load font: %@", errorDescription);
			CFRelease(errorDescription);
		}
		if (font) {
			CFRelease(font);
		}
		CFRelease(provider);
	}
}


@end
