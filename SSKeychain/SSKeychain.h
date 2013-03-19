//
//  SSKeychain.h
//  SSToolkit
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2009-2011 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>


/**
 Error code specific to SSKeychain that can be returned in NSError objects.
 For codes returned by the operating system, refer to SecBase.h for your platform.
 */
typedef enum {
    
	/** Some of the arguments were invalid. */
	SSKeychainErrorBadArguments = -1001,
    
} SSKeychainErrorCode;

extern NSString *const kSSKeychainErrorDomain;

/** Account name. */
extern NSString *const kSSKeychainAccountKey;

/**
 Time the item was created.
 
 The value will be a string.
 */
extern NSString *const kSSKeychainCreatedAtKey;

/** Item class. */
extern NSString *const kSSKeychainClassKey;

/** Item description. */
extern NSString *const kSSKeychainDescriptionKey;

/** Item label. */
extern NSString *const kSSKeychainLabelKey;

/** Time the item was last modified.
 
 The value will be a string.
 */
extern NSString *const kSSKeychainLastModifiedKey;

/** Where the item was created. */
extern NSString *const kSSKeychainWhereKey;

/**
 Simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system
 Keychain on Mac OS X and iOS.
 
 This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors.
 SSKeychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).
 */
@interface SSKeychain : NSObject

#pragma mark - Classic methods

/**
 Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't have a
 password for the given parameters.
 
 @param serviceName The service for which to return the corresponding password.
 
 @param account The account for which to return the corresponding password.
 
 @return Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't
 have a password for the given parameters.
 
 @see passwordForService:account:error:
 */
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;

/**
 Deletes a password from the Keychain.
 
 @param serviceName The service for which to delete the corresponding password.
 
 @param account The account for which to delete the corresponding password.
 
 @return Returns `YES` on success, or `NO` on failure.
 
 @see deletePasswordForService:account:error:
 */
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;

/**
 Sets a password in the Keychain.
 
 @param password The password to store in the Keychain.
 
 @param serviceName The service for which to set the corresponding password.
 
 @param account The account for which to set the corresponding password.
 
 @return Returns `YES` on success, or `NO` on failure.
 
 @see setPassword:forService:account:error:
 */
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;

#pragma mark - Get accounts

/**
 Returns an array containing the Keychain's accounts that match the given
 parameters or `nil` if should an error occur.
 
 @param service The name of the service for which to return the corresponding
 accounts.
 
 @param error Populated if accessing accounts results in an error.
 
 @return An array of dictionaries containing the Keychain's accountsfor the
 given parameters or `nil` if an error occurred. The order of the objects in
 the array isn't defined.
 */
+ (NSArray *)accountsForService:(NSString *)service error:(NSError **)error;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
/**
 Returns an array containing the Keychain's accounts that match the given
 parameters or `nil` if should an error occur.
 
 @param service The name of the service for which to return the corresponding
 accounts.
 
 @param group The name of access group for which to return the corresponding
 accounts.
 
 @param error Populated if accessing accounts results in an error.
 
 @return An array of dictionaries containing the Keychain's accountsfor the
 given parameters or `nil` if an error occurred. The order of the objects in
 the array isn't defined.
 */
+ (NSArray *)accountsForService:(NSString *)service accessGroup:(NSString *)group error:(NSError **)error;
#endif

#pragma mark - Get passwords

/**
 Get a password string from the Keychain, or `nil` if an error occurs or no
 such item is found. This method calls `passwordDataForService:account:error:`
 and creates a UTF-8-encoded string from the resulting data.
 
 @param service The service for which to return the corresponding password.
 
 @param account The account for which to return the corresponding password.
 
 @param error Populated if accessing the account results in an error.
 
 @return Returns a string from the Keychain, or `nil` if an error occurs or no
 such item is found.
 
 @see passwordDataForService:account:error:
 */
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

/**
 Get raw password data from the Keychain, or `nil` if an error occurs or no
 such item is found.
 
 @param service The service for which to return the corresponding password.
 
 @param account The account for which to return the corresponding password.
 
 @param error Populated if accessing the account results in an error.
 
 @return Returns password data from the Keychain, or `nil` if an error occurs
 or no such item is found.
 
 @see passwordForService:account:error:
 */
+ (NSData *)passwordDataForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
/**
 Get a password string from the Keychain, or `nil` if an error occurs or no
 such item is found. This method calls `passwordDataForService:account:error:`
 and creates a UTF-8-encoded string from the resulting data.
 
 @param service The service for which to return the corresponding password.
 
 @param account The account for which to return the corresponding password.
 
 @param group The group for which to return the corresponding password.
 
 @param error Populated if accessing the account results in an error.
 
 @return Returns a string from the Keychain, or `nil` if an error occurs or no
 such item is found.
 
 @see passwordDataForService:account:accessGroup:error:
 */
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)group error:(NSError **)error;

/**
 Get raw password data from the Keychain, or `nil` if an error occurs or no
 such item is found.
 
 @param service The service for which to return the corresponding password.
 
 @param account The account for which to return the corresponding password.
 
 @param group The group for which to return the corresponding password.
 
 @param error Populated if accessing the account results in an error.
 
 @return Returns password data from the Keychain, or `nil` if an error occurs
 or no such item is found.
 
 @see passwordForService:account:accessGroup:error:
 */
+ (NSData *)passwordDataForService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)group error:(NSError **)error;
#endif

#pragma mark - Delete passwords

/**
 Delete a password from the Keychain.
 
 @param service The service for which to delete the corresponding password.
 
 @param account The account for which to delete the corresponding password.
 
 @param error Populated if deleting the password results in an error.
 
 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
/**
 Delete a password from the Keychain.
 
 @param service The service for which to delete the corresponding password.
 
 @param account The account for which to delete the corresponding password.
 
 @param group The group for which to return the corresponding password.
 
 @param error Populated if deleting the password results in an error.
 
 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)group error:(NSError **)error;
#endif

#pragma mark - Set passwords

/**
 Set a password in the Keychain. This method first deletes any existing item
 that matches the given parameters. Then a new item is inserted. This method
 interprets `password` as a UTF-8-encoded string, converts it to data, and
 calls `setPasswordData:forService:account:error:` with the resulting data.
 
 @param password The password string to store in the Keychain.
 
 @param service The service for which to set the corresponding password.
 
 @param account The account for which to set the corresponding password.
 
 @param error Populated if adding the new item results in an error.
 
 @return Returns `YES` on success, or `NO` on failure.
 
 @see setPasswordData:forService:account:error:
 */
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error;

/**
 Sets password data in the Keychain. This method first deletes any existing
 item that matches the given parameters. Then a new item is inserted.
 
 @param password The data to store in the Keychain.
 
 @param service The service for which to set the corresponding password.
 
 @param account The account for which to set the corresponding password.
 
 @param error Populated if adding the new item results in an error.
 
 @return Returns `YES` on success, or `NO` on failure.
 
 @see setPassword:forService:account:error:
 */
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
/**
 Set a password in the Keychain. This method first deletes any existing item
 that matches the given parameters. Then a new item is inserted. This method
 interprets `password` as a UTF-8-encoded string, converts it to data, and
 calls `setPasswordData:forService:account:error:` with the resulting data.
 
 @param password The password string to store in the Keychain.
 
 @param service The service for which to set the corresponding password.
 
 @param account The account for which to set the corresponding password.
 
 @param group The group for which to return the corresponding password.
 
 @param error Populated if adding the new item results in an error.
 
 @return Returns `YES` on success, or `NO` on failure.
 
 @see setPasswordData:forService:account:error:
 */
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)group error:(NSError **)error;
#endif

#if __IPHONE_3_0 && TARGET_OS_IPHONE
/**
 Sets password data in the Keychain. This method first deletes any existing
 item that matches the given parameters. Then a new item is inserted.
 
 @param password The data to store in the Keychain.
 
 @param service The service for which to set the corresponding password.
 
 @param account The account for which to set the corresponding password.
 
 @param group The group for which to return the corresponding password.
 
 @param error Populated if adding the new item results in an error.
 
 @return Returns `YES` on success, or `NO` on failure.
 
 @see setPassword:forService:account:error:
 */
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)group error:(NSError **)error;
#endif

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
