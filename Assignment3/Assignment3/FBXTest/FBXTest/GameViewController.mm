//
//  GameViewController.m
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-10.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import <fbxsdk.h>
#import "FBXSceneUtil.h"
#import "GLProgramUtils.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define NUM_MAIN_SHADER_ATTRIBUTES 3

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
    FbxManager* _sdkManager;
    FbxScene* _scene;
    FbxNode* _meshNode;
    ShaderAttribute _mainAttrs[NUM_MAIN_SHADER_ATTRIBUTES];
    GLuint vao;
    GLuint vbo;
    GLuint vidx;
    GLuint uvbuf;
    GLuint texture;

    float _rotation;
    GLKMatrix4 _modelMatrix;
    GLKMatrix4 _viewMatrix;
    GLKMatrix4 _projectionMatrix;
    
    int _numIndices;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

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
    
    // Create an SDK manager and scene object
    _sdkManager = FbxManager::Create();
    FbxIOSettings* ios = FbxIOSettings::Create(_sdkManager, IOSROOT);
    _sdkManager->SetIOSettings(ios);
    _scene = FbxScene::Create(_sdkManager, "Scene001");

    
    
    _viewMatrix = GLKMatrix4MakeScale(6.0, 6.0, 6.0);
    _viewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, -5.0f), _viewMatrix);
    
    NSString* filename = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"fbx"];
    
    // Find the first node with a mesh
    LoadScene(_sdkManager, _scene, [filename cStringUsingEncoding:NSASCIIStringEncoding]);
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
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // Create and bind a vertex array to hold our vertex formats etc.
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    // Find the first mesh node in the scene (there are far better way of doing this, and it's not
    // really what we want, but this is sufficient for now)
    FbxNode* root = _scene->GetRootNode();
    FbxNode* meshNode = NULL;
    int numChildren = root->GetChildCount();
    for(int i = 0; i < numChildren; i++)
    {
        FbxNode* node = root->GetChild(i);
        FbxNodeAttribute* attr = node->GetNodeAttribute();
        FbxNodeAttribute::EType type = attr->GetAttributeType();
        if (type == FbxNodeAttribute::eMesh)
        {
            meshNode = node;
            break;
        }
    }
    
    
    // Get the mesh and load its indices into the index buffer
    FbxMesh* mesh = meshNode->GetMesh();
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
    
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 5 * mesh->GetPolygonVertexCount(), verts, GL_STATIC_DRAW);
    
    // Tell OpenGL to set the format for the vertex buffer in the vertex array
    glEnableVertexAttribArray(SHADER_ATTR_POSITION);
    glVertexAttribPointer(SHADER_ATTR_POSITION, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (char*)0);
    
    // Enable the texture coordinates and specify their format
    glEnableVertexAttribArray(SHADER_ATTR_TEXCOORD0);
    glVertexAttribPointer(SHADER_ATTR_TEXCOORD0, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (char*)(3 * sizeof(float)));
    
    NSString* textureFilename = [[NSBundle mainBundle] pathForResource:@"cube_texture" ofType:@"jpg"];
    texture = [GLProgramUtils setupTexture:textureFilename];
    
    glActiveTexture(GL_TEXTURE0);
    
    // Free all dat memory
    delete[] vertices;
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    _projectionMatrix = GLKMatrix4MakePerspective(65 * (180 / M_PI), aspect, 0.1f, 100.0f);
    
    _rotation += 0.01;
    _modelMatrix = GLKMatrix4MakeYRotation(_rotation);
    //_modelMatrix = GLKMatrix4Multiply(_modelMatrix, GLKMatrix4MakeXRotation(_rotation));
    GLKMatrix4 mvp = GLKMatrix4Multiply(_projectionMatrix, GLKMatrix4Multiply(_viewMatrix, _modelMatrix));
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, mvp.m);
    glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, GL_FALSE, GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_viewMatrix), NULL).m);
    
    [self updateScene];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUseProgram(_program);
    
    glBindVertexArrayOES(vao);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    [self traverseAndRenderScene];
}

-(void)updateScene
{
    
}

-(void)traverseAndRenderScene
{
    
}

-(BOOL) loadShaders
{
    _mainAttrs[0] = {SHADER_ATTR_POSITION, "position"};
    _mainAttrs[1] = {SHADER_ATTR_NORMAL, "normal"};
    _mainAttrs[2] = {SHADER_ATTR_TEXCOORD0, "texCoordIn"};
    
    NSString* vert = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString* frag = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    
    [GLProgramUtils makeProgram:&_program withVertShader:vert andFragShader:frag
                  andAttributes:_mainAttrs withNumberOfAttributes:sizeof(_mainAttrs) / sizeof(ShaderAttribute)];
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "tex");
    return YES;
}

@end
