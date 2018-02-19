//
//  TRSNetworkAgent+ShopGradeSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 06/07/16.
//

#import "TRSNetworkAgent+ShopGrade.h"
#import "TRSErrors.h"
#import "TRSTrustbadge.h"
#import "NSURL+TRSURLExtensions.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+HTTPMessage.h>
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>


SpecBegin(TRSNetworkAgent_ShopGrade)

describe(@"TRSNetworkAgent+ShopGrade", ^{
	
	__block TRSNetworkAgent *agent;
	beforeAll(^{
		agent = [[TRSNetworkAgent alloc] init];
		agent.debugMode = YES; // note: we don't test (yet) for non debug. not necessary
	});
	
	afterAll(^{
		agent = nil;
	});
		
	describe(@"-getShopGradeForTrustedShopsID:apiToken:success:failure:", ^{
		
		beforeEach(^{
			[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
				NSURL *usedInAgent = [NSURL shopGradeAPIURLForTSID:@"123" debug:YES];
				return [request.URL isEqual:usedInAgent];
			} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
				return [OHHTTPStubsResponse responseWithData:[[NSString stringWithFormat:@"success"] dataUsingEncoding:NSUTF8StringEncoding]
												  statusCode:200
													 headers:nil];
			}];
		});
		
		afterEach(^{
			[OHHTTPStubs removeAllStubs];
		});
		
		it(@"returns nil for nil ID and token", ^{
			id task = [agent getShopGradeForTrustedShopsID:nil apiToken:nil success:nil failure:nil];
			expect(task).to.beNil();
		});
		
		it(@"calls its failure block for nil token and or tsid", ^{
			waitUntil(^(DoneCallback done) {
				[agent getShopGradeForTrustedShopsID:nil apiToken:nil success:nil failure:^(NSError *error) {
					done();
				}];
			});
		});
		
		it(@"returns a NSURLSessionDataTask object for a given ID and token", ^{
			id task = [agent getShopGradeForTrustedShopsID:@"ID" apiToken:@"token" success:nil failure:nil];
			expect(task).to.beKindOf([NSURLSessionDataTask class]);
		});
		
		it(@"has the correct URL", ^{
			NSURLSessionDataTask *task = (NSURLSessionDataTask *)[agent getShopGradeForTrustedShopsID:@"123"
																							 apiToken:@"apiToken"
																							  success:nil
																							  failure:nil];
			expect(task.originalRequest.URL).to.equal([NSURL shopGradeAPIURLForTSID:@"123" debug:YES]);
		});
		
		it(@"calls '-GET:success:failure'", ^{
			id agentMock = OCMPartialMock(agent);
			OCMExpect([agentMock GET:[NSURL shopGradeAPIURLForTSID:@"123" debug:YES]
						   authToken:@"authToken"
							 success:[OCMArg any]
							 failure:[OCMArg any]]);
			
			[agent getShopGradeForTrustedShopsID:@"123" apiToken:@"authToken" success:nil failure:nil];
			
			OCMVerifyAll(agentMock);
		});
		
		context(@"when successful", ^{
			
			beforeEach(^{
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"123123" debug:YES]];
				} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
					NSBundle *bundle = [NSBundle bundleForClass:[self class]];
					NSString *path = [bundle pathForResource:@"shopGrade" ofType:@"data"];
					NSData *data = [NSData dataWithContentsOfFile:path];
					return [OHHTTPStubsResponse responseWithData:data
													  statusCode:200
														 headers:nil];
				}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"executes the success block and passes a 'NSDictionary' as data ", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"123123"
												apiToken:@"apiToken"
												 success:^(NSDictionary *gradeData) {
													 expect(gradeData).notTo.beNil();
													 expect(gradeData).to.beKindOf([NSDictionary class]);
													 done();
												 }
												 failure:nil];
				});
			});
			
		});
		
		context(@"when receiving a bad request", ^{
			
			__block NSString *trustedShopsID;
			beforeEach(^{
				trustedShopsID = @"123123123";
				NSString *file = OHPathForFileInBundle(@"shopGrade-badrequest.response", [NSBundle bundleForClass:[self class]]);
				NSData *messageData = [NSData dataWithContentsOfFile:file];
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithHTTPMessageData:messageData];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"123123123" debug:YES]];
				}
									withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
										return response;
									}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"passes a custom error code (Invalid TSID)", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"123123123"
												apiToken:@"apiToken"
												 success:nil
												 failure:^(NSError *error) {
													 expect(error.code).to.equal(TRSErrorDomainInvalidTSID);
													 done();
												 }];
				});
			});
			
		});
		
		context(@"when receiving an incpmplete response", ^{
			
			__block NSString *trustedShopsID;
			beforeEach(^{
				trustedShopsID = @"123123123";
				NSString *file = OHPathForFileInBundle(@"shopGrade-incomplete.response", [NSBundle bundleForClass:[self class]]);
				NSData *messageData = [NSData dataWithContentsOfFile:file];
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithHTTPMessageData:messageData];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"123123123" debug:YES]];
				}
									withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
										return response;
									}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"passes a custom error code (Invalid data)", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"123123123"
												apiToken:@"apiToken"
												 success:nil
												 failure:^(NSError *error) {
													 expect(error.code).to.equal(TRSErrorDomainInvalidData);
													 done();
												 }];
				});
			});
			
		});
		
		context(@"when receiving a not found error", ^{
			
			__block NSString *trustedShopsID;
			beforeEach(^{
				trustedShopsID = @"000111222333444555666777888999111";
				NSString *file = OHPathForFileInBundle(@"shopGrade-notfound.response", [NSBundle bundleForClass:[self class]]);
				NSData *messageData = [NSData dataWithContentsOfFile:file];
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithHTTPMessageData:messageData];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"000111222333444555666777888999111" debug:YES]];
				}
									withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
										return response;
									}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"passes a custom error code (TSID not found)", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"000111222333444555666777888999111"
												apiToken:@"apiToken"
												 success:nil
												 failure:^(NSError *error) {
													 expect(error.code).to.equal(TRSErrorDomainTSIDNotFound);
													 done();
												 }];
				});
			});
			
		});
		
		context(@"when receiving an unkown error", ^{
			
			__block NSString *trustedShopsID;
			beforeEach(^{
				trustedShopsID = @"000000000000000000000000000000000";
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData:[[NSString stringWithFormat:@"not a HTTP status code"] dataUsingEncoding:NSUTF8StringEncoding]
																		   statusCode:460
																			  headers:nil];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"000000000000000000000000000000000" debug:YES]];
				}
									withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
										return response;
									}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"passes a custom error code (unknown error)", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"000000000000000000000000000000000"
												apiToken:@"apiToken"
												 success:nil
												 failure:^(NSError *error) {
													 expect(error.code).to.equal(TRSErrorDomainUnknownError);
													 done();
												 }];
				});
			});
			
		});
		
		context(@"when data is invalid json", ^{
			
			__block NSString *trustedShopsID;
			beforeEach(^{
				trustedShopsID = @"111222333444555666777888999111222";
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData:[[NSString stringWithFormat:@"no json data"] dataUsingEncoding:NSUTF8StringEncoding]
																		   statusCode:200
																			  headers:nil];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"111222333444555666777888999111222" debug:YES]];
				} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
					return response;
				}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"passes a custom error code (Invalid data)", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"111222333444555666777888999111222"
												apiToken:@"apiToken"
												 success:nil
												 failure:^(NSError *error) {
													 expect(error.code).to.equal(TRSErrorDomainInvalidData);
													 done();
												 }];
				});
			});
			
		});
		
		context(@"when data is valid json, but has wrong fields", ^{
			
			__block NSString *trustedShopsID;
			beforeEach(^{
				trustedShopsID = @"111222333444555666777888999111223";
				NSDictionary *wrongJSON = @{@"response" : @{@"code" : @200,
															@"data" : @{@"shop" : @"wrongtype!",
																		@"wrongfield2" : @"useless"}}};
				NSData *asData = [NSJSONSerialization dataWithJSONObject:wrongJSON options:NSJSONWritingPrettyPrinted error:nil];
				NSString *asString = [[NSString alloc] initWithData:asData encoding:NSUTF8StringEncoding];
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData:[asString dataUsingEncoding:NSUTF8StringEncoding]
																		   statusCode:200
																			  headers:nil];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"111222333444555666777888999111223" debug:YES]];
				} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
					return response;
				}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"passes a custom error code (Invalid data)", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"111222333444555666777888999111223"
												apiToken:@"apiToken"
												 success:nil
												 failure:^(NSError *error) {
													 expect(error.code).to.equal(TRSErrorDomainInvalidData);
													 done();
												 }];
				});
			});
			
		});
		
		// note: atm the public API doesn't require the token anyways, but the class is built to work with a token already
		// For now I use a simple string as the response's data, once the API requires a token I should provide
		// a real response object by adding another fixture file.
		context(@"when using an invalid token", ^{
			
			__block NSString *trustedShopsID;
			beforeEach(^{
				trustedShopsID = @"111222333444555666777888999111224";
				NSString *responseData = @"This needs to be adapted once the API requires a token!";
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding]
																		   statusCode:401
																			  headers:nil];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					return [request.URL isEqual:[NSURL shopGradeAPIURLForTSID:@"111222333444555666777888999111224" debug:YES]];
				} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
					return response;
				}];
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
			});
			
			it(@"passes a custom error code (Invalid data)", ^{
				waitUntil(^(DoneCallback done) {
					[agent getShopGradeForTrustedShopsID:@"111222333444555666777888999111224"
												apiToken:@"apiToken"
												 success:nil
												 failure:^(NSError *error) {
													 expect(error.code).to.equal(TRSErrorDomainInvalidAPIToken);
													 done();
												 }];
				});
			});
			
		});
		
	});
	
});

SpecEnd
