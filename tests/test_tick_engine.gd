extends SceneTree

var _cleanup_helper = null

func _initialize() -> void:
	var failed = false
	print("--- RUNNING tests/test_tick_engine.gd ---")
	_cleanup_helper = ResourceLoader.load("res://scripts/test_cleanup_helper.gd", "", ResourceLoader.CACHE_MODE_IGNORE).new()
	if not _test_tick_increments():
		failed = true
	if not _test_tick_advance_is_deterministic():
		failed = true
	_cleanup_helper.cleanup()
	if _cleanup_helper != null and _cleanup_helper.has_method("free"):
		_cleanup_helper.free()
	if failed:
		print("TESTS FAILED")
		quit(1)
	else:
		print("ALL TESTS PASSED")
		quit(0)

func _test_tick_increments() -> bool:
	var TickEngineScript = _cleanup_helper.load_script("res://scripts/tick_engine.gd")
	var engine = _cleanup_helper.track_object(TickEngineScript.new())
	if engine.tick_count != 0:
		print("FAIL: initial tick_count != 0")
		return false
	engine.tick()
	if engine.tick_count != 1:
		print("FAIL: tick_count after 1 tick != 1")
		return false
	engine.reset()
	if engine.tick_count != 0:
		print("FAIL: reset did not set tick_count to 0")
		return false
	print("PASS: _test_tick_increments")
	return true

func _test_tick_advance_is_deterministic() -> bool:
	var TickEngineScript = _cleanup_helper.load_script("res://scripts/tick_engine.gd")
	var engine_a = _cleanup_helper.track_object(TickEngineScript.new())
	var engine_b = _cleanup_helper.track_object(TickEngineScript.new())

	engine_a.set_tick_rate(10)
	engine_b.set_tick_rate(10)

	engine_a.advance(0.05)
	engine_a.advance(0.05)
	engine_a.advance(0.10)

	engine_b.advance(0.20)

	if engine_a.tick_count != 2:
		print("FAIL: engine_a tick_count != 2")
		return false
	if engine_b.tick_count != 2:
		print("FAIL: engine_b tick_count != 2")
		return false
	if engine_a.tick_count != engine_b.tick_count:
		print("FAIL: deterministic advance produced different tick counts")
		return false
	if abs(engine_a.get_accumulator() - engine_b.get_accumulator()) > 0.00001:
		print("FAIL: deterministic advance produced different remainders")
		return false

	print("PASS: _test_tick_advance_is_deterministic")
	return true
