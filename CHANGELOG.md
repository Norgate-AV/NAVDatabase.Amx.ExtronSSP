# Changelog

## [2.0.1](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v2.0.0...v2.0.1) (2025-03-31)

### 🐛 Bug Fixes

- apply fixes from NAVFoundation.Amx v2.0.1 ([4de0c1f](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/4de0c1f74d0e6531cd7b7a8b2a19231d7ba362e5))

## [2.0.0](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v1.3.0...v2.0.0) (2025-03-12)

### ⚠ BREAKING CHANGES

- Internal blinking logic has been removed from all UI modules. If you wish to
  haveblinking feedback for a mute button this must now be implemented outside the module.

### 🌟 Features

- update to support NAVFoundation.Amx v2.0.0 ([31bb6e9](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/31bb6e99b046c64457aa7581b0a2dc9ef7eeafb8))

## [1.3.0](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v1.2.1...v1.3.0) (2025-02-17)

### 🌟 Features

- bump NAVFoundation.Amx to 1.27.0 ([26a28c9](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/26a28c9774a91923b16e31df93ad1b6963cc4de2))

## [1.2.1](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v1.2.0...v1.2.1) (2025-02-15)

### 🚀 Performance

- remove unnecessary logging ([00883a2](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/00883a23b4920114afeedc2b51556db4ce0c6f45))

## [1.2.0](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v1.1.2...v1.2.0) (2025-01-29)

### 🌟 Features

- add support for ssh connections ([3f230e6](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/3f230e63164028ee059fc839b56ba64166f2adb9))
- improve socket connection logging ([0ca2a19](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/0ca2a196da22538f75ebfe64a2069af310a66e10))

### 🐛 Bug Fixes

- dont send strings to an unconnected socket ([a72a2e5](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/a72a2e5d72e97c0ca0ba6b79685bfea7bb5a1596))

### 🚀 Performance

- move timeline arrays to constants ([8ef984f](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/8ef984fd8ee25013d28be33bf632bfc8d6089f3a))

## [1.1.2](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v1.1.1...v1.1.2) (2025-01-16)

### 🐛 Bug Fixes

- fix path update in install script ([0975319](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/0975319295450e9fb68db8881bddac326e723a08))

## [1.1.1](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v1.1.0...v1.1.1) (2025-01-16)

### 🐛 Bug Fixes

- fix release scripts ([6a131ff](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/6a131ffc88ffbf4dc09f4860114d05f684059344))

## [1.1.0](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/compare/v1.0.0...v1.1.0) (2024-03-09)

### 🌟 Features

- auto update scoop bucket ([cc9e4ed](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/cc9e4ed7ff2f489aaddc07a4fcd43cbfaf897ec3))

## 1.0.0 (2024-03-07)

### 🌟 Features

- increase volume ramp to 250ms ([bd80309](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/bd803092688613234a828e07935b6f1a2cb564ef))

### 🐛 Bug Fixes

- set initialized to true once a valid audio response is received ([0e0ec5f](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/0e0ec5f72e5b8af9518fe68b567772c709d047ed))
- update passthru callback to latest signature ([fba2ffa](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/fba2ffa9fd9160675d2597e9d3fee2318b71ee0f))
- use correct param when setup volume to absolute value ([9405c45](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/9405c454f98cad07a361fcc201195cc6d73a015e))

### 💅 Style

- add some line breaks ([e9abacf](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/e9abacf89478c19a0417eb6b51e1b8ce1df69ddf))

### ✨ Refactor

- correct program_name and include NAVFoundation.Core ([ca6ac70](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/ca6ac70d8259e5945b877c71a281dab4c0930a50))

### 🛠️ Build

- add build script and update relative paths for genlinx ([853a9a5](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/853a9a5fad58610a54a0ff22d25008d9688953b9))
- add genlinx package and update build script ([3ad3c48](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/3ad3c481b602cafb0544454ffd9eb1c3af02746f))

### 🤖 CI

- install pnpm ([1d49f22](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/1d49f2278ef2452086ed5d2d69c7371f22075779))
- update build step ([bda4a04](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/bda4a049e7ea8bc75fdd4839570bfecb021879c3))
- update repo for semantic-release setup ([75f4ba3](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/75f4ba362ea7fd1448273482e04c6d924cb53418))
- use pnpm and run build script ([3cb7abe](https://github.com/Norgate-AV/NAVDatabase.Amx.ExtronSSP/commit/3cb7abe606963d05866229a115f9854646c47689))
