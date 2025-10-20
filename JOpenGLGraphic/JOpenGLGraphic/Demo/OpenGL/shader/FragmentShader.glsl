precision mediump float;
uniform lowp int flag;
uniform sampler2D colorMap;
varying lowp vec2 varyTextCoord;
varying vec4 vDestinationColor;
void main()
{
    if(flag == 1){
        gl_FragColor = vec4(1.0,0.0,0.0,1.0);
    }
    else if(flag == 2){
        gl_FragColor = vDestinationColor;
    }
    else{
//        gl_FragColor = vec4(0.0,0.0,1.0,1.0);
        gl_FragColor = texture2D(colorMap, varyTextCoord);
    }
}
