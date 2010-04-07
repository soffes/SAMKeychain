//
//  SSGenericKeychainItem.h
//  SSKeychain
//
//  Created by Sam Soffes on 4/6/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSKeychainItem.h"

@interface SSGenericKeychainItem : SSKeychainItem {

	NSString *serviceName;
}

@property (nonatomic, retain) NSString *serviceName;

// Class Methods
+ (SSGenericKeychainItem *)genericKeychainItemForServiceName:(NSString *)aServiceName withUsername:(NSString *)aUsername;
+ (SSGenericKeychainItem *)createGenericKeychainItemForServiceName:(NSString *)aServiceName withUsername:(NSString *)aUsername password:(NSString *)aPassword;
+ (SSGenericKeychainItem *)genericKeychainItem:(SecKeychainItemRef)item forServiceName:(NSString *)aServiceName username:(NSString *)aUsername password:(NSString *)aPassword;
+ (NSString *)passwordForUsername:(NSString *)aUsername serviceName:(NSString *)aServiceName;
+ (void)setPassword:(NSString *)aPassword forUsername:(NSString *)aUsername serviceName:(NSString *)aServiceName;

// Initializers
- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem serviceName:(NSString *)aServiceName username:(NSString *)aUsername password:(NSString *)aPassword;

@end
