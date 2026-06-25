extends Node
class_name TickEngine

signal ticked(tick_count)

var ticks_per_second: int = 10
var max_ticks_per_frame: int = 5
var tick_count: int = 0
var _accumulator: float = 0.0

func _ready() -> void:
    set_process(true)

func tick() -> void:
    tick_count += 1
    emit_signal("ticked", tick_count)

func advance(delta: float) -> int:
    if delta <= 0.0:
        return 0

    var step_seconds := 1.0 / float(ticks_per_second)
    _accumulator += delta

    var processed := 0
    while _accumulator >= step_seconds and processed < max_ticks_per_frame:
        _accumulator -= step_seconds
        tick()
        processed += 1

    return processed

func _process(delta: float) -> void:
    advance(delta)

func reset() -> void:
    tick_count = 0
    _accumulator = 0.0

func set_tick_rate(value: int) -> void:
    ticks_per_second = max(1, value) as int

func get_accumulator() -> float:
    return _accumulator
