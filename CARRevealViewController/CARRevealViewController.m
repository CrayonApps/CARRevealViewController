//
//  CARRevealViewController.m
//  CARRevealViewControllerDemo
//
//  Created by Yamazaki Mitsuyoshi on 4/6/14.
//  Copyright (c) 2014 CrayonApps.inc. All rights reserved.
//

#import "CARRevealViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CARRevealViewController ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;

- (void)changeState:(CARRevealViewState)newState;

- (CGRect)leftViewFrame;
- (CGRect)rightViewFrame;
- (CGRect)leftViewRevealedFrame;
- (CGRect)rightViewRevealedFrame;

- (void)createMaskView;
- (void)createRootView;
- (void)createLeftView;
- (void)createRightView;
- (void)createGestureRecognizers;

- (void)revealSideView:(UIView *)view toFrame:(CGRect)frame animated:(BOOL)animated toState:(CARRevealViewState)toState completion:(void(^)(void))complation;

- (void)removeChildViewController:(UIViewController *)childViewController;
- (void)addNewChildViewController:(UIViewController *)childViewController viewFrame:(CGRect)frame;

@end

@implementation CARRevealViewController

@synthesize rootViewController = _rootViewController;
@synthesize leftViewController = _leftViewController;
@synthesize rightViewController = _rightViewController;
@synthesize interactiveHideGestureRecognizer = _interactiveHideGestureRecognizer;
@synthesize interactiveRevealLeftGestureRecognizer = _interactiveRevealLeftGestureRecognizer;
@synthesize interactiveRevealRightGestureRecognizer = _interactiveRevealRightGestureRecognizer;
@synthesize interactiveHideLeftGestureRecognizer = _interactiveHideLeftGestureRecognizer;
@synthesize interactiveHideRightGestureRecognizer = _interactiveHideRightGestureRecognizer;
@synthesize leftViewWidth = _leftViewWidth;
@synthesize rightViewWidth = _rightViewWidth;
@synthesize state = _state;

#pragma mark - Lifecycle
- (id)initWithRootViewController:(UIViewController *)rootViewController {
	
	if (rootViewController == nil) {
		[NSException raise:NSInvalidArgumentException format:@"rootViewController cannot be nil"];
	}
	
	self = [super init];
	if (self) {
		_rootViewController = rootViewController;
		[self.rootViewController willMoveToParentViewController:self];
		[self addChildViewController:self.rootViewController];
		[self.rootViewController didMoveToParentViewController:self];
		
		self.leftViewWidth = 240.0f;
		self.rightViewWidth = 240.0f;
		
		_state = CARRevealViewStateDefault;
		self.animationDuration = 0.3;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self createRootView];
	[self createMaskView];
	[self createLeftView];
	[self createRightView];
	[self createGestureRecognizers];

	self.rootViewController.view.frame = self.rootView.bounds;
	self.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.rootView addSubview:self.rootViewController.view];
	[self.rootView bringSubviewToFront:self.maskView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subview Initialization
- (void)createMaskView {
	
	NSAssert(self.maskView == nil, @"Are you sure about this?");
	NSAssert(self.rootView, @"Cannot be nil");
	
	self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
	self.maskView.alpha = 0.0f;
	self.maskView.hidden = YES;
	[self.rootView addSubview:self.maskView];
}

- (void)createRootView {
	
	NSAssert(self.rootView == nil, @"Are you sure about this?");

	self.rootView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.rootView.backgroundColor = [UIColor clearColor];
	
	[self.view addSubview:self.rootView];
}

- (void)createLeftView {
	
	NSAssert(self.leftView == nil, @"Are you sure about this?");
	
	self.leftView = [[UIView alloc] initWithFrame:self.leftViewFrame];
	self.leftView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.leftView.backgroundColor = [UIColor clearColor];
	self.leftView.clipsToBounds = YES;
		
	self.leftView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.leftView.layer.shadowRadius = 4.0f;
	self.leftView.layer.shadowOpacity = 0.4f;
	self.leftView.layer.shadowOffset = CGSizeMake(10.0f, 0.0f);
	self.leftView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.leftView.bounds].CGPath;
	self.leftView.layer.shouldRasterize = YES;
	self.leftView.layer.rasterizationScale = [UIScreen mainScreen].scale;
	
	[self.view addSubview:self.leftView];
}

- (void)createRightView {
	
	NSAssert(self.rightView == nil, @"Are you sure about this?");
	
	self.rightView = [[UIView alloc] initWithFrame:self.rightViewFrame];
	self.rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.rightView.backgroundColor = [UIColor clearColor];
	self.rightView.clipsToBounds = YES;
	
	self.rightView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.rightView.layer.shadowRadius = 4.0f;
	self.rightView.layer.shadowOpacity = 0.4f;
	self.rightView.layer.shadowOffset = CGSizeMake(-10.0f, 0.0f);
	self.rightView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.leftView.bounds].CGPath;
	self.rightView.layer.shouldRasterize = YES;
	self.rightView.layer.rasterizationScale = [UIScreen mainScreen].scale;

	[self.view addSubview:self.rightView];
}

- (void)createGestureRecognizers {
	
	_interactiveHideGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideView)];
	_interactiveHideGestureRecognizer.cancelsTouchesInView = NO;
	[self.maskView addGestureRecognizer:_interactiveHideGestureRecognizer];
	
	_interactiveRevealLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealLeftView)];
	_interactiveRevealLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	_interactiveRevealLeftGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveRevealLeftGestureRecognizer.enabled = NO;
	[self.rootView addGestureRecognizer:_interactiveRevealLeftGestureRecognizer];
	
	_interactiveRevealRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealRightView)];
	_interactiveRevealRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	_interactiveRevealRightGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveRevealRightGestureRecognizer.enabled = NO;
	[self.rootView addGestureRecognizer:_interactiveRevealRightGestureRecognizer];
	
	_interactiveHideLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideView)];
	_interactiveHideLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	_interactiveHideLeftGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveHideLeftGestureRecognizer.enabled = NO;
	[self.leftView addGestureRecognizer:_interactiveHideLeftGestureRecognizer];
	
	_interactiveHideRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideView)];
	_interactiveHideRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	_interactiveHideRightGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveHideRightGestureRecognizer.enabled = NO;
	[self.rightView addGestureRecognizer:_interactiveHideRightGestureRecognizer];
}

#pragma mark - Accessor
- (void)changeState:(CARRevealViewState)newState {
	
	if (newState == self.state) {
		return;
	}
	
	_state = newState;
	switch (newState) {
		case CARRevealViewStateDefault:
			if ([self.delegate respondsToSelector:@selector(revealViewControllerDidHideSideViewController:)]) {
				[self.delegate revealViewControllerDidHideSideViewController:self];
			}
			break;
			
		case CARRevealViewStateLeftViewShown:
			if ([self.delegate respondsToSelector:@selector(revealViewController:didRevealLeftViewController:)]) {
				[self.delegate revealViewController:self didRevealLeftViewController:self.leftViewController];
			}
			break;
			
		case CARRevealViewStateRightViewShown:
			if ([self.delegate respondsToSelector:@selector(revealViewController:didRevealRightViewController:)]) {
				[self.delegate revealViewController:self didRevealRightViewController:self.rightViewController];
			}
			break;
			
		default:
			break;
	}
}

- (void)setLeftViewWidth:(CGFloat)leftViewWidth {
	
	// TODO: what happens when the left view is shown?

	_leftViewWidth = leftViewWidth;
	self.leftView.frame = self.leftViewFrame;
}

- (void)setRightViewWidth:(CGFloat)rightViewWidth {
	
	// TODO: what happens when the right view is shown?

	_rightViewWidth = rightViewWidth;
	self.rightView.frame = self.rightViewFrame;
}

- (CGRect)leftViewFrame {
	
	CGRect frame = self.view.bounds;
	frame.size.width = self.leftViewWidth;
	frame.origin.x = -frame.size.width;

	return frame;
}

- (CGRect)rightViewFrame {
	
	CGRect frame = self.view.bounds;
	frame.size.width = self.rightViewWidth;
	frame.origin.x = self.view.bounds.size.width;

	return frame;
}

- (CGRect)leftViewRevealedFrame {
	
	CGRect frame = self.leftViewFrame;
	frame.origin.x = 0.0f;
	return frame;
}

- (CGRect)rightViewRevealedFrame {
	
	CGRect frame = self.rightViewFrame;
	frame.origin.x = self.view.frame.size.width - frame.size.width;
	return frame;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
	
	if (rootViewController == nil || rootViewController == self.rootViewController) {
		return;
	}
	
	[self removeChildViewController:self.rootViewController];
	_rootViewController = rootViewController;
	[self addNewChildViewController:self.rootViewController viewFrame:self.rootView.bounds];
	[self.rootView addSubview:self.rootViewController.view];
	[self.rootView bringSubviewToFront:self.maskView];
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
	
	// TODO: what happens when the left view is shown?

	if (leftViewController == self.leftViewController) {
		return;
	}
	
	[self removeChildViewController:self.leftViewController];
	_leftViewController = leftViewController;
	[self addNewChildViewController:self.leftViewController viewFrame:self.leftViewFrame];
}

- (void)setRightViewController:(UIViewController *)rightViewController {
	
	// TODO: what happens when the right view is shown?

	if (rightViewController == self.rightViewController) {
		return;
	}
	
	[self removeChildViewController:self.rightViewController];
	_rightViewController = rightViewController;
	[self addNewChildViewController:self.rightViewController viewFrame:self.rightViewFrame];
}

#pragma mark - Reveal Methods
- (void)revealLeftViewControllerAnimated:(BOOL)animated completion:(void(^)(void))complation {
	
	if (self.leftViewController == nil || self.state != CARRevealViewStateDefault) {
		return;
	}
	
	self.leftView.frame = self.leftViewFrame;
	self.leftViewController.view.frame = self.leftView.bounds;
	[self.leftView addSubview:self.leftViewController.view];
	
	[self revealSideView:self.leftView
				 toFrame:self.leftViewRevealedFrame
				animated:animated
				 toState:CARRevealViewStateLeftViewShown
			  completion:complation];
}

- (void)revealRightViewControllerAnimated:(BOOL)animated completion:(void(^)(void))complation {
	
	if (self.rightViewController == nil || self.state != CARRevealViewStateDefault) {
		return;
	}
	
	self.rightView.frame = self.rightViewFrame;
	self.rightViewController.view.frame = self.rightView.bounds;
	[self.rightView addSubview:self.rightViewController.view];
	
	[self revealSideView:self.rightView
				 toFrame:self.rightViewRevealedFrame
				animated:animated
				 toState:CARRevealViewStateRightViewShown
			  completion:complation];
}

- (void)hideSideViewControllerAnimated:(BOOL)animated completion:(void(^)(void))complation {
	
	UIView *view = nil;
	UIView *childView = nil;
	CGRect frame = CGRectZero;

	switch (self.state) {
		case CARRevealViewStateDefault:
			return;
			
		case CARRevealViewStateLeftViewShown:
			view = self.leftView;
			childView = self.leftViewController.view;
			frame = self.leftViewFrame;
			break;
			
		case CARRevealViewStateRightViewShown:
			view = self.rightView;
			childView = self.rightViewController.view;
			frame = self.rightViewFrame;
			break;
			
		default:
			break;
	}
	
	view.clipsToBounds = YES;	// To hide side view shadow
	
	void (^animation)(void) = ^(void) {
		view.frame = frame;
		self.maskView.alpha = 0.0f;
	};
	
	void (^revealCompletion)(BOOL finished) = ^(BOOL finished) {
		
		self.maskView.hidden = YES;
		[childView removeFromSuperview];
		[self changeState:CARRevealViewStateDefault];
		if (complation) {
			complation();
		}
	};

	if (animated) {
		[UIView animateWithDuration:self.animationDuration animations:animation completion:revealCompletion];
	}
	else {
		animation();
		revealCompletion(YES);
	}
}

- (void)revealSideView:(UIView *)view toFrame:(CGRect)frame animated:(BOOL)animated toState:(CARRevealViewState)toState completion:(void(^)(void))complation {
	
	self.maskView.hidden = NO;
	self.maskView.alpha = 0.0f;
	
	void (^animation)(void) = ^(void) {
		view.frame = frame;
		self.maskView.alpha = 1.0f;
	};
	
	void (^revealCompletion)(BOOL finished) = ^(BOOL finished) {
		
		view.clipsToBounds = NO;	// To visualize side view shadow
		[self changeState:toState];
		if (complation) {
			complation();
		}
	};
	
	if (animated) {
		[UIView animateWithDuration:self.animationDuration animations:animation completion:revealCompletion];
	}
	else {
		animation();
		revealCompletion(YES);
	}
}

- (void)revealLeftView {
	[self revealLeftViewControllerAnimated:YES completion:NULL];
}

- (void)revealRightView {
	[self revealRightViewControllerAnimated:YES completion:NULL];
}

- (void)hideSideView {
	[self hideSideViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ContainerViewController Methods
#pragma mark Method Forwarding
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
	return YES;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
	return YES;
}

#pragma mark
- (void)removeChildViewController:(UIViewController *)childViewController {
	
	[childViewController.view removeFromSuperview];
	[childViewController removeFromParentViewController];
}

- (void)addNewChildViewController:(UIViewController *)childViewController viewFrame:(CGRect)frame {

	[childViewController willMoveToParentViewController:self];
	[self addChildViewController:childViewController];
	[childViewController didMoveToParentViewController:self];
	
	childViewController.view.frame = frame;
	childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	childViewController.view.clipsToBounds = YES;
	
	// ここでaddSubviewしないのはsideViewControllerはreveal時にaddSubviewすることでviewWillAppearを呼ばせたいため
}

@end

@implementation UIViewController (CARRevealViewController)

- (CARRevealViewController *)revealViewController {
	
	for (UIViewController *viewController = self.parentViewController; viewController != nil; viewController = viewController.parentViewController) {
		if ([viewController isKindOfClass:[CARRevealViewController class]]) {
			return (CARRevealViewController *)viewController;
		}
	}
	return nil;
}

@end
