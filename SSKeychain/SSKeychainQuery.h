//
//  SSKeychainQuery.h
//  SSKeychain
//
//  Created by Caleb Davenport on 3/18/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Error code specific to SSKeychain that can be returned in NSError objects.
 For codes returned by the operating system, refer to SecBase.h for your
 platform.
 */
typedef enum {
    
	/** Some of the arguments were invalid. */
	SSKeychainErrorBadArguments = -1001,
    
} SSKeychainErrorCode;

/** SSKeychain error domain */
extern NSString * const SSKeychainErrorDomain;

@interface SSKeychainQuery : NSObject

/** kSecAttrAccount */
@property (nonatomic, copy) NSString *account;

/** kSecAttrService */
@property (nonatomic, copy) NSString *service;

/** kSecAttrLabel */
@property (nonatomic, copy) NSString *label;

/** kSecAttrAccessGroup (only used on iOS) */
@property (nonatomic, copy) NSString *accessGroup;

/**
 You do not need to set both of these.
 */
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSData *passwordData;

/**
 Save the receiver's attributes as a keychain item. Existing items with the
 given account, service, and access group will first be deleted.
 
 @param error Populated should an error occur.
 
 @return `YES` if saving was successful, `NO` otherwise.
 */
- (BOOL)save:(NSError **)error;

/**
 Dete keychain items that match the given account, service, and access group.
 
 @param error Populated should an error occur.
 
 @return `YES` if saving was successful, `NO` otherwise.
 */
- (BOOL)delete:(NSError **)error;

/**
 Fetch all keychain items that match the given account, service, and access
 group. The values of `password` and `passwordData` are ignored when fetching.
 
 @param error Populated should an error occur.
 
 @return An array of dictionaries that represent all matching keychain items or
 `nil` should an error occur.
 The order of the items is not determined.
 */
- (NSArray *)fetchAll:(NSError **)error;

/**
 Fetch the keychain item that matches the given account, service, and access
 group. The `password` and `passwordData` properties will be populated unless
 an error occurs. The values of `password` and `passwordData` are ignored when
 fetching.
 
 @param error Populated should an error occur.
 
 @return `YES` if fetching was successful, `NO` otherwise.
 */
- (BOOL)fetch:(NSError **)error;

#pragma mark - Configuration

#if __IPHONE_4_0 && TARGET_OS_IPHONE
/**
 Returns the accessibility type for all future passwords saved to the Keychain.
 
 @return Returns the accessibility type.
 
 The return value will be `NULL` or one of the "Keychain Item Accessibility
 Constants" used for determining when a keychain item should be readable.
 
 @see accessibilityType
 */
+ (CFTypeRef)accessibilityType;

/**
 Sets the accessibility type for all future passwords saved to the Keychain.
 
 @param accessibilityType One of the "Keychain Item Accessibility Constants"
 used for determining when a keychain item should be readable.
 
 If the value is `NULL` (the default), the Keychain default will be used.
 
 @see accessibilityType
 */
+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;
#endif

@end
