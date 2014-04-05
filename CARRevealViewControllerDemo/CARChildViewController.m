//
//  CARChildViewController.m
//  CARRevealViewControllerDemo
//
//  Created by Yamazaki Mitsuyoshi on 4/6/14.
//  Copyright (c) 2014 CrayonApps.inc. All rights reserved.
//

#import "CARChildViewController.h"

@interface CARChildViewController ()

@end

@implementation CARChildViewController

- (id)initWithTitle:(NSString *)title color:(UIColor *)color {
	
	self = [super init];
	if (self) {
		
		// デモ用
		// subViewの初期化は-loadViewか-viewDidLoadでするべき
		
		CGFloat margin = 20.0f;
		UIViewController *viewController = [[UIViewController alloc] init];
		viewController.view.backgroundColor = [UIColor whiteColor];
		
		CGRect labelFrame = viewController.view.bounds;
		labelFrame.origin.x += margin;
		labelFrame.origin.y += margin;
		labelFrame.size.width -= margin * 2.0f;
		labelFrame.size.height -= margin * 2.0f;
		
		UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
		label.backgroundColor = color;
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		label.font = [UIFont systemFontOfSize:30.0f];
		label.textAlignment = NSTextAlignmentCenter;
		label.text = title;
		
		self.view.backgroundColor = [UIColor whiteColor];
		[self.view addSubview:label];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MethodInfo;
}

- (void)viewWillDisappear:(BOOL)animated {
	MethodInfo;
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
