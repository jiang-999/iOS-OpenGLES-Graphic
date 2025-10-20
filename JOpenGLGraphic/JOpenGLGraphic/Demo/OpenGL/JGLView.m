//
//  JGLView.m
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/17.
//

#import "JGLView.h"
#include <OpenGLES/ES3/gl.h>
#import "JGLESUtils.h"
#import "ksMatrix.h"

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

//图片数组
GLfloat imageVertices[] = {
    -0.5f,0.5f,0.0f,0,0,
    0.5f,0.5f,0.0f,1,0,
    -0.5f,0.0f,0.0f,0,1,
    0.5f,0.0f,0.0f,1,1,
};

@interface JGLView ()
{
    EAGLContext *_context;//上下文
    CAEAGLLayer *_eaglLayer;//图层
    GLuint _renderBuffer;//渲染缓冲区
    GLuint _frameBuffer;//桢缓冲区
    
    GLuint _program;//program ID
    GLuint _positionSlot;//属性位置
    GLuint _colorMap;
    GLuint _textCoordinate;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    GLuint _colorSlot;
    
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _projectionMatrix;
    
    float _rotateColorCube;
    
    GLuint _flag;
}

@end

@implementation JGLView

+(Class)layerClass{
    //只有CAEAGLLayer类型的layer才支持在其上绘制OpenGL内容
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame: frame]){
        _rotateColorCube = 99;
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

//帧缓冲区
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
    _positionSlot = glGetAttribLocation(_program, "vPosition");
    _textCoordinate = glGetAttribLocation(_program, "textCoordinate");
    _flag = glGetUniformLocation(_program, "flag");
    _colorMap = glGetUniformLocation(_program, "colorMap");
    _colorSlot = glGetAttribLocation(_program, "vSourceColor");
    _projectionSlot = glGetUniformLocation(_program, "projection");
    _modelViewSlot = glGetUniformLocation(_program, "modelView");
}

-(void)setupProjection
{
    float aspect = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0f, 20.0f);
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
}

- (void) updateColorCubeTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksMatrixTranslate(&_modelViewMatrix, 0.0, -2, -5.5);
    
    ksMatrixRotate(&_modelViewMatrix, _rotateColorCube, 0.0, 1.0, 0.0);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

-(void)render{
    
    //设置清屏颜色，默认是黑色
    glClearColor(0.3, 0.5, 0.9, 1.0);
    //指定清除的buffer,可以设置GL_COLOR_BUFFER_BIT,GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    switch (self.type){
        case JGLView_Point:[self renderWithVertices:pointVertices mode:GL_POINTS type:self.type count:4];break;
        case JGLView_Lines:[self renderWithVertices:lineVertices mode:GL_LINES type:self.type count:4];break;
        case JGLView_Line_Strip:[self renderWithVertices:lineVertices mode:GL_LINE_STRIP type:self.type count:4];break;
        case JGLView_Line_Loop:[self renderWithVertices:lineVertices mode:GL_LINE_LOOP type:self.type count:4];break;
        case JGLView_Triangle:[self renderWithVertices:triangleVertices mode:GL_TRIANGLES type:self.type count:4];break;
        case JGLView_Triangle_Strip:[self renderWithVertices:triangleVertices mode:GL_TRIANGLE_STRIP type:self.type count:4];break;
        case JGLView_Triangle_Loop:[self renderWithVertices:triangleVertices mode:GL_TRIANGLE_FAN type:self.type count:4];break;
        case JGLView_Image:[self renderWithVertices:imageVertices mode:GL_TRIANGLE_STRIP type:JGLView_Image count:4];break;
        case JGLView_Cube:[self renderWithVertices:nil mode:GL_TRIANGLES type:JGLView_Cube count:4];break;
        default:NSLog(@"other type");
    }
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)renderWithVertices:(GLfloat[])verticesArray mode:(GLenum)mode type:(JGLViewDrawType)type count:(GLsizei)count{
    
//#if DEBUG
//    glVertexAttribPointer(_positionShot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
//    glEnableVertexAttribArray(_positionShot);
//    GLubyte indices[] = {
//        0,1,2
//    };
//    glDrawElements(mode, 3, GL_UNSIGNED_BYTE, indices);
//    return;
//#endif
    if(type == JGLView_Image){
        glUniform1i(_flag, 0);
        glEnableVertexAttribArray(_positionSlot);
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, verticesArray);
        
        glEnableVertexAttribArray(_textCoordinate);
        glVertexAttribPointer(_textCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, verticesArray + 3);
        GLuint tex = [self setupTexture:@"IMG999"];
//        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, tex);
        glUniform1i(_colorMap, 0);
        glDrawArrays(mode, 0, count);
    }
    else if (type == JGLView_Cube){
        glUniform1i(_flag, 2);
        [self setupProjection];
        [self updateColorCubeTransform];
        GLfloat vertices[] = {
            -0.5f, -0.5f, 0.5f, 1.0, 0.0, 0.0, 1.0,     // red
            -0.5f, 0.5f, 0.5f, 1.0, 1.0, 0.0, 1.0,      // yellow
            0.5f, 0.5f, 0.5f, 0.0, 0.0, 1.0, 1.0,       // blue
            0.5f, -0.5f, 0.5f, 1.0, 1.0, 1.0, 1.0,      // white
            
            0.5f, -0.5f, -0.5f, 1.0, 1.0, 0.0, 1.0,     // yellow
            0.5f, 0.5f, -0.5f, 1.0, 0.0, 0.0, 1.0,      // red
            -0.5f, 0.5f, -0.5f, 1.0, 1.0, 1.0, 1.0,     // white
            -0.5f, -0.5f, -0.5f, 0.0, 0.0, 1.0, 1.0,    // blue
        };
        
        GLubyte indices[] = {
            // Front face
            0, 3, 2, 0, 2, 1,
            
            // Back face
            7, 5, 4, 7, 6, 5,
            
            // Left face
            0, 1, 6, 0, 6, 7,
            
            // Right face
            3, 4, 5, 3, 5, 2,
            
            // Up face
            1, 2, 5, 1, 5, 6,
            
            // Down face
            0, 7, 4, 0, 4, 3
        };
        
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices);
        glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices + 3);
        glEnableVertexAttribArray(_positionSlot);
        glEnableVertexAttribArray(_colorSlot);
        glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
        glDisableVertexAttribArray(_colorSlot);
        
    }
    else{
        glUniform1i(_flag, 1);
        glEnableVertexAttribArray(_positionSlot);
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, verticesArray);
        glDrawArrays(mode, 0, count);
    }
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

//从图片中加载纹理
- (GLuint)setupTexture:(NSString *)fileName{
    /*
     *获取UIImage并转换成CGImage
     */
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if(!spriteImage){
        return 0;
    }
    
    //获取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    //分配内存
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    /*data - 指向要渲染的绘制图像的内存地址
     * width - 图片的宽度，单位为像素
     * height - 图片的高度，单位为像素
     * bitPerComponet - 内存中像素的每个组件位数，比如32位RGBA，就设置为8
     * bytesPerRow,bitmap的每行的内存所占比特数
     * colorSpace,bitmap使用的颜色空间
     */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, 4 * width, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGRect rect = CGRectMake(0, 0, width, height);
    //在上下文中绘制图片
    CGContextDrawImage(spriteContext, rect, spriteImage);
    CGContextRelease(spriteContext);
    
//    glBindTexture(GL_TEXTURE_2D, 0);
    // 创建纹理对象并且绑定，纹理对象用无符号整数表示
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    //设置纹理过滤模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    float fw = width,fh = height;
    //加载图片数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    //释放分配的空间
    free(spriteData);
    glBindTexture(GL_TEXTURE_2D, 0);
    return texName;
}

@end
