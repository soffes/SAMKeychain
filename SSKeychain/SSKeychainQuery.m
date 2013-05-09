//
//  SSKeychainQuery.m
//  SSKeychain
//
//  Created by Caleb Davenport on 3/19/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import "SSKeychainQuery.h"
#import "SSKeychain.h"

@implementation SSKeychainQuery

@synthesize account = _account;
@synthesize service = _service;
@synthesize label = _label;
@synthesize passwordData = _passwordData;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
@synthesize accessGroup = _accessGroup;
#endif


#pragma mark - Public

- (BOOL)save:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account || !self.passwordData) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
    
    [self delete:nil];
    
    NSMutableDictionary *query = [self query];
    [query setObject:self.passwordData forKey:(__bridge id)kSecValueData];
    if (self.label) {
        [query setObject:self.label forKey:(__bridge id)kSecAttrLabel];
    }
#if __IPHONE_4_0 && TARGET_OS_IPHONE
	CFTypeRef accessibilityType = [SSKeychain accessibilityType];
    if (accessibilityType) {
        [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
    }
#endif
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
	}
    
	return (status == errSecSuccess);
}


- (BOOL)delete:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
    
    NSMutableDictionary *query = [self query];
#if TARGET_OS_IPHONE
    status = SecItemDelete((__bridge CFDictionaryRef)query);
#else
    CFTypeRef result = NULL;
    [query setObject:@YES forKey:(__bridge id)kSecReturnRef];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
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


- (NSArray *)fetchAll:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    NSMutableDictionary *query = [self query];
    [query setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
	
	CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return nil;
	}

    return (__bridge NSArray *)result;
}


- (BOOL)fetch:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
	
	CFTypeRef result = NULL;
	NSMutableDictionary *query = [self query];
    [query setObject:@YES forKey:(__bridge_transfer id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return NO;
	}
    
    self.passwordData = (__bridge_transfer NSData *)result;
    return YES;
}


#pragma mark - Accessors

- (void)setPasswordObject:(id<NSSecureCoding>)object {
    self.passwordData = [NSKeyedArchiver archivedDataWithRootObject:object];
}


- (id<NSSecureCoding>)passwordObject {
    if ([self.passwordData length]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.passwordData];
    }
    return nil;
}


- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)password {
    if ([self.passwordData length]) {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    return nil;
}


#pragma mark - Private

- (NSMutableDictionary *)query {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    if (self.service) {
        [dictionary setObject:self.service forKey:(__bridge id)kSecAttrService];
    }
    
    if (self.account) {
        [dictionary setObject:self.account forKey:(__bridge id)kSecAttrAccount];
    }
    
#if __IPHONE_3_0 && TARGET_OS_IPHONE
#if !(TARGET_IPHONE_SIMULATOR)
    if (self.accessGroup) {
        [dictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
#endif
    
    return dictionary;
}


+ (NSError *)errorWithCode:(OSStatus) code {
    NSString *message = nil;
    switch (code) {
        case errSecSuccess: return nil;
        case SSKeychainErrorBadArguments: message = @"Some of the arguments were invalid"; break;
            
#if TARGET_OS_IPHONE
        case errSecUnimplemented: {
			message = @"Function or operation not implemented";
			break;
		}
        case errSecParam: {
			message = @"One or more parameters passed to a function were not valid";
			break;
		}
        case errSecAllocate: {
			message = @"Failed to allocate memory";
			break;
		}
        case errSecNotAvailable: {
			message = @"No keychain is available. You may need to restart your computer";
			break;
		}
        case errSecDuplicateItem: {
			message = @"The specified item already exists in the keychain";
			break;
		}
        case errSecItemNotFound: {
			message = @"The specified item could not be found in the keychain";
			break;
		}
        case errSecInteractionNotAllowed: {
			message = @"User interaction is not allowed";
			break;
		}
        case errSecDecode: {
			message = @"Unable to decode the provided data";
			break;
		}
        case errSecAuthFailed: {
			message = @"The user name or passphrase you entered is not correct";
			break;
		}
        default: {
			message = @"Refer to SecBase.h for description";
		}
#else
        default:
            message = (__bridge_transfer NSString *)SecCopyErrorMessageString(code, NULL);
#endif
    }
    
    NSDictionary *userInfo = nil;
    if (message != nil) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:kSSKeychainErrorDomain code:code userInfo:userInfo];
}

@end
