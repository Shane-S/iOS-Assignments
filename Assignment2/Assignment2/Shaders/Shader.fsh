//
//  Shader.fsh
//  Assignment2
//
//  Created by Shane Spoor on 2015-02-26.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
