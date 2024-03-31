/////////////////////////////////////////////////////////////////////////
///// IMPORT
import './style.css'

// Three.js関連
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import Stats from "three/examples/jsm/libs/stats.module";
import GUI, { FunctionController } from 'lil-gui';
//
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from "three/examples/jsm/postprocessing/RenderPass";
import { ShaderPass } from './ShaderPass.js';

import Vertex from "./vertex.glsl";
//import c_Fragment from "./fragment_CameraShake.glsl"; //単体 CameraShake
//import l_Fragment from "./fragment_LightLeak.glsl"; // 単体 LightLeak
//import g_Fragment from "./fragment_Glitch.glsl"; // 単体 Glitch
import Fragment from "./fragment.glsl"; // 3つまとめ

const gui = new GUI({width:180});
gui.domElement.id = 'gui';
gui.close();

window.onload = function(){

/////////////////////////////////////////////////////////////////////////
///// 
///// THREE.JS
///// 
///// 
/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
///// SCENE CREATION

const scene = new THREE.Scene()
scene.background = new THREE.Color('#eee');

/////////////////////////////////////////////////////////////////////////
///// RENDERER CONFIG

let PixelRation = 1; //PixelRatio
PixelRation = Math.min(window.devicePixelRatio, 2.0);

const renderer = new THREE.WebGLRenderer({
  canvas:document.getElementById("MyCanvas"),
  alpha:true,
  antialias: true,
});
renderer.setPixelRatio(PixelRation) //Set PixelRatio
renderer.setSize(window.innerWidth, window.innerHeight) // Make it FullScreen

/////////////////////////////////////////////////////////////////////////
// STATS SET

const stats = new Stats();
stats
stats.showPanel(0); // 0: fps, 1: ms, 2: mb, 3+: custom
document.body.appendChild(stats.dom);
Object.assign(stats.dom.style, {'position': 'fixed','height': 'max-content',
  'left': '0','right': 'auto',
  'top': 'auto','bottom': '0'
});

/////////////////////////////////////////////////////////////////////////
///// CAMERAS CONFIG

const camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 1000)
camera.position.set(0.0, 0.0, 100.0);
scene.add(camera)

/////////////////////////////////////////////////////////////////////////
///// CREATE ORBIT CONTROLS

const controls = new OrbitControls(camera, renderer.domElement)

/////////////////////////////////////////////////////////////////////////
///// CREATE HELPER

const size = 200;
const divisions = 40;

const gridHelperA = new THREE.GridHelper( size, divisions, "#bbbbbb", "#cccccc" );
gridHelperA.position.set(0.0, 0.0, -25);
gridHelperA.rotation.x = Math.PI/2
gridHelperA.visible = true;
scene.add( gridHelperA );

const axesHelper = new THREE.AxesHelper(5);
axesHelper.visible = true;
axesHelper.position.set(0.0, 0.0, -25);
scene.add(axesHelper);

// Cube
const geometry = new THREE.BoxGeometry( 25, 25, 25 ); 
const material = new THREE.MeshBasicMaterial( {
  color: 0xeeeeee,
} ); 
const cube = new THREE.Mesh( geometry, material ); 
cube.scale.set(0.999,0.999,0.999);
scene.add( cube );

const edges = new THREE.EdgesGeometry( geometry ); 
const line = new THREE.LineSegments(edges, new THREE.LineBasicMaterial( { color: 0x0000ee,linewidth: 2, } ) ); 
scene.add( line );

/////////////////////////////////////////////////////////////////////////
///// OBJECT

const effectComposer = new EffectComposer( renderer );
//
effectComposer.addPass(new RenderPass(scene, camera));
effectComposer.setPixelRatio(Math.min(window.devicePixelRatio, 2.0));
effectComposer.setSize( window.innerWidth, window.innerHeight );

//１）My PostProcessing Shader
const PostProcessingShader = {
  uniforms: {
    tDiffuse: { type:"t", value:null },
    u_resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight)},
    time: { value: 0.0 },
    uStep: { value: 0.0 },
    uStepA: { value: 0.0 },
    uStepB: { value: 0.0 },
    uStepC: { value: 0.0 },
    tDisplament: { type:"t", value: null }, // ライトリーク用のマスク画像
  },
  vertexShader: Vertex,
  fragmentShader: Fragment, // Fragment,　CameraShake:c_Fragment,　lightLeak:l_Fragment,　Glitch:g_Fragment
};
const MyEffectPass = new ShaderPass(PostProcessingShader);
effectComposer.addPass(MyEffectPass);

// ライトリーク用ディスプイメイト画像の更新
const displament = new THREE.TextureLoader().load("LightLeak.png", function(texture){
  MyEffectPass.material.uniforms.tDisplament.value = texture;
})
displament.wrapS = displament.wrapT = THREE.ClampToEdgeWrapping;


/////////////////////////////////////////////////////////////////////////
//// RENDER LOOP FUNCTION

const clock = new THREE.Clock();

function renderLoop() {
    stats.begin();//STATS計測
    //const delta = clock.getDelta();//animation programs
    const elapsedTime = clock.getElapsedTime();

    line.rotation.set(elapsedTime, 0, elapsedTime)
    cube.rotation.set(elapsedTime, 0, elapsedTime)

    //renderer.render(scene, camera) // render the scene using the camera
    effectComposer.render();

    requestAnimationFrame(renderLoop) //loop the render function
    stats.end();//stats計測
}

renderLoop() //start rendering

/////////////////////////////////////////////////////////////////////////
///// MAKE EXPERIENCE FULL SCREEN

window.addEventListener('resize', () => {
  const pixel = Math.min(window.devicePixelRatio, 2.0);
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  //
  renderer.setPixelRatio(pixel) //set pixel ratio
  renderer.setSize(window.innerWidth, window.innerHeight) // make it full screen  
  //
  effectComposer.setPixelRatio(pixel);//負荷軽減
  effectComposer.setSize(window.innerWidth, window.innerHeight);
})

/////////////////////////////////////////////////////////////////////////
///// STATS SETTING

const params = {						  
  myVisibleBoolean1: true,
  myVisibleBoolean2: false,
  myVisibleBoolean3: false,
  myVisibleBoolean4: false,
  myVisibleBoolean5: false,
  valueA: 0.0, //
  valueB: 0.0, //
};
	
gui.add( params, 'myVisibleBoolean1').name('helper').listen()
.listen().onChange( function( value ) { 
  if( value == true ){
    gridHelperA.visible = value;
    axesHelper.visible = value;
  }else{
    gridHelperA.visible = value;
    axesHelper.visible = value;
  }
});


gui.add( params, 'myVisibleBoolean2' ).name('CameraShake').listen().listen().onChange( function( value ) { 
  if( value == true ){
    MyEffectPass.material.uniforms.uStepA.value = 1.0;
  }else{
    MyEffectPass.material.uniforms.uStepA.value = 0.0;
  }
});

gui.add( params, 'myVisibleBoolean3' ).name('LightLeak').listen().listen().onChange(function( value ) { 
  if( value == true ){
    MyEffectPass.material.uniforms.uStepB.value = 1.0;
  }else{
    MyEffectPass.material.uniforms.uStepB.value = 0.0;
  }
});

gui.add( params, 'valueA', 0.0, 1.0 ).step( 0.01 ).name('LightLeak_value').listen().listen().onChange( function( value ) { 
  MyEffectPass.material.uniforms.uStep.value = value;
});

gui.add( params, 'myVisibleBoolean4' ).name('Glitch').listen().listen().onChange( function( value ) { 
  if( value == true ){
    MyEffectPass.material.uniforms.uStepC.value = 1.0;
  }else{
    MyEffectPass.material.uniforms.uStepC.value = 0.0;
  }
});


}//End Windows.onload