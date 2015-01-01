//
//  MRTAppStatusBar.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTStatusBarDelegate.h"

@interface MRTAppStatusBar : NSObject

- (id)initWithDelegate:(id<MRTStatusBarDelegate>)delegate;

@end