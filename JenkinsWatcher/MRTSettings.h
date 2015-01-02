//
//  MRTSettings.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 02/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTSettings : NSObject

@property (nonatomic) BOOL launchOnStartup;
@property (nonatomic, strong) NSString *jenkinsPath;

@end
