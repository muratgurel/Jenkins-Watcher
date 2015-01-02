//
//  MRTJobItem.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJobItem.h"

@implementation MRTJobItem

- (id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"JobItemView" owner:self topLevelObjects:nil];
    }
    return self;
}

@end
