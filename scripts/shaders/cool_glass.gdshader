shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise_texture: repeat_enable;

uniform vec3 color_1: source_color;
uniform vec3 color_2: source_color;

void fragment()
{
	float noise = texture(noise_texture,UV).r;
	
	COLOR.rgb = vec3(mix(color_1,color_2,noise));
}
