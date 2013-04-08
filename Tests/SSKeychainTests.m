//
//  SSKeychainTests.m
//  SSKeychainTests
//
//  Created by Sam Soffes on 10/3/11.
//  Copyright (c) 2011 Sam Soffes. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SSKeychain.h"

static NSString *kSSToolkitTestsServiceName = @"SSToolkitTestService";
static NSString *kSSToolkitTestsAccountName = @"SSToolkitTestAccount";
static NSString *kSSToolkitTestsPassword = @"SSToolkitTestPassword";

@interface SSKeychainTests : SenTestCase

- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name;

@end

@implementation SSKeychainTests

- (void)testAll {
    SSKeychainQuery *query = nil;
    NSError *error = nil;
    NSArray *accounts = nil;
    
    // create a new keychain item
    query = [[SSKeychainQuery alloc] init];
    query.password = kSSToolkitTestsPassword;
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertTrue([query save:&error], @"Unable to save item: %@", error);
    
    // check password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
    STAssertEqualObjects(query.password, kSSToolkitTestsPassword, @"Passwords were not equal");
    
    // set password to a dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:1], @"number",
                                @"4 8 15 16 23 42", @"string",
                                nil];
    query.passwordObject = dictionary;
    STAssertTrue([query save:&error], @"Unable to save item: %@", error);
    
    // check password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
    STAssertEqualObjects(query.passwordObject, dictionary, @"Passwords were not equal");
    
    // check all accounts
    query = [[SSKeychainQuery alloc] init];
    accounts = [query fetchAll:&error];
    STAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
    STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // check accounts for service
    query.service = kSSToolkitTestsServiceName;
    accounts = [query fetchAll:&error];
    STAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
    STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // delete password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertTrue([query delete:&error], @"Unable to delete password: %@", error);
}


- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name {
	for (NSDictionary *dictionary in accounts) {
		if ([[dictionary objectForKey:@"acct"] isEqualToString:name]) {
			return YES;
		}
	}
	return NO;
}

@end
