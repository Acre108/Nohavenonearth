class_name AttackFX
extends Node3D

## One-shot shot/impact/damage-number effect. Purely visual; frees itself when finished.
const TRAVEL := 0.18
const DAMAGE_TO_BLUE := Color("ff6b5e")
const DAMAGE_TO_RED := Color("ffd27a")
const NO_EFFECT := Color("b8c7d3")

func play(from: Vector3, to: Vector3, beam_color: Color, result: AttackResult, defender_faction: int, _text_scale: float) -> void:
	var landed := result.damage > 0
	CelEffects.burst(self, from, 0.45)
	var bolt := Primitives.sphere(self, 0.09, from, Color(beam_color.lightened(0.6), 1.0))
	var beam := Primitives.line(self, PackedVector3Array([from, to]), Color(beam_color.lightened(0.3), 0.85), 0.08)
	var beam_material: StandardMaterial3D = beam.get_child(0).material_override
	# HDR cores cross the glow threshold; ordinary tactical ribbons remain below it.
	beam_material.albedo_color = Color(beam_color.r * 3.0, beam_color.g * 3.0, beam_color.b * 3.0, 0.85)
	bolt.material_override.albedo_color = Color(beam_color.r * 3.5, beam_color.g * 3.5, beam_color.b * 3.5, 1.0)
	var number := Primitives.label(self, damage_text(result), to + Vector3.UP * 1.45, damage_color(result, defender_faction), 44)
	number.outline_size = 10
	number.visible = false
	var sequence := create_tween()
	sequence.tween_property(bolt, "position", to, TRAVEL)
	sequence.tween_callback(func() -> void:
		bolt.visible = false
		CelEffects.burst(self, to, 1.1 if landed else 0.45, not landed)
		number.visible = true)
	sequence.tween_property(beam_material, "albedo_color:a", 0.0, 0.45)
	sequence.parallel().tween_property(number, "font_size", 32, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	sequence.parallel().tween_property(number, "position:y", number.position.y + 0.9, 1.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	sequence.parallel().tween_property(number, "modulate:a", 0.0, 0.5).set_delay(0.9)
	sequence.parallel().tween_property(number, "outline_modulate:a", 0.0, 0.5).set_delay(0.9)
	sequence.tween_callback(queue_free)

static func damage_text(result: AttackResult) -> String:
	if result.destroyed:
		return "−%d  DESTROYED" % result.damage
	if result.damage > 0:
		return "−%d" % result.damage
	return "ARMOUR HELD" if result.connected() > 0 else "MISS"

static func damage_color(result: AttackResult, defender_faction: int) -> Color:
	if result.damage <= 0:
		return NO_EFFECT
	return DAMAGE_TO_BLUE if defender_faction == 0 else DAMAGE_TO_RED
