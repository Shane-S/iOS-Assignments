//
//  AIEntityView.h
//  Assignment3
//
//  Created by Shane Spoor on 2015-03-20.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <fbxsdk.h>
#import "AIEntity.h"

@interface AIEntityView : NSObject

/// Reference to the vertices of the cube
@property (nonatomic) GLuint vertexArray;
@property (nonatomic) GLuint vertexBuffer;

@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

@property (strong, nonatomic) AIEntity* entity;

/// The integer identifying the texture with which the plane view was constructed
@property (readonly, nonatomic) GLuint texture;

/// The mesh to display this entity
@property (readonly, nonatomic) FbxMesh* mesh;

/// The number of triangles in this mesh
@property (readonly, nonatomic) int numIndices;

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
- (instancetype) initWithEntity: (AIEntity *)cube andTexture: (GLuint)texture andMesh: (FbxMesh*) mesh;

/**
 * @brief Tells the cube view to free any resources it is holding.
 */
- (void)destroy;

@end
