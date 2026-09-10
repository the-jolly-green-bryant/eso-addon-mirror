# PB's MailerExtension

Adds the three mail boxes the game does not have — **Drafts**, **Sent** and **Kept** — for The
Elder Scrolls Online.

- **Author:** PinkBanther
- **Version:** 1.9.2
- **Requires:** nothing. `LibHarvensAddonSettings` >= 20106 is optional and adds the settings
  panel; without it the same two settings are on `/pbmail max`.

## Where it is

All three are tabs in the mail window — beside Inbox and Send, in both the keyboard and the
gamepad interface — and everything they do is also on `/pbmail`.

## What it does

**Drafts.** On the page you write on, press **Save as draft** — a keybind on the strip in both
interfaces. The **Drafts** tab lists what you have put away; pick one and put it back on the
page, or throw it away.

**Kept.** Everything in the inbox expires, and no add-on can change that — there is no call to
pin a mail or stop its clock. What this can do is copy what a letter *said* somewhere nothing
expires: open a mail and press **Keep this mail**, and its sender, subject, body and date are
written into the Kept tab, where they outlive the mail itself. **Guild mail too.** The body is
readable in the tab — on a controller in a pane laid out like the mail window's own, sender,
subject and a scrolling letter; on a keyboard under the list — and the whole
of it goes to chat with **Read it** or `/pbmail keep read <n>`. Putting one back on the page
addresses a reply to whoever sent it.

**What Kept cannot do is keep the parcel.** Attached items and gold belong to the server until
you take them, and an add-on has nowhere to put an item. The record notes what was attached so
you know what to look for — take it before the mail expires.

**While you write.** The letter on the Send page is saved to the drafts box every minute, so an
unfinished one survives a crash or walking away. It is one draft, kept up to date and named so
you can tell it from the ones you saved yourself; it goes when the letter is sent or the page is
cleared. The interval is a setting, and 0 turns it off.

**Once it is sent.** A letter put on the page from the drafts box takes its draft with it when
it goes — a draft is a letter you have not sent yet, and the sent box has the copy. That is a
setting too, for anybody who would rather keep the wording.

**How much room is left.** On the button-prompt row at the bottom of the screen, to the right
of the prompts: how much of the console's
add-on storage allowance is free, and how much of it this add-on is using. Three boxes of
letters is a thing that grows, and the allowance is shared with every other add-on. It turns red
under a tenth left. `/pbmail disk` says the same.

**Putting one back.** Picking a letter in either tab writes it onto the compose page and then
asks you to go to the **Send** tab yourself. That last step is not laziness: the add-on making
the tab change itself is what broke the Send button in 0.4.0 — see [FINDINGS.md](FINDINGS.md)
§9.

**Sent.** Every letter you send is written down as it goes. The **Sent** tab lists them, and any
of them can be put back on the page — to send the same thing again, or the same thing to
somebody else. The game keeps no copy of a sent mail and the API cannot read one, so this box
holds what was sent with the add-on installed and running, and nothing from before
([FINDINGS.md](FINDINGS.md) §1 and §8).

**The add-on never sends anything.** Putting a letter back fills the page; you read it and press
Send yourself, exactly as you do now.

**Or from the chat box**, which works the same in either interface:

```
/pbmail save jute for @Someone
/pbmail list
  Drafts -- 1 of 50:
  1. jute for @Someone -> @Someone  [2 items, 500g, 2026-09-09 12:34]
/pbmail load 1
```

### Commands

| | |
|---|---|
| `/pbmail save [name]` | put what is on the Send page into the drafts box |
| `/pbmail list` | the drafts box, numbered |
| `/pbmail load <n>` | put draft n back on the Send page |
| `/pbmail delete <n>` \| `all` | throw a draft away |
| `/pbmail sent` | what you have sent, numbered |
| `/pbmail sent load <n>` | put a sent letter back on the Send page |
| `/pbmail sent delete <n>` \| `all` | forget a sent letter |
| `/pbmail keep save` | copy the mail you have open into the Kept box |
| `/pbmail keep` | what you have kept, numbered |
| `/pbmail keep read <n>` | the whole of a kept letter, in chat |
| `/pbmail keep load <n>` | answer a kept letter on the page |
| `/pbmail keep delete <n>` \| `all` | forget a kept letter |
| `/pbmail max` | how many each box keeps |
| `/pbmail max drafts <n>` \| `sent <n>` \| `keep <n>` | change it — any figure from 1 to 1000 |
| `/pbmail autosave <seconds>` \| `off` | how often the letter you are writing is saved |
| `/pbmail onsend on` \| `off` | delete a draft once its letter is sent |
| `/pbmail disk` | how much room is left for saved add-on data |
| `/pbmail where` | whether the add-on can see the Send page, and whether the tabs went in |

`/pbm` is the short form of all of them.

## What it will not promise

- **Attached items are found again, not held.** A draft stores where each item was, which exact
  stack it was, and what kind of item it was. On restore it tries those in that order, so an
  item that moved in your backpack is still found, and a stack you used up is replaced by
  another of the same kind if you have one. If it is gone, the letter says so and restores
  everything else.
- **A sent letter put back on the page does not bring its items with it.** They were sent; they
  are somebody else's now. The record keeps what they *were*, so putting it back looks for
  another of the same kind in your backpack and names the ones it could not find.
- **The sent box cannot show what you sent before installing this**, and it records only what
  was sent from this installation.
- **A C.O.D. is reported, not set.** The page has one money field and a radio button that
  decides whether it means attached gold or C.O.D. Setting the number without the button would
  show the wrong word next to your money on the screen where you press Send.
- **A kept mail is a copy of the text, not a copy of the mail.** The mail in your inbox still
  expires on its own schedule and still has to have its attachments taken. Nothing an add-on
  can call changes that.
- **Drafts and kept mails refuse when the box is full; the sent box drops the oldest.** A draft is something
  you chose to keep. A log that stops recording once it is full has stopped being a log.
- **Lowering a limit never deletes anything.** The sent box is trimmed to the new figure the
  next time you send; the drafts box simply takes no new ones until it is back under. This is
  not politeness: the settings panel reports a slider *while it is being dragged*, so a limit
  that deleted on the way past would turn one notch too far into letters gone for good.

## Settings

**While you are writing** — how often the letter on the Send page is saved (default every 60
seconds, 0 to turn it off), and whether a draft is deleted once its letter has been sent
(default yes).

**How much to keep** — three numbers, up to 1000 each: how many drafts the box holds
(default 50), how many sent letters are remembered (default 100), and how many kept mails are
saved (default 100). They are in the add-on settings panel
when `LibHarvensAddonSettings` is installed, and always on `/pbmail max drafts <n>`,
`/pbmail max sent <n>` and `/pbmail max keep <n>`, which take any exact figure rather than the
panel's steps of ten.

## Tests

```
lua test/run.lua
```

Runs on any Lua 5.1+, with no client. Every file is loaded, the two interface files included:
nothing here can drive the screens they hook into, but loading them proves their main chunks are
what a main chunk should be — a guard, some locals and function definitions. A stray line of
executable code at the top of one of those is worth a console session, and it is free to catch
here.

 The harness stubs the queued-attachment calls, a backpack
whose contents can be moved around underneath a saved letter, the client's update timer, and
both mail interfaces — so "the item changed slot", "the item was replaced", "the item is gone",
"saved on the keyboard, restored on the gamepad", and "the client blanked the page before our
handler for the send event ran" are all checks on a laptop rather than sessions on a console.
