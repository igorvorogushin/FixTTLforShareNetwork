# TTL Fix for Windows

Open `TTLFixWindows.csproj` in Visual Studio 2022 with the .NET desktop development workload and choose **Start**. The app has the same layout and action flow as the macOS version: read both values, set `65` or `64`, then read both again before reporting success.

Changing values requests UAC elevation. The app uses Windows `netsh` commands to set the global IPv4 and IPv6 hop limits. These settings can persist after a restart; **Restore 64** sets both values to `64` and does not necessarily restore the machine's original settings.

The project enables Windows targeting for .NET builds on macOS. A final Windows release should be built and tested on Windows.
