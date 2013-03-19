//
//  SSKeychainQuery.m
//  SSKeychain
//
//  Created by Caleb Davenport on 3/19/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import <Security/Security.h>

#import "SSKeychainQuery.h"
#import "SSKeychain.h"

#if __has_feature(objc_arc)
    #define SSKeychainBridgedCast(type) __bridge type
    #define SSKeychainBridgeTransferCast(type) __bridge_transfer type
    #define SSKeychainAutorelease(stmt) stmt
#else
    #define SSKeychainBridgedCast(type) type
    #define SSKeychainBridgeTransferCast(type) type
    #define SSKeychainAutorelease(stmt) [stmt autorelease]
#endif

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
    query[(SSKeychainBridgedCast(id))kSecValueData] = self.passwordData;
    if (self.label) {
        query[(SSKeychainBridgedCast(id))kSecAttrLabel] = self.label;
    }
#if __IPHONE_4_0 && TARGET_OS_IPHONE
    if (SSKeychainAccessibilityType) {
        query[(SSKeychainBridgedCast(id))kSecAttrAccessible] = (id)[SSKeychain accessibilityType];
    }
#endif
    status = SecItemAdd((SSKeychainBridgedCast(CFDictionaryRef))query, NULL);
    
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
        *error = [[self class] errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}


- (NSArray *)fetchAll:(NSError **)error {
    OSStatus status = SSKeychainErrorBadArguments;
    NSMutableDictionary *query = [self query];
    query[(SSKeychainBridgedCast(id))kSecReturnAttributes] = (SSKeychainBridgedCast(id))kCFBooleanTrue;
    query[(SSKeychainBridgedCast(id))kSecMatchLimit] = (SSKeychainBridgedCast(id))kSecMatchLimitAll;
	
	CFTypeRef result = NULL;
    status = SecItemCopyMatching((SSKeychainBridgedCast(CFDictionaryRef))query, &result);
    if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return nil;
	}
    
    return SSKeychainAutorelease((SSKeychainBridgeTransferCast(NSArray *))result);
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
    query[(SSKeychainBridgedCast(id))kSecReturnData] = (SSKeychainBridgedCast(id))kCFBooleanTrue;
    query[(SSKeychainBridgedCast(id))kSecMatchLimit] = (SSKeychainBridgedCast(id))kSecMatchLimitOne;
    status = SecItemCopyMatching((SSKeychainBridgedCast(CFDictionaryRef))query, &result);
	
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return NO;
	}
    
    self.passwordData = SSKeychainAutorelease((SSKeychainBridgeTransferCast(NSData *))result);
    return YES;
}


#pragma mark - Accessors

- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)password {
    if (_passwordData) {
        return SSKeychainAutorelease([[NSString alloc] initWithData:_passwordData encoding:NSUTF8StringEncoding]);
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
    dictionary[(SSKeychainBridgedCast(id))kSecClass] = (SSKeychainBridgedCast(id))kSecClassGenericPassword;
    
    if (self.service) {
        dictionary[(SSKeychainBridgedCast(id))kSecAttrService] = self.service;
    }
    
    if (self.account) {
        dictionary[(SSKeychainBridgedCast(id))kSecAttrAccount] = self.account;
    }
    
#if __IPHONE_3_0 && TARGET_OS_IPHONE
    if (self.accessGroup) {
        dictionary[(SSKeychainBridgedCast(id))kSecAttrAccessGroup] = self.accessGroup;
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
            message = SSKeychainAutorelease((SSKeychainBridgeTransferCast(NSString *))SecCopyErrorMessageString(code, NULL));
#endif
    }
    
    NSDictionary *userInfo = nil;
    if (message != nil) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:kSSKeychainErrorDomain code:code userInfo:userInfo];
}

@end
