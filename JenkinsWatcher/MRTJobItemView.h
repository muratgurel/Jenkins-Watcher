//
//  MRTJobItemView.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 07/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MRTJobItemView : NSView

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSImageView *statusImageView;

@end
