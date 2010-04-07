//
//  SSKeychainItem.m
//  SSKeychain
//
//  Created by Sam Soffes on 4/6/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSKeychainItem.h"

@interface SSKeychainItem (PrivateMethods)
- (void)_setCoreKeychainItemAttributeWithTag:(SecItemAttr)attributeTag toString:(NSString *)stringValue;
@end


@implementation SSKeychainItem

@synthesize username;
@synthesize password;
@synthesize label;

#pragma mark -
#pragma mark Class Methods
#pragma mark -

+ (void)lockKeychain {
	SecKeychainLock(NULL);
}


+ (void)unlockKeychain {
	SecKeychainUnlock(NULL, 0, NULL, NO);
}

#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	[username release];
	[password release];
	[label release];
	[super dealloc];
}


#pragma mark -
#pragma mark Initializers
#pragma mark -

- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem {
	if (self = [super init]) 	{
		coreKeychainItem = aCoreKeychainItem;
	}
	return self;
}


- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem username:(NSString *)aUsername password:(NSString *)aPassword {
	if (self = [super init]) 	{
		coreKeychainItem = aCoreKeychainItem;
		self.username = aUsername;
		self.password = aPassword;
	}
	return self;
}


- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem username:(NSString *)aUsername password:(NSString *)aPassword label:(NSString *)aLabel {
	if (self = [super init]) 	{
		coreKeychainItem = aCoreKeychainItem;
		self.username = aUsername;
		self.password = aPassword;
		self.label = aLabel;
	}
	return self;
}


#pragma mark -
#pragma mark Tasks
#pragma mark -

- (void)destroy {
  	SecKeychainItemDelete(coreKeychainItem);
}


#pragma mark -
#pragma mark Private Methods
#pragma mark -


- (void)_setCoreKeychainItemAttributeWithTag:(SecItemAttr)attributeTag toString:(NSString *)stringValue {
	const char *newValue = [stringValue UTF8String];
	SecKeychainAttribute attributes[1];
	attributes[0].tag = attributeTag;
	attributes[0].length = strlen(newValue);
	attributes[0].data = (void *)newValue;
	
	SecKeychainAttributeList list;
	list.count = 1;
	list.attr = attributes;
	
	SecKeychainItemModifyAttributesAndData(coreKeychainItem, &list, 0, NULL);
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setUsername:(NSString *)newUsername {
	[self willChangeValueForKey:@"username"];
	[username release];
	username = [newUsername copy];
	[self didChangeValueForKey:@"username"];	
	
	[self _setCoreKeychainItemAttributeWithTag:kSecAccountItemAttr toString:username];
}


- (void)setPassword:(NSString *)newPassword {
	if (!newPassword) {
		newPassword = @"";
	}
	
	[self willChangeValueForKey:@"password"];
	[password autorelease];
	password = [newPassword copy];
	[self didChangeValueForKey:@"password"];
	
	const char *passwordCString = [password UTF8String];
	SecKeychainItemModifyAttributesAndData(coreKeychainItem, NULL, strlen(passwordCString), (void *)passwordCString);
}


- (void)setLabel:(NSString *)newLabel {
	[self willChangeValueForKey:@"label"];
	[label release];
	label = [newLabel copy];
	[self didChangeValueForKey:@"label"];	
	
	[self _setCoreKeychainItemAttributeWithTag:kSecLabelItemAttr toString:label];
}


@end
