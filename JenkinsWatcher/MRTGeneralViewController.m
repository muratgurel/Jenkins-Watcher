//
//  MRTSettingsViewController.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 03/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

// TODO: Use NSUserDefaultsController

#import "MRTGeneralViewController.h"
#import "MRTSettings.h"

@interface MRTGeneralViewController ()

@property (weak) IBOutlet NSButton *launchOnStartupCheckbox;
@property (weak) IBOutlet NSTextField *fetchIntervalField;

@property (weak) IBOutlet NSTextField *jenkinsPathField;
@property (weak) IBOutlet NSTextField *usernameField;
@property (weak) IBOutlet NSSecureTextField *passwordField;

@end

@implementation MRTGeneralViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    NSString *jenkinsPath = [self.settings jenkinsPath];
    NSString *jenkinsUsername = [self.settings jenkinsUsername];
    NSString *jenkinsPassword = [self.settings jenkinsPassword];
    
    [self.jenkinsPathField setStringValue:(jenkinsPath) ? jenkinsPath : @""];
    [self.launchOnStartupCheckbox setState:([self.settings launchOnStartup]) ? NSOnState : NSOffState];
    [self.fetchIntervalField setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.settings fetchInterval]]];
    [self.usernameField setStringValue:(jenkinsUsername) ? jenkinsUsername : @""];
    [self.passwordField setStringValue:(jenkinsPassword) ? jenkinsPassword : @""];
}

- (IBAction)toggleAutoLaunch:(id)sender {
    [self.settings setLaunchOnStartup:([self.launchOnStartupCheckbox state] == NSOnState) ? YES : NO];
}

- (IBAction)setJenkinsURL:(id)sender {
    [self.settings setJenkinsPath:[self.jenkinsPathField stringValue]];
}

- (IBAction)setUsername:(id)sender {
    [self.settings setJenkinsUsername:[self.usernameField stringValue]];
}

- (IBAction)setPassword:(id)sender {
    [self.settings setJenkinsPassword:[self.passwordField stringValue]];
}

- (IBAction)setFetchInterval:(id)sender {
    [self.settings setFetchInterval:[self.fetchIntervalField integerValue]];
}

@end
