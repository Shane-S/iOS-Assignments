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

@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

@property (strong, nonatomic) Cube* cube;

/// The integer identifying the texture with which the plane view was constructed
@property (readonly, nonatomic) GLuint texture;

/**
 * @brief Updates the normal and model-view matrices.
 * @param projection The perspective matrix.
 * @param cameraBase The matrix defining camera's rotation and position.
 */
- (void)updateMatricesWithView: (GLKMatrix4)view;

/**
 * @brief Initialises the CubeView with a reference to the cube it will render.
 * @param cube    The cube to be rendered.
 * @param texture The texture (if any) to be used with the cube. Specify nil if there is no texture.
 */
- (instancetype) initWithCube: (Cube *)cube andTexture: (GLuint)texture;

/**
 * @brief Tells the cube view to free any resources it is holding.
 */
- (void)destroy;
@end
