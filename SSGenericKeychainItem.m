//
//  SSGenericKeychainItem.m
//  SSKeychain
//
//  Created by Sam Soffes on 4/6/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSGenericKeychainItem.h"
#import <Security/Security.h>

@interface SSGenericKeychainItem (PrivateMethods)
- (void)_setCoreKeychainItemAttributeWithTag:(SecItemAttr)attributeTag toString:(NSString *)stringValue;
@end

@implementation SSGenericKeychainItem

@synthesize serviceName;

#pragma mark -
#pragma mark Class Methods
#pragma mark -

+ (SSGenericKeychainItem *)genericKeychainItem:(SecKeychainItemRef)item forServiceName:(NSString *)aServiceName username:(NSString *)aUsername password:(NSString *)aPassword {
	return [[[self alloc] initWithCoreKeychainItem:item serviceName:aServiceName username:aUsername password:aPassword] autorelease];
}


+ (SSGenericKeychainItem *)createGenericKeychainItemForServiceName:(NSString *)aServiceName withUsername:(NSString *)aUsername password:(NSString *)aPassword {
	if (!aUsername || [aUsername length] == 0 || !aServiceName || [aServiceName length] == 0) {
		return nil;
	}
	
	const char *serviceNameCString = [aServiceName UTF8String];
	const char *usernameCString = [aUsername UTF8String];
	const char *passwordCString = [aPassword UTF8String];
	
	SecKeychainItemRef item = nil;
	OSStatus returnStatus = SecKeychainAddGenericPassword(NULL, strlen(serviceNameCString), serviceNameCString, strlen(usernameCString), usernameCString, strlen(passwordCString), (void *)passwordCString, &item);
	
	if (returnStatus != noErr || !item) {
		return nil;
	}
	
	return [self genericKeychainItem:item forServiceName:aServiceName username:aUsername password:aPassword];
}


+ (SSGenericKeychainItem *)genericKeychainItemForServiceName:(NSString *)aServiceName withUsername:(NSString *)aUsername {
	if (!aUsername || [aUsername length] == 0) {
		return nil;
	}
	
	const char *serviceNameCString = [aServiceName UTF8String];
	const char *usernameCString = [aUsername UTF8String];
	
	UInt32 passwordLength = 0;
	char *passwordCString = nil;
	
	SecKeychainItemRef item = nil;
	OSStatus returnStatus = SecKeychainFindGenericPassword(NULL, strlen(serviceNameCString), serviceNameCString, strlen(usernameCString), usernameCString, &passwordLength, (void **)&passwordCString, &item);
	if (returnStatus != noErr || !item) {		
		return nil;
	}
	
//	NSString *passwordString = [NSString stringWithCString:passwordCString length:passwordLength];
	NSString *passwordString = [NSString stringWithCString:passwordCString encoding:NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, passwordCString);
	
	return [self genericKeychainItem:item forServiceName:aServiceName username:aUsername password:passwordString];
}


+ (NSString *)passwordForUsername:(NSString *)aUsername serviceName:(NSString*)aServiceName {
	return [[self genericKeychainItemForServiceName:aServiceName withUsername:aUsername] password];
}


+ (void)setPassword:(NSString *)aPassword forUsername:(NSString *)aUsername serviceName:(NSString *)aServiceName {
	SSKeychainItem *item = [self genericKeychainItemForServiceName:aServiceName withUsername:aUsername];
	
	if (item == nil) {
		[self createGenericKeychainItemForServiceName:aServiceName withUsername:aUsername password:aPassword];
	} else {
		item.password = aPassword;
	}
}


#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	[serviceName release];
	[super dealloc];
}


#pragma mark -
#pragma mark Initializers
#pragma mark -

- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem serviceName:(NSString *)aServiceName username:(NSString *)aUsername password:(NSString *)aPassword {
	if (self = [super initWithCoreKeychainItem:aCoreKeychainItem username:aUsername password:aPassword]) {
		self.serviceName = aServiceName;
	}
	return self;
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setServiceName:(NSString *)newServiceName {
	[self willChangeValueForKey:@"serviceName"];
	[serviceName release];
	serviceName = [newServiceName copy];
	[self didChangeValueForKey:@"serviceName"];	
	
	[self _setCoreKeychainItemAttributeWithTag:kSecServiceItemAttr toString:serviceName];
}

@end
