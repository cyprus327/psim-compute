#version 430

// largest size gauranteed by opengl is 1024
layout (local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

// ssbos have 128mb max so separate ssbos instead of struct
layout (std430, binding=0) buffer ssboP { vec4 positions[]; };
layout (std430, binding=1) buffer ssboV { vec4 velocities[]; };

layout (location=0) uniform float deltaTime;
layout (location=1) uniform float mult;
layout (location=2) uniform vec3 attractor;
layout (location=3) uniform int freeze;

void main() {
    if (0 != freeze) {
        return;
    }

    const uint ind = gl_GlobalInvocationID.x;
    vec3 pos = positions[ind].xyz;
    vec3 vel = velocities[ind].xyz;

    // dist from particle to attractor
    const float dx = pos.x - attractor.x;
    const float dy = pos.y - attractor.y;
    const float dz = pos.z - attractor.z;
    float dist = sqrt(dx * dx + dy * dy + dz * dz);

    // compute normal without modifying original dist
    const float dist2 = (0.0 == dist) ? 1.0 : 1.0 / dist;
    const vec3 norm = vec3(dx * dist2, dy * dist2, dz * dist2);

    dist = max(dist, 0.5);

    const float scaledMult = mult * deltaTime; 
    vel.x -= norm.x / dist * scaledMult;
    vel.y -= norm.y / dist * scaledMult;
    vel.z -= norm.z / dist * scaledMult;
    vel *= 1.0 - deltaTime;

    positions[ind] = vec4(pos + vel, 1.0);
    velocities[ind] = vec4(vel, 1.0);
}
