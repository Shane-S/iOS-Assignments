//
//  AIEntity.m
//  Assignment3
//
//  Created by Dan Russell on 2015-03-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIEntity.h"
#import "NSMutableArray_Shuffling.h"

@implementation AIEntity
{
    Direction lastDir;
    Direction selectedDir;
}

-(instancetype)init
{
    if((self = [super init]))
    {
        _position = GLKVector3Make(0, 0, 0);
        _scale = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _rotation = GLKVector3Make(0, 0, 0);
        _targetPosition = GLKVector3Make(0, 0, 0);
        _state = choosingDirection;
        _speed = 1.0f;
    }
    return self;
}

-(void)updateWithElapsedTime:(float) deltaTime andMap:(MazeWrapper*) maze
{
    if (_state == choosingDirection)
    {
        MazeCell cell;
        
        int cellCol = floorf(_position.x);
        int cellRow = floorf(_position.z);
        
        if (cellCol < 0)
        {
            cellCol = 0;
        }
        else if (cellCol > ([maze numCols] - 1))
        {
            cellCol = ([maze numCols] - 1);
        }
        
        if (cellRow < 0)
        {
            cellRow = 0;
        }
        else if (cellRow > ([maze numRows] - 1))
        {
            cellRow = ([maze numRows] - 1);
        }
        
        [maze getCellAtRow:cellRow andCol:cellCol storeIn:&cell];
        
        
        NSNumber *north = [NSNumber numberWithInt:dirNORTH];
        NSNumber *south = [NSNumber numberWithInt:dirSOUTH];
        NSNumber *west = [NSNumber numberWithInt:dirWEST];
        NSNumber *east = [NSNumber numberWithInt:dirEAST];
        NSMutableArray *directions = [[NSMutableArray alloc] initWithObjects:north, south, west, east, nil];
        
        NSMutableArray *possibleDirections = [[NSMutableArray alloc] init];
        
        while (directions.count != 0)
        {
            [directions shuffle];
            
            // find possible directions to travel in
            switch ([[directions objectAtIndex:0] intValue])
            {
                case dirNORTH:
                {
                    if (cell.northWallPresent || (cellCol == 0 && cellRow == 0))
                        [directions removeObjectAtIndex:0];
                    else
                    {
                        [possibleDirections addObject:[NSNumber numberWithInt:dirNORTH]];
                        [directions removeObjectAtIndex:0];
                    }
                } break;
                case dirSOUTH:
                {
                    if (cell.southWallPresent  || (cellCol == ([maze numCols] - 1) && cellRow == ([maze numRows] - 1)))
                        [directions removeObjectAtIndex:0];
                    else
                    {
                        [possibleDirections addObject:[NSNumber numberWithInt:dirSOUTH]];
                        [directions removeObjectAtIndex:0];
                    }
                } break;
                case dirWEST:
                {
                    if (cell.westWallPresent)
                        [directions removeObjectAtIndex:0];
                    else
                    {
                        [possibleDirections addObject:[NSNumber numberWithInt:dirWEST]];
                        [directions removeObjectAtIndex:0];
                    }
                } break;
                case dirEAST:
                {
                    if (cell.eastWallPresent)
                        [directions removeObjectAtIndex:0];
                    else
                    {
                        [possibleDirections addObject:[NSNumber numberWithInt:dirEAST]];
                        [directions removeObjectAtIndex:0];
                    }
                } break;
                    
                default:
                    break;
            }
        }
        
        lastDir = selectedDir;
        
        selectedDir = [[possibleDirections objectAtIndex:0] intValue];
        
        // prioritize directions that don't backtrack
        for (int i = 0; i < [possibleDirections count]; ++i)
        {
            Direction dir = [[possibleDirections objectAtIndex:i] intValue];
            
            switch (lastDir) {
                case dirNORTH:
                {
                    if (dir != dirSOUTH)
                    {
                        selectedDir = dir;
                    }
                } break;
                case dirSOUTH:
                {
                    if (dir != dirNORTH)
                    {
                        selectedDir = dir;
                    }
                } break;
                case dirWEST:
                {
                    if (dir != dirEAST)
                    {
                        selectedDir = dir;
                    }
                } break;
                case dirEAST:
                {
                    if (dir != dirWEST)
                    {
                        selectedDir = dir;
                    }
                } break;
                    
                default:
                    break;

            }
        }
        
        _targetPosition = GLKVector3Make(0, 0, 0);
        GLKVector3 cellPosition = GLKVector3Make(cellCol, 0, cellRow);
        
        switch (selectedDir) {
            case dirNORTH:
            {
                _targetPosition = GLKVector3Add(cellPosition, GLKVector3Make(0, 0, -1));
            } break;
            case dirSOUTH:
            {
                _targetPosition = GLKVector3Add(cellPosition, GLKVector3Make(0, 0, 1));
            } break;
            case dirWEST:
            {
                _targetPosition = GLKVector3Add(cellPosition, GLKVector3Make(-1, 0, 0));
            } break;
            case dirEAST:
            {
                _targetPosition = GLKVector3Add(cellPosition, GLKVector3Make(1, 0, 0));
            } break;
                
            default:
                break;
                
        }
        
        _state = moving;
    }
    else if (_state == moving)
    {
        GLKVector3 toTarget = GLKVector3Subtract(_targetPosition, _position);
        float length = GLKVector3Length(toTarget);
        if (length > 0) {
            toTarget = GLKVector3Normalize(toTarget);
        }
        GLKVector3 displacement = GLKVector3MultiplyScalar(toTarget, _speed * deltaTime);
        
        if (length < 0.1)
        {
            _state = choosingDirection;
            _position = _targetPosition;
        }
        else
        {
            _position = GLKVector3Add(_position, displacement);
        }
    }
}
@end