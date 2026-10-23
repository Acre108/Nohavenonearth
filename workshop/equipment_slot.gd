class_name EquipmentSlot
extends Button
## Equipment silhouettes stay crisp at any UI scale. Rarity and finish are independent.
const RARITIES := {"standard":Color("67cd83"), "uncommon":Color("58a9f4"), "rare":Color("ee666d")}
const WEAPON_ARMS := ["arm_marksman", "arm_cannon", "arm_breacher"]
## Silhouettes are drawn on a 64×64 grid and scaled to the button.
const GRID := Vector2(64, 64)
const STEEL := Color("8b9da6")
const FACE := Color("c4cdc2")
const DARK := Color("344750")
const SELECTED := Color("f4d49a")
const WORN := Color("ee9982")
var part: Dictionary = {}
var slot_id := ""
var customised := false
var condition := 100
var pending := false
var active := false
var phase := 0.0
var icon_size := 64.0

func _ready() -> void:
	custom_minimum_size = Vector2.ONE * icon_size
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	set_process(customised)

func _process(delta: float) -> void:
	phase = fmod(phase + delta * 0.55, 1.0)
	queue_redraw()

func rarity_colour() -> Color:
	return RARITIES.get(part.get("rarity", "standard"), RARITIES.standard)

func _draw() -> void:
	var rect := Rect2(Vector2(2,2), size - Vector2(4,4))
	var colour := rarity_colour()
	draw_style_box(box(Color("111e24"), Color("34464d"), 1), Rect2(Vector2.ZERO, size))
	draw_style_box(box(Color("1b2b33").lightened(0.07 if is_hovered() else 0), colour, 2), rect)
	if customised:
		draw_border_tracer(rect, colour)
	if active or has_focus():
		draw_rect(Rect2(Vector2(5,5), size - Vector2(10,10)), SELECTED, false, 1)
	draw_set_transform(Vector2.ZERO, 0, size / GRID)
	draw_silhouette(colour)
	draw_status(colour)
	draw_set_transform(Vector2.ZERO)

## A moving highlight travels the complete rarity border on customised equipment.
func draw_border_tracer(rect: Rect2, colour: Color) -> void:
	var edge := rect.size.x + rect.size.y
	for i in 14:
		var t := fmod(phase + float(i) * 0.007, 1.0) * edge * 2.0
		var point := rect.position
		if t < rect.size.x: point += Vector2(t, 0)
		elif t < edge: point += Vector2(rect.size.x, t - rect.size.x)
		elif t < edge + rect.size.x: point += Vector2(edge + rect.size.x - t, rect.size.y)
		else: point += Vector2(0, edge * 2.0 - t)
		draw_circle(point, 1.4 + float(i)/18.0, colour.lerp(Color.WHITE, float(i)/14.0))

func draw_silhouette(colour: Color) -> void:
	var id: String = part.get("id", "")
	var family: String = part.get("family", "")
	if "sensor" in family: draw_sensor(colour)
	elif id in WEAPON_ARMS or ("arm_drive" in family and slot_id.begins_with("right")): draw_weapon_arm(id, colour)
	elif "arm_drive" in family: draw_arm(id, colour)
	elif "leg_drive" in family: draw_leg(colour)
	elif "power" in family: draw_power(colour)
	elif "service" in family or "module" in family: draw_backpack(id, family, colour)
	elif "structure" in family: draw_structure(colour)
	elif "leg_armour" in family: draw_leg_armour()
	elif "arm_armour" in family: draw_arm_armour()
	else: draw_plating()

## Upgrade rivets, the condition strip and the pending-change dot supplement colour without adding labels.
func draw_status(colour: Color) -> void:
	if part.get("rarity", "standard") != "standard":
		draw_circle(Vector2(51,49),2.5,colour)
		if part.get("rarity") == "rare": draw_circle(Vector2(45,49),2.5,colour)
	draw_rect(Rect2(8,56,48,3), Color("0e171b"))
	var worn := condition < WorkshopState.WORN_BELOW
	draw_rect(Rect2(8,56,48*float(condition)/100.0,3), WORN if worn else colour.darkened(0.25))
	if pending: draw_circle(Vector2(54,10),3,SELECTED)

func draw_sensor(colour: Color) -> void:
	poly([Vector2(15,20),Vector2(24,13),Vector2(43,16),Vector2(49,29),Vector2(43,45),Vector2(22,47),Vector2(15,37)], STEEL)
	draw_rect(Rect2(20,25,24,12), DARK)
	draw_line(Vector2(23,30),Vector2(42,30),colour,4)
	draw_line(Vector2(38,17),Vector2(45,10),FACE,2)

## Distinct weapon silhouettes: long rifle, rotary cluster and short breacher.
func draw_weapon_arm(id: String, colour: Color) -> void:
	poly([Vector2(10,35),Vector2(19,26),Vector2(36,26),Vector2(39,35),Vector2(25,39),Vector2(23,48),Vector2(17,48),Vector2(18,38)], STEEL)
	var muzzle := 56.0 if id == "arm_marksman" else 49.0
	draw_line(Vector2(33,29),Vector2(muzzle,17),FACE,5)
	draw_line(Vector2(24,25),Vector2(35,19),colour,3)
	if id == "arm_cannon":
		for i in 3: draw_line(Vector2(35,27+i*4),Vector2(54,16+i*4),STEEL,3)
	elif id == "arm_breacher":
		draw_line(Vector2(36,33),Vector2(49,25),FACE,5)

func draw_arm(id: String, colour: Color) -> void:
	draw_circle(Vector2(24,20),10,STEEL)
	poly([Vector2(20,29),Vector2(33,24),Vector2(44,38),Vector2(38,49),Vector2(26,46)],STEEL)
	draw_line(Vector2(23,22),Vector2(34,37),DARK,5)
	if id == "arm_support":
		draw_line(Vector2(38,42),Vector2(49,36),FACE,5)
	else:
		draw_line(Vector2(39,38),Vector2(48,53),FACE,5)
	draw_circle(Vector2(25,20),4,colour)

func draw_leg(colour: Color) -> void:
	draw_circle(Vector2(31,17),8,STEEL)
	draw_line(Vector2(31,22),Vector2(25,34),FACE,9)
	draw_circle(Vector2(25,34),6,colour.darkened(0.25))
	draw_line(Vector2(27,38),Vector2(34,48),STEEL,9)
	poly([Vector2(27,46),Vector2(38,44),Vector2(46,51),Vector2(19,53)],FACE)

func draw_power(colour: Color) -> void:
	draw_rect(Rect2(17,14,30,38),STEEL)
	draw_rect(Rect2(21,18,22,30),DARK)
	poly([Vector2(35,18),Vector2(25,33),Vector2(32,33),Vector2(28,47),Vector2(40,29),Vector2(33,29)],colour)
	for i in 3: draw_line(Vector2(12,22+i*11),Vector2(17,22+i*11),FACE,3)

## Recovery rig, missile module or service rig, all on the same backpack casing.
func draw_backpack(id: String, family: String, colour: Color) -> void:
	draw_rect(Rect2(16,16,31,35),STEEL)
	draw_rect(Rect2(20,20,23,27),DARK)
	if "recovery" in id:
		draw_line(Vector2(25,25),Vector2(39,38),FACE,5)
		draw_arc(Vector2(27,26),6,0.5,4.4,12,colour,3)
	elif "module" in family:
		for x in 3:
			for y in 3: draw_circle(Vector2(25+x*7,25+y*8),2.5,colour)
	else:
		for i in 4: draw_line(Vector2(24,25+i*6),Vector2(39,25+i*6),colour,2)

func draw_structure(colour: Color) -> void:
	poly([Vector2(20,12),Vector2(44,12),Vector2(49,27),Vector2(41,50),Vector2(23,50),Vector2(15,27)],STEEL)
	poly([Vector2(25,19),Vector2(39,19),Vector2(41,29),Vector2(32,37),Vector2(23,29)],DARK)
	draw_line(Vector2(25,25),Vector2(39,25),colour,3)

func draw_leg_armour() -> void:
	poly([Vector2(23,12),Vector2(42,15),Vector2(38,34),Vector2(43,46),Vector2(46,52),Vector2(18,52),Vector2(20,43),Vector2(21,31)],STEEL)
	poly([Vector2(27,18),Vector2(37,20),Vector2(33,33),Vector2(24,31)],FACE)
	draw_line(Vector2(24,43),Vector2(38,43),DARK,3)

func draw_arm_armour() -> void:
	poly([Vector2(16,17),Vector2(40,13),Vector2(49,24),Vector2(44,34),Vector2(38,35),Vector2(43,47),Vector2(25,51),Vector2(20,37),Vector2(15,32)],STEEL)
	poly([Vector2(21,22),Vector2(38,18),Vector2(43,25),Vector2(38,30),Vector2(23,33)],FACE)
	draw_line(Vector2(27,40),Vector2(37,38),DARK,3)

## Torso plating, and the fallback for unknown families.
func draw_plating() -> void:
	poly([Vector2(18,14),Vector2(45,17),Vector2(49,31),Vector2(40,49),Vector2(31,53),Vector2(17,39),Vector2(14,27)],STEEL)
	poly([Vector2(22,20),Vector2(40,22),Vector2(42,31),Vector2(31,44),Vector2(23,35)],FACE)
	draw_line(Vector2(24,28),Vector2(38,30),DARK,3)

func poly(points: Array, colour: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),colour)

func box(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = fill
	result.border_color = border
	result.set_border_width_all(width)
	result.set_corner_radius_all(5)
	return result
