//
//  MRTSettings.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 02/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kSettingsDidChangeNotification;
extern NSString* const kSettingsChangedPropertyKey;

@interface MRTSettings : NSObject

@property (nonatomic) BOOL launchOnStartup;
@property (nonatomic) NSUInteger fetchInterval;

@property (nonatomic, strong) NSString *jenkinsPath;
@property (nonatomic, strong) NSString *jenkinsUsername;
@property (nonatomic, strong) NSString *jenkinsPassword;

@end
