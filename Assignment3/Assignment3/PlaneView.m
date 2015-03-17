//
//  PlaneView.m
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-02.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "PlaneView.h"
#import "GLProgramUtils.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation PlaneView

-(instancetype) initWithPlane: (Plane*) plane andTexture: (GLuint)texture
{
    if((self = [super init]))
    {
        _plane = plane;
        
        // Create a vertex array, which will specify the format of the vertices in the vertex buffer, and tell OpenGL to use it as the current vertex array
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        // Create a buffer, tell OpenGL to set it as the active buffer (with glBindBuffer), and set the buffer's data to the cube's vertices
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, plane.verticesSize, plane.vertices, GL_STATIC_DRAW);
        
        // Tell OpenGL to set the format for the vertex buffer in the vertex array
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), BUFFER_OFFSET(3 * sizeof(float)));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), BUFFER_OFFSET(6 * sizeof(float)));
        
        // Break the bindings (not strictly necessary since this would be done automatically on drawing next)
        glBindVertexArrayOES(0);
        
        _texture = texture;
    }
    
    return self;
}

-(void) updateMatricesWithView: (GLKMatrix4)view {
    
    // Perform model translation & scaling
    _modelMatrix = GLKMatrix4Identity;
    _modelMatrix = GLKMatrix4Multiply(_modelMatrix, GLKMatrix4MakeScale(_plane.scale, _plane.scale, _plane.scale));
    _modelMatrix = GLKMatrix4MakeTranslation(_plane.position.x, _plane.position.y, _plane.position.z);
    
    _modelViewMatrix = GLKMatrix4Multiply(view, _modelMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), NULL);
}
@end
