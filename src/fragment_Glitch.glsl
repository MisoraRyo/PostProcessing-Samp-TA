/*fragment.glsl*/
uniform sampler2D tDiffuse; /*表示される画像*/
uniform float time;
uniform float uStep; // time=>uStepに変更して、アニメションさせる

varying vec2 vUv;

// Precision-adjusted variations of https://www.shadertoy.com/view/4djSRW
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

void main() {

 	vec2 uv = vUv;

	// 走査線
	vec2 st = uv; 
	float sinv = sin(st.y * 1.5 + time * 1.0);
	float steped = 1.0 - step(0.99, sinv * sinv);
	
	// タイミングを制御 
	//float timeFrac = steped * step(0.8, fract(time));
	float timeFrac = step(0.8, fract(time)) * steped;

	// ブロック抜け	
	//vec2 st = uv;
    st *= vec2(st.x * 25.0, st.y * 40.0); 
    vec2 ipos = floor(st);  // get the integer coords
	vec4 blockcolor = vec4(vec3(hash( ipos ) + uStep), 1.0);
	float NoiseBlock = step(0.98, blockcolor.r);

	//色収差
	float R = texture2D(tDiffuse, uv + vec2(-0.015 * timeFrac, 0.0) + NoiseBlock * timeFrac ).r;
	float G = texture2D(tDiffuse, uv + vec2(0.0, 0.0) + NoiseBlock * timeFrac).g;
	float B = texture2D(tDiffuse, uv + vec2(0.015 * timeFrac, 0.0) + NoiseBlock * timeFrac ).b;
	//float A = texture2D(tDiffuse, uv + vec2(0.015 * timeFrac, 0.0) + NoiseBlock ).a + texture2D(tDiffuse, uv + vec2(-0.015 * timeFrac, 0.0) + NoiseBlock).a;

	////////////////////////////////////////////////////////////////////////////////////////
	// 出力
	gl_FragColor = vec4(R,G,B, 1.0);
}