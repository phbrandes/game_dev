extends Node
class_name SwarmAgent

var agent_id: String = ""
var position: Array = [0, 0]
var path_history: Array = []
var movement_speed: int = 1
var active: bool = true
var health: int = 3
var flow_field = null

func configure(id_value: String, start_position: Array, assigned_flow_field) -> void:
	agent_id = id_value
	position = [int(start_position[0]), int(start_position[1])]
	flow_field = assigned_flow_field
	path_history = [position.duplicate()]
	active = true

func set_position(new_position: Array) -> void:
	position = [int(new_position[0]), int(new_position[1])]
	path_history.append(position.duplicate())

func get_position() -> Array:
	return position.duplicate()

func get_path_history() -> Array:
	return path_history.duplicate(true)

func is_active() -> bool:
	return active and flow_field != null

func get_agent_id() -> String:
	return agent_id

func get_health() -> int:
	return health

func is_destroyed() -> bool:
	return health <= 0

func take_damage(amount: int) -> void:
	health -= amount if amount > 0 else 0
	if health <= 0:
		health = 0
		active = false

func _step_once() -> bool:
	if not is_active():
		return false

	var direction = flow_field.get_direction(position[0], position[1])
	if direction == [0, 0]:
		active = false
		return false

	position = [position[0] + direction[0], position[1] + direction[1]]
	path_history.append(position.duplicate())
	if flow_field.get_direction(position[0], position[1]) == [0, 0]:
		active = false
	return true

func step() -> void:
	for _step_index in range(max(1, movement_speed)):
		if not _step_once():
			break

func to_snapshot() -> Dictionary:
	return {
		"agent_id": agent_id,
		"position": position.duplicate(),
		"health": health,
		"active": active,
		"path_history": path_history.duplicate(true),
	}
