# Metal

When a computer is first powered on, raw machine code is loaded into the CPU instruction cache from some fixed offset in a non-removable component (e.g. ROM) on the mainboard and executed. This *first-stage bootloader* is typically very small — on the order of a few hundred bytes. Its only job is to initialize a storage device containing the second stage bootloader and enough of main memory to load it.

## Implementations

Generally, first stage bootloader and platform firmware is closed source software managed and installed by your mainboard manufacturer.

A well-known open source project with builds for many boards exists in the form of [coreboot](https://www.coreboot.org/). There's also a nascent Rust reimplemenation called [oreboot](https://github.com/oreboot/oreboot).