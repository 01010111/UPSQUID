#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform sampler2D uImage0;

uniform float c_1_r = 0.0;
uniform float c_1_g = 0.0;
uniform float c_1_b = 0.0;
uniform float c_2_r = 1.0;
uniform float c_2_g = 0.0;
uniform float c_2_b = 0.0;
uniform float c_3_r = 1.0;
uniform float c_3_g = 1.0;
uniform float c_3_b = 1.0;

void main(void)
{
	
    vec4 color = texture2D(uImage0, vTexCoord);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	
	vec4 col_1 = vec4(c_1_r, c_1_g, c_1_b, 1.0);
	vec4 col_2 = vec4(c_2_r, c_2_g, c_2_b, 1.0);
	vec4 col_3 = vec4(c_3_r, c_3_g, c_3_b, 1.0);
	
	if	(gray < 0.33)		color = col_1;
	else if	(gray < 0.66)	color = col_2;
	else					color = col_3;
	
	gl_FragColor = color;
}