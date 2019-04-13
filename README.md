Hummingbird E200 Opensource Processor Core
================

About
-----------

This repository hosts the project for open-source hummingbird E200 RISC processor Core.

The Hummingbird E200 core is a two-stages pipeline based ultra-low power/area implementation,
which has both performance and areas benchmark better than ARM Cortex-M0+ core, makes the Hummingbird E200 as a perfect replacement for legacy 8051 core or ARM Cortex-M cores in the IoT or other ultra-low power applications.

To boost the RISC-V popularity and to speed up the IoT development in China,
we are very proud to make it open-source. It is the first open-source processor core from
China mainland with state-of-art CPU design skills to support RISC-V instruction set.


Build & Run
--------------------

```sh
$ git clone https://github.com/darwinbeing/e200_opensource.git --recursive
$ cd e200_opensource/fpga
$ make CORE=e203 install
$ make mcs
$ make flash

$ cd ../hbird-e-sdk
$ make dasm PROGRAM=demo_gpio NANO_PFLOAT=0
$ make PROGRAM=demo_gpio upload

```
