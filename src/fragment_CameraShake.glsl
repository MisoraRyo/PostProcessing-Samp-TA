/*fragment.glsl*/
uniform sampler2D tDiffuse; /*表示される画像*/
uniform vec2 u_resolution;
uniform float time;

varying vec2 vUv;

// 1D, 2D & 3D Value Noise 
// By Morgan McGuire @morgan3d, http://graphicscodex.com
// Reuse permitted under the BSD license.
// https://www.shadertoy.com/view/4dS3Wd

// Precision-adjusted variations of https://www.shadertoy.com/view/4djSRW
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
    vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}


void main() {
 	vec2 uv = vUv;

	//Camera Shake
	vec2 camerashake = vec2( 10.0 ) * vec2(  noise( vec2(time) ) - 0.5,  noise(vec2(time * 2.0)) - 0.5  ) / u_resolution;
	vec4 texcel = texture2D( tDiffuse, uv + camerashake);

	gl_FragColor = vec4(texcel);
}