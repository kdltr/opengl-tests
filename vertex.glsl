#version 330 core
layout (location = 0) in vec3 inPosition;
layout (location = 1) in vec3 inColor;
layout (location = 2) in vec2 inTexCoord;

out vec3 fragColor;
out vec2 texCoord;

uniform vec3 offset;

void main()
{
    gl_Position = vec4(inPosition + offset, 1.0f);
    fragColor = inColor;
    texCoord = inTexCoord;
}
