shader_type canvas_item;

uniform int kernel_size: hint_range(1, 25) = 11;  // Should be an odd number!
uniform float weight: hint_range(0.0, 10.0) = 2.5;

void fragment() {
	vec4 color = vec4(0.0);
	for (int i = -kernel_size / 2; i < kernel_size / 2 + 1; i++) {
		for (int j = -kernel_size / 2; j < kernel_size / 2 + 1; j++) {
			vec2 position = SCREEN_UV + vec2(float(i) * weight * SCREEN_PIXEL_SIZE.x, float(j) * weight * SCREEN_PIXEL_SIZE.y);
			color += texture(SCREEN_TEXTURE, position, 0.0) / (float(kernel_size) * float(kernel_size));
		}
	}
	color.a = 1.0;
	COLOR = color;
}
