//
//  Shader.vsh
//  Assignment2
//
//  Created by Shane Spoor on 2015-02-26.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

precision mediump float;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoordIn;

// Get the information for the fragment shader
varying vec2 texCoordOut;
varying vec3 positionOut;
varying vec3 normalOut;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 translatedNormal = normalize(normalMatrix * normal);
    vec4 viewSpacePos = modelViewMatrix * position;
    normalOut = translatedNormal;
    
    positionOut = viewSpacePos.xyz;
    texCoordOut = texCoordIn;

    gl_Position = projectionMatrix * viewSpacePos;
}
