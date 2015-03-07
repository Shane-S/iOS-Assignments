//
//  CubeView.m
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-11.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "CubeView.h"
#import "GLProgramUtils.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
@implementation CubeView

- (instancetype)initWithCube: (Cube*) cube andTexture:(GLuint)texture
{
    
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
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), BUFFER_OFFSET(3 * sizeof(float)));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), BUFFER_OFFSET(6 * sizeof(float)));
        
        // Break the bindings (not strictly necessary since this would be done automatically on drawing next)
        glBindVertexArrayOES(0);
        _cube = cube;
        _texture = texture;
    }
    
    return self;
}

-(void) updateMatricesWithView: (GLKMatrix4)view {
    
    // Perform model rotation & scaling
    _modelMatrix = GLKMatrix4Identity;
    _modelMatrix = GLKMatrix4RotateX(_modelMatrix, _cube.rotation.x);
    _modelMatrix = GLKMatrix4RotateY(_modelMatrix, _cube.rotation.y);
    _modelMatrix = GLKMatrix4Multiply(_modelMatrix, GLKMatrix4MakeScale(_cube.scale.x, _cube.scale.y, _cube.scale.z));
    _modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(_cube.position.x, _cube.position.y, _cube.position.z), _modelMatrix);
    
    _modelViewMatrix = GLKMatrix4Multiply(view, _modelMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), NULL);
}


-(void) destroy {
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
}
@end
