//
//  SSKeychain.m
//  SSToolkit
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2009-2011 Sam Soffes. All rights reserved.
//

#import "SSKeychain.h"

NSString *const kSSKeychainErrorDomain = @"com.samsoffes.sskeychain";

NSString *const kSSKeychainAccountKey = @"acct";
NSString *const kSSKeychainCreatedAtKey = @"cdat";
NSString *const kSSKeychainClassKey = @"labl";
NSString *const kSSKeychainDescriptionKey = @"desc";
NSString *const kSSKeychainLabelKey = @"labl";
NSString *const kSSKeychainLastModifiedKey = @"mdat";
NSString *const kSSKeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE  
CFTypeRef SSKeychainAccessibilityType = NULL;
#endif

@interface SSKeychain ()
+ (NSMutableDictionary *)_queryForService:(NSString *)service account:(NSString *)account;
+ (NSError *)_errorWithCode:(OSStatus) code;
@end

@implementation SSKeychain

#pragma mark - Getting Accounts

+ (NSArray *)allAccounts {
    return [self accountsForService:nil error:nil];
}


+ (NSArray *)allAccounts:(NSError **)error {
    return [self accountsForService:nil error:error];
}


+ (NSArray *)accountsForService:(NSString *)service {
    return [self accountsForService:service error:nil];
}


+ (NSArray *)accountsForService:(NSString *)service error:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
    NSMutableDictionary *query = [self _queryForService:service account:nil];
#if __has_feature(objc_arc)
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
#else
    [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    [query setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
#endif
	
	CFTypeRef result = NULL;
#if __has_feature(objc_arc)
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
#else
	status = SecItemCopyMatching((CFDictionaryRef)query, &result);
#endif
    if (status != errSecSuccess && error != NULL) {
		*error = [self _errorWithCode:status];
		return nil;
	}
	
#if __has_feature(objc_arc)
	return (__bridge_transfer NSArray *)result;
#else
    return [(NSArray *)result autorelease];
#endif
}


#pragma mark - Getting Passwords

+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account {
	return [self passwordForService:service account:account error:nil];
}


+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    NSData *data = [self passwordDataForService:service account:account error:error];
	if (data.length > 0) {
		NSString *string = [[NSString alloc] initWithData:(NSData *)data encoding:NSUTF8StringEncoding];
#if !__has_feature(objc_arc)
		[string autorelease];
#endif
		return string;
	}
	
	return nil;
}


+ (NSData *)passwordDataForService:(NSString *)service account:(NSString *)account {
    return [self passwordDataForService:service account:account error:nil];
}


+ (NSData *)passwordDataForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (!service || !account) {
		if (error) {
			*error = [self _errorWithCode:status];
		}
		return nil;
	}
	
	CFTypeRef result = NULL;	
	NSMutableDictionary *query = [self _queryForService:service account:account];
#if __has_feature(objc_arc)
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
#else
	[query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	status = SecItemCopyMatching((CFDictionaryRef)query, &result);
#endif
	
	if (status != errSecSuccess && error != NULL) {
		*error = [self _errorWithCode:status];
		return nil;
	}
	
#if __has_feature(objc_arc)
	return (__bridge_transfer NSData *)result;
#else
    return [(NSData *)result autorelease];
#endif
}


#pragma mark - Deleting Passwords

+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account {
	return [self deletePasswordForService:service account:account error:nil];
}


+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
	OSStatus status = SSKeychainErrorBadArguments;
	if (service && account) {
		NSMutableDictionary *query = [self _queryForService:service account:account];
#if TARGET_OS_IPHONE && __has_feature(objc_arc)
		status = SecItemDelete((__bridge CFDictionaryRef)query);
#elif TARGET_OS_IPHONE
		status = SecItemDelete((CFDictionaryRef)query);
#else
        CFTypeRef result;
    #if __has_feature(objc_arc)
        [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnRef];
        status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    #else
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
        status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    #endif
        if (errSecSuccess == status) {
            status = SecKeychainItemDelete((SecKeychainItemRef) result);
            CFRelease(result);
        }
#endif
	}
	if (status != errSecSuccess && error != NULL) {
		*error = [self _errorWithCode:status];
	}
	return (status == errSecSuccess);
    
}


#pragma mark - Setting Passwords

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account {
	return [self setPassword:password forService:service account:account error:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    return [self setPasswordData:data forService:service account:account error:error];
}


+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)service account:(NSString *)account {
    return [self setPasswordData:password forService:service account:account error:nil];
}


+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (password && service && account) {
        [self deletePasswordForService:service account:account];
        NSMutableDictionary *query = [self _queryForService:service account:account];
#if __has_feature(objc_arc)
		[query setObject:password forKey:(__bridge id)kSecValueData];
#else
		[query setObject:password forKey:(id)kSecValueData];
#endif
		
#if __IPHONE_4_0 && TARGET_OS_IPHONE
		if (SSKeychainAccessibilityType) {
#if __has_feature(objc_arc)
			[query setObject:(id)[self accessibilityType] forKey:(__bridge id)kSecAttrAccessible];
#else
			[query setObject:(id)[self accessibilityType] forKey:(id)kSecAttrAccessible];
#endif
		}
#endif
		
#if __has_feature(objc_arc)
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
#else
		status = SecItemAdd((CFDictionaryRef)query, NULL);
#endif
	}
	if (status != errSecSuccess && error != NULL) {
		*error = [self _errorWithCode:status];
	}
	return (status == errSecSuccess);
}


#pragma mark - Configuration

#if __IPHONE_4_0 && TARGET_OS_IPHONE 
+ (CFTypeRef)accessibilityType {
	return SSKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
	CFRetain(accessibilityType);
	if (SSKeychainAccessibilityType) {
		CFRelease(SSKeychainAccessibilityType);
	}
	SSKeychainAccessibilityType = accessibilityType;
}
#endif


#pragma mark - Private

+ (NSMutableDictionary *)_queryForService:(NSString *)service account:(NSString *)account {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
#if __has_feature(objc_arc)
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
#else
	[dictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
#endif
	
    if (service) {
#if __has_feature(objc_arc)
		[dictionary setObject:service forKey:(__bridge id)kSecAttrService];
#else
		[dictionary setObject:service forKey:(id)kSecAttrService];
#endif
	}
	
    if (account) {
#if __has_feature(objc_arc)
		[dictionary setObject:account forKey:(__bridge id)kSecAttrAccount];
#else
		[dictionary setObject:account forKey:(id)kSecAttrAccount];
#endif
	}
	
    return dictionary;
}


+ (NSError *)_errorWithCode:(OSStatus) code {
    NSString *message = nil;
    switch (code) {
        case errSecSuccess: return nil;
        case SSKeychainErrorBadArguments: message = @"Some of the arguments were invalid"; break;
          
#if TARGET_OS_IPHONE
        case errSecUnimplemented: message = @"Function or operation not implemented"; break;
        case errSecParam: message = @"One or more parameters passed to a function were not valid"; break;
        case errSecAllocate: message = @"Failed to allocate memory"; break;
        case errSecNotAvailable: message = @"No keychain is available. You may need to restart your computer"; break;
        case errSecDuplicateItem: message = @"The specified item already exists in the keychain"; break;
        case errSecItemNotFound: message = @"The specified item could not be found in the keychain"; break;
        case errSecInteractionNotAllowed: message = @"User interaction is not allowed"; break;
        case errSecDecode: message = @"Unable to decode the provided data"; break;
        case errSecAuthFailed: message = @"The user name or passphrase you entered is not correct"; break;
        default: message = @"Refer to SecBase.h for description";
#elif __has_feature(objc_arc)
        default:
            message = (__bridge_transfer NSString *)SecCopyErrorMessageString(code, NULL);
#else
        default:
            message = [(id) SecCopyErrorMessageString(code, NULL) autorelease];
#endif
    }
    
    NSDictionary *userInfo = nil;
    if (message != nil) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:kSSKeychainErrorDomain
                               code:code
                           userInfo:userInfo];
}

@end
