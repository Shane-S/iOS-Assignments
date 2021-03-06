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
#import "Uniforms.h"
#import "FogView.h"
#import "MinimapView.h"
#import <OpenGLES/ES2/glext.h>

/// The RPM of the spinning cube
const int REVOLUTIONS_PER_MINUTE = 10;

/// Specifies the amount by which the camera will rotate about the y-axis
/// (i.e. by how much the Look At point will change) on scrolling one screen unit in the
/// x-axis
const float CAMERA_ROTATE_FACTOR = 0.01f;

/// The amount by which camera movement will be scaled
const float CAMERA_MOVE_FACTOR = 0.03f;

const GLKVector4 DEFAULT_CLEAR_COLOUR = {0.65f, 0.65f, 0.65f, 1.0f};

GLuint uniforms[NUM_UNIFORMS];

// The wall textures for planes
enum
{
    NO_WALLS = 0,
    RIGHT_WALL,
    LEFT_WALL,
    BOTH_WALLS
};

@interface GameViewController () {
    GLuint _program;

    Cube* _rotatorCube;
    CubeView *_cubeView;
    CGPoint _dragStart;
    NSTimeInterval _prevRotationTime;
    
    NSMutableArray* _walls;
    MazeWrapper* maze;

    Camera* _camera;
    FogView* _fogView;
    BOOL _fogOn;
    
    // Light stuff
    bool _lightOn;
    GLKVector4 _lightColour;
    float _lightCosine;
    float _lightIntensity;
    
    GLKVector4 _ambient;
    
    BOOL _mapOn;
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) UITapGestureRecognizer *resetTapRecognizer;
@property (strong, nonatomic) MinimapView* minimap;

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
    _camera = [[Camera alloc] initWithPosition:GLKVector3Make(0, 0, 0.0f)  andRotation:M_PI
                           andProjectionMatrix:GLKMatrix4MakePerspective(DEFAULT_FOV * (360 / M_PI * 2), aspect, DEFAULT_NEARPLANE, DEFAULT_FARPLANE)];
    
    maze = [[MazeWrapper alloc] initWithRows:3 andCols:3];
    
    _ambient = GLKVector4Make(1, 1, 1, 1);
    
    Fog fog;
    fog.density = 0.3f;
    fog.colour = GLKVector4Make(0.5f, 0.5f, 0.5f, 1);
    fog.type = FOG_NONE;
    fog.start = 0.05f;
    fog.end = 7.0f;
    _fogView = [[FogView alloc] initWithFog:fog andUniformArray:uniforms];
    _fogOn = NO;
    
    _lightColour = GLKVector4Make(0.8f, 0.8, 0.8, 1.0f);
    _lightIntensity = 250.0f;
    _lightCosine = cosf(((M_PI * 2)/360) * 10);
    _lightOn = false;
    
    _resetTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetScene:)];
    _resetTapRecognizer.numberOfTapsRequired = 2;
    _resetTapRecognizer.numberOfTouchesRequired = 1;
    
    _mapToggle.numberOfTapsRequired = 2;
    
    _mapOn = NO;
    
    [self.view addGestureRecognizer:_resetTapRecognizer];
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

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glLineWidth(2.0f);
    
    // Set the cube's properties
    _rotatorCube = [[Cube alloc] initWithScale: GLKVector3Make(0.3f, 0.3f, 0.3f) andRotation: GLKVector3Make(0, 0, 0) andPosition: GLKVector3Make(0, 0, 0)];
    
    // Create the cube view with its cube
    _cubeView = [[CubeView alloc] initWithCube: _rotatorCube andTexture:[GLProgramUtils setupTexture:@"crate.jpg"]];
    
    [self setupMaze];
    _minimap = [[MinimapView alloc] initWithMaze: maze andWalls: _walls andCube: _cubeView];
    glActiveTexture(GL_TEXTURE0);
    
}

-(void) setupMaze
{
    GLuint floorTexture = [GLProgramUtils setupTexture:@"floor.jpg"];
    
    GLuint textures[] = {
        [GLProgramUtils setupTexture:@"no_walls.jpg"],
        [GLProgramUtils setupTexture:@"left_wall.jpg"],
        [GLProgramUtils setupTexture:@"right_wall.jpg"],
        [GLProgramUtils setupTexture:@"both_walls.jpg"],
    };
    
    _walls = [[NSMutableArray alloc] init];
    MazeCell cell;
    
    // Create the walls and floor
    for(int row = 0; row < maze.numRows; row++)
    {
        for(int col = 0; col < maze.numCols; col++)
        {
            // Create the floor for this tile
            Plane* floorPlane = [[Plane alloc] initWithPosition: GLKVector3Make(col * MAZE_CELL_WIDTH, -1, row * MAZE_CELL_WIDTH) andScale:1 andPlaneType:FLOOR];
            PlaneView* floorView = [[PlaneView alloc] initWithPlane:floorPlane andTexture:floorTexture];
            [_walls addObject:floorView];
            
            // Determine the walls and add them
            [maze getCellAtRow:row andCol:col storeIn:&cell];
            
            if(cell.northWallPresent) [self makeMazeCell:&cell andPlaneType:NORTH_WALL andCol:col andRow:row andTextures:textures];
            if(cell.southWallPresent) [self makeMazeCell:&cell andPlaneType:SOUTH_WALL andCol:col andRow:row andTextures:textures];
            if(cell.westWallPresent) [self makeMazeCell:&cell andPlaneType:WEST_WALL andCol:col andRow:row andTextures:textures];
            if(cell.eastWallPresent) [self makeMazeCell:&cell andPlaneType:EAST_WALL andCol:col andRow:row andTextures:textures];
        }
    }
}

-(void)makeMazeCell: (MazeCell*) cell andPlaneType: (PlaneType)wallType andCol: (int)col andRow: (int)row andTextures: (GLuint*)textures
{
    const GLKVector3* ref = &(planePositions[wallType]);
    Plane* plane = [[Plane alloc] initWithPosition: GLKVector3Make(col * MAZE_CELL_WIDTH + ref->x, 0, row * MAZE_CELL_WIDTH + ref->z) andScale:1 andPlaneType:wallType];
    
    GLuint texture = [self textureForCell:cell withPlaneType:wallType andTextureList:textures];
    
    PlaneView* planeView = [[PlaneView alloc] initWithPlane: plane andTexture:texture];
    [_walls addObject: planeView];
}

-(GLuint)textureForCell: (MazeCell*) cell withPlaneType: (PlaneType)planeType andTextureList: (GLuint *)textures;
{
    switch(planeType)
    {
        case NORTH_WALL:
        {
            if(cell->eastWallPresent && cell->westWallPresent) return textures[BOTH_WALLS];
            else if(cell->westWallPresent) return textures[RIGHT_WALL];
            else if(cell->eastWallPresent) return textures[LEFT_WALL];
            else return textures[NO_WALLS];
        }
        case SOUTH_WALL:
        {
            if(cell->eastWallPresent && cell->westWallPresent) return textures[BOTH_WALLS];
            else if(cell->eastWallPresent) return textures[RIGHT_WALL];
            else if(cell->westWallPresent) return textures[LEFT_WALL];
            else return textures[NO_WALLS];
        }
        case WEST_WALL:
        {
            if(cell->northWallPresent && cell->southWallPresent) return textures[BOTH_WALLS];
            else if(cell->southWallPresent) return textures[RIGHT_WALL];
            else if(cell->northWallPresent) return textures[LEFT_WALL];
            else return textures[NO_WALLS];
        }
        case EAST_WALL:
        {
            if(cell->northWallPresent && cell->southWallPresent) return textures[BOTH_WALLS];
            else if(cell->northWallPresent) return textures[RIGHT_WALL];
            else if(cell->southWallPresent) return textures[LEFT_WALL];
            else return textures[NO_WALLS];
        }
        case FLOOR:
            NSLog(@"textureForCell: should not have received 'FLOOR' enum");
            return 0;
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

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
    
    [_cubeView updateMatricesWithView: _camera.view];
    for(PlaneView* planeView in _walls) [planeView updateMatricesWithView: _camera.view];
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
    GLKVector3 lightPosition = _camera.position;
    GLKVector4 clearColour = _fogView.fog->type ? _fogView.fog->colour : DEFAULT_CLEAR_COLOUR;
    clearColour = GLKVector4Multiply(clearColour, GLKVector4Make(_ambient.r, _ambient.g, _ambient.b, 1.0f));
    glClearColor(clearColour.r, clearColour.g, clearColour.b, clearColour.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Use the program we compiled earlier
    glUseProgram(_program);
    
    glUniform4fv(uniforms[UNIFORM_AMBIENT], 1, _ambient.v);
    
    // Turn the light on
    glUniform1f(uniforms[UNIFORM_LIGHT_CONE_ANGLE_COSINE], _lightCosine); // 20 degrees converted to radians
    glUniform1f(uniforms[UNIFORM_LIGHT_INTENSITY], _lightOn ? _lightIntensity : 0.0f);
    glUniform3fv(uniforms[UNIFORM_LIGHT_POSITION], 1, lightPosition.v);
    glUniform3fv(uniforms[UNIFORM_LIGHT_DIRECTION], 1, GLKVector3Make(0, 0, 1).v);
    glUniform4fv(uniforms[UNIFORM_LIGHT_COLOUR], 1, _lightColour.v);

    // Use fog
    _fogView.fog->type = _fogOn ? _fogTypeToggle.selectedSegmentIndex + 1: FOG_NONE;
    [_fogView draw];
    
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, false, _camera.projection.m);
    [self drawCube];
    [self drawMaze];
    
    if(_mapOn)
        [_minimap drawWithAspectRatio:self.view.bounds.size.width / self.view.bounds.size.height];
}

-(void)drawCube
{
    glBindVertexArrayOES(_cubeView.vertexArray);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, _cubeView.modelViewMatrix.m);
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
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, planeView.modelViewMatrix.m);
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
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
    uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(_program, "projectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_LIGHT_POSITION] = glGetUniformLocation(_program, "lightPosition");
    uniforms[UNIFORM_LIGHT_DIRECTION] = glGetUniformLocation(_program, "lightDirection");
    uniforms[UNIFORM_LIGHT_INTENSITY] = glGetUniformLocation(_program, "lightIntensity");
    uniforms[UNIFORM_LIGHT_CONE_ANGLE_COSINE] = glGetUniformLocation(_program, "lightConeAngleCosine");
    uniforms[UNIFORM_AMBIENT] = glGetUniformLocation(_program, "ambient");
    uniforms[UNIFORM_LIGHT_COLOUR] = glGetUniformLocation(_program, "lightColour");
    uniforms[UNIFORM_FOG_COLOUR] = glGetUniformLocation(_program, "fogColour");
    uniforms[UNIFORM_FOG_DENSITY] = glGetUniformLocation(_program, "fogDensity");
    uniforms[UNIFORM_FOG_TYPE] = glGetUniformLocation(_program, "fogType");
    uniforms[UNIFORM_FOG_START] = glGetUniformLocation(_program, "fogStart");
    uniforms[UNIFORM_FOG_END] = glGetUniformLocation(_program, "fogEnd");

    //uniforms[UNIFORM_SPECULAR] = glGetUniformLocation(_program, "texture");
    //uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_program, "texture");
    
    glActiveTexture(GL_TEXTURE0);
    return YES;
}

- (IBAction)onAmbientChange:(UIPinchGestureRecognizer *)sender {
    _ambient.r *= sender.scale;
    _ambient.g *= sender.scale;
    _ambient.b *= sender.scale;
    
    _ambient.r = fmaxf(0.2f, fminf(_ambient.r, 1.0f));
    _ambient.g = fmaxf(0.2f, fminf(_ambient.g, 1.0f));
    _ambient.b = fmaxf(0.2f, fminf(_ambient.b, 1.0f));
    
    sender.scale = 1.0f;
}

- (IBAction)onFlashlightToggle:(id)sender {
    _lightOn = !_lightOn;
}

- (IBAction)onPan:(UIPanGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        _dragStart = [sender locationInView:self.view];
    }
    CGPoint cur = [sender locationInView:self.view];
    GLKVector2 d = GLKVector2Make(cur.x - _dragStart.x, _dragStart.y - cur.y);
    _camera.rotation -= d.x * CAMERA_ROTATE_FACTOR;
    
    GLKVector3 movement = GLKVector3MultiplyScalar(_camera.lookDirection, d.y * CAMERA_MOVE_FACTOR);
    _camera.position = (GLKVector3Add(_camera.position, movement));
    _dragStart = cur;
}

- (IBAction)resetScene:(id)sender {
    _camera.rotation = M_PI;
    _camera.position = GLKVector3Make(0, 0, 0);
}

- (IBAction)toggleMinimap:(id)sender {
    _mapOn = !_mapOn;
}

- (IBAction)onFogToggle:(UIButton *)sender {
    if(!_fogOn)
    {
        _fogOn = YES;
        [sender setTitle:@"Fog Off" forState:UIControlStateNormal];
    }
    else
    {
        _fogOn = NO;
        [sender setTitle:@"Fog On" forState:UIControlStateNormal];
    }
}

- (IBAction)onToggleControls:(UIButton*)sender {
    _fogTypeToggle.hidden = !_fogTypeToggle.hidden;
    _fogColourLabel.hidden = !_fogColourLabel.hidden;
    _fogColourRLabel.hidden = !_fogColourRLabel.hidden;
    _fogColourGLabel.hidden = !_fogColourGLabel.hidden;
    _fogColourBLabel.hidden = !_fogColourBLabel.hidden;
    _fogColourRSlider.hidden = !_fogColourRSlider.hidden;
    _fogColourGSlider.hidden = !_fogColourGSlider.hidden;
    _fogColourBSlider.hidden = !_fogColourBSlider.hidden;
    _fogToggle.hidden = !_fogToggle.hidden;
    
    [sender setTitle: _fogTypeToggle.hidden ? @"Show Controls" : @"Hide Controls" forState:UIControlStateNormal];
}

- (IBAction)onRedColourChanged:(UISlider *)sender {
    _fogView.fog->colour.r = sender.value;
}

- (IBAction)onGreenColourChanged:(UISlider *)sender {
    _fogView.fog->colour.g = sender.value;
}

- (IBAction)onBlueColourChanged:(UISlider *)sender {
    _fogView.fog->colour.b = sender.value;
}
@end
