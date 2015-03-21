//
//  AIEntityView.m
//  Assignment3
//
//  Created by Shane Spoor on 2015-03-20.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import "AIEntityView.h"
#import "ShaderAttribute.h"

@implementation AIEntityView

- (void)updateMatricesWithView: (GLKMatrix4)view
{
    // Create the Scale Rotate Translate matrix
    _modelMatrix = GLKMatrix4MakeScale(_entity.scale.x, _entity.scale.y, _entity.scale.z);
    _modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeXRotation(_entity.rotation.x), _modelMatrix);
    _modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeYRotation(_entity.rotation.y), _modelMatrix);
    _modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeZRotation(_entity.rotation.z), _modelMatrix);
    _modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(_entity.position.x, _entity.position.y - 0.5f, _entity.position.z), _modelMatrix);
    
    // Concatenate the view and model matrices together
    _modelViewMatrix = GLKMatrix4Multiply(view, _modelMatrix);
}

- (instancetype) initWithEntity: (AIEntity *)entity andTexture: (GLuint)texture andMesh: (FbxMesh*) mesh
{
    if((self = [super init]))
    {
        _texture = texture;
        _entity = entity;
        _mesh = mesh;
        
        _numIndices = mesh->GetPolygonVertexCount();
        
        // Get the vertices and load them into their buffer
        float* vertices = new float[mesh->GetControlPointsCount() * 3];
        int vertexCount = mesh->GetControlPointsCount();
        FbxVector4* points = mesh->GetControlPoints();
        
        for(int i = 0; i < vertexCount; i++)
        {
            double* controlPointBuffer = points[i].Buffer();
            
            vertices[(i * 3) + 0] = (float)controlPointBuffer[0];
            vertices[(i * 3) + 1] = (float)controlPointBuffer[1];
            vertices[(i * 3) + 2] = (float)controlPointBuffer[2];
        }
        
        // Assume that polygons are all triangles, because they are (3 vertices per polygon * 5 floats per vertex = 15)
        int numPolygons = mesh->GetPolygonCount();
        float* verts = new float[numPolygons * 15];
        FbxLayerElementArrayTemplate<FbxVector2> uvActuals = mesh->GetElementUV()->GetDirectArray();
        int* vertexIndices = mesh->GetPolygonVertices();
        
        // We also assume here that the texture coordinates are mapped using eIndexToDirect
        for(int i = 0; i < numPolygons; i++)
        {
            int uvIndex1 = mesh->GetTextureUVIndex(i, 0);
            int uvIndex2 = mesh->GetTextureUVIndex(i, 1);
            int uvIndex3 = mesh->GetTextureUVIndex(i, 2);
            
            double* uv1 = uvActuals.GetAt(uvIndex1).Buffer();
            double* uv2 = uvActuals.GetAt(uvIndex2).Buffer();
            double* uv3 = uvActuals.GetAt(uvIndex3).Buffer();
            
            double* vert1 = points[vertexIndices[(i * 3) + 0]].Buffer();
            double* vert2 = points[vertexIndices[(i * 3) + 1]].Buffer();
            double* vert3 = points[vertexIndices[(i * 3) + 2]].Buffer();
            
            verts[(i * 15) + 0] = (float)vert1[0];
            verts[(i * 15) + 1] = (float)vert1[1];
            verts[(i * 15) + 2] = (float)vert1[2];
            verts[(i * 15) + 3] = (float)uv1[0];
            verts[(i * 15) + 4] = -(float)uv1[1];
            
            verts[(i * 15) + 5] = (float)vert2[0];
            verts[(i * 15) + 6] = (float)vert2[1];
            verts[(i * 15) + 7] = (float)vert2[2];
            verts[(i * 15) + 8] = (float)uv2[0];
            verts[(i * 15) + 9] = -(float)uv2[1];
            
            verts[(i * 15) + 10] = (float)vert3[0];
            verts[(i * 15) + 11] = (float)vert3[1];
            verts[(i * 15) + 12] = (float)vert3[2];
            verts[(i * 15) + 13] = (float)uv3[0];
            verts[(i * 15) + 14] = -(float)uv3[1];
        }
        
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 5 * mesh->GetPolygonVertexCount(), verts, GL_STATIC_DRAW);
        
        // Tell OpenGL to set the format for the vertex buffer in the vertex array
        glEnableVertexAttribArray(SHADER_ATTR_POSITION);
        glVertexAttribPointer(SHADER_ATTR_POSITION, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (char*)0);
        
        // Enable the texture coordinates and specify their format
        glEnableVertexAttribArray(SHADER_ATTR_TEXCOORD0);
        glVertexAttribPointer(SHADER_ATTR_TEXCOORD0, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (char*)(3 * sizeof(float)));
        
        glBindVertexArrayOES(0);
        
        // Don't want to go leaking everywhere
        delete[] vertices;
        delete[] verts;
    }
    
    return self;
}

- (void)destroy
{
    glDeleteBuffers(1, &(_vertexBuffer));
    glDeleteVertexArraysOES(1, &(_vertexArray));
    glDeleteTextures(1, &(_texture));
}

@end
