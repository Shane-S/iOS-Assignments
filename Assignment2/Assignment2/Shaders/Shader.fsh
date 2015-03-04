//
//  Shader.fsh
//  Assignment2
//
//  Created by Shane Spoor on 2015-02-26.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

precision mediump float;

varying lowp vec4 colorVarying;
varying vec2 texCoordOut;

/* set up a uniform sampler2D to get texture */
uniform sampler2D texture;

void main()
{
    vec4 colour = texture2D(texture, texCoordOut);
    gl_FragColor = colour;//colorVarying * colour;
}
