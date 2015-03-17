//
//  MinimapView.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-06.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "MazeWrapper.h"
#import "CubeView.h"

@interface MinimapView : NSObject

@property (strong, nonatomic) NSMutableArray* mazeWalls;
@property (strong, nonatomic) MazeWrapper* maze;
@property (strong, nonatomic) CubeView* cubeView;
@property (nonatomic) float percentOfScreen;

-(instancetype) initWithMaze: (MazeWrapper*) maze andWalls: (NSMutableArray *)mazeWalls andCube: (CubeView *)cubeView;
-(void) drawWithAspectRatio: (float)aspectRatio;

@end
