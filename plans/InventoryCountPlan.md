# Plan: Inventory item-count helper + Slimey potion top-up

## Context

The quest NPC (Slimey) should help the player stay stocked on health potions: if
the player has fewer than 2 potions, Slimey tops them up to 2; if they already have
2 or more, Slimey refuses. To do this we need a way to **count a specific item** in
the player's inventory — which `Inventory` (`src/resources/scripts/inventory.gd`)
currently can't do; it only supports `add`/`remove`.

Key fact that makes counting easy: the inventory stores **shared `Item` resource
references**. Every health potion in the bag is the *same* object,
`Items.HEALTH_POTION` (see `player_data.gd:22-23` adding it twice, and
`items.gd:4`). So counting is just identity comparison (`i == item`), and "giving a
potion" is `inventory.add(Items.HEALTH_POTION)`.

The NPC is fully dialogue-driven: `quest_npc.gd:_on_interact` just opens the balloon
for `quest.dialogue`. The Dialogue Manager supports `if/else` conditions and `$>`
mutations that call into autoloads, so the give/refuse branch lives in the dialogue
file.

## Checklist

### 1. Add counting + top-up helpers to `Inventory`
File: `src/resources/scripts/inventory.gd`

- [ ] Add a `count(item)` helper
- [ ] Add a `fill_to(item, target)` helper

Append two helpers next to the existing `add`/`remove`:

```gdscript
## Count how many of a specific item are in the inventory.
## Works because items are shared Item resource references
## (every health potion is the same Items.HEALTH_POTION object).
func count(item: Item) -> int:
	var total := 0
	for i in items:
		if i == item:
			total += 1
	return total


## Add copies of `item` until the inventory holds `target` of them.
## Returns how many were actually added (0 if already at/above target).
func fill_to(item: Item, target: int) -> int:
	var to_add := maxi(0, target - count(item))
	for n in to_add:
		add(item)
	return to_add
```

### 2. Wire the give/refuse branch into `quest.dialogue`
File: `src/resources/dialogue/quest.dialogue`

- [ ] Add a potion-check `if/else` branch to Slimey's greeting
- [ ] Confirm condition uses `count(...)` and the `$>` mutation uses `fill_to(...)`

Example placement: as part of Slimey's greeting, after the existing
`if (not GameState.met_slimey)` block. The condition reads the count via the new
helper; the `$>` mutation tops the player up:

```
if (PlayerData.inventory.count(Items.HEALTH_POTION) < 2)
	$> PlayerData.inventory.fill_to(Items.HEALTH_POTION, 2)
	Slimey: You look low on potions. Here, take enough to make two.
else
	Slimey: You've already got two potions — save them for the woods.
```

The UI updates automatically next time the inventory panel rebuilds
(`ui_inventory.gd:_update_items` iterates `PlayerData.inventory.items`); no extra
refresh call is needed unless the panel is open during dialogue.

> Note: the constant `2` is intentionally inline to keep the example simple. If you
> prefer a named goal, add `const POTION_GOAL := 2` somewhere and use
> `fill_to(..., POTION_GOAL)`.

### 3. (Fallback) Flat wrappers if the dialogue parser balks
File: `src/core/autoload/player_data.gd`

- [ ] Only if needed: add `potion_count()` / `fill_potions()` wrappers and call those from the dialogue

If Dialogue Manager has trouble parsing `PlayerData.inventory.count(...)` inside a
condition, add a flat wrapper on the `PlayerData` autoload and call that from the
dialogue instead:

```gdscript
func potion_count() -> int:
	return inventory.count(Items.HEALTH_POTION)

func fill_potions(target: int) -> int:
	return inventory.fill_to(Items.HEALTH_POTION, target)
```

Then the dialogue becomes `if (PlayerData.potion_count() < 2)` /
`$> PlayerData.fill_potions(2)`.

## Verification

- [ ] Run the main scene in Godot 4.6
- [ ] First talk to Slimey: he **refuses** (player starts with exactly 2 potions — `player_data.gd:22-23`)
- [ ] Use/remove potions down to 0 or 1, talk again: Slimey tops you back up to 2; inventory panel shows 2
- [ ] Talk again at 2 potions: he refuses and does not add more
- [ ] (Optional) Temporarily `print(PlayerData.inventory.count(Items.HEALTH_POTION))` in `quest_npc.gd:_on_interact` to log the count, then remove it
