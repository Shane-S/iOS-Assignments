//
//  AIEntity.m
//  Assignment3
//
//  Created by Dan Russell on 2015-03-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIEntity.h"

@implementation AIEntity

-(instancetype)init
{
    if((self = [super init]))
    {
        _position = GLKVector3Make(0, 0, 0);
    }
    return self;
}

-(void)update
{
    _position.x = 1;
    _position.z = 1;
    _modelMatrix = GLKMatrix4Identity;
    _modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(_position.x, _position.y, _position.z), _modelMatrix);
}
@end