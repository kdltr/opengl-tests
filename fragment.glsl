#version 330 core
in vec3 fragColor;
in vec2 texCoord;

out vec4 color;

uniform float mixFactor;
uniform sampler2D woodTexture;
uniform sampler2D smileTexture;

void main()
{
    color = mix(texture(woodTexture, texCoord), texture(smileTexture, texCoord), mixFactor);
}
