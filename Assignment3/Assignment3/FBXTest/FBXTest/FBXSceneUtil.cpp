//
//  FBXSceneUtil.cpp
//  FBXTest
//
//  Created by Shane Spoor on 2015-03-10.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#include <fbxsdk.h>
#include "FBXSceneUtil.h"

using namespace fbxsdk_2015_1;

bool LoadScene(FbxManager* pManager, FbxDocument* pScene, const char* pFilename)
{
    bool lStatus;
    char lPassword[1024];
    
    // Create an importer.
    FbxImporter* lImporter = FbxImporter::Create(pManager,"");
    
    // Initialize the importer by providing a filename.
    const bool lImportStatus = lImporter->Initialize(pFilename, -1, pManager->GetIOSettings());
    
    if( !lImportStatus )
    {
        FbxString error = lImporter->GetStatus().GetErrorString();
        FBXSDK_printf("Call to FbxImporter::Initialize() failed.\n");
        FBXSDK_printf("Error returned: %s\n\n", error.Buffer());
        
        if (lImporter->GetStatus().GetCode() == FbxStatus::eInvalidFileVersion)
        {
            int lFileMajor, lFileMinor, lFileRevision;
            int lSDKMajor,  lSDKMinor,  lSDKRevision;
            
            // Get the file version number generate by the FBX SDK.
            FbxManager::GetFileFormatVersion(lSDKMajor, lSDKMinor, lSDKRevision);
            lImporter->GetFileVersion(lFileMajor, lFileMinor, lFileRevision);
            
            FBXSDK_printf("FBX file format version for this FBX SDK is %d.%d.%d\n", lSDKMajor, lSDKMinor, lSDKRevision);
            FBXSDK_printf("FBX file format version for file '%s' is %d.%d.%d\n\n", pFilename, lFileMajor, lFileMinor, lFileRevision);
        }
        return false;
    }
    
    if (lImporter->IsFBX())
    {
        // Set the import states. By default, the import states are always set to
        // true. The code below shows how to change these states.
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_MATERIAL,        true);
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_TEXTURE,         true);
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_LINK,            true);
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_SHAPE,           true);
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_GOBO,            true);
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_ANIMATION,       true);
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_GLOBAL_SETTINGS, true);
    }
    
    // Import the scene.
    lStatus = lImporter->Import(pScene);
    
    if(lStatus == false && lImporter->GetStatus().GetCode() == FbxStatus::ePasswordError)
    {
        FBXSDK_printf("Please enter password: ");
        
        lPassword[0] = '\0';
        
        FBXSDK_CRT_SECURE_NO_WARNING_BEGIN
        scanf("%s", lPassword);
        FBXSDK_CRT_SECURE_NO_WARNING_END
        
        FbxString lString(lPassword);
        
        pManager->GetIOSettings()->SetStringProp(IMP_FBX_PASSWORD,      lString);
        pManager->GetIOSettings()->SetBoolProp(IMP_FBX_PASSWORD_ENABLE, true);
        
        lStatus = lImporter->Import(pScene);
        
        if(lStatus == false && lImporter->GetStatus().GetCode() == FbxStatus::ePasswordError)
        {
            FBXSDK_printf("\nPassword is wrong, import aborted.\n");
        }
    }
    
    // Destroy the importer.
    lImporter->Destroy();
    
    return lStatus;
}

void DestroySdkObjects(FbxManager* pManager)
{
    //Delete the FBX Manager. All the objects that have been allocated using the FBX Manager and that haven't been explicitly destroyed are also automatically destroyed.
    if( pManager ) pManager->Destroy();
}
