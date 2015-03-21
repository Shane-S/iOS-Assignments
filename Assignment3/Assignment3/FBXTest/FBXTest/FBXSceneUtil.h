//
//  FBXSceneUtil.h
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-10.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef __FBXTest__FBXSceneUtil__
#define __FBXTest__FBXSceneUtil__

/**
 * Loads a scene with the given file name and stores it in @var pScene.
 *
 * Note that pFilename should be obtained using [[NSBundle mainBundle] pathForResource:ofType:], otherwise
 * the import will likely fail with an uninformative error message ("Unexpected file type.").
 *
 * @param pManager  Handle to the SDK manager managing the scene's objects and memory.
 * @param pScene    Pointer to the scene which will store the meshes, textures, lights, etc. It will point
 *                  to a valid scene object if the function is successful.
 * @param pFilename A C string indicating the FBX file to load. Use [NSString cStringUsingEncoding:] to convert the
 *                  NSString returned from NSBundle. A list of string encodings can be found here:https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/#//apple_ref/doc/constant_group/String_Encodings
 * @return True if the scene creation was successful, false otherwise. The function will print an error message on failure.
 */
bool LoadScene(FbxManager* pManager, FbxDocument* pScene, const char* pFilename);

/**
 * Destroys all SDK objects managed by the given SDK manager.
 *
 * @param pManager Pointer to the SDK manager.
 */
void DestroySdkObjects(FbxManager* pManager);

#endif /* defined(__FBXTest__FBXSceneUtil__) */
