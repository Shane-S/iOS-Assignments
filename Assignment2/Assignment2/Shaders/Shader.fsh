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
uniform bool lightOn;
uniform vec3 lightDirection;
uniform vec3 lightPosition;
uniform vec3 lightColour;
uniform float lightIntensity;
uniform float lightConeAngleCosine;

const int FOG_NONE = 0;
const int FOG_LINEAR = 1;
const int FOG_EXP = 2;
const int FOG_EXP2 = 3;

const float LOG2 = 1.442695;
uniform float fogDensity;
uniform float fogStart;
uniform float fogEnd;
uniform vec4 fogColour;
uniform int fogType;

// The ambient lighting intensity
uniform vec3 ambient;

void main()
{
    // Get the initial texture colour
    vec4 texColour = texture2D(texture, texCoordOut);
    vec4 colour = texColour;
    vec3 diffuse = vec3(0.0, 0.0, 0.0);
    
    // Do the flashlight calculations
    if(lightOn)
    {
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
        
        vec3 positionToLight        = -positionOut;
        float positionToLightLength = length(positionToLight);
        vec3 positionToLightNormed  = positionToLight / positionToLightLength;
        float cosine = dot(positionToLightNormed, lightDirection);

        // lightDirection dot positionToLight
        if(cosine >= lightConeAngleCosine)
        {
            // Calculate the intensity of the light based on how close it is
            float actualIntensity = lightIntensity / positionToLightLength;

            // Calculate diffuse
            float angleIntensity = dot(positionToLightNormed, normalOut);
            diffuse.rgb = (lightColour.rgb * colour.rgb) * max(0.0, angleIntensity);
            
            // Calculate specular
       //    vec3 specular;
            
            // Vary the intensity based on the distance from the light
            //colour.rgb += (diffuse.rgb + specular.rgb) * actualIntensity;
        }
    }

    colour.rgb = (colour.rgb * ambient.rgb) + diffuse.rgb;
    colour.rgb = clamp(colour.rgb, vec3(0.0, 0.0, 0.0), texColour.rgb * 1.8);
    
    if(fogType != FOG_NONE)
    {
        if(fogType == FOG_LINEAR)
        {
            float fogFactor = clamp((-fogEnd - positionOut.z)/(-fogEnd+fogStart), 0.0, 1.0);
            colour = mix(fogColour, colour, fogFactor);
        }
        else if(fogType == FOG_EXP)
        {
            float fogFactor = clamp( exp(-fogDensity * -positionOut.z), 0.0, 1.0);
            colour = mix(fogColour, colour, fogFactor);
        }
        else if(fogType == FOG_EXP2)
        {
            float fogFactor = clamp(exp(-pow(fogDensity * -positionOut.z, 2.0)), 0.0, 1.0);
            colour = mix(fogColour, colour, fogFactor);
        }
    }
    
    gl_FragColor = colour;
}
