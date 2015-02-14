//
//  CubeView.h
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-11.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Cube.h"

@interface CubeView : NSObject

/// Reference to the vertices of the cube
@property (nonatomic) GLuint vertexArray;
@property (nonatomic) GLuint vertexBuffer;

@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix4 modelViewProjectionMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

/**
 * @brief Draws the cube.
 */
- (void)draw;

/**
 * @brief Updates the normal and model-view matrices.
 * @param projection The perspective matrix.
 * @param cameraBase The matrix defining camera's rotation and position.
 */
- (void)updateMatricesWithProjection: (GLKMatrix4 *)projection andCameraBase: (GLKMatrix4 *)cameraBase;

/**
 * @brief Initialises the CubeView with a reference to the cube it will render.
 */
- (instancetype) initWithCube: (Cube *)cube;
@end
