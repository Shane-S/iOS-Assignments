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


bool FBXRender::Initialize(FbxNode* rootNode, GLuint& numVertices, GLfloat* &vertices, GLuint& numIndices, GLuint* &indices)
{
	vertices = normals = NULL;
	numVertices = numNormals = 0;
    
    if (rootNode)
        TraverseFBXNodes(rootNode, numVertices, vertices, numIndices, indices);
	//LoadVBO(shaderPosAttr, shaderNormalAttr);

    initialized = true;

    return true;
}

void FBXRender::Purge()
{
    if (!initialized)
        return;
	//if (vertices)
	//	delete vertices;
	if (normals)
		delete normals;
}

bool FBXRender::Update()
{
    if (!initialized)
        return false;
	return true;
}

/*bool FBXRender::Render()
{
    if (!initialized)
        return false;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	if (indices)
	{
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vidx);
		glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, NULL);
	}
	else
	{
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glDrawArrays(GL_TRIANGLES, 0, numVertices);
	}

	return true;
}*/

void FBXRender::TraverseFBXNodes(FbxNode* node, GLuint& numVertices, GLfloat*& vertices, GLuint& numIndices, GLuint*& indices)
{
	// Grab the name
	const char* nodeName = node->GetName();
    printf("Traversing node <%s>\n", nodeName);
	
	// Get any transforms that could change the position
	FbxDouble3 trans = node->LclTranslation.Get();
	FbxDouble3 rot = node->LclRotation.Get();
	FbxDouble3 scale = node->LclScaling.Get();
	
	// Determine the number of children there are
	int numChildren = node->GetChildCount();
	FbxNode* childNode = 0;
    
	for (int i = 0; i < numChildren; i++) {
		childNode = node->GetChild(i);
		FbxMesh* mesh = childNode->GetMesh();
        
		if (mesh != NULL) {
			// ========= Get the vertices from the mesh ==============
			const char *name = mesh->GetName();
            printf("\tChild %d = <%s>\n", i, name);
			int numVerts = mesh->GetControlPointsCount();
			GLfloat* tempVerts = new GLfloat[numVerts*3];

			for (int j = 0; j < numVerts; j++) {
				FbxVector4 coord = mesh->GetControlPointAt(j);
				tempVerts[j*3+0] = (GLfloat)coord.mData[0];
				tempVerts[j*3+1] = (GLfloat)coord.mData[1];
				tempVerts[j*3+2] = (GLfloat)coord.mData[2];

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
		} // else

		TraverseFBXNodes(childNode, numVertices, vertices, numIndices, indices);
	} // for
}
/*
void FBXRender::LoadVBO(GLuint shaderPosAttr, GLuint shaderNormalAttr)
{
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	//int offset = 0;
	
	int sizeBuffer = (numVertices * 3) * sizeof(GLfloat);
	
	glBufferData(GL_ARRAY_BUFFER, sizeBuffer, this->vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(shaderPosAttr, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vidx);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numIndices * sizeof(int), this->indices, GL_STATIC_DRAW);
}*/
