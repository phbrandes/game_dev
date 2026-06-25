extends Node
class_name WorldState

const Grid = preload("res://scripts/grid.gd")

var tick_count: int = 0
var grid = null
var conveyors: Array = []
var swarm_agents: Array = []
var turrets: Array = []

func _init(width: int = 8, height: int = 8) -> void:
	grid = Grid.new(width, height)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if grid != null and is_instance_valid(grid):
			grid.free()
		grid = null
		conveyors.clear()
		swarm_agents.clear()
		turrets.clear()

func add_conveyor(segment) -> void:
	if segment != null:
		conveyors.append(segment)

func add_swarm_agent(agent) -> void:
	if agent != null:
		swarm_agents.append(agent)

func add_turret(turret) -> void:
	if turret != null:
		turrets.append(turret)

func _sort_agents_by_id() -> Array:
	var sorted = swarm_agents.duplicate()
	for i in range(sorted.size()):
		for j in range(i + 1, sorted.size()):
			var left_id = String(sorted[i].get_agent_id())
			var right_id = String(sorted[j].get_agent_id())
			if right_id < left_id:
				var temp = sorted[i]
				sorted[i] = sorted[j]
				sorted[j] = temp
	return sorted

func _sort_turrets_by_id() -> Array:
	var sorted = turrets.duplicate()
	for i in range(sorted.size()):
		for j in range(i + 1, sorted.size()):
			var left_id = String(sorted[i].turret_id)
			var right_id = String(sorted[j].turret_id)
			if right_id < left_id:
				var temp = sorted[i]
				sorted[i] = sorted[j]
				sorted[j] = temp
	return sorted

func step() -> void:
	for conveyor in conveyors:
		conveyor.prepare_handshake()
	for conveyor in conveyors:
		conveyor.commit_handshake()

	for agent in _sort_agents_by_id():
		agent.step()

	var sorted_agents = _sort_agents_by_id()
	for turret in _sort_turrets_by_id():
		turret.fire(sorted_agents)

	tick_count += 1

func to_snapshot() -> Dictionary:
	var agent_snapshots: Array = []
	for agent in _sort_agents_by_id():
		agent_snapshots.append(agent.to_snapshot())

	var turret_snapshots: Array = []
	for turret in _sort_turrets_by_id():
		turret_snapshots.append(turret.to_snapshot())

	return {
		"tick_count": tick_count,
		"grid": grid.to_snapshot(),
		"swarm_agents": agent_snapshots,
		"turrets": turret_snapshots,
	}
