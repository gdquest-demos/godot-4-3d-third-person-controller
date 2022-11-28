# Platformer & Third Person Shooter Demo

![](_ignore/screenshot.png)

This project demonstrates a character controller reminiscent of [Ratchet & Clank](https://en.wikipedia.org/wiki/Ratchet_%26_Clank).

## Main Features:

- Player character with melee attacks and two weapons (gun and grenades).
- Light platforming mechanics.
- Enemies.
- Destructable boxes.

## How to run:

1. Download or clone the GitHub repository.
2. Press <kbd>F5</kbd> or `Run Project`.

## Controls:

- <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd> or *left stick* to move
- *mouse* or *right stick* to move the camera around
- <kbd>space</kbd> or <kbd>Xbox Ⓐ</kbd> to jump
- <kbd>left mouse</kbd> or <kbd>Xbox Ⓑ</kbd> to shoot
- <kbd>right mouse</kbd> or <kbd>Xbox RT</kbd>to aim
- <kbd>tab</kbd> or <kbd>Xbox Ⓧ</kbd> to cycle between bullets and grenades

## FAQ:

### How do I use the player character in my game?

Copy the following folders into the root of your project:

- `Player`: contains the main Player assets and scenes.
- `shared`: contains shaders that are used by the player asset.

The following `Input Map` actions are needed for the `Player.tscn` to work:

- `move_left, move_right, move_up, move_down`: Move character according to Camera orientation.
- `camera_right, camera_left, camera_up, camera_down`: Move character Camera around the player.
- `jump, attack, aim, swap_weapons`: Action buttons for the character.

The `Player.tscn` scene works as a standalone scene, and doesn't need other Cameras to work. You can change the player UI by changing the `Control` node inside `Player.tscn`.

## License:

Unless stated otherwise, all code is MIT licensed, and assets are CC-By 4.0.
