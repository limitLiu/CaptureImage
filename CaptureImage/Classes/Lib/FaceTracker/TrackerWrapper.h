//
//  TrackerWrapper.h
//  CaptureImage
//
//  Created by limit on 2022/6/26.
//

#import <UIKit/UIKit.h>
#import <simd/simd.h>
#import <CoreVideo/CoreVideo.h>
#import "LLYUV.h"

typedef struct {
  simd_float4 position;
  simd_float2 uv;
} LLVertex;

typedef struct {
  matrix_float3x3 mat;
  vector_float3 offset;
} LLMatrix;

typedef void(^Callback)(LLYUVFrame * _Nullable);

NS_ASSUME_NONNULL_BEGIN

@interface TrackerWrapper : NSObject

@property(nonatomic, assign, getter=isDraw) BOOL draw;

- (instancetype)initWithPath:(NSString *)path;

- (void)track:(CVPixelBufferRef)pixelBuffer :(BOOL)isFront :(Callback)callback;

- (void)trackImage:(UIImage *)image :(Callback)callback;

- (float)scale;

- (CGPoint)position;

@end

NS_ASSUME_NONNULL_END
