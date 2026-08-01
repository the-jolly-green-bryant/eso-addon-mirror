VERSION 1.2x
-----------------
Now includes guild bank tracking, right now it only refreshes whenever you log into a character. However, you can force an update with "/dtgbupdate". You need to set a guild in the settings menu.

Description
-----------------
Records values of all gold and item donations received via mail and guild bank. Set keybind for the window or type /dt to show.

Settings
-----------------
Any settings you change only applies to future donations, all recorded donations are set in stone unless you click the button to manually apply the settings retrospectively.

Resetting Cycle
-----------------
All donation records are erased and DonationTracker forgets about any raffles injected into RaffleUnlimited. So only use this option when you are starting a fresh tracking cycle.
If you want to back up the data for your own records before resetting use the external exporter 

Optional Dependencies
-----------------
For best results with price guessing, use this addon with MasterMerchant, TTC, and WritWorthy
Also see integration for RaffleUnlimited

Mail Handling
-----------------
If a mail's SUBJECT looks like "OnBehalfOf: @username" OR "obo: @username" then DonationTracker will record all attachments in that mail as sent by @username. Note that @username IS case-sensitive.
There are 2 keybinds for the mail inbox. You set it under Controls -> Addons at the very bottom section under "User Interface". I recommend setting the Track/Untrack key to SHIFT for accessibility.

Donation Forwarding
-----------------
If you have multiple officers who receive donations, you can forward a description of these mails to the guildmaster (not the actual mail because attachments can't be manipulated via the API).

For the forwarder:
Simply set a keybind for forwarding data and enable forwarder mode. Press it when you want to forward a donation mail. Note this will not send the actual attachments due to API limitations, only information about the attachments.

For the guildmaster:
After you receive a mail with the subject line starting with "data:", you need to press the Accept keybind to record the data in DonationTracker.
Please check where the mail came from so bad actors don't try to get free raffle tickets by sending you bogus donation data!

Slash Commands
-----------------
/dt
Show the DonationTracker window

/dtundo #<MailID>
If you accidentally tracked a mail that's not a donation mail, you can undo tracking with this command. This will delete all donation records from that mail #. Use with caution.
E.g "/dtundo #123"

/dtcustom [<ItemLink> <price>]
You shouldn't need this command with the UI other than to manually review the custom pricing table.
Sets a custom price for a specific item. ItemLink is a link from Right Click -> Link in Chat. Price is any number.
E.g "/dtsetprice" to list all stored custom prices
E.g "/dtsetprice [Tempering Alloy] 5000" to set a custom price of 5000
E.g "/dtsetprice [Tempering Alloy] ?" to remove/unset the price entry
E.g "/dtsetprice [Tempering Alloy] auto" to try to auto guess the price again (possibly with more MM or TTC data)

/dtreset
Clears all item records and account records to reset the cycle.

RaffleUnlimited
-----------------
This addon has no plans to do raffles at this point. However, included is a convinient slash command for injecting custom tickets into RaffleUnlimited through its slash command interface.

/dtruignore [-][@username|#MailID]
Do not inject raffles for this user. DOES NOT AFFECT DONATION TOTAL. ONLY RAFFLE INJECTING.
E.g "/dtruignore" to list all stored ignored users
E.g "/dtruignore #5" to ignore mail #5 for the raffle only (does not affect donation total)
E.g "/dtruignore -@username" to remove the user from the ignore list for the raffle only (does not affect donation total)

/dtruinject [allowreset]
Convert total donation value into raffle tickets and inject them into RaffleUnlimited. The number of tickets injected is recorded so you can run this command multiple times to keep raffle tickets up to date.
However, if for some reason a guild member's donation amount is decreased and raffle tickets need to be removed then the only way to do so is by resetting ALL custom tickets. This includes custom tickets added NOT by this addon.
Note by default though ticket overages are simply ignored, unless you run the command with allow reset. E.g "/dtruinject allowreset"