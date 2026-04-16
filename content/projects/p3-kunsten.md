---
title: P3 AAU project - CMS System for Kunsten Museum of Art Aalborg
date: 2026-02-22
slug: p3-kunsten
tags: [university, java, spring boot, svelte]
draft: false
summary: Third Semester.
gitlinks: [https://github.com/cs-24-sw-3-09/KunstenCMSBackend, https://github.com/cs-24-sw-3-09/KunstenCMSFrontend]
---

# Kunsten CMS (Fall 2024)

The third semester of the software bachelor is about creating a well-designed system — so a lot of UML diagrams. During the semester, it is also required to work with a third party to create or collaborate on a system for/with them. Here, we contacted [Kunstmuseum of Art](https://kunsten.dk/), which resulted in us creating a content management system for their display screens.

## Technologies and theory

- Java, Spring Boot (with dependency injection)
- Svelte/SvelteKit, JS, CSS, SCSS, HTML
- SocketIO
- Authentication with JWT tokens
- MariaDB
- Problem and application domain analysis
- User interface design
    - Low fidelity sketches
    - Gigh fidelity prototypes
    - Usability testing
- Componet architecture and design

## Abstract (From Project Report)

This project is done in collaboration with Kunsten Museum of Modern Art Aalborg. They requested a new system to manage and schedule content for their infotainment screens. Before creating the system, a system definition was made, along with an analysis of both the problem domain and application domain. During the design phase of the user interface, low-fidelity sketches were created as a precursor to a functional high fidelity prototype. This prototype was used for usability testing to ensure the users can navigate and use the system intuitively. The user interface was implemented based on the evaluation of the usability test. Furthermore, the solution was implemented based on the architectural design of the system. Here, the frontend was built using SvelteKit, while the backend was developed using Spring Boot. To ensure the system's correctness, unit tests, integration tests, and system tests were conducted. The project is concluded with a discussion of the solution. Lastly, it is concluded that the system fulfils the problem statement.

## Images

### Component overview of frontend

<figure class="md-figure">
    <img src="/public/thumbs/p3/component-overview.png" alt="Component overview of frontend" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/component-overview.png">
    <figcaption>
        Component overview of frontend
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

### Scheduling and live dashboard

<figure class="md-figure">
    <img src="/public/thumbs/p3/dashboard-admin.png" alt="Dashboard wiht live view of media screens content" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/dashboard-admin.png">
    <figcaption>
        Dashboard wiht live view of media screens content
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/week-schedule.png" alt="Week schedule page" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/week-schedule.png">
    <figcaption>
        Week schedule page
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/new-time-slot-model.png" alt="New time slot model for scheduling" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/new-time-slot-model.png">
    <figcaption>
        New time slot model for scheduling
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

### Media management

<figure class="md-figure">
    <img src="/public/thumbs/p3/slideshow-edit-page.png" alt="Slideshow edit and creation page" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/slideshow-edit-page.png">
    <figcaption>
        Slideshow edit and creation page
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/gallery.png" alt="Media gallery page" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/gallery.png">
    <figcaption>
        Media gallery page
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/gallery-item.png" alt="Gallery item modal" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/gallery-item.png">
    <figcaption>
        Gallery item modal
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/new-gallery-item.png" alt="New gallery item modal" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/new-gallery-item.png">
    <figcaption>
        New gallery item modal
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

### User login and management

<figure class="md-figure">
    <img src="/public/thumbs/p3/login.png" alt="Login page" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/login.png">
    <figcaption>
        Login page
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/forgot-pswd.png" alt="Forgot password page" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/forgot-pswd.png">
    <figcaption>
        Forgot password page
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/pswd-reset.png" alt="Password reset page" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/pswd-reset.png">
    <figcaption>
        Password reset page
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/user.png" alt="User settings page" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/user.png">
    <figcaption>
        User settings page
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>

<figure class="md-figure">
    <img src="/public/thumbs/p3/admin-board.png" alt="Admin board over users" title="(click to see full undithered image)" class="thumbable" data-full="/public/img/p3/admin-board.png">
    <figcaption>
        Admin board over users
        <br>
        (click to see full undithered image)
    </figcaption>
</figure>