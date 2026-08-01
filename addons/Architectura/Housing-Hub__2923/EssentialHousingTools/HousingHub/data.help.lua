if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

local DATA =
{
	["Index"] =
	{
		Title = "Housing Hub Basics",
		Content =
		[[Welcome to the Housing Hub and to the largest Housing Community for The Elder Scrolls Online. We are excited to have you join the thousands of other members in our ever growing Community, to share our builds and creativity with you and to visit and tour any homes that you would like to open up to us.
|ac
What does the Housing Hub have to offer? Our goal was to provide one central place where you can easily:
|r
|pip Visit your homes and any homes of any other player
|pip Organize your favorite homes and keep personal notes on each
|pip Tour homes participating in guild events and contests and find your guilds' designated Guildhalls
|pip Discover new homes beyond the boundaries of your friends list and guildmates
|pip Share your homes with the entire Housing Community
|pip Sign in at homes you visit and see who stopped by yours
|pip Track your furnishings across your homes, storage chests, bank and characters' inventories**
|ac
**Requires the DecoTrack add-on
(Available from ESOUI.com and Minion)
|r
		]],
	},
	["CommunitySetupVideoPC"] =
	{
		Title = "Community Setup Video (PC)",
		Url = "SetupCommunityPC",
	},
	["CommunitySetupVideoMac"] =
	{
		Title = "Community Setup Video (Mac)",
		Url = "SetupCommunityMac",
	},
	["CommunityApp"] =
	{
		Title = "Community App",
		Content =
		[[Many Housing Hub features - including Open House tours, hosting your own Open Houses and signing Guest Journals - require the Community App.

While you are playing ESO, the Community App syncs with the Community server to download other players' Open House and Guest Journal information and publishes any of your own Open House listings.

The Community App comes bundled with this add-on making setup easy. To install the Community App, check out the |cffff00Community Setup Video|r Help category for your platform (on the left) or use the following instructions.

Open Windows Explorer and navigate to the "EssentialHousingCommunity" folder located here:

    Documents
        The Elder Scrolls Online
            live
                AddOns
                    EssentialHousingTools
                        EssentialHousingCommunity

Right-click the "EssentialHousingCommunity" App inside of the "EssentialHousingCommunity" folder and choose "Run as administrator"

|pip EXPLANATION: This installer configures the Community App to run at Start Up which may prompt some firewall or anti-virus software to block the installation or prevent the Community App from communicating with the Community server. For this reason, we recommend running the application as an administrator which is often easier than manually configuring firewall or antivirus software to allow the Community to run.

Confirm the Windows prompt that follows and wait several seconds for the final setup completion dialog. If you have ESO open and you are already signed in, please reload the User Interface by typing /reloadui

Congratulations! You should now be ready to tour Open Houses, host your own and see who stopped by with Guest Journals.
		]],
	},
	["LiveStreams"] =
	{
		Title = "Live Streams",
		Content =
		[[|acDo you live stream Elder Scrolls Online Housing content?
|r
Let the thousands of Essential Housing Community members on the European and North American megaservers know about your channel and when you are live in 2 easy steps:
|cffff44|ac
1. Register your Twitch channel
|r
Open the Housing Hub (type /hub), click the Live Streams tab, click |cffff88"Go Live..."|r and enter your Twitch channel's web URL, name, schedule and a brief description.
|cffff44|ac
2. Announce your stream each time you Go Live
|r
Before each live stream, open the Housing Hub, click the Live Streams tab and click |cffff88"Go Live..."|r.  This will let Essential Housing Community members know that your stream is now Live.

After you |cffff88"Go Live..."|r for the first time, your Twitch channel will also be listed in the Live Streams tab of the Housing Hub for the thousands of Essential Housing Community members to see.  |cffff44Just be sure to click the "Go Live..." button before each stream|r in order to announce your Live stream to everyone that is online.

Please note that Twitch channels will be automatically unlisted if they do not "Go Live..." at least once every 30 days.
		]],
	},
}
HOUSING_HUB_HELP_TOPICS = DATA

do
	local ICON_PIP = EHH.Textures.ICON_PIP

	for topicId, data in pairs(DATA) do
		if data.Content then
			data.Content = zo_strgsub(data.Content, "|pip", ICON_PIP)
		end

		data.TopicId = topicId
		data.TitleLower = data.Title and string.lower(data.Title) or nil
		data.ContentLower = data.Content and string.lower(data.Content) or nil
		if data.Url then
			data.Url = EssentialHousingHub.Defs.Urls[data.Url]
		end
	end
end