precision mediump float;

attribute vec4 position;
uniform float zIndex;
uniform mat4 modelViewProjection;

void main()
{
    vec4 positionOut = modelViewProjection * position;
    positionOut.z = zIndex;
    gl_Position = positionOut;
}
