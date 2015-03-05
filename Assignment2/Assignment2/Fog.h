//
//  Fog.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
typedef enum
{
    FOG_NONE,
    FOG_LINEAR,
    FOG_EXP,
    FOG_EXP2
} FogType;

typedef struct _Fog
{
    float density;
    float start;
    float end;
    GLKVector4 colour;
    FogType type;
} Fog;
