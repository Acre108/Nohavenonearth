class_name CelEffects
extends RefCounted
## Four painted frames on a camera-facing card; no volumetric simulation.
const BURST := preload("res://art/fx_burst.svg")
static var frames: SpriteFrames

static func burst(parent: Node3D, at: Vector3, size: float = 0.8, smoke: bool = false) -> AnimatedSprite3D:
	if frames == null:
		frames = SpriteFrames.new()
		frames.set_animation_speed("default", 12.0)
		frames.set_animation_loop("default", false)
		frames.add_animation("smoke")
		frames.set_animation_speed("smoke", 8.0)
		frames.set_animation_loop("smoke", false)
		for i in 4:
			var frame := AtlasTexture.new()
			frame.atlas = BURST
			frame.region = Rect2(i * 128, 0, 128, 128)
			frames.add_frame("default", frame)
			if i >= 2: frames.add_frame("smoke", frame)
	var sprite := AnimatedSprite3D.new()
	sprite.sprite_frames = frames
	sprite.position = at
	sprite.pixel_size = size / 128.0
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.shaded = false
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)
	sprite.animation_finished.connect(sprite.queue_free)
	sprite.play("smoke" if smoke else "default")
	return sprite
