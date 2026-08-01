Hey Jensen Bounty Tracker v1.0.2

New in v1.0.2:

Added bounty kill verification.
When a player wins a completed duel against an active bounty target, the addon creates a bounty claim code.
Forfeits are ignored.
Duels under 10 seconds are ignored.
The player can use /hjb claim or the Mail Last Claim button to send the claim to @Hey-Jensen.
The claim mail includes killer, target, bounty amount, duel seconds, timestamp, and claim code.
Jensen can verify a claim with /hjb verify @Killer @Target 100000 12345 1234567890.

New in v1.0.1:

The addon now uses the wooden Jensen Bounty Tracker board as the UI background.
A small top 3 bounty submenu opens automatically every time the player logs in or reloads UI.
The full bounty board menu now explains how the addon works on the wooden board without overlapping the text.
Added /hjb mini to reopen the small top 3 bounty window.

Hey Jensen Bounty Tracker is an in game bounty board addon.

Players can open the addon, enter a target ESO account, enter a gold amount, and click Mail Bounty Gold. The addon opens mail to @Hey-Jensen and prefills the bounty subject and message. The player must manually attach the gold before sending.

The addon listens for bounty announcements from @Hey-Jensen in chat. Anyone who has the addon installed and sees the message in say, zone, or another chat channel will have their local bounty board updated.

Admin announcement format:

Hey Jensen Bounty: @TargetName is 100000 gold.

Remove format:

Hey Jensen Bounty Remove: @TargetName

Commands:

/hjb
/bounty
/hjb mail @TargetName 100000
/hjb announce @TargetName 100000
/hjb remove @TargetName
/hjb list

Important limitations:

This is an in game only bounty tracker.
There is no Discord requirement.
There is no outside server.
Players only receive bounty board updates if they are online and see the admin bounty message in chat.
Gold deposits and payouts are manual through in game mail.
