ESOTheater = {
	Name = "ESOTheater",
	Title = "ESO Theater Addon",
	Author = "Halja",
	Version = "0.4.8",
	SV = "ESOTheaterSavedVariables",
	SVersion = "0.3.4",
	CurrentSVars = {},
}
local TransparentFlag = false
local LastKnownTarget = nil
local ET = ESOTheater

local verboseFlag = false
local lastEmote = {
	Name = "",
	ID = 0,
}
local TransparentFlag = false
local LastKnownTarget = nil

function ET.GetLastEmote()
	return lastEmote
end

function ET.SetLastEmote(name,id)
	lastEmote.Name = name
	lastEmote.ID = id
end

function ET.GetLastKnownTarget()
	return LasstKnownTarget
end

function ET.IsVerbose()
	if (verboseFlag  ~= nil) then
		return verboseFlag
	else
		return false
	end
end

local function PlayerTargetOnChange()
    local name = GetUnitName("reticleover") 
    local caption = GetUnitCaption("reticleover")
    if DoesUnitExist('reticleover') then
            --if IsUnitPlayer('reticleover') then
				if (name ~= LastKnownTarget) then
					LastKnownTarget = name
					if ET.IsVerbose() then
						ET.PrintSystemChat( "New Target: "..name )
					end
				end
			--end
	end
end

function ET.PrintSystemChat( text )
	if (type(text) ~= string) then
		text = tostring(text)
	end
	--d( text )
	CHAT_SYSTEM:AddMessage(text)
end

function ET.EmptyTable( aTable )
	for k,v  in pairs (aTable) do
		aTable[k] = nil
	end
end

function ET.TableSize( aTable )
	-- # shortcut for lua table count is not always working?
	local count = 0
	for k,v  in pairs (aTable) do
		count = count +1
	end
	return count
end

function ET.IsString(obj)
    return type(obj) == 'string'
end

function ET.IsNumber(obj)
    return type(obj) == 'number'
end

function ET.GetActiveLanguage() 
	--Not directly document but the UserSettings.txt are loaded to game as CVars
	return string.upper(GetCVar("Language.2"))
end

function ET.GetTransparentFlag()
	return TransparentFlag
end
					
function ET.SetTransparentFlag()
	TransparentFlag = not TransparentFlag
	if ET.IsVerbose()then
		ET.PrintSystemChat(TransparentFlag)
	end
	local TransparencyLevel = tonumber(ET.CurrentSVars.UserSettings.TransparencyLevel)
	
	if (TransparencyLevel < 1) then TransparencyLevel = 1 end
	if (TransparencyLevel > 100) then TransparencyLevel = 100 end
	TransparencyLevel = (TransparencyLevel / 100)
	
	local mainFrame = GetControl("TheaterFrame")
	local configFrame = GetControl("PlaybillFrame")
	if TransparentFlag then
		mainFrame:SetAlpha(1)
		configFrame:SetAlpha(1)
	else
		mainFrame:SetAlpha(TransparencyLevel)
		configFrame:SetAlpha(TransparencyLevel)
	end
end

function ET.CategoryIdByName(aname)
	local id = 0
	local tblCategory = ET.EmoteData.CategoryTable
	
	for k  in pairs (tblCategory) do
		if (aname == tblCategory[k]) then
			id = k
		end
	end
	return id
end

function ET.EmoteIdByName(aname)
	local id = 0
	local tblemote = ET.EmoteData.EmoteTable
	
	for k,v  in pairs (tblemote) do
		if (aname == v["EmoteName"]) then
			id = v["ID"]
		end
	end
	return id
end

function ET.EmoteNameByID(id)
	local name = ""
	local tblemote = ET.EmoteData.EmoteTable

	for k,v  in pairs (tblemote) do
		if (id == v["ID"]) then
			name = v["EmoteName"]
		end
	end
	return name
end

function ET.PlayEmoteByName(name)
	local emoteid= ET.EmoteIdByName(name)
	emoteid = emoteid
	if (emoteid >= 1) then
		PlayEmoteByIndex(emoteid)
		if ET.IsVerbose() then
			ET.PrintSystemChat( "Playing /"..name)
		end
		ET.SetLastEmote(name,emoteid)
	end
end

function ET.PlayEmoteByID( ID )
	local eName = ET.EmoteNameByID( ID )
	if (eName ~= "") then
		PlayEmoteByIndex( ID )
		if ET.IsVerbose() then
			ET.PrintSystemChat( "Playing /"..eName)
		end
		ET.SetLastEmote(eName,ID)
	end
end

function ET.TestFoo()
	---A Placeholder for trying stuff

	--ET.ESOPlaybill:FillScrollList(3)
	ET.PrintSystemChat( string.format("%s", ET.CategoryIdByName("FRIENDLY")))
	--local control = GetControl("PlaybillFrameList")
	--ZO_ScrollList_HideAllCategories(control)
	--ZO_ScrollList_ShowCategory(control, "FRIENDLY")
	--ZO_ScrollList_ShowCategory(control, "OFFENSIVE")
	--ET.PrintSystemChat( string.format("%s",GetActiveLanguage() ))
	--ET.PrintSystemChat( string.format("%d", GetNumEmotes() ) )
	--ET.PrintSystemChat( zo_strformat( '<<1>> eats <<2>>',  'Cat', 'Bird' ) )
	--ET.PrintSystemChat( LocalizeString('Steinfälle^F') )
	
	if ET.IsVerbose() then
		ET.PrintSystemChat( "Done :D" )
	end
end

local function ShouldHideAddon()
	local CompassIsHidden = ZO_CompassFrame:IsHidden()
	if (CompassIsHidden and IsReticleHidden() ) then
		ESOTheater:Hide()
		ESOPlaybill:Hide()
	else
		--There is a variable in the class to check that it should really become visible.
		ESOTheater:Show()
	end
end

function ET.ToggleAddon()
	ET.ESOStage:ToggleWindow()
end

function ET.ToggleEmotesWindow()
	ET.ESOPlaybill:ToggleWindow()
end

function ET.QuickEmotes( btnNumber )
	local emotename = ET.ESOStage:GetFavoriteButtonEmote( btnNumber )
	if (emotename ~= nul) then
		ET.PlayEmoteByName(emotename)
	end
end

function ET.RandomEmote()
	local tblemote = ET.EmoteData.EmoteTable
	local size = ET.TableSize( tblemote )
	local remoteid = math.random(1, size)
	local ZOSemotename = tblemote[remoteid].EmoteName
	ET.PrintSystemChat( "Playing /"..ZOSemotename)
	ET.PlayEmoteByID(tblemote[remoteid].ID)
end

local function ReloadRawTable()
	ET.EmptyTable( ET.CurrentSVars.RawTable )
	ET.PrintSystemChat( string.format("%d", GetNumEmotes() ) )
	
	for i=1, GetNumEmotes() do
			local eName = GetEmoteSlashNameByIndex( i )
			if (string.len(eName) == 0) then
				eName = "Unknown"
			else
				eName = string.sub(eName,2,string.len(eName))
			end
			
			if ET.IsVerbose() then
				ET.PrintSystemChat( string.format("%d\t%s", i, eName) )
			end
			table.insert (ET.CurrentSVars.RawTable, i, {EmoteName = eName})
	end
end

local function ReloadAddOnDefaults()
	
	local size = ET.TableSize(ET.EmoteData.FavoriteTable)

	if ( size > 0) then
		if ET.IsVerbose() then
			ET.PrintSystemChat("Starting reset...")
		end

		ET.EmptyTable( ET.CurrentSVars.FavoriteTable )
		ET.EmptyTable( ET.CurrentSVars.RawTable )
		ET.EmptyTable( ET.CurrentSVars.UserSettings )
		
		ET.CurrentSVars.UserSettings = ET.UserSettings
		ET.CurrentSVars.FavoriteTable = ET.EmoteData.FavoriteTable
		ET.CurrentSVars.RawTable= ET.EmoteData.RawTable
		
		ET.ESOStage.ReLoadFavoriteButtons()
		local x =  ET.CurrentSVars.UserSettings.StageLocation.Xoffset
		local y = ET.CurrentSVars.UserSettings.StageLocation.Yoffset
		ET.ESOStage:MoveWindow( x, y )
		
		x =  ET.CurrentSVars.UserSettings.PlaybillLocation.Xoffset
		y = ET.CurrentSVars.UserSettings.PlaybillLocation.Yoffset
		ET.ESOPlaybill:MoveWindow( x, y )

		if ET.IsVerbose() then
			ET.PrintSystemChat("Reset Done")
		end
	end
end

local function OnAddSlashCommand( ... )
	
	--only parsing the first argument 
	local arg1 = select(1,...)
	if ( arg1 ~= nil and arg1 ~= "") then
		if ET.IsVerbose()  then
			ET.PrintSystemChat( arg1 )
		end
		
		if (arg1 == "-help" or arg1 == "-h"or arg1 == "-?") then
			ET.PrintSystemChat(ET.Name.." Slash Commands")
			ET.PrintSystemChat("******************************************")
			ET.PrintSystemChat("/esotheater : Display emote window")
			ET.PrintSystemChat("/et : Alias to display emote window")
			ET.PrintSystemChat("/et -< Options >")
			ET.PrintSystemChat("/et -help : This message")
			ET.PrintSystemChat("/et -enumsys : Pulls system emotes and copies to SavedVariables file")
			ET.PrintSystemChat("/et -reload : Reloads Add-on default to SavedVariables file")
			ET.PrintSystemChat("/et -repin : Reset main window position to top left corner")
			ET.PrintSystemChat("/et ####	Plays the games emote id **** ID can be different while playing in French and/or German ****")
			ET.PrintSystemChat("/et <emote name>	Plays the emote based on the name. i.e. /et cœur brisé and /et Hände reiben")
			ET.PrintSystemChat("/et -f##	Plays the emote based on the favorite's button number i.e. /et -f9 plays the emote you assigned to button 9.")
			ET.PrintSystemChat("******************************************")
		end

		if arg1 == "-enumsys" then
			ReloadRawTable()
		end

		if arg1 == "-reload" then
			ReloadAddOnDefaults()
		end

		if arg1 == "-repin" then
			ET.ESOStage:MoveWindow( 30, 20 )
			ET.ESOPlaybill:MoveWindow( 360, 20 )
		end
		
		if (string.sub(string.upper(arg1),1,2) == "-F") then
			local btnNumber = string.sub(arg1,3)
			local emotename = ET.ESOStage:GetFavoriteButtonEmote( btnNumber )
			if (emotename ~= nul) then
				--No error checking just tossing over the fence :P
				ET.PlayEmoteByName(emotename)
			end
		end
				
		if arg1 == "-v" then
			if ET.IsVerbose()  then
				verboseFlag = false
			else
				verboseFlag = true
			end
		end
		
		
		local emoteid = tonumber(arg1)
		if (emoteid ~= nul and ET.IsNumber(emoteid) == true) then
			ET.PlayEmoteByID(emoteid)
		else
			--No error checking just tossing over the fence :P
			ET.PlayEmoteByName(arg1)
		end

	else
		 ET.ESOStage:OnSlashCommand()
	end
	
end

function ET.AddonInitialized( self )
	
	ET.ESOStage:Initialize()
	ET.ESOStage:Hide()
		
	ET.ESOPlaybill:Initialize()
	local control = GetControl("PlaybillFrame")
	control:SetHidden( true )
	 
	--great tip from @Errc & SinusPi of Zgoo
	SetGameCameraUIMode(true) --Release the mouse focus
end

local function OnAddOnLoaded(eventCode, addOnName)
    if (addOnName == ET.Name) then
				
		local defaultSV = {
			["FavoriteTable"] = 
			{
			},
			["RawTable"] = 
			{
			},
			["UserSettings"] = 
			{
			},
		}
		
		defaultSV.UserSettings = ET.UserSettings
		defaultSV.FavoriteTable = ET.EmoteData.FavoriteTable
		
		--initialize saved variables
		if ( EmotesAccountWide == 1 ) then
			ET.CurrentSVars = ZO_SavedVars:NewAccountWide(ET.SV, ET.SVersion, "Session", defaultSV)
		else
			ET.CurrentSVars = ZO_SavedVars:New(ET.SV, ET.SVersion, "Session", defaultSV)
		end
	
	--Initialize Slash commands
		SLASH_COMMANDS["/esotheater"]  = function( ... ) OnAddSlashCommand( ... ) end
		SLASH_COMMANDS["/et"] = function( ... ) OnAddSlashCommand( ... ) end
		
		ET.ESOStage:LoadFavoriteButtons()
		local x =  ET.CurrentSVars.UserSettings.StageLocation.Xoffset
		local y = ET.CurrentSVars.UserSettings.StageLocation.Yoffset
		ET.ESOStage:MoveWindow( x, y )

		x =  ET.CurrentSVars.UserSettings.PlaybillLocation.Xoffset
		y = ET.CurrentSVars.UserSettings.PlaybillLocation.Yoffset
		ET.ESOPlaybill:MoveWindow( x, y )
		ET.ESOPlaybill:LoadCategoryFilters()

    end
end

EVENT_MANAGER:RegisterForEvent(ET.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
--EVENT_MANAGER:RegisterForEvent(ET.Name, EVENT_RETICLE_HIDDEN_UPDATE, ShouldHideAddon)  --also fires when main game main menu is triggered
EVENT_MANAGER:RegisterForEvent(ET.Name, EVENT_RETICLE_TARGET_CHANGED, PlayerTargetOnChange)
ZO_CreateStringId("SI_BINDING_NAME_DISPLAY_ESOTHEATER", "Display ESOTheater")
ZO_CreateStringId("SI_BINDING_NAME_DISPLAY_EMOTES", "Display Emotes |c888855( All )|r")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_01", "Emote Favorite 01")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_02", "Emote Favorite 02")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_03", "Emote Favorite 03")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_04", "Emote Favorite 04")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_05", "Emote Favorite 05")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_06", "Emote Favorite 06")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_07", "Emote Favorite 07")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_08", "Emote Favorite 08")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_09", "Emote Favorite 09")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_10", "Emote Favorite 10")
ZO_CreateStringId("SI_BINDING_NAME_RANDOM_EMOTE", "Play Random Emote")
