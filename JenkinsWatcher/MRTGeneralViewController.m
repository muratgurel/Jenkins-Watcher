//
//  MRTSettingsViewController.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 03/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTGeneralViewController.h"
#import "MRTSettings.h"

@interface MRTGeneralViewController ()

@property (weak) IBOutlet NSTextField *jenkinsPathField;
@property (weak) IBOutlet NSButton *launchOnStartupCheckbox;
@property (weak) IBOutlet NSTextField *fetchIntervalField;

@end

@implementation MRTGeneralViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    NSString *jenkinsPath = [self.settings jenkinsPath];
    [self.jenkinsPathField setStringValue:(jenkinsPath) ? jenkinsPath : @""];
    [self.launchOnStartupCheckbox setState:([self.settings launchOnStartup]) ? NSOnState : NSOffState];
    [self.fetchIntervalField setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.settings fetchInterval]]];
}

- (IBAction)toggleAutoLaunch:(id)sender {
    [self.settings setLaunchOnStartup:([self.launchOnStartupCheckbox state] == NSOnState) ? YES : NO];
}

- (IBAction)setJenkinsURL:(id)sender {
    [self.settings setJenkinsPath:[self.jenkinsPathField stringValue]];
}

- (IBAction)setFetchInterval:(id)sender {
    [self.settings setFetchInterval:[self.fetchIntervalField integerValue]];
}

@end
