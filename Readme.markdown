# SSKeychain

SSKeychain is a simple utility class for making the system keychain less sucky.

This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors. SSKeychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).

## Adding to your project

1. Add Security.framework to your target
2. Add SSKeychain.h and SSKeychain.m to your project.

## Working with the keychain

SSKeychain has the following class methods for working with the system keychain:

    + (NSString *)passwordForService:(NSString *)service account:(NSString *)account;
    + (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

    + (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account;
    + (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error;

    + (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account;
    + (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error;

Easy as that.

## Debugging

If you saving to the keychain fails, you use the error codes provided in SSKeychain.h. Here's an example:

    NSError *error = nil;
    NSString *password = [SSKeychain passwordForService:@"MyService" account:@"samsoffes" error:&error];
    
    if ([error code] == SSKeychainErrorNotFound) {
        NSLog(@"Password not found");
    }

Obviously, you should do something more sophisticated. Working with the keychain is pretty sucky. You should really check for errors and failures. This library doesn't make it any more stable, it just wraps up all of the annoying C APIs.
