shader_type canvas_item;
render_mode unshaded;

global uniform float sensor_mix;
uniform sampler2D scene_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D grade_lut : filter_linear, repeat_disable;
uniform float grade_strength : hint_range(0.0, 1.0) = 0.55;
uniform float aberration_pixels : hint_range(0.0, 3.0) = 0.45;
uniform float grain_strength : hint_range(0.0, 0.1) = 0.012;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.18;

vec3 grade(vec3 color) {
	vec3 cube = clamp(color, vec3(0.0), vec3(1.0)) * 15.0;
	float lower = floor(cube.b);
	vec2 low_uv = vec2((lower * 16.0 + cube.r + 0.5) / 256.0, (cube.g + 0.5) / 16.0);
	vec2 high_uv = low_uv + vec2(16.0 / 256.0, 0.0);
	return mix(texture(grade_lut, low_uv).rgb, texture(grade_lut, high_uv).rgb, fract(cube.b));
}

float grain(vec2 position, float frame) {
	return fract(sin(dot(position + frame, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
}

void fragment() {
	float amount = 1.0 - sensor_mix;
	vec2 uv = SCREEN_UV;
	vec2 radial = uv - 0.5;
	vec2 bleed = radial * dot(radial, radial) * SCREEN_PIXEL_SIZE * aberration_pixels * 5.0 * amount;
	// Glow has already been applied by WorldEnvironment. Grade each channel's
	// source before shifting it, preserving the requested grade -> aberration order.
	vec3 center = texture(scene_texture, uv).rgb;
	vec3 red = texture(scene_texture, uv + bleed).rgb;
	vec3 blue = texture(scene_texture, uv - bleed).rgb;
	center = mix(center, grade(center), grade_strength * amount);
	red = mix(red, grade(red), grade_strength * amount);
	blue = mix(blue, grade(blue), grade_strength * amount);
	vec3 color = vec3(red.r, center.g, blue.b);
	color += grain(FRAGCOORD.xy, floor(TIME * 24.0)) * grain_strength * amount;
	float vignette = smoothstep(0.12, 0.62, dot(radial, radial));
	color *= 1.0 - vignette * vignette_strength * amount;
	COLOR = vec4(color, 1.0);
}
