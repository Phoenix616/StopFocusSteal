# StopFocusSteal
Really simple AutoHotKey script to stop unanted focus steal under Windows to prevent accidental input into newly created (popup) windows while typing or just the automatic moving into the front in general for example when a game/program needs time to load. 

Why AutoHotkey you might ask. Well I'm familiar with using keyboard stuff under windows with it and it was the fastest thing for me to get up and running.

You need [AutoHotkey](https://autohotkey.com/) installed if you don't want to run random executables from the web!

### StopFocusSteal.ini
``` ini
[Settings]
filelog=0
; Log everything to file
notifications=1
; Show tray tip when steal was blocked
inputonly=1
; Only stop stealing when keyboard typing is detected
preventinput=1000
; Number of milliseconds in which we should prevent input in newly created windows
```

### License:

> Copyright (C) 2016 Max Lee (https://github.com/Phoenix616/)

> This program is free software: you can redistribute it and/or modify
> it under the terms of the Mozilla Public License as published by
> the Mozilla Foundation, version 2.

> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> Mozilla Public License v2.0 for more details.

> You should have received a copy of the Mozilla Public License v2.0
> along with this program. If not, see <http://mozilla.org/MPL/2.0/>.
