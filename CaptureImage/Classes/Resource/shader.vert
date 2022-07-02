attribute vec4 position;
attribute vec2 texcoord;
uniform mat4 mvpMat;
varying vec2 vTexcoord;
void main() {
  gl_Position = mvpMat * position;
  vTexcoord = texcoord.xy;
}
