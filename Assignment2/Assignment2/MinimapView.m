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
    UNIFORM_MAZE_INDICES,
    UNIFORM_ASPECT_RATIO,
    UNIFORM_SCALE_FACTOR,
    UNIFORM_TRANSLATION,
    UNIFORM_ISINPORTRAIT,
    UNIFORM_MODEL_MATRIX,
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
        uniforms[UNIFORM_MAZE_INDICES] = glGetUniformLocation(_shader, "mazeIndices");
        uniforms[UNIFORM_ASPECT_RATIO] = glGetUniformLocation(_shader, "aspectRatio");
        uniforms[UNIFORM_SCALE_FACTOR] = glGetUniformLocation(_shader, "scaleFactor");
        uniforms[UNIFORM_TRANSLATION] = glGetUniformLocation(_shader, "translation");
        uniforms[UNIFORM_ISINPORTRAIT] = glGetUniformLocation(_shader, "isInPortrait");
        uniforms[UNIFORM_ISINPORTRAIT] = glGetUniformLocation(_shader, "isInPortrait");
        
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
    GLKVector2 mazeIndices = {0, 0};
    
    glUseProgram(_shader);
    glUniform1f(uniforms[UNIFORM_ASPECT_RATIO], ratio);
    glUniform1f(uniforms[UNIFORM_SCALE_FACTOR], scaleFactor);
    glUniform2fv(uniforms[UNIFORM_TRANSLATION], 1, translations.v);
    glUniform1i(uniforms[UNIFORM_ISINPORTRAIT], ratio < 1.0f);
    
    for(PlaneView* planeView in _mazeWalls)
    {
        mazeIndices.x = floor(planeView.plane.position.x);
        mazeIndices.y = -floor(planeView.plane.position.z);
       
        glBindVertexArrayOES(planeView.vertexArray);
        glUniform2fv(uniforms[UNIFORM_MAZE_INDICES], 1, mazeIndices.v);
        
        if(planeView.plane.type == FLOOR)
        {
            glUniform4fv(uniforms[UNIFORM_COLOUR], 1, GLKVector4Make(1, 1, 1, 1).v);
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
        else
        {
            glUniform4fv(uniforms[UNIFORM_COLOUR], 1, GLKVector4Make(0, 0, 1, 1).v);
            glDrawArrays(GL_LINE_LOOP, 0, 6);
        }
    }
}

@end
