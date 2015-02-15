//
//  CubeView.m
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-11.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "CubeView.h"
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface CubeView()

@property (strong, nonatomic) Cube* cube;

@end

@implementation CubeView

- (instancetype)initWithCube: (Cube*) cube {
    
    self = [super init];
    
    if(self) {
        
        // Create a vertex array, which will specify the format of the vertices in the vertex buffer, and tell OpenGL to use it as the current vertex array
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        // Create a buffer, tell OpenGL to set it as the active buffer (with glBindBuffer), and set the buffer's data to the cube's vertices
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, cube.vertexArraySize, cube.vertexData, GL_STATIC_DRAW);
        
        // Tell OpenGL to set the format for the vertex buffer in the vertex array
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
        
        // Break the bindings (not strictly necessary since this would be done automatically on drawing next)
        glBindVertexArrayOES(0);
        //glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        _cube = cube;
    }
    
    return self;
}

-(void) updateMatricesWithProjection: (GLKMatrix4 *)projection andCameraBase: (GLKMatrix4 *)cameraBase {
    
    // Perform model rotation & scaling
    _modelViewMatrix = GLKMatrix4MakeTranslation(_cube.position.x, _cube.position.y, _cube.position.z);
    _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, _cube.rotation.x, 1.0f, 0.0f, 0.0f);
    _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, _cube.rotation.y, 0.0f, 1.0f, 0.0f);
    _modelViewMatrix = GLKMatrix4Multiply(_modelViewMatrix, GLKMatrix4MakeScale(_cube.scale.x, _cube.scale.y, _cube.scale.z));
    
    _modelViewMatrix = GLKMatrix4Multiply(*cameraBase, _modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(*projection, _modelViewMatrix);
}


-(void) destroy {
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
}
@end
