extends Node
class_name FlowField

const Grid = preload("res://scripts/grid.gd")
var DIRECTION_ORDER := [[1, 0], [0, 1], [-1, 0], [0, -1]]
var DIRECTION_NAMES := {
	"0,0": "none",
	"1,0": "right",
	"0,1": "down",
	"-1,0": "left",
	"0,-1": "up",
}

var width: int = 1
var height: int = 1
var distances: Array = []
var directions: Array = []

func _init(w: int = 1, h: int = 1) -> void:
	resize(w, h)

func resize(w: int, h: int) -> void:
	width = w if w > 0 else 1
	height = h if h > 0 else 1
	_allocate_buffers()

func _allocate_buffers() -> void:
	distances = []
	directions = []
	distances.resize(width * height)
	directions.resize(width * height)
	for index in range(width * height):
		distances[index] = -1
		directions[index] = [0, 0]

func _index(x: int, y: int) -> int:
	return x + y * width

func _is_blocked(grid, x: int, y: int) -> bool:
	return grid.get_tile_type(x, y) == Grid.TileType.WALL

func _is_valid_goal(grid, goal) -> bool:
	return grid.is_in_bounds(goal[0], goal[1]) and not _is_blocked(grid, goal[0], goal[1])

func build_from_grid(grid, goals: Array) -> void:
	resize(grid.width, grid.height)

	var queue: Array = []
	for goal_value in goals:
		if typeof(goal_value) != TYPE_ARRAY or goal_value.size() < 2:
			continue
		var goal = goal_value
		if not _is_valid_goal(grid, goal):
			continue
		var goal_index := _index(goal[0], goal[1])
		if distances[goal_index] != 0:
			distances[goal_index] = 0
			directions[goal_index] = [0, 0]
			queue.append(goal)

	var queue_head := 0
	while queue_head < queue.size():
		var current = queue[queue_head]
		queue_head += 1
		var current_distance = int(distances[_index(current[0], current[1])])

		for direction in DIRECTION_ORDER:
			var neighbor = [current[0] + direction[0], current[1] + direction[1]]
			if not grid.is_in_bounds(neighbor[0], neighbor[1]):
				continue
			if _is_blocked(grid, neighbor[0], neighbor[1]):
				continue

			var neighbor_index = _index(neighbor[0], neighbor[1])
			if distances[neighbor_index] != -1:
				continue

			distances[neighbor_index] = current_distance + 1
			queue.append(neighbor)

	for y in range(height):
		for x in range(width):
			var index := _index(x, y)
			if distances[index] <= 0:
				directions[index] = [0, 0]
				continue

			var best_distance = distances[index]
			var best_direction = [0, 0]
			for direction in DIRECTION_ORDER:
				var neighbor = [x + direction[0], y + direction[1]]
				if not grid.is_in_bounds(neighbor[0], neighbor[1]):
					continue
				if _is_blocked(grid, neighbor[0], neighbor[1]):
					continue

				var neighbor_distance = distances[_index(neighbor[0], neighbor[1])]
				if neighbor_distance >= 0 and neighbor_distance < best_distance:
					best_distance = neighbor_distance
					best_direction = direction

			directions[index] = best_direction

func get_distance(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return -1
	return distances[_index(x, y)]

func get_direction(x: int, y: int) -> Array:
	if x < 0 or y < 0 or x >= width or y >= height:
		return [0, 0]
	return directions[_index(x, y)]

func get_direction_name(x: int, y: int) -> String:
	var direction = get_direction(x, y)
	return DIRECTION_NAMES.get("%s,%s" % [direction[0], direction[1]], "none")

func to_snapshot() -> Dictionary:
	var rows: Array = []
	for y in range(height):
		var row: Array = []
		for x in range(width):
			row.append({
				"distance": get_distance(x, y),
				"direction": get_direction_name(x, y),
			})
		rows.append(row)

	return {
		"width": width,
		"height": height,
		"rows": rows,
	}
