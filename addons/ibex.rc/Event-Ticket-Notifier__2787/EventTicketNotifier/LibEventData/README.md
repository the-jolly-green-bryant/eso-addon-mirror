<!--
SPDX-FileCopyrightText: © 2020 @ibex.rc
SPDX-License-Identifier: MPL-2.0
-->

# LibEventData

This library provides data about current and upcoming game events.

# Dependencies

None.

# API

## `Event` record

Functions documented as returning an `Event` record return a table with the following fields:

- `title`: **`string`** – official title of the event
- `newsUrl`: **`string`** – URL of the announcement in the ESO website
- `beginsAt`: **`number`** – Unix time at which the event starts, as announced
- `endsAt`: **`number`** – Unix time at which the event ends, as announced
- `minTicketsPerLoot`: **`number`** – at least this many tickets can be acquired at once
- `maxTicketsPerLoot`: **`number`** – at most this many tickets can be acquired at once

## `LibEventData.CurrentEvent(): Event`

Return the currently ongoing event, or `nil` if no event is currently active.

## `LibEventData.UpcomingEvent(beginningAfter: number, scanDuration: number): Event`

Locate an event starting in the time window of `scanDuration` seconds `beginningAfter` a Unix time.
If no such event is found, `nil` is returned.

The following example looks for an event starting within 24 hours of the current time:

```lua
nextEvent = LibEventData.UpcomingEvent(GetTimeStamp(), 86400)
```

# Legal

This Add-on is © 2020 @ibex.rc, and distributed subject to the terms of the Mozilla Public License, v. 2.0.
A copy of the MPL can be found in LICENSES/MPL-2.0.txt, as well as at https://mozilla.org/MPL/2.0/.

This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates.
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries.
All rights reserved.
