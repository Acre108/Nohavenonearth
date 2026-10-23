shader_type spatial;
render_mode cull_back, specular_disabled, ambient_light_disabled;

global uniform float sensor_mix;
uniform vec4 paint : source_color = vec4(0.7, 0.73, 0.72, 1.0);
uniform vec4 shadow_tint : source_color = vec4(0.22, 0.19, 0.36, 1.0);
uniform vec4 rim_color : source_color = vec4(0.92, 0.76, 0.58, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.16;
uniform int bands : hint_range(2, 3) = 3;
uniform bool sensor_unit = false;
uniform bool use_albedo_texture = false;
uniform sampler2D albedo_texture : source_color, filter_nearest_mipmap;
uniform float emission_strength = 0.0;
varying vec3 painted_color;

void fragment() {
	vec3 base = paint.rgb;
	if (use_albedo_texture) { base *= texture(albedo_texture, UV).rgb; }
	// Preserve authored chips and crevices as hard shapes, without smooth AO grime.
	vec3 wear = floor(clamp(COLOR.rgb, vec3(0.0), vec3(1.0)) * 3.0 + 0.5) / 3.0;
	painted_color = base * mix(vec3(0.48), vec3(1.0), wear);
	// light() supplies the painted colour itself; avoid multiplying it twice.
	ALBEDO = vec3(1.0);
	SPECULAR = 0.0;
	METALLIC = 0.0;
	// Constant ID in the normal/roughness buffer. Specular is disabled, so this
	// creates no glossy response. Environment materials reserve values >= 0.18.
	ROUGHNESS = sensor_unit ? 0.02 : 0.82;
	float rim = step(0.72, 1.0 - max(dot(NORMAL, VIEW), 0.0));
	float value = dot(base, vec3(0.2126, 0.7152, 0.0722));
	vec3 sensor = vec3(0.10, 0.14, 0.17) + vec3(value * 0.30);
	vec3 shadow = mix(shadow_tint.rgb * 0.32, painted_color, 0.38);
	EMISSION = mix(shadow + rim * rim_color.rgb * rim_strength + base * emission_strength,
		sensor, sensor_mix);
	ALBEDO *= 1.0 - sensor_mix;
}

void light() {
	// Attenuation includes real shadow maps and local-light falloff.
	float key = max(dot(NORMAL, LIGHT), 0.0) * ATTENUATION;
	float band = bands == 2 ? step(0.36, key) :
		mix(0.0, 0.48, step(0.18, key)) + 0.52 * step(0.67, key);
	vec3 shadow = mix(shadow_tint.rgb * 0.32, painted_color, 0.38);
	vec3 lit = max(painted_color - shadow, vec3(0.0));
	// Godot light colours include PI. max prevents lamps washing out the cels.
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, lit * band * LIGHT_COLOR / PI * (1.0 - sensor_mix));
}
