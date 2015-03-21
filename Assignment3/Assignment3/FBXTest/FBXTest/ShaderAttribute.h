//
//  ShaderAttribute.h
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef FBXTest_ShaderAttribute_h
#define FBXTest_ShaderAttribute_h

enum {
    SHADER_ATTR_POSITION,
    SHADER_ATTR_NORMAL,
    SHADER_ATTR_UV,
    SHADER_ATTR_TEXCOORD0,
    SHADER_ATTR_TEXCOORD1
};

/**
 * Contains the OpenGL index indicating the type of attribute and its name within the vertex shader.
 */
typedef struct _ShaderAttribute {
    GLuint attributeIndex;
    const char *attributeName;
} ShaderAttribute;

#endif
