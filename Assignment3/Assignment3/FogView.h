//
//  FogView.h
//  Assignment2
//
//  Created by Shane Spoor on 2015-03-04.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fog.h"

@interface FogView : NSObject

@property (nonatomic, readonly) Fog* fog;
@property (nonatomic) GLuint* uniforms;

-(instancetype)initWithFog:(Fog)fog andUniformArray:(GLuint*)uniforms;
-(void)draw;

@end
