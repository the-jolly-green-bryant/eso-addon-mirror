# Findings

What was checked before writing the add-on, and where the answers came from. The source is the
client's own Lua, cloned from `esoui/esoui` (branch `live`, API 101050 / 12.0.8) — the same
repository that ships `ESOUIDocumentation.txt`.

Anything marked **from source** is read out of the client's own Lua or its API dump and has not
been contradicted, but has not been seen on a console either. Anything marked **to measure** is
a question this laptop cannot answer. The distinction matters: on console a wrong guess costs a
whole test round.

---

## 1. There is no such thing as a sent mail, as far as the API is concerned

**From source.** Every mail read in `ESOUIDocumentation.txt` (lines ~16679–16780) is an inbox
read:

```
GetNumMailItemsByCategory(category)          -> numMail
GetMailIdByIndex(category, index)            -> mailId
GetMailItemInfo(mailId)                      -> sender, subject, ..., category
ReadMail(mailId)                             -> body
GetAttachedItemInfo(mailId, attachIndex)     -> icon, stack, ...
```

There is no counterpart that takes a mail you sent, and no `MailCategory` value for one:
`MAIL_CATEGORY_PLAYER_MAIL`, `MAIL_CATEGORY_SYSTEM_MAIL`, `MAIL_CATEGORY_INFO_ONLY_SYSTEM_MAIL`
and nothing else. The server does not keep a copy of what you send, so a "sent box" can only be
a log this add-on writes at the moment of sending. It will hold what was sent with the add-on
installed and running, on this installation, and nothing else. That limit is real and belongs
in the store listing, not in a footnote.

## 2. A draft is entirely ours, and the client already does the hard part of it

**From source.** `ingame/mail/mailsend_shared.lua` keeps the queued attachments across a screen
change:

```lua
g_pendingAttachments[i] = {
    bagId = bagId, slotIndex = slotIndex,
    itemInstanceId = GetItemInstanceId(bagId, slotIndex),
    stackSize = stack, icon = icon,
}
-- ...and on the way back:
local sameItemInSlot = GetItemInstanceId(p.bagId, p.slotIndex) == p.itemInstanceId
local sameStackSize  = GetSlotStackSize(p.bagId, p.slotIndex) == p.stackSize
if sameItemInSlot and sameStackSize then QueueItemAttachment(p.bagId, p.slotIndex, slot) end
```

This add-on is that idea written to disk. Two deliberate differences: the stack SIZE is not part
of the test (a stack of jute that grew is still the jute the draft meant), and when the slot no
longer matches, the backpack is searched — first for the same `itemInstanceId`, then for the
same item link. A draft is days old, not one screen change old.

## 3. The two interfaces differ in the text and only in the text

**From source.** The compose surface:

| | keyboard | gamepad |
|---|---|---|
| file | `mail/keyboard/mailsend_keyboard.lua` | `mail/gamepad/mailsend_gamepad.lua` |
| object | `MAIL_SEND.to` / `.subject` / `.body` | `MAIL_GAMEPAD:GetSend().mailView` |
| read | `control:GetText()` | `ZO_MailView_GetAddress_Gamepad(view)` etc. |
| write | `control:SetText(text)` | `ZO_MailView_Display_Gamepad(view, cod, gold, to, subject, body)` |

The attachments and the money are **not** per-interface. `GetQueuedItemAttachmentInfo`,
`QueueItemAttachment`, `GetQueuedMoneyAttachment`, `GetQueuedCOD` are one queue in the client,
and both interfaces draw the same numbers. That is why `Compose.lua` splits only the text, and
why a draft saved in one interface restores in the other.

## 4. Whether the Send page is open

**From source.** `ingame/inventory/inventoryslot.lua` asks it the same way this add-on does:

```lua
local function IsSendingMail()
    if MAIL_SEND and not MAIL_SEND:IsHidden() then return true
    elseif MAIL_GAMEPAD and MAIL_GAMEPAD:GetSend():IsAttachingItems() then return true end
end
```

The keyboard half is copied. The gamepad half is not: `IsAttachingItems()` is true only while
the inventory side is up, and we want the whole Send tab, so `Compose.lua` asks
`GAMEPAD_MAIL_SEND_FRAGMENT:GetState() == SCENE_FRAGMENT_SHOWN` instead.

**Measured**, 2026-09-09, gamepad interface: with the Send page open, `/pbmail where` answered
"the Send page is open (gamepad interface)". So the fragment test is right, and the departure
from the client's own `IsAttachingItems()` was the correct one — that call would have answered
false on the same screen. It also settles that the add-on loads and that the slash route works
on the machine.

## 5. A third tab can be added to the mail window in both interfaces

**From source.** Both interfaces are added to rather than replaced, and neither hook changes a
client function's behaviour.

Keyboard (`ingame/scenes/keyboard/keyboardingamescenes.lua`) builds the tabs as:

```lua
SCENE_MANAGER:AddSceneGroup("mailSceneGroup", ZO_SceneGroup:New("mailInbox", "mailSend"))
MAIN_MENU_KEYBOARD:AddSceneGroup(MENU_CATEGORY_MAIL, "mailSceneGroup", iconData)
```

Calling `AddSceneGroup` again with a longer list would work, and would also re-register a
`StateChange` callback on `mailInbox` and `mailSend`, which were already in it. So instead:
`ZO_SceneGroup:AddScene(name)` puts a third scene in the group, and one row appended to
`MAIN_MENU_KEYBOARD.sceneGroupInfo["mailSceneGroup"].menuBarIconData` gives it a tab —
`MainMenu_Keyboard:SetupSceneGroupBar` rebuilds the bar from that table every time the group is
shown. `AddRawScene` then tells the main menu the scene belongs to the mail category.

Gamepad (`ingame/mail/gamepad/mail_gamepad.lua`): the tabs are `self.tabBarEntries`, a plain
array of `{ text, callback }`, built in `ZO_Mail_Gamepad:PerformDeferredInitialization`.
`baseHeaderData` holds a reference to that same array, so a tab appended after the fact is
drawn. `ZO_PostHook` on `PerformDeferredInitialization` is where it is appended; that runs
before `OnStateChanged` reaches `SwitchToHeader`, so the tab is there the first time the window
opens.

The gamepad screen is a `ZO_Gamepad_ParametricList_Screen`, and `AddList(name, setup)` builds a
list in its own container with the screen's own look; `SetCurrentList` shows, activates and puts
away. So the drafts list is the game's list rather than a window of ours over the top.

Cross-tab navigation is the client's own: `ZO_MailInbox_Gamepad:Reply()` sets pending data on
the send screen and calls `SwitchToSendTab()`, and the pending data is applied when the send
screen shows. Loading a draft from the drafts tab does exactly that.

## 6. Nothing here calls SendMail

`SendMail(to, subject, body)` carries no `private`/`protected` marker in the API dump. That is
not evidence: the dump has been wrong before (`SetSetting` is unmarked and private,
`BindKeyToAction` is marked protected and is private), and add-on Lua is insecure code, so a
restricted call is unreachable from every context — a timer, an event, a slash command, a real
key press.

It does not matter here, because sending is the irreversible act in this window and the add-on
has no business doing it. Restoring a draft fills the page; the player reads it and presses Send.
Whatever `SendMail`'s real status is, this design does not depend on it.


## 7. Trust belongs to the function, not to the callstack — so never wrap a client function

**Measured**, PS5, 0.2.0. This is the most useful thing learned here, and it cost a working
feature to learn.

0.2.0 added its tab with two `ZO_PostHook`s: one on `ZO_Mail_Gamepad:PerformDeferredInitialization`,
one on `ZO_MailSend_Gamepad:PopulateMainList`. Post hooks. Neither changes what the client
function does. Picking a recipient on the Send page then failed:

```
ZO_PlayerConsoleInfoRequestManager.lua:134: Attempt to access a private function
'ShowSelectFromUserListDialog' from insecure code. The callstack became untrusted
2 stack frames from the top.
  ZO_PlayerConsoleInfoRequestManager.lua:134: in 'RequestIdFromUserListDialog'
  MailSend_Gamepad.lua:537: in function 'actionFunction'
  MailSend_Gamepad.lua:240: in function 'callback'
  ZO_KeybindStrip.lua:677: in 'TryHandlingKeybindDown'
```

Every frame in that traceback is the client's own code. Nothing of the add-on's is on the stack.
Frame 2 — `MailSend_Gamepad.lua:537` — is the closure `userListCallback`, and it is **created
inside** `PopulateMainList`:

```lua
-- mailsend_gamepad.lua, inside ZO_MailSend_Gamepad:PopulateMainList
local userListCallback = function()
    PLAYER_CONSOLE_INFO_REQUEST_MANAGER:RequestIdFromUserListDialog(...)
end
```

So the engine is not asking "is anything on the stack right now insecure". It is asking "is this
function object trusted", and the answer was decided when the closure was **created** — during a
call that `ZO_PostHook` was making from an add-on's frame.

**A closure created while an add-on frame is on the stack is permanently untrusted**, for the
rest of the session, wherever it is later called from. Post hook or pre hook makes no
difference: both call the original from a function of ours.

The consequence for hooking client UI: a hook on any function that builds a screen — anything
that populates a list, initializes keybind descriptors, or stores callbacks for later — silently
poisons every callback that screen just built. Nothing goes wrong until one of those callbacks
reaches a private function, which may be a feature nobody in the add-on ever thought about.

What is safe, and is all this add-on now uses:

* **registering** a callback with the client's own callback manager — a scene's or a fragment's
  `"StateChange"`. Our function is stored beside theirs and called by them; theirs is not
  wrapped and nothing of theirs is created inside our frame.
* **appending a table entry** the client will read later: the tab in `tabBarEntries`, a keybind
  in `mainKeybindDescriptor`, a tab icon in `menuBarIconData`. Data is not code.

The cost is that a registered callback necessarily runs *after* the client has done its work,
so the tab bar is redrawn once, on the first open of a session, with the new tab in it.


## 8. The sent letter has to be copied before it goes

**From source.** §1 settles that a sent box can only be a copy this add-on makes. The question
left is *when*, and there is only one workable answer.

`EVENT_MAIL_SEND_SUCCESS` is too late. The client's own handler for that event blanks the page:

```lua
function MailSend:OnMailSendSuccess()             -- mailsend_keyboard.lua
    PlaySound(SOUNDS.MAIL_SENT)
    self:ClearFields()
end

function ZO_MailSend_Gamepad:OnMailSendSuccess()  -- mailsend_gamepad.lua
    PlaySound(SOUNDS.MAIL_SENT)
    self.inSendMode = false
    self:Clear()
    ...
end
```

The keyboard one is registered in `MailSend:Initialize`, when the UI loads — before any add-on
exists, and so before ours in that event's handler list. By our turn there is nothing left to
read. (The gamepad one is registered later, in `ConnectShownEvents`, so the order there happens
to favour us — but a design that depends on which of two handlers the client registered first is
a design waiting to break.)

Hooking the send is out for two reasons. §7 is the first. The second is worse: wrapping
`MailSend:Send` would leave our frame on the callstack while the client called `SendMail`, and
if `SendMail` turns out to be restricted, that breaks sending itself. Nothing here is worth that
risk.

So the add-on keeps a copy of the page while the page is open, refreshed ten times a second by a
registered update, and the last copy that had anything on it becomes the record when the event
says the letter went. The addressee is taken from the event rather than from the copy, because
the event carries the name the server accepted.

The copy is a read of values the client already holds — three edit boxes and the six queued
attachment slots. It asks the server for nothing, it runs only while the Send page is open, and
it is unregistered the moment the page closes.

What the record keeps of an attachment is deliberately less than a draft keeps. The items have
left the backpack, so the bag slot and the stack id are dropped and only the link and the name
survive: keeping the slot would let a later "put this back on the page" grab whatever unrelated
item has since moved into it.


## 9. Causing the client to build a screen taints it, exactly as wrapping it does

**Measured**, PS5, 0.4.0. §7 said never to *wrap* a client function. This is the other half of
the same rule, and it cost a second working feature to learn: **never call client code that
builds a screen either.** Pressing Send failed with:

```
ZO_PlayerConsoleRequestsUtils.lua:138: Attempt to access a private function
'IsConsoleCommunicationRestricted' from insecure code. The callstack became untrusted
1 stack frame(s) from the top.
  ZO_PlayerConsoleRequestsUtils.lua:138: in 'ZO_ConsoleAttemptCommunicateOrError'
  MailSend_Gamepad.lua:654: in function 'AttemptSendMail'
  MailSend_Gamepad.lua:240: in function 'callback'
  ZO_KeybindStrip.lua:677: in 'TryHandlingKeybindDown'
```

**The frame count is zero-based.** `ZO_ConsoleAttemptCommunicateOrError` is a plain global
defined at file scope in the client's own file, so it cannot be the untrusted one; frame 1 is
`AttemptSendMail`. Reading §7's error the same way puts the blame there on `callback` at
`MailSend_Gamepad.lua:240`. Both are closures, and both are created inside code this add-on
caused to run:

```lua
function ZO_MailSend_Gamepad:PopulateMainList()      -- line 514
    ...
    local function AttemptSendMail()                 -- line 649: this is the Send button
        ...
        ZO_ConsoleAttemptCommunicateOrError(...)     -- line 654: reaches a private function
    end
    self:AddMainListEntry(GetString(SI_MAIL_SEND_SEND), ..., AttemptSendMail)
```

The add-on never hooked `PopulateMainList` in 0.4.0. It did this, when a letter was picked in
the drafts or sent tab and the Send page was not the tab in front of you:

```
ui:ShowSendPage() -> ZO_MailSend_Gamepad:SwitchToSendTab()
  -> the tab callback -> SwitchToFragment(GAMEPAD_MAIL_SEND_FRAGMENT)
    -> fragment SHOWING -> ZO_MailSend_Gamepad:OnShowing()
      -> self:PopulateMainList()          <- our frame is at the bottom of this stack
```

Four client calls deep, and every closure that call created was born untrusted -- including the
one that sends the mail. So the drafts box worked, the letter went onto the page, and then Send
failed.

**The fix is to write the letter and let the player change the tab.** The compose controls and
the attachment queue exist whether or not the Send page is the tab being shown -- the queue is
one queue in the client, not something the screen owns -- so the letter can be written from the
drafts tab and is there when the player walks over. Their tab change runs `OnShowing` from the
client's own frame, with nothing of ours underneath it.

### What still runs client code from our frame

Two things, both narrower, both deliberate, and neither able to reach `PopulateMainList`:

* `MAIL_GAMEPAD:AddList` and `SetCurrentList`, for our own list. They create list objects, not
  screens, and the closures involved belong to our list.
* `QueueItemAttachment` while restoring a letter. The client handler for the resulting event is
  `OnMailAttachmentAdded`, which refreshes the inventory list -- **but the handler that calls
  `PopulateMainList` on an inventory change is registered in `ConnectShownEvents` and
  unregistered in `DisconnectShownEvent`, so it exists only while the Send page is shown.**
  Restoring from a tab therefore cannot reach it. Restoring with `/pbmail load` while standing
  on the Send page still could, if the client dispatches inventory events synchronously -- which
  is measurement 13.

---

## Measured

The ladder below was walked on the machine, gamepad interface, 2026-09-09. All three answered
the good way, which is why there is no degraded mode anywhere in the code.

1. ~~**`/pbmail where`, with the Send page open, in the interface you actually play in.**~~
   **Done** — answered "gamepad interface". See §4. The keyboard half of the same test is
   unmeasured, but it is the client's own line of code, so it is the lesser risk.

2. ~~**Save a letter with an item and some gold on it, then list it.**~~
   **Done** — `test -> @account [1 items, 100G, 2026-09-09 12:24]`. Reading the page works,
   including the attachment queue and the money.

3. ~~**Clear the page, then load the draft back.**~~
   **Done** — the text and the attachment both came back, and the add-on printed no notes,
   which is the part that matters: a note would have meant a refused attach.

   **This settles the one genuinely uncertain call in the design.**
   `QueueItemAttachment(bagId, slotIndex, attachSlot)` returned `MAIL_ATTACHMENT_RESULT_SUCCESS`
   from add-on code, driven from a slash command, in the gamepad interface. So the queued-mail
   calls are not restricted, and the fallback that was held in reserve -- restore the text and
   list the attachments for the player to re-attach by hand -- is not needed.

   `SetText` on the gamepad compose fields (through `ZO_MailView_Display_Gamepad`) also sticks.


---

## To measure, stage 2 (the tabs)

Same rule: one at a time, and what each answer would prove. This is the gamepad ladder, since
that is the interface in use; the keyboard tab is the same code path with different furniture.

4. **Open Mail. Is there a third tab, "下書き", after 受信箱 and 送信?**
   Yes → `tabBarEntries` accepts an appended tab and the post-hook fires early enough.
   No → the hook did not take. `/pbmail where` now reports whether each interface was wired,
   and prints the error if one failed, which says whether the problem is the hook or the tab.

5. **On the Send tab, is there a "下書きに保存" row under 送信, and does pressing A on it save?**
   Yes → an appended list entry survives the client's own `Commit`.
   No → the entry has to become a keybind on the strip instead.

6. ~~**Does the drafts tab list the drafts, and does A put one back on the Send page?**~~
   **Done** — the tab is there, the draft was listed, and it went back onto the page.

   The same session turned up the taint bug in §7: the tab was there, but the recipient picker
   on the Send page had been poisoned by the hook that put it there. Fixed in 0.2.1 by removing
   every hook.

7. **After 0.2.1 and a UI reload: on the Send page, does choosing 宛先 open the friends list
   without an error?**
   Yes → §7's account of the mechanism is right and the fix is complete.
   No → the taint has another source in this add-on, and every remaining client call made from
   our own frames is suspect: `AddList`, `SetCurrentList`, `ZO_Dialogs_ShowPlatformDialog`.

8. **On the drafts tab, does Y ask before deleting, and does the dialog work?**
   This is the one remaining place the add-on calls a client function that builds something
   (`ZO_Dialogs_ShowPlatformDialog`). If it errors, the confirmation becomes ours rather than
   the client's.

---

## To measure, stage 3 (the sent box)

9. **Send a letter with an item and some gold on it, then open the Sent tab.**
   Listed, with the right addressee, item count and gold → the copy is being taken at the right
   moment and the event's recipient is coming through.
   Listed but blank or wrong → the copy is being taken too late; `/pbmail sent` shows the same
   record, so compare the two before changing anything.
   Not listed → either the update never ran (the page-open callback) or the event never arrived.

10. **Put a sent letter back on the page with A.**
    Text and addressee back → done.
    It also attached an item → expected and correct: it found another of the same kind in the
    backpack. Whatever it could not find is named in chat.

11. **Send two letters in a row without leaving the Send page.**
    Both recorded, in order → the copy is refreshed after a send as well as before one.
    Only the first → the poll is not running after the client's own reset, and the page-open
    callback has to fire again there.

---

## To measure, stage 4 (after 0.4.1)

12. **Pick a letter in the drafts tab, go to the Send tab yourself, press Send.**
    It sends → §9's account is right and the fix is complete.
    It still fails → something else of ours is causing the client to rebuild that screen, and
    the list above is where to look.

13. **On the Send page, with a draft that has an attachment: `/pbmail load 1`, then Send.**
    It sends → queuing an attachment does not make the client repopulate its list, and nothing
    more needs doing.
    It fails → it does, and the command has to write the text only while the Send page is the
    tab in front of you, leaving the attachments to a tab change like the buttons do.