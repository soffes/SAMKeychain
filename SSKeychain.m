//
//  SSKeychain.m
//  SSKeychain
//
//  Created by Sam Soffes on 4/6/10.
//  Copyright Sam Soffes 2010 . All rights reserved.
//


#import "SSKeychain.h"

@interface SSKeychain (PrivateMethods)
+ (SecKeychainItemRef) itemForKeychainUsername:(NSString*)username;
+ (NSString*) _uniqueServiceNameForApp;
@end


@implementation SSKeychain

+ (NSString *)_uniqueServiceNameForApp {
	return [[NSBundle mainBundle] bundleIdentifier];
}


+ (SecKeychainItemRef)itemForKeychainUsername:(NSString *)username {
	SecKeychainItemRef item = NULL;
	NSString *serviceName = [self _uniqueServiceNameForApp];
	
	OSErr err = SecKeychainFindGenericPassword(NULL, [serviceName length], [serviceName UTF8String],
											   [username length], [username UTF8String], NULL,
											   NULL, &item);
	
	if (err == noErr || item != NULL) {
		return item;
	}
	
	return NULL;
}


+ (NSString *)securePasswordForIdentifier:(NSString *)username {
	SecKeychainItemRef item = [self itemForKeychainUsername:username];
	
	if (item == NULL) {
    	return nil;
  	}
	
	UInt32 passwordLength;
	char* password;
	OSErr err = SecKeychainItemCopyAttributesAndData(item, NULL, NULL, NULL, &passwordLength, (void**)&password);
	
	if (err != noErr) {
		CFStringRef errMsg = SecCopyErrorMessageString(err, NULL);
		CFShow(errMsg);
		CFRelease(errMsg);
		return nil;
	}
	
	NSString *passwordString = [[NSString alloc] initWithBytes:password length:passwordLength encoding:NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, password);
	return [passwordString autorelease];
}


+ (BOOL)setSecurePassword:(NSString *)newPasswordString forIdentifier:(NSString *)username {
	if (!newPasswordString) {
		newPasswordString = @"";
	}
    
	SecKeychainItemRef item = [self itemForKeychainUsername:username];
	
	if (item == NULL) {
		NSString *serviceName = [self _uniqueServiceNameForApp];
		
		OSErr err = SecKeychainAddGenericPassword(NULL, [serviceName length], [serviceName UTF8String],
												  [username length], [username UTF8String], [newPasswordString length],
												  [newPasswordString UTF8String], &item);
		return (err == noErr && item != NULL);
	} else {
		const char *newPassword = [newPasswordString UTF8String];
		OSStatus err = SecKeychainItemModifyAttributesAndData(item, NULL, strlen(newPassword), (void *)newPassword);
		return (err == noErr && item != NULL);
	}
}

@end
