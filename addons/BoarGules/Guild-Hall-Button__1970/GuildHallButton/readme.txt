Guild Hall Button

by Boar Gules 
esoui@boargules.com

Many players of Elder Scrolls Online® have hankered after guild halls of the sort provided by Guild Wars.

When Zenimax announced Homestead, the ESO housing framework, many guilds immediately co-opted it as a way to set up guild halls. Typically, though not always, the guild hall is the guild leader’s primary residence. Often, such houses are not furnished as residences at all: they have full catering facilities, crafting stations, and other things you would not expect to find in a private home, however wealthy the owner might be. And frequently, the sleeping quarters, if any, call a barracks to mind, rather than a residence.

You can quite easily travel to such a guild hall: simply pick your guild leader’s name out of the guild roster and select Visit Primary Residence from the context menu.

The Guild Hall Button add-on does little more than that. It is a simple way to reduce the number of mouse-clicks required, and also expresses the intention of the guilds that such houses are not residences at all, but guild halls.

To Install

Most people use Minion to install add-ons, but if you want to do a manual install, that is very straightforward. Open the zipfile and you will see a folder called GuildHallButton. Extract this folder to your ESO add-ons folder. 

• On a PC that will typically be C:\Users\username\Documents\Elder Scrolls Online\live\AddOns. If you have installed ESO on another drive, or have chosen another location for your Documents folder, you will presumably know what to substitute for C:.
• On a Mac that will typically be ~/Documents/Elder Scrolls Online/live/AddOns.
Once you have done this you should have a new folder in AddOns called GuildHallButton. There should be 11 files and 2 subfolders inside it:
• GuildHallButton.lua and Version.lua
• GuildHallButton.txt and GuildHallButton.xml
• this documentation in two forms (GuildHallButton.pdf and readme.txt)
• 5 screenshots (.jpg)
• subfolders lang (for internationalization) and lib (for library files).

Operation

Following a successful install, if you press G for Guild, you should see Guild Hall shown on the bottom left of your Guild home screen. Press the button Travel to Guild Hall and you will be moved to the “primary residence” of that guild’s leader.

Configuration

This add-on was intended to be zero-configuration software. But some guilds have castellan-officers, and it is their primary residence that is the guild hall, not the guild leader’s, and this situation needs to be manually configured. Otherwise, pressing the button will either take you to the wrong place, or simply yield the warning The house you attempted to visit is unavailable.

It is not uncommon for a single management team to run a group of related guilds with a shared guild hall. But, according to ESO rules, a player may be leader of only one guild, so the shared guild hall will not always belong to the leader of the guild you are in.

An add-on cannot discover this situation from the game API, because from the game’s point of view, there is no such thing as a guild hall. Even as a player, you can only find this out by reading your guild’s message of the day, website, or Facebook page. In such cases, you need to enter the information manually.

Fortunately, configuration is simple. Start by going to the game menu Settings | Addons | Guild Hall Button.

This will list your guilds, with three fairly self-explanatory option settings for each.

• Override default guild hall. Set this to on if you need to configure the Guild Hall Button. This will enable the remaining 2 settings:
• Castellan officer. This is the name of the guild officer who is the formal owner of the guild hall. The default value is (guild leader) because that is the usual situation. A drop-down list will offer you a list of the senior officers in the guild to choose from. If the name you want is not on the list, see Extras below.
• Name of guild hall. The default value for this is (principal residence) and you will hardly ever need to change it. A drop-down list will offer the names of notable houses, which are the only ones likely to be guild halls. If the house you want is not on the list, see Extras below, which also suggests why you might possibly want to do this.

Leaving and Joining Guilds

When you leave a guild or join a new one, the configuration screen will not show your changed membership until the next UI reload. This happens when you log out or issue the /reloadui command.

You can choose to have the Guild Hall Button do an automatic UI reload when you leave or join a guild. Then the configuration screen will always reflect all of your guild current memberships.

But switching this on will mean that if you join or leave two guilds in succession, you will get two /reloadui commands. This may not be what you want.
If in doubt, leave these options switched off.

Error Reporting

If something unexpected happens in an ESO add-on, the game will normally display a UI Error window with the traceback of the code leading up to the Lua error.
Tracebacks are vital to the developer. Without them, solving the problem is close to impossible. But they are meaningless to the end-user. For this reason, this add-on traps and stores the traceback, and simply issues a message saying that what you were trying to do did not work, and that you can retrieve the traceback using the command /guildhall traceback.

You can do this at any time, so that you can compose a bug report when it suits you, instead of having to choose between composing a bug report at that very moment, or closing the UI Error window and destroying the evidence. The Guild Hall Button stores your last 9 tracebacks, numbered 1 to 9. Traceback 1 is the most recent.

Extras

Bypassing the Settings menu

You can use slash commands to bypass the Settings menu. You may need to do this if the drop-down lists on the configuration screen don’t show you the player or the house that you want. It may also be helpful in special situations, such as when playing on the Public Test Server, where it can happen that other add-ons (including ones that the Guild Hall Button depends on) may not always be up to date.

Start by typing the command /guildhall list and you will see a dialogue box showing the guilds you are a member of.

Now suppose that the guild hall of Rangiest Rangers is not the guild leader’s primary residence but is instead the primary residence of castellan-officer @Slartibartfast. Type this command:
/guildhall 2 @Slartibartfast

That will take you to the guild hall, so that you can be sure that your configuration is correct. After that, the next time you press the guild hall button, it will take you to the right place without having to be told a second time. If you see the warning Can’t identify @slartibartfast as a guild member, it indicates you have typed the name wrong. Names are case-sensitive, and the leading @ is required.

To reverse this configuration, simply do the same thing, but supply the guild leader’s name.

For people who dislike taking their fingers from the keyboard, you can also use the command /guildhall (alternative spelling /gh), without a player name, to take you to the guild hall, and you can optionally type a number between 1 and 5 (for example /guildhall 2) to specify which guild. If you omit the number then the command takes you to the guild selected on the guild home screen.

A guild leader whose primary residence is a guild hall will generally have other, more modest accommodation elsewhere. If you have permission to visit one of those other houses, you can go there using the following command:

/guildhall number name

where number is the number of the guild as shown above (not optional), and name is the name of the house, or part of it. For example, typing /gh 1 sleek is enough to identify Sleek Creek. The name you type must be long enough to match exactly one house.

You can combine the two forms of the /guildhall command to permanently set the guild hall for a guild to something other than a primary residence, for example:

/guildhall 2 @Slartibartfast sleek

though it is unlikely that you would want to do this in normal circumstances, because that would mean that guild 2’s guild hall could only be reached by using the Guild Hall Button, or another add-on with similar facilities, because there would be no way for guild members to go there using the game’s normal UI. The only use-case for this would be as a convenience when playing on the Public Test Server. 

Visiting houses other than guild halls

If you want the ability to go to any house of any player, but not set it as a nonstandard guild hall, use the command /visit instead of /guildhall. This was an extra requested by some users and it is disabled by default. After enabling it in the configuration screen, you can use this command:

/visit @Slartibartfast sleek

which will simply take you to @Slartibartfast’s house at Sleek Creek but won’t affect guild hall settings. If you don’t specify a house then the /visit command will take you to that player’s principal residence. If you specify a house but not a player the command will take you to your house of that name.

Version checking

The command /gh version will show a dialogue box giving 

• The version of the add-on. The version numbers follow the principles of semantic versioning, fully described at semver.org.
• The version of the game API that is currently running. This version is determined by Zenimax and generally changes after a major update. If this number is higher than an add-on supports, then the game will mark that add-on as out of date.
• The versions of the API that the add-on supports. Add-ons can support two successive API versions. This can be helpful when the Public Test Server is running a later version of the API than the live game. 

This happens for some weeks before each major update.

Slash Command Reference

The two commands /guildhall and /gh are equivalent. They take the subcommands shown below:

+-------------------------------+-------------------------------+--------------------------------------------------------------------------------------+
|      Possible subcommands     |             Example           |                                        Effect                                        |
+-------------------------------+-------------------------------+--------------------------------------------------------------------------------------+
|             blank             |               /gh             |                           Go to guild hall of current guild                          |
|          guild-number         |              /gh 3            |                              Go to guild hall of guild 3                             |
|     guild-number house-id     |           /gh 1 sleek         |                  Go to the guild 1 leader’s house called Sleek Creek                 |
|                               |            /gh 1 23           |                                                                                      |
|      guild-number @player     |      /gh 2 @Slartibartfast    |  Go to @Slartibartfast’s principal residence and make that the guild hall of guild 2 |
| guild-number @player house-id |   /gh 2 @Slartibartfast sleek |   Go to @Slartibartfast’s house Sleek Creek and make that the guild hall of guild 2  |
|                               |    /gh 2 @Slartibartfast 23   |                                                                                      |
|              list             |            /gh list           |                  List all guilds and guild halls in a pop-up window                  |
|               ?               |              /gh ?            |                                                                                      |
|            version            |           /gh version         |          Give add-on version number and API compatibility in a pop-up window         |
|           traceback           |          /gh traceback        |                Display the most recent traceback in a UI Error window                |
|   traceback sequence-number   |         /gh traceback 1       |                                                                                      |
|                               |         /gh traceback 3       |                                  Display traceback 3                                 |
+-------------------------------+-------------------------------+--------------------------------------------------------------------------------------+

The companion command /visit is only available if you enable it in Settings | Addons | Guild Hall Button. Use it as shown below:

+----------------------+-------------------------------+----------------------------------------------+
| Possible subcommands |             Example           |                    Effect                    |
+----------------------+-------------------------------+----------------------------------------------+
|       @player        |     /visit @Slartibartfast    |  Go to @Slartibartfast’s principal residence |
|    @player house     |  /visit @Slartibartfast sleek |   Go to @Slartibartfast’s house Sleek Creek  |
|        house         |          /visit sleek         |         Go to your house Sleek Creek         |
|    outside house     |      /visit outside sleek     |  Go to the outside of your house Sleek Creek |
+----------------------+-------------------------------+----------------------------------------------+

Obsolescence

ESO 8.2.5 Update 36 rendered this add-on’s namesake button mostly superfluous. Guild leaders can now put a link to their guild hall in the guild’s Message of the Day, which essentially duplicates the functionality of the button, on the same screen. The link mechanism is more convenient, and also allows several houses to be listed, made desirable after it became impossible to fit everything that should be in a guild hall into one house. And, of course, there is no need to install an add-on because the link is managed by the guild leader (which is where the control should lie) and not by individual players.

I will maintain the add-on for continuity and because its /visit command is still useful and popular. It was originally an extra, but now becomes the add-on’s primary justification.

My thanks to everyone over the past 5 years who participated in the long beta test, who conscientiously reported bugs, and who contributed translations, and to the thousands of players who downloaded and used it.

Translation

Spanish

Warm thanks to Narian of the now-disbanded Cervanteso team. That team did such a good job that eventually Zenimax came out with an official Spanish version of the game, in June 2022. It is almost certain that the availability of the Cervanteso translation drew more Spanish speakers to the game, which in turn made it worthwhile for Zenimax to support the language officially. You can read the story of the project here: https://p10.helmantika.com/2022/06/07/memorias-de-un-proyecto-altruista-cervanteso/

French

Warm thanks to mouton.

Russian

Warm thanks to GJSmoker.
