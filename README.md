# HolyDino

A small recreation of the Chrome Dinosaur game written in **HolyC**, running on Arch Linux with SDL2.

This was a fun little experiment in vibe coding: I wanted to see if I could get Chrome Dino running in HolyC on my Linux setup, so I gave it a shot. I wasn't particularly interested in learning HolyC deeply — I just wanted to make the game work.

And, somehow, it did.

## Features

- Dinosaur jumping
- Cactus obstacles
- Collision detection
- Scrolling ground
- Score counter
- Game over screen
- Restart after losing

## Built With

- **HolyC** — game code
- **SDL2** — window and rendering
- **SDL2_image** — PNG sprite loading
- **Arch Linux** — development environment
- **No IDE** — written using terminal tools

## Requirements

- Arch Linux or a compatible Linux environment
- A compatible HolyC compiler (`hcc`)
- SDL2
- SDL2_image

## Running the Game

Clone the repository:

```bash
git clone https://github.com/DeltaDev310/HolyDino.git
cd HolyDino
```

Install the SDL2 dependencies on Arch Linux:

```bash
sudo pacman -S sdl2 sdl2_image
```

Install and configure a compatible HolyC compiler, then run:

```bash
hcc -jit Dino.HC
```

The game loads its sprites from the `assets/` directory, so keep that directory alongside `Dino.HC`.

## Controls

- **Space** — Jump; press again after losing to restart.
- **Escape** — Quit the game.

## Why?

Honestly, I just thought it would be funny to make Chrome Dino in HolyC.

This is a small experimental project, not an attempt to master the language *that's why i mostly used chatGPT to do it*.


## Credits

- Inspired by Google's Chrome Dinosaur game.
- Created by [DeltaDev310](https://github.com/DeltaDev310).

This is an unofficial fan project and is not affiliated with Google.
