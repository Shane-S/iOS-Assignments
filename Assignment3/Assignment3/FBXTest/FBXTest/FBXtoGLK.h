//
//  FBXtoGLK.h
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-11.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef __FBXTest__FBXtoGLK__
#define __FBXTest__FBXtoGLK__
#include <GLKit/GLKMatrix4.h>

void FBXMatrixToGLKMatrix4(FbxAMatrix* fbxMat, GLKMatrix4* dest);

#endif /* defined(__FBXTest__FBXtoGLK__) */
