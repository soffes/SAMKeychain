//
//  SSKeychainItem.h
//  SSKeychain
//
//  Created by Sam Soffes on 4/6/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface SSKeychainItem : NSObject {

	NSString *username;
	NSString *password;
	NSString *label;
	
	SecKeychainItemRef coreKeychainItem;
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *label;

// Class Methods
+ (void)lockKeychain;
+ (void)unlockKeychain;

// Initializers
- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem;
- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem username:(NSString *)aUsername password:(NSString *)aPassword;
- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem username:(NSString *)aUsername password:(NSString *)aPassword label:(NSString *)aLabel;

// Tasks
- (void)destroy;

@end
