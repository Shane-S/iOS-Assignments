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
    CGPoint _moveStart;

    BOOL _isRotatingContinuous;
    
    NSTimeInterval _prevRotationTime;
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

- (IBAction)resetScene:(id)sender {
    _rotatorCube.rotation = GLKVector3Make(0, 0, 0);
    _rotatorCube.scale = GLKVector3Make(1, 1, 1);
    _rotatorCube.position = GLKVector3Make(0, 0, 0);
    _isRotatingContinuous = FALSE;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    // Set the cube's properties
    _rotatorCube = [[Cube alloc] init];
    _rotatorCube.position = GLKVector3Make(0, 0, 0);
    _rotatorCube.rotation = GLKVector3Make(0, 0, 0);
    _rotatorCube.scale = GLKVector3Make(1, 1, 1);
    
    // Create the cube view with its cube
    _cubeView = [[CubeView alloc] initWithCube: _rotatorCube];
    
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
    
    [self clampCube];
    [_cubeView updateMatricesWithProjection: &projectionMatrix andCameraBase: &baseModelViewMatrix];
}

- (void)clampCube {
    if(_rotatorCube.rotation.x > M_PI * 2) [_rotatorCube rotationRef]->x = (2 * M_PI) - _rotatorCube.rotation.x;
    else if(_rotatorCube.rotation.x < 0) [_rotatorCube rotationRef]->x = _rotatorCube.rotation.x + (2 * M_PI);
    
    if(_rotatorCube.rotation.y > M_PI * 2) [_rotatorCube rotationRef]->y = (2 * M_PI) - _rotatorCube.rotation.y;
    else if(_rotatorCube.rotation.y < 0) [_rotatorCube rotationRef]->y = _rotatorCube.rotation.y + (2 * M_PI);
}

- (void)updateContinuousRotation {
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
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
    
    // Specify the mapping of the shader variables to their respective attribute indices
    ShaderAttribute shaderAttrs[] = {
        {GLKVertexAttribPosition, "position"},
        {GLKVertexAttribNormal, "normal"}
    };
    
    // Try to create the program
    if([GLProgramUtils makeProgram:&_program withVertShader:vertPath andFragShader:fragPath andAttributes:shaderAttrs withNumberOfAttributes:sizeof(shaderAttrs) / sizeof(ShaderAttribute)]) {
        return NO;
    }
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    return YES;
}

@end
