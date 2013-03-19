//
//  SSKeychainQuery.m
//  SSKeychain
//
//  Created by Caleb Davenport on 3/18/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import <Security/Security.h>

#import "SSKeychainQuery.h"

#if __has_feature(objc_arc)
    #define SSKeychainQueryBridgedCast(type) __bridge type
    #define SSKeychainQueryBridgeTransferCast(type) __bridge_transfer type
    #define SSKeychainQueryAutorelease(stmt) stmt
#else
    #define SSKeychainQueryBridgedCast(type) type
    #define SSKeychainQueryBridgeTransferCast(type) type
    #define SSKeychainQueryAutorelease(stmt) [stmt autorelease]
#endif

#if __IPHONE_4_0 && TARGET_OS_IPHONE
    CFTypeRef SSKeychainAccessibilityType = NULL;
#endif

NSString * const SSKeychainErrorDomain = @"com.samsoffes.sskeychain";

@implementation SSKeychainQuery

@synthesize account = _account;
@synthesize service = _service;
@synthesize accessGroup = _accessGroup;
@synthesize passwordData = _passwordData;

#pragma mark - NSObject

#if !__has_feature(objc_arc)
- (void)dealloc {
    [_account release]; _account = nil;
    [_service release]; _service = nil;
    [_accessGroup release]; _accessGroup = nil;
    [_passwordData release]; _passwordData = nil;
    [super dealloc];
}
#endif

#pragma mark - Public

- (BOOL)save:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account || !self.passwordData) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
    
    [self delete:nil];
    
    NSMutableDictionary *query = [self query];
    query[(id)kSecValueData] = self.passwordData;
#if __IPHONE_4_0 && TARGET_OS_IPHONE
    if (SSKeychainAccessibilityType) {
        query[(id)kSecAttrAccessible] = (id)[self accessibilityType];
    }
#endif
    status = SecItemAdd((SSKeychainQueryBridgedCast(CFDictionaryRef))query, NULL);
    
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
	}
    
	return (status == errSecSuccess);
}


- (BOOL)delete:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
    
    NSMutableDictionary *query = [self query];
#if TARGET_OS_IPHONE
    status = SecItemDelete((SSKeychainQueryBridgedCast(CFDictionaryRef))query);
#else
    CFTypeRef result = NULL;
    query[(id)kSecReturnRef] = (id)kCFBooleanTrue;
    status = SecItemCopyMatching((SSKeychainQueryBridgedCast(CFDictionaryRef))query, &result);
    if (status == errSecSuccess) {
        status = SecKeychainItemDelete((SecKeychainItemRef)result);
        CFRelease(result);
    }
#endif
    
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}


- (NSArray *)fetchAll:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
    NSMutableDictionary *query = [self query];
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;
    query[(id)kSecMatchLimit] = (id)kSecMatchLimitAll;
	
	CFTypeRef result = NULL;
    status = SecItemCopyMatching((SSKeychainQueryBridgedCast(CFDictionaryRef))query, &result);
    if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return nil;
	}
    
    return SSKeychainQueryAutorelease((SSKeychainQueryBridgeTransferCast(NSArray *))result);
}


- (BOOL)fetch:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
	
	CFTypeRef result = NULL;
	NSMutableDictionary *query = [self query];
    query[(id)kSecReturnData] = (id)kCFBooleanTrue;
    query[(id)kSecMatchLimit] = (id)kSecMatchLimitOne;
    status = SecItemCopyMatching((SSKeychainQueryBridgedCast(CFDictionaryRef))query, &result);
	
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return NO;
	}
    
    self.passwordData = SSKeychainQueryAutorelease((SSKeychainQueryBridgeTransferCast(NSData *))result);
    return YES;
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


#pragma mark - Accessors

- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)password {
    if (_passwordData) {
        return SSKeychainQueryAutorelease([[NSString alloc] initWithData:_passwordData encoding:NSUTF8StringEncoding]);
    }
    return nil;
}


- (void)setPasswordData:(NSData *)data {
#if !__has_feature(objc_arc)
    [_passwordData release];
#endif
    _passwordData = [data copy];
}


#pragma mark - Private

- (NSMutableDictionary *)query {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    dictionary[(id)kSecClass] = (id)kSecClassGenericPassword;
    
    if (self.service) {
        dictionary[(id)kSecAttrService] = self.service;
    }
    
    if (self.account) {
        dictionary[(id)kSecAttrAccount] = self.account;
    }
    
#if __IPHONE_3_0 && TARGET_OS_IPHONE
    if (self.accessGroup) {
        dictionary[(id)kSecAttrAccessGroup] = self.accessGroup;
    }
#endif
    
    return dictionary;
}


+ (NSError *)errorWithCode:(OSStatus) code {
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
            message = SSKeychainQueryAutorelease((SSKeychainQueryBridgeTransferCast(NSString *))SecCopyErrorMessageString(code, NULL));
#endif
    }
    
    NSDictionary *userInfo = nil;
    if (message != nil) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:SSKeychainErrorDomain code:code userInfo:userInfo];
}

@end
