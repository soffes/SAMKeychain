//
//  SSInternetKeychainItem.m
//  SSKeychain
//
//  Created by Sam Soffes on 4/7/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSInternetKeychainItem.h"

@interface SSInternetKeychainItem (PrivateMethods)
- (void)_setCoreKeychainItemAttributeWithTag:(SecItemAttr)attributeTag toString:(NSString *)stringValue;
@end

@implementation SSInternetKeychainItem

@synthesize server;
@synthesize path;
@synthesize port;
@synthesize protocol;

#pragma mark -
#pragma mark Class Methods
#pragma mark -

+ (SSInternetKeychainItem *)internetKeychainItem:(SecKeychainItemRef)item forServer:(NSString *)aServer username:(NSString *)aUsername password:(NSString *)aPassword path:(NSString *)aPath port:(NSInteger)aPort protocol:(SecProtocolType)aProtocol {
	return [[[self alloc] initWithCoreKeychainItem:item server:aServer username:aUsername password:aPassword path:aPath port:aPort protocol:aProtocol] autorelease];
}


+ (SSInternetKeychainItem *)internetKeychainItemForServer:(NSString *)aServer withUsername:(NSString *)aUsername path:(NSString *)aPath port:(NSInteger)aPort protocol:(SecProtocolType)aProtocol {
	if (!aUsername || [aUsername length] == 0 || !aServer || [aServer length] == 0) {
		return nil;
	}
	
	const char *serverCString = [aServer UTF8String];
	const char *usernameCString = [aUsername UTF8String];
	const char *pathCString = (!aPath || [aPath length] == 0) ? "" : [aPath UTF8String];
	
	UInt32 passwordLength = 0;
	char *passwordCString = nil;
	
	SecKeychainItemRef item = nil;
	OSStatus returnStatus = SecKeychainFindInternetPassword(NULL, strlen(serverCString), serverCString, 0, NULL, strlen(usernameCString), usernameCString, strlen(pathCString), pathCString, aPort, aProtocol, kSecAuthenticationTypeDefault, &passwordLength, (void **)&passwordCString, &item);
	
	if (returnStatus != noErr || !item) {
		return nil;
	}
	
//	NSString *passwordString = [NSString stringWithCString:passwordCString length:passwordLength];
	NSString *passwordString = [NSString stringWithCString:passwordCString encoding:NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, passwordCString);
	
	return [self internetKeychainItem:item forServer:aServer username:aUsername password:passwordString path:aPath port:aPort protocol:aProtocol];
}


+ (SSInternetKeychainItem *)createInternetKeychainItemForServer:(NSString *)aServer withUsername:(NSString *)aUsername password:(NSString *)aPassword path:(NSString *)aPath port:(int)aPort protocol:(SecProtocolType)aProtocol {
	if (!aUsername || [aUsername length] == 0 || !aServer || [aServer length] == 0 || !aPassword || [aPassword length] == 0) {
		return nil;
	}
	
	const char *serverCString = [aServer UTF8String];
	const char *usernameCString = [aUsername UTF8String];
	const char *passwordCString = [aPassword UTF8String];
	const char *pathCString = (!aPath || [aPath length] == 0) ? "" : [aPath UTF8String];
	
	SecKeychainItemRef item = nil;
	OSStatus returnStatus = SecKeychainAddInternetPassword(NULL, strlen(serverCString), serverCString, 0, NULL, strlen(usernameCString), usernameCString, strlen(pathCString), pathCString, aPort, aProtocol, kSecAuthenticationTypeDefault, strlen(passwordCString), (void *)passwordCString, &item);
	if (returnStatus != noErr || !item) {
		return nil;
	}
	
	return [self internetKeychainItem:item forServer:aServer username:aUsername password:aPassword path:aPath port:aPort protocol:aProtocol];
}


#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	[server release];
	[path release];
	[super dealloc];
}


#pragma mark -
#pragma mark Initializers
#pragma mark -

- (id)initWithCoreKeychainItem:(SecKeychainItemRef)aCoreKeychainItem server:(NSString *)aServer username:(NSString *)aUsername password:(NSString *)aPassword path:(NSString *)aPath port:(NSInteger)aPort protocol:(SecProtocolType)aProtocol {
	if (self = [super initWithCoreKeychainItem:aCoreKeychainItem username:username password:password]) {
		self.server = aServer;
		self.path = aPath;
		self.port = aPort;
		self.protocol = aProtocol;
	}
	return self;
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setServer:(NSString *)newServer {
	[self willChangeValueForKey:@"server"];
	[server release];
	server = [newServer copy];
	[self didChangeValueForKey:@"server"];	
	
	[self _setCoreKeychainItemAttributeWithTag:kSecServerItemAttr toString:server];
}


- (void)setPath:(NSString *)newPath {
	[self willChangeValueForKey:@"path"];
	[path release];
	path = [newPath copy];
	[self didChangeValueForKey:@"path"];	
	
	[self _setCoreKeychainItemAttributeWithTag:kSecPathItemAttr toString:path];
}


- (void)setPort:(NSInteger)newPort {
	[self willChangeValueForKey:@"port"];
	port = newPort;
	[self didChangeValueForKey:@"port"];
	
	[self _setCoreKeychainItemAttributeWithTag:kSecPortItemAttr toString:[NSString stringWithFormat:@"%i", path]];
}


- (void)setProtocol:(SecProtocolType)newProtocol {
	[self willChangeValueForKey:@"protocol"];
	protocol = newProtocol;
	[self didChangeValueForKey:@"protocol"];
	
	SecKeychainAttribute attributes[1];
	attributes[0].tag = kSecProtocolItemAttr;
	attributes[0].length = sizeof(protocol);
	attributes[0].data = (void *)protocol; // Not sure how to prevent warning here
	
	SecKeychainAttributeList list;
	list.count = 1;
	list.attr = attributes;
	
	SecKeychainItemModifyAttributesAndData(coreKeychainItem, &list, 0, NULL);
}

@end
