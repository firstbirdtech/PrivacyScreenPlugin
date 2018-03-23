#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface PrivacyScreenPlugin : CDVPlugin

- (void) hidePrivacyScreen:(CDVInvokedUrlCommand*)command;
- (void) showPrivacyScreen:(CDVInvokedUrlCommand*)command;

@end
