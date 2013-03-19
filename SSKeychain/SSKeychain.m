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

#if __has_feature(objc_arc)
    #define SSKeychainBridgedCast(type) __bridge type
    #define SSKeychainBridgeTransferCast(type) __bridge_transfer type
    #define SSKeychainAutorelease(stmt) stmt
#else
    #define SSKeychainBridgedCast(type) type
    #define SSKeychainBridgeTransferCast(type) type
    #define SSKeychainAutorelease(stmt) [stmt autorelease]
#endif


#if __IPHONE_4_0 && TARGET_OS_IPHONE
CFTypeRef SSKeychainAccessibilityType = NULL;
#endif

@interface SSKeychain ()
+ (NSMutableDictionary *)_queryForService:(NSString *)service
                                  account:(NSString *)account
                              accessGroup:(NSString *)accessGroup;
+ (NSError *)_errorWithCode:(OSStatus) code;

+ (NSArray *)accountsForService:(NSString *)serviceName accessGroup:(NSString *)accessGroup error:(NSError **)error;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup  error:(NSError **)error;
+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup error:(NSError **)error;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup error:(NSError **)error;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup error:(NSError **)error;
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup error:(NSError **)error;

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


+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError **)error {
    return [self accountsForService:serviceName accessGroup:nil error:error];
}


+ (NSArray *)accountsForService:(NSString *)service
                    accessGroup:(NSString *)accessGroup
                          error:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
    NSMutableDictionary *query = [self _queryForService:service account:nil accessGroup:accessGroup];
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;
    query[(id)kSecMatchLimit] = (id)kSecMatchLimitAll;
	
	CFTypeRef result = NULL;
    status = SecItemCopyMatching((SSKeychainBridgedCast(CFDictionaryRef))query, &result);
    if (status != errSecSuccess && error != NULL) {
		*error = [self _errorWithCode:status];
		return nil;
	}
    
    return SSKeychainAutorelease((SSKeychainBridgeTransferCast(NSArray *))result);
}


#pragma mark - Getting Passwords

+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account {
	return [self passwordForService:service account:account error:nil];
}


+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    return [self passwordForService:serviceName account:account accessGroup:nil error:error];
}


+ (NSString *)passwordForService:(NSString *)service
                         account:(NSString *)account
                     accessGroup:(NSString *)accessGroup
                           error:(NSError **)error {
    NSData *data = [self passwordDataForService:service
                                        account:account
                                    accessGroup:accessGroup
                                          error:error];
	if (data.length > 0) {
		NSString *string = [[NSString alloc] initWithData:(NSData *)data encoding:NSUTF8StringEncoding];
        return SSKeychainAutorelease(string);
	}
	
	return nil;
}


+ (NSData *)passwordDataForService:(NSString *)service account:(NSString *)account {
    return [self passwordDataForService:service account:account error:nil];
}


+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    return [self passwordDataForService:serviceName account:account accessGroup:nil error:error];
}


+ (NSData *)passwordDataForService:(NSString *)service
                           account:(NSString *)account
                       accessGroup:(NSString *)accessGroup
                             error:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (!service || !account) {
		if (error) {
			*error = [self _errorWithCode:status];
		}
		return nil;
	}
	
	CFTypeRef result = NULL;	
	NSMutableDictionary *query = [self _queryForService:service account:account accessGroup:accessGroup];
    query[(id)kSecReturnData] = (id)kCFBooleanTrue;
    query[(id)kSecMatchLimit] = (id)kSecMatchLimitOne;
    status = SecItemCopyMatching((SSKeychainBridgedCast(CFDictionaryRef))query, &result);
	
	if (status != errSecSuccess && error != NULL) {
		*error = [self _errorWithCode:status];
		return nil;
	}
    
    return SSKeychainAutorelease((SSKeychainBridgeTransferCast(NSData *))result);
}


#pragma mark - Deleting Passwords

+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account {
	return [self deletePasswordForService:service account:account error:nil];
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    return [self deletePasswordForService:serviceName account:account accessGroup:nil error:error];
}


+ (BOOL)deletePasswordForService:(NSString *)service
                         account:(NSString *)account
                     accessGroup:(NSString *)accessGroup
                           error:(NSError **)error {
	OSStatus status = SSKeychainErrorBadArguments;
	if (service && account) {
        NSMutableDictionary *query = [self _queryForService:service account:account accessGroup:accessGroup];
#if TARGET_OS_IPHONE
        status = SecItemDelete((SSKeychainBridgedCast(CFDictionaryRef))query);
#else
        CFTypeRef result = NULL;
        query[(id)kSecReturnRef] = (id)kCFBooleanTrue;
        status = SecItemCopyMatching((SSKeychainBridgedCast(CFDictionaryRef))query, &result);
        if (status == errSecSuccess) {
            status = SecKeychainItemDelete((SecKeychainItemRef)result);
            CFRelease(result);
        }
#endif
        
        if (status != errSecSuccess && error != NULL) {
            *error = [self _errorWithCode:status];
        }
    }
    
    return (status == errSecSuccess);
}


#pragma mark - Setting Passwords

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account {
	return [self setPassword:password forService:service account:account error:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    return [self setPassword:password forService:serviceName account:account accessGroup:nil error:error];
}


+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
            account:(NSString *)account
        accessGroup:(NSString *)accessGroup
              error:(NSError **)error {
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    return [self setPasswordData:data forService:service account:account accessGroup:accessGroup error:error];
}


+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)service account:(NSString *)account {
    return [self setPasswordData:password forService:service account:account error:nil];
}


+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    return [self setPasswordData:password forService:serviceName account:account accessGroup:nil error:error];
}


+ (BOOL)setPasswordData:(NSData *)password
             forService:(NSString *)service
                account:(NSString *)account
            accessGroup:(NSString *)accessGroup
                  error:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (password && service && account) {
        [self deletePasswordForService:service account:account];
        NSMutableDictionary *query = [self _queryForService:service
                                                    account:account
                                                accessGroup:accessGroup];
        query[(id)kSecValueData] = password;
		
#if __IPHONE_4_0 && TARGET_OS_IPHONE
		if (SSKeychainAccessibilityType) {
            query[(id)kSecAttrAccessible] = (id)[self accessibilityType];
		}
#endif
        
        status = SecItemAdd((SSKeychainBridgedCast(CFDictionaryRef))query, NULL);
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

+ (NSMutableDictionary *)_queryForService:(NSString *)service
                                  account:(NSString *)account
                              accessGroup:(NSString *)accessGroup {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    dictionary[(id)kSecClass] = (id)kSecClassGenericPassword;
    
    if (service) {
        dictionary[(id)kSecAttrService] = service;
    }
    
    if (account) {
        dictionary[(id)kSecAttrAccount] = account;
    }
    
#if __IPHONE_3_0 && TARGET_OS_IPHONE
    if (accessGroup) {
        dictionary[(id)kSecAttrAccessGroup] = accessGroup;
    }
#endif
    
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
#else
        default:
            message = SSKeychainAutorelease((SSKeychainBridgeTransferCast(NSString *))SecCopyErrorMessageString(code, NULL));
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
