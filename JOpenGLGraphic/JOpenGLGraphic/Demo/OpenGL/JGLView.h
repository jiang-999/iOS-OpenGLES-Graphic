//
//  JGLView.h
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JGLView_Point,//点
    JGLView_Lines,//线条样式一
    JGLView_Line_Strip,//线条样式二
    JGLView_Line_Loop,//线条样式三
    JGLView_Triangle,//三角形样式一
    JGLView_Triangle_Strip,//三角形样式二
    JGLView_Triangle_Loop,//三角形样式三
    JGLView_Image,//图片
    JGLView_Cube,//绘制立方体
} JGLViewDrawType;

@interface JGLView : UIView

@property (nonatomic,assign) JGLViewDrawType type;//图元类型,点、线、三角形

@end

NS_ASSUME_NONNULL_END
