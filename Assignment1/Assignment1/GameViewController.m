//
//  GameViewController.m
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "GameViewController.h"
#import "GLProgramUtils.h"
#import <OpenGLES/ES2/glext.h>

const int REVOLUTIONS_PER_MINUTE = 30;

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};


@interface GameViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    Cube *_cube;
    CubeView *_cubeView;
    CGPoint _dragStart;
    CGPoint _moveStart;
    
    BOOL _isRotating;
    BOOL _isMoving;
    BOOL _isRotatingContinuous;
    
    NSTimeInterval _prevRotationTime;
}
@property (strong, nonatomic) EAGLContext *context;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTap;

@property (strong, nonatomic) Counter *mixedCounter;
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

/**
 * @brief Clamps the cube's scale and rotation.
 */
- (void)clampCube;

/**
 * @brief Moves the cube around the screen.
 * @param recognizer The gesture recognizer that sent the event.
 */
- (void)doMove:(UIPanGestureRecognizer *)recognizer;

/**
 * @brief Rotates the cube about the x and y axes.
 * @param recognizer The gesture recognizer that sent the event.
 */
- (void)doRotate:(UIPanGestureRecognizer *)recognizer;
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
    
    _isMoving = FALSE;
    _isRotating = FALSE;
    _prevRotationTime = 0;
    
    _mixedCounter = [[Counter alloc] init];
    
    // Set up UI recognizer for double tap which can't be properly configured in the interface builder :(
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(toggleContinuousRotation:)];
    _doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:_doubleTap];
    
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

- (IBAction)doScale:(UIPinchGestureRecognizer *)sender {
    
    // Nothing is allowed to happen if the cube is currently rotating
    if(_isRotatingContinuous) return;
    
    // Scale the cube by whatever the delta from last time was
    [_cube scaleRef]->x = _cube.scale.x * sender.scale;
    [_cube scaleRef]->y = _cube.scale.y * sender.scale;
    [_cube scaleRef]->z = _cube.scale.z * sender.scale;
    
    // Reset the scale to 1 so that sender.scale contains only the delta from this scale
    sender.scale = 1;
}

- (IBAction)doPan:(UIPanGestureRecognizer *)recognizer
{
    // Nothing is allowed to happen if the cube is currently rotating
    if(_isRotatingContinuous) return;
    
    // If the pan recognizer registers one touch or is already rotating, rotate; if it's two or already moving, move
    // This should have been done with shouldFireOnlyIfRecognizerFails (or whatever that function is) with another
    // recognizer for two-finger panning, but this already works
    int touches = [recognizer numberOfTouches];
    if((touches == 1 && !_isMoving) || _isRotating) [self doRotate:recognizer];
    else if((touches == 2 &&  !_isRotating) || _isMoving) [self doMove:recognizer];
}

- (void)doRotate:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // Set the initial origin on drag start
        _dragStart = [recognizer locationInView:self.view];
        _isRotating = TRUE;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // Add the rotation delta to the cube's current rotation and set the current point to drag start
        CGPoint newPt = [recognizer locationInView:self.view];
        [_cube rotationRef]->x = _cube.rotation.x + ((newPt.y - _dragStart.y) * M_PI / 180);
        [_cube rotationRef]->y = _cube.rotation.y + ((newPt.x - _dragStart.x) * M_PI / 180);
        _dragStart = newPt;
    }
    else _isRotating = FALSE;
}

- (void)doMove:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        // Set the inital origin when the pan begins
        _moveStart = [recognizer locationInView:self.view];
        _isMoving = TRUE;
    }
    else if (recognizer.state != UIGestureRecognizerStateEnded)
    {
        // Add the rotation delta to the cube's current rotation and set the current point to move start
        CGPoint newPt = [recognizer locationInView:self.view];
        
        [_cube positionRef]->x = _cube.position.x + ((newPt.x - _moveStart.x) / 30);
        [_cube positionRef]->y = _cube.position.y + ((-newPt.y + _moveStart.y) / 30);
        _moveStart = newPt;
    }
    else _isMoving = FALSE;
}

- (IBAction)toggleContinuousRotation:(id)sender {
    // Toggle the rotation on/off and set the start time for the next rotation calculation
    _isRotatingContinuous = _isRotatingContinuous ? FALSE: TRUE;
    if(_isRotatingContinuous) _prevRotationTime = [NSDate timeIntervalSinceReferenceDate];
}

- (IBAction)changeCounter:(id)sender {
    [_mixedCounter incrementCounter];
    [_mixedCounter toggleCounter];
}

- (IBAction)resetScene:(id)sender {
    _cube.rotation = GLKVector3Make(0, 0, 0);
    _cube.scale = GLKVector3Make(1, 1, 1);
    _cube.position = GLKVector3Make(0, 0, 0);
    _isRotatingContinuous = FALSE;
}


- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    // Set the cube's properties
    _cube = [[Cube alloc] init];
    _cube.position = GLKVector3Make(0, 0, 0);
    _cube.rotation = GLKVector3Make(0, 0, 0);
    _cube.scale = GLKVector3Make(1, 1, 1);
    
    // Create the cube view with its cube
    _cubeView = [[CubeView alloc] initWithCube: _cube];
    
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
    // Recalculate the projection matrix based on the screen's current aspect ratio and move the world 4 units along with x-axis
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    
    NSString *cubeInfo = [NSString stringWithFormat:@"Rotation: (%.1f°, %.1f°, %.1f°)\nPosition: (%.2f, %.2f, %.2f)",
                          _cube.rotation.x * 180 / M_PI, _cube.rotation.y * 180 / M_PI, _cube.rotation.z * 180 / M_PI,
                          _cube.position.x, _cube.position.y, _cube.position.z];
    NSString *counterText = [NSString stringWithFormat: @"%@: %d", _mixedCounter.usingObjC ? @"Obj-C" :@"C++", [_mixedCounter getCounterValue]];
    
    if(_isRotatingContinuous) [self updateContinuousRotation];
    
    [self clampCube];
    [_cubeView updateMatricesWithProjection: &projectionMatrix andCameraBase: &baseModelViewMatrix];
    
    [_cubeInfoLabel setText: cubeInfo];
    [_counterValueLabel setText:counterText];
}

- (void)clampCube {
    if(_cube.rotation.x > M_PI * 2) [_cube rotationRef]->x = (2 * M_PI) - _cube.rotation.x;
    else if(_cube.rotation.x < 0) [_cube rotationRef]->x = _cube.rotation.x + (2 * M_PI);
    
    if(_cube.rotation.y > M_PI * 2) [_cube rotationRef]->y = (2 * M_PI) - _cube.rotation.y;
    else if(_cube.rotation.y < 0) [_cube rotationRef]->y = _cube.rotation.y + (2 * M_PI);
    
    if(_cube.scale.x < 0.1f) {
        [_cube scaleRef]->x = 0.1f;
        [_cube scaleRef]->y = 0.1f;
        [_cube scaleRef]->z = 0.1f;
    } else if(_cube.scale.x > 2) {
        [_cube scaleRef]->x = 2;
        [_cube scaleRef]->y = 2;
        [_cube scaleRef]->z = 2;
    }
}

- (void)updateContinuousRotation {
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    double timeDelta = currentTime - _prevRotationTime;
    double angleDelta = timeDelta * REVOLUTIONS_PER_MINUTE / 60 * 2 * M_PI; // s * rev/min * min/60s * 2PI/rev
    [_cube rotationRef]->y += angleDelta;
    _prevRotationTime = currentTime;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear the scene
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Use the program we compiled earlier
    glUseProgram(_program);
    
    glBindVertexArrayOES(_cubeView.vertexArray);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _cubeView.modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _cubeView.normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    NSString *vertPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString *fragPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    int status = 0;
    
    // Try to create the program
    if((status = [GLProgramUtils makeProgram:&_program withVertShader:vertPath andFragShader:fragPath]) != 0) {
        switch(status) {
            case VERT_SHADER_FAIL:
                NSLog(@"Failed to compile vertex shader.");
                break;
            case FRAG_SHADER_FAIL:
                NSLog(@"Failed to compile fragment shader.");
                break;
            case PROGRAM_LINK_FAIL:
                NSLog(@"Failed to link program.");
                break;
        }
        return NO;
    }
        uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
        uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    return YES;
}

@end
