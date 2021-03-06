//
//  NSURL+TRSURLExtensionsSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 21/03/16.
//

#import "NSURL+TRSURLExtensions.h"
#import <Specta/Specta.h>
#import "TRSShop.h"
#import "TRSNetworkAgent+Trustbadge.h"

SpecBegin(NSURL_TRSURLExtensions)

describe(@"NSURL+TRSURLExtensions", ^{
	__block NSURL *profileURL;
	__block NSURL *shopGradeAPIURL;
	__block NSURL *shopGradeAPIURLDebug;
	__block NSURL *productGradeAPIURL;
	__block NSURL *productGradeAPIURLDebug;
	__block NSURL *productReviewAPIURL;
	__block NSURL *productReviewAPIURLDebug;
	__block NSURL *trustMarkURL;
	__block NSURL *trustMarkURLDebug;
	__block TRSShop *testShop;
	beforeAll(^{
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
		NSData *data = [NSData dataWithContentsOfFile:path];
		NSDictionary *shopData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		testShop = [[TRSShop alloc] initWithDictionary:shopData[@"response"][@"data"][@"shop"]];
		profileURL = [NSURL profileURLForShop:testShop];
		shopGradeAPIURL = [NSURL shopGradeAPIURLForTSID:testShop.tsId debug:NO];
		shopGradeAPIURLDebug = [NSURL shopGradeAPIURLForTSID:testShop.tsId debug:YES];
		productGradeAPIURL = [NSURL productGradeAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:NO];
		productGradeAPIURLDebug = [NSURL productGradeAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:YES];
		productReviewAPIURL = [NSURL productReviewAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:NO];
		productReviewAPIURLDebug = [NSURL productReviewAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:YES];
		trustMarkURL = [NSURL trustMarkAPIURLForTSID:testShop.tsId debug:NO];
		trustMarkURLDebug = [NSURL trustMarkAPIURLForTSID:testShop.tsId debug:YES];
	});
	
	afterAll(^{
		profileURL = nil;
		shopGradeAPIURL = nil;
		shopGradeAPIURLDebug = nil;
		testShop = nil;
		trustMarkURL = nil;
		trustMarkURLDebug = nil;
	});
	
	describe(@"+profileURLForShop:", ^{
		
		it(@"returns an NSURL", ^{
			expect([NSURL profileURLForShop:testShop]).to.beKindOf([NSURL class]);
		});
		
		it(@"has the correct prefix", ^{
			NSString *urlString = [profileURL absoluteString];
			expect([urlString hasPrefix:@"https://www.trustedshops."]).to.equal(YES);
		});
		
		it(@"contains the shop's TSID", ^{
			NSString *urlString = [profileURL absoluteString];
			expect([urlString containsString:testShop.tsId]).to.equal(YES);
		});
		
		it(@"points to a html file", ^{
			expect([profileURL pathExtension]).to.equal(@"html");
		});
	});
	
	describe(@"+profileURLForTSID:countryCode:language:", ^{
		
		it(@"returns the same NSURL as +profileURLForShop: with a fitting shop", ^{
			NSURL *fromShop = [NSURL profileURLForShop:testShop];
			NSURL *fromData = [NSURL profileURLForTSID:testShop.tsId
										   countryCode:testShop.targetMarketISO3
											  language:testShop.languageISO2];
			expect([fromData absoluteString]).to.equal([fromShop absoluteString]);
		});
	});
	
	describe(@"+shopGradeAPIURLForTSID:debug:", ^{
		
		it(@"returns an NSURL", ^{
			expect([NSURL shopGradeAPIURLForTSID:testShop.tsId debug:YES]).to.beKindOf([NSURL class]);
			expect([NSURL shopGradeAPIURLForTSID:testShop.tsId debug:NO]).to.beKindOf([NSURL class]);
		});
		
		it(@"has the correct prefix", ^{
			NSString *urlStringDebug = [shopGradeAPIURLDebug absoluteString];
			NSString *urlString = [shopGradeAPIURL absoluteString];
			expect([urlStringDebug hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPointDebug]]).to.equal(YES);
			expect([urlString hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPoint]]).to.equal(YES);
		});
		
		it(@"contains the shop's TSID", ^{
			NSString *urlString = [shopGradeAPIURL absoluteString];
			NSString *urlStringDebug = [shopGradeAPIURLDebug absoluteString];
			expect([urlString containsString:testShop.tsId]).to.equal(YES);
			expect([urlStringDebug containsString:testShop.tsId]).to.equal(YES);
		});
		
		it(@"points to json", ^{
			expect([shopGradeAPIURL pathExtension]).to.equal(@"json");
			expect([shopGradeAPIURLDebug pathExtension]).to.equal(@"json");
		});
	});
	
	describe(@"+productGradeAPIURLForTSID:skuHash:debug:", ^{
		
		it(@"returns an NSURL", ^{
			expect([NSURL productGradeAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:YES]).to.beKindOf([NSURL class]);
			expect([NSURL productGradeAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:NO]).to.beKindOf([NSURL class]);
		});
		
		it(@"has the correct prefix", ^{
			NSString *urlStringDebug = [productGradeAPIURLDebug absoluteString];
			NSString *urlString = [productGradeAPIURL absoluteString];
			expect([urlStringDebug hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPointDebug]]).to.equal(YES);
			expect([urlString hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPoint]]).to.equal(YES);
		});
		
		it(@"contains the shop's TSID", ^{
			NSString *urlString = [productGradeAPIURL absoluteString];
			NSString *urlStringDebug = [productGradeAPIURLDebug absoluteString];
			expect([urlString containsString:testShop.tsId]).to.equal(YES);
			expect([urlStringDebug containsString:testShop.tsId]).to.equal(YES);
		});
		
		it(@"contains the the correct SKU hash", ^{
			NSString *urlString = [productGradeAPIURL absoluteString];
			NSString *urlStringDebug = [productGradeAPIURLDebug absoluteString];
			expect([urlString containsString:@"3230363130"]).to.equal(YES);
			expect([urlStringDebug containsString:@"3230363130"]).to.equal(YES);
		});
		
		it(@"points to json", ^{
			expect([productGradeAPIURL pathExtension]).to.equal(@"json");
			expect([productGradeAPIURLDebug pathExtension]).to.equal(@"json");
		});
	});
	
	describe(@"+productReviewAPIURLForTSID:skuHash:debug:", ^{
		
		it(@"returns an NSURL", ^{
			expect([NSURL productReviewAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:YES]).to.beKindOf([NSURL class]);
			expect([NSURL productReviewAPIURLForTSID:testShop.tsId skuHash:@"3230363130" debug:NO]).to.beKindOf([NSURL class]);
		});
		
		it(@"has the correct prefix", ^{
			NSString *urlStringDebug = [productReviewAPIURLDebug absoluteString];
			NSString *urlString = [productReviewAPIURL absoluteString];
			expect([urlStringDebug hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPointDebug]]).to.equal(YES);
			expect([urlString hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPoint]]).to.equal(YES);
		});
		
		it(@"contains the shop's TSID", ^{
			NSString *urlString = [productReviewAPIURL absoluteString];
			NSString *urlStringDebug = [productReviewAPIURLDebug absoluteString];
			expect([urlString containsString:testShop.tsId]).to.equal(YES);
			expect([urlStringDebug containsString:testShop.tsId]).to.equal(YES);
		});
		
		it(@"contains the the correct SKU hash", ^{
			NSString *urlString = [productReviewAPIURL absoluteString];
			NSString *urlStringDebug = [productReviewAPIURLDebug absoluteString];
			expect([urlString containsString:@"3230363130"]).to.equal(YES);
			expect([urlStringDebug containsString:@"3230363130"]).to.equal(YES);
		});
		
		it(@"points to json", ^{
			expect([productReviewAPIURL pathExtension]).to.equal(@"json");
			expect([productReviewAPIURLDebug pathExtension]).to.equal(@"json");
		});
	});

	describe(@"+trustMarkAPIURLForTSID:andAPIEndPoint:", ^{
		
		it(@"returns an NSURL", ^{
			expect([NSURL trustMarkAPIURLForTSID:testShop.tsId debug:YES]).to.beKindOf([NSURL class]);
			expect([NSURL trustMarkAPIURLForTSID:testShop.tsId debug:NO]).to.beKindOf([NSURL class]);
		});
		
		it(@"has the correct prefix", ^{
			NSString *urlStringDebug = [trustMarkURLDebug absoluteString];
			NSString *urlString = [trustMarkURL absoluteString];
			expect([urlStringDebug hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPointDebug]]).to.equal(YES);
			expect([urlString hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPoint]]).to.equal(YES);
		});
		
		it(@"contains the shop's TSID", ^{
			NSString *urlString = [trustMarkURL absoluteString];
			NSString *urlStringDebug = [trustMarkURLDebug absoluteString];
			expect([urlString containsString:testShop.tsId]).to.equal(YES);
			expect([urlStringDebug containsString:testShop.tsId]).to.equal(YES);
		});
		
		it(@"points to json", ^{
			expect([trustMarkURL pathExtension]).to.equal(@"json");
			expect([trustMarkURLDebug pathExtension]).to.equal(@"json");
		});
	});
});

SpecEnd
