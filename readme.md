# PCSX2 updater

Small PCSX2 updater written with PowerShell using [7Zip4Powershell](https://github.com/thoemmi/7Zip4Powershell)
Based on [UpdatePCSX2.ps1](https://github.com/jpcarstech/emulation/blob/main/UpdatePCSX2.ps1) by [jpcarstech](https://github.com/jpcarstech)
Updater downloads any latest release (including pre-releases) directly from GitHub using GitHub Api

## Usage
- Install 7Zip4Powershell with `Install-Module -Name 7Zip4Powershell` in powershell console
- Copy script to some directory on your machine  (PCSX2 folder or empty one)
- change `$releaseType` to the one you need: 
  - `32bit-AVX2-symbols.7z`
  - `32bit-AVX2.7z`
  - `32bit-SSE4-symbols.7z`
  - `32bit-SSE4.7z`
  - `64bit-AVX2-symbols.7z`
  - `64bit-AVX2.7z`
  - `64bit-SSE4-symbols.7z`
  - `64bit-SSE4.7z`
- right click on script -> *Run with PowerShell*
- ???
- PROFIT