extends Node
class_name Grid

enum TileType { EMPTY, BELT, MACHINE, POWER, WALL }

const TILE_TYPE_NAMES := {
    TileType.EMPTY: "empty",
    TileType.BELT: "belt",
    TileType.MACHINE: "machine",
    TileType.POWER: "power",
    TileType.WALL: "wall",
}

var width: int
var height: int
var cells: Array = []

func _init(w: int = 5, h: int = 3) -> void:
    width = w if w > 0 else 1
    height = h if h > 0 else 1
    _allocate_cells()

func _index(x: int, y: int) -> int:
    return x + y * width

func _allocate_cells() -> void:
    cells = []
    cells.resize(width * height)
    for i in range(width * height):
        cells[i] = _create_cell()

func _create_cell(tile_type: int = TileType.EMPTY) -> Dictionary:
    return {
        "tile_type": tile_type,
        "entity_id": "",
        "payload": null,
        "state": {},
    }

func is_in_bounds(x: int, y: int) -> bool:
    return x >= 0 and y >= 0 and x < width and y < height

func _assert_in_bounds(x: int, y: int) -> void:
    if not is_in_bounds(x, y):
        push_error("Grid coordinates out of bounds: (%s, %s)" % [x, y])

func _get_cell_index(x: int, y: int) -> int:
    _assert_in_bounds(x, y)
    return _index(x, y)

func set_tile_type(x: int, y: int, tile_type: int) -> void:
    if not TILE_TYPE_NAMES.has(tile_type):
        push_error("Invalid tile type: %s" % tile_type)
        return
    cells[_get_cell_index(x, y)]["tile_type"] = tile_type

func get_tile_type(x: int, y: int) -> int:
    return cells[_get_cell_index(x, y)]["tile_type"]

func set_entity_id(x: int, y: int, entity_id: String) -> void:
    cells[_get_cell_index(x, y)]["entity_id"] = entity_id

func get_entity_id(x: int, y: int) -> String:
    return cells[_get_cell_index(x, y)]["entity_id"]

func set_state(x: int, y: int, key: String, value) -> void:
    cells[_get_cell_index(x, y)]["state"][key] = value

func get_state(x: int, y: int) -> Dictionary:
    return cells[_get_cell_index(x, y)]["state"]

func get_cell_snapshot(x: int, y: int) -> Dictionary:
    var cell: Dictionary = cells[_get_cell_index(x, y)]
    return {
        "tile_type": TILE_TYPE_NAMES[cell["tile_type"]],
        "entity_id": cell["entity_id"],
        "payload": cell["payload"],
        "state": cell["state"].duplicate(true),
    }

func to_snapshot() -> Dictionary:
    var rows: Array = []
    for y in range(height):
        var row: Array = []
        for x in range(width):
            row.append(get_cell_snapshot(x, y))
        rows.append(row)

    return {
        "width": width,
        "height": height,
        "rows": rows,
    }

func clear_cell(x: int, y: int) -> void:
    cells[_get_cell_index(x, y)] = _create_cell()

func step() -> void:
    for obj in cells:
        if obj and obj["payload"] and obj["payload"].has_method("step"):
            obj["payload"].step()
