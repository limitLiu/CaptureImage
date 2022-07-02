//
//  LLYUV.m
//  CaptureImage
//
//  Created by limit on 2022/7/2.
//

#import "LLYUV.h"

@implementation LLYUVData

+ (instancetype)dataWithLength:(NSInteger)length data:(uint8_t *)data {
  return [[self alloc] initWithLength:length data:data];
}

- (instancetype)initWithLength:(NSInteger)length data:(uint8_t *)data {
  if (self = [super init]) {
    _length = length;
    _data = data;
  }
  return self;
}

@end

@implementation LLYUVFrame

- (instancetype)initWithLuma:(LLYUVData *)luma chromaB:(LLYUVData *)chromaB chromaR:(LLYUVData *)chromaR width:(NSInteger)width height:(NSInteger)height {
  if (self = [super init]) {
    _width = width;
    _height = height;
    _luma = luma;
    _chromaB = chromaB;
    _chromaR = chromaR;
  }
  return self;
}

+ (instancetype)frameWithLuma:(LLYUVData *)luma chromaB:(LLYUVData *)chromaB chromaR:(LLYUVData *)chromaR width:(NSInteger)width height:(NSInteger)height {
  return [[self alloc] initWithLuma:luma chromaB:chromaB chromaR:chromaR width:width height:height];
}

- (uint8_t *)lumaData {
  return self.luma.data;
}

- (uint8_t *)chromaBData {
  return self.chromaB.data;
}

- (uint8_t *)chromaRData {
  return self.chromaR.data;
}

@end
