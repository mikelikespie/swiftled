# SwiftLed

Lighting controller implementation in swift. Completely unsupported and
experimental.

Designed to interface with [go-led-spi](https://github.com/mikelikespie/go-led-spi), but
also should work with arbitrary [OPC](http://openpixelcontrol.org/) servers.

Mostly putting code here to share, but if somebody else wants to use it, I'll
gladly license it under MIT or Apache 2.

## Sources/OPC

OPC library. Similar to openpixelcontrol's OPC library... but in Swift.

## Sources/swiftled

Test executable is here. Will probably do more visualizations in the future.

##  SwiftledMobile

UI that uses OPC library. Probably will have code specific to my LED ball. Fork
it. Do what you want.
