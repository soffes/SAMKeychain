//
//  SSKeychain.m
//  SSToolkit
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2009-2011 Sam Soffes. All rights reserved.
//

#import "SSKeychain.h"
#import "SSKeychainQuery.h"

NSString *const kSSKeychainAccountKey = @"acct";
NSString *const kSSKeychainCreatedAtKey = @"cdat";
NSString *const kSSKeychainClassKey = @"labl";
NSString *const kSSKeychainDescriptionKey = @"desc";
NSString *const kSSKeychainLabelKey = @"labl";
NSString *const kSSKeychainLastModifiedKey = @"mdat";
NSString *const kSSKeychainWhereKey = @"svce";

#if __has_feature(objc_arc)
    #define SSKeychainAutorelease(stmt) stmt
#else
    #define SSKeychainAutorelease(stmt) [stmt autorelease]
#endif

@implementation SSKeychain

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
    SSKeychainQuery *query = SSKeychainAutorelease([[SSKeychainQuery alloc] init]);
    query.service = serviceName;
    query.account = account;
    [query fetch:nil];
    return query.password;
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
    SSKeychainQuery *query = SSKeychainAutorelease([[SSKeychainQuery alloc] init]);
    query.service = serviceName;
    query.account = account;
    return [query delete:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
    SSKeychainQuery *query = SSKeychainAutorelease([[SSKeychainQuery alloc] init]);
    query.service = serviceName;
    query.account = account;
    query.password = password;
    return [query save:nil];
}


+ (NSArray *)allAccounts {
    return [self accountsForService:nil];
}


+ (NSArray *)accountsForService:(NSString *)serviceName {
    SSKeychainQuery *query = SSKeychainAutorelease([[SSKeychainQuery alloc] init]);
    query.service = serviceName;
    return [query fetchAll:nil];
}

@end
