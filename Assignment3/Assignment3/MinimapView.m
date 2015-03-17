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
    // Scale the maze so that it takes up _percentOfScreen * 2 (OpenGL goes from -1 to 1, so need to fit within 2).
    // _maze.numRows / (_maze.numRows - 1) is making the assumption that our maze is a square. If this is not the case, then we're screwed since
    // I arrived at this equation at around 5 AM and no longer remember why it is the way it is (in particular, why I divide by _mazeRows - 1;
    // it was something to do with the number of steps in between the numbers vs the actual number of rows).
    float scaleFactor = (_maze.numRows / (_maze.numRows - 1)) * (2.0 * _percentOfScreen / _maze.numRows);
    
    // Translate the maze about its centre, moving up and 0.5 down so that it starts at 0 offset by half of the height, and do the same with z.
    // Note that this equation relies on equal widths/heights for the maze, and I'm pretty sure that it also relies on the scale of the planes.
    GLKVector2 translations = GLKVector2Make((-_maze.numRows / 2.0) + 0.5, (_maze.numRows / 2.0) - 0.5);
    
    // Scale our maze according to the current orientation of the screen. If y > x, then we want to multiply y by the aspect ratio. Conversely, if x > y,
    // then we must divide x by the aspect ratio. We treat the smaller component of the aspect ratio as "unit length", and scale the larger one down.
    GLKVector3 scales = GLKVector3Make(ratio < 1.0f ? scaleFactor : scaleFactor / ratio, ratio < 1.0f ? scaleFactor * ratio : scaleFactor, scaleFactor);
    
    GLKMatrix4 mvp;
    
    // Make a view matrix that rotates the world to face z, scales everything to fit on the screen, and translates the map so that its centre is centred in the screen.
    GLKMatrix4 view = GLKMatrix4MakeXRotation(M_PI / 2);
    view = GLKMatrix4Multiply(GLKMatrix4MakeScale(scales.x, scales.y, scales.z), view);
    view = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(translations.x * scales.x, translations.y * scales.y, 0), view);
    
    glUseProgram(_shader);
    for(PlaneView* planeView in _mazeWalls)
    {
        Plane* plane = planeView.plane;
        mvp = GLKMatrix4Multiply(view, planeView.modelMatrix);
        
        // zIndex should be <= 0.1 (the near clipping plane). It allows things to be properly layered on-screen.
        glBindVertexArrayOES(planeView.vertexArray);
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
    
    glBindVertexArrayOES(_cubeView.vertexArray);
    glUniform4fv(uniforms[UNIFORM_COLOUR], 1, GLKVector4Make(1, 0, 0, 1).v);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, GLKMatrix4Multiply(view, _cubeView.modelMatrix).m);
    for(int i = 0; i < 72; i += 3)
    {
        // To draw the triangles as lines, we have to go through the array and draw each set of lines as a line loop. This is a lot
        // of draw calls, however, so I might switch back to triangles later.
        glDrawArrays(GL_LINE_LOOP, i, 3);
    }
}

@end
