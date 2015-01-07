//
//  MRTJobItem.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJobItem.h"
#import "MRTJob.h"

@interface MRTJobItem ()

@property (weak) IBOutlet NSTextField *titleLabel;

@end

@implementation MRTJobItem

- (id)initWithJob:(MRTJob *)job {
    NSParameterAssert(job);
    
    self = [super init];
    if (self) {
        self.representedObject = job;
        
        [[NSBundle mainBundle] loadNibNamed:@"MRTJobItemView" owner:self topLevelObjects:nil];
        [self.titleLabel setStringValue:job.name];
    }
    return self;
}

- (MRTJob*)job {
    return self.representedObject;
}

@end
