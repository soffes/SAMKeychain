//
//  SSKeychainTests.m
//  SSKeychainTests
//
//  Created by Sam Soffes on 10/3/11.
//  Copyright (c) 2011-2014 Sam Soffes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SSKeychain.h"

static NSString *kSSToolkitTestsServiceName = @"SSToolkitTestService";
static NSString *kSSToolkitTestsAccountName = @"SSToolkitTestAccount";
static NSString *kSSToolkitTestsPassword = @"SSToolkitTestPassword";
static NSString *kSSToolkitTestsLabel = @"SSToolkitLabel";

@interface SSKeychainTests : XCTestCase
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
    query.label = kSSToolkitTestsLabel;
    XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);
    
    // check password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    query.password = nil;
    XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
    XCTAssertEqualObjects(query.password, kSSToolkitTestsPassword, @"Passwords were not equal");
    
    // set password to a dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:1], @"number",
                                @"4 8 15 16 23 42", @"string",
                                nil];
    query.passwordObject = dictionary;
    XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);
    
    // check password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    query.passwordObject = nil;
    XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
    XCTAssertEqualObjects(query.passwordObject, dictionary, @"Passwords were not equal");
    
    // check all accounts
    query = [[SSKeychainQuery alloc] init];
    accounts = [query fetchAll:&error];
    XCTAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
    XCTAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // check accounts for service
    query.service = kSSToolkitTestsServiceName;
    accounts = [query fetchAll:&error];
    XCTAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
    XCTAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // delete password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    XCTAssertTrue([query deleteItem:&error], @"Unable to delete password: %@", error);
    
    // check if saving with missing informations is handled correctly
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    XCTAssertFalse([query save:&error], @"Function should return NO as not all needed information is provided: %@", error);
    
    query = [[SSKeychainQuery alloc] init];
    query.password = kSSToolkitTestsPassword;
    query.account = kSSToolkitTestsAccountName;
    XCTAssertFalse([query save:&error], @"Function should return NO as not all needed information is provided: %@", error);

    query = [[SSKeychainQuery alloc] init];
    query.password = kSSToolkitTestsPassword;
    query.service = kSSToolkitTestsServiceName;
    XCTAssertFalse([query save:&error], @"Function save should return NO if not all needed information is provided: %@", error);
    
    // check if deletion with missing information is handled correctly
    query = [[SSKeychainQuery alloc] init];
    query.account = kSSToolkitTestsAccountName;
    XCTAssertFalse([query deleteItem:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);

    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    XCTAssertFalse([query deleteItem:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);
    
    // check if fetch handels missing information correctly
    query = [[SSKeychainQuery alloc] init];
    query.account = kSSToolkitTestsAccountName;
    XCTAssertFalse([query fetch:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);
    
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    XCTAssertFalse([query fetch:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);
  
    // test kSecAttrSynchronizable
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    query.password = kSSToolkitTestsPassword;
    query.synchronizationMode = SSKeychainQuerySynchronizationModeYes;
    XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);

    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    query.password = nil;
    query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
    XCTAssertFalse([query fetch:&error], @"Fetch should fail when trying to fetch an unsynced password that was saved as synced.");
    XCTAssertNotEqualObjects(query.password, kSSToolkitTestsPassword, @"Passwords should not be equal when trying to fetch an unsynced password that was saved as synced.");
  
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    query.password = nil;
    query.synchronizationMode = SSKeychainQuerySynchronizationModeAny;
    XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
    XCTAssertEqualObjects(query.password, kSSToolkitTestsPassword, @"Passwords were not equal");
}


- (void)testSSKeychain {
    NSError *error = nil;
    
    // Test Class Methods of SSKeychain
    
    // create a new keychain item
    XCTAssertTrue([SSKeychain setPassword:kSSToolkitTestsPassword forService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName error:&error], @"Unable to save item: %@", error);
    
    // check password
    XCTAssertEqualObjects([SSKeychain passwordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName], kSSToolkitTestsPassword, @"Passwords were not equal");
    
    // check all accounts
    XCTAssertTrue([self _accounts:[SSKeychain allAccounts] containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    // check account
    XCTAssertTrue([self _accounts:[SSKeychain accountsForService:kSSToolkitTestsServiceName] containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // delete password
    XCTAssertTrue([SSKeychain deletePasswordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName error:&error], @"Unable to delete password: %@", error);
    
    // set password and delete it without error function
    XCTAssertTrue([SSKeychain setPassword:kSSToolkitTestsPassword forService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName], @"Unable to save item");
    XCTAssertTrue([SSKeychain deletePasswordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName], @"Unable to delete password");
    
#if __IPHONE_4_0 && TARGET_OS_IPHONE
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlockedThisDeviceOnly];
    XCTAssertTrue([SSKeychain accessibilityType] == kSecAttrAccessibleWhenUnlockedThisDeviceOnly, @"Unable to verify accessibilityType");
#endif
}


#pragma mark - Private

- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name {
	for (NSDictionary *dictionary in accounts) {
		if ([[dictionary objectForKey:@"acct"] isEqualToString:name]) {
			return YES;
		}
	}
	return NO;
}

@end
