#version 120

#ifdef GL_ES
precision highp float;
#endif

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uImage0;

uniform float speed;
uniform float density;
uniform float scale;

varying vec2 vTexCoord;

void main(void) {
	vec2 uv = vTexCoord.xy;

	vec2 dt;
	dt.x = sin(speed*uTime+uv.y*density)*0.001*scale;
	dt.y = cos(0.7+0.7*speed*uTime+uv.x*density)*0.001*scale;

	gl_FragColor = texture2D(uImage0, uv+dt);
}
