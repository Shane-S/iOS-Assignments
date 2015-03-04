//
//  GameViewController.m
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "GameViewController.h"
#import "GLProgramUtils.h"
#import "Camera.h"
#import "MazeWrapper.h"
#import "PlaneView.h"
#import <OpenGLES/ES2/glext.h>

/// The RPM of the spinning cube
const int REVOLUTIONS_PER_MINUTE = 5;

/// Specifies the amount by which the camera will rotate about the y-axis
/// (i.e. by how much the Look At point will change) on scrolling one screen unit in the
/// x-axis
const float CAMERA_ROTATE_FACTOR = 0.01f;

const float CAMERA_MOVE_FACTOR = 0.03f;

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

@interface GameViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    Cube* _rotatorCube;
    CubeView *_cubeView;
    CGPoint _dragStart;
    NSTimeInterval _prevRotationTime;
    
    Camera* _camera;
    
    NSMutableArray* _walls;
    
    MazeWrapper* maze;
}
@property (strong, nonatomic) EAGLContext *context;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTap;

/**
 * @brief Creates the GL context for rendering and initialises the CubeView.
 */
- (void)setupGL;

/**
 * @brief Destroys the rendering context and disposes of the cube.
 */
- (void)tearDownGL;

/**
 * @brief Loads the shaders for rendering, creates a program a program object and stores it in _program.
 */
- (BOOL)loadShaders;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    _prevRotationTime = 0;
    
    
    float aspect = (float)self.view.bounds.size.width / self.view.bounds.size.height;
    _camera = [[Camera alloc] initWithPosition:GLKVector3Make(0, 0, 0.0f)  andRotation:0
                           andProjectionMatrix:GLKMatrix4MakePerspective(DEFAULT_FOV * (360 / M_PI * 2), aspect, DEFAULT_NEARPLANE, DEFAULT_FARPLANE)];
    
    maze = [[MazeWrapper alloc] init];
    
    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)onPan:(UIPanGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        _dragStart = [sender locationInView:self.view];
    }
    CGPoint cur = [sender locationInView:self.view];
    GLKVector2 d = GLKVector2Make(cur.x - _dragStart.x, _dragStart.y - cur.y);
    _camera.rotation -= d.x * CAMERA_ROTATE_FACTOR;
    
    GLKVector3 movement = GLKVector3MultiplyScalar(_camera.lookAtVector, d.y * CAMERA_MOVE_FACTOR);
    _camera.position = (GLKVector3Add(_camera.position, movement));
    _dragStart = cur;
}

- (IBAction)resetScene:(id)sender {
    _rotatorCube.rotation = GLKVector3Make(0, 0, 0);
    _rotatorCube.scale = GLKVector3Make(1, 1, 1);
    _rotatorCube.position = GLKVector3Make(0, 0, 0);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // Set the cube's properties
    _rotatorCube = [[Cube alloc] initWithScale: GLKVector3Make(0.3f, 0.3f, 0.3f) andRotation: GLKVector3Make(0, 0, 0) andPosition: GLKVector3Make(0, 0, 0)];
    
    // Create the cube view with its cube
    _cubeView = [[CubeView alloc] initWithCube: _rotatorCube andTexture:[GLProgramUtils setupTexture:@"crate.jpg"]];
    
    [self setupMaze];
    
    glActiveTexture(GL_TEXTURE0);
    
}

-(void) setupMaze
{
    GLuint floorTexture = [GLProgramUtils setupTexture:@"floor.jpg"];
    GLuint noWallsTexture = [GLProgramUtils setupTexture:@"no_walls.jpg"];
    GLuint leftWallTexture = [GLProgramUtils setupTexture:@"left_wall.jpg"];
    GLuint rightWallTexture = [GLProgramUtils setupTexture:@"right_wall.jpg"];
    GLuint bothWallsTexture = [GLProgramUtils setupTexture:@"both_walls.jpg"];
    
    _walls = [[NSMutableArray alloc] init];
    MazeCell cell;
    
    // Create the walls and floor
    for(int row = 0; row < maze.numRows; row++)
    {
        for(int col = 0; col < maze.numCols; col++)
        {
            // Create the floor for this tile
            Plane* floorPlane = [[Plane alloc] initWithPosition: GLKVector3Make(col * MAZE_CELL_WIDTH, -1, -row * MAZE_CELL_WIDTH) andScale:1 andPlaneType:FLOOR];
            PlaneView* floorView = [[PlaneView alloc] initWithPlane:floorPlane andTexture:floorTexture];
            [_walls addObject:floorView];
            
            // Determine the walls and add them
            [maze getCellAtRow:row andCol:col storeIn:&cell];
            
            if(cell.northWallPresent)
            {
                PlaneType wallType = NORTH_WALL;
                const GLKVector3* ref = &(planePositions[wallType]);
                Plane* northPlane = [[Plane alloc] initWithPosition: GLKVector3Make(col * MAZE_CELL_WIDTH + ref->x, 0, -row * MAZE_CELL_WIDTH + ref->z) andScale:1 andPlaneType:wallType];
                
                GLuint texture;
                if(cell.eastWallPresent && cell.westWallPresent) texture = bothWallsTexture;
                else if(cell.eastWallPresent) texture = rightWallTexture;
                else if(cell.westWallPresent) texture = leftWallTexture;
                else texture = noWallsTexture;
                
                PlaneView* northView = [[PlaneView alloc] initWithPlane: northPlane andTexture:texture];
                [_walls addObject: northView];
            }
            /*if(cell.southWallPresent)
            {
                PlaneType wallType = SOUTH_WALL;
                const GLKVector3* ref = &(planePositions[wallType]);
                Plane* southPlane = [[Plane alloc] initWithPosition: GLKVector3Make(col * MAZE_CELL_WIDTH + ref->x, 0, -row * MAZE_CELL_WIDTH + ref->z) andScale:1 andPlaneType:wallType];
                
                GLuint texture;
                if(cell.eastWallPresent && cell.westWallPresent) texture = bothWallsTexture;
                else if(cell.eastWallPresent) texture = rightWallTexture;
                else if(cell.westWallPresent) texture = leftWallTexture;
                else texture = noWallsTexture;
                
                PlaneView* southView = [[PlaneView alloc] initWithPlane: southPlane andTexture:texture];
                [_walls addObject: southView];
            }
            if(cell.westWallPresent)
            {
                PlaneType wallType = WEST_WALL;
                const GLKVector3* ref = &(planePositions[wallType]);
                Plane* westPlane = [[Plane alloc] initWithPosition: GLKVector3Make(col * MAZE_CELL_WIDTH + ref->x, 0, -row * MAZE_CELL_WIDTH + ref->z) andScale:1 andPlaneType:wallType];
                
                GLuint texture;
                if(cell.eastWallPresent && cell.westWallPresent) texture = bothWallsTexture;
                else if(cell.eastWallPresent) texture = rightWallTexture;
                else if(cell.westWallPresent) texture = leftWallTexture;
                else texture = noWallsTexture;
                
                PlaneView* westView = [[PlaneView alloc] initWithPlane: westPlane andTexture:texture];
                [_walls addObject: westView];
            }
            if(cell.eastWallPresent)
            {
                PlaneType wallType = EAST_WALL;
                const GLKVector3* ref = &(planePositions[wallType]);
                Plane* eastPlane = [[Plane alloc] initWithPosition: GLKVector3Make(col * MAZE_CELL_WIDTH + ref->x, 0, -row * MAZE_CELL_WIDTH + ref->z) andScale:1 andPlaneType:wallType];
                
                GLuint texture;
                if(cell.eastWallPresent && cell.westWallPresent) texture = bothWallsTexture;
                else if(cell.eastWallPresent) texture = rightWallTexture;
                else if(cell.westWallPresent) texture = leftWallTexture;
                else texture = noWallsTexture;
                
                PlaneView* eastView = [[PlaneView alloc] initWithPlane: eastPlane andTexture:texture];
                [_walls addObject: eastView];
            }*/
        }
    }
}

-(GLuint)textureForCell: (MazeCell*) cell withDirection: (Direction)dir bothWalls: (GLuint)both rightWall: (GLuint)right leftWall: (GLuint)left noWalls: (GLuint)none
{
    switch(dir)
    {
        case dirNORTH:
        {
            if(cell->eastWallPresent && cell->westWallPresent) return both;
            else if(cell->westWallPresent) return right;
            else if(cell->eastWallPresent) return left;
            else return none;
        }
        case dirSOUTH:
        {
            if(cell->eastWallPresent && cell->westWallPresent) return both;
            else if(cell->eastWallPresent) return right;
            else if(cell->westWallPresent) return left;
            else return none;
        }
        case dirWEST:
        {
            if(cell->northWallPresent && cell->southWallPresent) return both;
            else if(cell->southWallPresent) return right;
            else if(cell->northWallPresent) return left;
            else return none;
        }
        case dirEAST:
        {
            if(cell->northWallPresent && cell->southWallPresent) return both;
            else if(cell->northWallPresent) return right;
            else if(cell->southWallPresent) return left;
            else return none;
        }
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    [_cubeView destroy];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{   
    [_camera updateMatricesWithScreenWidth:self.view.bounds.size.width andScreenHeight:self.view.bounds.size.height andFieldOfView:DEFAULT_FOV];

    [self updateContinuousRotation];
    [self clampCube];
    
    [_cubeView updateMatricesWithView: _camera.view];
    for(PlaneView* planeView in _walls) [planeView updateMatricesWithView: _camera.view];
}

- (void)clampCube {
    if(_rotatorCube.rotation.x > M_PI * 2) [_rotatorCube rotationRef]->x = (2 * M_PI) - _rotatorCube.rotation.x;
    else if(_rotatorCube.rotation.x < 0) [_rotatorCube rotationRef]->x = _rotatorCube.rotation.x + (2 * M_PI);
    
    if(_rotatorCube.rotation.y > M_PI * 2) [_rotatorCube rotationRef]->y = (2 * M_PI) - _rotatorCube.rotation.y;
    else if(_rotatorCube.rotation.y < 0) [_rotatorCube rotationRef]->y = _rotatorCube.rotation.y + (2 * M_PI);
}

- (void)updateContinuousRotation {
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    if(!_prevRotationTime) _prevRotationTime = [NSDate timeIntervalSinceReferenceDate];
    double timeDelta = currentTime - _prevRotationTime;
    double angleDelta = timeDelta * REVOLUTIONS_PER_MINUTE / 60 * 2 * M_PI; // s * rev/min * min/60s * 2PI/rev
    
    [_rotatorCube rotationRef]->y += angleDelta;
    _prevRotationTime = currentTime;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear the scene
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Use the program we compiled earlier
    glUseProgram(_program);
    
    [self drawCube];
    [self drawMaze];
}

-(void)drawCube
{
    glBindVertexArrayOES(_cubeView.vertexArray);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, GLKMatrix4Multiply(_camera.projection, _cubeView.modelViewMatrix).m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _cubeView.normalMatrix.m);
    
    glBindTexture(GL_TEXTURE_2D, _cubeView.texture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

-(void)drawMaze
{
    for(PlaneView* planeView in _walls)
    {
        glBindVertexArrayOES(planeView.vertexArray);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, GLKMatrix4Multiply(_camera.projection, planeView.modelViewMatrix).m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, planeView.normalMatrix.m);
        
        glBindTexture(GL_TEXTURE_2D, planeView.texture);
        glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
        
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    NSString *vertPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString *fragPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    
    // Specify the mapping of the shader variables to their respective attribute indices
    ShaderAttribute shaderAttrs[] = {
        {GLKVertexAttribPosition, "position"},
        {GLKVertexAttribNormal, "normal"},
        {GLKVertexAttribTexCoord0, "texCoordIn"}
    };
    
    // Try to create the program
    if([GLProgramUtils makeProgram:&_program withVertShader:vertPath andFragShader:fragPath andAttributes:shaderAttrs withNumberOfAttributes:sizeof(shaderAttrs) / sizeof(ShaderAttribute)]) {
        return NO;
    }
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    
    glActiveTexture(GL_TEXTURE0);
    return YES;
}

@end
