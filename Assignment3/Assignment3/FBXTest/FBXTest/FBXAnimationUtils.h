//
//  FBXAnimationUtils.h
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-10.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef __FBXTest__FBXAnimationUtils__
#define __FBXTest__FBXAnimationUtils__

#include <fbxsdk.h>
#include "GetPosition.h"
#include "FBXMatrixUtils.h"

void ComputeShapeDeformation(FbxMesh* pMesh,
                             FbxTime& pTime,
                             FbxAnimLayer * pAnimLayer,
                             FbxVector4* pVertexArray);

void ComputeClusterDeformation(FbxAMatrix& pGlobalPosition,
                               FbxMesh* pMesh,
                               FbxCluster* pCluster,
                               FbxAMatrix& pVertexTransformMatrix,
                               FbxTime pTime,
                               FbxPose* pPose);

void ComputeLinearDeformation(FbxAMatrix& pGlobalPosition,
                              FbxMesh* pMesh,
                              FbxTime& pTime,
                              FbxVector4* pVertexArray,
                              FbxPose* pPose);

void ComputeDualQuaternionDeformation(FbxAMatrix& pGlobalPosition,
                                      FbxMesh* pMesh,
                                      FbxTime& pTime,
                                      FbxVector4* pVertexArray,
                                      FbxPose* pPose);

void ComputeSkinDeformation(FbxAMatrix& pGlobalPosition,
                            FbxMesh* pMesh,
                            FbxTime& pTime,
                            FbxVector4* pVertexArray,
                            FbxPose* pPose);

void ReadVertexCacheData(FbxMesh* pMesh,
                         FbxTime& pTime,
                         FbxVector4* pVertexArray);

#endif /* defined(__FBXTest__FBXAnimationUtils__) */
