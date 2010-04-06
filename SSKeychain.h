//
//  SSKeychain.h
//  SSKeychain
//
//  Created by Sam Soffes on 4/6/10.
//  Copyright Sam Soffes 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface SSKeychain : NSObject {
}

+ (NSString *)securePasswordForIdentifier:(NSString *)username;
+ (BOOL)setSecurePassword:(NSString *)somePassword forIdentifier:(NSString *)username;

@end
