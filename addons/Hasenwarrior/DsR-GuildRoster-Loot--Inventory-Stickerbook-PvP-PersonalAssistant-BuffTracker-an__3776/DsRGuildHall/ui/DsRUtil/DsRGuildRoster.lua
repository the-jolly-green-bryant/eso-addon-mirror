-- Create namespace
DsRGuildRoster = {}

local DsRGuildRoster = DsRGuildRoster

DsRGuildRoster.Widths = {
    ["DisplayName"] = 175,
    ["Character"]   = 205,
    ["Zone"]        = 200,
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Changes the header row
function DsRGuildRoster.ModifyGuildMemberMenuHeader()  
  -- Account Name
    ZO_GuildRosterHeadersDisplayName:SetWidth(DsRGuildRoster.Widths.DisplayName)
    ZO_GuildRosterHeadersDisplayName:ClearAnchors()
    ZO_GuildRosterHeadersDisplayName:SetAnchor(LEFT, ZO_GuildRosterHeadersRank, RIGHT, 10)
    
  -- Character Name
    local characterNameColumn = ZO_GuildRosterHeadersCharacterName
    
  -- if column label doesn't exist yet, create it
    if not characterNameColumn then
        characterNameColumn = WINDOW_MANAGER:CreateControlFromVirtual(ZO_GuildRosterHeaders:GetName() .. "CharacterName", ZO_GuildRosterHeaders, "ZO_SortHeader")
        characterNameColumn:SetAnchor(TOPLEFT, ZO_GuildRosterHeadersDisplayName, TOPRIGHT)
        characterNameColumn:SetDimensions(DsRGuildRoster.Widths.Character, 32)
    end
     
    ZO_SortHeader_Initialize(characterNameColumn, GetString(SI_GROUP_LIST_PANEL_NAME_HEADER):upper(), "characterName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    GUILD_ROSTER_KEYBOARD.sortHeaderGroup:AddHeader(characterNameColumn)
    
  -- Zone
    ZO_GuildRosterHeadersZone:SetWidth(DsRGuildRoster.Widths.Zone)
    ZO_GuildRosterHeadersZone:ClearAnchors()
    ZO_GuildRosterHeadersZone:SetAnchor(LEFT, characterNameColumn, RIGHT, 0)     
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Modifies the guild member rows
local function ModifyGuildMemberMenuRow( control ) 
    local displayNameControl   = control:GetNamedChild("DisplayName")
    local characterNameControl = control:GetNamedChild("CharacterName")
    local zoneControl          = control:GetNamedChild("Zone")
    local classControl         = control:GetNamedChild("ClassIcon")
    local noteControl          = control:GetNamedChild("Note")

  -- Display Name
    displayNameControl:ClearAnchors()
    displayNameControl:SetAnchor(LEFT, control:GetNamedChild("RankIcon"), RIGHT, 5)
    displayNameControl:SetWidth(DsRGuildRoster.Widths.DisplayName)

  -- Character Name
    if characterNameControl == nil then
		characterNameControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "CharacterName", control, CT_LABEL)
		characterNameControl:SetFont("ZoFontGame")
		characterNameControl:SetAnchor(LEFT, displayNameControl, RIGHT, 0)
		characterNameControl:SetVerticalAlignment(BOTTOM)
	end

    characterNameControl:SetColor((control.dataEntry.data.online and ZO_SECOND_CONTRAST_TEXT or ZO_DISABLED_TEXT):UnpackRGB())
    characterNameControl:SetWidth(DsRGuildRoster.Widths.Character)
	characterNameControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, control.dataEntry.data.characterName); ZO_GroupListRow_OnMouseEnter(control); end);
	characterNameControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	characterNameControl:SetText(control.dataEntry.data.characterName)
 
  -- Zone
    zoneControl:ClearAnchors()
    zoneControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
    zoneControl:SetWidth(DsRGuildRoster.Widths.Zone)
    
  -- Class (move a bit further left than normal)
    classControl:ClearAnchors()
    classControl:SetAnchor(LEFT, zoneControl, RIGHT, 14)
    
  -- Note (move a bit further left than normal)
    noteControl:ClearAnchors()
    noteControl:SetAnchor(LEFT, control:GetNamedChild("Level"), RIGHT, 0)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildRoster.OnSceneChange(oldState, newState)
    if newState == "showing" then zo_callLater(DsRGuildRoster.UpdateGuildRosterList, 100) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Runs through each row in the roster to update it
function DsRGuildRoster.UpdateGuildRosterList()
	if ZO_GuildRoster:IsHidden() == false then
        for _, row in pairs(ZO_GuildRosterList.activeControls) do
			ModifyGuildMemberMenuRow(row)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- MouseOver functions
local org_ZO_KeyboardGuildRosterRowAlliance_OnMouseEnter = ZO_KeyboardGuildRosterRowAlliance_OnMouseEnter
local org_ZO_KeyboardGuildRosterRowAlliance_OnMouseExit = ZO_KeyboardGuildRosterRowAlliance_OnMouseExit

-------------------------------------------------------------------------------------------------------------------------------------------------
-- show custom rank icon / personal icon in guild roster and color name for Leader
function DsRGuildRoster.CustomIcons()
    local setupEntry = GUILD_ROSTER_MANAGER.SetupEntry
    function GUILD_ROSTER_MANAGER:SetupEntry( control, data, selected )
        setupEntry( self, control, data, selected )
        
        local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
        local guildName = GetGuildName(guildId)        
        local AllCont   = control:GetNamedChild( "AllianceIcon" )
        local RankCont  = control:GetNamedChild( "RankIcon" )
        local Name      = control:GetNamedChild( "DisplayName" )
        local player    = data.displayName
        local playerAll = data.alliance

        if guildName == "Die sieben Raben" then 
            for k,v in pairs(DsRglobals.GuildLeader) do
                if player == "@PettiPuuh"then
                    RankCont:SetTexture( "/DsRGuildHall/misc/DsR_RabenwachtPetti.dds" )
                elseif player == "@flo1980" then
                    RankCont:SetTexture( "/DsRGuildHall/misc/DsR_RabenwachtFLO.dds" )
                elseif player == v then
                    RankCont:SetTexture( "/DsRGuildHall/misc/DsR_Rabenwacht.dds" )
                end
            end
        end
        if playerAll == 1 then
            AllCont:SetTexture( "/esoui/art/ava/ava_hud_emblem_aldmeri.dds" )
        elseif playerAll == 2 then
            AllCont:SetTexture( "/esoui/art/ava/ava_hud_emblem_ebonheart.dds" )
        elseif playerAll == 3 then
            AllCont:SetTexture( "/esoui/art/ava/ava_hud_emblem_daggerfall.dds" )
        end
    end
    function ZO_GuildRosterManager:ColorRow(control, data, textColor, iconColor, textColor2)
        ZO_SocialList_ColorRow(control, data, textColor, iconColor, textColor2)
        
        local Name      = control:GetNamedChild( "DisplayName" )
        local OwnACC    = GetUnitDisplayName("player")
        local player    = data.displayName
        local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
        local guildName = GetGuildName(guildId)        
        if guildName == "Die sieben Raben" then     
            local playerNote = data.note
            local SearchEhrenRabeNote = zo_strmatch(zo_strupper(playerNote) , zo_strupper("Ehrenrabe"))
            if SearchEhrenRabeNote ~= nil then
                for k,v in pairs(DsRglobals.GuildLeader) do
                    if OwnACC == v then
                        Name:SetColor( 128, 0, 0 , 1 )
                    end
                end
            end
            for k,v in pairs(DsRglobals.GuildLeader) do
                if player == v then
                    Name:SetColor( 196 , 167 , 0 , 1 )
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Alliance
function ZO_KeyboardGuildRosterRowAlliance_OnMouseEnter(control)
  org_ZO_KeyboardGuildRosterRowAlliance_OnMouseEnter(control)
  local parent    = control:GetParent()
  local data      = ZO_ScrollList_GetData(parent)

  InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
  if data.alliance == 1 then
      SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(GetString(DsR_Aldmeri)))
  elseif data.alliance == 2 then
      SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(GetString(DsR_Ebonheart)))
  elseif data.alliance == 3 then
      SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(GetString(DsR_Daggerfall)))
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function ZO_KeyboardGuildRosterRowAlliance_OnMouseExit(control)
  ClearTooltip(InformationTooltip)

  org_ZO_KeyboardGuildRosterRowAlliance_OnMouseExit(control)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On guild change
function DsRGuildRoster.OnGuildIdChanged(guild_roster_manager)
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    if not guild_roster_manager then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t identify the guild hall yet")))
        return
    end
    if not guildId then
        return
    end

    -- if guildName == "Die sieben Raben" then
        DsRGuildRoster.CustomIcons()
    -- end
end
