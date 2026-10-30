extends SceneTree
## Shared lifecycle and diagnostics for standalone --script test suites.

var checks := 0
var failures := 0
var suite_name: String:
	get:
		return get_script().resource_path.get_file().get_basename().trim_prefix("test_").replace("_", " ").to_upper()

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	check(false, "Test suite must implement run()")
	finish()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(suite_name + " FAIL / " + message)

func frames(count: int = 3) -> void:
	for i in count:
		await process_frame

func capture(name: String, wait_frames: int = 3) -> void:
	await frames(wait_frames)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://artifacts/" + name + ".png")

func finish() -> void:
	print("%s / %d checks / %d failures" % [suite_name, checks, failures])
	quit(1 if failures else 0)
