//
//  TrackerWrapper.m
//  CaptureImage
//
//  Created by limit on 2022/6/26.
//

#import "tracker.h"
#import "UIImage+OpenCV.h"
#import "TrackerWrapper.h"

@implementation TrackerWrapper

- (instancetype)initWithPath:(NSString *)path {
  if (self = [super init]) {
    tracker_init(path.UTF8String);
  }
  return self;
}

- (void)setDraw:(BOOL)draw {
  _draw = draw;
  tracker_set_draw(_draw ? 1 : 0);
}

- (float)scale {
  return tracker_scale();
}

- (void)track:(CVPixelBufferRef)pixelBuffer :(BOOL)isFront :(Callback)callback {
  cv::Mat bgrFrame;
  CVPixelBufferLockBaseAddress(pixelBuffer, 0);
  auto address = CVPixelBufferGetBaseAddress(pixelBuffer);
  int height = (int) CVPixelBufferGetWidth(pixelBuffer);
  int width = (int) CVPixelBufferGetHeight(pixelBuffer);
  cv::Mat imageFrame = cv::Mat(width, height, CV_8UC4, address, 0);
  cv::cvtColor(imageFrame, bgrFrame, cv::COLOR_BGRA2BGR);
  cv::rotate(bgrFrame, bgrFrame, cv::ROTATE_90_CLOCKWISE);
  if (isFront) {
    cv::flip(bgrFrame, bgrFrame, 1);
  }
  tracker_track(bgrFrame);
  CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
  cv::Mat yuvFrame;
  cv::cvtColor(bgrFrame, yuvFrame, cv::COLOR_BGR2YUV_I420);
  int lumaSize = width * height;
  int chromaSize = lumaSize / 4;
  uint8_t *lumaData = yuvFrame.data;
  uint8_t *cbData = yuvFrame.data + lumaSize;
  uint8_t *crData = yuvFrame.data + lumaSize + chromaSize;
  
  auto luma = [LLYUVData dataWithLength:lumaSize data:lumaData];
  auto cb = [LLYUVData dataWithLength:chromaSize data:cbData];
  auto cr = [LLYUVData dataWithLength:chromaSize data:crData];
  auto yuv = [LLYUVFrame frameWithLuma:luma chromaB:cb chromaR:cr width:width height:height];
  
  callback(yuv);
}

- (void)trackImage:(UIImage *)image :(Callback)callback {
  int width = image.size.width;
  int height = image.size.height;
  auto mat = [image CVMat3];
  tracker_track(mat);
  cv::cvtColor(mat, mat, cv::COLOR_RGB2YUV_I420);
  int lumaSize = width * height;
  int chromaSize = lumaSize / 4;
  uint8_t *lumaData = mat.data;
  uint8_t *cbData = mat.data + lumaSize;
  uint8_t *crData = mat.data + lumaSize + chromaSize;
  
  auto luma = [LLYUVData dataWithLength:lumaSize data:lumaData];
  auto cb = [LLYUVData dataWithLength:chromaSize data:cbData];
  auto cr = [LLYUVData dataWithLength:chromaSize data:crData];
  auto yuv = [LLYUVFrame frameWithLuma:luma chromaB:cb chromaR:cr width:width height:height];
  callback(yuv);
}

- (CGPoint)position {
  auto position = tracker_position();
  return (CGPoint) { .x = position.x, .y = position.y };
}

@end
