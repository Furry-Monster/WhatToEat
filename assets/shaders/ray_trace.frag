#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uMouse;

out vec4 fragColor;

// 噪声函数
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// 分形布朗运动
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 3.0;
    
    for(int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// 流体动画
vec3 fluidAnimation(vec2 uv, vec2 mouse) {
    float t = uTime * 0.3;
    vec2 p = uv;
    
    // 鼠标交互波纹
    float mouseInfluence = exp(-length(p - mouse) * 3.0);
    p += mouseInfluence * vec2(cos(t), sin(t)) * 0.1;
    
    // 多层流体效果
    float fluid1 = fbm(p + t);
    float fluid2 = fbm(p - t * 0.5);
    
    // 动态颜色
    vec3 col1 = vec3(0.1, 0.5, 0.9); // 蓝色
    vec3 col2 = vec3(0.0, 0.8, 0.6); // 青色
    vec3 col3 = vec3(0.6, 0.2, 0.9); // 紫色
    
    vec3 color = mix(col1, col2, fluid1);
    color = mix(color, col3, fluid2);
    
    // 光晕效果
    float glow = exp(-length(p) * 2.0) * 0.5;
    color += vec3(0.2, 0.4, 1.0) * glow;
    
    // 动态波纹
    float ripple = sin(length(p) * 20.0 - t * 5.0) * 0.1;
    color += ripple;
    
    return color;
}

void main() {
    vec2 uv = (FlutterFragCoord().xy - uResolution.xy * 0.5) / min(uResolution.x, uResolution.y);
    vec2 mouse = (uMouse - uResolution.xy * 0.5) / min(uResolution.x, uResolution.y);
    
    // 生成流体效果
    vec3 color = fluidAnimation(uv, mouse);
    
    // 添加闪光点
    float sparkle = pow(noise(uv * 50.0 + uTime), 20.0) * 0.8;
    color += vec3(sparkle);
    
    // 边缘渐变
    float vignette = 1.0 - length(uv) * 0.7;
    color *= vignette;
    
    // 整体亮度
    color *= 1.2;
    
    fragColor = vec4(color, 1.0);
} 