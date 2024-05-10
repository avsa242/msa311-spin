{
----------------------------------------------------------------------------------------------------
    Filename:       MSA311-Demo.spin
    Description:    Demo of the MSA311 driver
    Author:         Jesse Burt
    Started:        May 7, 2024
    Updated:        May 10, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    _clkmode    = cfg._clkmode
    _xinfreq    = cfg._xinfreq


OBJ

    cfg:    "boardcfg.flip"
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    time:   "time"
    sensor: "sensor.accel.3dof.msa311" | SCL=28, SDA=29, I2C_FREQ=400_000


PUB main() | a[3], axis, sign

    setup()
    sensor.opmode(sensor.NORMAL)
    sensor.accel_scale(2)
    sensor.accel_int_set_mask(sensor.INT_DATA_RDY)

    repeat
        repeat until sensor.accel_data_rdy()
        sensor.accel_g(@a[sensor.X_AXIS], @a[sensor.Y_AXIS], @a[sensor.Z_AXIS])
        ser.pos_xy(0, 3)
        ser.str(@"Accel (g):  ")
        repeat axis from sensor.X_AXIS to sensor.Z_AXIS
            if ( a[axis] < 0 )
                sign := "-"
            else
                sign := " "
            ser.printf3(@"%c%d.%06.6d     ",    sign, ...
                                                ||(a[axis] / 1_000_000), ...
                                                ||(a[axis] // 1_000_000) )
        ser.newline()


PUB cal_accel()
' Calibrate the accelerometer
    ser.pos_xy(0, 5)
    ser.str(@"Calibrating accelerometer...")
    sensor.calibrate_accel()
    ser.pos_xy(0, 5)
    ser.clear_ln()


PUB setup()

    ser.start()
    time.msleep(30)
    ser.clear
    ser.strln(@"Serial terminal started")

    if ( sensor.start() )
        ser.strln(@"MSA311 driver started")
    else
        ser.strln(@"MSA311 driver failed to start - halting")
        repeat


DAT
{
Copyright 2024 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

