//
//  FBXDrawUtils.cpp
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-10.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#include "FBXDrawUtils.h"
#include "FBXAnimationUtils.h"
#include "GetPosition.h"
#include "SceneCache.h"

/****************************************************************************************
 
 Copyright (C) 2014 Autodesk, Inc.
 All rights reserved.
 
 Use of this software is subject to the terms of the Autodesk license agreement
 provided at the time of installation or download, or which otherwise accompanies
 this software in either electronic or hard copy form.
 
 ****************************************************************************************/

void DrawNode(FbxNode* pNode,
              FbxTime& lTime,
              FbxAnimLayer * pAnimLayer,
              FbxAMatrix& pParentGlobalPosition,
              FbxAMatrix& pGlobalPosition,
              FbxPose* pPose);

void DrawMesh(FbxNode* pNode, FbxTime& pTime, FbxAnimLayer* pAnimLayer,
              FbxAMatrix& pGlobalPosition, FbxPose* pPose);

// Draw recursively each node of the scene. To avoid recomputing
// uselessly the global positions, the global position of each
// node is passed to it's children while browsing the node tree.
// If the node is part of the given pose for the current scene,
// it will be drawn at the position specified in the pose, Otherwise
// it will be drawn at the given time.
void DrawNodeRecursive(FbxNode* pNode, FbxTime& pTime, FbxAnimLayer* pAnimLayer,
                       FbxAMatrix& pParentGlobalPosition, FbxPose* pPose)
{
    FbxAMatrix lGlobalPosition = GetGlobalPosition(pNode, pTime, pPose, &pParentGlobalPosition);
    
    if (pNode->GetNodeAttribute())
    {
        // Geometry offset.
        // it is not inherited by the children.
        FbxAMatrix lGeometryOffset = GetGeometry(pNode);
        FbxAMatrix lGlobalOffPosition = lGlobalPosition * lGeometryOffset;
        
        DrawNode(pNode, pTime, pAnimLayer, pParentGlobalPosition, lGlobalOffPosition, pPose);
    }
    
    const int lChildCount = pNode->GetChildCount();
    for (int lChildIndex = 0; lChildIndex < lChildCount; ++lChildIndex)
    {
        DrawNodeRecursive(pNode->GetChild(lChildIndex), pTime, pAnimLayer, lGlobalPosition, pPose);
    }
}

// Draw the node following the content of it's node attribute.
void DrawNode(FbxNode* pNode,
              FbxTime& pTime,
              FbxAnimLayer* pAnimLayer,
              FbxAMatrix& pParentGlobalPosition,
              FbxAMatrix& pGlobalPosition,
              FbxPose* pPose)
{
    FbxNodeAttribute* lNodeAttribute = pNode->GetNodeAttribute();
    
    if (lNodeAttribute)
    {
        // NURBS and patch have been converted into triangluation meshes.
        if (lNodeAttribute->GetAttributeType() == FbxNodeAttribute::eMesh)
        {
            DrawMesh(pNode, pTime, pAnimLayer, pGlobalPosition, pPose);
        }
    }
}

// Draw the vertices of a mesh.
void DrawMesh(FbxNode* pNode, FbxTime& pTime, FbxAnimLayer* pAnimLayer,
              FbxAMatrix& pGlobalPosition, FbxPose* pPose)
{
    FbxMesh* lMesh = pNode->GetMesh();
    const int lVertexCount = lMesh->GetControlPointsCount();
    
    // No vertex to draw.
    if (lVertexCount == 0)
    {
        return;
    }
    
    const VBOMesh * lMeshCache = static_cast<const VBOMesh *>(lMesh->GetUserDataPtr());
    
    // If it has some defomer connection, update the vertices position
    const bool lHasVertexCache = lMesh->GetDeformerCount(FbxDeformer::eVertexCache) &&
    (static_cast<FbxVertexCacheDeformer*>(lMesh->GetDeformer(0, FbxDeformer::eVertexCache)))->Active.Get();
    const bool lHasShape = lMesh->GetShapeCount() > 0;
    const bool lHasSkin = lMesh->GetDeformerCount(FbxDeformer::eSkin) > 0;
    const bool lHasDeformation = lHasVertexCache || lHasShape || lHasSkin;
    
    FbxVector4* lVertexArray = NULL;
    if (!lMeshCache || lHasDeformation)
    {
        lVertexArray = new FbxVector4[lVertexCount];
        memcpy(lVertexArray, lMesh->GetControlPoints(), lVertexCount * sizeof(FbxVector4));
    }
    
    if (lHasDeformation)
    {
        // Active vertex cache deformer will overwrite any other deformer
        if (lHasVertexCache)
        {
            ReadVertexCacheData(lMesh, pTime, lVertexArray);
        }
        else
        {
            if (lHasShape)
            {
                // Deform the vertex array with the shapes.
                ComputeShapeDeformation(lMesh, pTime, pAnimLayer, lVertexArray);
            }
            
            //we need to get the number of clusters
            const int lSkinCount = lMesh->GetDeformerCount(FbxDeformer::eSkin);
            int lClusterCount = 0;
            for (int lSkinIndex = 0; lSkinIndex < lSkinCount; ++lSkinIndex)
            {
                lClusterCount += ((FbxSkin *)(lMesh->GetDeformer(lSkinIndex, FbxDeformer::eSkin)))->GetClusterCount();
            }
            if (lClusterCount)
            {
                // Deform the vertex array with the skin deformer.
                ComputeSkinDeformation(pGlobalPosition, lMesh, pTime, lVertexArray, pPose);
            }
        }
        
        if (lMeshCache)
            lMeshCache->UpdateVertexPosition(lMesh, lVertexArray);
    }
    
    // Concatenate the matrix with the global position
    // This will need to be done using GLKMatrix4
    if (lMeshCache)
    {
        lMeshCache->BeginDraw();
        const int lSubMeshCount = lMeshCache->GetSubMeshCount();
        for (int lIndex = 0; lIndex < lSubMeshCount; ++lIndex)
        {
            const FbxSurfaceMaterial * lMaterial = pNode->GetMaterial(lIndex);
            if (lMaterial)
            {
                const MaterialCache * lMaterialCache = static_cast<const MaterialCache *>(lMaterial->GetUserDataPtr());
                if (lMaterialCache)
                {
                    lMaterialCache->SetCurrentMaterial();
                }
            }
            else
            {
                // Draw green for faces without material
                MaterialCache::SetDefaultMaterial();
            }
            lMeshCache->Draw(lIndex);
        }
        lMeshCache->EndDraw();
    }
    
    delete [] lVertexArray;
}
