# Royale With Cheese (Chat Filter)

Author: @Messajah (EU)

Cleans up the Elder Scrolls Online chat, Quentin Tarantino style with guns blazing. You know what they call a Quarter Pounder with Cheese in Paris? They call it a Royale with Cheese... Well, they can keep it. It's called a Quarter Pounder!

[https://www.youtube.com/watch?v=ymtTUPqSFcM](https://www.youtube.com/watch?v=ymtTUPqSFcM)

Anyway, on a more serious note, the multilingual chat system in Elder Scrolls Online is extremely poorly implemented. Every player from the whole world is dumped into the "/zone" chat, and the game stupidly doesn't subscribe people to their own language-specific "English Zone", "German Zone", "Russian Zone", etc. As a result, most people are only subscribed to the global "/zone" and don't even use their own native zone chats at all.

Some people may say "Fine, so let everyone speak every language they want in /zone so that they can reach the other players who speak that language". But the problem this creates in REALITY is that /zone is an endless barrage of people incessantly chitter-chattering and spamming in various languages that nobody else understands, which is just a bunch of distracting garbage for all other people and just pushes away important messages (such as your own guild chat). ESO's zone chat is a total mess, and it's the game's fault for implementing the chat so poorly.

A proper game implementation would be to delete /zone, and only have the language-specific channels, so that people don't have to see various national languages that they'll never speak. But they're obviously never going to fix the chat system.

Therefore, we have to bring in our own cleaning crew: This addon. It detects various non-English alphabets and deletes all messages written in those languages, so that your screen remains clean and uncluttered. Thereby ensuring that all people speak Tamrielic in Tamriel.

Peace at last.


## Requires:

- [LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu.html)


## Features:

- Easy installation. The default configuration is perfect for most people and will filter all non-English messages from /zone, /say, /yell and /emote, so that you can simply install this addon and immediately enjoy the improved game chat.
- Extremely high performance with 0% game impact. Better than ALL other chat filter addons. The filtering algorithm takes around 0 milliseconds per message, even for max-length messages. It will not slow down your game performance whatsoever!
- Supports both the original game's chat and the popular "[pChat](https://www.esoui.com/downloads/info93-pChat.html)" addon.
- Written in a reliable way which cleanly intercepts the messages without causing any game bugs. Therefore, this addon will continue working forever without any need for updates as long as ESO never changes their chat code. And it's very unlikely that they'll ever change anything.
- Accurate language detection code which catches 99% of all non-English messages. Messages will be perfectly intercepted as long as they contain at least one of their own national non-English alphabet characters.
- Gathers statistics about how many messages it has blocked, just for fun. The statistics are account-wide and lets you see exactly how much garbage you've cleaned up from your screen.
- Full control over which chat channels will be filtered. You can toggle additional channels. Every channel in the game is supported.
- Two separate controls for which alphabets/languages to filter: Cyrillic (i.e. Russian) and European languages (German, French, Spanish, etc...). By far the most "spam" on the EU megaserver comes from Russian (80%). German (15%) is the 2nd most spammy language, and then there's some occasional Spanish speakers (5%). French is also included since it's seen occasionally. Other European languages are extremely rare in the game, but may also be caught in these alphabet filters, since several human languages partially share the same alphabet characters.


## New Feature Requests:

- In most cases the answer will be NO if it's beyond the scope of this addon's purpose. Wild fantasy ideas that radically transform this addon will be rejected.
- I will not implement deeper per-language controls than the "block Cyrillic and/or European" selection that it currently offers. Deeper controls may "sound" like a good idea, but actually makes no sense, because almost all of the European languages share the exact same alphabets/characters. Any other addon that pretends to let you filter "only German" for example is lying, since most of the German letters are also used in all Nordic/Scandinavian languages, and the same is true for all other European languages. There is simply too much overlap in the European alphabets, and no matter how carefully we separate the alphabets, we'd still always end up catching multiple languages that use the same characters. Besides, if you personally have friends that speak a specific language and you want to talk to them, then you should talk to them in your guild chat, group or whispers, instead of cluttering up the general zone chat.
- There are no plans to add more languages, but I will possibly add more languages to the "European" category if you have any GOOD suggestions. However, the addon already catches ALL of the active languages that are spammed in the game.
- If an idea is truly great and fits the intended scope of this addon (filtering languages), then I might still add it. Feel free to tell me your ideas.


## Frequently Asked Questions:

- Q: How does this addon compare to older chat filter addons, such as "Cyrillic Chat Filter" and "Clean My Chat"?
- A: The performance, detection accuracy and code quality of this addon is vastly superior to all older alternatives, which is the reason why this addon was created. Both of those older addons have very poor detection code, which only scans for a small subset of the alphabet letters and thereby allows plenty of messages to escape past their weak filters. Their code is also completely incorrect and doesn't handle uppercase vs lowercase letters, which further weakens their filters. Lastly, their performance is awful due to their spaghetti code (which does things such as "string:find()" on the entire message over and over again for every individual letter, and incorrectly and wastefully does "string:lower()" even though that function only works on ASCII text, not multi-byte Unicode text). I'll say it again: This new addon was created because the old ones were so awful. You should use "Royale With Cheese" if you care about incredibly fast performance, detection accuracy, clean code, zero impact on the game's stability and never having code conflicts with any other addons.

- Q: Why do I sometimes still see non-English messages?
- A: The person has written a message without using their own alphabet. For example, a German speaker may write "ich liebe dich" which contains nothing from the German alphabet. There's no way to detect such a message as non-English. We'd have to import big national word dictionaries into the game engine and scan for whole words to detect that it's German, which would be way too slow for the game engine and also risks lots of false positives (for example, "die" is a word in both English and German), so we're not going to do that. No other chat filter addons do that either. We detect the usage of non-English alphabets, which helps us achieve extremely high performance and catches 99% of all messages. You'll have to live with the occasional but extremely rare messages that slip through the filter.

- Q: Is this addon racist?
- A: I've seen this extremely ignorant claim so many times on all other language filter addons and in Reddit and forum discussions, that it seems to need its own proactive FAQ entry. The answer is No. Only an idiot would think that cleaning up distracting, foreign languages that you *can't read* from the game chat is somehow "racism". Their very common claim that "it's racism when English-speakers refuse to learn Russian", could equally be applied to say "the Russians are racist for refusing to learn English and choosing to do a hostile takeover of the zone chat by spamming Russian even though only about 2% of the world speaks their language". That's the end of this discussion. Everyone has the right to play the game without having to see random, spammy messages that just clutter up our screens and are totally unreadable by us. If you want a proper solution to this problem, just ask ZOS to finally enforce their per-language zone chats instead. Anyone who wastes space in the forum comments and ignorantly claims that this addon is "racist" will be reported to the admins of ESOUI for spamming the addon forum with inflammatory off-topic comments. I've seen it enough on all similar addons and don't want to see the same inflammatory behavior here. Thank you.


## Addon Code License:

- All rights reserved. All code is written by me.
- No forks allowed. Writing an addon takes a considerable amount of time and work. I respect your work and you respect my work. You don't have the right to simply steal my work and rewrite it slightly. If something about the current project makes you unhappy, then you should simply propose it as a feature request, and if it's a good idea then it will be added.
- If I ever quit the game someday, then I will open up the code for anyone else who wants to maintain it. Until then, I'm the maintainer if you have any feedback / requests.