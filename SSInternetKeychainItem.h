//
//  SSInternetKeychainItem.h
//  SSKeychain
//
//  Created by Sam Soffes on 4/7/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>
#import "SSKeychainItem.h"

@interface SSInternetKeychainItem : SSKeychainItem {

	NSString *server;
	NSString *path;
	NSInteger port;
	SecProtocolType protocol;
}

@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) SecProtocolType protocol;

// Class Methods
+ (SSInternetKeychainItem *)internetKeychainItem:(SecKeychainItemRef)item forServer:(NSString *)aServer username:(NSString *)aUsername password:(NSString *)aPassword path:(NSString *)aPath port:(NSInteger)aPort protocol:(SecProtocolType)aProtocol;
+ (SSInternetKeychainItem *)internetKeychainItemForServer:(NSString *)aServer withUsername:(NSString *)aUsername path:(NSString *)aPath port:(NSInteger)aPort protocol:(SecProtocolType)aProtocol;
+ (SSInternetKeychainItem *)createInternetKeychainItemForServer:(NSString *)aServer withUsername:(NSString *)aUsername password:(NSString *)aPassword path:(NSString *)aPath port:(int)aPort protocol:(SecProtocolType)aProtocol;

// Initializers
- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem server:(NSString *)aServer username:(NSString *)aUsername password:(NSString *)aPassword path:(NSString *)aPath port:(NSInteger)aPort protocol:(SecProtocolType)aProtocol;

@end
