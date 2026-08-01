-- Create namespace
DsRGuildHall = {}
local DsRGuildHall = DsRGuildHall or {}

local DsRIcon = DsRglobals:HolidayIconLoad()

-- Name for registering events
DsRGuildHall.name        = "DsRGuildHall"
DsRGuildHall.version     = DsRVersion.version
DsRGuildHall.DisplayName = "DsR GuildRoster"
DsRGuildHall.Author      = "Hasenwarrior"

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
local function OnGroupScroll()
	if ZO_GuildRoster:IsHidden() == false then zo_callLater(DsRGuildRoster.UpdateGuildRosterList, 250) end
end

-- Initialization function
function DsRGuildHall:Initialize()

    DsRdefaults:Defaults()

    DsRGuildHall.scene_fragment        = ZO_SimpleSceneFragment:New(DsRGuildHallFrame)
    DsRGuildHall.scene_fragmentHoliday = ZO_SimpleSceneFragment:New(DsRGuildHolidayFrame)
    DsRGuildHall.scene_fragmentAdmin   = ZO_SimpleSceneFragment:New(DsRGuildAdminFrame)
    DsRGuildHall.scene_fragmentInfo    = ZO_SimpleSceneFragment:New(DsRGuildInfoFrame)
    DsRGuildHall.scene_fragmentRaid    = ZO_SimpleSceneFragment:New(DsRGuildRaidFrame)
    DsRGuildHall.scene_fragmentLead    = ZO_SimpleSceneFragment:New(DsRGuildLeaderFrame)
  
    GUILD_HOME_SCENE:AddFragment(DsRGuildHall.scene_fragment)
    GUILD_HOME_SCENE:AddFragment(DsRGuildHall.scene_fragmentHoliday)
    GUILD_HOME_SCENE:AddFragment(DsRGuildHall.scene_fragmentAdmin)
    GUILD_HOME_SCENE:AddFragment(DsRGuildHall.scene_fragmentInfo)
    GUILD_HOME_SCENE:AddFragment(DsRGuildHall.scene_fragmentRaid)
    GUILD_HOME_SCENE:AddFragment(DsRGuildHall.scene_fragmentLead)

    if DsRAutoINV.cfg.GuildInfRosterOnOff then
        GUILD_ROSTER_SCENE:AddFragment(DsRGuildHall.scene_fragmentHoliday)
        GUILD_ROSTER_SCENE:AddFragment(DsRGuildHall.scene_fragmentAdmin)
        GUILD_ROSTER_SCENE:AddFragment(DsRGuildHall.scene_fragmentInfo)
        GUILD_ROSTER_SCENE:AddFragment(DsRGuildHall.scene_fragmentRaid)
        GUILD_ROSTER_SCENE:AddFragment(DsRGuildHall.scene_fragmentLead)
    end

    if DsRAutoINV.cfg.GuildInfRankOnOff then
        GUILD_RANKS_SCENE:AddFragment(DsRGuildHall.scene_fragmentHoliday)
        GUILD_RANKS_SCENE:AddFragment(DsRGuildHall.scene_fragmentAdmin)
        GUILD_RANKS_SCENE:AddFragment(DsRGuildHall.scene_fragmentInfo)
        GUILD_RANKS_SCENE:AddFragment(DsRGuildHall.scene_fragmentRaid)
        GUILD_RANKS_SCENE:AddFragment(DsRGuildHall.scene_fragmentLead)
    end

    if DsRAutoINV.cfg.GuildInfRecrutOnOff then
        KEYBOARD_GUILD_RECRUITMENT_SCENE:AddFragment(DsRGuildHall.scene_fragmentHoliday)
        KEYBOARD_GUILD_RECRUITMENT_SCENE:AddFragment(DsRGuildHall.scene_fragmentAdmin)
        KEYBOARD_GUILD_RECRUITMENT_SCENE:AddFragment(DsRGuildHall.scene_fragmentInfo)
        KEYBOARD_GUILD_RECRUITMENT_SCENE:AddFragment(DsRGuildHall.scene_fragmentRaid)
        KEYBOARD_GUILD_RECRUITMENT_SCENE:AddFragment(DsRGuildHall.scene_fragmentLead)
    end

    EVENT_MANAGER:UnregisterForEvent(DsRGuildHall.name, EVENT_ADD_ON_LOADED)
    
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", DsRGuildHall.OnGuildIdChanged)
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", DsRGuildAdmin.OnGuildIdChanged)
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", DsRGuildHoliday.OnGuildIdChanged)
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", DsRGuildInfo.OnGuildIdChanged)
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", DsRGuildRoster.OnGuildIdChanged)
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", DsRGuildRaid.OnGuildIdChanged)
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", DsRGuildLeader.OnGuildIdChanged)

    ZO_PostHook(GUILD_ROSTER_MANAGER, "RefreshAll", DsRGuildRoster.UpdateGuildRosterList)
    GUILD_ROSTER_SCENE:RegisterCallback("StateChange", DsRGuildRoster.OnSceneChange)
    ZO_PreHook("ZO_ScrollList_UpdateScroll", OnGroupScroll)

    DsRGuildLoot.sV.characters = { }
    for charNum=1, GetNumCharacters ( ), 1 do
        local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo ( charNum )
        DsRGuildLoot.sV.characters [ charNum ] = zo_strformat(SI_UNIT_NAME, name)
    end

    local GuildCount                  = GetNumGuilds()
    local GuildNames                  = {}
    DsRAutoINV.cfg.GuildNames         = { }
    DsRAutoINV.cfg.GuildNumbers       = { }
    DsRAutoINV.cfg.GuildInfNoGuildMem = true

    for i = 1, GuildCount do
        local guildID  = GetGuildId(i)
        DsRAutoINV.cfg.GuildNames [ guildID ]   = GetGuildName(guildID)
        DsRAutoINV.cfg.GuildNumbers [ guildID ] = i

        if GetGuildName(guildID) == "Die sieben Raben" then
            DsRAutoINV.cfg.GuildInfNoGuildMem = false
        end
    end

    DsRVersionDefaults:Defaults()
    DsRGuildPriceDefaults:Defaults()
    DsRGuildPersonalDefaults:Defaults()
    DsRGuildBarDefaults:Defaults()

    DsRslashcmd.createSlashCommands()

    DsRGuildHall.InitKeybinds()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildHall.InitKeybinds()
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_BINDALL_UNKNOWN", GetString(DsRGuildBind_bindunknown))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_POSTALL_UNBOUNTED", GetString(DsRGuildBind_postunbounted))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_TOGGLE_INVENTORY_ASSISTANT", GetString(DsRGuildInventory_Open))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_TOGGLE_INVENTORY_ASSISTANT_NOFOCUS", GetString(DsRGuildInventory_OpenGrab))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_PORT_TO_CYRO", GetString(DsRGuildPvP_ap_telvarSaverKeybindmsg))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_CYROINVITE_CHAT", GetString(DsRGuildPvP_GroupInviteZonemsg))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_MAINBUTTON_WINDOW", GetString(DsRGuildcmd_MainButtonWindow))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_BUFF_MANAGEMENT", GetString(DsRGuildcmd_BuffSettingButtonWindow))
    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_GROUP_ATTACK", GetString(DsRGuildcmd_GroupAttack))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Startup function
function DsRGuildHall.OnGuildDataLoaded(event_code, guild_id)
    --Note: This event only fires on startup, not on /reloadui
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function UpdatePlatformStyles(styleTable)
    ApplyTemplateToControl(DsRVersion_Updated_Title, styleTable.titleTemplate)
    ApplyTemplateToControl(DsRVersion_Updated_Dismiss, styleTable.dismissTemplate)
end

local function LogoutOrQuit()
    local CharName   = GetUnitName("player")
    DsRGuildLoot.sV.charplayed[CharName] = GetSecondsPlayed()
end

local function DsR_ChatDefault()
    local ChatSV = DsRGuildLoot.sV.DefaultChat

    if ChatSV == 6 then
        CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_SAY)
    elseif ChatSV == 7 then
        CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_ZONE)
    elseif ChatSV == 8 then
        CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
    else
        CHAT_SYSTEM:SetChannel(_G["CHAT_CHANNEL_GUILD_" .. ChatSV])
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handlers
local function OnAddonLoaded(event, addonName)
    if (addonName ~= DsRGuildHall.name) then return end

    DsRGuildHall:Initialize()

    local ld = os.date("*t")
    local myGuildTextColor = "9fb6cd"
    local myEventTextColor = "ff4c4c"
    local myTextColor      = "FDFEFE"
  
    local myGuildText = "Die sieben Raben"

-- Valentine's Day
    if ld.month == 2 and ld.day == 14 then
        local myText      = GetString(DsR_valentinTXT)
        local myEventText = GetString(DsR_valentinEvent)
        local myPicture   = DsRIcon
        Guild   = string.format("|c%s%s|r", myGuildTextColor, myGuildText)
        Message = string.format("|c%s%s|r\n|c%s%s|r", myTextColor, myText, myEventTextColor, myEventText)
        Picture = string.format("%s", myPicture)
-- Ester
    elseif (ld.month == 3 and ld.day >= 25) and (ld.month == 3 and ld.day <= 29) then
        local myText      = GetString(DsR_esterTXT)
        local myEventText = GetString(DsR_esterEvent)
        local myPicture   = DsRIcon
        Guild   = string.format("|c%s%s|r", myGuildTextColor, myGuildText)
        Message = string.format("|c%s%s|r\n|c%s%s|r", myTextColor, myText, myEventTextColor, myEventText)
        Picture = string.format("%s", myPicture)
-- Halloween
    elseif ld.month == 10 and ld.day == 31 then
        local myText      = GetString(DsR_halloweenTXT)
        local myEventText = GetString(DsR_halloweenEvent)
        local myPicture   = DsRIcon
        Guild   = string.format("|c%s%s|r", myGuildTextColor, myGuildText)
        Message = string.format("|c%s%s|r\n|c%s%s|r", myTextColor, myText, myEventTextColor, myEventText)
        Picture = string.format("%s", myPicture)
-- Christmas
    elseif ld.month == 12 and ld.day >= 23 and ld.day <= 26 then
        local myText      = GetString(DsR_xmasTXT)
        local myEventText = GetString(DsR_xmasEvent)
        local myPicture   = DsRIcon
        Guild   = string.format("|c%s%s|r", myGuildTextColor, myGuildText)
        Message = string.format("|c%s%s|r\n|c%s%s|r", myTextColor, myText, myEventTextColor, myEventText)
        Picture = string.format("%s", myPicture)
-- New year
    elseif (ld.month == 1 and ld.day >= 0) and (ld.month == 1 and ld.day <= 3) then
        local myText      = GetString(DsR_newyearTXT)
        local myEventText = GetString(DsR_newyearEvent)
        local myPicture   = DsRIcon
        Guild   = string.format("|c%s%s|r", myGuildTextColor, myGuildText)
        Message = string.format("|c%s%s|r\n|c%s%s|r", myTextColor, myText, myEventTextColor, myEventText)
        Picture = string.format("%s", myPicture)
    else
        local myText      = ""
        local myEventText = ""
        local myPicture   = ""
    end
    if myEventText == "" then
    else
        CENTER_SCREEN_ANNOUNCE:AddMessage(1, CSA_CATEGORY_MAJOR_TEXT, SOUNDS.LEVEL_UP, Guild, nil, Picture, nil, nil, nil, 20000)
        CENTER_SCREEN_ANNOUNCE:AddMessage(2, CSA_CATEGORY_MAJOR_TEXT, nil, nil, Message, nil, nil, nil, nil, 20000)
    end 
    
    local player       = GetDisplayName()
    local texturePath, left, right, top, bottom = LibCustomIcons.GetStatic(player)
        
    if texturePath then
        DsRGuildHallHodorIcon:SetTexture(texturePath)
        DsRGuildHallHodorIcon:SetTextureCoords(left or 0, right or 1, top or 0, bottom or 1)
        DsRGuildHallHodorIcon:SetAnchor(TOP, DsRGuildHall.GoToDsRGuildHall, BOTTOM, 0, 10)
    else
        DsRGuildHallHodorIcon:SetTexture("/esoui/art/worldmap/map_indexicon_housing_up.dds")
        DsRGuildHallHodorIcon:SetAnchor(TOP, DsRGuildHall.GoToDsRGuildHall, BOTTOM, 0, 10)
    end

	-- Change the width of the RosterWindow
    ZO_KeyboardFriendsList:SetWidth(950)

    -- Change the width of the Tooltip
    ItemTooltip:SetDimensionConstraints(470, 0, 470, 1440)
    PopupTooltip:SetDimensionConstraints(470, 0, 470, 1440)
    
    DsRGuildRoster.ModifyGuildMemberMenuHeader()
    DsRGuildRoster.CustomIcons()
    DsRGuildRabenwacht.OnAddonLoaded()

    DsRGuildMail.OnAddonLoaded()
    DsRGuildFriends.OnAddonLoaded()
    DsRGuildGroup.OnAddonLoaded()
    DsRGuildLoot.OnAddonLoaded()
    DsRGuildLootHistory.OnAddonLoaded()
    DsRGuildBind.OnAddOnLoaded()
    DsRBeam.Handlers.OnAddOnLoaded()
    DsRGuildPvP.OnAddonLoaded()
    DsRGuildPvPstatus.Initialize()
    DsRGuildPvPdoor.OnAddonLoaded()
    DsRGuildPvPKeepInfo.OnAddonLoaded()
    DsRGuildPvPICdistrictName.OnAddonLoaded()
    DsRGuildPvPcountPlayer.OnAddonLoaded()
    DsRGuildPvPCrown.OnAddOnLoaded()
    IA_InventoryAssistant_OnInitialize()
    DsRGuildAchievTracker.OnAddonLoaded()
    DsRGuildPvPBossTimer.OnAddOnLoaded()
    DsRGuildPrecrafter.OnAddOnLoaded()
    DsRGuildAlchemy.OnAddOnLoaded()
    DsRGuildProvision.OnAddOnLoaded()
    DsRGuildDeathTable.OnAddOnLoaded()
    DsRGuildPrice.OnAddOnLoaded()
    DsRGuildAllies.OnAddOnLoaded()
    DsRGuildPersonal.OnAddOnLoaded()
    DsRInventoryButton.OnAddonLoaded()
    DsRGuildUnknown.OnAddonLoaded()
    DsRGuildWelcome.OnAddOnLoaded()
    DsRGuildNeedOne.OnAddonLoaded()
    DsRGuildBar.OnAddonLoaded()
    DsRGuildDeveloper.OnAddonLoaded()
    DsRGuildBuffs.OnAddOnLoaded()
    DsRGroupAttackProtocol:RegisterLGBProtocols()

    DsRGuildTEMPSaveChange.ChangeALL()

    zo_callLater(function() 
        if DsRVersion.UpdateVersion.UV == DsRGuildHall.version or DsRVersion.UpdateVersion.UV == "2000.01.01" then
            DsRVersion.UpdateVersion.UV = DsRGuildHall.version
            DsRVersion_Updated:SetHidden(true)
        elseif DsRVersion.UpdateVersion.UV ~= DsRGuildHall.version and DsRVersion.UpdateVersion.Show == true then
            DsRVersion.UpdateVersion.UV = DsRGuildHall.version
            DsRVersion_Updated:SetHidden(false)
            SetGameCameraUIMode ( true )
        end
    end, 1000)

    local CharName   = GetUnitName("player")
    if DsRGuildLoot.sV.charplayed[CharName] == nil then
        DsRGuildLoot.sV.charplayed[CharName] = GetSecondsPlayed()
    end

    local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo ( CharNum )
    local classIcon = zo_iconFormat(ZO_GetClassIcon(classId),24,24)

    DsRGuildLoot.sV.DsRBuff_CurrentChar = CharName

    DsR.Menu.Initialize()
    DsRBeam.Menu_Init()
    InventoryAssistantMenu.Menu_Init()
    DsRGuildPriceMenu:SetupMenueSettings()
    DsRGuildPersonalMenu:SetupMenueSettings()
    DsRGuildBarMenu:SetupMenueSettings()

    ZO_PreHook("Logout", function() LogoutOrQuit() end)
	ZO_PreHook("Quit", function() LogoutOrQuit() end)

    if DsRGuildLoot.sV.DefaultChatONOFF then
        if pChat or AccountSettings or rChat then
	        zo_callLater(function() DsR_ChatDefault() end, 10000)
        else
            DsR_ChatDefault()
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- change guild
function DsRGuildHall.OnGuildIdChanged(guild_roster_manager)
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    if not guild_roster_manager then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can't identify the guild hall yet")))
        return
    end
    if not guildId then
        return
    end

    local name          = DsRGuildHallName
    local HALLname      = DsRGuild
    local Icon          = DsRGuildHallIcon
    local GoToButton    = GoToDsRGuildHall
    local HodorIcon     = DsRGuildHallHodorIcon
    local GoToButtonMem = GoToDsRGuildHallMem
    local GuildMail     = DsRGuildHallPostButton
    
    if guildName ~= "Die sieben Raben" then
        name:SetHidden(true)
        HALLname:SetHidden(true)
        Icon:SetHidden(true)
        GoToButton:SetHidden(true)
        
        local player       = GetDisplayName()
        local texturePath, left, right, top, bottom = LibCustomIcons.GetStatic(player)
            
        if texturePath then
            HodorIcon:SetTexture(texturePath)
            HodorIcon:SetTextureCoords(left or 0, right or 1, top or 0, bottom or 1)
            HodorIcon:SetAnchor(TOP, HALLname, TOP, 0, 10)
            GoToButtonMem:SetAnchor(TOP, HodorIcon, BOTTOM, 0, 5)
        else
            HodorIcon:SetTexture("/esoui/art/worldmap/map_indexicon_housing_up.dds")
            HodorIcon:SetAnchor(TOP, HALLname, TOP, 0, 10)
            GoToButtonMem:SetAnchor(TOP, HodorIcon, BOTTOM, 0, 5)
        end
    else
        name:SetHidden(false)
        HALLname:SetHidden(false)
        Icon:SetHidden(false)
        GoToButton:SetHidden(false)

        local player       = GetDisplayName()
        local texturePath, left, right, top, bottom = LibCustomIcons.GetStatic(player)
            
        if texturePath then
            HodorIcon:SetTexture(texturePath)
            HodorIcon:SetTextureCoords(left or 0, right or 1, top or 0, bottom or 1)
            HodorIcon:SetAnchor(TOP, GoToButton, BOTTOM, 0, 10)
            GoToButtonMem:SetAnchor(TOP, HodorIcon, BOTTOM, 0, 5)
        else
            HodorIcon:SetTexture("/esoui/art/worldmap/map_indexicon_housing_up.dds")
            HodorIcon:SetAnchor(TOP, GoToButton, BOTTOM, 0, 10)
            GoToButtonMem:SetAnchor(TOP, HodorIcon, BOTTOM, 0, 5)
        end
 
        HALLname:SetText(GetString(DsR_Guild))
        GoToButton:SetText(GetString(DsR_Hall))
        GoToButtonMem:SetText(GetString(DsR_HallMem))
        GuildMail:SetText(GetString(DsR_Post))
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Special textures for event days
-- Logo
function DsRGuildHall.LoadIcon()
    local Icon    = DsRGuildHallIcon
    Icon:SetTexture(DsRIcon)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Check first guild
function DsRGuildHall.Check()
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    local name          = DsRGuildHallName
    local HALLname      = DsRGuild
    local Icon          = DsRGuildHallIcon
    local GoToButton    = GoToDsRGuildHall
    local GoToButtonMem = GoToDsRGuildHallMem
    local GuildMail     = DsRGuildHallPostButton
    
    GoToButtonMem:SetText(GetString(DsR_HallMem))
    GuildMail:SetText(GetString(DsR_Post))
    
    if guildName ~= "Die sieben Raben" then
        name:SetHidden(true)
        HALLname:SetHidden(true)
        Icon:SetHidden(true)
        GoToButton:SetHidden(true)

        local player       = GetDisplayName()
        local texturePath, left, right, top, bottom = LibCustomIcons.GetStatic(player)
            
        if texturePath then
            DsRGuildHallHodorIcon:SetTexture(texturePath)
            DsRGuildHallHodorIcon:SetTextureCoords(left or 0, right or 1, top or 0, bottom or 1)
            DsRGuildHallHodorIcon:SetAnchor(TOP, DsRGuildHallFrame, TOP, 0, 10)
            GoToButtonMem:SetAnchor(TOP, HodorIcon, BOTTOM, 0, 5)
        else
            DsRGuildHallHodorIcon:SetTexture("/esoui/art/worldmap/map_indexicon_housing_up.dds")
            DsRGuildHallHodorIcon:SetAnchor(TOP, DsRGuildHallFrame, TOP, 0, 10)
            GoToButtonMem:SetAnchor(TOP, HodorIcon, BOTTOM, 0, 5)
        end
    else
        name:SetHidden(false)
        HALLname:SetHidden(false)
        Icon:SetHidden(false)
        GoToButton:SetHidden(false)
        
        HALLname:SetText(GetString(DsR_Guild))
        GoToButton:SetText(GetString(DsR_Hall))
    
        DsRGuildHall.LoadIcon()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Register event handler
EVENT_MANAGER:RegisterForEvent(DsRGuildHall.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
