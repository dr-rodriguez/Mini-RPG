# Transition & Scene-Change — Improvement Checklist

Review of `main_game.gd` / `main_game.tscn` scene-change + transition logic, reformatted as
an actionable checklist. Line numbers reference the current `main_game.gd`.

## Verdict

Works for the current 2-level + battle setup. Well-designed parts:

- Player persists under `World/EntityRoot` across swaps instead of being re-instanced.
- Signal-based decoupling (`GameState.level_change_requested` / `battle_requested`) is the right pattern.
- `call_deferred` correctly avoids freeing a level mid-physics-callback.
- `_restore_level` defensively null-checks `get_tree()` for the quit-from-battle case.

Biggest remaining risks: re-entrancy and a missing `load()` null check.

---

## 🔴 Correctness

- [x] ~~Use `get_node_or_null("LevelFX")`~~ — **already fixed** (`:108`, `:131`). `Level1.tscn`
  has no `LevelFX` node; `get_node_or_null` avoids "Node not found" error spam.

- [ ] **Add a re-entrancy guard.** Nothing prevents a second transition from starting while
  one is in flight — two fast level-change emits run `_swap_level` concurrently (both `await`
  the same `FadeScreen`, both iterate `Levels` and `queue_free`), and a `battle_requested`
  mid-`_swap_level` fights over `FadeScreen` and `get_tree().paused`. Wire up the existing-but-
  unused `GameState.transition_scene` flag (`game_state.gd:15`): `if transition_scene: return`,
  set on entry / clear on exit around `_swap_level` (`:63`) and `_on_battle_requested` (`:100`).

- [ ] **Null-check `load(scene_path)`** (`:72`). A bad/renamed path makes `load()` return null
  and `.instantiate()` crash — after the screen has faded to black, leaving you stuck on black.
  On failure, fade back in instead of crashing.

## 🟠 Scalability / Architecture

- [ ] **Extract a `SceneLoader` / `TransitionManager` autoload** owning the fade + swap + battle
  stack. Centralizes the re-entrancy guard, lets any scene request a transition without
  `main_game` mediating, and thins the root controller. Already on the `CLAUDE.md` TODO.
  Highest-value refactor for growth.

- [ ] **Remove redundant `add_to_group("Levels")`** (`:73`). Both `Level1.tscn` and `Level2.tscn`
  already declare `groups=["Levels"]` (inherited on instance). Pick one home — the `.tscn`.

- [ ] **Centralize hardcoded scene paths.** `level_1.gd:13`, `level_2.gd:6`, the `LEVEL_MUSIC`
  dict (`main_game.gd:14-18`), the Level1 lookup (`:32`), and the `Battle.tscn` string (`:118`)
  all hardcode `res://...`. A level-registry resource (enum/key → path) or exported scene refs
  would centralize it and survive renames.

## 🟡 Style / Conventions

- [ ] `connect("pressed", ...)` (`:29`) → Godot 4 Callable syntax:
  `%DebugButton.pressed.connect(_on_debug_button_pressed)`.
- [ ] Type the untyped vars — `player_menu` (`:3`), `fade_screen` (`:6`), and locals `level`
  (`:106`) / `battle` (`:118`) — to match the rest of the file.
- [ ] Move regular vars (`player_menu_visible`, `current_track`, `level_track`, `music_tween`,
  `:9-12`) above the `@onready` block.
- [ ] Add `-> void` to `_on_battle_requested` (`:100`).
- [ ] Clarify `fade_tween`'s `duration` param — it tweens `duration/2.0` (`:89`, `:95`), so a
  0.6 call fades 0.3s each way.

## Top 3 fixes, by impact

1. **Add the re-entrancy guard** (wire up `transition_scene`) — kills the concurrency bugs.
2. **Null-check `load(scene_path)`** — avoids the stuck-on-black-screen crash.
3. **Extract a `SceneLoader` / `TransitionManager` autoload** — the structural move that makes
   everything above scale, and it's already on the TODO list.
