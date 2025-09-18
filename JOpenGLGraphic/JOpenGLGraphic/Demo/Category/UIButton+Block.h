//
//  UIButton+block.h
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JTouchButtonBlock)(NSInteger tag);

@interface UIButton (Block)

-(void)addTouchActionBlock:(JTouchButtonBlock)block;

@end

NS_ASSUME_NONNULL_END
