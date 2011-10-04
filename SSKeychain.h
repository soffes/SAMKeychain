//
//  SSKeychain.h
//  SSToolkit
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2009-2011 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

typedef enum {
	SSKeychainErrorBadArguments = -1001,
	SSKeychainErrorNoPassword = -1002,
	SSKeychainErrorInvalidParameter = errSecParam,
	SSKeychainErrorFailedToAllocated = errSecAllocate,
	SSKeychainErrorNotAvailable = errSecNotAvailable,
	SSKeychainErrorAuthorizationFailed = errSecAuthFailed,
	SSKeychainErrorDuplicatedItem = errSecDuplicateItem,
	SSKeychainErrorNotFound = errSecItemNotFound,
	SSKeychainErrorInteractionNotAllowed = errSecInteractionNotAllowed,
	SSKeychainErrorFailedToDecode = errSecDecode
} SSKeychainErrorCode;

extern NSString *SSKeychainErrorDomain;

@interface SSKeychain : NSObject

// Getting Accounts
+ (NSArray *)allAccounts;
+ (NSArray *)allAccounts:(NSError **)error;
+ (NSArray *)accountsForService:(NSString *)serviceName;
+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError **)error;

// Getting Passwords
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

// Deleting Passwords
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

// Setting Passwords
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

@end
