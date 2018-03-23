PrivacyScreenPlugin
==================

Both iOS (as of iOS 7) and Android have app switchers that display a screenshot of your app.

This is a lovely feature for most apps, but if your app displays sensitive information this is a possible privacy risk.

This plugin flags your app so that it doesn't show your users' sensitive data in the task switcher. It sets the [FLAG_SECURE](http://developer.android.com/reference/android/view/WindowManager.LayoutParams.html#FLAG_SECURE) flag in Android (which also prevents manual screenshots from being taken) and hides the window in iOS.

On iOS this plugin will show a gradient color view on top of your window.

Installation
------------

Add this line to config.xml:

    <plugin name="cordova-plugin-fb-privacyscreen" spec="https://github.com/firstbirdtech/PrivacyScreenPlugin.git" />

Usage:
------

This plugin exposes no interface in JavaScript, it simply sets your app to be private. You don't need to do anything except install the plugin.

For iOS there are 3 preferences that can be set in config.xml:
- "PrivacyOnBackground": If set to "true" allows privacy screen to be shown only when app enters background (i.e. switched to another app or pressed the home button)

When using splash storyboard add images to the config xml, i.e

    <splash src="res/screen/ios/LaunchImage@2x~universal~anyany.png" />
    <splash src="res/screen/ios/LaunchImage@3x~universal~anyany.png" />

Test this plugin on a real device because the iOS simulator (7.1 at least) does a poor job hiding your app.
