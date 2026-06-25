extends SceneTree

var _tracked_objects: Array = []
var _tracked_resources: Array = []

func _initialize() -> void:
	var failed = false
	print("--- RUNNING tests/test_tick_engine.gd ---")
	if not _test_tick_increments():
		failed = true
	if not _test_tick_advance_is_deterministic():
		failed = true
	if not _test_world_state_determinism():
		failed = true
	_cleanup_tracked_objects()
	if failed:
		print("TESTS FAILED")
		quit(1)
	else:
		print("ALL TESTS PASSED")
		quit(0)

func _track_object(obj):
	if obj != null:
		_tracked_objects.append(obj)
	return obj

func _cleanup_tracked_objects() -> void:
	for index in range(_tracked_objects.size() - 1, -1, -1):
		var obj = _tracked_objects[index]
		if obj != null and is_instance_valid(obj) and obj.has_method("free"):
			obj.free()
	_tracked_objects.clear()

	for index in range(_tracked_resources.size() - 1, -1, -1):
		var res = _tracked_resources[index]
		if res != null:
			# Script resources are RefCounted and cannot be freed manually; clear references instead.
			res = null
		_tracked_resources[index] = null
	_tracked_resources.clear()

func _load_script(path: String):
	var script_res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if script_res != null:
		_tracked_resources.append(script_res)
	return script_res

func _test_tick_increments() -> bool:
	var TickEngineScript = _load_script("res://scripts/tick_engine.gd")
	var engine = _track_object(TickEngineScript.new())
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
	var TickEngineScript = _load_script("res://scripts/tick_engine.gd")
	var engine_a = _track_object(TickEngineScript.new())
	var engine_b = _track_object(TickEngineScript.new())

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

func _build_world_state_fixture():
	var WorldStateScript = _load_script("res://scripts/world_state.gd")
	var FlowFieldScript = _load_script("res://scripts/flow_field.gd")
	var SwarmAgentScript = _load_script("res://scripts/swarm_agent.gd")
	var TurretControllerScript = _load_script("res://scripts/turret_controller.gd")

	var world = _track_object(WorldStateScript.new(4, 4))
	var flow_field = _track_object(FlowFieldScript.new(4, 4))
	flow_field.build_from_grid(world.grid, [[3, 3]])

	var alpha = _track_object(SwarmAgentScript.new())
	alpha.configure("alpha", [1, 0], flow_field)
	alpha.health = 2

	var beta = _track_object(SwarmAgentScript.new())
	beta.configure("beta", [2, 0], flow_field)
	beta.health = 3

	var turret = _track_object(TurretControllerScript.new())
	turret.configure("turret-a", [0, 0], 4, 1)

	world.add_swarm_agent(alpha)
	world.add_swarm_agent(beta)
	world.add_turret(turret)

	return world

func _test_world_state_determinism() -> bool:
	var world_a = _build_world_state_fixture()
	var world_b = _build_world_state_fixture()

	for _tick in range(4):
		world_a.step()
		world_b.step()

	var snapshot_a = world_a.to_snapshot()
	var snapshot_b = world_b.to_snapshot()

	if snapshot_a != snapshot_b:
		print("FAIL: world state diverged for identical setups")
		return false
	if snapshot_a["tick_count"] != 4:
		print("FAIL: world state tick_count did not advance")
		return false

	var agents = snapshot_a["swarm_agents"]
	if agents.size() != 2:
		print("FAIL: expected two swarm agents in world snapshot")
		return false
	if agents[0]["agent_id"] != "alpha":
		print("FAIL: agent ordering is not deterministic")
		return false

	print("PASS: _test_world_state_determinism")
	return true
