shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

global uniform float sensor_mix;
uniform vec4 faction : source_color = vec4(0.39, 0.85, 0.93, 1.0);
uniform vec4 ink : source_color = vec4(0.10, 0.14, 0.20, 1.0);
uniform float width_pixels : hint_range(0.0, 4.0) = 1.5;

void vertex() {
	// Orthographic screen-space width: stable through tactical zoom and resize.
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 view_normal = normalize(MODELVIEW_NORMAL_MATRIX * NORMAL);
	vec2 projected_normal = (PROJECTION_MATRIX * vec4(view_normal, 0.0)).xy;
	vec2 direction = projected_normal / max(length(projected_normal), 0.0001);
	clip.xy += direction * (2.0 / VIEWPORT_SIZE) * width_pixels * clip.w * mix(1.0, 1.25, sensor_mix);
	POSITION = clip;
}

void fragment() {
	ALBEDO = mix(ink.rgb, faction.rgb * 0.78, sensor_mix);
}
