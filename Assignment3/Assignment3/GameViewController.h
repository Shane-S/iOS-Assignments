//
//  GameViewController.h
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Cube.h"
#import "CubeView.h"

@interface GameViewController : GLKViewController

@property (weak, nonatomic) IBOutlet UIButton *adjustModelBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fogTypeToggle;
@property (weak, nonatomic) IBOutlet UILabel *fogColourLabel;
@property (weak, nonatomic) IBOutlet UILabel *fogColourRLabel;
@property (weak, nonatomic) IBOutlet UILabel *fogColourGLabel;
@property (weak, nonatomic) IBOutlet UILabel *fogColourBLabel;
@property (weak, nonatomic) IBOutlet UISlider *fogColourRSlider;
@property (weak, nonatomic) IBOutlet UISlider *fogColourGSlider;
@property (weak, nonatomic) IBOutlet UISlider *fogColourBSlider;
@property (weak, nonatomic) IBOutlet UIButton *fogToggle;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapToggle;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *flashlightToggleRecognizer;
@end
