extends Node
class_name ConveyorSegment

var item = null
var next_segment: ConveyorSegment = null
var _reserved_inbound = null

func step() -> void:
    prepare_handshake()
    commit_handshake()

func can_accept() -> bool:
    return item == null and _reserved_inbound == null

func prepare_handshake() -> bool:
    if item == null or next_segment == null:
        return false
    if not next_segment.can_accept():
        return false

    next_segment._reserved_inbound = item
    return true

func commit_handshake() -> void:
    if _reserved_inbound != null and item == null:
        item = _reserved_inbound
        _reserved_inbound = null
        return

    if item != null and next_segment != null and next_segment._reserved_inbound == item:
        item = null
