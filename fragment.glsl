#version 330 core
in vec3 fragPosition;
in vec3 normal;
out vec4 color;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPosition;
uniform vec3 viewerPosition;

void main()
{
  // Ambiant lighting
  float ambiantStrength = 0.1f;
  vec3 ambiant = ambiantStrength * lightColor;

  // Diffuse lighting
  vec3 norm = normalize(normal);
  vec3 lightDirection = normalize(lightPosition - fragPosition);
  float diff = max(dot(norm, lightDirection), 0);
  vec3 diffuse = lightColor * diff;

  // Specular lighting
  float specularStrength = 0.5f;
  vec3 viewDirection = normalize(viewerPosition - fragPosition);
  vec3 reflectDirection = reflect(-lightDirection, norm);
  float spec = pow(max(dot(viewDirection, reflectDirection), 0.0), 32);
  vec3 specular = specularStrength * spec * lightColor;

  vec3 result = (ambiant + diffuse + specular) * objectColor;
  color = vec4(result, 1.0f);
}
