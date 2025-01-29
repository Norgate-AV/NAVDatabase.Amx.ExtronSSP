MODULE_NAME='mExtronSSP'    (
                                dev vdvObject,
                                dev dvPort
                            )

(***********************************************************)
#DEFINE USING_NAV_MODULE_BASE_CALLBACKS
#DEFINE USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
#DEFINE USING_NAV_MODULE_BASE_PASSTHRU_EVENT_CALLBACK
#DEFINE USING_NAV_STRING_GATHER_CALLBACK
#include 'NAVFoundation.ModuleBase.axi'
#include 'NAVFoundation.Math.axi'
#include 'NAVFoundation.SocketUtils.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'LibExtronSSP.axi'

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

constant char DELIMITER[] = "{ {NAV_CR}, {NAV_LF} }"

constant integer IP_PORT = NAV_TELNET_PORT

constant long TL_DRIVE          = 1
constant long TL_SOCKET_CHECK   = 2
constant long TL_HEARTBEAT      = 3
constant long TL_VOLUME_RAMP    = 4

constant long TL_DRIVE_TICK_INTERVAL[]   = { 200 }
constant long TL_SOCKET_CHECK_INTERVAL[] = { 3000 }
constant long TL_HEARTBEAT_INTERVAL[]    = { 20000 }
constant long TL_VOLUME_RAMP_INTERVAL[]  = { 250 }

constant integer MAX_LEVELS = 3
constant integer MAX_OUTPUTS = 1

constant integer MAX_VOLUME = 100
constant integer MIN_VOLUME = 0

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile integer output[MAX_LEVELS][MAX_OUTPUTS]
volatile integer outputPending[MAX_LEVELS][MAX_OUTPUTS]

volatile integer outputActual[MAX_LEVELS][MAX_OUTPUTS]

volatile _NAVStateInteger currentVolume
volatile _NAVStateInteger currentMute

volatile char password[NAV_MAX_CHARS]

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
define_function SendString(char payload[]) {
    if (IsSocket() && !module.Device.SocketConnection.IsConnected) {
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_TO,
                                            dvPort,
                                            payload))

    send_string dvPort, "payload"
    wait 1 module.CommandBusy = false
}


define_function Drive() {
    stack_var integer x
    stack_var integer z

    if (IsSocket() && !module.Device.SocketConnection.IsConnected) {
        return
    }

    if (module.CommandBusy) {
        return
    }

    z = NAV_SWITCH_LEVEL_AUD

    for (x = 1; x <= MAX_OUTPUTS; x++) {
        if (!outputPending[z][x] || module.CommandBusy) {
            continue
        }

        outputPending[z][x] = false
        module.CommandBusy = true

        SendString(BuildSwitch(output[z][x]))
    }
}


define_function MaintainIpConnection() {
    if (module.Device.SocketConnection.IsConnected) {
        return
    }

    NAVClientSocketOpen(dvPort.PORT,
                        module.Device.SocketConnection.Address,
                        module.Device.SocketConnection.Port,
                        IP_TCP)
}


#IF_DEFINED USING_NAV_STRING_GATHER_CALLBACK
define_function NAVStringGatherCallback(_NAVStringGatherResult args) {
    stack_var char data[NAV_MAX_BUFFER]
    stack_var char delimiter[NAV_MAX_CHARS]

    data = args.Data
    delimiter = args.Delimiter

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_STRING_FROM,
                                            dvPort,
                                            data))

    data = NAVStripRight(data, length_array(delimiter))

    select {
        active (NAVStartsWith(data, 'Aud')): {
            stack_var integer input

            remove_string(data, 'Aud', 1)

            input = atoi(data)

            if (input == outputActual[NAV_SWITCH_LEVEL_AUD][1]) {
                return
            }

            outputActual[NAV_SWITCH_LEVEL_AUD][1] = input
            send_string vdvObject, "'SWITCH-', itoa(input)"

            if (module.Device.IsInitialized) {
                return
            }

            module.Device.IsInitialized = true
        }
        active (NAVStartsWith(data, 'Vol')): {
            stack_var integer volume
            stack_var sinteger scaledVolume

            remove_string(data, 'Vol', 1)

            volume = atoi(data)

            if (volume == currentVolume.Actual) {
                return
            }

            currentVolume.Actual = volume
            send_string vdvObject, "'VOLUME-ABS,', itoa(volume)"

            scaledVolume = NAVScaleValue(type_cast(volume), (MAX_VOLUME - MIN_VOLUME), 255, 0)

            send_string vdvObject, "'VOLUME-', itoa(scaledVolume)"
            send_level vdvObject, VOL_LVL, scaledVolume
        }
        active (NAVStartsWith(data, 'Amt')): {
            stack_var integer state

            remove_string(data, 'Amt', 1)

            state = atoi(data)

            if (state == currentMute.Actual) {
                return
            }

            currentMute.Actual = state
            send_string vdvObject, "'MUTE-', itoa(state)"
        }
        active (NAVStartsWith(data, 'Vrb')): {
            if (module.Device.IsInitialized) {
                return
            }

            Init()
        }
    }
}
#END_IF


define_function CommunicationTimeOut(integer timeout) {
    cancel_wait 'TimeOut'

    module.Device.IsCommunicating = true

    wait (timeout * 10) 'TimeOut' {
        module.Device.IsCommunicating = false
    }
}


define_function Reset() {
    module.Device.SocketConnection.IsConnected = false
    module.Device.IsCommunicating = false

    NAVTimelineStop(TL_HEARTBEAT)
    NAVTimelineStop(TL_DRIVE)
}


define_function Init() {
    SendString('V')
    SendString('Z')
    SendString('$')
}


#IF_DEFINED USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
define_function NAVModulePropertyEventCallback(_NAVModulePropertyEvent event) {
    switch (event.Name) {
        case NAV_MODULE_PROPERTY_EVENT_IP_ADDRESS: {
            module.Device.SocketConnection.Address = event.Args[1]
            module.Device.SocketConnection.Port = IP_PORT
            NAVTimelineStart(TL_SOCKET_CHECK, TL_SOCKET_CHECK_INTERVAL, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
        }
        case NAV_MODULE_PROPERTY_EVENT_PASSWORD: {
            password = event.Args[1]
        }
    }
}
#END_IF


#IF_DEFINED USING_NAV_MODULE_BASE_PASSTHRU_EVENT_CALLBACK
define_function NAVModulePassthruEventCallback(_NAVModulePassthruEvent event) {
    if (event.Device != vdvObject) {
        return
    }

    SendString(event.Payload)
}
#END_IF


define_function char IsSocket() {
    return dvPort.NUMBER == 0
}


define_function VolumeRampEvent() {
    if (IsSocket() && !module.Device.SocketConnection.IsConnected) {
        return
    }

    if ([vdvObject, VOL_UP]) {
        SendString('+V')
        return
    }

    if ([vdvObject, VOL_DN]) {
        SendString('-V')
        return
    }
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START {
    create_buffer dvPort, module.RxBuffer.Data
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvPort] {
    online: {
        if (data.device.number != 0) {
            NAVCommand(data.device, "'SET BAUD 9600,N,8,1 485 DISABLE'")
            NAVCommand(data.device, "'B9MOFF'")
            NAVCommand(data.device, "'CHARD-0'")
            NAVCommand(data.device, "'CHARDM-0'")
            NAVCommand(data.device, "'HSOFF'")
        }

        if (data.device.number == 0) {
            module.Device.SocketConnection.IsConnected = true
        }

        SendString("NAV_ESC, '3CV', NAV_CR")

        NAVTimelineStart(TL_DRIVE, TL_DRIVE_TICK_INTERVAL, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
        NAVTimelineStart(TL_HEARTBEAT, TL_HEARTBEAT_INTERVAL, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
    }
    offline: {
        if (data.device.number == 0) {
            NAVClientSocketClose(data.device.port)
            Reset()
        }
    }
    onerror: {
        if (data.device.number == 0) {
            Reset()
        }
    }
    string: {
        [vdvObject, DATA_INITIALIZED] = true

        CommunicationTimeOut(30)

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM,
                                                data.device,
                                                data.text))

        select {
            active (NAVContains(module.RxBuffer.Data, "'Password:'")): {
                module.RxBuffer.Data = '';
                SendString("password, NAV_CR, NAV_LF");
            }
            active (true): {
                NAVStringGather(module.RxBuffer, "NAV_CR, NAV_LF")
            }
        }
    }
}

data_event[vdvObject] {
    command: {
        stack_var _NAVSnapiMessage message

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM,
                                                data.device,
                                                data.text))

        NAVParseSnapiMessage(data.text, message)

        switch (message.Header) {
            case NAV_MODULE_EVENT_SWITCH: {
                output[NAV_SWITCH_LEVEL_AUD][1] = atoi(message.Parameter[1])
                outputPending[NAV_SWITCH_LEVEL_AUD][1] = true
            }
            case NAV_MODULE_EVENT_VOLUME: {
                switch (message.Parameter[1]) {
                    case 'ABS': {
                        SendString(BuildVolume(atoi(message.Parameter[2])))
                    }
                    default: {
                        stack_var sinteger value

                        value = NAVScaleValue(atoi(message.Parameter[1]), 255, (MAX_VOLUME - MIN_VOLUME), 0)
                        SendString(BuildVolume(type_cast(value)))
                    }
                }
            }
            case NAV_MODULE_EVENT_MUTE: {
                SendString(BuildMute(NAVStringToBoolean(message.Parameter[1])))
            }
        }
    }
}


channel_event[vdvObject, 0] {
    on: {
        switch (channel.channel) {
            case VOL_UP:
            case VOL_DN: {
                NAVTimelineStart(TL_VOLUME_RAMP, TL_VOLUME_RAMP_INTERVAL, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
            }
            case VOL_MUTE: {
                SendString(BuildMute(!currentMute.Actual))
            }
        }
    }
    off: {
        NAVTimelineStop(TL_VOLUME_RAMP)
    }
}


timeline_event[TL_VOLUME_RAMP] {
    VolumeRampEvent()
}


timeline_event[TL_DRIVE] { Drive() }


timeline_event[TL_SOCKET_CHECK] { MaintainIpConnection() }


timeline_event[TL_HEARTBEAT] {
    SendString("NAV_ESC, '3CV', NAV_CR")
}


timeline_event[TL_NAV_FEEDBACK] {
    [vdvObject, NAV_IP_CONNECTED]	= (module.Device.SocketConnection.IsConnected)
    [vdvObject, DEVICE_COMMUNICATING] = (module.Device.IsCommunicating)
    [vdvObject, DATA_INITIALIZED] = (module.Device.IsInitialized)
    [vdvObject, VOL_MUTE_FB] = (currentMute.Actual)
}


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
