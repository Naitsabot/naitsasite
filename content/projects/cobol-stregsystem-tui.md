---
title: Stregsystem TUI Written in gnuCOBOL
date: 2026-06-08
slug: cobol-tui
tags: [gnucobol]
draft: false
summary: something with COBOL.
gitlinks: [https://github.com/Naitsabot/stregsystem-cob-tui]
---

# Stregsystem COBOL TUI

A terminal user interface for the F-Klubben stregsystem, written in GnuCOBOL with those nice punchcard limitations.

## The WHY?!

It seems as if every project I set out to do, documented or undocumented, I try to use some kind of framework, methods, and of course a language that I have not tried before.

<figure class="md-figure">
    <img src="/public/img/thumbs/cobol/comic.png" alt="Dilbert by Schott Adams comic from 1997-11-04" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/cobol/comic.png" loading="lazy">
    <figcaption>
    <a href="https://web.archive.org/web/20230301151600/https://dilbert.com/strip/1997-11-04">Dilbert by Schott Adams comic from 1997-11-04</a>
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>  

I have long heard about COBOL. It has been referenced as: the language where writing a  `Hello, World!` program takes more lines than its corresponding assembly; the language whose syntax is so verbose because it was designed around the idea that managers reading their subordinates' code should be able to understand the programmes; the language running on the dinosaur in the basement that still haunts us to this day, running old and critical services on mainframes; and the language whose developers retire handsomely while their code does not.

Each one of these seems like just all the more reason to try to make _something_ with it!

For the time I have been at Aalborg University, I have also been part of F-Klubben, the oldest student association on campus!  
One mantra, not to sound like a cult, spread around the sofas and fridges of F-Klubben, is to embrace scuffed stuff and make more things. If you think of a funny idea, make it.

The most important system in F-Klubben is the [stregsystemet](https://github.com/f-klubben/stregsystemet), although as the F-ormand (committee leader) of F-oret, I would say it is the system for songbook creation: [sangbog](https://github.com/f-klubben/sangbog) and the newer [Typst sangbog](https://github.com/f-klubben/ftsongbook).  

<figure class="md-figure">
    <img src="/public/img/thumbs/cobol/stregsystemfff.png" alt="Screenshot of stregsystem frontend" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/cobol/stregsystemfff.png" loading="lazy">
    <figcaption>
    Screenshot of stregsystem frontend, from an <a href="https://github.com/f-klubben/stregsystemet/pull/586">old closed PR of mine</a>
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>  

Stregsystemet is a lot of things, but can be described as the system of systems in F-Klubben. Most importantly, it is the member payment portal for the refreshing, drinkable, and poppable substances made available because of the association. Users have a username and a balance attributed to their account.
This can be accessed via the frontend, but it can also be accessed through an API.

Now for the inspiration behind this project: the [Stregsystem TUI by Marc Nygaard (Many5900)](https://github.com/Many5900/stregsystemet-tui):
> A modern, feature-rich Terminal User Interface (TUI) for the Stregsystemet beverage purchasing system.  

And it is written 100% in... Rust.  
Now I have no problems with Rust, and the TUI is very fancy and cool, but I could not help but think that Stregsystemet deserves a proper TUI, one that might crash, one that I have written in a language that has no native library for JSON parsing, one that is written in a language that does not have a library for TCP, one that might not even be able to run in your terminal, one where debugging involves counting letters and spaces, and one where numbers on a screen are printed with too many leading zeroes because the author does not know how it works.

This leads you, my dear reader, and myself onto this strange island, my brain numb from seeing COBOL, yet ready to afflict you with the wisdom that comes thereof...

## gnuCOBOL

COBOL has a rich history of [many versions, dialects and implementations](https://en.wikipedia.org/wiki/COBOL), but I can't say that I even looked at any of them. I took what seemed like it might be 1. open source and 2. able to run on a normal machine. I still don't really know what a mainframe is, or why some implementations are made purely for them. [gnuCOBOL](https://gnucobol.sourceforge.io/) has `gnu` in front of it... so gnuCOBOL it was!

### Documentation

[Documentation exists yes](https://gnucobol.sourceforge.io/guides.html). It is very much from another era compared with the documentation of languages, tools, and frameworks I usually work with. There are gnuCOBOL programmers' guides, quick references, sample programmes, GNU info files (something I've never seen before), grammar documentation, and more.

One thing they have in common is that they come in various formats, and you really have to hunt for information. Sometimes you might stumble upon a blog or website with some example code or documentation, only to discover that it is for another flavour or implementation of COBOL.

### Unimplemented Functions!

Apropos differing versions of COBOL, a function implemented in one might be proprietary and unimplemented in another. This was discovered with something like `JSON-PARSE`, being unimplemented in gnuCOBOL, or there apparently existing a TCP or HTTP library of some sort for the IBM mainframe implementation, which I could not use.

### Libraries

I tried and failed to understand libraries, apart from being able to import a repository of intrinsic functions. To be honest, I didn't try to look that hard either.

## Writing COBOL

It can be said that most of the code is parsing and assembling strings, but it is also a real and repetitive pain.

### Self-imposed Limitations

The reason for not looking much into COBOL flavours or libraries is to avoid limiting my experience. I want to experience the "real COBOL", and by that I mean restricting myself to:
- Using fixed-format COBOL with traditional punch card conventions.
- Writing everything in COBOL locally, unless it would require creating an entire internet implementation due to lack of language support, in which case I would delegate it to a terminal tool.

#### Punchcard Column Layout 

Like the real programmers we all strive to become, I look back at my roots and think, "They were the real deal." And by "the real deal" I mean they had the headache of writing programmes on punchcards in the 80-column punchcard format, and not dropping or damaging the punchcards in the meantime.

This format restricts the line length of a programme to 80 characters/columns, where each row is then a line. But it isn't just 80 columns, that would be easy. They also have semantic meanings:
- **Columns 1–6**: Sequence numbers (optional, usually blank)
- **Column 7**: Indicator area
  - `*` = Comment line
  - `-` = Continuation of previous line
  - Blank = Regular code line
- **Columns 8–11**: Area A (division headers, section names, paragraph names, level numbers 01–49)
- **Columns 12–72**: Area B (statements, procedure code)
- **Columns 73–80**: Identification area (ignored by the compiler)

If your code isn't correctly positioned within these columns, it won't compile.

Here is another representation of the columns screaming at you:
```
######*AAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBIIIIIIII
```

### Copybooks

Starting out, I didn't know copybooks were a thing, which could have avoided a wealth of confusion.

Copybooks are one of the things that actually seem to be designed by a sane person, especially in a verbose language like this one with punchcards. They define a shared structure in one place, which can be reused in different modules instead of copy-pasting the same 01-level monster block across the whole codebase.

```cobol
      * Copybook: Parsed Member Info Structure
      * Used after JSON-DECODER parses GET_MEMBER response
       01  parsed-member-info.
           05  member-balance       PIC S9(9) COMP-5.
           05  member-username      PIC X(30).
           05  member-active        PIC X(5).
           05  member-name          PIC X(50).
```

For this project, it solved the pain of data becoming misaligned whenever I tried to define the same structure in multiple places. _Did you know that COBOL does not care what your data is called when transferring between modules or functions?_ Well, I do now.

### Components

#### HTTP

COBOL is oooooooooold and does not support TCP intrinsically.

A connection to the wider web is of course very important for any project that tries to query it. As said, there is no library implementation that I know of. After much thinking and searching, and also looking at an [actual implementation of a REST client](https://github.com/OCamlPro/gnucobol-contrib/tree/master/samples/socket), I decided not to implement it from the ground up.

I started with trying to use `netcat` as an HTTP client but later shifted to `curl`. The reason for the shift from `nc` to `curl` is that `nc` operates at the transport layer while `curl` operates at the application layer, and the project already uses an out of the box implementation of an HTTP client, so this makes it easier to implement in the project.

The client was used as a module, with a pretty basic and well-known process: 
- build the request line and headers by hand,
- send it through a terminal tool,
- read back the raw response,
- separate status code, headers, and body,
- and then hope that nothing had shifted by one character.

COBOL is very verbose, so the code gets to be very verbose also. Even simple operations like GET and POST involved a lot of attention to formatting, line endings, and header ordering. Upon failure, there are no helpful error messages, so `DISPLAY`, and later the a logger, is your friend.

#### JSON Encoding/decoding

For my part this is a black box, partly. gnuCOBOL does actually have a few reserved `JSON-related` keywords, including `JSON PARSE` and `JSON GENERATE`, but the codebase does not really lean on them in the same way. Also, `JSON PARSE` remains unavailable in the actual runtime and will throw an exception when used.

JSON generation is handled with plain string building, which is enough for the small request bodies this project needs.

JSON decoding is the part that gets more awkward. Here I let the AI loose, with the requirement that it did not implement its own parser and just use `jq` to handle decoding instead. The result is not a general-purpose JSON layer, just a practical set of endpoint-specific parsers glued into the rest of the project.

Funnily enough, this is probably the thing failing the most in the app still, with `jq` throwing errors that are not being handled...

##### Tables

To store the retrieved data, a table data structure had to be implemented. It sounds simple, it is not, so again AI was let loose, as I could not be bothered.

A funny thing is that all data is stored in temp files, as you cannot really save state otherwise. And because usernames in the Stregsystem can be called literally anything other than whitespace, tab characters had to be used as data separators.

#### Stregsystem API

The Stregsystem API component acts as a high-level interface and orchestration layer between the TUI component and the Stregsystem backend.
It takes API request operations, builds and sends the HTTP request through the HTTP client, and then turns the response back into COBOL data using the implemented JSON decoder and the endpoint-specific parsing logic.
Each needed endpoint is defined here.

#### The TUI Part

When I first had the idea of the project, I looked into whether you could actually make a TUI with COBOL (easily, that is). COBOL is old, verbose, and stubborn, but as it turns out, this part was not actually that bad. COBOL has a `SCREEN SECTION` built right into the language, which lets you define what a screen looks like declaratively, and then display and accept input from it.

Probably pretty useful for inputting data into records in the before-times...

```cobol
       SCREEN SECTION.
       01 MAIN-SELECTION-SCREEN
           BACKGROUND-COLOR BG-COLOUR
           FOREGROUND-COLOR FG-COLOUR.
       
           05 BLANK SCREEN.
           05 LINE 14 COLUMN 4 VALUE "Choose an action:".
           05 LINE 19 COLUMN 4 VALUE "Choice:".
           05 LINE 19 COLUMN 12 PIC X(1) USING SCREEN-MENU-CHOICE.

      * ...

       MAIN-SELECTION.
           MOVE 0 TO DONE
           PERFORM UNTIL DONE = 1
               DISPLAY MAIN-SELECTION-SCREEN
               ACCEPT MAIN-SELECTION-SCREEN
      * ...
               PERFORM HANDLE-KEY-COLOR
           END-PERFORM
```

You define your screen layout with `LINE` and `COLUMN` values, assign fields to data items using `USING`, and then `DISPLAY` renders it while `ACCEPT` waits for user input. T
he main pain is that you are doing a lot of manual counting to figure out where things should go on the screen. There is no layout engine, no padding, no flexbox, there is just you.

What is actually doing the heavy lifting under the hood, I cannot say for certain. My best guess is ncurses, given that terminal color and cursor control has to come from somewhere, but I have not verified this. It works, and I am choosing not to look too closely.

##### Themes

The theming is simple but effective. Two variables, BG-COLOUR and FG-COLOUR, are referenced throughout the SCREEN SECTION definitions. Changing them changes the look of the entire application.

At runtime, the function keys F1–F8 are each bound to a different color scheme. When you press one, the program updates the two color variables and re-displays the current screen. The change is immediate, so you can cycle through themes interactively until you find something you can live with. 

COBOL already asks a lot of you in terms of boilerplate, a theming system that is just two variables and a keypress is a very welcome change of pace.

## The Endproduct

<figure class="md-figure">
    <img src="/public/img/thumbs/cobol/1.png" alt="Welcome screen/UI for the COBOL Stregsystem TUI (with purple theme)" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/cobol/1.png" loading="lazy">
    <figcaption>
        Welcome screen/UI for the COBOL Stregsystem TUI (with purple theme)
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/img/thumbs/cobol/2.png" alt="Kiosk selection screen/UI for the COBOL Stregsystem TUI (with MacD theme)" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/cobol/2.png" loading="lazy">
    <figcaption>
    Kiosk selection screen/UI for the COBOL Stregsystem TUI (with MacD theme)
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/img/thumbs/cobol/3.png" alt="Kiosk screen/UI with products and buy order for the COBOL Stregsystem TUI (with Stregsystem theme)" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/cobol/3.png" loading="lazy">
    <figcaption>
    Kiosk screen/UI with products and buy order for the COBOL Stregsystem TUI (with Stregsystem theme)
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>  

<figure class="md-figure">
    <img src="/public/img/thumbs/cobol/4.png" alt="Failed order screen/UI for the COBOL Stregsystem TUI (with Stregsystem theme)" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/cobol/4.png" loading="lazy">
    <figcaption>
    Failed order screen/UI for the COBOL Stregsystem TUI (with Stregsystem theme)
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/img/thumbs/cobol/5.png" alt="Sucessful order screen/UI for the COBOL Stregsystem TUI (with Stregsystem theme)" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/cobol/5.png" loading="lazy">
    <figcaption>
    Sucessful order screen/UI for the COBOL Stregsystem TUI (with Stregsystem theme)
    <br>
    (click to see full undithered image)
    </figcaption>
</figure>


## AI

Generally, AI can make COBOL code, but you need to modify it a lot for it to actually work, so it is best used as a talkative rubber duck. If and when you do get AI generated code, you had best look at all the columns and wonder why it can't figure them out.

All there is to say: Review, research, replace.

## Docs and references

- [GnuCOBOL Manual](https://gnucobol.sourceforge.io/doc/gnucobol.html)
- [GnuCOBOL Programmer’s Guide](https://gnucobol.sourceforge.io/HTML/gnucobolpg.html)
- [DevDocs for GnuCOBOL Programmer’s Guide](https://devdocs.io/gnu_cobol/)
- [IBM COBOL procedures](https://www.ibm.com/docs/en/db2/11.5.x?topic=routines-cobol-procedures)
- [Generating JSON with COBOL](https://eklausmeier.goip.de/blog/2021/08-17-generating-json-with-cobol/)
- [Serialize/deserialize JSON in GnuCOBOL](https://compile7.org/serialize-and-deserialize/how-to-serialize-and-deserialize-json-in-gnucobol-cgi/)
- [COBOL JSON examples](https://learnxbyexample.com/cobol/json/)
- [GnuCOBOL contrib thread](https://sourceforge.net/p/gnucobol/discussion/contrib/thread/2b474086/)
- [OCamlPro GnuCOBOL contrib](https://github.com/OCamlPro/gnucobol-contrib/)
- [GnuCOBOL socket samples](https://github.com/OCamlPro/gnucobol-contrib/tree/master/samples/socket)
