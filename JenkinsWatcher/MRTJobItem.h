//
//  MRTJobItem.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MRTJob;

@interface MRTJobItem : NSMenuItem

- (id)initWithJob:(MRTJob*)job;

@end
