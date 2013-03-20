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
    [query setObject:self.passwordData forKey:(SSKeychainBridgedCast(id))kSecValueData];
    if (self.label) {
        [query setObject:self.label forKey:(SSKeychainBridgedCast(id))kSecAttrLabel];
    }
#if __IPHONE_4_0 && TARGET_OS_IPHONE
	CFTypeRef accessibilityType = [SSKeychain accessibilityType];
    if (accessibilityType) {
        [query setObject:(SSKeychainBridgedCast(id))accessibilityType forKey:(SSKeychainBridgedCast(id))kSecAttrAccessible];
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
    [query setObject:(SSKeychainBridgedCast(id))kCFBooleanTrue forKey:(SSKeychainBridgedCast(id))kSecReturnRef];
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
    [query setObject:(SSKeychainBridgedCast(id))kCFBooleanTrue forKey:(SSKeychainBridgedCast(id))kSecReturnAttributes];
    [query setObject:(SSKeychainBridgedCast(id))kSecMatchLimitAll forKey:(SSKeychainBridgedCast(id))kSecMatchLimit];
	
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
    [query setObject:(SSKeychainBridgedCast(id))kCFBooleanTrue forKey:(SSKeychainBridgedCast(id))kSecReturnData];
    [query setObject:(SSKeychainBridgedCast(id))kSecMatchLimitOne forKey:(SSKeychainBridgedCast(id))kSecMatchLimit];
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
    [dictionary setObject:(SSKeychainBridgedCast(id))kSecClassGenericPassword forKey:(SSKeychainBridgedCast(id))kSecClass];
    
    if (self.service) {
        [dictionary setObject:self.service forKey:(SSKeychainBridgedCast(id))kSecAttrService];
    }
    
    if (self.account) {
        [dictionary setObject:self.account forKey:(SSKeychainBridgedCast(id))kSecAttrAccount];
    }
    
#if __IPHONE_3_0 && TARGET_OS_IPHONE
    if (self.accessGroup) {
        [dictionary setObject:self.accessGroup forKey:(SSKeychainBridgedCast(id))kSecAttrAccessGroup];
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
