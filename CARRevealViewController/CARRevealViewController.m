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

@property (nonatomic, getter = isMaskViewHidden) BOOL maskViewHidden;

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

- (void)addRevealChildView:(UIView *)view toView:(UIView *)superView;
- (void)removeRevealChildViewController:(UIViewController *)childViewController;
- (void)addRevealChildViewController:(UIViewController *)childViewController;

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
@synthesize maskViewHidden = _maskViewHidden;

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
		
		[self createGestureRecognizers];
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
	
	[self addRevealChildView:self.rootViewController.view toView:self.rootView];
	[self.rootView bringSubviewToFront:self.maskView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation
- (BOOL)shouldAutorotate {
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
	return 0;
}

#pragma mark - Subview Initialization
- (void)createMaskView {
	
	NSAssert(self.maskView == nil, @"Are you sure about this?");
	NSAssert(self.rootView, @"Cannot be nil");
	NSAssert(self.interactiveHideGestureRecognizer, @"Cannot be nil");
	
	self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
	self.maskView.alpha = 0.0f;
	self.maskViewHidden = YES;
	
	[self.rootView addSubview:self.maskView];
	[self.maskView addGestureRecognizer:self.interactiveHideGestureRecognizer];
	[self.maskView addGestureRecognizer:self.interactiveHideLeftGestureRecognizer];
	[self.maskView addGestureRecognizer:self.interactiveHideRightGestureRecognizer];
}

- (void)createRootView {
	
	NSAssert(self.rootView == nil, @"Are you sure about this?");
	NSAssert(self.interactiveRevealLeftGestureRecognizer, @"Cannot be nil");
	NSAssert(self.interactiveRevealRightGestureRecognizer, @"Cannot be nil");

	self.rootView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.rootView.backgroundColor = [UIColor clearColor];
	
	[self.view addSubview:self.rootView];
	[self.rootView addGestureRecognizer:self.interactiveRevealLeftGestureRecognizer];
	[self.rootView addGestureRecognizer:self.interactiveRevealRightGestureRecognizer];
}

- (void)createLeftView {
	
	NSAssert(self.leftView == nil, @"Are you sure about this?");
	NSAssert(self.interactiveHideLeftGestureRecognizer, @"Cannot be nil");

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
	NSAssert(self.interactiveHideRightGestureRecognizer, @"Cannot be nil");

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
	
	_interactiveRevealLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealLeftView)];
	_interactiveRevealLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	_interactiveRevealLeftGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveRevealLeftGestureRecognizer.enabled = NO;
	
	_interactiveRevealRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealRightView)];
	_interactiveRevealRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	_interactiveRevealRightGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveRevealRightGestureRecognizer.enabled = NO;
	
	_interactiveHideLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideView)];
	_interactiveHideLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	_interactiveHideLeftGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveHideLeftGestureRecognizer.enabled = NO;
	
	_interactiveHideRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideView)];
	_interactiveHideRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	_interactiveHideRightGestureRecognizer.cancelsTouchesInView = NO;
	_interactiveHideRightGestureRecognizer.enabled = NO;
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
	
	if (self.leftView == nil) {
		return;	// To not load self.view
	}
	
	self.leftView.frame = self.leftViewFrame;
	self.leftView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.leftView.bounds].CGPath;
}

- (void)setRightViewWidth:(CGFloat)rightViewWidth {
	
	// TODO: what happens when the right view is shown?

	_rightViewWidth = rightViewWidth;
	
	if (self.rightView == nil) {
		return;	// To not load self.view
	}

	self.rightView.frame = self.rightViewFrame;
	self.rightView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.rightView.bounds].CGPath;
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
	
	[self removeRevealChildViewController:self.rootViewController];
	_rootViewController = rootViewController;
	[self addRevealChildViewController:self.rootViewController];
	[self addRevealChildView:self.rootViewController.view toView:self.rootView];
	[self.rootView bringSubviewToFront:self.maskView];
	
	if (self.state != CARRevealViewStateDefault) {
		[self hideSideViewControllerAnimated:YES completion:NULL];
	}
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
	
	if (leftViewController == self.leftViewController) {
		return;
	}
	
	BOOL leftViewShown = (self.state == CARRevealViewStateLeftViewShown);
	
	void (^leftViewControllerSetter)(void) = ^(void) {
		
		[self removeRevealChildViewController:self.leftViewController];
		_leftViewController = leftViewController;
		[self addRevealChildViewController:self.leftViewController];
		
		if (leftViewShown) {
			[self revealLeftViewControllerAnimated:YES completion:NULL];
		}
	};
		
	if (leftViewShown) {
		[self hideSideViewControllerAnimated:YES completion:leftViewControllerSetter];
	}
	else {
		leftViewControllerSetter();
	}
}

- (void)setRightViewController:(UIViewController *)rightViewController {
	
	if (rightViewController == self.rightViewController) {
		return;
	}
	
	BOOL rightViewShown = (self.state == CARRevealViewStateRightViewShown);
	
	void (^rightViewControllerSetter)(void) = ^(void) {
		
		[self removeRevealChildViewController:self.rightViewController];
		_rightViewController = rightViewController;
		[self addRevealChildViewController:self.rightViewController];
		
		if (rightViewShown) {
			[self revealRightViewControllerAnimated:YES completion:NULL];
		}
	};

	if (rightViewShown) {
		[self hideSideViewControllerAnimated:YES completion:rightViewControllerSetter];
	}
	else {
		rightViewControllerSetter();
	}
}

- (void)setMaskViewHidden:(BOOL)maskViewHidden {
	
	_maskViewHidden = maskViewHidden;
	self.maskView.hidden = maskViewHidden;
	self.maskView.userInteractionEnabled = !maskViewHidden;
}

#pragma mark - Reveal Methods
- (void)revealLeftViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion {
	
	if (self.leftViewController == nil || self.state != CARRevealViewStateDefault) {
		return;
	}
	
	self.leftView.frame = self.leftViewFrame;
	[self addRevealChildView:self.leftViewController.view toView:self.leftView];
		
	[self revealSideView:self.leftView
				 toFrame:self.leftViewRevealedFrame
				animated:animated
				 toState:CARRevealViewStateLeftViewShown
			  completion:completion];
}

- (void)revealRightViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion {
	
	if (self.rightViewController == nil || self.state != CARRevealViewStateDefault) {
		return;
	}
	
	self.rightView.frame = self.rightViewFrame;
	[self addRevealChildView:self.rightViewController.view toView:self.rightView];
	
	[self revealSideView:self.rightView
				 toFrame:self.rightViewRevealedFrame
				animated:animated
				 toState:CARRevealViewStateRightViewShown
			  completion:completion];
}

- (void)hideSideViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion {
	
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
		
		self.maskViewHidden = YES;
		[childView removeFromSuperview];
		[self changeState:CARRevealViewStateDefault];
		if (completion) {
			completion();
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
	
	self.maskViewHidden = NO;
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
- (void)addRevealChildView:(UIView *)view toView:(UIView *)superView {
	
	NSAssert(view, @"view cannot be nil");
	NSAssert(superView, @"superView cannot be nil");
	
	view.frame = superView.bounds;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.clipsToBounds = YES;

	[superView addSubview:view];
}

- (void)removeRevealChildViewController:(UIViewController *)childViewController {
	
	[childViewController.view removeFromSuperview];
	[childViewController removeFromParentViewController];
}

- (void)addRevealChildViewController:(UIViewController *)childViewController {

	[childViewController willMoveToParentViewController:self];
	[self addChildViewController:childViewController];
	[childViewController didMoveToParentViewController:self];
		
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
