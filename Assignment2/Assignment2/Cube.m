//
//  Cube.m
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cube.h"

static GLfloat _actualCubeVertices[] = {
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ, u, v
       0.5f,     -0.5f,     -0.5f,          1.0f,    0.0f,    0.0f,    1, 0,
       0.5f,      0.5f,     -0.5f,          1.0f,    0.0f,    0.0f,    1, 1,
       0.5f,     -0.5f,      0.5f,          1.0f,    0.0f,    0.0f,    0, 0,
       0.5f,     -0.5f,      0.5f,          1.0f,    0.0f,    0.0f,    0, 0,
       0.5f,      0.5f,     -0.5f,          1.0f,    0.0f,    0.0f,    1, 1,
       0.5f,      0.5f,      0.5f,          1.0f,    0.0f,    0.0f,    0, 1,
    
       0.5f,      0.5f,     -0.5f,          0.0f,    1.0f,    0.0f,    1, 1,
      -0.5f,      0.5f,     -0.5f,          0.0f,    1.0f,    0.0f,    0, 1,
       0.5f,      0.5f,      0.5f,          0.0f,    1.0f,    0.0f,    1, 0,
       0.5f,      0.5f,      0.5f,          0.0f,    1.0f,    0.0f,    1, 0,
      -0.5f,      0.5f,     -0.5f,          0.0f,    1.0f,    0.0f,    0, 1,
      -0.5f,      0.5f,      0.5f,          0.0f,    1.0f,    0.0f,    0, 0,
    
      -0.5f,      0.5f,     -0.5f,         -1.0f,    0.0f,    0.0f,    0, 1,
      -0.5f,     -0.5f,     -0.5f,         -1.0f,    0.0f,    0.0f,    0, 0,
      -0.5f,      0.5f,      0.5f,         -1.0f,    0.0f,    0.0f,    1, 1,
      -0.5f,      0.5f,      0.5f,         -1.0f,    0.0f,    0.0f,    1, 1,
      -0.5f,     -0.5f,     -0.5f,         -1.0f,    0.0f,    0.0f,    0, 0,
      -0.5f,     -0.5f,      0.5f,         -1.0f,    0.0f,    0.0f,    1, 0,
    
      -0.5f,     -0.5f,     -0.5f,          0.0f,    -1.0f,   0.0f,    0, 0,
       0.5f,     -0.5f,     -0.5f,          0.0f,    -1.0f,   0.0f,    1, 0,
      -0.5f,     -0.5f,      0.5f,          0.0f,    -1.0f,   0.0f,    0, 1,
      -0.5f,     -0.5f,      0.5f,          0.0f,    -1.0f,   0.0f,    0, 1,
       0.5f,     -0.5f,     -0.5f,          0.0f,    -1.0f,   0.0f,    1, 0,
       0.5f,     -0.5f,      0.5f,          0.0f,    -1.0f,   0.0f,    1, 1,
    
       0.5f,      0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    1, 1,
      -0.5f,      0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    0, 1,
       0.5f,     -0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    1, 0,
       0.5f,     -0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    1, 0,
      -0.5f,      0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    0, 1,
      -0.5f,     -0.5f,      0.5f,          0.0f,     0.0f,   1.0f,    0, 0,
    
       0.5f,     -0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    0, 0,
      -0.5f,     -0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    1, 0,
       0.5f,      0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    0, 1,
       0.5f,      0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    0, 1,
      -0.5f,     -0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    1, 0,
      -0.5f,      0.5f,     -0.5f,          0.0f,     0.0f,  -1.0f,    1, 1
};

@implementation Cube

-(instancetype)init {
    return [self initWithScale: GLKVector3Make(1, 1, 1) Rotation: GLKVector3Make(0, 0, 0) andPosition: GLKVector3Make(0, 0, 0)];
}

-(instancetype)initWithPosition:(GLKVector3)pos {
    return [self initWithScale: GLKVector3Make(1, 1, 1) Rotation: GLKVector3Make(0, 0, 0) andPosition: pos];
}

-(instancetype) initWithRotation: (GLKVector3)rot andPosition: (GLKVector3)pos {
    return [self initWithScale: GLKVector3Make(1, 1, 1) Rotation: rot andPosition: pos];
}

-(instancetype)initWithScale:(GLKVector3)scl Rotation: (GLKVector3)rot andPosition: (GLKVector3)pos{
    self = [super init];
    
    if(self) {
        _position = pos;
        _rotation = rot;
        _scale = scl;
        
        // Give the class a reference to the cube vertices
        _vertexData = _actualCubeVertices;
        _vertexArraySize = sizeof(_actualCubeVertices);
    }
    
    return self;
}

- (GLKVector3 *)rotationRef {
    return &_rotation;
}

-(GLKVector3 *)positionRef {
    return &_position;
}

-(GLKVector3 *)scaleRef {
    return &_scale;
}
@end