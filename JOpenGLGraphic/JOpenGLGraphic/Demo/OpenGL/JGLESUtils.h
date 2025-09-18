//
//  JGLESUtils.h
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/17.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGLESUtils : NSObject


/// 创建一个shader对象
/// - Parameters:
///   - type: 顶点或片元
///   - shaderString: shader代码
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

/// 创建一个shader对象
/// - Parameters:
///   - type: 顶点或片元
///   - shaderString: shader文件路径
+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;


/// 创建一个program对象
/// - Parameters:
///   - vertextShaderFilepath: vertext shader filepath
///   - fragmentShaderFilepath: fragment shader filepath
+(GLuint)loadProgram:(NSString *)vertextShaderFilepath
withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath;

@end

NS_ASSUME_NONNULL_END
