# PB’s ChatFilter

Shows guild chat only from the guilds you choose, and hides guild recruitment adverts, on
**The Elder Scrolls Online**.

- **Author:** PinkBanther

## Why this exists

Five guilds mean five guild channels and five officer channels arriving in one chat window. On
console there is nothing to sort them into — no tabs, no per-category filters. The client says
so itself, in `esoui/ingame/chatsystem/chatdata.lua`, right above the block that builds the
extra zone channels:

> `--TODO: Allow these in console when we implement tabs and filters`

This add-on is that filter, for the guild channels.

**Only guild channels are affected.** Zone, say, yell, whisper, group, emote, the NPC channels
and every system message are left exactly as they were. The filter looks at the channel, sees
it is not a guild channel, and hands the message straight on — there is no second code path for
them to fall down.

## Guild recruitment adverts

Optional, and **off** until you switch it on.

Guilds advertise by linking themselves in zone chat: the Guild Finder's **Link in Chat** calls
`GetGuildRecruitmentLink(guildId, LINK_STYLE_BRACKETS)` and submits it, so the message arrives
carrying an ordinary chat link —

```
|H<style>:guild:<guildId>|h[Guild Name]|h
```

— the same `GUILD_LINK_TYPE` (`"guild"`, `zo_linkhandler.lua`) the client's own link handlers
pick out of chat. Finding that link in a message is what "this is a recruitment advert" means
here. It is an exact test on something the game itself put in the message, not a guess about
wording, so it works whatever language the advert is written in.

Turn it on in the panel, or with `/pbfilter recruit on`. Three things stay exempt:

| exempt | why |
| --- | --- |
| guild channels | Your guild linking a guild is your guild talking, and whether you read that channel at all is already the per-guild switch's business. Two rules arguing over one message only makes it unpredictable. |
| whispers | Whisper recruitment is real, but a whisper is a person addressing you directly, and losing one silently is worse than reading an advert. `/pbfilter recruit whisper on` includes them. |
| your own messages | Covered by the same switch as everywhere else. |

**What it cannot catch:** an advert typed as plain text with no link in it. There is nothing in
such a message that tells it apart from ordinary chat except its wording, and matching on
wording is how a filter starts eating conversations.

## Setup

Install it and reload the UI. Nothing is filtered until you switch a guild off, so a fresh
install behaves exactly like no add-on at all.

Then either open **Settings → Add-Ons → PB’s ChatFilter** and uncheck what you do not want to
read, or use the chat command.

## The settings panel

One section per guild, two switches in it: **Guild chat** and **Officer chat**. They are
separate channels and get separate switches, so you can follow the officer channel of a guild
whose main chat you have muted, or the other way round.

Below the guild list is **Guild recruitment**, described above. Above it are the two switches
that apply to everything:

- **Filter guild chat** — the master switch. Turn it off to see every guild channel again for a
  while without losing the choices below it.
- **Always show my own messages** — on by default. Your own guild messages are shown even in a
  guild you have switched off. Without it, typing into a hidden guild channel prints nothing at
  all and looks as though the message was never sent.

The guild list on the panel is the guilds you had **when you logged in**. Join or leave one and
reload the UI to redraw it; the chat command always reads the current list.

## The chat command

`/pbfilter`, or `/pbcf`.

```
/pbfilter                        which guild is shown, and how much has been hidden
/pbfilter on | off               the master switch
/pbfilter 2 off                  guild 2, both its channels
/pbfilter 2 officer on           one channel of guild 2
/pbfilter only 1 3               show these guilds and hide the rest
/pbfilter all                    show every guild
/pbfilter none                   hide every guild
/pbfilter own on | off           always show your own messages
/pbfilter recruit on | off       hide messages that link a guild
/pbfilter recruit whisper on|off and in whispers too
/pbfilter banner on | off        print the status at login
/pbfilter reset                  forget every choice
/pbfilter help                   this list
```

The guild numbers are the ones the game itself uses — guild 2 is `/g2`, and the same guild the
second row of the settings panel is about.

The bare `/pbfilter` is the measurement: it names each guild, says whether its two channels are
shown, counts what it has hidden this session, and does the same for recruitment adverts. If
you are not sure the add-on is doing anything, those counts are the answer.

## How it works

`CHAT_ROUTER` holds one message formatter per chat event, and `FormatAndAddChatMessage` only
publishes a message if that formatter returned text:

```lua
local formattedEventText, ... = messageFormatter(...)
if formattedEventText then
    self:FireCallbacks("FormattedChatMessage", ...)
end
```

`"FormattedChatMessage"` is the one callback both chat systems listen on — the keyboard one in
`sharedchatsystem.lua`, the gamepad one in `chatmenu_gamepad.lua` — so a formatter that returns
`nil` ends the message for both. It is never added to a window, never scrolled past, and never
reaches the transcript.

So the add-on reads the live formatter out of `CHAT_ROUTER:GetRegisteredMessageFormatters()`,
puts its own in through `RegisterMessageFormatter`, and either returns `nil` or passes the
arguments to the one it replaced. Both of those are public methods. Nothing here reimplements
the client's formatting: when a message is kept, the game's own formatter formats it, exactly
as if this add-on were not installed.

Wrapping rather than replacing also means another add-on that wraps the same formatter — before
or after this one — keeps working.

Two events carry guild-channel traffic, and both are wrapped:

| event | what it is |
| --- | --- |
| `EVENT_CHAT_MESSAGE_CHANNEL` | what people say |
| `EVENT_GUILD_KEEP_ATTACK_UPDATE` | the AvA keep notices the game posts *into* a guild channel |

The keep notices follow that guild's switch, because a guild you have muted should not still be
shouting about a keep. The game's own setting for them lives in Settings → Combat, and turning
them off there is still the way to be rid of them everywhere.

## Which guild a channel is

Guild channels are numbered by your guild **index**, 1 to 5: `CHAT_CHANNEL_GUILD_2` is the
second guild in your list, and `CHAT_CHANNEL_OFFICER_2` is that same guild's officer channel.
The evidence is in `chatdata.lua` — `CHAT_CHANNEL_GUILD_2` carries
`GetGuildChannelErrorFunction(2)`, which looks the guild up with `GetGuildId(2)`.

The channel-to-index table in `Main.lua` is written out by hand rather than derived by
arithmetic on `CHAT_CHANNEL_GUILD_1`. The numeric values of the `ChannelType` enum are not
documented, and a client that renumbered them would turn an offset calculation into silently
muting the wrong guild. The test harness numbers the channels non-contiguously and out of order
for exactly that reason.

Settings are stored per **guild id**, not per index. The index is a position in a list that
reorders itself when you join or leave a guild; the id belongs to the guild.

## What it does when it is not sure

It shows the message. Every uncertainty resolves that way:

- a guild whose id cannot be read yet (guild data not loaded) → shown
- a guild that has never been configured → shown
- the master switch off → shown
- the formatter missing, or the chat system unavailable → the hook is not installed at all, and
  `/pbfilter` says so on its second line

A filter that hides too little is one you notice and fix. A filter that hides too much loses a
guild invite you were waiting for and never tells you.

## Tests

```
lua test/run.lua
```

from the add-on folder, with any Lua 5.1 or later. `test/harness.lua` stubs the part of the
client the add-on touches — `CHAT_ROUTER` and its formatter table, the guild list, saved
variables and `LibHarvensAddonSettings` — reproducing `FormatAndAddChatMessage`'s "publish only
if the formatter returned text" exactly, since that is the behaviour everything rests on.

The add-on runs on a console, where one real test costs a session: build, upload, boot, log in,
and then talk a guildmate into saying something. The suite is there so the logic does not have
to be tested that way.

## Settings panel dependency

The panel uses `LibHarvensAddonSettings`, declared as an **optional** dependency. Without the
library the add-on still loads, still filters, and is driven entirely by `/pbfilter`.

## Files

| file | what is in it |
| --- | --- |
| `Main.lua` | the filter, the settings model and the chat command |
| `Settings.lua` | the LibHarvensAddonSettings panel |
| `lang/strings.lua`, `lang/jp.lua` | English and Japanese text |
| `test/` | the offline test harness |
| `FINDINGS.md` | what the client does and does not allow here (Japanese) |
