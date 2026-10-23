shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;
global uniform float sensor_mix;
uniform float visibility = 0.0;
void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}
void fragment() {
	ALBEDO = vec3(0.65, 0.68, 0.82);
	ALPHA = 0.18 * visibility * (1.0 - sensor_mix);
}
