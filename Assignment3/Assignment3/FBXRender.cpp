//////////////////////////////////////////////////////////////////////////
//
//  FBXRender
//
//  (c) 2010-2015 Borna Noureddin
//
//////////////////////////////////////////////////////////////////////////


#define _USE_MATH_DEFINES
#include <math.h>

#include "FBXRender.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

void LoadUVInformation(FbxMesh* pMesh, GLfloat* uvs);

bool FBXRender::Initialize(FbxNode* rootNode, GLuint& numVertices, GLfloat* &vertices, GLuint& numIndices, GLuint* &indices)
{
	vertices = normals = NULL;
	numVertices = numNormals = 0;
    
    if (rootNode)
        TraverseFBXNodes(rootNode, numVertices, vertices, numIndices, indices);
    initialized = true;

    return true;
}

void FBXRender::Purge()
{
    if (!initialized)
        return;
	if (vertices)
		delete vertices;
	if (normals)
		delete normals;
}

bool FBXRender::Update()
{
    if (!initialized)
        return false;
	return true;
}

void FBXRender::TraverseFBXNodes(FbxNode* node, GLuint& numVertices, GLfloat*& vertices, GLuint& numIndices, GLuint*& indices)
{
    // Get any transforms that could change the position
    FbxDouble3 trans = node->LclTranslation.Get();
    FbxDouble3 rot = node->LclRotation.Get();
    FbxDouble3 scale = node->LclScaling.Get();
    
    // Determine the number of children there are
    int numChildren = node->GetChildCount();
    FbxNode* childNode = 0;
    
    for (int i = 0; i < numChildren; i++)
    {
        childNode = node->GetChild(i);
        FbxMesh* mesh = childNode->GetMesh();
        
        if (mesh != NULL) {
            // ========= Get the vertices from the mesh ==============
            int numVerts = mesh->GetControlPointsCount();
            GLfloat* tempVerts = new GLfloat[numVerts*3];
            
            for (int j = 0; j < numVerts; j++) {
                FbxVector4 coord = mesh->GetControlPointAt(j);
                tempVerts[j*3+0] = (GLfloat)coord.mData[0] * 0.005;
                tempVerts[j*3+1] = (GLfloat)coord.mData[1] * 0.005 - 0.5;
                tempVerts[j*3+2] = (GLfloat)coord.mData[2] * 0.005;
                
            }
            vertices = tempVerts;
            numVertices = numVerts;
            
            // ========= Get the indices from the mesh ===============
            numIndices = mesh->GetPolygonVertexCount();
            indices = (GLuint *)mesh->GetPolygonVertices();
            
            // ========= Get the normals from the mesh ===============
            FbxGeometryElementNormal* normalElement = mesh->GetElementNormal();
            if (normalElement) {
                numNormals = mesh->GetPolygonCount()*3;
                GLfloat* tempNormals = new GLfloat[numNormals*3];
                int vertexCounter = 0;
                // Loop through the triangle meshes
                for(int polyCounter = 0; polyCounter < mesh->GetPolygonCount(); polyCounter++)
                {
                    // Loop through each vertex of the triangle
                    for(int i = 0; i < 3; i++)
                    {
                        //Get the normal for this vertex
                        FbxVector4 normal = normalElement->GetDirectArray().GetAt(vertexCounter);
                        tempNormals[vertexCounter*3+0] = normal[0];
                        tempNormals[vertexCounter*3+1] = normal[1];
                        tempNormals[vertexCounter*3+2] = normal[2];
                    }
                    vertexCounter += 3;
                }
                normals = tempNormals;
            }
            
            //FbxGeometryElementUV* uvElement = mesh->GetElementUV();
            //if (uvElement)
            //{
                
            //}
            
            LoadUVInformation(mesh);
            
        } // else
        
        TraverseFBXNodes(childNode, numVertices, vertices, numIndices, indices);
    } // for
}

void FBXRender::LoadUVInformation(FbxMesh* pMesh)
{
    //get all UV set names
    FbxStringList lUVSetNameList;
    pMesh->GetUVSetNames(lUVSetNameList);
    
    //iterating over all uv sets
    for (int lUVSetIndex = 0; lUVSetIndex < lUVSetNameList.GetCount(); lUVSetIndex++)
    {
        //get lUVSetIndex-th uv set
        const char* lUVSetName = lUVSetNameList.GetStringAt(lUVSetIndex);
        const FbxGeometryElementUV* lUVElement = pMesh->GetElementUV(lUVSetName);
        
        if(!lUVElement)
            continue;
        
        // only support mapping mode eByPolygonVertex and eByControlPoint
        if( lUVElement->GetMappingMode() != FbxGeometryElement::eByPolygonVertex &&
           lUVElement->GetMappingMode() != FbxGeometryElement::eByControlPoint )
            return;
        
        //index array, where holds the index referenced to the uv data
        const bool lUseIndex = lUVElement->GetReferenceMode() != FbxGeometryElement::eDirect;
        const int lIndexCount= (lUseIndex) ? lUVElement->GetIndexArray().GetCount() : 0;
        
        //iterating through the data by polygon
        const int lPolyCount = pMesh->GetPolygonCount();
        const int lPolySize = pMesh->GetPolygonSize(0);
        
        GLfloat* tempUVs = new GLfloat[lPolyCount * lPolySize * 2];
        int uvIndex = 0;
        
        if( lUVElement->GetMappingMode() == FbxGeometryElement::eByControlPoint )
        {
            for( int lPolyIndex = 0; lPolyIndex < lPolyCount; ++lPolyIndex )
            {
                // build the max index array that we need to pass into MakePoly
                for( int lVertIndex = 0; lVertIndex < lPolySize; ++lVertIndex )
                {
                    FbxVector2 lUVValue;
                    
                    //get the index of the current vertex in control points array
                    int lPolyVertIndex = pMesh->GetPolygonVertex(lPolyIndex,lVertIndex);
                    
                    //the UV index depends on the reference mode
                    int lUVIndex = lUseIndex ? lUVElement->GetIndexArray().GetAt(lPolyVertIndex) : lPolyVertIndex;
                    
                    lUVValue = lUVElement->GetDirectArray().GetAt(lUVIndex);
                    
                    tempUVs[uvIndex++] = lUVValue[0];
                    tempUVs[uvIndex++] = lUVValue[1];
                    //User TODO:
                    //Print out the value of UV(lUVValue) or log it to a file
                }
            }
            
        }
        else if (lUVElement->GetMappingMode() == FbxGeometryElement::eByPolygonVertex)
        {
            int lPolyIndexCounter = 0;
            const int lPolySize = pMesh->GetPolygonSize(0);
            
            for( int lPolyIndex = 0; lPolyIndex < lPolyCount; ++lPolyIndex )
            {
                // build the max index array that we need to pass into MakePoly
                for( int lVertIndex = 0; lVertIndex < lPolySize; ++lVertIndex )
                {
                    if (lPolyIndexCounter < lIndexCount)
                    {
                        FbxVector2 lUVValue;
                        
                        //the UV index depends on the reference mode
                        int lUVIndex = lUseIndex ? lUVElement->GetIndexArray().GetAt(lPolyIndexCounter) : lPolyIndexCounter;
                        
                        lUVValue = lUVElement->GetDirectArray().GetAt(lUVIndex);
                        
                        tempUVs[uvIndex++] = lUVValue[0];
                        tempUVs[uvIndex++] = lUVValue[1];
                        //User TODO:
                        //Print out the value of UV(lUVValue) or log it to a file
                        
                        lPolyIndexCounter++;
                    }
                }
            }
            
        }
        uvs = tempUVs;
    }
}


