/**
 * PrivacyScreenPlugin.m
 * Created by Tommy-Carlos Williams on 18/07/2014
 * Copyright (c) 2014 Tommy-Carlos Williams. All rights reserved.
 * MIT Licensed
 */
#import "PrivacyScreenPlugin.h"

static UIImageView *imageView;

@interface PrivacyScreenPlugin ()
@end


@implementation PrivacyScreenPlugin

#pragma mark - Initialize
- (void)pluginInitialize
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageDidLoad)
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
    if (imageView)
    {
        self.viewController.view.window.hidden = NO;

        [UIView animateWithDuration:0.1f
                         animations:^{
                             imageView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [imageView removeFromSuperview];
                         }];
    }
}

-(void) applyPrivacyScreen
{
    UIImage* splash;

    // splash = [UIImage imageNamed:@"LaunchStoryboard"];

    NSString* imageName = [self getImageName:[self getCurrentOrientation] delegate:(id<CDVScreenOrientationDelegate>)self.viewController device:[self getCurrentDevice]];
    splash = [UIImage imageNamed:imageName];

    if (splash == NULL)
    {
        self.viewController.view.window.hidden = YES;
    }
    else
    {
        [imageView removeFromSuperview];
        imageView = nil;

        imageView = [[UIImageView alloc]initWithFrame:[self.viewController.view bounds]];
        [imageView setImage:splash];

      #ifdef __CORDOVA_4_0_0
        [[UIApplication sharedApplication].keyWindow addSubview:imageView];
      #else
        [self.viewController.view addSubview:imageView];
      #endif

    }
}

// Code below borrowed from the CDV splashscreen plugin @ https://github.com/apache/cordova-plugin-splashscreen
// Made some adjustments though, becuase landscape splashscreens are not available for iphone < 6 plus
- (CDV_iOSDevice) getCurrentDevice
{
    CDV_iOSDevice device;

    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat mainScreenHeight = mainScreen.bounds.size.height;
    CGFloat mainScreenWidth = mainScreen.bounds.size.width;

    int limit = MAX(mainScreenHeight,mainScreenWidth);

    device.iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    device.iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    device.retina = ([mainScreen scale] == 2.0);
    device.iPhone4 = (device.iPhone && limit == 480.0);
    device.iPhone5 = (device.iPhone && limit == 568.0);
    // note these below is not a true device detect, for example if you are on an
    // iPhone 6/6+ but the app is scaled it will prob set iPhone5 as true, but
    // this is appropriate for detecting the runtime screen environment
    device.iPhone6 = (device.iPhone && limit == 667.0);
    device.iPhone6Plus = (device.iPhone && limit == 736.0);
    device.iPhoneX  = (device.iPhone && limit == 812.0);

    return device;
}

- (BOOL) isUsingCDVLaunchScreen {
    NSString* launchStoryboardName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UILaunchStoryboardName"];
    if (launchStoryboardName) {
        return ([launchStoryboardName isEqualToString:@"CDVLaunchScreen"]);
    } else {
        return NO;
    }
}

- (UIInterfaceOrientation)getCurrentOrientation
{
    UIInterfaceOrientation iOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation dOrientation = [UIDevice currentDevice].orientation;

    bool landscape;

    if (dOrientation == UIDeviceOrientationUnknown || dOrientation == UIDeviceOrientationFaceUp || dOrientation == UIDeviceOrientationFaceDown) {
        // If the device is laying down, use the UIInterfaceOrientation based on the status bar.
        landscape = UIInterfaceOrientationIsLandscape(iOrientation);
    } else {
        // If the device is not laying down, use UIDeviceOrientation.
        landscape = UIDeviceOrientationIsLandscape(dOrientation);

        // There's a bug in iOS!!!! http://openradar.appspot.com/7216046
        // So values needs to be reversed for landscape!
        if (dOrientation == UIDeviceOrientationLandscapeLeft)
        {
            iOrientation = UIInterfaceOrientationLandscapeRight;
        }
        else if (dOrientation == UIDeviceOrientationLandscapeRight)
        {
            iOrientation = UIInterfaceOrientationLandscapeLeft;
        }
        else if (dOrientation == UIDeviceOrientationPortrait)
        {
            iOrientation = UIInterfaceOrientationPortrait;
        }
        else if (dOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            iOrientation = UIInterfaceOrientationPortraitUpsideDown;
        }
    }

    return iOrientation;
}

- (NSString*)getImageName:(UIInterfaceOrientation)currentOrientation delegate:(id<CDVScreenOrientationDelegate>)orientationDelegate device:(CDV_iOSDevice)device
{
    // Use UILaunchImageFile if specified in plist.  Otherwise, use Default.
    NSString* imageName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UILaunchImageFile"];

    // detect if we are using CB-9762 Launch Storyboard; if so, return the associated image instead
    if ([self isUsingCDVLaunchScreen]) {
        imageName = @"LaunchStoryboard";
        return imageName;
    }

    NSUInteger supportedOrientations = [orientationDelegate supportedInterfaceOrientations];

    // Checks to see if the developer has locked the orientation to use only one of Portrait or Landscape
    BOOL supportsLandscape = (supportedOrientations & UIInterfaceOrientationMaskLandscape);
    BOOL supportsPortrait = (supportedOrientations & UIInterfaceOrientationMaskPortrait || supportedOrientations & UIInterfaceOrientationMaskPortraitUpsideDown);
    // this means there are no mixed orientations in there
    BOOL isOrientationLocked = !(supportsPortrait && supportsLandscape);

    if (imageName)
    {
        imageName = [imageName stringByDeletingPathExtension];
    }
    else
    {
        imageName = @"Default";
    }

    // Add Asset Catalog specific prefixes
    if ([imageName isEqualToString:@"LaunchImage"])
    {
        if (device.iPhone4 || device.iPhone5 || device.iPad) {
            imageName = [imageName stringByAppendingString:@"-700"];
        } else if(device.iPhone6) {
            imageName = [imageName stringByAppendingString:@"-800"];
        } else if(device.iPhone6Plus || device.iPhoneX ) {
            if(device.iPhone6Plus) {
                imageName = [imageName stringByAppendingString:@"-800"];
            } else {
                imageName = [imageName stringByAppendingString:@"-1100"];
            }
            if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                imageName = [imageName stringByAppendingString:@"-Portrait"];
            }
        }
    }

    if (device.iPhone5)
    { // does not support landscape
        imageName = [imageName stringByAppendingString:@"-568h"];
    }
    else if (device.iPhone6)
    { // does not support landscape
        imageName = [imageName stringByAppendingString:@"-667h"];
    }
    else if (device.iPhone6Plus || device.iPhoneX)
    { // supports landscape
        if (isOrientationLocked)
        {
            imageName = [imageName stringByAppendingString:(supportsLandscape ? @"-Landscape" : @"")];
        }
        else
        {
            switch (currentOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    imageName = [imageName stringByAppendingString:@"-Landscape"];
                    break;
                default:
                    break;
            }
        }
        if (device.iPhoneX) {
            imageName = [imageName stringByAppendingString:@"-2436h"];
        } else {
            imageName = [imageName stringByAppendingString:@"-736h"];
        }
    }
    else if (device.iPad)
    {   // supports landscape
        if (isOrientationLocked)
        {
            imageName = [imageName stringByAppendingString:(supportsLandscape ? @"-Landscape" : @"-Portrait")];
        }
        else
        {
            switch (currentOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    imageName = [imageName stringByAppendingString:@"-Landscape"];
                    break;

                case UIInterfaceOrientationPortrait:
                case UIInterfaceOrientationPortraitUpsideDown:
                default:
                    imageName = [imageName stringByAppendingString:@"-Portrait"];
                    break;
            }
        }
    }

    return imageName;
}

- (void)updateBounds
{

    UIImage* img = imageView.image;
    CGRect imgBounds = (img) ? CGRectMake(0, 0, img.size.width, img.size.height) : CGRectZero;

    CGSize screenSize = [self.viewController.view convertRect:[UIScreen mainScreen].bounds fromView:nil].size;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGAffineTransform imgTransform = CGAffineTransformIdentity;

    /* If and only if an iPhone application is landscape-only as per
     * UISupportedInterfaceOrientations, the view controller's orientation is
     * landscape. In this case the image must be rotated in order to appear
     * correctly.
     */
    CDV_iOSDevice device = [self getCurrentDevice];
    if (UIInterfaceOrientationIsLandscape(orientation) && !device.iPhone6Plus && !device.iPad)
    {
        imgTransform = CGAffineTransformMakeRotation(M_PI / 2);
        imgBounds.size = CGSizeMake(imgBounds.size.height, imgBounds.size.width);
    }

    // There's a special case when the image is the size of the screen.
    if (CGSizeEqualToSize(screenSize, imgBounds.size))
    {
        CGRect statusFrame = [self.viewController.view convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil];
        if (!(IsAtLeastiOSVersion(@"7.0")))
        {
            imgBounds.origin.y -= statusFrame.size.height;
        }
    }
    else if (imgBounds.size.width > 0)
    {
        CGRect viewBounds = self.viewController.view.bounds;
        CGFloat imgAspect = imgBounds.size.width / imgBounds.size.height;
        CGFloat viewAspect = viewBounds.size.width / viewBounds.size.height;
        // This matches the behaviour of the native splash screen.
        CGFloat ratio;
        if (viewAspect > imgAspect)
        {
            ratio = viewBounds.size.width / imgBounds.size.width;
        }
        else
        {
            ratio = viewBounds.size.height / imgBounds.size.height;
        }
        imgBounds.size.height *= ratio;
        imgBounds.size.width *= ratio;
    }

    imageView.transform = imgTransform;
    imageView.frame = imgBounds;
}

@end
