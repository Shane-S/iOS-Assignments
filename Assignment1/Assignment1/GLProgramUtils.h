//
//  GLProgramUtils.h
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-13.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

/**
 * @brief Failure states for the makeProgram function.
 */
enum GL_PROG_UTILS_MAKEFAIL
{
    VERT_SHADER_FAIL  = 1,
    FRAG_SHADER_FAIL  = 2,
    PROGRAM_LINK_FAIL = 3
};

@interface GLProgramUtils : NSObject

/**
 * @brief Validates a linked program.
 *
 * @discussion According to the <a href="https://www.khronos.org/opengles/sdk/docs/man/xhtml/glValidateProgram.xml">
 *             OpenGL</a> specification, glValidateProgram determines whether the program can run given the current
 *             state of OpenGL. If this function returns NO, use <a href="https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGetProgramInfoLog.xml">
 *             glGetProgramInfoLog</a> to retrieve a string describing the problem.
 *
 * @param prog Handle to the program to be validated.
 * @return Whether the program is valid.
 */
+ (BOOL)validateProgram:(GLuint)prog;

/**
 * @brief Links a compiled shader program.
 * @param prog Index to the compiled program to be linked.
 * @return Whether the shader was successfully linked.
 */
+ (BOOL)linkProgram:(GLuint)prog;

/**
 * @brief Compiles the shader of the specified type with source code in the given file.
 *
 * @discussion Note that the shader can only be used if this function returns YES.
 *
 * @param shader Pointer to an integer which will hold the shader index on success.
 * @param type   The type of shader (not sure what this actually is).
 * @param file   The path to the file containing the shader's source code.
 * @return       Whether the shader was successfully compiled.
 */
+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;

/**
 * @brief Compiles, links and validates a program with the given vertex and fragment shader.
 * @discussion The returned integer will be 0 on success and will otherwise hold the creation step that failed.
 * @param program        Pointer to ta GLuint which will hold the program handle on successful compilation.
 * @param vertShaderPath Path to the vertex shader.
 * @param fragShaderPath Path to the fragment shader.
 * @return The creation step that failed or 0 on success.
 */
+ (int)makeProgram:(GLuint *)program withVertShader: (NSString *)vertShaderPath andFragShader: (NSString *)fragShaderPath;

@end
