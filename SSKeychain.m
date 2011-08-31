//
//  SSKeychain.m
//  SSToolkit
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright 2009-2011 Sam Soffes. All rights reserved.
//

#import "SSKeychain.h"

NSString *SSKeychainErrorDomain = @"com.samsoffes.sskeychain";

@interface SSKeychain ()
+ (NSMutableDictionary *)queryForService:(NSString *)service account:(NSString *)account;
@end

@implementation SSKeychain

#pragma mark - common methods
+ (NSMutableDictionary *)queryForService:(NSString *)service account:(NSString *)account {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    if (service) { [dictionary setObject:service forKey:(id)kSecAttrService]; }
    if (account) { [dictionary setObject:account forKey:(id)kSecAttrAccount]; }
    return dictionary;
}

#pragma mark - get passwords
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account {
	return [self passwordForService:service account:account error:nil];
}
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
	OSStatus status = SSKeychainErrorBadArguments;
	NSString *result = nil;
	
	if (0 < [service length] && 0 < [account length]) {
		CFDataRef passwordData = NULL;
		NSMutableDictionary *query = [self queryForService:service account:account];
		[query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
		[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
		
		status = SecItemCopyMatching((CFDictionaryRef)query,
											  (CFTypeRef *)&passwordData);
		if (status == noErr && 0 < [(NSData *)passwordData length]) {
			result = [[[NSString alloc] initWithData:(NSData *)passwordData
											encoding:NSUTF8StringEncoding] autorelease];
		}
		
		if (passwordData != NULL) {
			CFRelease(passwordData);
		}
	}
	
	if (status != noErr && error != NULL) {
		*error = [NSError errorWithDomain:SSKeychainErrorDomain code:status userInfo:nil];
	}
	
	return result;
}

#pragma delete passwords
+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account {
	return [self deletePasswordForService:service account:account error:nil];
}
+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
	OSStatus status = SSKeychainErrorBadArguments;
	if (0 < [service length] && 0 < [account length]) {
		NSMutableDictionary *query = [self queryForService:service account:account];
		status = SecItemDelete((CFDictionaryRef)query);
	}
	
	if (status != noErr && error != NULL) {
		*error = [NSError errorWithDomain:SSKeychainErrorDomain code:status userInfo:nil];
	}
	
	return status == noErr;
}

#pragma mark - set passwords
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account {
	return [self setPassword:password forService:service account:account error:nil];
}
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error {
	OSStatus status = SSKeychainErrorBadArguments;
	if (0 < [service length] && 0 < [account length]) {
		[self deletePasswordForService:service account:account];
		if (0 < [password length]) {
			NSMutableDictionary *query = [self queryForService:service account:account];
			NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
			[query setObject:passwordData forKey:(id)kSecValueData];
			status = SecItemAdd((CFDictionaryRef)query, NULL);
		}
	}
	
	if (status != noErr && error != NULL) {
		*error = [NSError errorWithDomain:SSKeychainErrorDomain code:status userInfo:nil];
	}
	
	return status == noErr;
}

@end
