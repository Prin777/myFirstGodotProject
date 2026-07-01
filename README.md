# Tiny Swords Adventure

A small Godot 4 top-down melee adventure prototype planned around Pixel Frog's Tiny Swords asset pack.

## Controls

- Move: `WASD` or arrow keys
- Attack: left mouse button or `Space`
- Restart after victory/defeat: `R`

## Current state

The game loop is implemented and playable:

- Start screen
- One meadow combat map
- Player movement, melee attack, health, invulnerability, death
- Enemy patrol, detection, chase, attack, damage, death
- HUD with HP and remaining enemies
- Victory and defeat screens

The downloaded Tiny Swords free pack is expected under `assets/tiny_swords/Tiny Swords (Free Pack)/`.
The player uses the blue Warrior sprites, enemies use the red Warrior sprites, and the meadow map uses the pack's terrain and decoration images with simple collision shapes.
