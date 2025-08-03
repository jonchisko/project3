shader_type canvas_item;

uniform float alpha_over_time : hint_range(0.0, 1.0, 0.05) = 1.0;
uniform vec4 area_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float alpha = texture(TEXTURE, UV).a * alpha_over_time;
	COLOR = vec4(area_color.rgb, alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
