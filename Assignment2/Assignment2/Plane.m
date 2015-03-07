//
//  Plane.m
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-02.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "Plane.h"

static const float _planeVertices[5][FLOATS_PER_FACE] =
{
    // North wall
    {
     // positionX, positionY, positionZ,     normalX, normalY, normalZ, u, v
        0.5f,      0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    1, 1,
       -0.5f,      0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    0, 1,
        0.5f,     -0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    1, 0,
        0.5f,     -0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    1, 0,
       -0.5f,      0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    0, 1,
       -0.5f,     -0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    0, 0,
    },
    
    // South wall
    {
     // positionX, positionY, positionZ,     normalX, normalY, normalZ, u, v
        0.5f,     -0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    0, 0,
       -0.5f,     -0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    1, 0,
        0.5f,      0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    0, 1,
        0.5f,      0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    0, 1,
       -0.5f,     -0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    1, 0,
       -0.5f,      0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    1, 1
    },
    
    // West wall
    {
     // positionX, positionY, positionZ,     normalX, normalY, normalZ, u, v
        0.5f,     -0.5f,     -0.5f,          1.0f,    0.0f,    0.0f,    1, 0,
        0.5f,      0.5f,     -0.5f,          1.0f,    0.0f,    0.0f,    1, 1,
        0.5f,     -0.5f,      0.5f,          1.0f,    0.0f,    0.0f,    0, 0,
        0.5f,     -0.5f,      0.5f,          1.0f,    0.0f,    0.0f,    0, 0,
        0.5f,      0.5f,     -0.5f,          1.0f,    0.0f,    0.0f,    1, 1,
        0.5f,      0.5f,      0.5f,          1.0f,    0.0f,    0.0f,    0, 1,
    },
    
    // East wall
    {
      // positionX, positionY, positionZ,    normalX, normalY, normalZ, u, v
        -0.5f,      0.5f,     -0.5f,        -1.0f,    0.0f,    0.0f,    0, 1,
        -0.5f,     -0.5f,     -0.5f,        -1.0f,    0.0f,    0.0f,    0, 0,
        -0.5f,      0.5f,      0.5f,        -1.0f,    0.0f,    0.0f,    1, 1,
        -0.5f,      0.5f,      0.5f,        -1.0f,    0.0f,    0.0f,    1, 1,
        -0.5f,     -0.5f,     -0.5f,        -1.0f,    0.0f,    0.0f,    0, 0,
        -0.5f,     -0.5f,      0.5f,        -1.0f,    0.0f,    0.0f,    1, 0,
    },
    
    // Floor
    {
     // positionX, positionY, positionZ,     normalX, normalY, normalZ, u, v
        0.5f,      0.5f,     -0.5f,          0.0f,    1.0f,    0.0f,    1, 1,
       -0.5f,      0.5f,     -0.5f,          0.0f,    1.0f,    0.0f,    0, 1,
        0.5f,      0.5f,      0.5f,          0.0f,    1.0f,    0.0f,    1, 0,
        0.5f,      0.5f,      0.5f,          0.0f,    1.0f,    0.0f,    1, 0,
       -0.5f,      0.5f,     -0.5f,          0.0f,    1.0f,    0.0f,    0, 1,
       -0.5f,      0.5f,      0.5f,          0.0f,    1.0f,    0.0f,    0, 0,
    }
};

// The correct positioning in the cube to have the wall face inward from its side
const GLKVector3 planePositions[5] =
{
    {0, 0, -1},
    {0, 0, 1},
    {-1, 0, 0},
    {1, 0, 0},
    {0, -1, 0}
};

@implementation Plane

-(instancetype)initWithPosition:(GLKVector3)pos andScale: (float)scale andPlaneType:(PlaneType)type
{
    if((self = [super init]))
    {
        _type = type;
        _position = pos;
        _vertices = &(_planeVertices[type][0]);
        _verticesSize = sizeof(_planeVertices[type]);
        _scale = scale;
    }
    return self;
}

@end
