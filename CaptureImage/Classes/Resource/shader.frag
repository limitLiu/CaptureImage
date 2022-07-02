varying highp vec2 vTexcoord;
uniform sampler2D sTextureY;
uniform sampler2D sTextureU;
uniform sampler2D sTextureV;

void main() {
  highp float y = texture2D(sTextureY, vTexcoord).r;
  highp float u = texture2D(sTextureU, vTexcoord).r - 0.5;
  highp float v = texture2D(sTextureV, vTexcoord).r - 0.5;
  
  highp float r = y + 1.402 * v;
  highp float g = y - 0.344 * u - 0.714 * v;
  highp float b = y + 1.772 * u;
  
  gl_FragColor = vec4(r, g, b, 1.0);
}
