//
//  FBXMatrixUtils.h
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef __FBXTest__FBXMatrixUtils__
#define __FBXTest__FBXMatrixUtils__

#include <stdio.h>
#include <fbxsdk.h>

// Scale all the elements of a matrix.
void MatrixScale(FbxAMatrix& pMatrix, double pValue);
// Add a value to all the elements in the diagonal of the matrix.
void MatrixAddToDiagonal(FbxAMatrix& pMatrix, double pValue);

// Sum two matrices element by element.
void MatrixAdd(FbxAMatrix& pDstMatrix, FbxAMatrix& pSrcMatrix);
#endif /* defined(__FBXTest__FBXMatrixUtils__) */
