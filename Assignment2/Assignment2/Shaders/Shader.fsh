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

// The ambient lighting intensity
uniform vec3 ambient;

void main()
{
    // Get the initial texture colour
    vec4 colour = texture2D(texture, texCoordOut);
    
    // Add some default intensities
    colour.rgb *= ambient.rgb;
    
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
         *      lightDirection * cosine  /        |
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
        float cosine = dot(positionToLightNormed, lightDirection); // Have to take absolute value; one vector points at the light, the other points away

        if(cosine >= lightConeAngleCosine)
        {
            // Calculate the intensity of the light based on how close it is
            float actualIntensity = lightIntensity / positionToLightLength;

            // Calculate diffuse
            vec3 diffuse;
            float angleIntensity = dot(positionToLightNormed, normalOut);
            diffuse.rgb = (lightColour.rgb * colour.rgb) * max(0.0, angleIntensity);
            
            // Calculate specular
       //    vec3 specular;
            
            colour.rgb += diffuse.rgb;// * actualIntensity;
            
            // Vary the intensity based on the distance from the light
            //colour.rgb += (diffuse.rgb + specular.rgb) * actualIntensity;
        }
    }
    colour.rgb = clamp(colour.rgb, 0.0, 1.0);
    gl_FragColor = colour;
}
