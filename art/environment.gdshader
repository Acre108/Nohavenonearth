shader_type spatial;
render_mode cull_back, diffuse_lambert, specular_schlick_ggx;

global uniform float sensor_mix;
uniform vec4 paint : source_color = vec4(0.3, 0.34, 0.39, 1.0);
uniform bool use_albedo_texture = false;
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float texture_world_size = 4.0;
uniform bool wet_ground = false;
uniform float emission_strength = 0.0;
uniform vec3 lamp_positions[4];
uniform int lamp_count = 0;
uniform vec4 lamp_color : source_color = vec4(1.0, 0.8, 0.545, 1.0);
uniform float reflection_strength = 0.18;
varying vec3 world_position;
varying vec3 world_normal;

float wash(vec2 p) {
	return sin(p.x * 1.7 + sin(p.y * 0.8)) * sin(p.y * 1.4 + cos(p.x * 0.6));
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	// Broad brush washes, no surface normals or metallic noise.
	float brush = floor(wash(world_position.xz * 0.55 + world_position.y) * 3.0) / 3.0;
	vec3 background = paint.rgb * (0.95 + brush * 0.08);
	if (use_albedo_texture) {
		// World projection keeps box walls and roofs at the same physical scale.
		vec3 axis = abs(normalize(world_normal));
		vec2 surface_uv = world_position.xz;
		if (axis.x > axis.y && axis.x > axis.z) {
			surface_uv = world_position.zy;
		} else if (axis.z > axis.y) {
			surface_uv = world_position.xy;
		}
		background *= texture(albedo_texture, surface_uv / max(texture_world_size, 0.01)).rgb;
	}
	float puddle = wet_ground ? smoothstep(0.12, 0.42, wash(world_position.xz * 0.46)) : 0.0;
	background = mix(background, background * vec3(0.62, 0.66, 0.84), puddle * 0.55);
	float value = dot(paint.rgb, vec3(0.2126, 0.7152, 0.0722));
	float contour = 1.0 - smoothstep(0.025, 0.065, abs(fract(world_position.y * 2.0) - 0.5));
	vec3 sensor = vec3(value * 0.30) * vec3(0.65, 0.78, 0.9) + vec3(0.03, 0.04, 0.05) * contour;
	ALBEDO = background * (1.0 - sensor_mix);
	ROUGHNESS = mix(mix(0.88, 0.18, puddle), 0.88, sensor_mix);
	SPECULAR = mix(0.0, 0.65, puddle) * (1.0 - sensor_mix);
	METALLIC = 0.0;
	vec3 reflected = vec3(0.0);
	vec2 camera_forward = INV_VIEW_MATRIX[2].xz;
	vec2 along = camera_forward / max(length(camera_forward), 0.001);
	vec2 across = vec2(-along.y, along.x);
	for (int i = 0; i < lamp_count; i++) {
		vec2 offset = world_position.xz - lamp_positions[i].xz;
		float distance_along = dot(offset, along);
		float distance_across = abs(dot(offset, across));
		float shape = (1.0 - smoothstep(0.1, 0.35, distance_across)) *
			(1.0 - smoothstep(0.0, 3.8, distance_along)) * step(0.0, distance_along);
		float steps = 0.5 * step(0.2, shape) + 0.5 * step(0.68, shape);
		reflected += lamp_color.rgb * steps * reflection_strength * puddle;
	}
	EMISSION = mix(background * emission_strength + reflected, sensor, sensor_mix);
}

void light() {
	// Keep puddle roughness/specular for SSR, without the orthographic key flare.
	DIFFUSE_LIGHT += max(dot(NORMAL, LIGHT), 0.0) * ATTENUATION * LIGHT_COLOR / PI;
}
