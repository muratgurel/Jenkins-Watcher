//
//  MRTSettings.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 02/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTSettings.h"

NSString* const kSettingsDidChangeNotification = @"com.muratgurel.notification.settingsDidChange";
NSString* const kSettingsChangedPropertyKey = @"changedSettingsProperty";

NSString* const kFirstLaunchKey = @"firstLaunchIndicator";
NSString* const kLaunchOnStartupKey = @"launchOnStartup";
NSString* const kJenkinsPathKey = @"jenkinsPathKey";
NSString* const kFetchIntervalKey = @"fetchIntervalKey";

@implementation MRTSettings

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if ([prefs objectForKey:kFirstLaunchKey] == nil) {
            [prefs setBool:NO forKey:kLaunchOnStartupKey];
            [prefs setBool:YES forKey:kFirstLaunchKey];
            [prefs setInteger:60 forKey:kFetchIntervalKey];
        }
        
        // User could have changed this setting from system prefs
        _launchOnStartup = [self isAppInLoginItems];
        [prefs setBool:_launchOnStartup forKey:kLaunchOnStartupKey];
        
        _jenkinsPath = [prefs stringForKey:kJenkinsPathKey];
        _fetchInterval = [prefs integerForKey:kFetchIntervalKey];
    }
    return self;
}

- (void)dispatchNotificationForPropertyWithName:(NSString*)propName {
    NSParameterAssert(propName);
    
    NSDictionary *userInfo = @{ kSettingsChangedPropertyKey : propName };
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsDidChangeNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - Setters

- (void)setLaunchOnStartup:(BOOL)launchOnStartup {
    if (_launchOnStartup != launchOnStartup) {
        _launchOnStartup = launchOnStartup;
        [[NSUserDefaults standardUserDefaults] setBool:_launchOnStartup forKey:kLaunchOnStartupKey];
        
        [self toggleAppLoginItem:_launchOnStartup];
        [self dispatchNotificationForPropertyWithName:NSStringFromSelector(@selector(launchOnStartup))];
    }
}

- (void)setJenkinsPath:(NSString *)jenkinsPath {
    if (_jenkinsPath != jenkinsPath) {
        _jenkinsPath = jenkinsPath;
        [[NSUserDefaults standardUserDefaults] setObject:_jenkinsPath forKey:kJenkinsPathKey];
        [self dispatchNotificationForPropertyWithName:NSStringFromSelector(@selector(jenkinsPath))];
    }
}

- (void)setFetchInterval:(NSUInteger)fetchInterval {
    if (_fetchInterval != fetchInterval) {
        _fetchInterval = fetchInterval;
        [[NSUserDefaults standardUserDefaults] setInteger:_fetchInterval forKey:kFetchIntervalKey];
        [self dispatchNotificationForPropertyWithName:NSStringFromSelector(@selector(fetchInterval))];
    }
}

#pragma mark - Launch On Startup

- (BOOL)isAppInLoginItems {
    // See if the app is currently in LoginItems.
    LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
    // Store away that boolean.
    BOOL isInList = itemRef != nil;
    // Release the reference if it exists.
    if (itemRef != nil) CFRelease(itemRef);
    
    return isInList;
}

- (void)toggleAppLoginItem:(BOOL)newValue {
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return;
    if (newValue) {
        // Add the app to the LoginItems list.
        CFURLRef appUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, appUrl, NULL, NULL);
        if (itemRef) CFRelease(itemRef);
    }
    else {
        // Remove the app from the LoginItems list.
        LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
        LSSharedFileListItemRemove(loginItemsRef,itemRef);
        if (itemRef != nil) CFRelease(itemRef);
    }
    CFRelease(loginItemsRef);
}

- (LSSharedFileListItemRef)itemRefInLoginItems {
    LSSharedFileListItemRef itemRef = nil;
    NSURL *itemUrl = nil;
    
    // Get the app's URL.
    NSURL *appUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return nil;
    // Iterate over the LoginItems.
    NSArray *loginItems = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItemsRef, nil);
    for (int currentIndex = 0; currentIndex < [loginItems count]; currentIndex++) {
        // Get the current LoginItem and resolve its URL.
        LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItems objectAtIndex:currentIndex];
        itemUrl = (__bridge NSURL *)(LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, NULL));
        if (itemUrl != nil) {
            // Compare the URLs for the current LoginItem and the app.
            if ([itemUrl isEqual:appUrl]) {
                // Save the LoginItem reference.
                itemRef = currentItemRef;
            }
        }
    }
    // Retain the LoginItem reference.
    if (itemRef != nil) CFRetain(itemRef);
    CFRelease(loginItemsRef);
    
    return itemRef;
}

@end
