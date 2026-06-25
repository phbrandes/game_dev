extends Node
class_name TurretController

var turret_id: String = ""
var position: Array = [0, 0]
var attack_range: int = 3
var damage_per_shot: int = 1
var shots_fired: int = 0
var target_history: Array = []

func configure(id_value: String, start_position: Array, range_value: int = 3, damage_value: int = 1) -> void:
	turret_id = id_value
	position = [int(start_position[0]), int(start_position[1])]
	attack_range = range_value if range_value > 0 else 1
	damage_per_shot = damage_value if damage_value > 0 else 1
	shots_fired = 0
	target_history = []

func get_position() -> Array:
	return position.duplicate()

func _distance_to(agent) -> int:
	var agent_position = agent.get_position()
	var dx = position[0] - agent_position[0]
	if dx < 0:
		dx = -dx
	var dy = position[1] - agent_position[1]
	if dy < 0:
		dy = -dy
	return dx + dy

func _is_valid_target(agent) -> bool:
	if agent == null:
		return false
	if not agent.has_method("is_active") or not agent.has_method("is_destroyed"):
		return false
	return agent.is_active() and not agent.is_destroyed()

func _select_target(agents: Array):
	var best_target = null
	var best_distance = attack_range + 1
	var best_agent_id = ""

	for agent in agents:
		if not _is_valid_target(agent):
			continue

		var distance = _distance_to(agent)
		if distance > attack_range:
			continue

		var agent_id = agent.get_agent_id()
		if best_target == null or distance < best_distance or (distance == best_distance and String(agent_id) < best_agent_id):
			best_target = agent
			best_distance = distance
			best_agent_id = String(agent_id)

	return best_target

func fire(agents: Array) -> Dictionary:
	var target = _select_target(agents)
	if target == null:
		return {
			"fired": false,
			"target_id": "",
			"target_position": [],
		}

	target.take_damage(damage_per_shot)
	shots_fired += 1
	var target_position = target.get_position()
	var target_id = target.get_agent_id()
	target_history.append({
		"target_id": target_id,
		"target_position": target_position.duplicate(),
		"damage": damage_per_shot,
	})
	return {
		"fired": true,
		"target_id": target_id,
		"target_position": target_position.duplicate(),
		"damage": damage_per_shot,
	}

func get_target_history() -> Array:
	return target_history.duplicate(true)

func to_snapshot() -> Dictionary:
	return {
		"turret_id": turret_id,
		"position": position.duplicate(),
		"attack_range": attack_range,
		"damage_per_shot": damage_per_shot,
		"shots_fired": shots_fired,
		"target_history": target_history.duplicate(true),
	}
