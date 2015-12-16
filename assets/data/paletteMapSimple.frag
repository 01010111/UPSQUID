#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform sampler2D uImage0;

void main(void)
{
    vec4 color = texture2D(uImage0, vTexCoord);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	
	if	(gray < 0.33)		color = vec4(0.0, 0.0, 0.0, 1.0);
	else if	(gray < 0.85)	color = vec4(1.0, 0.0, 0.0, 1.0);
	else					color = vec4(1.0, 1.0, 1.0, 1.0);
	
	gl_FragColor = color;
}