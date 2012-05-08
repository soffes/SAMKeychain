# SSKeychain

SSKeychain is a simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system Keychain on Mac OS X and iOS. SSKeychain works in ARC and non-ARC projects.

This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors. SSKeychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).

## Adding to your project

1. Add `Security.framework` to your target
2. Add `SSKeychain.h` and `SSKeychain.m` to your project.

You don't need to do anything regarding ARC. SSKeychain will detect if you're not using ARC and add the required memory management code.

Note: Currently SSKeychain does not support Mac OS 10.6.

## Working with the keychain

SSKeychain has the following class methods for working with the system keychain:

```objective-c
+ (NSArray *)allAccounts;
+ (NSArray *)accountsForService:(NSString *)serviceName;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
```

Easy as that. (See [SSKeychain.h](https://github.com/samsoffes/sskeychain/blob/master/SSKeychain.h) for all of the methods.)

## Documentation

Install the documentation into Xcode with the following steps:

1. Open Xcode Preferences
2. Choose Downloads
3. Choose the Documentation tab
4. Click the plus button in the bottom right and enter the following URL:
    
        http://docs.samsoff.es/com.samsoffes.sskeychain.atom

5. Click Install next the new row reading "SSKeychain Documentation". (If you don't see it and didn't get an error, try restarting Xcode.)

Be sure you have the docset selected in the organizer to see results for SSKeychain.

You can also **read the [SSKeychain Documentation](http://docs.samsoff.es/SSKeychain/Classes/SSKeychain.html) online.**

## Debugging

If you saving to the keychain fails, you use the error codes provided in SSKeychain.h. Here's an example:

```objective-c
NSError *error = nil;
NSString *password = [SSKeychain passwordForService:@"MyService" account:@"samsoffes" error:&error];

if ([error code] == SSKeychainErrorNotFound) {
    NSLog(@"Password not found");
}
```

Obviously, you should do something more sophisticated. Working with the keychain is pretty sucky. You should really check for errors and failures. This library doesn't make it any more stable, it just wraps up all of the annoying C APIs.
