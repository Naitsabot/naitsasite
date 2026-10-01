---
title: Mise Tool Plugin for using GnuCOBOL  
date: 2026-10-01  
slug: mise-gnucobol  
tags: [gnucobol]  
draft: false  
summary: Something with COBOL again.  
gitlinks: [https://github.com/Naitsabot/mise-gnucobol]  
---

# Making yet another tool for COBOL

## [Mise-en-place](https://en.wikipedia.org/wiki/Mise_en_place)

After installing EndeavourOS on my T14s daily driver, which I lovingly call `Thonkpad`, I decided I wanted yet another way to manage my tooling, other than, of course, using `pacman` or `yay` or `paru` or whatever. I have stumbled upon the eternal problem of managing different versions of different languages and keeping different environments when developing, and wanted to avoid the hassle. Also, I want to be a better person than my peers and use something they don’t, adding yet another file to all the projects I am part of, like a Nix user would.

[https://mise.jdx.dev/](Mise) or Meez or mise-en-place seemed like the tool, which appears to work after having tested it on some other systems, where my environments and `$PATH` became a disaster after a while. As per the Mise page, it is a tool for managing "development tools", "environment variables", "tasks", and "machine setup", and I looked upon all that I had read, and saw that it was good.

## GnuCOBOL

Did you know that GnuCOBOL does *not* have a tool or backend plugin that can install this god-loving programming language? What a travesty :( How else are you supposed to install the [Stregsystem COBOL TUI](https://github.com/Naitsabot/stregsystem-cob-tui)? Use the distro package manager?? Heaven's sake, then it would probably be installed in `/usr/bin/gnucobol/` and we can't have that! What if I want to install a whole *two*, yes, you heard me *TWO*, different versions of GnuCOBOL?? Fun detail: the [AUR](https://aur.archlinux.org/packages/gnucobol) only serves *one*!

So, a Mise tool plugin for installing GnuCOBOL is up for grabs, it seems.

## My gift to the world

Actually, it was not *that* much "up for grabs", as GnuCOBOL is rather particular about how it gets installed. Nevertheless, now you don't have to cry in your sleepy nightmares because you cannot manage your GnuCOBOL versions (2.2, 3.1, 3.1.1, 3.1.2, **3.2**) using Meez, because now you can just run suspicious code blocks from the internet instead!

```
mise plugin install gnucobol https://github.com/Naitsabot/mise-gnucobol
mise use gnucobol@3.2
cobc --version
```

◝(ᵔᗜᵔ)◜ ദ्दी(˵ •̀ ᴗ - ˵ ) ✧ ⸜(｡˃ ᵕ ˂ )⸝♡ ₍₍⚞(˶˃ ꒳ ˂˶)⚟⁾⁾ (≧∇≦)

## Where do we go now?

Like any academic paper, as this is, we discuss the future... IN THE PAST GnuCOBOL has had many names, even earlier versions (I mean, who starts at version 2.2?). As [Brian Tiffin](https://sourceforge.net/u/btiffin/profile/) [writes](https://gnucobol.sourceforge.io/faq/index.html#what-is-the-development-history-of-gnucobol) in the [FAQ on the GnuCOBOL Sourceforge page](https://gnucobol.sourceforge.io/faq/index.html), (a page I wish I had found this *A YEAR AGO*, when I started using COBOL), GnuCOBOL has been called "OpenCOBOL" and, quite plainly, "GNU Cobol version" in the past. It has also shifted release platforms a few times, but there are versions *somewhere* all the way back to the OpenCOBOL 0.9.0 release on 25th January 2002.

So... perhaps incorporating the old versions could be fun. Even though the newest version is from July 2023.

Windows? I can see it raining outside, so I’ll end the post here before my internet gets washed away.
