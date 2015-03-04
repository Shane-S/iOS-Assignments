//
//  Cube.h
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef Assignment1_Cube_h
#define Assignment1_Cube_h

#import <GLKit/GLKit.h>

@interface Cube : NSObject

/// Scale in each axis
@property (nonatomic) GLKVector3 scale;

/// Position in (x, y, z)
@property (nonatomic) GLKVector3 position;

/// Rotation in each axis
@property (nonatomic) GLKVector3 rotation;

/// Reference to the vertices of the cube
@property (nonatomic) GLfloat* vertexData;

/// The size of the vertex array in bytes.
@property (nonatomic) uint vertexArraySize;

/// Make a cube at the specified position and with default scale & rotation.
- (instancetype) initWithPosition: (GLKVector3) pos;

/// Make a cube at the specified location with the specified rotation.
- (instancetype) initWithRotation: (GLKVector3)rot andPosition: (GLKVector3) rot;

/// Make a cube at the specified location and with the specified rotation and scale.
- (instancetype) initWithScale: (GLKVector3)scl andRotation: (GLKVector3)rot andPosition: (GLKVector3)pos;

/// Returns a reference to the rotation property.
- (GLKVector3 *)rotationRef;

/// Returns a reference to the position.
- (GLKVector3 *)positionRef;

/// Returns a reference to the scale.
- (GLKVector3 *)scaleRef;
@end

#endif
