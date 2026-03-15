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

Stregsystemet is a lot of things, but can be described as the system of systems in F-Klubben. Most importantly, it is the member payment portal for the refreshing, drinkable and poppable substances made available because of the association. Users have a username and some value amount attributed to their account. \
This can be accessed via the awesome frontend, but it can also be accessed by an API.

Now for the inspiration of this course of this project: the [Stregsystem TUI by Marc Nygaard (Many5900)](https://github.com/Many5900/stregsystemet-tui):
> A modern, feature-rich Terminal User Interface (TUI) for the Stregsystemet beverage purchasing system.  

And it is written 100% in... Rust.  
Now I have no problems with Rust, and the TUI is very fancy and cool, but I could not help but think that Stregsystemet deserves a proper TUI, one that might crash, one that I have written in a language that has no native library for JSON parsing, one that is written in a language that does not have a library for TCP, one that might not even be able to run in your terminal, one where debugging involves counting letters and spaces, and one where numbers on a screen are printed with too many leading zeroes because the author does not know how it works.

This leads you, my dear reader, and myself on this strange island, my brain numb from seeing COBOL, yet ready to afflict you with the wisdom that comes thereof...

## gnuCOBOL

COBOL has a rich history of [many versions, dialects and implementations](https://en.wikipedia.org/wiki/COBOL), but I can't say that I even looked at any of them. I took what seemed like it might be 1. open source and 2. able to run on a normal machine. I still don't really know what a mainframe is, or why some implementations are made purely for them. [gnuCOBOL](https://gnucobol.sourceforge.io/) has `gnu` in front of it... so gnuCOBOL it was!

### Documentation

[Documentation exists yes](https://gnucobol.sourceforge.io/guides.html). It is very much from another era compared with the documentation of languages, tools, and frameworks I usually have worked with. 
There are gnuCOBOL programmers' guides, quick references, sample programmes, GNU info files (something I've never seen before), grammar documentation, etc.  

One thing in common is that they come in various file formats, and you really have to hunt for information.  
Sometimes you might stumble upon a blog or website with some example code or documentation, but discover that it is for another flavour or implementation of COBOL.

### Unimplemented Functions!

Apropos differing versions of COBOL, an intricate function implemented in one, might be proprietary and yet unimplemented in another! \
This was discovered with something like `JSON-PARSE`, being unimplemented in gnuCOBOL, or there apparently existing a TCP or HTTP library of some sort for the IBM mainframe implementation, which I could not use.

### Libraries

I tried and failed to understand libraries, apart from being able to import a repository of intrinsic functions.

To be honest, I didn't try to look that hard either.

### Self-imposed Limitations

The reason for not looking much into COBOL flavour or libraries is to avoid limiting my experience. I want to experience the "_real COBOL_", and by that I mean restricting myself to:
- Using fixed-format COBOL with traditional punch card conventions.
- Writing everything in COBOL locally, unless it would require creating an entire internet implementation due to the lack of language support, in which case I would delegate it to a terminal tool.

#### Punchcard Column Layout 

Like the real programmers we all strive to become, I look back at my roots and think, "They were the real deal." And by "the real deal" I mean they had the headache of writing programmes on punchcards in the 80-column punchcard format, and not dropping or damaging the punchcards in the meantime.

This format restructures the line length of a programme to 80 characters/columns, where each row is then a line. But it isn't just 80 columns, no, no—that would be easy; they also have specific meanings:
- **Columns 1–6**: Sequence numbers (optional, usually blank)
- **Column 7**: Indicator area
  - `*` = Comment line
  - `-` = Continuation of previous line
  - Blank = Regular code line
- **Columns 8–11**: Area A (division headers, section names, paragraph names, level numbers 01–49)
- **Columns 12–72**: Area B (statements, procedure code)
- **Columns 73–80**: Identification area (ignored by the compiler)

If your code isn't correctly positioned within these columns, it won't compile.

Here is another representation of the columns:
```
######*AAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBIIIIIIII
```

## Writing COBOL

## Components

### HTTP



### JSON Parsing

For my part this is a black box.

### Tables

For my part this is a black box.

### The TUI Part

DISPLAY SECTION


## The Endproduct




## AI

