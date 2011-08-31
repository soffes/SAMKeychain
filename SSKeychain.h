//
//  SSKeychain.h
//  SSToolkit
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright 2009-2011 Sam Soffes. All rights reserved.
//

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

@interface SSKeychain : NSObject {
	
}

// get accounts
+ (NSArray *)accounts;
+ (NSArray *)accounts:(NSError **)error;
+ (NSArray *)accountsForService:(NSString *)service;
+ (NSArray *)accountsForService:(NSString *)service error:(NSError **)error;

// get passwords
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account;
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

// delete passwords
+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

// set passwords
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error;

@end
