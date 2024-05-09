{
----------------------------------------------------------------------------------------------------
    Filename:       sensor.accel.3dof.msa311.spin
    Description:    Driver for the MEMSensing Microsystems MSA311 accelerometer
    Author:         Jesse Burt
    Started:        May 7, 2024
    Updated:        May 9, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

#include "sensor.accel.common.spinh"            ' pull in code common to all accel drivers


CON

    { default I/O configuration - these can be overridden by the parent object }
    SCL         = 28
    SDA         = 29
    I2C_FREQ    = 400_000


    ACCEL_DOF   = 3                             ' number of axes/degrees of freedom this sensor has

    X_AXIS      = 0
    Y_AXIS      = 1
    Z_AXIS      = 2


    { I2C-specific I/O }
    SLAVE_WR    = core.SLAVE_ADDR
    SLAVE_RD    = core.SLAVE_ADDR|1

    DEF_SCL     = 28
    DEF_SDA     = 29
    DEF_HZ      = 100_000
    I2C_MAX_FREQ= core.I2C_MAX_FREQ



VAR


OBJ

{ decide: Bytecode I2C engine, or PASM? Default is PASM if BC isn't specified }
#ifdef MSA311_I2C_BC
    i2c:    "com.i2c.nocog"                     ' BC I2C engine
#else
    i2c:    "com.i2c"                           ' PASM I2C engine
#endif
    core:   "core.con.msa311.spin"              ' hw-specific low-level const's
    time:   "time"                              ' basic timing functions


PUB null()
' This is not a top-level object


PUB start(): status
' Start using "standard" Propeller I2C pins and 100kHz
    return startx(SCL, SDA, I2C_FREQ)


PUB startx(SCL_PIN, SDA_PIN, I2C_HZ): status
' Start using custom IO pins and I2C bus frequency
    if ( lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) )
        if ( status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ) )
            time.usleep(core.T_POR)             ' wait for device startup
            if ( dev_id() == core.DEVID_RESP )  ' check for device response
                return
    ' if this point is reached, something above failed
    ' Re-check I/O pin assignments, bus speed, connections, power
    ' Lastly - make sure you have at least one free core/cog 
    return FALSE


PUB stop()
' Stop the driver
    i2c.deinit()


PUB defaults()
' Set factory defaults


PUB accel_data(ptr_x, ptr_y, ptr_z) | tmp[2]
' Read accelerometer data
'   ptr_x, ptr_y, ptr_z: pointers to copy accelerometer data to
'   NOTE: Data is signed 12-bit, sign extended to 32-bit
    tmp[0] := tmp[1] := 0
    readreg(core.X_AXIS, 6, @tmp)
    long[ptr_x] := ~~tmp.word[0] ~> 4           ' extend sign and right-justify
    long[ptr_y] := ~~tmp.word[1] ~> 4
    long[ptr_z] := ~~tmp.word[2] ~> 4


PUB accel_data_rate(r): c
' TBD


PUB accel_data_rdy(): f
' TBD
    return true


PUB accel_scale(s=0): c | s_bits
' Set accelerometer full-scale range, in g's
'   s: 2, 4, 8, 16
'   Returns:
'       current setting if another value is used
    c := 0
    readreg(core.RANGE, 1, @c)
    case s
        2, 4, 8, 16:
            s_bits := lookdownz(s: 2, 4, 8, 16) ' 2..16 -> %00..%11
            _ares := lookupz(s_bits: 0_000976, 0_001953, 0_003906, 0_007812)
            s := (c & core.FS_MASK) | s_bits
            writereg(core.RANGE, 1, @s)
        other:
            return lookupz((c & core.FS_BITS): 2, 4, 8, 16)


PUB accel_set_bias(x, y, z)
' TBD

PUB dev_id(): id
' Read device identification
'   Returns: $13 if the device was detected
    id := 0
    readreg(core.PARTID, 1, @id)


CON

    { operating modes }
    NORMAL  = 0
    LOW_PWR = 1
    SUSPEND = 3

PUB opmode(m): s
' Set device operating mode
'   NORMAL (0):     normal/measurements active
'   LOW_PWR (1):    low-power mode
'   SUSPEND (3):    suspend (retain settings, but measuring is halted)
'   Returns:
'       current setting if another value is used
    s := 0
    readreg(core.PWR_MODE_BW, 1, @s)
    case m
        NORMAL, LOW_PWR, SUSPEND:
            m := (s & core.PWR_MODE_MASK) | m
            writereg(core.PWR_MODE_BW, 1, @m)
        other:
            return ((s >> core.PWR_MODE) & core.PWR_MODE_BITS)


PUB reset()
' Reset the device


PRI readreg(reg_nr, nr_bytes, ptr_buff) | cmd_pkt
' Read nr_bytes from the device into ptr_buff
    case reg_nr                                 ' validate register num
        $00..$FF:
            cmd_pkt.byte[0] := SLAVE_WR
            cmd_pkt.byte[1] := reg_nr
            i2c.start()
            i2c.wrblock_lsbf(@cmd_pkt, 2)
            i2c.start()
            i2c.wr_byte(SLAVE_RD)
            i2c.rdblock_lsbf(ptr_buff, nr_bytes, i2c.NAK)
            i2c.stop()
        other:                                  ' invalid reg_nr
            return

PRI writereg(reg_nr, nr_bytes, ptr_buff) | cmd_pkt
' Write nr_bytes to the device from ptr_buff
    case reg_nr
        $00..$FF:
            cmd_pkt.byte[0] := SLAVE_WR
            cmd_pkt.byte[1] := reg_nr
            i2c.start()
            i2c.wrblock_lsbf(@cmd_pkt, 2)
            i2c.wrblock_lsbf(ptr_buff, nr_bytes)
            i2c.stop()
        other:
            return


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

