attribute vec4 vPosition;
attribute vec2 textCoordinate;
varying lowp vec2 varyTextCoord;
uniform lowp int flag;
uniform mat4 projection;
uniform mat4 modelView;

attribute vec4 vSourceColor;
varying vec4 vDestinationColor;

void main(void)
{
    if(flag == 2){
        gl_Position = projection * modelView * vPosition;
        vDestinationColor = vSourceColor;
    }else{
        varyTextCoord = textCoordinate;
        gl_Position = vPosition;
        gl_PointSize = 10.0;
    }
}
