//
//  UIView+Block.m
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/18.
//

#import "UIView+Block.h"
#import <objc/runtime.h>

static const void *jGestureBlockKey = &jGestureBlockKey;

@implementation UIView (Block)

-(void)addGestureBlock:(JGestureBlock)block{
    objc_setAssociatedObject(self, jGestureBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:gestureRecognizer];
}

-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer{
    JGestureBlock block = objc_getAssociatedObject(self, jGestureBlockKey);
    if(block){
        block(gestureRecognizer);
    }
}

@end
