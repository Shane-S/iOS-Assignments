//
//  FogView.m
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import "Uniforms.h"
#import "FogView.h"

@interface FogView()
{
    Fog _fog;
    GLuint* _uniforms;
}

@end

@implementation FogView

-(instancetype)initWithFog:(Fog)fog andUniformArray:(GLuint *)uniforms
{
    if((self = [super init]))
    {
        _fog = fog;
        _uniforms = uniforms;
    }
    return self;
}

-(Fog*)fog
{
    return &_fog;
}

-(void)draw
{
    FogType type = _fog.type;
    glUniform1i(_uniforms[UNIFORM_FOG_TYPE], type);
    switch(type)
    {
        case FOG_NONE:
            break;
        case FOG_LINEAR:
            glUniform4fv(_uniforms[UNIFORM_FOG_COLOUR], 1, _fog.colour.v);
            glUniform1i(_uniforms[UNIFORM_FOG_TYPE], FOG_LINEAR);
            glUniform1f(_uniforms[UNIFORM_FOG_START], _fog.start);
            glUniform1f(_uniforms[UNIFORM_FOG_END],  _fog.end);
        case FOG_EXP:
        case FOG_EXP2:
            glUniform4fv(_uniforms[UNIFORM_FOG_COLOUR], 1, _fog.colour.v);
            glUniform1f(_uniforms[UNIFORM_FOG_DENSITY], _fog.density);
            break;
    }
}

@end
