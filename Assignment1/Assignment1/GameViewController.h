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
@property (weak, nonatomic) IBOutlet UIButton *cubeResetBtn;
@property (weak, nonatomic) IBOutlet UILabel *cubeInfoLabel;

@end
