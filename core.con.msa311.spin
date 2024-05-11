{
----------------------------------------------------------------------------------------------------
    Filename:       core.con.msa311.spin
    Description:    MSA311-specific constants
    Author:         Jesse Burt
    Started:        May 7, 2024
    Updated:        May 11, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

' I2C Configuration
    I2C_MAX_FREQ                = 400_000       ' device max I2C bus freq
    SLAVE_ADDR                  = $62 << 1      ' 7-bit format slave address
    T_POR                       = 3_000         ' startup time (usecs)

    DEVID_RESP                  = $13           ' device ID expected response


' Register definitions
    SOFT_RESET                  = $00           ' w/o
        RESET                   = (1 << 5) | (1 << 2)

    PARTID                      = $01

    X_AXIS                      = $02'..$03     ' 12bits, LSByte-first, left-justified
    Y_AXIS                      = $04'..$05
    Z_AXIS                      = $06'..$07

    MOTION_INT                  = $09
    MOTION_INT_MASK             = $75
        ORIENT_INT              = 6
        S_TAP_INT               = 5
        D_TAP_INT               = 4
        ACTIVE_INT              = 2
        FREEFALL_INT            = 0

    DATA_INT                    = $0a
        NEW_DATA                = 0

    TAP_ACTIVE_ST               = $0b
    TAP_ACTIVE_ST_MASK          = $ff
        TAP_SIGN                = 7
        TAP_FIRST_X             = 6
        TAP_FIRST_Y             = 5
        TAP_FIRST_Z             = 4
        ACTIVE_SIGN             = 3
        ACTIVE_FIRST_X          = 2
        ACTIVE_FIRST_Y          = 1
        ACTIVE_FIRST_Z          = 0
        
    ORIENTATION_ST              = $0c
    ORIENTATION_ST_MASK         = $70
        ORIENT_Z                = 6
        ORIENT_XY               = 4
        ORIENT_XY_BITS          = %11
        ORIENT_XYZ              = 4
        ORIENT_XYZ_BITS         = %111

    RANGE                       = $0f
    RANGE_MASK                  = $03
        FS                      = 0
        FS_BITS                 = %11
        FS_MASK                 = FS_BITS ^ RANGE_MASK

    ODR_AXIS_ENA                = $10
    ODR_AXIS_ENAMASK            = $ef
        X_AXIS_DIS              = 7
        X_AXIS_DIS_MASK         = (1 << X_AXIS_DIS) ^ ODR_AXIS_ENAMASK
        Y_AXIS_DIS              = 6
        Y_AXIS_DIS_MASK         = (1 << Y_AXIS_DIS) ^ ODR_AXIS_ENAMASK
        Z_AXIS_DIS              = 5
        Z_AXIS_DIS_MASK         = (1 << Z_AXIS_DIS) ^ ODR_AXIS_ENAMASK
        XYZAXIS_DIS             = 5
        XYZAXIS_DIS_BITS        = %111
        XYZAXIS_DIS_MASK        = (XYZAXIS_DIS_BITS << XYZAXIS_DIS) ^ ODR_AXIS_ENAMASK
        ODR                     = 0
        ODR_BITS                = %1111
        ODR_MASK                = (ODR_BITS << ODR) ^ ODR_AXIS_ENAMASK

    PWR_MODE_BW                 = $11
    PWR_MODE_BW_MASK            = $de
        PWR_MODE                = 6
        PWR_MODE_BITS           = %11
        PWR_MODE_MASK           = (PWR_MODE_BITS << PWR_MODE) ^ PWR_MODE_BW_MASK
        LOW_POWER_BW            = 1
        LOW_POWER_BW_BITS       = %1111
        LOW_POWER_BW_MASK       = (LOW_POWER_BW_BITS << LOW_POWER_BW) ^ PWR_MODE_BW_MASK

    SWAP_POL                    = $12
    SWAP_POL_MASK               = $0f
        X_POLARITY              = 3
        X_POLARITY_MASK         = (1 << X_POLARITY) ^ SWAP_POL_MASK
        Y_POLARITY              = 2
        Y_POLARITY_MASK         = (1 << Y_POLARITY) ^ SWAP_POL_MASK
        Z_POLARITY              = 1
        Z_POLARITY_MASK         = (1 << Z_POLARITY) ^ SWAP_POL_MASK
        X_Y_SWAP                = 0
        X_Y_SWAP_MASK           = (1 << X_Y_SWAP) ^ SWAP_POL_MASK

    INT_SET_0                   = $16
    INT_SET_0_MASK              = $77
        ORIENT_INT_EN           = 6
        S_TAP_INT_EN            = 5
        D_TAP_INT_EN            = 4
        ACTIVE_INT_EN_Z         = 2
        ACTIVE_INT_EN_Y         = 1
        ACTIVE_INT_EN_X         = 0

    INT_SET_1                   = $17
    INT_SET_1_MASK              = $18
        NEW_DATA_INT_EN         = 4
        FREEFALL_INT_EN         = 3

    INT_SET_MASK                = (INT_SET_1_MASK << 8) | INT_SET_0_MASK


    INT_MAP_0                   = $19
    INT_MAP_0_MASK              = $75
        INT1_ORIENT             = 6
        INT1_S_TAP              = 5
        INT1_D_TAP              = 4
        INT1_ACTIVE             = 2
        INT1_FREEFALL           = 0

    INT_MAP_1                   = $1a
    INT_MAP_1_MASK              = $01
        INT1_NEW_DATA           = 0

    INT1_MAP_MASK               = (INT_MAP_1_MASK << 8) | INT_MAP_0_MASK


    INT_CONFIG                  = $20
    INT_CONFIG_MASK             = $03
        INT1_OD                 = 1
        INT1_OD_MASK            = (1 << INT1_OD) ^ INT_CONFIG_MASK
        INT1_LVL                = 0
        INT1_LVL_MASK           = (1 << INT1_LVL) ^ INT_CONFIG_MASK

    INT_LATCH                   = $21
    INT_LATCH_MASK              = $8f
        RESET_INT               = 7
        RESET_INT_MASK          = (1 << RESET_INT) ^ INT_LATCH_MASK
        RESET_LATCHED_INTS      = (1 << RESET_INT)
        LATCH_INT               = 0
        LATCH_INT_BITS          = %1111
        LATCH_INT_MASK          = (LATCH_INT_BITS << LATCH_INT) ^ INT_LATCH_MASK

    FREEFALL_DUR                = $22

    FREEFALL_TH                 = $23

    FREEFALL_HYST               = $24
    FREEFALL_HYST_MASK          = $07
        FREEFALL_MODE           = 2
        FREEFALL_MODE_MASK      = (1 << FREEFALL_MODE) ^ FREEFALL_HYST_MASK
        FREEFALL_HY             = 0
        FREEFALL_HY_BITS        = %11
        FREEFALL_HY_MASK        = (FREEFALL_HY_BITS << FREEFALL_HY) ^ FREEFALL_HYST_MASK

    ACTIVE_DUR                  = $27
    ACTIVE_DUR_MASK             = $03

    ACTIVE_TH                   = $28

    TAP_DUR_QS                  = $2a
    TAP_DUR_QS_MASK             = $c7
        TAP_QUIET               = 7
        TAP_QUIET_MASK          = (1 << TAP_QUIET) ^ TAP_DUR_QS_MASK
        TAP_SHOCK               = 6
        TAP_SHOCK_MASK          = (1 << TAP_SHOCK) ^ TAP_DUR_QS_MASK
        TAP_DUR                 = 0
        TAP_DUR_BITS            = %111
        TAP_DUR_MASK            = (TAP_DUR_BITS << TAP_DUR) ^ TAP_DUR_QS_MASK

    TAP_TH                      = $2b
    TAP_TH_MASK                 = $1f

    ORIENT_HY                   = $2c
    ORIENT_HY_MASK              = $7f
        ORIENT_HYST             = 4
        ORIENT_HYST_BITS        = %111
        ORIENT_HYST_MASK        = (ORIENT_HYST_BITS << ORIENT_HYST) ^ ORIENT_HY_MASK
        ORIENT_BLOCKING         = 2
        ORIENT_BLOCKING_BITS    = %11
        ORIENT_BLOCKING_MASK    = (ORIENT_BLOCKING_BITS << ORIENT_BLOCKING) ^ ORIENT_HY_MASK
        ORIENT_MODE             = 0
        ORIENT_MODE_BITS        = %11
        ORIENT_MODE_MASK        = (ORIENT_MODE_BITS << ORIENT_MODE) ^ ORIENT_HY_MASK

    Z_BLOCK                     = $2d
    Z_BLOCK_MASK                = $0f

    OFFSET_X                    = $38           ' 8 bits 1LSB = 3.9mg
    OFFSET_Y                    = $39
    OFFSET_Z                    = $3a



PUB null()
' This is not a top-level object


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

