extends Object
class_name TestCleanupHelper

var tracked_objects: Array = []
var tracked_resources: Array = []

func track_object(obj):
	if obj != null:
		tracked_objects.append(obj)
	return obj

func load_script(path: String):
	var script_res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if script_res != null:
		tracked_resources.append(script_res)
	return script_res

func cleanup() -> void:
	for index in range(tracked_objects.size() - 1, -1, -1):
		var obj = tracked_objects[index]
		if obj != null and is_instance_valid(obj) and obj.has_method("free"):
			obj.free()
	tracked_objects.clear()

	for index in range(tracked_resources.size() - 1, -1, -1):
		tracked_resources[index] = null
	tracked_resources.clear()
