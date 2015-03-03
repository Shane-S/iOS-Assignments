//
//  MazeWrapper.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-01.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const float MAZE_CELL_WIDTH;

typedef struct MazeImpl MazeImpl;

@interface MazeWrapper : NSObject
{
    MazeImpl* mazeImpl;
}

@property (readonly, nonatomic) int numCols;
@property (readonly, nonatomic) int numRows;

-(instancetype) initWithRows: (int)rows andCols: (int)cols;


@end