//
//  GLView.h
//  LLPlayer
//
//  Created by limit on 2022/6/19.
//

#import <UIKit/UIKit.h>
#import "LLYUV.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLRenderer : NSObject

@end

@interface GLView : UIView

@property(nonatomic, assign) NSInteger videoWidth;
@property(nonatomic, assign) NSInteger videoHeight;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)render:(LLYUVFrame * _Nullable)frame;

@end

NS_ASSUME_NONNULL_END
