MODULE_NAME='mExtronSSPLevelUIArray'	(
                                            dev dvTP[],
                                            dev vdvObject
                                        )

(***********************************************************)
#include 'NAVFoundation.ModuleBase.axi'
#include 'NAVFoundation.Math.axi'
#include 'NAVFoundation.UIUtils.axi'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

constant integer ADDRESS_LEVEL_PERCENTAGE	= 1

constant integer LOCK_TOGGLE	= 301
constant integer LOCK_ON	= 302
constant integer LOCK_OFF	= 303
constant integer LEVEL_TOUCH	= 304


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile char locked

volatile char levelTouched

volatile sinteger currentLevel


(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function Update(dev device[], sinteger level) {
    if (levelTouched) {
        return
    }

    currentLevel = level

    NAVSendLevelArray(device, VOL_LVL, type_cast(level))
    NAVTextArray(device, ADDRESS_LEVEL_PERCENTAGE, '0', "itoa(NAVScaleValue(type_cast(level), 255, 100, 0)), '%'")
}


define_function LevelEventHandler(dev device[], tlevel level) {
    if (!levelTouched || locked) {
        return
    }

    NAVCommand(vdvObject, "'VOLUME-', itoa(level.value)")
    NAVTextArray(device, ADDRESS_LEVEL_PERCENTAGE, '0', "itoa(NAVScaleValue(type_cast(level.value), 255, 100, 0)), '%'")
}


define_function UpdateFeedback() {
    [dvTP, LOCK_TOGGLE]	= (locked)
    [dvTP, LOCK_ON]	= (locked)
    [dvTP, LOCK_OFF]	= (!locked)
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START {

}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

level_event[vdvObject, VOL_LVL] {
    Update(dvTP, level.value)
}


button_event[dvTP, 0] {
    push: {
        switch (button.input.channel) {
            case VOL_UP:
            case VOL_DN: {
                if (!locked) {
                    to[vdvObject, button.input.channel]
                }
            }
            case LOCK_TOGGLE: {
                locked = !locked
                UpdateFeedback()
            }
            case LOCK_ON: {
                locked = true
                UpdateFeedback()
            }
            case LOCK_OFF: {
                locked = false
                UpdateFeedback()
            }
            case LEVEL_TOUCH: {
                levelTouched = true
            }
        }
    }
    release: {
        switch (button.input.channel) {
            case LEVEL_TOUCH: {
                levelTouched = false
            }
        }
    }
}


level_event[dvTP, VOL_LVL] {
    LevelEventHandler(dvTP, level)
}


data_event[dvTP] {
    online: {
        Update(dvTP, currentLevel)
    }
}


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
