#version 430

layout (location=0) in vec3 vertexPosition;

layout (location=0) uniform mat4 projMat;
layout (location=1) uniform mat4 viewMat;

layout(std430, binding=0) buffer ssboP { vec4 positions[]; };
layout(std430, binding=1) buffer ssboV { vec4 velocities[]; };

out vec4 fragColor;

void main() {
    vec3 vel = velocities[gl_InstanceID].xyz;
    vec3 pos = positions[gl_InstanceID].xyz;

    fragColor = vec4(abs(normalize(vel)) + 0.2, 1.0);

    const float scale = 0.08;
    vec3 vertexView = vertexPosition*scale;

    // compute the angle of the velocity in view space
    const vec2 velocityView = (viewMat * vec4(vel, 0.0)).xy;
    const float speed = length(velocityView);

    // triangle's tip currently at 90 degrees in view space,
    // to make it point to velocityAngle rotate by 90 degrees backwards
    float velocityAngle = atan(velocityView.y, velocityView.x);

    // clockwise rotation
    velocityAngle -= radians(90);
    const float cr = cos(velocityAngle), sr = sin(velocityAngle);
    vertexView.xy = vertexView.x * vec2(cr, sr) + vertexView.y* vec2(-sr, cr);

    // scale the tip
    const float isTip = float(2 == gl_VertexID);
    const float arrowLength = speed * 8.0;
    vertexView.xy = vertexView.xy * (1.0 - isTip) + isTip * vertexView.xy * (arrowLength + 1.0);

    // add particle position to the vertex in view space
    vertexView += (viewMat * vec4(pos, 1.0)).xyz;

    // final vertex position
    gl_Position = projMat * vec4(vertexView, 1.0);
}