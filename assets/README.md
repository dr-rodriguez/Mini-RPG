# Assets

Game assets for Mini-RPG: art, audio, fonts, and other media used by scenes and resources.

> **Note:** Asset files are intentionally **not committed** to this repository to avoid infringing on distribution rights for third-party assets. See the main [README](../README.md) for links to where these assets can be obtained.

## Example Folder Layout

```
assets/
  art/
    characters/
      enemies/      # enemy sprites, spritesheets, animations
      npcs/         # non-player character sprites
      player/       # player sprites, spritesheets, animations
    ui/
      fonts/        # bitmap and TrueType/OpenType fonts
      icons/        # HUD and menu icons
    world/
      backgrounds/  # parallax layers, scene backdrops
      tilesets/     # tilemap source images
  audio/
    music/          # background tracks, looping ambience
    sfx/            # sound effects (hits, pickups, UI)
```

Add new subfolders as the project grows (e.g. `art/effects/` for particles, `audio/voice/` for voice lines, etc.).
