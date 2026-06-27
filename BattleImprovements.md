# Battle System Improvements

A phased checklist for cleaning up `src/levels/battle.gd` and its sub-scenes
(`battle_state.gd`, `player_turn.gd`, `enemy_turn.gd`). Each tier is
independently shippable — stop wherever the code feels clear enough.

## Why this exists

The battle works, but the control flow is hard to follow because **ownership
direction is inconsistent**:

- The state nodes (`player_turn.gd` / `enemy_turn.gd`) grab the parent via
  `@onready var battle: Battle = owner` and then mutate its internals directly:
  `battle.player_anim`, `battle.run_timer()`, `battle.on_cooldown`,
  `battle.change_label_text.emit(...)`, `battle.enemy_defeated.emit()`,
  `battle.battle_state.change_state(...)`. The states drive the parent instead of
  being driven by it.
- `battle.gd` reaches back *down* with a hardcoded path:
  `$BattleState/PlayerTurn.damage_enemy(value)` — and `damage_enemy` doesn't even
  conceptually belong on the *player* state.
- `change_label_text` and `enemy_defeated` are emitted and consumed by the **same
  node**, so they're disguised method calls, not real decoupling.
- The state machine is thin (no `exit()`, `CHECK_END` is commented out), so
  "whose turn is next?" and "is anyone dead?" logic is smeared across three files.

Recommended stopping point for a learning project: **end of Tier 2.**

---

## Tier 0 — Bug fixes (do first; small and high-value)
- [x] REJECTED. Connect `PlayerData.player_died` in `battle.gd._ready()` and handle it
      (show log, then route to game-over / leave battle). It is currently emitted
      but never connected, so the player dying on the enemy's turn does nothing.
- [x] Apply the cooldown/turn guard consistently: block `_use_item()` and
      `_on_flee_pressed()` while `on_cooldown` (or while it isn't the player's
      turn), the same way `PlayerTurn.do_attack()` already does.
- [x] Pick ONE input-lock mechanism (button `disabled` vs `on_cooldown`) as the
      source of truth and make the other follow it, so they can't disagree.

## Tier 1 — Quick cleanups (readability, no structural change)
- [x] Replace the `change_label_text` self-signal with a plain
      `set_log(text: String)` method on Battle; update all `*.emit(...)` callers.
- [x] Replace the `enemy_defeated` self-signal with a direct method call
      (e.g. rename `_on_enemy_defeated()` → `handle_enemy_defeated()` and call it).
- [x] Remove `@onready` from plain-literal vars (`on_cooldown`, `log_text`).
- [x] Extract the opposed roll into one helper
      `opposed_check(a_mod: int, b_mod: int) -> bool` and reuse it in
      `roll_initiative()` and `_on_flee_pressed()` (the `randi_range(1,20)+dex`
      contest currently appears 3×).
- [x] Remove the dead `log_text` field(s) that aren't actually read.
- [x] Replace the hardcoded `$BattleState/PlayerTurn.damage_enemy(value)` path
      (resolved properly in Tier 2 by moving `damage_enemy` off the player state).

## Tier 2 — Structural refactor (clarify ownership)
- [x] Stop the state nodes from reaching into `owner`. Give states a small,
      explicit context (pass `battle` into `enter()`/actions, or expose a narrow
      API on Battle) instead of touching the parent's internals.
- [x] Make the turn manager own transitions. Add `enter()`/`exit()`; have states
      *return* or *request* the next state rather than calling
      `battle_state.change_state(...)` themselves.
- [x] Reinstate a single end-of-turn resolution step (the commented-out
      `CHECK_END`): one place that asks "is anyone at 0 HP?" and routes to
      victory / defeat, removing the duplicated death checks in
      `player_turn.damage_enemy()`, `enemy_turn.enter()`, and the `do_attack`
      guards.
- [x] Move `damage_enemy()` to where damage is owned (Battle or a combat helper),
      not on `PlayerTurn`; have both player attack and item use call it.
- [x] Rename `BattleState` → `TurnManager` (and the `battle_state` var) to match
      what it actually does.

## Tier 3 — Optional deeper architecture (most learning, most churn)
- [ ] Introduce a `Combatant` abstraction (interface or wrapper) unifying player
      and enemy: `stats`, `health`, `roll_attack()`, `roll_damage()`,
      `take_damage()`, `play_anim()`. Player is `PlayerData` (autoload), enemy is
      a node — their interfaces are nearly identical but accessed differently
      (`PlayerData.stats` / `PlayerData.health` vs `enemy.data.stats` /
      `enemy.health`), which currently blocks sharing code.
- [ ] Collapse `player_turn.gd` + `enemy_turn.gd` into a single parametrized
      attack-resolution routine taking `attacker`/`defender` Combatants (they are
      near-mirror images today).
- [x] Move item effects onto the item resources (target + apply), so `_use_item`
      no longer `match`es on `item.name` (`"Health Potion"` / `"Red Gem"`).
      Adding an item should not require editing the battle controller.
- [ ] Split UI out of `battle.gd` into a `BattleHUD` controller (item-button
      building in `_update_items`, log label, health label, button enable/disable),
      leaving Battle to orchestrate combat only.
