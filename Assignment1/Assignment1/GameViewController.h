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
#include "Counter.h"

@interface GameViewController : GLKViewController
@property (weak, nonatomic) IBOutlet UILabel *cubeInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *counterValueLabel;

@end
