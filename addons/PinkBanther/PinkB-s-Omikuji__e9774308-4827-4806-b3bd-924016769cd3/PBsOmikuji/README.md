# PB's Omikuji

Draws a Japanese fortune slip in chat when you log in, for **The Elder Scrolls Online**.

- **Author:** PinkBanther
- **Version:** 1.1.0
- **Requires:** nothing. `LibHarvensAddonSettings` >= 20106 is optional and adds the settings
  panel; without it everything is reachable from `/omikuji`.
- **Language:** the 365 fortunes are Japanese. See [Language](#language).

## What it does

An *omikuji* is the paper fortune slip you draw at a Japanese shrine: a rank, and a line of
advice under it. This one is drawn in chat at login, and the advice is about Tamriel.

```
PB's Omikuji: ブンブン、2026年9月10日（木）の運勢は……
  【中吉】 料理をひとつ作り置きしておくと、あとで効いてくる。
```

Two lines, once per login. Never on a zone change.

## The 365 fortunes

One for every day of a year. Seven ranks, in the order a shrine puts them in, and how often
each comes up:

| Rank | | Fortunes | Share |
|---|---|---:|---:|
| 大吉 | great blessing | 50 | 13.7% |
| 中吉 | middle blessing | 60 | 16.4% |
| 小吉 | small blessing | 60 | 16.4% |
| 吉 | blessing | 60 | 16.4% |
| 末吉 | blessing to come | 60 | 16.4% |
| 凶 | curse | 45 | 12.3% |
| 大凶 | great curse | 30 | 8.2% |

The total is the size of the writing, not a cycle length: the draw is a hash rather than a deal
of a deck, so a year will repeat some slips and never reach others.

The draw is uniform over the 365 slips rather than over the seven ranks, so a rank's share of
your days *is* its share of the lines — there is no separate weight table to keep in sync. The
four middle ranks are the fat part, because a fortune that hands out 大吉 every third day stops
meaning anything, and 大凶 is deliberately the thinnest, because it is the one people quote at
each other and it should cost something to get.

To reweight a rank, add or remove lines in `Fortunes.lua`. `test/run.lua` asserts the total is
365 and that no line is written twice.

## The same day is the same fortune

A fortune that changes when you look at it is a random number. So the slip is a pure function
of two things and nothing else — **which day it is, where you are sitting**, and **who is
drawing**:

- the same character sees the same slip all day, through zone changes, `/reloadui`, a crash,
  a reinstall, or a lost `SavedVariables` file
- each of your characters gets its own slip on the same day, so your main can have 大吉 on a
  day your writ alt has 大凶
- `/omikuji` shows today's again. Nothing anywhere rerolls it

Set `/omikuji scope account` if you would rather have one fortune a day than eight.

## The date

The client has no `GetDate()` — it does not exist at any API version. It has a server clock
(`GetTimeStamp`, UTC) and a machine clock (`GetSecondsSinceMidnight`, local), and the date is
worked out from the pair, so the fortune rolls over at **your** midnight rather than the
server's. A naive implementation rolls over at 09:00 in Japan, in the middle of an evening.

The calendar date itself is computed arithmetically, because there is no client call that
returns a day and a month either.

**Known limitation.** A wall-clock reading is ambiguous between UTC-11 and UTC+13, and there is
no timezone call in the client to break the tie. The band is set for UTC+13 (New Zealand and
Tonga in summer). At UTC-11, UTC+13:45 or UTC+14 the date reads as the neighbouring day and
rolls over at the neighbouring day's midnight. See `FINDINGS.md` §2.

## Commands

| | |
|---|---|
| `/omikuji` | today's fortune again |
| `/omikuji status` | what the settings are |
| `/omikuji scope character \| account` | who gets their own fortune |
| `/omikuji once on \| off` | only the first login of the day |
| `/omikuji date on \| off` | the date in the first line |
| `/omikuji ranks` | the seven ranks and how many fortunes each has |
| `/omikuji on \| off` | draw at login, or do not |
| `/omikuji reset` | every setting back to default |

`/pbomi` is the short form of all of them.

## Settings

| Setting | Default | |
|---|---|---|
| Draw at login | on | off leaves `/omikuji` as the only way to see the day's slip |
| Only the first login of the day | off | on keeps later logins that day quiet |
| One fortune per | Character | or Account |
| Show the date | on | your local date, not the server's |

## Language

The fortunes and the rank names are Japanese and are the same in every client. That is a
decision rather than an oversight: an omikuji in English is a different object, and 大吉 is not
"Great Blessing", it is 大吉.

Everything around them — the settings panel, the commands, the errors — is in the string table
and translated the usual way, so a Japanese client gets a Japanese panel and an English one
gets an English panel.

**The client has no Japanese font of its own.** On a client without a Japanese font patch the
fortunes will not render, and that is the one thing about this add-on a laptop cannot check.
Adding a second language of fortunes means adding a parallel table to `Fortunes.lua` and
choosing between them at load; nothing in the index arithmetic cares what the strings say.

## Files

| | |
|---|---|
| `Main.lua` | settings, commands, and the login rule |
| `Fortunes.lua` | the 365 slips and the seven ranks. No code |
| `Draw.lua` | the date, the hash, and today's slip |
| `Settings.lua` | the `LibHarvensAddonSettings` panel |
| `lang/` | English base, Japanese overrides |
| `test/` | the harness and the checks |

## Tests

```
lua test/run.lua
```

272 checks, no game required. What is worth testing here is everything that decides which slip
you get and when: the timezone arithmetic over the two clocks (156 checks on its own, every
zone anybody plays from at both ends of the local day, with the clocks deliberately disagreeing
by up to four minutes), the calendar conversion against known dates including leap days and the
2100 century boundary, that the hash reaches all 365 slips without starving any of them, that a
zone change is not a login, and that no Japanese line is missing from the translation or takes
different arguments from its English original.

Every one of those is a PS5 session not spent finding out the same thing.
