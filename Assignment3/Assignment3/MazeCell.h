//
//  MazeCell.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-03.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef Assignment2_MazeCell_h
#define Assignment2_MazeCell_h

typedef struct MazeCell
{
    bool northWallPresent, southWallPresent, eastWallPresent, westWallPresent;
} MazeCell;

typedef enum { dirNORTH=0, dirEAST, dirSOUTH, dirWEST } Direction;

#endif
