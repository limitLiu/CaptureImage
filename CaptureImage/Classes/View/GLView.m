//
//  GLView.m
//  LLPlayer
//
//  Created by limit on 2022/6/19.
//

#import "GLView.h"
#import <GLKit/GLKit.h>

enum {
  AttributeVertex,
  AttributeTexcoord,
};

@interface LLRenderer () {
  GLint _location[3];
  GLuint _textures[3];
}

@end

@implementation LLRenderer

- (BOOL)isValid {
  return _textures[0] != 0;
}

- (void)resolve:(GLuint)program {
  _location[0] = glGetUniformLocation(program, "sTextureY");
  _location[1] = glGetUniformLocation(program, "sTextureU");
  _location[2] = glGetUniformLocation(program, "sTextureV");
}

- (void)updateFrame:(LLYUVFrame *)frame {
  if (!frame) {
    return;
  }
  
  const int width = (int) frame.width;
  const int height = (int) frame.height;
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  if (0 == _textures[0]) {
    glGenTextures(3, _textures);
  }
  
  const UInt8 *pixels[3] = {
    frame.lumaData, frame.chromaBData, frame.chromaRData,
  };
  
  const int widths[3] = {
    width,
    width / 2,
    width / 2,
  };
  const int heights[3] = {
    height,
    height / 2,
    height / 2,
  };
  
  for (int i = 0; i < 3; ++i) {
    glBindTexture(GL_TEXTURE_2D, _textures[i]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, widths[i], heights[i], 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels[i]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  }
}

- (BOOL)prepareRender {
  if (_textures[0] == 0) {
    return NO;
  }
  
  for (int i = 0; i < 3; ++i) {
    glActiveTexture(GL_TEXTURE0 + i);
    glBindTexture(GL_TEXTURE_2D, _textures[i]);
    glUniform1i(_location[i], i);
  }
  return YES;
}

- (void)dealloc {
  if (_textures[0]) {
    glDeleteTextures(3, _textures);
  }
}

@end

@interface GLView () {
  GLfloat _vertices[8];
}

@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic, assign) GLuint frameBuffer;
@property(nonatomic, assign) GLuint renderBuffer;
@property(nonatomic, assign) GLint width;
@property(nonatomic, assign) GLint height;
@property(nonatomic, assign) GLuint program;
@property(nonatomic, assign) GLint uniformMatrix;
@property(nonatomic, assign) CGPoint point;
@property(nonatomic, strong) LLRenderer *renderer;
@property(nonatomic, assign) BOOL initialized;

@end

@implementation GLView

+ (Class)layerClass {
  return CAEAGLLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _renderer = LLRenderer.new;
    self.contentScaleFactor = UIScreen.mainScreen.scale;
  }
  return self;
}

- (BOOL)shaders {
  BOOL result = NO;
  GLuint vertexShader = 0, fragmentShader = 0;
  _program = glCreateProgram();
  NSString *path = [NSBundle.mainBundle pathForResource:@"shader" ofType:@"vert"];
  NSString *vertexShaderStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  vertexShader = compile(GL_VERTEX_SHADER, vertexShaderStr);
  if (!vertexShader) {
    glDeleteShader(vertexShader);
    return NO;
  }
  NSString *fragPath = [NSBundle.mainBundle pathForResource:@"shader" ofType:@"frag"];
  NSString *yuvFragmentShaderStr = [NSString stringWithContentsOfFile:fragPath encoding:NSUTF8StringEncoding error:nil];
  fragmentShader = compile(GL_FRAGMENT_SHADER, yuvFragmentShaderStr);
  if (!fragmentShader) {
    glDeleteShader(fragmentShader);
    return NO;
  }
  glAttachShader(_program, vertexShader);
  glAttachShader(_program, fragmentShader);
  glBindAttribLocation(_program, AttributeVertex, "position");
  glBindAttribLocation(_program, AttributeTexcoord, "texcoord");
  
  glLinkProgram(_program);
  GLint status;
  glGetProgramiv(_program, GL_LINK_STATUS, &status);
  if (status == GL_FALSE) {
    NSLog(@"Failed to link program %d", _program);
    
    glDeleteProgram(_program);
    _program = 0;
    return NO;
  }
  result = validate(_program);
  _uniformMatrix = glGetUniformLocation(_program, "mvpMat");
  [_renderer resolve:_program];
  
  return result;
}

- (void)dealloc {
  if (_frameBuffer) {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
  }
  
  if (_renderBuffer) {
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
  }
  if (_program) {
    glDeleteProgram(_program);
    _program = 0;
  }
  
  if (EAGLContext.currentContext == _context) {
    EAGLContext.currentContext = nil;
    _context = nil;
  }
}

- (void)render:(LLYUVFrame * _Nullable)frame {
  static const GLfloat texCoordArray[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
  };
  if (!EAGLContext.currentContext) {
    [EAGLContext setCurrentContext:_context];
  }
  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glViewport(0, 0, _width, _height);
  glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  glUseProgram(_program);
  [_renderer updateFrame:frame];
  if ([_renderer prepareRender]) {
    GLKMatrix4 modelViewProjective = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
    glUniformMatrix4fv(_uniformMatrix, 1, GL_FALSE, modelViewProjective.m);
    glVertexAttribPointer(AttributeVertex, 2, GL_FLOAT, 0, 0, _vertices);
    glEnableVertexAttribArray(AttributeVertex);
    glVertexAttribPointer(AttributeTexcoord, 2, GL_FLOAT, 0, 0, texCoordArray);
    glEnableVertexAttribArray(AttributeTexcoord);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  }
  glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
  [_context presentRenderbuffer:GL_RENDERBUFFER];
}

static GLuint compile(GLenum type, NSString *shaderStr) {
  GLint status;
  const GLchar *source = shaderStr.UTF8String;
  GLuint shader = glCreateShader(type);
  if (shader == 0 || shader == GL_INVALID_ENUM) {
    NSLog(@"Failed to create shader %d", type);
    return 0;
  }
  
  glShaderSource(shader, 1, &source, NULL);
  glCompileShader(shader);
  glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
  if (status == GL_FALSE) {
    glDeleteShader(shader);
    NSLog(@"Failed to compile shader.");
    return 0;
  }
  return shader;
}

static BOOL validate(GLuint programe) {
  GLint status;
  glValidateProgram(programe);
  glGetProgramiv(programe, GL_VALIDATE_STATUS, &status);
  if (status == GL_FALSE) {
    NSLog(@"Failed to validate program %d", programe);
    return NO;
  }
  return YES;
}

- (BOOL)setup {
  CAEAGLLayer *layer = (CAEAGLLayer *) self.layer;
  layer.opaque = YES;
  layer.drawableProperties = @{
    kEAGLDrawablePropertyRetainedBacking: @(YES),
    kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
  };
  _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  if (!_context || ![EAGLContext setCurrentContext:_context]) {
    NSLog(@"Failed to setup EAGLContext.");
    return NO;
  }
  glGenFramebuffers(1, &_frameBuffer);
  glGenRenderbuffers(1, &_renderBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *) self.layer];
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if (status != GL_FRAMEBUFFER_COMPLETE) {
    NSLog(@"Failed to make FBO.");
    return NO;
  }
  GLenum error = glGetError();
  if (GL_NO_ERROR != error) {
    NSLog(@"Failed to setup gl %x\n", error);
    return NO;
  }
  
  if (![self shaders]) {
    return NO;
  }
  _vertices[0] = -1.0f;
  _vertices[1] = -1.0f;
  _vertices[2] =  1.0f;
  _vertices[3] = -1.0f;
  _vertices[4] = -1.0f;
  _vertices[5] =  1.0f;
  _vertices[6] =  1.0f;
  _vertices[7] =  1.0f;
  return YES;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!self.initialized) {
    _videoWidth = self.frame.size.width;
    _videoHeight = self.frame.size.height;
    self.initialized = [self setup];
  }
}

- (void)setContentMode:(UIViewContentMode)contentMode {
  [super setContentMode:contentMode];
  [self fit];
  if (self.renderer.isValid) {
    [self render:nil];
  }
}

- (void)fit {
  const BOOL fit = self.contentMode == UIViewContentModeScaleAspectFit;
  if (!fit) {
    self.videoWidth = self.frame.size.width;
    self.videoHeight = self.frame.size.height;
  }
  const GLfloat width = self.width / self.videoWidth;
  const GLfloat height = self.height / self.videoHeight;
  const float fitted = fit ? MIN(height, width) : MAX(height, width);
  const float w = self.videoWidth * fitted / self.width;
  const float h = self.videoHeight * fitted / self.height;
  GLfloat vertices[8] = {
    -w, -h, w, -h,
    -w,  h, w,  h
  };
  memcpy(_vertices, vertices, sizeof(_vertices));
}

@end
