PROGRAM_NAME='LibExtronSSP'

(***********************************************************)
#include 'NAVFoundation.Core.axi'

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


#IF_NOT_DEFINED __LIB_EXTRONSSP__
#DEFINE __LIB_EXTRONSSP__ 'LibExtronSSP'


DEFINE_CONSTANT

constant char DEFAULT_USERNAME[] = 'admin'
constant integer SSH_PORT = 22023


define_function char[NAV_MAX_BUFFER] BuildSwitch(integer input) {
    return "itoa(input), '$'"
}


define_function char[NAV_MAX_BUFFER] BuildVolume(integer volume) {
    return "itoa(volume), 'V'"
}


define_function char[NAV_MAX_BUFFER] BuildMute(integer state) {
    return "itoa(state), 'Z'"
}


#END_IF // __LIB_EXTRONSSP__
