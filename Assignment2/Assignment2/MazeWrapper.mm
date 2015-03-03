//
//  Maze.m
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-01.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "MazeWrapper.h"
#import "maze.h"

#define DEFAULT_DIMENSIONS 4

const float MAZE_CELL_WIDTH = 1;

struct MazeImpl {
public:
    Maze *maze;
    MazeImpl(int rows, int cols): maze(new Maze(rows, cols)){maze->Create();} // Creates a maze with the default number of columns and rows
    ~MazeImpl() {delete maze; maze = NULL;}
};

@implementation MazeWrapper

-(instancetype) init
{
    return [self initWithRows:DEFAULT_DIMENSIONS andCols:DEFAULT_DIMENSIONS];
}

-(instancetype)initWithRows:(int)rows andCols:(int)cols
{
    if((self = [super init]))
    {
        mazeImpl = new MazeImpl(rows, cols);
    }
    return self;
}

-(void)dealloc
{
    delete mazeImpl;
    mazeImpl = NULL;
}

-(int)numRows
{
    return mazeImpl->maze->rows;
}

-(int)numCols
{
    return mazeImpl->maze->cols;
}

@end
