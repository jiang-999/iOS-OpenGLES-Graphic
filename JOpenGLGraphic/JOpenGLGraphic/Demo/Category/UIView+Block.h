//
//  UIView+Block.h
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JGestureBlock)(UIGestureRecognizer *gestureRecognizer);

@interface UIView (Block)

-(void)addGestureBlock:(JGestureBlock)block;

@end

NS_ASSUME_NONNULL_END
