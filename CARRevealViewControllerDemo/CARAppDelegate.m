//
//  CARAppDelegate.m
//  CARRevealViewControllerDemo
//
//  Created by Yamazaki Mitsuyoshi on 4/6/14.
//  Copyright (c) 2014 CrayonApps.inc. All rights reserved.
//

#import "CARAppDelegate.h"

#import "CARRevealViewController.h"
#import "CARChildViewController.h"

@interface CARAppDelegate () <CARRevealViewControllerDelegate>

@property (nonatomic, strong) CARRevealViewController *revealViewController;

@end

@implementation CARAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

	UIViewController *rootViewController = [[CARChildViewController alloc] initWithTitle:@"RootViewController" color:[UIColor greenColor]];
	
	self.revealViewController = [[CARRevealViewController alloc] initWithRootViewController:rootViewController];
	self.revealViewController.delegate = self;
	self.revealViewController.interactiveHideGestureRecognizer.enabled = YES;
	self.revealViewController.interactiveRevealLeftGestureRecognizer.enabled = YES;
	self.revealViewController.interactiveRevealRightGestureRecognizer.enabled = YES;
	self.revealViewController.interactiveHideLeftGestureRecognizer.enabled = YES;
	self.revealViewController.interactiveHideRightGestureRecognizer.enabled = YES;
	
	self.revealViewController.leftViewController = [[CARChildViewController alloc] initWithTitle:@"Left" color:[UIColor redColor]];
	self.revealViewController.rightViewController = [[CARChildViewController alloc] initWithTitle:@"Right" color:[UIColor blueColor]];
	
	self.window.rootViewController = self.revealViewController;
	[self.window makeKeyAndVisible];
		
	return YES;
}

#pragma mark - CARRevealViewControllerDelegate
- (void)revealViewController:(CARRevealViewController *)controller didRevealLeftViewController:(UIViewController *)leftViewController {
	MethodInfo;
}

- (void)revealViewController:(CARRevealViewController *)controller didRevealRightViewController:(UIViewController *)rightViewController {
	MethodInfo;
}

- (void)revealViewControllerDidHideSideViewController:(CARRevealViewController *)controller {
	MethodInfo;
}

@end
