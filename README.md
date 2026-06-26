# game_dev
a repository for a indie game dev idea

## Godot scaffold

This workspace contains a minimal Godot 4 scaffold for the Antigravity-style backend prototype.

Run headless tests with:

```bash
# Use `godot` or `godot4` depending on your installation
godot --headless -s tests/test_tick_engine.gd
godot --headless -s tests/test_world_state.gd
```

Files added:

- `project.godot` — minimal project settings
- `scenes/data_grid.tscn` — data-only scene referencing `scripts/grid.gd`
- `scripts/tick_engine.gd` — deterministic tick engine (logic-only)
- `scripts/grid.gd` — grid data model
- `scripts/conveyor_segment.gd` — minimal conveyor placeholder
- `tests/test_tick_engine.gd` — tick-engine headless test runner
- `tests/test_world_state.gd` — world-state, flow-field, swarm, and turret test runner

