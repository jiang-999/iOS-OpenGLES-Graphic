//
//  JGLESUtils.m
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/17.
//

#import "JGLESUtils.h"

@implementation JGLESUtils

/// 创建一个shader对象
/// - Parameters:
///   - type: 顶点或片元
///   - shaderString: shader代码
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString{
    GLuint shader = glCreateShader(type);
    if(shader == 0){
        NSLog(@"创建shader失败");
        return 0;
    }
    //加载shader
    const GLchar *shaderStringUTF8 = (GLchar *)[shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    
    //编译shader
    glCompileShader(shader);
    
    //检查编译状态
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if(!compiled){
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen > 1){
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"编译shader报错:\n%s\n",infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

/// 创建一个shader对象
/// - Parameters:
///   - type: 顶点或片元
///   - shaderString: shader文件路径
+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath{
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFilepath encoding:NSUTF8StringEncoding error:&error];
    if(!shaderString){
        NSLog(@"加载shader文件报错：%@ %@",shaderFilepath,error.localizedDescription);
        return 0;
    }
    
    return [self loadShader:type withString:shaderString];
}

/// 创建一个program对象
/// - Parameters:
///   - vertextShaderFilepath: vertext shader filepath
///   - fragmentShaderFilepath: fragment shader filepath
+(GLuint)loadProgram:(NSString *)vertextShaderFilepath
withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath{
    //加载顶点shader
    GLuint vertextShader = [self loadShader:GL_VERTEX_SHADER withFilepath:vertextShaderFilepath];
    if(0 == vertextShader){return 0;}
    //加载片元shader
    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER withFilepath:fragmentShaderFilepath];
    if(0 == fragmentShader){return 0;}
    //创建program object
    GLuint programHandle = glCreateProgram();
    if(0 == programHandle){return 0;}
    glAttachShader(programHandle, vertextShader);
    glAttachShader(programHandle, fragmentShader);
    //连接program
    glLinkProgram(programHandle);
    
    //检查连接状态
    GLint linked;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linked);
    if(!linked){
        GLint infoLen = 0;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen > 1){
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(programHandle, infoLen, NULL, infoLog);
            NSLog(@"连接错误：\n%s",infoLog);
            free(infoLog);
            
        }
        glDeleteProgram(programHandle);
        return 0;
    }
    glDeleteShader(vertextShader);
    glDeleteShader(fragmentShader);
    return programHandle;
}

@end
