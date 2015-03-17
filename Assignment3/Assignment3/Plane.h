//
//  Plane.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-02.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>

// (position: (x, y, z) + normal: (x, y, z) + texture: (s, t)) * 6 vertices per face
#define FLOATS_PER_FACE 48

typedef enum _PlaneType
{
    NORTH_WALL,
    SOUTH_WALL,
    WEST_WALL,
    EAST_WALL,
    FLOOR,
} PlaneType;

extern const GLKVector3 planePositions[5];

@interface Plane : NSObject

@property (nonatomic) GLKVector3 position;
@property (nonatomic) float scale;

@property (readonly, nonatomic) const float *vertices;
@property (readonly, nonatomic) unsigned int verticesSize; // Size in bytes of the vertex array
@property (readonly, nonatomic) PlaneType type;

-(instancetype)initWithPosition: (GLKVector3)pos andScale: (float)scale andPlaneType: (PlaneType)type;

@end
