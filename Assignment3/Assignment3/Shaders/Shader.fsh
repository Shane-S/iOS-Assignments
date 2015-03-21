//
//  Shader.fsh
//  Assignment2
//
//  Created by Shane Spoor on 2015-02-26.
//  Copyright (c) 2015 BCIT. All rights reserved.
//
precision mediump float;

varying vec2 texCoordOut;
varying vec3 positionOut;
varying vec3 normalOut;

/* set up a uniform sampler2D to get texture */
uniform sampler2D texture;

// Flashlight variables
uniform vec3 lightDirection;
uniform vec3 lightPosition;
uniform vec4 lightColour;
uniform float lightIntensity;
uniform float lightConeAngleCosine;

// The colour and interpolated factor from the vertex shader
uniform vec4 fogColour;
uniform float fogDensity;
uniform float fogStart;
uniform float fogEnd;
uniform int fogType;

const int FOG_NONE = 0;
const int FOG_LINEAR = 1;
const int FOG_EXP = 2;
const int FOG_EXP2 = 3;

// The ambient lighting intensity
uniform vec4 ambient;

void main()
{
    // Get the initial texture colour
    vec4 texColour = texture2D(texture, texCoordOut);
    vec4 colour = texColour;
    vec4 diffuseComponent = vec4(0.0, 0.0, 0.0, 0.0);
    
    vec3 positionToLight        = -positionOut;
    float positionToLightLength = length(positionToLight);
    vec3 positionToLightNormed  = positionToLight / positionToLightLength;
    
    float fogFactor = 1.0;
    
    if(fogType == FOG_LINEAR)    fogFactor = clamp((-fogEnd - positionOut.z)/(-fogEnd+fogStart), 0.0, 1.0);
    else if(fogType == FOG_EXP)  fogFactor = clamp( exp(-fogDensity * -positionOut.z), 0.0, 1.0);
    else if(fogType == FOG_EXP2) fogFactor = clamp(exp(-pow(fogDensity * -positionOut.z, 2.0)), 0.0, 1.0);
    
    /**
     * The diagram looks something like this:
     *
     *
     *                                       /|
     *                                      / |
     *                                     /  |
     *                                    /   |
     *                                   /    |
     *                                  /     |
     *                                 /      |
     *                                /       |
     *     lightDirection * -cosine  /        |
     *                              /         |
     *                             /          |
     *                            /           |
     *                           /            |
     *                          /             |
     *                         /              |
     *                        /               |
     *                       /                |
     *                      /                 |
     *                     /                  |
     *                    /                   |
     *                   /                    |
     *                  /                     |
     *                 /                      |
     *                /\ lightConeAngle       |
     * lightPosition /__|_____________________|positionOut
     *
     *     cosine = (positionOut - lightPosition) dot lightDirection
     */
    
    // We're in view space, so the light direction will be positive Z; don't need to do dot product w/ light direction
    float cosine = positionToLightNormed.z;

    // lightDirection dot positionToLight
    if(cosine >= lightConeAngleCosine)
    {
        // Calculate the intensity of the light based on how close it is
        float actualIntensity = lightIntensity / positionToLightLength;

        // Calculate diffuse
        float angleIntensity = max(0.0, dot(positionToLightNormed, normalOut));
       
        diffuseComponent = (lightColour * texColour) * lightIntensity * angleIntensity;
     
        // Calculate specular
        // vec3 specular;
        
        // Vary the intensity based on the distance from the light
        //colour.rgb += (diffuse.rgb + specular.rgb) * actualIntensity;
    }

    colour = (colour * ambient) + diffuseComponent;
    colour = clamp(colour, vec4(0.0, 0.0, 0.0, 0.0), texColour * 1.8);
    colour = mix(fogColour, colour, fogFactor);
    colour.a = 1.0;
    
    gl_FragColor = colour;
}
