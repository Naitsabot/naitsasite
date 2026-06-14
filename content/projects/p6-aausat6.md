---
title: P6 AAU Bachelors Project - AAUSAT6 Computer Vision Pipeline in Space
date: 2026-06-09
slug: p6-aausat6
tags: [university, cpp, python, opencv]
draft: false
summary: Sixth Semester.
gitlinks: [https://github.com/cs-26-sw-6-03/AAUSAT6-vision]
---

# Feasibility of Real-time Region of Interest Tracking and Stabilisation Onboard a 2U CubeSat (Spring 2026)

The sixth semester bachelor project is a research-oriented project.

We partnered with [AAU Satlab](https://satlab.aau.dk/about/), a student organisation at Aalborg University that has built and launched five CubeSats since 2001, with a sixth, AAUSAT6, currently under development.

AAUSAT6 carries a camera capable of 4K@60FPS, but the radio downlink can only handle 1080p@30FPS. Rather than simply discarding the excess resolution, Satlab proposed using a computer vision to track a region of interest (ROI), such as Aalborg municipality, stabilise it, crop it, and downlink that instead. Our project investigated whether such a (relativly) simple traditional computer vision pipeline could actually run in real time on the satellite's onboard hardware.

Machine learning approaches were ruled out early: the NPU on the board could handle inference, but training a model to detect a specific geographic region is fragile, and retraining is not an option once the satellite is in orbit. Classical computer vision was the only viable path.

## What We Built

We started with a naive pipeline, ORB feature detection every frame, matched against a reference image, followed by ED-RANSAC homography stabilisation. Profiling it immediately showed the problem: ORB alone ran at 0.33 FPS.

The optimised pipeline addressed this with two changes:
- **Lucas-Kanade optical flow** to propagate keypoints between frames, only 
  re-running ORB when tracking fails or at fixed intervals
- **Producer-consumer threading** to distribute pipeline stages across the 
  available CPU cores concurrently

The stabiliser was also replaced with a lighter 4-DOF EMA affine approach, dropping the full 6-DOF homography. At 550 km altitude, perspective warp is negligible (~0.000004 error), and the satellite's camera parameters are fixed before launch, so the extra degrees of freedom add cost with no practical benefit.

### Results

The optimised pipeline achieved a roughly tenfold improvement over the naive baseline, going from 0.33 FPS (ORB every frame + ED-RANSAC) to a peak of 2.93 FPS. 

The 30 FPS target was not met. Optical flow and the affine warp application stage are the remaining bottlenecks, parameter tuning across ORB feature count, window size, and pyramid levels only accounts for about a 33% difference in compute time, nowhere near enough to close the gap. Further work is needed: input downscaling before processing, or NPU-based
inference, are the most promising directions.

## Technologies and Such

- OpenCV, C++, Python
- Lucas-Kanade optical flow
- ORB feature detection
- 4-DOF EMA affine stabilisation
- Producer-consumer threading model

## Abstract (From Project Report)

CubeSat platforms have an inherent tension between the mission requirements and the available computational resources.
CubeSats increasingly use onboard video processing pipelines, making the feasibility of running them within the computational budget a central problem.
This paper looks into whether a classical computer vision pipeline for ROI tracking and digital video stabilisation can meet the 30 FPS throughput requirements of live video streaming of the AAUSAT6 2U CubeSat, and the tradeoffs between throughput, tracking accuracy and power consumption across pipeline configurations.
Using classical computer vision methods, a pipeline using ORB feature detection, Lucas-Kanade optical flow propagation, 4-DOF EMA affine stabilisation, pose estimation, running in a parallel, queued producer-consumer pattern was evaluated on the Debix Model B target platform provided by AAU Satlab.
A synthetic dataset simulating a panning camera motion at 550 km altitude was generated using Google Earth Studio. 
Across configurations varying ORB feature count, optical flow window size, pyramid levels, and stabiliser parameters, per-stage throughput, ROI centre tracking error, and board-level power consumption were measured.
The pipeline achieves ROI tracking and stabilisation, but fails to meet the 30 FPS target, peaking at approximately 2.93 FPS. Optical flow and the application of the affine warp are the primary bottlenecks. Single-run measurements and power meter uncertainty limit the precision of the result. Input downscaling or pipeline restructuring are identified as possible directions for future work.
