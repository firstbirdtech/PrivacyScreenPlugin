#import "PrivacyScreenPlugin.h"

static UIImageView *imageView;
UIViewController *blankViewController;

@interface PrivacyScreenPlugin ()
@end

@implementation PrivacyScreenPlugin

#pragma mark - Initialize
- (void)pluginInitialize
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:)
        name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(onPageDidLoad)
        name:CDVPageDidLoadNotification object:nil];

    NSString* onBackgroundKey = @"privacyonbackground";

    if([self.commandDelegate.settings objectForKey:[onBackgroundKey lowercaseString]] && [[self.commandDelegate.settings objectForKey:[onBackgroundKey lowercaseString]] isEqualToString:@"true"])
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:)
            name:UIApplicationDidEnterBackgroundNotification object:nil];
    else
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:)
            name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - Explicit Commands
- (void) hidePrivacyScreen:(CDVInvokedUrlCommand*)command
{
    [self removePrivacyScreen];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) showPrivacyScreen:(CDVInvokedUrlCommand*)command
{
    [self applyPrivacyScreen];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Triggered functions
- (void) onPageDidLoad
{
    [self removePrivacyScreen];
}

- (void)onAppDidBecomeActive:(UIApplication *)application
{
    [self removePrivacyScreen];
}

- (void)onAppWillResignActive:(UIApplication *)application
{
    [self applyPrivacyScreen];
}

#pragma mark - Helper functions
-(void) removePrivacyScreen
{
    // This should be omitted if your application presented a lock screen
    // in -applicationDidEnterBackground:
    [self.viewController dismissViewControllerAnimated:NO completion:nil];
}

-(void) applyPrivacyScreen
{
    // Your application can present a full screen modal view controller to
    // cover its contents when it moves into the background. If your
    // application requires a password unlock when it retuns to the
    // foreground, present your lock screen or authentication view controller here.
    if (blankViewController == NULL) {
        blankViewController = [UIViewController new];
//        blankViewController.view.backgroundColor = [UIColor whiteColor];

        CAGradientLayer *gradient = [CAGradientLayer layer];

        gradient.frame = blankViewController.view.bounds;
        // somewhat in line with css: linear-gradient(102deg, #44adfc 0%, #05d5ab 100%)
        gradient.colors = @[(id)[self colorFromHexString:@"#44adfc"].CGColor, (id)[self colorFromHexString:@"#05d5ab"].CGColor];

        [blankViewController.view.layer insertSublayer:gradient atIndex:0];
    }

    // Pass NO for the animated parameter. Any animation will not complete
    // before the snapshot is taken.
    blankViewController.view.window.hidden = NO;
    [self.viewController.view.window.rootViewController presentViewController:blankViewController animated:NO completion:NULL];
}

// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
