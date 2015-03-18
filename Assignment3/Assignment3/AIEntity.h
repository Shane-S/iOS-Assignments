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

@interface AIEntity : NSObject

-(instancetype)init;
-(void)update;
@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKMatrix4 modelMatrix;

@end
#endif
