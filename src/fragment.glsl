/*fragment.glsl*/

uniform sampler2D tDiffuse; /*表示される画像*/
uniform vec2 u_resolution;
uniform float time;

uniform float uStep;
//
uniform float uStepA;
//
uniform sampler2D tDisplament; /*表示される画像*/
uniform float uStepB;
//
uniform float uStepC;

varying vec2 vUv;

//////////////////////////////////////////////////
//　カメラシェイク

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

	// グリッチ
	vec2 st = uv; 
	float sinv = sin(st.y * 1.5 + time * 1.0);
	float steped = 1.0 - step(0.99, sinv * sinv);
	
	// タイミングを制御 
	float timeFrac = step(0.8, fract(time)) * steped;

	// ブロック抜け	
    st *= vec2(st.x * 25.0, st.y * 40.0); 
    vec2 ipos = floor(st);  // get the integer coords
	vec4 blockcolor = vec4(vec3(hash( ipos ) + uStep), 1.0);
	float NoiseBlock = step(0.98, blockcolor.r);

	// ライトリーク
	vec4 dispMask =  texture2D(tDisplament, vUv) * 1.8;
	vec3 col = vec3(uv.x, uv.y, 1.0);

	//　カメラシェイク
	vec2 camerashake = vec2( 10.0 ) * vec2(  noise( vec2(time) ) - 0.5,  noise(vec2(time * 2.0)) - 0.5  ) / u_resolution;

	//vec4 bg_color =  texture2D(tDiffuse, uv + camerashake*uStepA);
	float R = texture2D(tDiffuse, uv + camerashake*uStepA + ( vec2(-0.015 * timeFrac, 0.0) + NoiseBlock*timeFrac)*uStepC ).r;
	float G = texture2D(tDiffuse, uv + camerashake*uStepA + ( NoiseBlock * timeFrac)*uStepC ).g;
	float B = texture2D(tDiffuse, uv + camerashake*uStepA + ( vec2(0.015 * timeFrac, 0.0) + NoiseBlock*timeFrac )*uStepC).b;
	//float A = texture2D(tDiffuse, uv + vec2(0.015 * timeFrac, 0.0)*uStepC).a + texture2D(tDiffuse, uv + vec2(-0.015 * timeFrac, 0.0)*uStepC).a;
	//
	float RR = mix(R, col.r + dispMask.r*uStep*4.0, (dispMask.r + 1.1 )*uStep*uStepB );
	float GG = mix(G, col.g + dispMask.r*uStep*4.0, (dispMask.r + 1.1 )*uStep*uStepB );
	float BB = mix(B, col.b + dispMask.r*uStep*4.0, (dispMask.r + 1.1 )*uStep*uStepB );

	////////////////////////////////////////////////////////////////////////////////////////
	// 出力
	gl_FragColor = vec4(RR,GG,BB, 1.0);

}