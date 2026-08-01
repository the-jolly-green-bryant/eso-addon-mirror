This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

++

MailHistory by @PacificOshie.  Have fun!

Mail History saves a copy of your mail when sending, taking, returning, and deleting mail to provide a history of your mail activity.

Mail History data is stored account-wide across all characters.  Mail that was sent, taken, returned, or deleted on one character may be viewed on another character.

Mail is only shown in the history when it is no longer in your mailbox.

Reply to mail and Forward mail (without attachments) from the history.

Export the currently shown or filtered history using copy-and-paste into your own spreadsheet or file.

DEPENDENCIES
- LibAddonMenu-2.0
- LibAsync
- LibCustomMenu

++

MAIL HISTORY SETTINGS
- Automatically show and hide the history when viewing your mailbox.
- Included or exclude System mail from displaying in the history.

CHAT SETTINGS
- Log a mail summary in the chat window when sending, taking, returning, and deleting mail.

STORAGE SETTINGS
- Save or delete System mail.
- Increase or decrease the number of saved mail.  The number of saved mail affects memory usage, disk space, and performance.

DATE AND TIME SETTINGS
- Select the preferred date and time display format.

EXPORT SETTINGS
- Select the preferred separator when exporting mail.  For example, commas for CSV and tabs for TSV format.

++

COPY AND PASTE
- The popup displays mail to allow selecting the text to copy and paste.  Click to put the cursor into the text, then select all using CTRL+A and copy using CTRL+C.

MISSING MAIL INFO
- Some other addons process mail before Mail History can save the mail.  If an entire mail is missing, you may see the message "Missed mail due to other addons."  And if attachment info is missing, you may see the message "Unknown attachment."
- Some old addons replaced the ESOUI mail functions so Mail History is not notified of mail.  Please ensure you're using addons that have been updated recently.

NOT CERTIFIED MAIL
- Mail is saved in an unencrypted file which may be modified on the file system.  The existence of data does not guarantee or certify its authenticity.  The data is intended to be used as a personal copy of your mail and it’s not to be used as proof of sending or receiving mail.

PERSISTING DATA
- The ESOUI system is designed to hold data in memory and only persists the data to disk when a user reloads the ui, logs off, or exits the game.  If the game or machine crashes before reloading the ui, logging off, or existing the game, then any new mail will be lost.  The easiest way to force persisting the data to disk is to execute the command: /reloadui

++

2024-04-24 v14 - Added a new export capability to copy the mail history data into a CSV (comma) or TSV (tab) format.  Also, updated the api version.

2024-01-18 v13 - No code changes.  Only updated the api version.

2023-08-21 v12 - Added a NEW DEPENDENCY on LibCustomMenu for the context menu of the mail history list.  Also updated the api version.

2023-06-13 v11 - No code changes.  Updated version to include Scribes of Fate 101037 and Necrom 101038.

2023-02-24 v10 - Fixed a bug when unintentionally deleting Player mail when intending to only delete System mail.

2023-02-18 v9 - Added the ability to Reply and Forward mail from the history using the right-click context menu or from the mail popup window.

2023-02-12 v8 - Added a keybinding to toggle the history window.  Added options for the date and time format.  Simplified options for showing System mail which includes hirelings, trader, pvp, etc.  Added a new option to stop saving System mail altogether (besides just hiding it).  Updated RU Russian translations by Verling!  Updated to API version 101037 for ESO 8.3 Scribes of Fate.

2023-02-09 v7 - PLEASE BACKUP YOUR SAVED VARIABLES!  Fixed an issue with updating data across versions.  Support for hiding the guild trader mail in DE, EN, FR, JP, and RU.  Updated DE German translations by Baertram!  Updated RU Russian translations by Verling!

2023-02-06 v6 - Added DE German translations by Baertram!  Added RU Russian translations by Verling!  Duplicate sent mail (e.g., guild newsletter) is kept as a single mail with multiple recipients.  Added a status message for how many mail are being shown.  Added a progress bar when using the search filter.  Added a tooltip option to display some mail details from the history when mouse over.

2023-02-03 v5 - Fixed the error when clicking on the window title.  Moved saved data to be server region specific, but settings are server region agnostic.  Updated the date and time to use the system locale.  Display the character in the history who was sending, taking, returning, or deleting the mail.  Support for hiding the hireling mail in DE, EN, FR, JP, and RU.  Added language support for display strings but still need translations.  Save mail that was taken, returned, or deleted in gamepad mode.  Works with Lazy Writ Crafter auto-loot hireling mail.

2023-02-02 v4 - Indicate which character on your account was sending, taking, returning, or deleting the mail.  Show and hide the mail history using mailbox events to support gamepad mode.  Added another event handler to attempt saving mail before other addons remove them.

2023-02-02 v3 - Refresh data every time the history is shown so any updated settings are applied.  Handle unknown attachments when mail data is missing due to other addons.

2023-01-30 v2 - Added an option to save more mail; and added an option to hide hireling mail.  Added a search filter to the history to allow finding mail with specific text.  Added a popup window that shows more details when clicking on mail from the history; and allows selecting CTRL+A and copying CTRL+C the mail text.

2023-01-25 v1 - Preview release.
