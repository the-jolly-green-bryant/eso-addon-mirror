AITUF = {}
local AITUF = AITUF

AITUF.name = "AddedInfoTargetedUnitFrame"
AITUF.version = "2.5"

AITUF.accountWideDefaults = {
    accountWide = true
}

AITUF.defaults = {
    showRace = false,
    showClass = false,
    highlightFriends = false,
    highlightGuildMembers = false,
    highlightEsoPlus = false,
    useRaceIcon = false,
    useClassIcon = true,
    iconSizeRace = 24,
    iconSizeClass = 32,
    showCPifAvailable = false,
    hideTitle = false,
    colorGuildIcon = false,
}

local ESO_PLUS_BUFF_ID = 63601

local function GetRaceIcon(raceId)
    if raceId == 1 then -- Breton
        return "/esoui/art/charactercreate/charactercreate_bretonicon_down.dds"
    elseif raceId == 2 then -- Redguard
        return "/esoui/art/charactercreate/charactercreate_redguardicon_down.dds"
    elseif raceId == 3 then -- Orc
        return "/esoui/art/charactercreate/charactercreate_orcicon_down.dds"
    elseif raceId == 4 then -- Dark Elf
        return "/esoui/art/charactercreate/charactercreate_dunmericon_down.dds"
    elseif raceId == 5 then -- Nord
        return "/esoui/art/charactercreate/charactercreate_nordicon_down.dds"
    elseif raceId == 6 then -- Argonian
        return "/esoui/art/charactercreate/charactercreate_argonianicon_down.dds"
    elseif raceId == 7 then -- High Elf
        return "/esoui/art/charactercreate/charactercreate_altmericon_down.dds"
    elseif raceId == 8 then -- Wood Elf
        return "/esoui/art/charactercreate/charactercreate_bosmericon_down.dds"
    elseif raceId == 9 then -- Khajiit
        return "/esoui/art/charactercreate/charactercreate_khajiiticon_down.dds"
    elseif raceId == 10 then -- Imperial
        return "/esoui/art/charactercreate/charactercreate_imperialicon_down.dds"
    end
end

local function OnGamepadPreferredModeChanged()
    if IsInGamepadPreferredMode() then
        AITUF.frame.raceLabel:SetFont("ZoFontGamepad36")
        AITUF.frame.classLabel:SetFont("ZoFontGamepad36")
        AITUF.frame.raceIcon:SetDimensions(AITUF.SV.iconSizeRace, AITUF.SV.iconSizeRace)
        AITUF.frame.classIcon:SetDimensions(40, 40)
    else
        AITUF.frame.raceLabel:SetFont("ZoFontGameBold")
        AITUF.frame.classLabel:SetFont("ZoFontGameBold")
        AITUF.frame.raceIcon:SetDimensions(AITUF.SV.iconSizeRace, AITUF.SV.iconSizeRace)
        AITUF.frame.classIcon:SetDimensions(AITUF.SV.iconSizeClass, AITUF.SV.iconSizeClass)
    end
end

local function UpdateRace(self)
    if IsUnitPlayer("reticleover") and AITUF.SV.showRace then
        if AITUF.SV.useRaceIcon then
            -- Set race texture
            self.raceIcon:SetTexture(GetRaceIcon(GetUnitRaceId(self.unitTag)))
           
            -- Set anchors
            self.raceIcon:ClearAnchors()
            self.raceIcon:SetAnchor(LEFT, self.levelLabel, RIGHT, 5)
            
            -- Set visibility
            self.raceIcon:SetHidden(false)
            self.raceLabel:SetHidden(true)
        else
            -- Set race label text
            
            
            --self.raceLabel:SetText(GetUnitRace(self.unitTag))
            self.raceLabel:SetText(zo_strformat("<<1>>", GetRaceName(GetUnitGender(self.unitTag), GetUnitRaceId(self.unitTag))))
            
            -- Set anchors
            self.raceLabel:ClearAnchors()
            self.raceLabel:SetAnchor(LEFT, self.levelLabel, RIGHT, 5)
            
            -- Set visibility
            self.raceLabel:SetHidden(false)
            self.raceIcon:SetHidden(true)
        end
    else
        -- Hide icons (if even visible), used for changing settings
        self.raceIcon:SetHidden(true)
        self.raceLabel:SetHidden(true)
    end
end

local function UpdateClass(self)
    if IsUnitPlayer(self.unitTag) and AITUF.SV.showClass then
        if AITUF.SV.useClassIcon then
            -- Set class icon texture
            self.classIcon:SetTexture(GetPlatformClassIcon(GetUnitClassId(self.unitTag)))
            
            -- Set anchors
            self.classIcon:ClearAnchors()
            if AITUF.SV.showRace and AITUF.SV.useRaceIcon then
                self.classIcon:SetAnchor(LEFT, self.raceIcon, RIGHT, 0)
            elseif AITUF.SV.showRace then
                self.classIcon:SetAnchor(LEFT, self.raceLabel, RIGHT, 0)
            else
                self.classIcon:SetAnchor(LEFT, self.levelLabel, RIGHT, 0)
            end
            
            -- Set visibility
            self.classLabel:SetHidden(true)
            self.classIcon:SetHidden(false)
        else
            -- Set text label text
            --self.classLabel:SetText(GetUnitClass(self.unitTag))
            self.classLabel:SetText(zo_strformat("<<1>>", GetClassName(GENDER_NEUTER, GetUnitClassId(self.unitTag))))
            
            -- Set anchors
            self.classLabel:ClearAnchors()
            if AITUF.SV.showRace and AITUF.SV.useRaceIcon then
                self.classLabel:SetAnchor(LEFT, self.raceIcon, RIGHT, 0)
            elseif AITUF.SV.showRace then
                self.classLabel:SetAnchor(LEFT, self.raceLabel, RIGHT, 5)
            else
                self.classLabel:SetAnchor(LEFT, self.levelLabel, RIGHT, 5)
            end
            
            -- Set visibility
            self.classIcon:SetHidden(true)
            self.classLabel:SetHidden(false)
        end
    else
        -- Hide icons (if even visible), used for changing settings
        self.classIcon:SetHidden(true)
        self.classLabel:SetHidden(true)  
    end
end
local function UpdateTitle(self)
    if AITUF.SV.hideTitle and IsUnitPlayer(self.unitTag) then
        self.captionLabel:SetText(ZO_GetSecondaryPlayerNameFromUnitTag(self.unitTag))
    end
end


local GUILD_COLOR_DEFS = {
    [1] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_1)),
    [2] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_2)),
    [3] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_3)),
    [4] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_4)),
    [5] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_5)),
}

local function UpdateSocialIcons(self)
    local socialIcons = ""
    local size = IsInGamepadPreferredMode() and 32 or 24
    
    -- If is friend
    if AITUF.SV.highlightFriends and IsUnitFriend(self.unitTag) then
        socialIcons = zo_iconFormat("/esoui/art/campaign/campaignbrowser_friends.dds", size, size) 
    end
    
    -- If is guild member (of any of the player's guilds)
    if AITUF.SV.highlightGuildMembers then
        if IsGuildMate(GetUnitDisplayName(self.unitTag)) then
            if AITUF.SV.colorGuildIcon then
                for guildIndex = 1, GetNumGuilds() do
                    if GetGuildMemberIndexFromDisplayName(GetGuildId(guildIndex), GetUnitDisplayName(self.unitTag)) then
                        socialIcons = socialIcons .. GUILD_COLOR_DEFS[guildIndex]:Colorize(zo_iconFormatInheritColor("/esoui/art/campaign/campaignbrowser_guild.dds", size, size))
                        break
                    end
                end
            else
                socialIcons = socialIcons .. zo_iconFormat("/esoui/art/campaign/campaignbrowser_guild.dds", size, size)
            end
        end
    end
    
    -- ESO Plus Members
    if AITUF.SV.highlightEsoPlus then
        for i = 1, GetNumBuffs(self.unitTag) do
            local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(self.unitTag, i)
            if abilityId == ESO_PLUS_BUFF_ID then
                socialIcons = socialIcons .. zo_iconFormat("/esoui/art/market/keyboard/esoplus_chalice_white_32.dds", size, size)
                break
            end
        end
    end
    
    -- Easter Eggs ;3
    if GetUnitDisplayName(self.unitTag) == "@MrPikPik" then
        socialIcons = socialIcons .. ZO_ColorDef:New("8C1D40"):Colorize(zo_iconFormatInheritColor("/esoui/art/ava/ava_rankicon_general.dds", size, size))
    end
    
    -- Update caption text
    local originalText = self.captionLabel:GetText()
    self.captionLabel:SetText(zo_strformat("<<1>><<2>>", socialIcons, originalText))
end

local function UpdateLevel(self)
    -- if the Character Data Collector addon is enabled, we will try and show the CP for the account
    --if MPPCDC and AITUF.SV.showCPifAvailable then
    --    if GetUnitChampionPoints(self.unitTag) == 0 then
    --        local accountName = GetUnitDisplayName(self.unitTag)
    --        local cp = 0
    --        for _, data in pairs(MPPCDC.SV.characters) do
    --            if (data.account == accountName) and (cp < data.championPoints) then cp = data.championPoints end
    --        end
    --        
    --        if cp > 0 then
    --            local t = self.levelLabel:GetText()
    --            self.levelLabel:SetText(zo_strformat("<<1>> (~<<2>><<3>>)", t, GetChampionIconMarkupString(24), cp))
    --        end 
    --    end  
    --end
end

local function RefreshControls(self)
    if not self.hidden then
        if self.hasTarget then  
            UpdateRace(self)
            UpdateClass(self)
            UpdateTitle(self)
            UpdateSocialIcons(self)
            UpdateLevel(self)
            
            -- Caption anchor offset for nicer display
            self.captionLabel:ClearAnchors()
            if IsUnitPlayer(self.unitTag) and ((AITUF.SV.showClass and AITUF.SV.useClassIcon) or (AITUF.SV.showRace and AITUF.SV.useRaceIcon)) and not IsInGamepadPreferredMode() then
                self.captionLabel:SetAnchor(TOP, ZO_TargetUnitFramereticleoverTextArea, BOTTOM, 0, -8)
            else
                self.captionLabel:SetAnchor(TOP, ZO_TargetUnitFramereticleoverTextArea, BOTTOM, 0, 0)
            end           
            
            self.nameLabel:ClearAnchors()
            if IsUnitPlayer(self.unitTag) then
                if AITUF.SV.showClass and AITUF.SV.useClassIcon then
                    self.nameLabel:SetAnchor(LEFT, self.classIcon, RIGHT, 0)
                elseif AITUF.SV.showClass then
                    self.nameLabel:SetAnchor(LEFT, self.classLabel, RIGHT, 5)
                elseif AITUF.SV.showRace and AITUF.SV.useRaceIcon then
                    self.nameLabel:SetAnchor(LEFT, self.raceIcon, RIGHT, 0)
                elseif AITUF.SV.showRace then
                    self.nameLabel:SetAnchor(LEFT, self.raceLabel, RIGHT, 5)
                else
                    self.nameLabel:SetAnchor(LEFT, self.levelLabel, RIGHT, 5)
                end
            else
                self.nameLabel:SetAnchor(LEFT)
            end
            
            -- Easter eggs :'3
            if GetUnitDisplayName(self.unitTag) == "@MrPikPik" then   
                self.leftBracket:SetHidden(false)
                self.rightBracket:SetHidden(false)
                self.leftBracketUnderlay:SetHidden(true)
                self.rightBracketUnderlay:SetHidden(true)               
                self:SetPlatformDifficultyTextures(MONSTER_DIFFICULTY_DEADLY)
                if not IsInGamepadPreferredMode() then
                    self.leftBracketUnderlay:SetHidden(false)
                    self.rightBracketUnderlay:SetHidden(false)
                end    
            end
 
            self:DoAlphaUpdate(IsUnitInGroupSupportRange(self.unitTag), IsUnitOnline(self.unitTag), IsUnitGroupLeader(self.unitTag))
        end
    end
end


function AITUF.InitializeControls()
    local control = AITUF.frame
    
    control.raceLabel  = WINDOW_MANAGER:CreateControl(control.frame:GetName() .. "RaceText" , ZO_TargetUnitFramereticleoverTextArea, CT_LABEL)
    control.raceIcon   = WINDOW_MANAGER:CreateControl(control.frame:GetName() .. "RaceIcon" , ZO_TargetUnitFramereticleoverTextArea, CT_TEXTURE)
    control.classLabel = WINDOW_MANAGER:CreateControl(control.frame:GetName() .. "ClassText", ZO_TargetUnitFramereticleoverTextArea, CT_LABEL)
    control.classIcon  = WINDOW_MANAGER:CreateControl(control.frame:GetName() .. "ClassIcon", ZO_TargetUnitFramereticleoverTextArea, CT_TEXTURE)
    
    control.raceIcon:SetDimensions(AITUF.SV.iconSizeRace, AITUF.SV.iconSizeRace)
    control.classIcon:SetDimensions(AITUF.SV.iconSizeClass, AITUF.SV.iconSizeClass)

    control:AddFadeComponent("RaceText")
    control:AddFadeComponent("RaceIcon")
    control:AddFadeComponent("ClassText")
    control:AddFadeComponent("ClassIcon")
    
    control.championIcon:ClearAnchors()
    control.championIcon:SetAnchor(RIGHT, control.levelLabel, LEFT, -2)
    
    OnGamepadPreferredModeChanged()
end

-- Initializes
function AITUF.Initialize()
    AITUF.frame = UNIT_FRAMES:GetFrame("reticleover")

    AITUF.InitializeControls()
    
    ZO_PostHook(AITUF.frame, "RefreshControls", RefreshControls)
    
    EVENT_MANAGER:RegisterForEvent(AITUF.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= AITUF.name then return end
    EVENT_MANAGER:UnregisterForEvent(AITUF.name, EVENT_ADD_ON_LOADED)
    
    
    -- Creating saved vars
    AITUF.DS = ZO_SavedVars:NewAccountWide("AITUFSavedVariables", 1.0, nil, AITUF.accountWideDefaults)
    
    if AITUF.DS.accountWide then
        AITUF.SV = ZO_SavedVars:NewAccountWide("AITUFSavedVariables", 1.0, nil, AITUF.defaults)
    else
        AITUF.SV = ZO_SavedVars:New("AITUFSavedVariables", 1.0, nil, AITUF.defaults)
    end
    
    AITUF.InitializeAddonMenu()
    AITUF.Initialize()
end

EVENT_MANAGER:RegisterForEvent(AITUF.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)