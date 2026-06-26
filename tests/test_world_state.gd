extends SceneTree

var _cleanup_helper = null

func _initialize() -> void:
	var failed = false
	print("--- RUNNING tests/test_world_state.gd ---")
	_cleanup_helper = ResourceLoader.load("res://scripts/test_cleanup_helper.gd", "", ResourceLoader.CACHE_MODE_IGNORE).new()
	if not _test_world_state_determinism():
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

func _build_world_state_fixture():
	var WorldStateScript = _cleanup_helper.load_script("res://scripts/world_state.gd")
	var FlowFieldScript = _cleanup_helper.load_script("res://scripts/flow_field.gd")
	var SwarmAgentScript = _cleanup_helper.load_script("res://scripts/swarm_agent.gd")
	var TurretControllerScript = _cleanup_helper.load_script("res://scripts/turret_controller.gd")

	var world = _cleanup_helper.track_object(WorldStateScript.new(4, 4))
	var flow_field = _cleanup_helper.track_object(FlowFieldScript.new(4, 4))
	flow_field.build_from_grid(world.grid, [[3, 3]])

	var alpha = _cleanup_helper.track_object(SwarmAgentScript.new())
	alpha.configure("alpha", [1, 0], flow_field)
	alpha.health = 2

	var beta = _cleanup_helper.track_object(SwarmAgentScript.new())
	beta.configure("beta", [2, 0], flow_field)
	beta.health = 3

	var turret = _cleanup_helper.track_object(TurretControllerScript.new())
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
