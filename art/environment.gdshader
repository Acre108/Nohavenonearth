shader_type spatial;
render_mode cull_back, diffuse_lambert, specular_schlick_ggx;

global uniform float sensor_mix;
uniform vec4 paint : source_color = vec4(0.3, 0.34, 0.39, 1.0);
uniform bool wet_ground = false;
uniform float emission_strength = 0.0;
varying vec3 world_position;

float wash(vec2 p) {
	return sin(p.x * 1.7 + sin(p.y * 0.8)) * sin(p.y * 1.4 + cos(p.x * 0.6));
}

void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }

void fragment() {
	// Broad brush washes, no surface normals or metallic noise.
	float brush = floor(wash(world_position.xz * 0.55 + world_position.y) * 3.0) / 3.0;
	vec3 background = paint.rgb * (0.95 + brush * 0.08);
	float puddle = wet_ground ? smoothstep(0.12, 0.42, wash(world_position.xz * 0.46)) : 0.0;
	background = mix(background, background * vec3(0.62, 0.66, 0.84), puddle * 0.55);
	float value = dot(paint.rgb, vec3(0.2126, 0.7152, 0.0722));
	float contour = 1.0 - smoothstep(0.025, 0.065, abs(fract(world_position.y * 2.0) - 0.5));
	vec3 sensor = vec3(value * 0.30) * vec3(0.65, 0.78, 0.9) + vec3(0.03, 0.04, 0.05) * contour;
	ALBEDO = background * (1.0 - sensor_mix);
	ROUGHNESS = mix(mix(0.88, 0.18, puddle), 0.88, sensor_mix);
	SPECULAR = mix(0.0, 0.65, puddle) * (1.0 - sensor_mix);
	METALLIC = 0.0;
	EMISSION = mix(background * emission_strength, sensor, sensor_mix);
}
