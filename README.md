PrivacyScreenPlugin
==================

Both iOS (as of iOS 7) and Android have app switchers that display a screenshot of your app.

This is a lovely feature for most apps, but if your app displays sensitive information this is a possible privacy risk.

This plugin flags your app so that it doesn't show your users' sensitive data in the task switcher. It sets the [FLAG_SECURE](http://developer.android.com/reference/android/view/WindowManager.LayoutParams.html#FLAG_SECURE) flag in Android (which also prevents manual screenshots from being taken) and hides the window in iOS.

On iOS this plugin will try to show your splashscreen in the app switcher. It will search for splashscreens prefixed by `LaunchImage` or the value of the key `UILaunchImageFile` in your .plist file.
If it fails to find a splashscreen for a specific device or orientation (portrait or landscape), a black screen is shown instead.

Installation
------------

Add this line to config.xml:

<plugin name="cordova-plugin-fb-privacyscreen" spec="https://github.com/firstbirdtech/PrivacyScreenPlugin.git" />

Usage:
------

This plugin exposes no interface in Android, it simply sets your app to be private. You don't need to do anything except install the plugin.

In iOS the privacy screen fades on page load or in a set time interval, if you want more control you have the following functions:
- setTimer(successCallback, errorCallback, timeInterval) : sets timer to make privacy screen fade away (default is 3 seconds and can be set through preference).
- hidePrivacyScreen(successCallback, errorCallback)  : Explicitely hides the privacy screen.
- showPrivacyScreen(successCallback, errorCallback)  : Explicitely shows the privacy screen (respects timer interval to fade)

For iOS there are 3 preferences that can be set in config.xml:
- "PrivacyOnBackground": If set to "true" allows splashscreen to be shown only when app enters background (i.e. switched to another app or pressed the home button)
- "PrivacyOverrideLaunchImage": If set to "true" allows privacy screen to be the Default image even if LaunchImage is set in the info-plist
- "PrivacyImageName": String for image name, images should be in the app bundle and follow the size naming convention (i.e. for app name "Test", there should be a "Test-667h.png" in the bundle for iPhone 6)
- "PrivacyTimer": accepts a value in seconds for the privacy screen timer

When using splash storyboard add images to the config xml, i.e

    <splash src="res/screen/ios/LaunchImage@2x~universal~anyany.png" />
    <splash src="res/screen/ios/LaunchImage@3x~universal~anyany.png" />


Test this plugin on a real device because the iOS simulator (7.1 at least) does a poor job hiding your app.
