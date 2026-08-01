---------------------------------------------------------
--	ARKadium's Extended Guild Notes Chat file  		    -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 


local LC = LibStub("libChat-1.0")

ARK_EGN              	= ARK_EGN or {}
local EGN 			 	= ARK_EGN
EGN.Chat		 		= ARK_EGN.Chat or{}
local Chat				= ARK_EGN.Chat
Chat.sVars			= {}
Chat.savedVarsVersion= 1

Chat.default		= {
	imageHeight			=	18,
}

Chat.starsList = {}



do

	function Chat.Initialize()
		--loads saved variables from file or default
		Chat.sVars = ZO_SavedVars:NewAccountWide( "ARK_EGN_SavedVariables", Chat.savedVarsVersion, "Chat", Chat.default )
		

		--initialize settings
		
		--intialize ui
		
		--populates list
		local height = Chat.sVars.imageHeight
		local width = height*4
		--:x: :xx: :xxx: :xxxx: :xxxxx: 
		--:xoooo: :xxooo: :xxxoo: :*xxxxo: :ooooo:
		Chat.starsList 	= {
			[":o:"]			= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_o.dds|t",
			[":x:"]			= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_x.dds|t",
			[":xoooo:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xoooo.dds|t",
			[":xx:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xx.dds|t",
			[":xxooo:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xxooo.dds|t",
			[":xxx:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xxx.dds|t",
			[":xxxoo:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xxxoo.dds|t",
			[":xxxx:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xxxx.dds|t",
			[":xxxxo:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xxxxo.dds|t",
			[":xxxxx:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_xxxxx.dds|t",
			[":ooooo:"]		= "|t"..width..":"..height..":ARK_EGN/textures/Stars/ark_stars_ooooo.dds|t",--not used
		}
		
		--initialize listener
		LC:registerText(Chat.ReplaceStars,EGN.addonName)
		
		
		zo_callLater(function() EGN.Debug( "Chat","Module Loaded" ) end, 2600)
	end

	function Chat.ReplaceStars(channelID, from, text, isCustomerService)
		--todo :  add channel management for quick exit
		
			for key, value in pairs(Chat.starsList) do
				text = text:gsub( key, value) 
			end			 

		return text
	end
	
	function Chat_Slash(emote)
		CHAT_SYSTEM.textEntry:SetText(emote)
		CHAT_SYSTEM:Maximize()
		CHAT_SYSTEM.textEntry:Open()
	end
	
	function Chat.Slash_x()
		Chat_Slash(":x:")
	end
	function Chat.Slash_xx()
		Chat_Slash(":xx:")
	end
	function Chat.Slash_xxx()
		Chat_Slash(":xxx:")
	end
	function Chat.Slash_xxxx()
		Chat_Slash(":xxxx:")
	end
	function Chat.Slash_xxxxx()
		Chat_Slash(":xxxxx:")
	end
	function Chat.Slash_xoooo()
		Chat_Slash(":xoooo:")
	end
	function Chat.Slash_xxooo()
		Chat_Slash(":xxooo:")
	end
	function Chat.Slash_xxxoo()
		Chat_Slash(":xxxoo:")
	end
	function Chat.Slash_xxxxo()
		Chat_Slash(":xxxxo:")
	end
	
end

SLASH_COMMANDS["/ark_stars_1*"] = Chat.Slash_x
SLASH_COMMANDS["/ark_stars_2*"] = Chat.Slash_xx
SLASH_COMMANDS["/ark_stars_3*"] = Chat.Slash_xxx
SLASH_COMMANDS["/ark_stars_4*"] = Chat.Slash_xxxx
SLASH_COMMANDS["/ark_stars_5*"] = Chat.Slash_xxxxx
SLASH_COMMANDS["/ark_stars_roster_1*"] = Chat.Slash_xoooo
SLASH_COMMANDS["/ark_stars_roster_2*"] = Chat.Slash_xxooo
SLASH_COMMANDS["/ark_stars_roster_3*"] = Chat.Slash_xxxoo
SLASH_COMMANDS["/ark_stars_roster_4*"] = Chat.Slash_xxxxo
SLASH_COMMANDS["/ark_stars_roster_5*"] = Chat.Slash_xxxxx
