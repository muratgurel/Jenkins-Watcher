//
//  MRTSettingsWindowController.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 04/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTSettingsWindowController.h"

@interface MRTSettingsWindowController ()

@property (weak) IBOutlet NSToolbar *toolbar;

@end

@implementation MRTSettingsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.toolbar setSelectedItemIdentifier:@"NSToolbarGeneralItem"];
}

@end
