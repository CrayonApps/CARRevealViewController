//
//  CARChildViewController.m
//  CARRevealViewControllerDemo
//
//  Created by Yamazaki Mitsuyoshi on 4/6/14.
//  Copyright (c) 2014 CrayonApps.inc. All rights reserved.
//

#import "CARChildViewController.h"

#import "CARRevealViewController.h"

@interface CARChildViewController ()

@property (nonatomic, readonly) NSString *labelTitle;
@property (nonatomic, readonly) UIColor *color;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)didSelectSegment:(id)sender;

@end

@implementation CARChildViewController

@synthesize labelTitle = _labelTitle;
@synthesize color = _color;

+ (UIColor *)nextColor {
	static NSInteger index = 0;
	
	NSArray *colors = @[@"green", @"red", @"blue", @"brown", @"orange", @"purple", @"darkGray", @"magenta", @"cyan"];
	NSString *colorName = colors[index];
	index = (index + 1) % colors.count;

	NSString *selectorName = [NSString stringWithFormat:@"%@Color", colorName];
	SEL selector = NSSelectorFromString(selectorName);
	
	return [[UIColor class] performSelector:selector];
}

- (id)initWithTitle:(NSString *)title color:(UIColor *)color {
	
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		_labelTitle = title.copy;
		_color = color;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.titleLabel.backgroundColor = self.color;
	self.titleLabel.text = self.labelTitle;	
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

- (IBAction)didSelectSegment:(id)sender {

	UISegmentedControl *segmentedControl = sender;
	
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:	// Left
			self.revealViewController.leftViewController = [[CARChildViewController alloc] initWithTitle:@"Left" color:[self.class nextColor]];
			break;
			
		case 1:	// Center
			self.revealViewController.rootViewController = [[CARChildViewController alloc] initWithTitle:@"RootViewController" color:[self.class nextColor]];
			break;
			
		case 2:	// Right
			self.revealViewController.rightViewController = [[CARChildViewController alloc] initWithTitle:@"Right" color:[self.class nextColor]];
			break;
			
		default:
			break;
	}
}

@end
