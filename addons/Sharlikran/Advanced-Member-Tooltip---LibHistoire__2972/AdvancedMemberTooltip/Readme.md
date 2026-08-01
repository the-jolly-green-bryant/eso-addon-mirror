Advanced Member Tooltip

- Author: Arkadius (@arkadius1 EU), Calia1120, continued by Sharlikran

This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks
of ZeniMax Media Inc. in the United States and/or other countries.

You can read the full terms at:
https://account.elderscrollsonline.com/add-on-terms

# Description

Adds time of membership and guild bank deposits/withdrawals (gold only) to the guild roster
tooltips.

This addon adds some information to the standard guild roster tooltips:
- Days since a member joined
- Amount of gold that a member deposited on / withdrew from the guild bank

When the addon is run for the very first time, it needs to download all information from
the server first. This needs to be done only one time and may take some minutes.
NOTE: If you're running other addons, that request guild histories (like Shopkeeper or
Master Merchant) you might get bounced from the server because of spam. In that case, I
suggest disabling those addons for the initial scan.

After the initial scan, all further scans are done every 5 minutes to keep the information
up to date.

* This addon does not have an in game settings menu currently. I am planning on adding it
in addition to some other features in the future as time permits.

# Manual Installation

1. Go to the "Elder Scrolls Online" folder in your Documents.

For Windows: C:\Users\<username>\Documents\Elder Scrolls Online\live\
For Mac: ~/Documents/Elder Scrolls Online/live/

2. You should find an AddOns folder. If you don't, create one.
3. Extract the addon from the downloaded zip file to the AddOns folder.
4. Log into the game, and in the character creation screen, you'll find the addons menu.
    Enable your addons from there.

# Changelog

## 2.35, 2.36

- Imporved routine to remove unused save data

## 2.34

- Cover instance where guild name is an empty string from an old LibHistoire issue

## 2.33

- Fix for: AdvancedMemberTooltip.lua:976: attempt to index a string value

## 2.32

- Added routine to remove unused save data
- Time format is less precise and omits seconds and minutes depending on days and hours

## 2.31

- Fix for updateJoinDate when you log in just as a new guild member gets invited

## 2.29, 2.30

- Update refresh routine so it isn't never ending now that LibHistoire is updated for U41

## 2.28

- API Bump For Dependencies
- Updates for Join date and Deposits now that user events are viewable to the individual that made them

Note: ZOS still restricts guild deposits based on GM settings

## 2.27

- API Bump For Dependencies

## 2.26

- Updated for U41

## 2.25

- Fix GetAmountDonated() for members joining a guild while you are online
  - leading to errors such as:
    - AdvancedMemberTooltip.lua:1304: attempt to index a nil value

## 2.24

- API Bump

## 2.23

- Updated settings to keep EU and NA LibHistoire tracking separate to prevent resetting the data when switching between servers

## 2.22

- Fix for error on line 303: operator - is not supported for number - table when no LibHistoire join date is present

## 2.19, 2.20

- Possible fix for an error caused by users joining a guild after AMT has initialized

## 2.18

- Updated localization for settings menu
- Added LibGuildRoster Support and Donations Column
- Fixed user join date displayed when there is no date in LibHistoire, was showing 57 years
- Fixed deposit and withdrawal time reports for most recent and earliest for the week
- Added support for a future feature to display time ranges similar to Master Merchant (Not Implemented Yet)

Note: There has been a major saved variables update. In chat type "/amt fullrefresh" (without quotes) to fully update guild information. Only do this once!

## 2.17

- Updated localization method
- Updated French Translation
- Fix for: bad argument #3 to 'string.format' (integer expected, got string) in AdvancedMemberTooltip.lua:327 for French client

## 2.16

- Revised refresh option to hopefully catch when LibHistoire is processing events a little better

## 2.15

- Pre PTS version

## 2.14

- Did not realize that the guild founded date processing was not automatic depending on region. There is now a dropdown to choose the Date format for your region. Such as yy.dd.mm or dd.mm.yy and so on.

NOTE: This only affects how the guild founded date is processed because ZOS made it a string for some reason.

## 2.13

- Pre PTS version

## 2.12

- API Bump
- Only transmit LibHistoire Bank information for the current week since the kiosk flip
- If player does not have permission to view bank deposits and withdrawals rather then display zeros for the information don't display that information on the tooltip

## 2.11

- Fix for: AdvancedMemberTooltip.lua:834: attempt to index a nil value

## 2.10

- Fix for offline status when the server has used epoch time instead of the seconds since someone logged off
- Updated how the player's days for deposits are shown. Now if someone has not deposited any gold for the week it will say "0 d" for 0 days ago.
- Updated time formatting to show days, hours, minutes, and seconds
- Offline status updated when the GM logs in. No need to be online to track when a player logged out last as with previous versions.

## 2.09

- Fixes to address when a member joins the guild, while you are online, have not reloaded the UI, and does not exist yet in the user database

## 2.08

- Updated Epoch time export

NOTE: Joined date when unavailable to the server will be exported as April 4 2014. Last seen date will be 0 when unseen, or the Epoch time recorded when the player's status changed to offline. Hopefully sorting in a spreadsheet will be better with this format.


## 2.07

- Opps forgot to add a new separator for exporting with Epoch time

## 2.06

- Added toggle to export Guild Stats with Epoch time which is what the game uses by default.

NOTE: I am not a spreadsheet guru but I know that a spreadsheet can use the Epoch time and convert it

## 2.05

- Added Time Since last Login to export

## 165 (5/17/18)

- API updated for Summerset (100023)

## 1.5 (6/10/17)

- API updated for Morrowind (100019)

## 1.4 (2/6/17)

- API updated for Homestead (100018)

## 1.3 (10/5/16)
- API updated for One Tamriel (100017)

## 1.2 (7/14/16)

- API updated for Shadows of the Hist (100016)

## 1.1 (6/6/16)

- Goofed the README file, my bad. Fixed!

## 1.0 (6/5/16)

- Updated API for Dark Brotherhood patch, added language localizations for
- FR, corrected some German localizations as well.

## 0.1.2 (4/23/15)

- Fixed a bug where AMT would display too high numbers for memberships

## 0.1.1 (4/17/15)

- Fixed a bug that caused a LUA error when requesting a tooltip of a guild member that wasn't scanned yet
- Added some text output during the initial scan to let the user know about the progress

## 0.1.0 (4/15/15)
- Initial release
