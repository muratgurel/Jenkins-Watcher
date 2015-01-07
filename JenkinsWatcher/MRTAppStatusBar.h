//
//  MRTAppStatusBar.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTStatusBarDelegate.h"

typedef NS_ENUM(NSUInteger, StatusIconColor) {
    StatusIconColorBlack,
    StatusIconColorRed
};

@class MRTJobItem;

@interface MRTAppStatusBar : NSObject

@property (nonatomic) StatusIconColor iconColor;

- (id)initWithDelegate:(id<MRTStatusBarDelegate>)delegate;

- (void)clearJobItems;
- (void)addJobMenuItem:(MRTJobItem*)jobItem;

@end
