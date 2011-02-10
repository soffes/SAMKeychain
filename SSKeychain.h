//
//  SSKeychain.h
//  SSToolkit
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

enum {
	SSKeychainErrorBadArguments = -1001,
	SSKeychainErrorNoPassword = -1002
};

extern NSString *SSKeychainErrorDomain;

@interface SSKeychain : NSObject

+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account;
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error;

@end
