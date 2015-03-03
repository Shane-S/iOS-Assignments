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
const float DEFAULT_FARPLANE = 100.0f;

@implementation Camera

-(instancetype)initWithPosition: (GLKVector3)position andLookAtPoint: (GLKVector3)lookAtPoint andProjectionMatrix: (GLKMatrix4)projection
{
    if((self = [super init]))
    {
        _projection = projection;
        _position = position;
        _lookAtPoint = lookAtPoint;
        _view = GLKMatrix4MakeLookAt(position.x, position.y, position.z, lookAtPoint.x, lookAtPoint.y, lookAtPoint.z, 0, 1, 0);
        _viewProjection = GLKMatrix4Multiply(projection, _view);
    }
    return self;
}

-(void) updateMatricesWithScreenWidth:(int)width andScreenHeight:(int)height andFieldOfView:(float)fov
{
    float aspectRatio = (float)width / height;
    
    _view = GLKMatrix4MakeLookAt(_position.x, _position.y, _position.z, _lookAtPoint.x, _lookAtPoint.y, _lookAtPoint.z, 0, 1, 0);
    
    _projection = GLKMatrix4MakePerspective(DEFAULT_FOV, aspectRatio, DEFAULT_NEARPLANE, DEFAULT_FARPLANE);
    _viewProjection = GLKMatrix4Multiply(_projection, _view);
}
@end
