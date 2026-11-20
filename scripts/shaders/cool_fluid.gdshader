shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise_texture: repeat_enable;

uniform vec3 color_1: source_color;
uniform vec3 color_2: source_color;

uniform float drink_amount;

void fragment()
{
	float noise = texture(noise_texture,UV).r;
	
	if(UV.y < drink_amount)
	{
		discard;
	}
	
	COLOR.rgb = vec3(mix(color_1,color_2,noise));
}
