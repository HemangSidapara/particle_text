#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform vec2 uPointer;
uniform float uPointerRadius;
uniform float uReturnSpeed;
uniform float uFriction;
uniform float uRepelForce;
uniform sampler2D uCurrentData; // [x, y, vx, vy] as RGBA
uniform sampler2D uTargetData;  // [tx, ty, size, alpha] as RGBA

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    
    // Read current state
    vec4 current = texture(uCurrentData, uv);
    vec2 pos = current.xy;
    vec2 vel = current.zw;
    
    // Read target state
    vec4 target = texture(uTargetData, uv);
    vec2 tPos = target.xy;
    
    // 1. Spring-back logic
    vec2 springForce = (tPos - pos) * uReturnSpeed;
    vel += springForce;
    
    // 2. Pointer Repulsion
    float dist = distance(pos, uPointer);
    if (dist < uPointerRadius) {
        vec2 dir = normalize(pos - uPointer);
        float power = (1.0 - (dist / uPointerRadius)) * uRepelForce;
        vel += dir * power;
    }
    
    // 3. Friction/Damping
    vel *= uFriction;
    
    // 4. Integration
    pos += vel;
    
    // Output new state
    fragColor = vec4(pos, vel);
}
