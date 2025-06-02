shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float base_transparency = 0.4;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 text = texture(TEXTURE, UV);
	vec2 center = UV/2.0;
	float dist = length((UV - vec2(0.5, 0.5)));

	float alpha = 0.0;
	if (dist <= 0.5 && dist >= 0.49) {
		alpha = 0.5;
	}

	float final_alpha = base_transparency * (alpha + clamp(1.0 - 1.8 * dist, 0.0, 1.0));

	COLOR = vec4(color.rgb, final_alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
