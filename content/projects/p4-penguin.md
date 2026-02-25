---
title: P4 AAU project - Penguin Lang for the Nintendo Game Boy
date: 2026-02-21
slug: p4-penguin
tags: [university, pyhton, sm83]
draft: false
summary: Fourth Semester.
gitlinks: [https://https://github.com/cs-25-sw-4-15/penguinlang]
---

# Penguin Lang (Spring 2025)

The fourth semster of the bechelor is all about creating a working programming language. We decided to make the programming language "Penguin" - because all of programming should relate to animals. This is a domain spesific programming language that tries to abstract the hardware of the Game Boy. It compiles down to [SM83 assembly](https://gbdev.io/gb-opcodes/optables/) (it is a freak child of [Z80 and Intel 8080](https://en.wikipedia.org/wiki/Game_Boy#Technical_specifications) - at least the processor is), from there the [RGBDS](https://rgbds.gbdev.io/) toolchain creates a ROM for it, which can be run on an emulator or the real hardware.

## Abstract

This project set out to address the nostalgia many people have for retro gaming devices, with a specific focus on the Nintendo Game Boy. The console and its emulators are still used today, but developing for them requires programmers to write in low-level SM83 assembly language and to understand the Game Boy’s hardware in detail. As of 2025, assembly language is neither widely taught nor commonly used, which has resulted in a steep learning curve for programmers who want to develop for the Game Boy. The goal of this project is to design and implement PENGUIN, a statically typed imperative programming language that compiles to SM83 assembly. PENGUIN abstracts away hardware complexity by introducing more accessible higher-level constructs to make Game Boy development more approachable, while it retains low-level control over the hardware. While some features are still unimplemented, PENGUIN represents a solid first step toward making Game Boy development more accessible through higher-level abstractions.

## Code Examples



## Images
