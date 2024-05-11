{
----------------------------------------------------------------------------------------------------
    Filename:       sensor.accel.3dof.msa311.spin
    Description:    Driver for the MEMSensing Microsystems MSA311 accelerometer
    Author:         Jesse Burt
    Started:        May 7, 2024
    Updated:        May 11, 2024
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
    CAL_XL_SCL  = 2                             ' scale to perform calibration at
    CAL_XL_DR   = 64                            ' data rate to perform calibration at

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
            reset()
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


PUB accel_data_rate(r=-1): c | bits
' Set accelerometer output data rate, in Hz
'   r: 1, 2, 4, 8, 16, 32, 64, 125, 250, 500, 1000
'   Returns:
'       current setting if another value is used
    c := 0
    readreg(core.ODR_AXIS_ENA, 1, @c)
    case r
        1, 2, 4, 8, 16, 32, 64, 125, 250, 500, 1000:
            r := (c & core.ODR_MASK) | lookdownz(r: 1, 2, 4, 8, 16, 32, 64, 128, 250, 500, 1000)
            writereg(core.ODR_AXIS_ENA, 1, @r)
        other:
            return lookupz( (c & core.ODR_BITS):    1, 2, 4, 8, 16, 32, 64, 128, 250, 500, ...
                                                    1000, 1000, 1000, 1000, 1000, 1000)


PUB accel_data_rdy(): f
' Flag indicating new accelerometer data is available
'   NOTE: To use this function, the interrupt INT_DATA_RDY must be set using accel_int_set_mask()
    f := 0
    readreg(core.DATA_INT, 1, @f)
    return ( (f & 1) == 1 )


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
            _ares := lookupz(s_bits:    0_000976, ...   ' set g's per LSB scaling
                                        0_001953, ...
                                        0_003906, ...
                                        0_007812)
            s := (c & core.FS_MASK) | s_bits
            writereg(core.RANGE, 1, @s)
        other:
            return lookupz((c & core.FS_BITS): 2, 4, 8, 16)


PUB accel_set_bias(x, y, z)
' Write accelerometer calibration offset values
'   x, y, z: -128..127 (clamped to range)
    x := -128 #> x <# 127
    y := -128 #> y <# 127
    z := -128 #> z <# 127

    writereg(core.OFFSET_X, 1, @x)
    writereg(core.OFFSET_Y, 1, @y)
    writereg(core.OFFSET_Z, 1, @z)


PUB dev_id(): id
' Read device identification
'   Returns: $13 if the device was detected
    id := 0
    readreg(core.PARTID, 1, @id)


CON

    { interrupts }
    INT_DATA_RDY    = 1 << 12                   ' new data ready
    INT_FREEFALL    = 1 << 11                   ' sensor is in free-fall
    INT_ORIENT      = 1 << 6                    ' sensor orientation
    INT_S_TAP       = 1 << 5                    ' single-tap
    INT_D_TAP       = 1 << 4                    ' double-tap
    INT_ACTIVE_Z    = 1 << 2                    ' active, z-axis
    INT_ACTIVE_Y    = 1 << 1                    ' active, y-axis
    INT_ACTIVE_X    = 1 << 0                    ' active, x-axis

    INT_ACTIVE_LOW  = 0                         ' INT1 pin active logic state
    INT_ACTIVE_HIGH = 1


PUB accel_int_mask(): m
' Get accelerometer interrupt mask
    m := 0
    readreg(core.INT_SET_0, 2, @m)


PUB accel_int_polarity(s=-1): c
' Set interrupt pin active state/logic level
'   s: LOW (0), HIGH (1)
'   Returns: current setting if other values are used
    c := 0
    readreg(core.INT_CONFIG, 1, @c)
    case s
        0, 1:
            s := ((c & core.INT1_LVL_MASK) | s)
            writereg(core.INT_CONFIG, 1, @s)
        other:
            return (c & 1)


PUB accel_int_set_mask(m)
' Set accelerometer interrupt mask
'   bits 12, 11, 6..4, 2..0 (all other bits are reserved and will be ignored if set)
'       12: INT_DATA_RDY
'       11: INT_FREEFALL
'       6:  INT_ORIENT
'       5:  INT_S_TAP
'       4:  INT_D_TAP
'       2:  INT_ACTIVE_Z
'       1:  INT_ACTIVE_Y
'       0:  INT_ACTIVE_X
'   Returns: none
    m &= core.INT_SET_MASK                      ' mask off reserved bits
    writereg(core.INT_SET_0, 2, @m)             ' write INT_SET_0, INT_SET_1


CON

    { interrupts }
    INT1_DATA_RDY   = 1 << 8                    ' new data ready
    INT1_ORIENT     = 1 << 6                    ' sensor orientation
    INT1_S_TAP      = 1 << 5                    ' single-tap
    INT1_D_TAP      = 1 << 4                    ' double-tap
    INT1_ACTIVE     = 1 << 2                    ' active, z-axis
    INT1_FREEFALL   = 1 << 0                    ' sensor is in free-fall

PUB accel_int1_set_mask(m)
' Set accelerometer INT1 pin interrupt mask
'   bits 8, 6..4, 2, 0 (all other bits are reserved and will be ignored if set)
'       8:  INT1_DATA_RDY
'       6:  INT1_ORIENT
'       5:  INT1_S_TAP
'       4:  INT1_D_TAP
'       2:  INT1_ACTIVE
'       0:  INT1_FREEFALL
'   Returns: none
    m &= core.INT1_MAP_MASK                     ' mask off reserved bits
    writereg(core.INT_MAP_0, 2, @m)             ' write INT_MAP_0, INT_MAP_1


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
            m := (s & core.PWR_MODE_MASK) | (m << core.PWR_MODE)
            writereg(core.PWR_MODE_BW, 1, @m)
        other:
            return ((s >> core.PWR_MODE) & core.PWR_MODE_BITS)


CON

    { orientation }
    PORT_UP_FR      = 0
    PORT_DOWN_FR    = 1
    LAND_LT         = 2
    LAND_RT         = 3
    Z_UP            = 0
    Z_DOWN          = 1

PUB orientation(): o
' Get device orientation
'   Returns:
'       bits 1..0:
'           PORT_UP_FR (0):     portrait upright
'           PORT_DOWN_FR (1):   portrait upside-down
'           LAND_LT (2):        landscape left
'           LAND_RT (3):        landscape right
'       bit 2:
'           Z_UP (0):           upward looking
'           Z_DOWN (1):         downward looking
'   NOTE: INT_ORIENT must be set using accel_int_set_mask() in order for this method to
'       return valid data.
    o := 0
    readreg(core.ORIENTATION_ST, 1, @o)
    return (o >> core.ORIENT_XYZ)


PUB reset() | tmp
' Reset the device
    tmp := core.RESET
    writereg(core.SOFT_RESET, 1, @tmp)


PRI readreg(reg_nr, nr_bytes, ptr_buff) | cmd_pkt
' Read nr_bytes from the device into ptr_buff
    case reg_nr                                 ' validate register num
        $01..$07, $09..$0c, $0f..$12, $16, $17, $19, $1a, $20..$24, $27, $28, $2a..$2d, ...
        $38..$3a:
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
        $00, $0f..$12, $16, $17, $19, $1a, $20..$24, $27, $28, $2a..$2d, $38..$3a:
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

