---
title: P4 AAU project - Penguin Lang for the Nintendo Game Boy
date: 2026-02-23
slug: p4-penguin
tags: [university, pyhton, sm83]
draft: false
summary: Fourth Semester.
gitlinks: [https://https://github.com/cs-25-sw-4-15/penguinlang]
---

# Penguin Lang (Spring 2025)

The fourth semester of the bachelor is all about creating a working programming language. We decided to make the programming language "Penguin" — because all programming should relate to animals. This is a domain-specific programming language that tries to abstract the hardware of the Game Boy. It compiles down to [SM83 assembly](https://gbdev.io/gb-opcodes/optables/) (it is a freak child of [Z80 and Intel 8080](https://en.wikipedia.org/wiki/Game_Boy#Technical_specifications) — at least the processor is), and from there the [RGBDS](https://rgbds.gbdev.io/) toolchain creates a ROM for it, which can be run on an emulator or on the real hardware.

## Technologies

- ANTLR4 (Python runtime)
- SM83 assembly
- RGBDS
- Compiler frontend and backend

## Abstract (From Project Report)

This project set out to address the nostalgia many people have for retro gaming devices, with a specific focus on the Nintendo Game Boy. The console and its emulators are still used today, but developing for them requires programmers to write in low-level SM83 assembly language and to understand the Game Boy’s hardware in detail. As of 2025, assembly language is neither widely taught nor commonly used, which has resulted in a steep learning curve for programmers who want to develop for the Game Boy. The goal of this project is to design and implement PENGUIN, a statically typed imperative programming language that compiles to SM83 assembly. PENGUIN abstracts away hardware complexity by introducing more accessible higher-level constructs to make Game Boy development more approachable, while it retains low-level control over the hardware. While some features are still unimplemented, PENGUIN represents a solid first step toward making Game Boy development more accessible through higher-level abstractions.

## Code Examples

### Penguinoid

A remake of the ["Unbricked" game written in GM ASM tutorial](https://gbdev.io/gb-asm-tutorial/part2/getting-started.html) in 100% Penguin code. Unbriked itself is a [Breakout](https://en.wikipedia.org/wiki/Breakout_(video_game))/[Arkanoid](https://en.wikipedia.org/wiki/Arkanoid) clone. 

```c
tileset tileset_block_0 = "penguinoid_tileset.2bpp";
tileset tileset_block_2 = "penguinoid_tileset.2bpp";
tilemap tilemap0 = "penguinoid_tilemap.bin";

control_waitVBlankStart();
control_LCDoff();

display_tileset_block_0 = tileset_block_0;
display_tileset_block_2 = tileset_block_2;
display_tilemap0 = tilemap0;

int BRICK_LEFT = 5;
int BRICK_RIGHT = 6;
int BLANK_TILE = 8;
int WALL_RIGHT = 7;
int WALL_LEFT = 4;
int WALL_BOTTOM = 9;
int WALL_TOP = 1;
int TOP_RIGHT_CORNER = 0;
int TOP_LEFT_CORNER = 2;

int paddleX = 16;
int paddleY = 145;
int ballX = 25;
int ballY = 100;

int i = 0;
loop (i < 40) {
    display_oam_y[i] = 0;
    i = i + 1;
}

display_oam_tile[0] = 10;
display_oam_x[0] = paddleX;
display_oam_y[0]= paddleY;
display_oam_tile[1] = 11;
display_oam_x[1] = ballX;
display_oam_y[1] = ballY;

int Xtile = 0;
int Ytile = 0;
int Xmomentum = 1; // 1 = right, 2 = left
int Ymomentum = 2; // 1 = down, 2 = up
int tile = 0;
int left = 0;
int right = 0;

procedure handleWallCollision() {
    if (tile == WALL_LEFT or tile == WALL_RIGHT or tile == TOP_LEFT_CORNER or tile == TOP_RIGHT_CORNER) {
        if (Xmomentum == 1) {
            Xmomentum = 2;
        } else {
            Xmomentum = 1;
        }
    }

    if (tile == WALL_TOP or tile == WALL_BOTTOM) {
        if (Ymomentum == 1) {
            Ymomentum = 2;
        } else {
            Ymomentum = 1;
        }
    }
}

procedure handleBrickCollision() {
    if (tile == BRICK_LEFT or tile == BRICK_RIGHT) {
        display_tilemap0[Xtile][Ytile] = BLANK_TILE;
        if (Ymomentum == 1) {
            Ymomentum = 2;
        } else {
            Ymomentum = 1;
        }
        control_waitVBlankOver();
        control_waitVBlankStart();
        if (tile == BRICK_LEFT) {
            display_tilemap0[Xtile+1][Ytile] = BLANK_TILE;
        } else {
            display_tilemap0[Xtile-1][Ytile] = BLANK_TILE;
        }
    }
}

procedure handlePaddleCollision() {
    if (ballX <= (paddleX+8)) {
        if (ballX >= (paddleX - 8)) {
            if (((ballY+5) >= 145)) {
                if (((ballY+3) <= 145)) {
                    if (Ymomentum == 1) {
                        Ymomentum = 2;
                    }
                }
            }
            if (((ballY) >= 145)) {
                if (((ballY-3) <= 145)) {
                    if (Ymomentum == 2) {
                        Ymomentum = 1;
                    }
                }
            }
        }
    }
}

procedure updateBallPosition() {
    if (Xmomentum == 1) {
        ballX = ballX + 2;
    } else {
        ballX = ballX - 2;
    }
    if (Ymomentum == 1) {
        ballY = ballY + 2;
    } else {
        ballY = ballY - 2;
    }
}

procedure setBallAndPaddlePosition() {
    if (left) {
        if (paddleX > 16) {
            paddleX = paddleX - 2;
        }
    }
    if (right) {
        if (paddleX < 104) {
            paddleX = paddleX + 2;
        }
    }

    display_oam_x[1] = ballX;
    display_oam_y[1] = ballY;
    display_oam_x[0] = paddleX;
    display_oam_y[0] = 145;
}

procedure main() {
    int frame = 0;
    control_LCDon();
    control_initDisplayRegs();
    control_initPalette();

    loop (1) {
        control_waitVBlankOver();
        control_waitVBlankStart();

        if (frame == 0) {
            control_updateInput();
            left = control_checkLeft();
            right = control_checkRight();

            updateBallPosition();

            Xtile = (ballX-9) >> 3;
            Ytile = (ballY-16) >> 3;
            tile = display_tilemap0[Xtile][Ytile];

            handleBrickCollision();
            handleWallCollision();
            handlePaddleCollision();
            frame = 1;
        } else {
            if (frame == 1) {
                setBallAndPaddlePosition();
                frame = 0;
            }
        }
    }
}

main();
```

## Images

### Penguinoid / Unbricked

<figure class="md-figure">
    <img src="/public/img/thumbs/p4/penguinoid.png" alt="Screenshot of Penguinoid running on an emulator" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p4/penguinoid.png" loading="lazy">
    <figcaption>
        Screenshot of Penguinoid running on an emulator
    </figcaption>
</figure>