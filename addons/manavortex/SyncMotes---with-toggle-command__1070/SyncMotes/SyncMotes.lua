--.----------------.  .----------------.  .-----------------. .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
--| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
--| |    _______   | || |  ____  ____  | || | ____  _____  | || |     ______   | || | ____    ____ | || |     ____     | || |  _________   | || |  _________   | || |    _______   | |
--| |   /  ___  |  | || | |_  _||_  _| | || ||_   \|_   _| | || |   .' ___  |  | || ||_   \  /   _|| || |   .'    `.   | || | |  _   _  |  | || | |_   ___  |  | || |   /  ___  |  | |
--| |  |  (__ \_|  | || |   \ \  / /   | || |  |   \ | |   | || |  / .'   \_|  | || |  |   \/   |  | || |  /  .--.  \  | || | |_/ | | \_|  | || |   | |_  \_|  | || |  |  (__ \_|  | |
--| |   '.___`-.   | || |    \ \/ /    | || |  | |\ \| |   | || |  | |         | || |  | |\  /| |  | || |  | |    | |  | || |     | |      | || |   |  _|  _   | || |   '.___`-.   | |
--| |  |`\____) |  | || |    _|  |_    | || | _| |_\   |_  | || |  \ `.___.'\  | || | _| |_\/_| |_ | || |  \  `--'  /  | || |    _| |_     | || |  _| |___/ |  | || |  |`\____) |  | |
--| |  |_______.'  | || |   |______|   | || ||_____|\____| | || |   `._____.'  | || ||_____||_____|| || |   `.____.'   | || |   |_____|    | || | |_________|  | || |  |_______.'  | |
--| |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | |
--| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
--'----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 
--All Credit and Copyrights go to (ESO EU) Dero - @Deryl
--Thx to @Puse for some helpful thoughts
--Thx to the Guild (ESO EU) Blutlied for testing
--I did my best to comment the code for others to learn from it ;)

-- Add-on properties
ESO_SM                               = {}
local ESO_SM                         = ESO_SM
ESO_SM.name                          = "SyncMotes"
ESO_SM.description                   = "Synchronized Emotes"
ESO_SM.version                       = "1.1.3"
ESO_SM.savedVariablesName            = 'ESO_SM_SavedVariables'
ESO_SM.configVersion                 = 2
ESO_SM.configNamespace               = 'ESO_SM'
ESO_SM.watch = ""
ESO_SM.listening = false

ESO_SM.configDefaults = {
    ["configVersion"]               = ESO_SM.configVersion,
    ["debug"]                       = false,
    ["stack_on_insert"]             = false
}

local EVENT_MANAGER                 = EVENT_MANAGER

-- List of all Emotes
function ESO_SM.list()
	log("List of Emotes:")
	for i = 1 , GetNumEmotes(),1 do
		log(i .. " : " .. GetEmoteSlashNameByIndex(i))
	end
end

-- SyncMote command for chatmessage
function ESO_SM.NumericCall(argnumber)
	CHAT_SYSTEM:StartTextEntry('SyncMotes ' .. argnumber)
end

-- Numeric Call of ChatSyncMotes
function ESO_SM.NumericCallChat(argnumber)
	PlayEmoteByIndex(argnumber)
end

--Get Emote by name
function ESO_SM.getemotebyname(message)
	message = message:gsub("SyncMotes ", "")
	for i = 1 , GetNumEmotes(),1 do
		local lookforthisemote = GetEmoteSlashNameByIndex(i):gsub("/", "")
		if(ESO_SM_SavedData.CapsCheck == 0) then
			message = string.lower(message)
			lookforthisemote = string.lower(lookforthisemote)
		end
		if(message == lookforthisemote) then
			ESO_SM.NumericCall(i)		
			break
		end
	end
	--log("Sorry, Emote " .. message .. " doesn't exist.") --NEEDS TO BE DONE!
end

-- Checking Chat for SyncMotes
function ESO_SM.listen(eventCode, messageType, sender, message)
	for j = 1 , table.getn(chatstocheck) ,1 do
		if (messageType == chatstocheck[j][1] and ESO_SM_SavedData.ModeC[j] == 1) then		
			for i = 1 , GetNumEmotes(),1 do
				if message == (ESO_SM.watch .. i)and sender ~= nil and sender ~= "" then
					message = message:gsub("SyncMotes ", "")
					if (ESO_SM_SavedData.Mode[i] == 1) then
						log("SyncMotes playing Emote " .. GetEmoteSlashNameByIndex(message) .. " (ID: " .. message .. ")")
						PlayEmoteByIndex(179)
						zo_callLater(function() ESO_SM.NumericCallChat(message) end, 1500)
					else
						log("Emote " .. GetEmoteSlashNameByIndex(message) .. " is deactivated.")
					end
				end
			end
		end
	end
end

-- Checking Chat for SyncPhrases
function ESO_SM.listenRP(eventCode, messageType, sender, message)
	for j = 1 , table.getn(chatstocheckRP) ,1 do
		if (messageType == chatstocheckRP[j][1] and ESO_SM_SavedData.ModeCRP[j] == 1) then		
			for _,phrase in pairs(ESO_SM_SavedData.SynPhrase) do
				if(ESO_SM_SavedData.CapsCheck == 0) then
					phrasetocheck = string.lower(phrase[1])
					message = string.lower(message)
				else
					phrasetocheck = phrase[1]
				end
				if phrasetocheck == message then
					if(sender:gsub("%^.+", "") == GetUnitName("player")) then
						if(phrase[3] >= 1) then
							messagenum = phrase[3]
							delay = phrase[2]
							if (ESO_SM_SavedData.ModeRP[messagenum] == 1) then
								log("SyncPhrases playing emote: " .. GetEmoteSlashNameByIndex(messagenum) .. " in: " .. delay .. " ms.")
								zo_callLater(function() ESO_SM.NumericCallChat(messagenum) end, delay)
							else
								log("SyncPhrases Emote " .. GetEmoteSlashNameByIndex(messagenum) .. " is deactivated.")
							end
						end
					else
						if(phrase[5] >= 1) then
							messagenum = phrase[5]
							delay = phrase[4]
							if (ESO_SM_SavedData.ModeRP[messagenum] == 1) then
								log("SyncPhrases playing emote: " .. GetEmoteSlashNameByIndex(messagenum) .. " in: " .. delay .. " ms.")
								zo_callLater(function() ESO_SM.NumericCallChat(messagenum) end, delay)
							else
								log("SyncPhrases Emote " .. GetEmoteSlashNameByIndex(messagenum) .. " is deactivated.")
							end
						end
					end
				end
			end
		end
	end
end

-- Deactivate SyncMotes Emotes
function ESO_SM.deactivate()
	ESO_SM.watch = ""
	EVENT_MANAGER:UnregisterForEvent(ESO_SM.name, EVENT_CHAT_MESSAGE_CHANNEL)
	ESO_SM.listening = false
	ESO_SM_ON:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
	ESO_SM_OFF:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
	ESO_SM_SavedData.IsActivated = 0
		ESO_SM_HEADERSM:SetText("|c880000SM|r: |cff0000OFF|r")
	log("SyncMotes deactivated - Chat SyncMotes will be ignored.")
end

-- Deactivate SyncPhrases Emotes
function ESO_SM.deactivateRP()
	EVENT_MANAGER:UnregisterForEvent(ESO_SM.name .. "RP", EVENT_CHAT_MESSAGE_CHANNEL, ESO_SM.listenRP)
	ESO_SM.listeningRP = false
	ESO_SM_ONRP:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
	ESO_SM_OFFRP:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
	ESO_SM_SavedData.IsActivatedRP = 0
	ESO_SM_HEADERSP:SetText("|c5555ffSP|r: |cff0000OFF|r")
	log("SyncMotes RolePlayMode deactivated - Chat synphrases will be ignored.")
end

-- Activate SyncMotes Emotes
function ESO_SM.activate()
	ESO_SM.watch = "SyncMotes "
	if not ESO_SM.listening then		
		EVENT_MANAGER:RegisterForEvent(ESO_SM.name, EVENT_CHAT_MESSAGE_CHANNEL, ESO_SM.listen)
		ESO_SM.listening = true
		ESO_SM_ON:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
		ESO_SM_OFF:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
		ESO_SM_SavedData.IsActivated = 1
		ESO_SM_HEADERSM:SetText("|c880000SM|r: |c00ff00ON|r")
		log("SyncMotes activated - Chat will be checked for 'SyncMotes [1-" .. GetNumEmotes() .. "]'.")
	end
end

function ESO_SM.toggleRP()
	
	if ESO_SM.listeningRP then
		ESO_SM.deactivateRP()
	else
		ESO_SM.activateRP()
	end
end

-- Activate SyncPhrases Emotes
function ESO_SM.activateRP()
	if not ESO_SM.listeningRP then		
		EVENT_MANAGER:RegisterForEvent(ESO_SM.name .. "RP", EVENT_CHAT_MESSAGE_CHANNEL, ESO_SM.listenRP)
		ESO_SM.listeningRP = true
		ESO_SM_ONRP:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
		ESO_SM_OFFRP:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
		ESO_SM_SavedData.IsActivatedRP = 1
		ESO_SM_HEADERSP:SetText("|c5555ffSP|r: |c00ff00ON|r")
		log("SyncMotes RolePlayMode activated - Chat will be checked for Synphrases.")
	end
end

-- Activate Case-Sensitivity
function ESO_SM.activateCS()
	ESO_SM_ONCS:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
	ESO_SM_OFFCS:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
	ESO_SM_SavedData.CapsCheck = 1
	ESO_SM_HEADERCS:SetText("|c888800CS|r: |c00ff00ON|r")
	log("Case-Sensitivity activated.")
end

-- Deactivate Case-Sensitivity
function ESO_SM.deactivateCS()
	ESO_SM_ONCS:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
	ESO_SM_OFFCS:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
	ESO_SM_SavedData.CapsCheck = 0
	ESO_SM_HEADERCS:SetText("|c888800CS|r: |cff0000OFF|r")
	log("Case-Sensitivity deactivated.")
end

--Add a new SyncPhrase to the SavedVariabled
function ESO_SM.AddPhrase(arg,editnumber)
	if(editnumber == nil) then
		editnumber = 0
	end
	if(table.getn(arg) >= 6) then
		if(editnumber >= 1 and editnumber <= table.getn(ESO_SM_SavedData.SynPhrase)) then
			nextphrase = editnumber
			editnumber = 0
		else
			nextphrase = table.getn(ESO_SM_SavedData.SynPhrase) + 1
		end
		
		SyncPhrase = ""
		for i = 2 , table.getn(arg)-4 , 1 do
			if(i == 2) then
				SyncPhrase = SyncPhrase .. "" .. arg[i]
			else
				SyncPhrase = SyncPhrase .. " " .. arg[i]
			end
		end
		
		OtherEmote = tonumber(arg[table.getn(arg)])
		
		--Check if OtherEmote is an Emotename
		OtherEmotePhrase = arg[table.getn(arg)]:gsub("/", "")
		for i = 1 , GetNumEmotes(),1 do
			CheckForEmote = GetEmoteSlashNameByIndex(i):gsub("/", "")
			if(string.lower(CheckForEmote) == string.lower(OtherEmotePhrase))then
				OtherEmote = i
				break
			end
		end
		if(string.lower(OtherEmotePhrase) == "none") then
			OtherEmote = 0
		end
		
		OtherDelay = tonumber(arg[table.getn(arg) - 1])
		YourEmote = tonumber(arg[table.getn(arg) - 2])
		
		--Check if Your Emote is an Emotename
		YourEmotePhrase = arg[table.getn(arg) -2]:gsub("/", "")
		for i = 1 , GetNumEmotes(),1 do
			CheckForEmote = GetEmoteSlashNameByIndex(i):gsub("/", "")
			if(string.lower(CheckForEmote) == string.lower(YourEmotePhrase))then
				YourEmote = i
				break
			end
		end
		if(string.lower(YourEmotePhrase) == "none") then
			YourEmote = 0
		end
		
		YourDelay = tonumber(arg[table.getn(arg) - 3])
		
		--Check if Every argument is given
		if(tonumber(OtherEmote) == nil) then
			ESO_SM_PL_SCROLLBOXTEXT:SetText("Sorry, Other Emote:'" .. ESO_SM_PL_BOXOE:GetText() .. "' is not a valid Emote-ID or Emote-Name!")
			log("last argument [" .. arg[table.getn(arg)] .."] (Other Emote) is not a valid Emote-ID or Emote-Name!")
			return
		elseif(tonumber(OtherDelay) == nil) then
			ESO_SM_PL_SCROLLBOXTEXT:SetText("Sorry, Others Delay:'" .. ESO_SM_PL_BOXOD:GetText() .. "' is not a valid Delay")
			log("2nd last argument [" .. arg[table.getn(arg) - 1] .."] (Other Delay) is not a Number!")
			return
		elseif(tonumber(YourEmote) == nil) then
			ESO_SM_PL_SCROLLBOXTEXT:SetText("Sorry, Your Emote:'" .. ESO_SM_PL_BOXYE:GetText() .. "' is not a valid Emote-ID or Emote-Name!")
			log("3rd last argument [" .. arg[table.getn(arg) - 2] .."] (Your Emote) is not a valid Emote-ID or Emote-Name!")
			return
		elseif(tonumber(YourDelay) == nil) then
			ESO_SM_PL_SCROLLBOXTEXT:SetText("Sorry, Your Delay:'" .. ESO_SM_PL_BOXYD:GetText() .. "' is not a valid Delay")
			log("4th last argument [" .. arg[table.getn(arg) - 3] .."] (Your Delay) is not a Number!")
			return
		elseif(tonumber(OtherEmote) < 0 or tonumber(OtherEmote) > GetNumEmotes() ) then
			ESO_SM_PL_SCROLLBOXTEXT:SetText("Sorry, Others Emote:'" .. ESO_SM_PL_BOXOE:GetText() .. "' is not a valid Emote-ID or Emote-Name!")
			log("Other Emote [" .. arg[table.getn(arg)] .."] is not a valid Emote-ID!")
			return
		elseif(tonumber(YourEmote) < 0 or tonumber(YourEmote) > GetNumEmotes() ) then
			ESO_SM_PL_SCROLLBOXTEXT:SetText("Sorry, Your Emote:'" .. ESO_SM_PL_BOXYE:GetText() .. "' is not a valid Emote-ID or Emote-Name!")
			log("Your Emote [" .. arg[table.getn(arg) - 2] .."] is not a valid Emote-ID!")
			return
		else
			--Only if its a new phrase check for already existing entry
			if(nextphrase > table.getn(ESO_SM_SavedData.SynPhrase))then
				for _,phrase in pairs(ESO_SM_SavedData.SynPhrase) do
					if(string.lower(phrase[1]) == string.lower(SyncPhrase)) then
						PhraseMatch = 1
						break
					else
						PhraseMatch = 0
					end
				end
			else
				PhraseMatch = 0
			end
			if(PhraseMatch == 1) then
				ESO_SM_PL_SCROLLBOXTEXT:SetText("Sorry, the SyncPhrase '" .. SyncPhrase .. "' already exists.")
				log("Sorry, the SyncPhrase '" .. SyncPhrase .. "' already exists.")
			else
				NewPhrase = {SyncPhrase,YourDelay,YourEmote,OtherDelay,OtherEmote}
				ESO_SM_SavedData.SynPhrase[nextphrase] = NewPhrase
				ESO_SM.UpdatePhraseListText(CurrPhrase)
				log("SyncPhrase: '" .. SyncPhrase .. "' With options: Your Delay: '" .. YourDelay .. " ms' Your Emote: '" .. YourEmote .. " (" .. GetEmoteSlashNameByIndex(YourEmote) .. ")' Other Delay: '" .. OtherDelay .. " ms' OtherEmote: '" .. OtherEmote .. " (" .. GetEmoteSlashNameByIndex(OtherEmote) .. ")' has been saved with ID: " .. nextphrase)
			end
		end
	else
		ESO_SM_PL_SCROLLBOXTEXT:SetText("Please fill out every Inputbox.")
		log("Not enough arguments. Please Check your Command.")
	end
end

--Shows a List of SyncPhrases and their ID in a new Frame
function ESO_SM.PhraseList()
	ESO_SM.openphrasemenu()
end

-- Open Menu for SyncMotes settings contained in SyncMotesMenu.lua
function ESO_SM.openmenu()
	SetGameCameraUIMode(true)
	SyncMotesMenu:SetHidden(not SyncMotesMenu:IsHidden())
end

--Shows a List of SyncPhrases and their ID in a new Frame
function ESO_SM.openphrasemenu()
	ESO_SM.UpdatePhraseListText(1)
	SetGameCameraUIMode(true)
	PhraseList:SetHidden(not PhraseList:IsHidden())
	if(PhraseList:IsHidden() == true and EmoteListEdited == 1) then
		EmoteListEdited = 0
		EmoteList:SetHidden(true)
	end
end

--Shows a List of Emotes and their ID in a new Frame
function ESO_SM.openemotemenu()
	ESO_SM_SPBCONT:SetHidden(true)
	ESO_SM_EL:SetMovable(true)
	ESO_SM_EL:SetDimensions(EmoteListWidth, EmoteListHeight)
	SetGameCameraUIMode(true)
	EmoteList:SetHidden(not EmoteList:IsHidden())
end

--Shows the Edited Emotelist on SyncPhrases to take Emotes from it
function ESO_SM.ShowEmotesEdited()
	EmoteListEdited = 1
	EmoteList:SetHidden(false)
	ESO_SM_SPBCONT:SetHidden(false)
	ESO_SM_EL:SetMovable(false)
	ESO_SM_EL:ClearAnchors()
	ESO_SM_EL:SetAnchor(TOPLEFT,ESO_SM_PL,TOPRIGHT,12,0)
	ESO_SM_EL:SetDimensions(EmoteListWidth,EmoteListHeight+100)
end



-- Main function called by the /sm command
function ESO_SM.Main(arg)
	ArgArray = {} --Defining an Array for the Argument
	ArgArrayNum = 1 --Count to fill the Array
	for i in string.gmatch(arg, "%S+") do
		ArgArray[ArgArrayNum] = i
		ArgArrayNum = ArgArrayNum + 1
	end
    if arg == "" or arg == "help" or arg == "info" or arg == "hilfe" then
        log("- Help -")
		log("/sm menu - Open the SyncMotes Menu")
		log("/sm list - Shows the SyncMotes EmoteList")		
		log("/sm on - Start listening to selected Chats")
		log("/sm off - Stop listening to selected Chats")
		log("/sm [EMOTE-ID] - Enters the SyncMotes command line into Chat !!(you need to hit Enter afterwards)!!")
		log("/sm [EMOTENAME] - Enters the SyncMotes command line into Chat !!(you need to hit Enter afterwards)!!")
		log("/sm add [Phrase] [YourDelay(ms)] [YourEmote] [OthersDelay(ms)] [OthersEmote] - Adds a SyncPhrase")
		log("/sm phrase - Shows the SyncPhrase config to add/edit/remove SyncPhrases")
	elseif ArgArray[1] == "list" then
		--ESO_SM.list() OLD! NEED TO DELTE THIS AND ALL ITS COMPONENTS
		ESO_SM.openemotemenu()
	elseif ArgArray[1] == "menu" then	
		ESO_SM.openmenu()
	elseif ArgArray[1] == "off" then
		ESO_SM.deactivate()
	elseif ArgArray[1] == "on" then
		ESO_SM.activate()
	elseif ArgArray[1] == "add" then
		ESO_SM.AddPhrase(ArgArray)
	elseif ArgArray[1] == "phrase" then
		ESO_SM.openphrasemenu()
	elseif ArgArray[1] == "toggle" then
		ESO_SM.toggleRP()
	elseif ArgArray[1] == "annoy" then -- IF YOU SEE THIS - DO NOT USE THIS - IT DOESNT WORK! ^^
		ESO_SM.annoy()
	elseif ArgArray[1] == "stopit" then -- IF YOU MADE IT WORK - USE THIS TO STOP IT! 
		ESO_SM.annoystp()
	elseif tonumber(ArgArray[1]) ~= nil then
	local argnumber = tonumber(ArgArray[1])
		if argnumber <= GetNumEmotes() and argnumber >= 1 then
			ESO_SM.NumericCall(argnumber)
		else
			log("There is no such Emote. Please try Numbers from 1 to " .. GetNumEmotes())
		end
	else
		ESO_SM.getemotebyname(arg)
    end
end

--================================================================
-- Dero's Annoying Annoy section! ;) 
--================================================================
function ESO_SM.annoy()	if(stopit == 0 and CountUp <= 30) then zo_callLater(function() PlayEmoteByIndex(4) end, 100)	zo_callLater(function() PlayEmoteByIndex(22) end, 600)	zo_callLater(function() ESO_SM.annoy() end, 1200) CountUp = CountUp + 1 end end
function ESO_SM.annoystp() if(stopit == 0) then stopit = 1	else stopit = 0	CountUp = 1 end end
--================================================================
-- /Dero's Annoying Annoy section! ;)
--================================================================

-- Log a message to Chat
function ESO_SM.Log(msg)
    d(msg)
end

-- Initialise the add-on
function ESO_SM.OnAddOnLoaded(eventCode, addOnName)
    if (addOnName ~= ESO_SM.name) then return end
    -- Unregister for loaded event
    EVENT_MANAGER:UnregisterForEvent(ESO_SM.name, EVENT_ADD_ON_LOADED)

	-- Logging for Debugging
    log = ESO_SM.Log
    dbg = ESO_SM.Debug

    -- Slash command
    SLASH_COMMANDS["/sm"] = ESO_SM.Main
	
	--Initializing of Default Data
	ESO_SM.Initdata()
	
	--Loading saved Variables and setting item to save them
	ESO_SM_SavedData = ZO_SavedVars:NewAccountWide("ESO_SM_EmoteCheckData", 1, nil, ESO_SM_DATA)
	
	--Build up the Menu
	ESO_SM.buildmenu()
	
	--Build up the PhraseList
	ESO_SM.buildPhraseList()
	
	--Build up the EmoteMenu
	ESO_SM.buildEmoteMenu()

	--Automatically activate/deactivate SyncMotes
	if ESO_SM_SavedData.IsActivated == 1 then
		ESO_SM.activate()
	else
		ESO_SM.deactivate()
	end
	
	--Automatically activate/deactivate SyncPhrases
	if ESO_SM_SavedData.IsActivatedRP == 1 then
		ESO_SM.activateRP()
	else
		ESO_SM.deactivateRP()
	end

	--Automatically activate/deactivate CaseSensitivity
	if ESO_SM_SavedData.CapsCheck == 1 then
		ESO_SM.activateCS()
	else
		ESO_SM.deactivateCS()
	end
	
	--Initiate KeyBinding
	ZO_CreateStringId("SI_BINDING_NAME_OPEN_SYNCMOTES_MENU", "Open SyncMotes Menu")
	ZO_CreateStringId("SI_BINDING_NAME_OPEN_PHRASELIST_MENU", "Open PhraseList Menu")
	ZO_CreateStringId("SI_BINDING_NAME_OPEN_EMOTELIST_MENU", "Open EmoteList")
	
	--Event to Hide the UI when Moving to Unbug bugged skills
	--EVENT_MANAGER:RegisterForEvent("SyncMotesHideWhenMoving",EVENT_GAME_CAMERA_UI_MODE_CHANGED,function()
	--	if(not IsGameCameraUIModeActive()) then
	--		SyncMotesMenu:SetHidden(true)
	--	end
	--end)
end

-- Register for the initialisation event
EVENT_MANAGER:RegisterForEvent(ESO_SM.name, EVENT_ADD_ON_LOADED, ESO_SM.OnAddOnLoaded)