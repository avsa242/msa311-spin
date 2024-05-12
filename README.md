# msa311-spin 
--------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for the MSA311 3DoF accelerometer

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* I2C connection at up to 400kHz (unenforced)
* Set full-scale range
* Set operating mode
* Set output data rate
* Interrupts: set, read mask (data ready, free-fall, orientation, single/double-tap, active-z, y, x), enable latching, set latching duration, clear, set output mode (push-pull or open-drain)
* Read acceleration in ADC words, g's
* Read sensor orientation (portrait, landscape, up/down)
* Free-fall detection
* Activity detection


## Requirements

P1/SPIN1:
* spin-standard-library
* sensor.accel.common.spinh (provided by the spin-standard-library)


P2/SPIN2:
* p2-spin-standard-library


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.9.4)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.9.4)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.9.4)       | NuCode       | Not yet implemented   |
| P2        | SPIN2    | FlexSpin (6.9.4)       | Native/PASM2 | Not yet implemented   |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* Very early in development - may malfunction, or outright fail to build

