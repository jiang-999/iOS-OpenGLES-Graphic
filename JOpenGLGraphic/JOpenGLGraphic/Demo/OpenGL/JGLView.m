//
//  JGLView.m
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/17.
//

#import "JGLView.h"
#include <OpenGLES/ES3/gl.h>
#import "JGLESUtils.h"

//点数组
GLfloat pointVertices[] = {
    -0.5f,0.5f,0.0f,
    0.5f,0.5f,0.0f,
    -0.5f,0.0f,0.0f,
    0.5f,0.0f,0.0f
};

//线数组
GLfloat lineVertices[] = {
    -0.5f,0.5f,0.0f,
    0.5f,0.5f,0.0f,
    0.5f,0.0f,0.0f,
    -0.5f,0.0f,0.0f
};

//三角形数组
GLfloat triangleVertices[] = {
    -0.5f,0.5f,0.0f,
    0.5f,0.5f,0.0f,
    -0.5f,0.0f,0.0f,
    0.5f,0.0f,0.0f
};

@interface JGLView ()
{
    EAGLContext *_context;//上下文
    CAEAGLLayer *_eaglLayer;//图层
    GLuint _renderBuffer;//渲染缓冲区
    GLuint _frameBuffer;//桢缓冲区
    
    GLuint _program;//program ID
    GLuint _positionShot;//属性位置
}

@end

@implementation JGLView

+(Class)layerClass{
    //只有CAEAGLLayer类型的layer才支持在其上绘制OpenGL内容
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame: frame]){
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(![EAGLContext setCurrentContext:_context]){
        _context = nil;
        NSLog(@"设置当前context失败");
    }
    [self destoryBuffers];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
}

-(void)dealloc{
    [self destoryBuffers];
    if([EAGLContext currentContext] == _context){
        [EAGLContext setCurrentContext:nil];
    }
}

/// 设置图层
-(void)setupLayer{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;//提供性能
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
}


/// 设置上下文
-(void)setupContext{
    //指定OpenGL渲染API的版本
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if(!_context){
        NSLog(@"初始化context失败");
        return;
    }
    //设置上下文
    if(![EAGLContext setCurrentContext:_context]){
        _context = nil;
        NSLog(@"设置当前context失败");
    }
}

//渲染缓冲区
-(void)setupRenderBuffer{
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    //为 color renderbuffer分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

//桢缓冲区
-(void)setupFrameBuffer{
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //将renderbuffer装配到GL_COLOR_ATTACHMENT0附着点
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}


-(void)setupProgram{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    _program = [JGLESUtils loadProgram:vertexShaderPath withFragmentShaderFilepath:fragmentShaderPath];
    if(_program == 0){
        NSLog(@"Failed to setup program.");
        return;
    }
    glUseProgram(_program);
    _positionShot = glGetAttribLocation(_program, "vPosition");
}

-(void)render{
    //设置清屏颜色，默认是黑色
    glClearColor(0.3, 0.5, 0.9, 1.0);
    //指定清除的buffer,可以设置GL_COLOR_BUFFER_BIT,GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    switch (self.type){
        case JGLView_Point:[self renderWithVertices:pointVertices mode:GL_POINTS count:4];break;
        case JGLView_Lines:[self renderWithVertices:lineVertices mode:GL_LINES count:4];break;
        case JGLView_Line_Strip:[self renderWithVertices:lineVertices mode:GL_LINE_STRIP count:4];break;
        case JGLView_Line_Loop:[self renderWithVertices:lineVertices mode:GL_LINE_LOOP count:4];break;
        case JGLView_Triangle:[self renderWithVertices:triangleVertices mode:GL_TRIANGLES count:4];break;
        case JGLView_Triangle_Strip:[self renderWithVertices:triangleVertices mode:GL_TRIANGLE_STRIP count:4];break;
        case JGLView_Triangle_Loop:[self renderWithVertices:triangleVertices mode:JGLView_Triangle_Loop count:4];break;
        default:NSLog(@"other type");
    }
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)renderWithVertices:(const GLvoid*)vertices mode:(GLenum)mode count:(GLsizei)count{
    glVertexAttribPointer(_positionShot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionShot);
    glDrawArrays(mode, 0, count);
}

- (void)destoryBuffers{
    if(_renderBuffer){
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if(_frameBuffer){
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

-(void)setType:(JGLViewDrawType)type{
    if(_type != type){
        _type = type;
//        [self destoryBuffers];
//        [self setupRenderBuffer];
//        [self setupFrameBuffer];
        [self render];
    }
}

@end
