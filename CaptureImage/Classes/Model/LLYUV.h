//
//  LLYUV.h
//  CaptureImage
//
//  Created by limit on 2022/6/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLYUVData : NSObject

@property(nonatomic, assign) uint8_t *data;
@property(nonatomic, assign) NSInteger length;

+ (instancetype)dataWithLength:(NSInteger)length data:(uint8_t *)data;
- (instancetype)initWithLength:(NSInteger)length data:(uint8_t *)data;

@end

@interface LLYUVFrame : NSObject

@property(nonatomic, strong) LLYUVData *luma;
@property(nonatomic, strong) LLYUVData *chromaB;
@property(nonatomic, strong) LLYUVData *chromaR;
@property(nonatomic, assign) NSInteger width;
@property(nonatomic, assign) NSInteger height;

+ (instancetype)frameWithLuma:(LLYUVData *)luma chromaB:(LLYUVData *)chromaB chromaR:(LLYUVData *)chromaR width:(NSInteger)width height:(NSInteger)height;

- (instancetype)initWithLuma:(LLYUVData *)luma chromaB:(LLYUVData *)chromaB chromaR:(LLYUVData *)chromaR width:(NSInteger)width height:(NSInteger)height;

- (uint8_t *)lumaData;
- (uint8_t *)chromaBData;
- (uint8_t *)chromaRData;

@end

NS_ASSUME_NONNULL_END
