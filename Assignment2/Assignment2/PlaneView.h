//
//  PlaneView.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-02.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Plane.h"

@interface PlaneView : NSObject

@property (nonatomic) GLuint vertexArray;
@property (nonatomic) GLuint vertexBuffer;

@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

/// The integer identifying the texture with which the plane view was constructed
@property (readonly, nonatomic) GLuint texture;

/// The plane object which this planeView renders
@property (readonly, nonatomic) Plane* plane;

-(instancetype) initWithPlane: (Plane*) plane andTexture: (GLuint)texture;

/**
 * @brief Updates the normal and model-view matrices.
 * @param projection The perspective matrix.
 * @param cameraBase The matrix defining camera's rotation and position.
 */
- (void)updateMatricesWithView: (GLKMatrix4)view;

@end
