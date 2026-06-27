# Transition & Scene-Change Review — Improvement Plan

Review of `main_game.gd` / `main_game.tscn` scene-change + transition logic, with
suggested improvements to implement gradually.

## Verdict

Works for the current 2-level + battle setup. Several things are well-designed:

- Player persists under `World/EntityRoot` across swaps instead of being re-instanced.
- Signal-based decoupling (`GameState.level_change_requested` / `battle_requested`) is the right pattern.
- `call_deferred` correctly avoids freeing a level mid-physics-callback.
- `_restore_level` defensively null-checks `get_tree()` for the quit-from-battle case.

But not yet stable or scalable as-is. Biggest risks: re-entrancy and a latent error on Level1.

---

## 🔴 Correctness risks

### 1. `get_node("LevelFX")` errors on Level1 — `main_game.gd:86` and `:106`
`Level1.tscn` has no `LevelFX` node (only `Level2` does). `get_node()` on a missing path
pushes a "Node not found" error and returns null. The `if fx:` guard means gameplay still
works, but it spams errors every time you start/end a battle on Level1.

**Fix:** use `get_node_or_null("LevelFX")` in both spots. The `if fx:` checks show that was
the intent anyway.

### 2. No re-entrancy guard on transitions — the scalability killer
Nothing prevents a second transition from starting while one is in flight:

- Two fast level-change emits → two `_swap_level` coroutines run concurrently, both `await`
  tweens on the *same* `FadeScreen`, both iterate the `Levels` group and `queue_free` — can
  free a half-built level or end on the wrong fade alpha.
- A `battle_requested` arriving mid-`_swap_level` (or vice-versa) fights over the shared
  `FadeScreen` and over `get_tree().paused`.

`GameState.transition_scene: bool` already exists (`game_state.gd:15`) and is never used —
looks like the guard was planned and never wired. A single `if _transitioning: return` /
set-and-clear flag around both `_swap_level` and `_on_battle_requested` closes this.

### 3. No validation on `load(scene_path)` — `main_game.gd:54`
A bad/renamed path makes `load()` return null and `.instantiate()` crashes — after the screen
has already faded to black, so you're stuck on a black screen. Add a null check that fades
back in on failure.

---

## 🟠 Scalability / architecture

### 4. `main_game.gd` is becoming a god object
It owns level swapping, battle entry/exit, menu toggling, and debug UI. `CLAUDE.md` lists
`SceneLoader` as a planned autoload, and this is exactly the logic that belongs there.
Extracting a `TransitionManager` / `SceneLoader` autoload (owning the fade + swap + battle
stack) would: centralize the re-entrancy guard, let any scene request a transition without
`main_game` mediating, and keep the root controller thin. Highest-value refactor for growth.

### 5. Redundant group management — `main_game.gd:55`
`new_level.add_to_group("Levels")` is redundant — both `Level1.tscn` and `Level2.tscn`
already declare `groups=["Levels"]` in the scene file (inherited on instance). Harmless now,
but level membership is defined in two places; pick one (the `.tscn` is the better home).

### 6. Hardcoded scene paths scattered across level scripts
`level_1.gd`, `level_2.gd`, and the battle path string in `main_game.gd:93` all hardcode
`res://...` strings. As levels multiply this gets fragile. A small level-registry resource
(enum/key → path) or exported scene refs would centralize it and survive renames.

---

## 🟡 Style / conventions

- **`main_game.gd:16`** — `connect("pressed", ...)` uses the old string-signal API. Prefer
  Godot 4 Callable syntax: `%DebugButton.pressed.connect(_on_debug_button_pressed)`.
- **Untyped vars** — `player_menu`, `fade_screen` (`:3`, `:6`) and the `battle`/`level`/`fx`
  locals are untyped while the rest of the file is typed. Keep typing consistent within a file.
- **Member order — `main_game.gd:7`** — `player_menu_visible` (regular var) sits below the
  `@onready` block; convention is regular vars above `@onready`.
- **`_on_battle_requested` missing `-> void`** (`:78`) while the rest of the file annotates returns.
- **`fade_tween` param naming** — `duration` is misleading since you tween `duration/2.0`; a
  0.6 call actually fades in 0.3s each way.

---

## Top 3 fixes, by impact

1. **Add a transition guard** (wire up the existing `transition_scene` flag) around
   `_swap_level` and `_on_battle_requested` — kills the concurrency bugs.
2. **`get_node` → `get_node_or_null` for `LevelFX`** (`:86`, `:106`) — stops real error spam
   on Level1.
3. **Extract a `SceneLoader` / `TransitionManager` autoload** — the structural move that makes
   everything above scale, and it's already on the TODO list.
