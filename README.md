---
cover: static/cover.webp
itchio: https://gdquest-demos.itch.io/Godot-4-Character-3D-Demo
tags: 3D third-person-shooter shooter controller
description: "A 3D Third Person Shooter Controller Demo"
---

# RoboBlast: Third-Person Shooter demo (Godot 4, 3D)

![](static/third-person-shooter-demo.webp)

This open-source Godot 4 demo shows how to create a 3D character controller inspired by games like Ratchet and Clank or Jak and Daxter. You can copy the character to your project as a plug-and-play asset to prototype 3D games with and build upon.

It features a character that can run, jump, make a melee attack, aim, shoot, and throw grenades.

![](static/third-person-character-aiming-grenade.webp)

There are two kinds of enemies: flying wasps that fire bullets and beetles that attack you on the ground. The environment comes with breakable crates, jumping pads, and coins that move to the player's character.

## How to run:

1. Download or clone the GitHub repository.
2. Press <kbd>F5</kbd> or `Run Project`.

## Controls:

- <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd> or <kbd>left stick</kbd> to move.
- <kbd>mouse</kbd> or <kbd>right stick</kbd> to move the camera around.
- <kbd>Space</kbd> or <kbd>Xbox Ⓐ</kbd> to jump.
- <kbd>Left mouse</kbd> or <kbd>Xbox Ⓑ</kbd> to shoot.
- <kbd>Right mouse</kbd> or <kbd>Xbox RT</kbd>to aim.
- <kbd>Tab</kbd> or <kbd>Xbox Ⓧ</kbd> to cycle between bullets and grenades.

## FAQ:

### How do I use the player character in my game?

Copy the following folders into the root of your project:

- `Player`: contains the main Player assets and scenes.
- `shared`: contains shaders used by the player asset.

The following `Input Map` actions are needed for the `Player.tscn` to work:

- `move_left`, `move_right`, `move_up`, `move_down`: move the character according to the camera's orientation.
- `camera_right`, `camera_left`, `camera_up`, `camera_down`: rotate the camera around the character.
- `jump`, `attack`, `aim`, `swap_weapons`: Action buttons for the character.

The `Player.tscn` scene works as a standalone scene and doesn't need other cameras to work. You can change the player UI by changing the `Control` node inside `Player.tscn`.

## License:

All code is MIT-licensed, and assets are CC-By 4.0 [GDQuest](https://www.gdquest.com/).
