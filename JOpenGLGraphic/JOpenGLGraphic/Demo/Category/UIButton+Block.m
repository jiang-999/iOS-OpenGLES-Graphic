//
//  UIButton+block.m
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/18.
//

#import "UIButton+Block.h"
#import <objc/runtime.h>

static const void *jTouchButtonBlockKey = &jTouchButtonBlockKey;

@implementation UIButton (Block)

-(void)addTouchActionBlock:(JTouchButtonBlock)block{
    objc_setAssociatedObject(self, jTouchButtonBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)clickButton:(UIButton *)btn{
    JTouchButtonBlock block = objc_getAssociatedObject(self, jTouchButtonBlockKey);
    if(block){
        block(btn.tag);
    }
}

@end
