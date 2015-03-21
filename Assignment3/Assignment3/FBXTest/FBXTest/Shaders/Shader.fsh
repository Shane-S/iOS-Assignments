//
//  Shader.fsh
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-10.
//  Copyright (c) 2015 BCIT. All rights reserved.
//
precision mediump float;

varying lowp vec4 colorVarying;
varying vec2 texCoordOut;

uniform sampler2D tex;
void main()
{
    vec4 texColour = texture2D(tex, texCoordOut);
    gl_FragColor = texColour;
}
