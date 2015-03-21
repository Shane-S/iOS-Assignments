//
//  FBXtoGLK.cpp
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-11.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#include <fbxsdk.h>
#include <stdlib.h>
#include "FBXtoGLK.h"

using namespace fbxsdk_2015_1;

/**
 * Convert an FBX matrix to a GLK matrix.
 *
 * @param fbxMat The FBX matrix to convert.
 * @param dest   Pointer to a GLKMatrix4 which will store the converted matrix.
 */
void FBXMatrixToGLKMatrix4(FbxAMatrix* fbxMat, GLKMatrix4* dest)
{
    double* cols[] = {
        fbxMat->GetColumn(0).Buffer(),
        fbxMat->GetColumn(1).Buffer(),
        fbxMat->GetColumn(2).Buffer(),
        fbxMat->GetColumn(3).Buffer(),
    };
    
    for(int col = 0; col < 4; col++)
    {
        for(int row = 0; row < 4; row++)
        {
            dest->m[col + row] = (float)(cols[col][row]);
        }
    }
}

/**
 * Convert a GLK matrix to an FBX matrix.
 *
 * @param fbxMat The FBX matrix to convert.
 * @param dest   Pointer to a GLKMatrix4 which will store the converted matrix.
 */
void GLKMatrix4ToFBXAMatrix(GLKMatrix4* glkMat, FbxAMatrix* dest)
{
    double* cols[] = {
        dest->GetColumn(0).Buffer(),
        dest->GetColumn(1).Buffer(),
        dest->GetColumn(2).Buffer(),
        dest->GetColumn(3).Buffer(),
    };
    
    for(int col = 0; col < 4; col++)
    {
        for(int row = 0; row < 4; row++)
        {
            cols[col][row] = glkMat->m[col + row];
        }
    }
}