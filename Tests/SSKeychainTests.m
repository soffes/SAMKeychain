//
//  SSKeychainTests.m
//  SSKeychainTests
//
//  Created by Sam Soffes on 10/3/11.
//  Copyright (c) 2011-2014 Sam Soffes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SSKeychain.h"

static NSString *const kSSKeychainServiceName = @"SSToolkitTestService";
static NSString *const kSSKeychainAccountName = @"SSToolkitTestAccount";
static NSString *const kSSKeychainPassword = @"SSToolkitTestPassword";
static NSString *const kSSKeychainLabel = @"SSToolkitLabel";

@interface SSKeychainTests : XCTestCase
@end

@implementation SSKeychainTests

- (void)testNewItem {
	// New item
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.password = kSSKeychainPassword;
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;
	query.label = kSSKeychainLabel;

	NSError *error;
	XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);

	// Look up
	query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;
	query.password = nil;

	XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
	XCTAssertEqualObjects(query.password, kSSKeychainPassword, @"Passwords were not equal");

	// Search for all accounts
	query = [[SSKeychainQuery alloc] init];
	NSArray *accounts = [query fetchAll:&error];
	XCTAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
	XCTAssertTrue([self _accounts:accounts containsAccountWithName:kSSKeychainAccountName], @"Matching account was not returned");

	// Check accounts for service
	query.service = kSSKeychainServiceName;
	accounts = [query fetchAll:&error];
	XCTAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
	XCTAssertTrue([self _accounts:accounts containsAccountWithName:kSSKeychainAccountName], @"Matching account was not returned");

	// Delete
	query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;
	XCTAssertTrue([query deleteItem:&error], @"Unable to delete password: %@", error);
}


- (void)testPasswordObject {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;

	NSDictionary *dictionary = @{@"number": @42, @"string": @"Hello World"};
	query.passwordObject = dictionary;

	NSError *error;
	XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);

	query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;
	query.passwordObject = nil;
	XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
	XCTAssertEqualObjects(query.passwordObject, dictionary, @"Passwords were not equal");
}


- (void)testMissingInformation {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;

	NSError *error;
	XCTAssertFalse([query save:&error], @"Function should return NO as not all needed information is provided: %@", error);
	
	query = [[SSKeychainQuery alloc] init];
	query.password = kSSKeychainPassword;
	query.account = kSSKeychainAccountName;
	XCTAssertFalse([query save:&error], @"Function should return NO as not all needed information is provided: %@", error);

	query = [[SSKeychainQuery alloc] init];
	query.password = kSSKeychainPassword;
	query.service = kSSKeychainServiceName;
	XCTAssertFalse([query save:&error], @"Function save should return NO if not all needed information is provided: %@", error);
}


- (void)testDeleteWithMissingInformation {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.account = kSSKeychainAccountName;

	NSError *error;
	XCTAssertFalse([query deleteItem:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);

	query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	XCTAssertFalse([query deleteItem:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);
	
	// check if fetch handels missing information correctly
	query = [[SSKeychainQuery alloc] init];
	query.account = kSSKeychainAccountName;
	XCTAssertFalse([query fetch:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);
	
	query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	XCTAssertFalse([query fetch:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);
}


- (void)testSynchronizable {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;
	query.password = kSSKeychainPassword;
	query.synchronizationMode = SSKeychainQuerySynchronizationModeYes;

	NSError *error;
	XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);

	query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;
	query.password = nil;
	query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
	XCTAssertFalse([query fetch:&error], @"Fetch should fail when trying to fetch an unsynced password that was saved as synced.");
	XCTAssertNotEqualObjects(query.password, kSSKeychainPassword, @"Passwords should not be equal when trying to fetch an unsynced password that was saved as synced.");
  
	query = [[SSKeychainQuery alloc] init];
	query.service = kSSKeychainServiceName;
	query.account = kSSKeychainAccountName;
	query.password = nil;
	query.synchronizationMode = SSKeychainQuerySynchronizationModeAny;
	XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
	XCTAssertEqualObjects(query.password, kSSKeychainPassword, @"Passwords were not equal");
}


// Test Class Methods of SSKeychain
- (void)testSSKeychain {
	NSError *error = nil;
	
	// create a new keychain item
	XCTAssertTrue([SSKeychain setPassword:kSSKeychainPassword forService:kSSKeychainServiceName account:kSSKeychainAccountName error:&error], @"Unable to save item: %@", error);
	
	// check password
	XCTAssertEqualObjects([SSKeychain passwordForService:kSSKeychainServiceName account:kSSKeychainAccountName], kSSKeychainPassword, @"Passwords were not equal");
	
	// check all accounts
	XCTAssertTrue([self _accounts:[SSKeychain allAccounts] containsAccountWithName:kSSKeychainAccountName], @"Matching account was not returned");
	// check account
	XCTAssertTrue([self _accounts:[SSKeychain accountsForService:kSSKeychainServiceName] containsAccountWithName:kSSKeychainAccountName], @"Matching account was not returned");
	
	// delete password
	XCTAssertTrue([SSKeychain deletePasswordForService:kSSKeychainServiceName account:kSSKeychainAccountName error:&error], @"Unable to delete password: %@", error);
	
	// set password and delete it without error function
	XCTAssertTrue([SSKeychain setPassword:kSSKeychainPassword forService:kSSKeychainServiceName account:kSSKeychainAccountName], @"Unable to save item");
	XCTAssertTrue([SSKeychain deletePasswordForService:kSSKeychainServiceName account:kSSKeychainAccountName], @"Unable to delete password");
	
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
