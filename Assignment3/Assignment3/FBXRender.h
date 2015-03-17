//////////////////////////////////////////////////////////////////////////
//
//  FBXRender
//
//  (c) 2010-2015 Borna Noureddin
//
//////////////////////////////////////////////////////////////////////////

#ifndef FBXRENDER_H
#define FBXRENDER_H

#define FBXSDK_NEW_API
#include "fbxsdk.h"
#include <OpenGLES/ES2/gl.h>

using namespace std;

struct MeshExtents
{
	bool xInit, yInit, zInit;
	GLfloat xMin, xMax;
	GLfloat yMin, yMax;
	GLfloat zMin, zMax;
};


class FBXRender
{
public:

    FBXRender() : initialized(false) {};

	bool Initialize(FbxNode* rootNode, GLuint& numVertices, GLfloat* &vertices, GLuint& numIndices, GLuint* &indices);
	void Purge();
	bool Update();
	bool Render();

    //private:
    bool initialized;
	GLfloat *normals;
	GLuint numNormals;
	MeshExtents meshExtents;

	void TraverseFBXNodes(FbxNode* node, GLuint& numVertices, GLfloat*& vertices, GLuint& numIndices, GLuint*& indices);
	//void LoadVBO(GLuint shaderPosAttr, GLuint shaderNormalAttr);
};


#endif