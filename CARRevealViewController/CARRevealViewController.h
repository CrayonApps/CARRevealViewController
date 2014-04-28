//
//  CARRevealViewController.h
//  CARRevealViewControllerDemo
//
//  Created by Yamazaki Mitsuyoshi on 4/6/14.
//  Copyright (c) 2014 CrayonApps.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CARRevealViewStateDefault,
	CARRevealViewStateLeftViewShown,
	CARRevealViewStateRightViewShown,
	CARRevealViewStateSideViewHidden = CARRevealViewStateDefault,
}CARRevealViewState;

@class CARRevealViewController;

@protocol CARRevealViewControllerDelegate <NSObject>
@optional
- (void)revealViewController:(CARRevealViewController *)controller didRevealLeftViewController:(UIViewController *)leftViewController;
- (void)revealViewController:(CARRevealViewController *)controller didRevealRightViewController:(UIViewController *)rightViewController;
- (void)revealViewControllerDidHideSideViewController:(CARRevealViewController *)controller;
@end

@interface CARRevealViewController : UIViewController

@property (nonatomic, weak) id <CARRevealViewControllerDelegate> delegate;

@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

@property (nonatomic, readonly) UITapGestureRecognizer *interactiveHideGestureRecognizer;			// on RootView, default: enabled
@property (nonatomic, readonly) UISwipeGestureRecognizer *interactiveRevealLeftGestureRecognizer;	// on RootView, default: disabled
@property (nonatomic, readonly) UISwipeGestureRecognizer *interactiveRevealRightGestureRecognizer;	// on RootView, default: disabled
@property (nonatomic, readonly) UISwipeGestureRecognizer *interactiveHideRightGestureRecognizer;	// on RightView, default: disabled
@property (nonatomic, readonly) UISwipeGestureRecognizer *interactiveHideLeftGestureRecognizer;		// on LeftView, default: disabled

@property (nonatomic) CGFloat leftViewWidth;
@property (nonatomic) CGFloat rightViewWidth;
@property (nonatomic, readonly) CARRevealViewState state;
@property (nonatomic) NSTimeInterval animationDuration;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)revealLeftViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void)revealRightViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void)hideSideViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;

// animated = YES
- (void)revealLeftView;
- (void)revealRightView;
- (void)hideSideView;

@end

@interface UIViewController (CARRevealViewController)
- (CARRevealViewController *)revealViewController;
@end