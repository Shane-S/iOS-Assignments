//
//  AIEntity.h
//  Assignment3
//
//  Created by Dan Russell on 2015-03-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef Assignment3_AIEntity_h
#define Assignment3_AIEntity_h

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "MazeWrapper.h"

@interface AIEntity : NSObject

typedef enum AIState
{
    choosingDirection,
    moving,
    paused
} AIState;

-(instancetype)init;
-(void)updateWithElapsedTime:(float) deltaTime andMap:(MazeWrapper*) maze;
@property (nonatomic) float speed;
@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 scale;
@property (nonatomic) GLKVector3 rotation;
@property (nonatomic) GLKVector3 targetPosition;
@property (nonatomic) enum AIState state;

@end
#endif
