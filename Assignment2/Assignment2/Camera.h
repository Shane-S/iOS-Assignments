//
//  Camera.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-02-28.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Camera : NSObject

@property (nonatomic) GLKMatrix4 view;
@property (nonatomic) GLKMatrix4 projection;
@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 lookAtPoint;
@property (nonatomic, readonly) GLKMatrix4 viewProjection;

extern const float DEFAULT_FOV;
extern const float DEFAULT_NEARPLANE;
extern const float DEFAULT_FARPLANE;

/**
 * @brief Initialises a camera object with the specified view and projection matrices.
 *
 * @param position    The camera's position in world space.
 * @param lookAtPoint The point at which the camera is directed.
 * @param projection  The projection matrix.
 * @return A Camera instance.
 */
-(instancetype)initWithPosition: (GLKVector3)position andLookAtPoint: (GLKVector3)lookAtPoint andProjectionMatrix: (GLKMatrix4)projection;

/**
 * @brief Updates the projection and viewProjection matrices.
 * @discussion Note that the units of width and height are irrelevant as long as they are in the same units as they will be used to used to calculate
 * the aspect ratio.
 * @param width  The screen's width.
 * @param height The screen's height.
 */
-(void)updateMatricesWithScreenWidth: (int)width andScreenHeight: (int)height andFieldOfView: (float)fov;

@end
