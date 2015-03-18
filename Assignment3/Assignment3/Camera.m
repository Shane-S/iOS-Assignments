//
//  Camera.m
//  Assignment2
//
//  Created by Shane Spoor on 2015-02-28.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "Camera.h"

const float DEFAULT_FOV = M_PI / 3;
const float DEFAULT_NEARPLANE = 0.1f;
const float DEFAULT_FARPLANE = 1000.0f;

@implementation Camera

-(instancetype)initWithPosition: (GLKVector3)position andRotation: (float)rotation andProjectionMatrix: (GLKMatrix4)projection
{
    if((self = [super init]))
    {
        _projection = projection;
        _position = position;
        _rotation = rotation;
        _view = GLKMatrix4Rotate(GLKMatrix4Identity, -rotation, 0, 1, 0);
        _view = GLKMatrix4Translate(_view, -position.x, -position.y, -position.z);
        _viewProjection = GLKMatrix4Multiply(projection, _view);
    }
    return self;
}

-(void) updateMatricesWithScreenWidth:(int)width andScreenHeight:(int)height andFieldOfView:(float)fov
{
    float aspectRatio = (float)width / height;
    
    // Note: since we're translating the world about the camera, the transforms must all be negated
    _view = GLKMatrix4RotateY(GLKMatrix4Identity, -_rotation);
    _view = GLKMatrix4Translate(_view, -_position.x, -_position.y, -_position.z);
    
    _projection = GLKMatrix4MakePerspective(DEFAULT_FOV, aspectRatio, DEFAULT_NEARPLANE, DEFAULT_FARPLANE);
    _viewProjection = GLKMatrix4Multiply(_projection, _view);
}

-(GLKVector3)lookDirection
{
    // Rotate the -z axis (the camera's default look direction) about y to match the camera's current direction
    GLKVector3 direction;
    GLKMatrix4 rot = GLKMatrix4MakeYRotation(_rotation);

    direction = GLKMatrix4MultiplyVector3(rot, GLKVector3Make(0, 0, -1));
    
    return direction;
}
@end
