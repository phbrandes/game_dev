extends Node
class_name PersistenceManager

class SessionData:
	extends Object

	var run_seed: int = 0
	var factory_layout: Dictionary = {}
	var active_inventory: Dictionary = {}
	var run_stats: Dictionary = {}

	func snapshot() -> Dictionary:
		return {
			"run_seed": run_seed,
			"factory_layout": factory_layout.duplicate(true),
			"active_inventory": active_inventory.duplicate(true),
			"run_stats": run_stats.duplicate(true),
		}

class GlobalProfile:
	extends Object

	var schema_version: int = 1
	var unlocked_upgrades: Array = []
	var meta_currency: int = 0
	var total_runs: int = 0

	func snapshot() -> Dictionary:
		return {
			"schema_version": schema_version,
			"unlocked_upgrades": unlocked_upgrades.duplicate(),
			"meta_currency": meta_currency,
			"total_runs": total_runs,
		}

var session: SessionData = null
var profile: GlobalProfile = GlobalProfile.new()

func start_run(run_seed: int = 0) -> SessionData:
	session = SessionData.new()
	session.run_seed = run_seed
	session.factory_layout = {}
	session.active_inventory = {}
	session.run_stats = {
		"ticks_survived": 0,
		"enemies_defeated": 0,
	}
	return session

func commit_run(delta: Dictionary) -> void:
	if delta.has("meta_currency"):
		profile.meta_currency += int(delta["meta_currency"])
	if delta.has("unlocked_upgrades"):
		for upgrade in delta["unlocked_upgrades"]:
			var upgrade_name := String(upgrade)
			if not profile.unlocked_upgrades.has(upgrade_name):
				profile.unlocked_upgrades.append(upgrade_name)
	if delta.has("total_runs"):
		profile.total_runs += int(delta["total_runs"])

func wipe_run() -> void:
	session = null

func serialize_profile() -> Dictionary:
	return profile.snapshot()

func serialize_session() -> Dictionary:
	if session == null:
		return {}
	return session.snapshot()
