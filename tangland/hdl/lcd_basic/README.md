# LCD basic

A demonstration of the 1.4inch LCD display with ST7789V3 driver IC, communication over 4-line SPI.

## Initialization sequence

1. Power on
2. Hardware reset
3. Software reset
4. Exit sleep (120ms wait)
5. Set color mode (optional)
6. Set column addresses
7. Set row addresses
8. Invert colors
9. Normal mode on (optional)
10. Main display on

## Pinout

* CS: chip select (active low)
* RS: resource select (parameter/data when high, command when low)
* SCL: serial clock (off when inactive)
* SDA: serial data (bidirectional)
* RST: reset (active low, min 10us)

## Frame data

* 1 byte per color component with upper 6 bits containing valid data
* Buffer fills from top-left
* Red component sent first



