//
//  AppDelegate.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "AppDelegate.h"
#import "MRTJob.h"
#import "MRTJenkins.h"
#import "MRTAppStatusBar.h"
#import "MRTSettings.h"
#import <Bolts/Bolts.h>
#import "MRTGeneralViewController.h"

#import "MRTFailedJobsController.h"

@interface AppDelegate () <MRTStatusBarDelegate>

@property (nonatomic, strong) MRTAppStatusBar *statusBar;
@property (nonatomic, strong) MRTJenkins *jenkins;
@property (nonatomic, strong) MRTSettings *settings;

@property (nonatomic, strong) NSStoryboard *storyboard;
@property (nonatomic, strong) NSWindowController *activeWindowController;

@property (nonatomic, strong) MRTFailedJobsController *failedJobsController;

- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:kSettingsDidChangeNotification object:nil];
    
    self.storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.settings = [[MRTSettings alloc] init];
    self.statusBar = [[MRTAppStatusBar alloc] initWithDelegate:self];
    
    self.failedJobsController = [[MRTFailedJobsController alloc] initWithContext:self.managedObjectContext andStatusBar:self.statusBar];
    
    if (![self.settings jenkinsPath]) {
        [self presentSettingsWindow];
    }
    else {
        self.jenkins = [self newJenkins];
        
        [[self.jenkins connect] continueWithBlock:^id(BFTask *task) {
            [self.jenkins fetchJobs];
            return nil;
        }];
    }
}

- (void)presentSettingsWindow {
    NSWindowController *settingsWC = [self.storyboard instantiateControllerWithIdentifier:@"Settings"];
    MRTGeneralViewController *generalVC = (MRTGeneralViewController*)settingsWC.contentViewController;
    [generalVC setSettings:self.settings];
    [settingsWC showWindow:self];
    [settingsWC.window setLevel:NSFloatingWindowLevel];
    // TODO: Keyboard focus
    
    self.activeWindowController = settingsWC;
}

- (MRTJenkins*)newJenkins {
    MRTJenkins *jenkins = [[MRTJenkins alloc] initWithURL:[NSURL URLWithString:[self.settings jenkinsPath]] context:self.managedObjectContext];
    [jenkins setAutoRefresh:YES];
    [jenkins setAutoRefreshInterval:[self.settings fetchInterval]];
    [jenkins setCredentialsWithUsername:[self.settings jenkinsUsername] andPassword:[self.settings jenkinsPassword]];
    return jenkins;
}

#pragma mark - Status Bar Delegate

- (void)showSettings {
    [self presentSettingsWindow];
}

- (void)quit {
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - Settings Notification

- (void)settingsDidChange:(NSNotification*)notification {
    NSString *propertyName = [notification.userInfo objectForKey:kSettingsChangedPropertyKey];
    if ([propertyName isEqualToString:NSStringFromSelector(@selector(jenkinsPath))]) {
        [self.jenkins setAutoRefresh:NO]; // Removes timer FIXME: Fix retain problem
        self.jenkins = [self newJenkins];
        
        [[self.jenkins connect] continueWithBlock:^id(BFTask *task) {
            [self.jenkins fetchJobs];
            return nil;
        }];
    }
    else if ([propertyName isEqualToString:NSStringFromSelector(@selector(fetchInterval))]) {
        [self.jenkins setAutoRefreshInterval:[self.settings fetchInterval]];
    }
    else if ([propertyName isEqualToString:NSStringFromSelector(@selector(jenkinsUsername))]
             || [propertyName isEqualToString:NSStringFromSelector(@selector(jenkinsPassword))]) {
        if ([self.settings jenkinsUsername] && [self.settings jenkinsPassword]) {
            [self.jenkins setAutoRefresh:NO]; // Removes timer FIXME: Fix retain problem
            self.jenkins = [self newJenkins];
            
            [[self.jenkins connect] continueWithBlock:^id(BFTask *task) {
                [self.jenkins fetchJobs];
                return nil;
            }];
        }
    }
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"JenkinsWatcher" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    NSString *failureReason;
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
        coordinator = nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    if (error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    return NSTerminateNow;
}

@end
