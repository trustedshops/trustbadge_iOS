//
//  TRSTrustcard.m
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

#import "TRSTrustcard.h"
#import "TRSTrustbadgeSDKPrivate.h"
@import NBMaterialDialogIOS;
#import <Trustbadge/Trustbadge-Swift.h>
@import CoreText;

@interface TRSTrustcard ()

@property (nonatomic, weak) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIImageView *sealImage;

@property (weak, nonatomic) IBOutlet UILabel *cardHeader;

@property (nonatomic, weak) IBOutlet UILabel *checkmark;
@property (weak, nonatomic) IBOutlet UILabel *checkHeader;
@property (weak, nonatomic) IBOutlet UILabel *checkText;

@property (nonatomic, weak) IBOutlet UILabel *lockmark;
@property (weak, nonatomic) IBOutlet UILabel *lockHeader;
@property (weak, nonatomic) IBOutlet UILabel *lockText;

@property (nonatomic, weak) IBOutlet UILabel *bubblesmark;
@property (weak, nonatomic) IBOutlet UILabel *bubblesHeader;
@property (weak, nonatomic) IBOutlet UILabel *bubblesText;

@end

@implementation TRSTrustcard

- (void)reloadView {
	if (!self.cardView) {
		[TRSTrustbadgeBundle() loadNibNamed:@"Trustcard" owner:self options:nil];
		
		// TODO: load font (if needed) and replace placeholder text with correct symbols & internationalized text
		CGFloat fontSize = self.checkmark.font.pointSize;
		UIFont *theFont = [TRSTrustcard openFontAwesomeWithSize:fontSize];
		self.checkmark.font = theFont;
		self.lockmark.font = theFont;
		self.bubblesmark.font = theFont;
		self.checkmark.text = @"\uf00c";
		self.lockmark.text = @"\uf023";
		self.bubblesmark.text = @"\uf0e6";
	}
}

- (void)showInLightbox {
	UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
	// fallback for the unlikely case the delegate doesn't have the window set:
	if (!mainWindow) {
		mainWindow = [[[UIApplication sharedApplication] windows] firstObject];
	}
	
	[self reloadView];
	
	void (^myAction)(BOOL myBool) = ^void(BOOL myBool) {
		if (myBool) {
			NSLog(@"Canceled/Certificate");
			// open certificate in mobile browser
		}
		else NSLog(@"OKed");
	};
	
	NBMaterialDialogObCFix *lightbox = [[NBMaterialDialogObCFix alloc] init];
	lightbox.customBtnColor = [UIColor colorWithRed:247.0f/255.0f green:132.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
	// since the dialog lib is still a bit wonky I must provide a height. 300.0f works well on all sizes/rotations
	// note that the color setting ONLY works with this workaround for now. See NBMaterialDialogObCFix.swift
	[lightbox showFromObjCDialog:mainWindow
						   title:nil
						 content:self.cardView
					dialogHeight:300.0f
				   okButtonTitle:@"OK"
						  action:myAction
			   cancelButtonTitle:@"CERTIFICATE"];
}

#pragma mark Font helper methods

+ (UIFont *)openFontAwesomeWithSize:(CGFloat)size
{
	NSString *fontName = @"fontawesome";
	UIFont *font = [UIFont fontWithName:fontName size:size];
	if (!font) {
		[[self class] dynamicallyLoadFontNamed:fontName];
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
		CFRelease(font);
		CFRelease(provider);
	}
}


@end