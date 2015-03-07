precision mediump float;

attribute vec4 position;
uniform vec2 mazeIndices;
uniform vec2 translation;

uniform float aspectRatio;
uniform bool isInPortrait;
uniform float scaleFactor;
uniform float stepFactor;
void main()
{
    vec4 positionOut = position;
    
    // Rotate by 90 degrees counterclockwise about x axis
    // y' = y * cos(alpha) + z * sin(alpha) = 0 - z = -z
    // z' = z * cos(alpha) - y * sin(alpha = 0 + y = y
    positionOut.y = -position.z;
    positionOut.z = position.y;
    
    if(isInPortrait)
    {
        positionOut.y *= aspectRatio;
        
        // Scale everything to fit on the screen
        positionOut.y *= scaleFactor;
        positionOut.z *= scaleFactor;
        positionOut.x *= scaleFactor;
        
        // Translate the vertex to its appropriate spot such that the map is centred on the screen
        positionOut.y += (mazeIndices.y + translation.y) * (scaleFactor * aspectRatio);
        positionOut.x += (mazeIndices.x + translation.x) * scaleFactor;
    }
    else
    {
        positionOut.x /= aspectRatio;
        
        // Scale everything to fit on the screen
        positionOut.y *= scaleFactor;
        positionOut.z *= scaleFactor;
        positionOut.x *= scaleFactor;
        
        // Translate the vertex to its appropriate spot such that the map is centred on the screen
        positionOut.y += (mazeIndices.y + translation.y) * scaleFactor;
        positionOut.x += (mazeIndices.x + translation.x) * (scaleFactor / aspectRatio);
    }
    
    gl_Position = positionOut;
}
