/*fragment.glsl*/
uniform sampler2D tDiffuse; /*表示される画像*/
uniform sampler2D tDisplament; /*表示される画像*/
uniform float time;
uniform float uStep;
uniform float uStepB;
varying vec2 vUv;

void main() {

 	vec2 uv = vUv;
	vec4 bg_color =  texture2D(tDiffuse, uv);

	// カラー
	vec3 col = vec3(uv.x, uv.y, 1.0);
	// マスクの画像マップ
	vec4 dispMask =  texture2D(tDisplament, uv);

	float R = mix(bg_color.r, col.r + dispMask.r*uStep*4.0, (dispMask.r + 1.1 )*uStep );
	float G = mix(bg_color.g, col.g + dispMask.r*uStep*4.0, (dispMask.r + 1.1 )*uStep );
	float B = mix(bg_color.b, col.b + dispMask.r*uStep*4.0, (dispMask.r + 1.1 )*uStep );
	////////////////////////////////////////////////////////////////////////////////////////
	// 出力
	gl_FragColor = vec4(R,G,B, 1.0);
}