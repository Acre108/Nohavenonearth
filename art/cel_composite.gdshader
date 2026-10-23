shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_draw_never, depth_test_disabled;

global uniform float sensor_mix;
uniform sampler2D scene_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;
uniform float paint_strength : hint_range(0.0, 1.0) = 0.45;
uniform float edge_strength : hint_range(0.0, 1.0) = 0.65;
uniform float normal_threshold = 0.65;
uniform float depth_threshold = 0.075;
uniform vec4 ink : source_color = vec4(0.055, 0.045, 0.09, 1.0);
uniform bool show_mask = false;

void vertex() { POSITION = vec4(VERTEX.xy, 1.0, 1.0); }

float unit_mask(vec2 uv) {
	float roughness = texture(normal_texture, uv).a;
	return (1.0 - step(0.08, roughness)) * step(0.001, texture(depth_texture, uv).r);
}

float linear_depth(vec2 uv, mat4 inverse_projection) {
	float z = texture(depth_texture, uv).r;
	vec4 view = inverse_projection * vec4(uv * 2.0 - 1.0, z, 1.0);
	return -view.z / view.w;
}

vec3 kuwahara(vec2 uv, vec2 pixel) {
	vec3 center = texture(scene_texture, uv).rgb;
	vec3 best = center;
	float minimum_variance = 1e10;
	// Four overlapping 3x3 quadrants, chosen by smallest colour variance.
	// Ignore mech samples, so a painted wall never borrows armour or ink.
	for (int quadrant = 0; quadrant < 4; quadrant++) {
		vec2 direction = vec2(quadrant % 2 == 0 ? -1.0 : 1.0, quadrant < 2 ? -1.0 : 1.0);
		vec3 sum = vec3(0.0);
		vec3 square_sum = vec3(0.0);
		for (int y = 0; y <= 2; y++) {
			for (int x = 0; x <= 2; x++) {
				vec2 at = uv + vec2(float(x), float(y)) * direction * pixel;
				vec3 sample_color = mix(texture(scene_texture, at).rgb, center, unit_mask(at));
				sum += sample_color;
				square_sum += sample_color * sample_color;
			}
		}
		vec3 mean = sum / 9.0;
		vec3 variance = abs(square_sum / 9.0 - mean * mean);
		float total = variance.r + variance.g + variance.b;
		if (total < minimum_variance) { minimum_variance = total; best = mean; }
	}
	return best;
}

void fragment() {
	vec2 pixel = 1.0 / VIEWPORT_SIZE;
	vec3 color = texture(scene_texture, SCREEN_UV).rgb;
	float mask = unit_mask(SCREEN_UV);
	float cinematic = 1.0 - sensor_mix;
	if (mask < 0.5 && paint_strength * cinematic > 0.001) {
		color = mix(color, kuwahara(SCREEN_UV, pixel), paint_strength * cinematic);
	}
	if (mask > 0.5 && edge_strength * cinematic > 0.001) {
		float dx = 0.0;
		float dy = 0.0;
		vec3 nx = vec3(0.0);
		vec3 ny = vec3(0.0);
		float center_depth = linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
		for (int y = -1; y <= 1; y++) {
			for (int x = -1; x <= 1; x++) {
				vec2 at = SCREEN_UV + vec2(float(x), float(y)) * pixel;
				// Inner lines only. The inverted hull supplies the outer silhouette.
				float valid = unit_mask(at);
				float d = mix(center_depth, linear_depth(at, INV_PROJECTION_MATRIX), valid);
				vec3 n = mix(texture(normal_texture, SCREEN_UV).rgb, texture(normal_texture, at).rgb, valid) * 2.0 - 1.0;
				float sx = float(x) * (y == 0 ? 2.0 : 1.0);
				float sy = float(y) * (x == 0 ? 2.0 : 1.0);
				dx += d * sx; dy += d * sy;
				nx += n * sx; ny += n * sy;
			}
		}
		float depth_edge = smoothstep(depth_threshold, depth_threshold * 2.0, length(vec2(dx, dy)) / 4.0);
		float normal_edge = smoothstep(normal_threshold, normal_threshold * 1.5, sqrt(dot(nx, nx) + dot(ny, ny)) / 4.0);
		color = mix(color, ink.rgb, max(depth_edge, normal_edge) * edge_strength * cinematic);
	}
	ALBEDO = show_mask ? vec3(mask) : color;
	ALPHA = 1.0;
}
