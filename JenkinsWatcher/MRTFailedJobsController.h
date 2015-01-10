//
//  MRTFailedJobsController.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 09/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class MRTAppStatusBar;

@interface MRTFailedJobsController : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;
@property (nonatomic, strong, readonly) MRTAppStatusBar *statusBar;

- (id)initWithContext:(NSManagedObjectContext*)context
         andStatusBar:(MRTAppStatusBar*)statusBar;

@end
