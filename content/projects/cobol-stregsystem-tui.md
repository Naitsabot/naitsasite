---
title: Stregsystem TUI Written in gnuCOBOL
date: 2026-03-15
slug: cobol-tui
tags: [gnucobol]
draft: false
summary: something with COBOL.
gitlinks: [https://github.com/Naitsabot/stregsystem-cob-tui]
---

# Stregsystem COBOL TUI

A terminal user interface for the F-Klubben stregsystem, written in GnuCOBOL with those nice punchcard limitations.

## The WHY?!

It seems as if every project I set out to do, documented or undocumented, I try to use some kind of framework, methods, and of course language that I have not tried before.

<figure class="md-figure">
    <img src="/public/thumbs/cobol/comic.png" alt="img" title="Availability Page" class="thumbable" data-full="/public/img/cobol/comic.png">
    <figcaption>
    <a href="https://web.archive.org/web/20230301151600/https://dilbert.com/strip/1997-11-04">Dilbert by Schott Adams 1997-11-04</a>
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>  

I have long heard about the COBOL language. It has been referenced as: the language where writing a `Hello, World!` program takes more lines than its corresponding assembly; the language whose syntax is so verbose because it was designed around the idea that managers reading their subordinates' code should be able to understand the programmes; the language running on the dinosaur in the basement that still haunts us to this day, running old and critical services on mainframes; and the language whose developers retire handsomely while their code does not.

Each one of these seems just all the more reason to try to make _something_ with it!

For the time I have been at Aalborg University, I have also been part of F-Klubben, the oldest student association on campus!  
One mantra, not to sound like a cult, spread around the sofas and fridges of F-Klubben, is to embrace scuffed stuff, and make more things. If you think of a funny idea, make it.

The most important system in F-Klubben is the [stregsystemet](https://github.com/f-klubben/stregsystemet), although as the F-ormand (committee leader) of F-oret, I would say it is the system for songbook creation: [sangbog](https://github.com/f-klubben/sangbog) and the newer [Typst sangbog](https://github.com/f-klubben/ftsongbook).  

<figure class="md-figure">
    <img src="/public/thumbs/cobol/stregsystemfff.png" alt="img" title="Availability Page" class="thumbable" data-full="/public/img/cobol/stregsystemfff.png">
    <figcaption>
    Screenshot of stregsystem frontend, from an <a href="https://github.com/f-klubben/stregsystemet/pull/586">old closed PR of mine</a>
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>  

SStregsystemet is a lot of things, but can be described as the system of systems in F-Klubben. Most importantly, it is the member payment portal for the refreshing, drinkable and poppable substances made available because of the association. Users have a username and some value amount attributed to their account. \
This can be accessed via the awesome frontend, but it can also be accessed by an API.

Now for the inspiration of this course of this project: the [Stregsystem TUI by Marc Nygaard (Many5900)](https://github.com/Many5900/stregsystemet-tui)  
> A modern, feature-rich Terminal User Interface (TUI) for the Stregsystemet beverage purchasing system.  
And it is written 100% in... Rust.  
Now I have no problems with Rust, and the TUI is very fancy and cool, but I could not help but think that Stregsystemet deserves a proper TUI, one that might crash, one that I have written in a language that has no native library for JSON parsing, one that is written in a language that does not have a library for TCP, one that might not even be able to run in your terminal, one where debugging involves counting letters and spaces, and one where numbers on a screen are printed with too many leading zeroes because the author does not know how it works.

This leads you, my dear reader, and myself on this strange island, my brain numb from seeing COBOL, yet ready to afflict you with the wisdom that comes thereof...

## gnuCOBOL



### Self-imposed Limitations


### Unimplemented Functions!


## Components

### HTTP



### JSON Parsing



### Tables

For my part this is a black box.

### The TUI Part

DISPLAY SECTION


## The Endproduct




## AI

