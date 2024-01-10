# Wireless Corne ZMK Config

My [ZMK](https://github.com/zmkfirmware/zmk) configs for my [Typeractive](https://typeractive.xyz/) Corne
using the `nice!nano` MC and `nice!view` display.


### Docker

To build using Docker, simply execute `make`. The resulting firmware can then be found under `./firmware` to be flashed to the respective side of the Corne.

Execute `make clean` to clean out the firmware files and build cache.

Execute `make distclean` to remove the docker image used to build the firmware.


### Layout

Inspiration is taken from the [Miryoku](https://github.com/manna-harbour/miryoku_zmk) layout for the split layers and the keyboard layout is slightly modified from the [Engram](https://engram.dev) layout.
