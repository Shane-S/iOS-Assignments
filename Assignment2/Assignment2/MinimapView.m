//
//  MinimapView.m
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-06.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "MinimapView.h"
#import "GLProgramUtils.h"
#import "PlaneView.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

enum
{
    UNIFORM_COLOUR,
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_Z_INDEX,
    NUM_UNIFORMS
};

static GLuint uniforms[NUM_UNIFORMS];

@interface MinimapView()
{
    GLuint _shader;

    GLKVector4 _lineColour;
    GLKVector4 _floorColour;
    
    GLfloat *_vertices;
    GLuint _buffer;
    GLuint _array;
}

@end

@implementation MinimapView

-(instancetype) initWithMaze: (MazeWrapper*) maze andWalls: (NSMutableArray *)mazeWalls andCube: (CubeView *)cubeView
{
    if((self = [super init]))
    {
        _maze = maze;
        _mazeWalls = mazeWalls;
        _cubeView = cubeView;
        
        NSString* vert = [[NSBundle mainBundle] pathForResource:@"MinimapShader" ofType:@"vsh"];
        NSString* frag = [[NSBundle mainBundle] pathForResource:@"MinimapShader" ofType:@"fsh"];
        ShaderAttribute attrs[] =
        {
            {GLKVertexAttribPosition, "position"},
        };
        
        if([GLProgramUtils makeProgram:&_shader withVertShader:vert andFragShader:frag andAttributes:attrs withNumberOfAttributes:1])
            return nil;
        
        uniforms[UNIFORM_COLOUR] = glGetUniformLocation(_shader, "colour");
        uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_shader, "modelViewProjection");
        uniforms[UNIFORM_Z_INDEX] = glGetUniformLocation(_shader, "zIndex");
        
        _floorColour = GLKVector4Make(0.3f, 0.3f, 0.3f, 1);
        _lineColour = GLKVector4Make(0, 0.3f, 0.8f, 1);
        
        _percentOfScreen = 0.75f;
    }
    
    return self;
}

-(void)drawWithAspectRatio: (float)ratio
{
    float scaleFactor = (_maze.numRows / (_maze.numRows - 1)) * (2.0 * _percentOfScreen / _maze.numRows);
    GLKVector2 translations = GLKVector2Make((-_maze.numRows / 2.0) + 0.5, (_maze.numRows / 2.0) - 0.5);
    GLKMatrix4 rotationMatrix;
    GLKMatrix4 scaleMatrix;
    GLKMatrix4 translationMatrix;
    GLKMatrix4 mvp;
    
    // We need this to fit within the screen, so whichever dimension is smaller should be treated as the "unit size", and the larger one
    // must be scaled down so that their unit sizes are equal
    GLKVector3 scales = GLKVector3Make(ratio < 1.0f ? scaleFactor : scaleFactor / ratio, ratio < 1.0f ? scaleFactor * ratio : scaleFactor, scaleFactor);
    rotationMatrix = GLKMatrix4MakeXRotation(M_PI / 2);
    
    glUseProgram(_shader);
    for(PlaneView* planeView in _mazeWalls)
    {
        Plane* plane = planeView.plane;
        // Rotate by 90 degrees clockwise about x (i.e., rotate the world 90 degrees ccw), scale everything down to fit on the screen, and multiply by appropriate aspect ratio values
        // Note that z will be zeroed in the shader, so it doesn't really matter what happens to it here
        scaleMatrix = GLKMatrix4MakeScale(scales.x, scales.y, scales.z);
        translationMatrix = GLKMatrix4MakeTranslation((plane.position.x + translations.x) * scales.x,
                                                      (-plane.position.z + translations.y) * scales.y,
                                                      plane.position.z * scales.z);
        
        mvp = GLKMatrix4Multiply(translationMatrix, GLKMatrix4Multiply(scaleMatrix, rotationMatrix));
        
        glBindVertexArrayOES(planeView.vertexArray);
        
        // Concatenate our hacked-up model view projection matrix :)
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, mvp.m);
        if(plane.type == FLOOR)
        {
            glUniform1f(uniforms[UNIFORM_Z_INDEX], 0.1);
            glUniform4fv(uniforms[UNIFORM_COLOUR], 1, GLKVector4Make(1, 1, 1, 0.5f).v);
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
        else
        {
            glUniform1f(uniforms[UNIFORM_Z_INDEX], 0.0f);
            glUniform4fv(uniforms[UNIFORM_COLOUR], 1, GLKVector4Make(0, 0, 1, 0.5f).v);
            glDrawArrays(GL_LINE_LOOP, 0, 3);
        }
    }
    
    // Draw the cube
    // Concatenate the cube's rotation with our rotation about x
    rotationMatrix = GLKMatrix4Multiply(GLKMatrix4MakeZRotation(-_cubeView.cube.rotation.y), GLKMatrix4MakeXRotation(-_cubeView.cube.rotation.x + (M_PI / 2)));
    rotationMatrix = GLKMatrix4Multiply(rotationMatrix, GLKMatrix4MakeYRotation(-_cubeView.cube.rotation.z));
    
    // Concatenate the cube's scale with our scale factor
    scaleMatrix = GLKMatrix4MakeScale(_cubeView.cube.scale.x * scales.x, _cubeView.cube.scale.y * scales.y, _cubeView.cube.scale.z * scales.z);
    
    // Move the cube to the appropriate position
    translationMatrix = GLKMatrix4MakeTranslation((_cubeView.cube.position.x + translations.x) * scales.x,
                                                  (-_cubeView.cube.position.z + translations.y) * scales.y,
                                                  _cubeView.cube.position.z * scales.z);
    
    glBindVertexArrayOES(_cubeView.vertexArray);
    
    glUniform4fv(uniforms[UNIFORM_COLOUR], 1, GLKVector4Make(1, 0, 0, 1).v);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, GLKMatrix4Multiply(translationMatrix, GLKMatrix4Multiply(scaleMatrix, rotationMatrix)).m);
    for(int i = 0; i < 72; i += 3)
    {
        glDrawArrays(GL_LINE_LOOP, i, 3);
    }
}

@end
