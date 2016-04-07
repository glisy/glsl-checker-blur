#version 400
precision mediump float;

uniform float iGlobalTime;
uniform vec3 iResolution;
out vec4 fragColor;

vec3 sampler(vec2 uv);

#define ITERATIONS 40

#pragma glslify: checker = require('glsl-checker')
#pragma glslify: blur = require('glsl-hash-blur', sample=sampler, iterations=ITERATIONS)

vec3 sampler(vec2 uv) {
  return vec3(checker(uv, 15.0));
}

void main() {
  vec3 color = vec3(0.0);

  float texelSize = 1.0 / iResolution.x;
  float aspect = iResolution.x / iResolution.y;

  vec2 q = vec2(gl_FragCoord.xy / iResolution.xy);

  float anim = sin(iGlobalTime)/2.0+0.5;
  float strength = mix(20.0, 50.0, anim) * texelSize;

  //vignette blur
  float radius = length(q - 0.5);
  radius = smoothstep(0.0, 1.6, radius) * strength;

  //jitter the noise but not every frame
  float tick = floor(fract(iGlobalTime)*20.0);
  float jitter = mod(tick * 382.0231, 21.321);

  //apply blur
  vec2 uv = q * vec2(aspect, 1.0);
  vec3 tex = blur(uv, radius, aspect, jitter);
  fragColor = vec4(tex, 1.0);
}
