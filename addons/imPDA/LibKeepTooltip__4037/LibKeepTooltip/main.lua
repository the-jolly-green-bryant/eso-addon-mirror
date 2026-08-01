local function Logger()
    if not LibDebugLogger then return function(...) end end

    local logger = LibDebugLogger:Create('LibKeepTooltip')
    logger:SetMinLevelOverride(LibDebugLogger.LOG_LEVEL_DEBUG)

    local level = LibDebugLogger.LOG_LEVEL_DEBUG

    local function inner(...)
        logger:Log(level, ...)
    end

    return inner
end

local Log = Logger()

-- ----------------------------------------------------------------------------

local addon = {}

addon.name = 'LibKeepTooltip'
addon.displayName = 'LibKeepTooltip'
addon.version = '1.0.1'

--#region REFACTORED PART
-- Refactored `esoui\esoui\ingame\map\keeptooltip.lua`
local LINE_SPACING = 3
local BORDER = 8
local MAX_WIDTH = 400

local KEEP_TOOLTIP_NAME = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_NAME))
local KEEP_TOOLTIP_ATTACK_LINE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_ATTACK_LINE))
local KEEP_TOOLTIP_NORMAL_LINE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_NORMAL_LINE))
local KEEP_TOOLTIP_ACCESSIBLE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_ACCESSIBLE))
local KEEP_TOOLTIP_NOT_ACCESSIBLE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_NOT_ACCESSIBLE))
local KEEP_TOOLTIP_UNIDIRECTIONALLY_ACCESSIBLE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_UNIDIRECTIONALLY_ACCESSIBLE))
local KEEP_TOOLTIP_AT_KEEP = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_AT_KEEP))
local KEEP_TOOLTIP_OWNER = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_OWNER))
local KEEP_TOOLTIP_UNCLAIMED = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_UNCLAIMED))

local SMALL_KEEP_ICON_STRING = zo_iconFormatInheritColor('EsoUI/Art/AvA/AvA_tooltipIcon_keep.dds', 32, 32)

local DISTRICT_BONUS_VALUE_FORMAT = GetString(SI_TOOLTIP_DISTRICT_TEL_VAR_BONUS_FORMAT)
local KEEP_CAPTURE_BONUS_VALUE_FORMAT = GetString(SI_TOOLTIP_KEEP_CAPTURE_BONUS_FORMAT)
local DISTRICT_BONUS_RESTRICTION_TEXT = GetString(SI_TOOLTIP_DISTRICT_TEL_VAR_BONUS_RESTRICTION_TEXT)

addon.KEEP_TOOLTIP_NORMAL_LINE = KEEP_TOOLTIP_NORMAL_LINE
addon.KEEP_TOOLTIP_ATTACK_LINE = KEEP_TOOLTIP_ATTACK_LINE

local function AddVerticalSpace(self, offsetY)
    self.extraSpace = offsetY
end

local function AddLine(self, text, color)
    local line = self.linePool:AcquireObject()
    line:SetHidden(false)
    line:SetDimensionConstraints(0, 0, MAX_WIDTH, 0)
    line:SetText(text)

    local r,g,b,a = color:UnpackRGBA()
    line:SetColor(r,g,b,a)

    local spacing = self.extraSpace or LINE_SPACING
    if(self.lastLine) then
        line:SetAnchor(TOPLEFT, self.lastLine, BOTTOMLEFT, 0, spacing)
    else
        line:SetAnchor(TOPLEFT, GetControl(self, 'Name'), BOTTOMLEFT, 0, spacing)
    end

    self.extraSpace = nil
    self.lastLine = line

    local width, height = line:GetTextDimensions()

    if(width > self.width) then
        self.width = width
    end

    self.height = self.height + height + LINE_SPACING

    return line
end
addon.AddLine = AddLine

local function AddHeaderLine(self)
    local alliance = self.alliance
    local keepName = self.keepName

    local text = zo_strformat(SI_TOOLTIP_KEEP_NAME, keepName)

    local headerControl = GetControl(self, 'Name')
    local allianceColor = GetAllianceColor(alliance)

    local icon = (alliance ~= 0) and ZO_GetAllianceIcon(alliance) or nil
    if icon then
        local allianceIcon = zo_iconFormatInheritColor(icon, 16, 32)
        text = string.format('%s %s', allianceIcon, text)
    end

    headerControl:SetText(allianceColor:Colorize(text))

    local width, height = headerControl:GetTextDimensions()
    self.width = width
    self.height = height
end

local function AddAllianceOwnerLine(self)
    if not IsKeepTypeCapturable(self.keepType) then
        Log(self.keepType .. ' UNCAPTURABLE')
        return
    end

    local alliance = self.alliance
    local allianceName
    if(self.alliance == ALLIANCE_NONE) then
        allianceName = GetString(SI_KEEP_UNCLAIMED)
    else
        allianceName = GetAllianceName(alliance)
    end
    local allianceColor = GetAllianceColor(alliance)

    local text = zo_strformat(GetString(SI_TOOLTIP_KEEP_ALLIANCE_OWNER), allianceColor:Colorize(allianceName))

    AddLine(self, text, KEEP_TOOLTIP_NORMAL_LINE)
end

local function AddGuildOwnerLine(self)
    if not IsKeepTypeClaimable(self.keepType) then
        Log(self.keepType .. ' UNCLIMABLE')
        return
    end

    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext

    local guildName = GetClaimedKeepGuildName(keepId, battlegroundContext)
    local color = KEEP_TOOLTIP_NAME

    if guildName == '' then
        guildName = GetString(SI_KEEP_UNCLAIMED_GUILD)
        color = KEEP_TOOLTIP_UNCLAIMED
    end

    local text = zo_strformat(GetString(SI_TOOLTIP_KEEP_GUILD_OWNER), color:Colorize(guildName))

    AddLine(self, text, KEEP_TOOLTIP_NORMAL_LINE)
end

local function AddSiegesLine(self)
    -- Not original function, changed a bit but too lazy to revert chages to ZOS variant 
    -- pros: prettier imo
    -- cons: there is no way back (if you prefer ZOS variant - sorry) and only English supported
    if not DoesKeepTypeHaveSiegeLimit(self.keepType) then
        Log(self.keepType .. ' DOES NOT HAVE SIEGE LIMIT')
        return
    end

    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext

    local maxSiegeWeapons = GetMaxKeepSieges(keepId, battlegroundContext)
    local siegesTable = {}

    for i = 1, NUM_ALLIANCES do
        local allianceColor = GetAllianceColor(i)
        local numSiegeWeapons = GetNumSieges(keepId, battlegroundContext, i)

        local sieges = allianceColor:Colorize(string.format('%d/%d', numSiegeWeapons, maxSiegeWeapons))
        table.insert(siegesTable, sieges)
    end

    local text = 'Sieges: ' .. table.concat(siegesTable, ' - ')

    AddLine(self, text, KEEP_TOOLTIP_NORMAL_LINE)
end

local function AddArtifactLine(self)
    if self.keepType ~= KEEPTYPE_ARTIFACT_KEEP then
        Log(self.keepType .. ' NOT ARTIFACT TYPE')
        return
    end

    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext

    local objectiveId = GetKeepArtifactObjectiveId(keepId)
    if objectiveId == 0 then return end

    local text
    local _, artifactType, artifactState = GetObjectiveInfo(keepId, objectiveId, battlegroundContext)
    if artifactType == OBJECTIVE_ARTIFACT_OFFENSIVE then
        text = zo_strformat(SI_TOOLTIP_ARTIFACT_TYPE_OFFENSIVE)
    else
        text = zo_strformat(SI_TOOLTIP_ARTIFACT_TYPE_DEFENSIVE)
    end
    AddLine(self, text, KEEP_TOOLTIP_NORMAL_LINE)

    if artifactState ~= OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE then
        AddLine(self, GetString(SI_TOOLTIP_ARTIFACT_TAKEN), KEEP_TOOLTIP_ATTACK_LINE)
    end
end

local function AddTelVarBonusLine(self)
    if self.keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT then
        Log(self.keepType .. ' NOT TELVAR DISTRICT')
        return
    end

    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext
    local alliance = self.alliance

    local telVarBonus = GetDistrictOwnershipTelVarBonusPercent(keepId, battlegroundContext)
    if telVarBonus <= 0 then return end

    local captured = alliance == GetUnitAlliance('player')
    local color = captured and KEEP_TOOLTIP_ACCESSIBLE or KEEP_TOOLTIP_UNCLAIMED
    local telVarBonusText = color:Colorize(zo_strformat(DISTRICT_BONUS_VALUE_FORMAT, telVarBonus))

    local finalBonusText = zo_strformat(SI_TOOLTIP_DISTRICT_TEL_VAR_BONUS_TEXT, telVarBonusText, ZO_Currency_GetPlatformFormattedCurrencyIcon(CURT_TELVAR_STONES))

    AddLine(self, finalBonusText, KEEP_TOOLTIP_NORMAL_LINE)
    AddLine(self, DISTRICT_BONUS_RESTRICTION_TEXT, KEEP_TOOLTIP_NORMAL_LINE)
end

local function AddKeepCaptureBonusLine(self)
    if self.keepType ~= KEEPTYPE_KEEP then
        Log(self.keepType .. ' NOT USUAL KEEP')
        return
    end

    local function GetKeepCaptureBonusText(keepId_, battlegroundContext_, keepAlliance_)
        local pointBonus = GetKeepCaptureBonusPercent(keepId_, battlegroundContext_)
        if pointBonus > 0 then
            local pointBonusText = zo_strformat(KEEP_CAPTURE_BONUS_VALUE_FORMAT, pointBonus)
            local captured = keepAlliance_ == GetUnitAlliance('player')
            local color = captured and KEEP_TOOLTIP_ACCESSIBLE or KEEP_TOOLTIP_UNCLAIMED
            return color:Colorize(pointBonusText)
        end
        return nil
    end

    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext
    local alliance = self.alliance

    local pointBonusText = GetKeepCaptureBonusText(keepId, battlegroundContext, alliance)
    if pointBonusText then
        local finalBonusText = zo_strformat(SI_TOOLTIP_KEEP_CAPTURE_BONUS_TEXT, pointBonusText, ZO_Currency_GetPlatformFormattedCurrencyIcon(CURT_ALLIANCE_POINTS))
        AddLine(self, finalBonusText, KEEP_TOOLTIP_NORMAL_LINE)
    end
end

local function AddPassableLine(self)
    if not IsKeepTypePassable(self.keepType) then
        Log(self.keepType .. ' NOT PASSABLE TYPE')
        return
    end

    local function GetPassableKeepStatusText(keepId_, battlegroundContext_, keepType_)
        if IsKeepTypePassable(keepType_) then
            local directionalAccess = GetKeepDirectionalAccess(keepId_, battlegroundContext_)
            if directionalAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_BIDIRECTIONAL then
                local statusText = GetString(SI_MAP_KEEP_PASSABLE_STATUS_CAN_PASS)
                return KEEP_TOOLTIP_ACCESSIBLE:Colorize(statusText)
            elseif directionalAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_BLOCKED then
                local statusText = GetString(SI_MAP_KEEP_PASSABLE_STATUS_CANNOT_PASS)
                return KEEP_TOOLTIP_NOT_ACCESSIBLE:Colorize(statusText)
            elseif directionalAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_UNIDIRECTIONAL then
                if keepType_ == KEEPTYPE_MILEGATE then
                    local statusText = GetString(SI_MAP_KEEP_MILEGATE_UNIDIRECTIONALLY_PASSABLE)
                    return KEEP_TOOLTIP_UNIDIRECTIONALLY_ACCESSIBLE:Colorize(statusText)
                end
            end
        end
    end

    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext
    local keepType = self.keepType

    local statusText = GetPassableKeepStatusText(keepId, battlegroundContext, keepType)
    if statusText then
        AddLine(self, zo_strformat(SI_TOOLTIP_KEEP_PASSABLE_STATUS, statusText), KEEP_TOOLTIP_NORMAL_LINE)
    end
end

local function AddFastTravelLine(self)
    local startingKeep = GetKeepFastTravelInteraction()
    local isUsingKeepRecallStone = WORLD_MAP_MANAGER:IsInMode(MAP_MODE_AVA_KEEP_RECALL)

    if not startingKeep or not isUsingKeepRecallStone then return end

    local keepId = self.keepId
    local keepType = self.keepType
    local battlegroundContext = self.battlegroundContext
    local alliance = self.alliance

    AddVerticalSpace(self, 5)
    if keepId == startingKeep then
        AddLine(self, GetString(SI_TOOLTIP_KEEP_STARTING_KEEP), KEEP_TOOLTIP_AT_KEEP)
    else
        local bgContext = ZO_WorldMap_GetBattlegroundQueryType()
        local isKeepAccessible = isUsingKeepRecallStone and GetKeepRecallAvailable(keepId, bgContext) or CanKeepBeFastTravelledTo(keepId, bgContext)

        if isKeepAccessible then
            AddLine(self, GetString(SI_TOOLTIP_KEEP_ACCESSIBLE), KEEP_TOOLTIP_ACCESSIBLE)
        else
            local playerAlliance = GetUnitAlliance('player')
            if keepType ~= KEEPTYPE_KEEP and keepType ~= KEEPTYPE_BORDER_KEEP and keepType ~= KEEPTYPE_OUTPOST and keepType ~= KEEPTYPE_TOWN then
                AddLine(self, GetString(SI_TOOLTIP_KEEP_NOT_ACCESSIBLE), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            elseif playerAlliance ~= alliance then
                AddLine(self, GetString(SI_TOOLTIP_KEEP_NOT_ACCESSIBLE_WRONG_OWNER), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            elseif IsKeepTravelBlockedByDaedricArtifact(keepId) then
                AddLine(self, GetString(SI_TOOLTIP_KEEP_NOT_ACCESSIBLE_CARRYING_DAEDRIC_ARTIFACT), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            elseif GetKeepUnderAttack(keepId, bgContext) then
                AddLine(self, GetString(SI_TOOLTIP_KEEP_NOT_ACCESSIBLE_UNDER_ATTACK), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            elseif GetKeepUnderAttack(startingKeep, battlegroundContext) then
                AddLine(self, GetString(SI_TOOLTIP_KEEP_STARTING_KEEP_UNDER_ATTACK), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            elseif isUsingKeepRecallStone then
                local keepRecallUseResult = CanUseKeepRecallStone()
                AddLine(self, GetString('SI_KEEPRECALLSTONEUSERESULT', keepRecallUseResult), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            elseif not GetKeepHasResourcesForTravel(keepId, bgContext) then
                AddLine(self, GetString(SI_TOOLTIP_KEEP_NOT_ACCESSIBLE_RESOURCES), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            elseif not GetKeepHasResourcesForTravel(startingKeep, bgContext) then
                AddLine(self, GetString(SI_TOOLTIP_KEEP_STARTING_KEEP_RESOURCES), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            else
                AddLine(self, GetString(SI_TOOLTIP_KEEP_NOT_ACCESSIBLE_NETWORK), KEEP_TOOLTIP_NOT_ACCESSIBLE)
            end
        end
    end
end

local function AddKeepUnderAttackLine(self)
    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext

    local showUnderAttackLine = GetKeepUnderAttack(keepId, battlegroundContext)
    if not showUnderAttackLine then return end

    AddLine(self, GetString(SI_TOOLTIP_KEEP_IN_COMBAT), KEEP_TOOLTIP_ATTACK_LINE)
end

local function AddRespawnLine(self)
    if not WORLD_MAP_MANAGER:IsInMode(MAP_MODE_AVA_RESPAWN) then return end

    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext

    if not IsLocalBattlegroundContext(battlegroundContext) then return end

    if CanRespawnAtKeep(keepId) then
        AddLine(self, GetString(SI_TOOLTIP_KEEP_RESPAWNABLE), KEEP_TOOLTIP_ACCESSIBLE)
    else
        AddLine(self, GetString(SI_TOOLTIP_KEEP_NOT_RESPAWNABLE), KEEP_TOOLTIP_NOT_ACCESSIBLE)
    end
end
--#endregion REFACTORED

--#region COOKING
local INGRIDIENTS = {
    HEADER = 1,
    ALLIANCE_OWNER = 2,
    GUILD_OWNER = 3,
    SIEGES = 4,
    ARTIFACT = 5,
    TEL_VAR_BONUS = 6,
    KEEP_CAPTURE_BONUS = 7,
    IS_PASSABLE = 8,
    FAST_TRAVEL = 9,
    KEEP_UNDER_ATTACK = 10,
    RESPAWN = 11,
}
addon.INGRIDIENTS = INGRIDIENTS

local LAST_INGRIDIENT = 1000

function addon:RegisterIngridient(name, callback)
    if type(callback) ~= 'function' then
        error('Callback for ' .. name .. ' is not a function')
    end

    local ingridient = self.INGRIDIENTS[name]
    if ingridient then error('Ingridient ' .. name .. ' already exists') end

    self.INGRIDIENTS[name] = LAST_INGRIDIENT
    self.callbacks[LAST_INGRIDIENT] = callback

    LAST_INGRIDIENT = LAST_INGRIDIENT + 1

    return self.INGRIDIENTS[name]
end

function addon:ReplaceIngridient(ingridient, callback)
    self.callbacks[ingridient] = callback
end

function addon:GetIngridient(name)
    return self.INGRIDIENTS[name]
end

function addon:GetIngridientCallback(ingridient)
    return self.callbacks[ingridient]
end

local function find(table, value)
    for i = 1, #table do
        if table[i] == value then return i end
    end
end

local function AddIngridient(recipe, ingridient, index)
    if index then
        table.insert(recipe, index, ingridient)
    else
        table.insert(recipe, ingridient)
    end
end

local function RemoveIngridient(recipe, ingridient)
    local index = find(recipe, ingridient)
    if index then table.remove(recipe, index) end

    return index
end

local function AddIngridientAfter(recipe, ingridient, after)
    local index = find(recipe, after)
    if not index then error('Ingridient ' .. tostring(ingridient) .. ' not found in recipe ' .. tostring(recipe)) end
    table.insert(recipe, index + 1, ingridient)

    return index
end

local function AddIngridientBefore(recipe, ingridient, before)
    local index = find(recipe, before)
    if not index then error('Ingridient ' .. tostring(ingridient) .. ' not found in recipe ' .. tostring(recipe)) end
    table.insert(recipe, index - 1, ingridient)

    return index
end

addon.AddIngridient = AddIngridient
addon.RemoveIngridient = RemoveIngridient
addon.AddIngridientAfter = AddIngridientAfter
addon.AddIngridientBefore = AddIngridientBefore

-- TODO replace and unregister?
-- function addon:UnregisterIngridient(name)
--     local ingridient = self.ingridients[name]
--     if ingridient then error('Ingridient does not exists') end

--     self.ingridients[name] = LAST_INGRIDIENT
--     self.callbacks[LAST_INGRIDIENT] = callback

--     LAST_INGRIDIENT = LAST_INGRIDIENT + 1
-- end

addon.callbacks = {
    [INGRIDIENTS.HEADER] = AddHeaderLine,
    [INGRIDIENTS.ALLIANCE_OWNER] = AddAllianceOwnerLine,
    [INGRIDIENTS.GUILD_OWNER] = AddGuildOwnerLine,
    [INGRIDIENTS.SIEGES] = AddSiegesLine,
    [INGRIDIENTS.ARTIFACT] = AddArtifactLine,
    [INGRIDIENTS.TEL_VAR_BONUS] = AddTelVarBonusLine,
    [INGRIDIENTS.KEEP_CAPTURE_BONUS] = AddKeepCaptureBonusLine,
    [INGRIDIENTS.IS_PASSABLE] = AddPassableLine,
    [INGRIDIENTS.FAST_TRAVEL] = AddFastTravelLine,
    [INGRIDIENTS.KEEP_UNDER_ATTACK] = AddKeepUnderAttackLine,
    [INGRIDIENTS.RESPAWN] = AddRespawnLine,
}
--#region DEFAULT RECIPES
local USUAL_KEEP_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
    INGRIDIENTS.ALLIANCE_OWNER,
    INGRIDIENTS.GUILD_OWNER,
    INGRIDIENTS.SIEGES,
    INGRIDIENTS.KEEP_CAPTURE_BONUS,
    INGRIDIENTS.FAST_TRAVEL,
    INGRIDIENTS.KEEP_UNDER_ATTACK,
    INGRIDIENTS.RESPAWN,
}

local RESOURCE_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
    INGRIDIENTS.ALLIANCE_OWNER,
    INGRIDIENTS.GUILD_OWNER,
    INGRIDIENTS.SIEGES,
    INGRIDIENTS.KEEP_UNDER_ATTACK,
}

local OUTPOST_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
    INGRIDIENTS.ALLIANCE_OWNER,
    INGRIDIENTS.GUILD_OWNER,
    INGRIDIENTS.SIEGES,
    INGRIDIENTS.FAST_TRAVEL,
    INGRIDIENTS.KEEP_UNDER_ATTACK,
    INGRIDIENTS.RESPAWN,
}

local TOWN_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
    INGRIDIENTS.ALLIANCE_OWNER,
    -- INGRIDIENTS.GUILD_OWNER,
    INGRIDIENTS.SIEGES,
    INGRIDIENTS.FAST_TRAVEL,
    INGRIDIENTS.KEEP_UNDER_ATTACK,
    INGRIDIENTS.RESPAWN
}

local IC_DISTRICT_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
    INGRIDIENTS.ALLIANCE_OWNER,
    -- INGRIDIENTS.GUILD_OWNER,
    INGRIDIENTS.FAST_TRAVEL,
    INGRIDIENTS.KEEP_UNDER_ATTACK,
    INGRIDIENTS.RESPAWN,
}

local ARTIFACT_KEEP_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
    INGRIDIENTS.SIEGES,
    INGRIDIENTS.ARTIFACT,
}

local ARTIFACT_GATE_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
}

local BRIDGE_TOOLTIP_RECIPE = {
    INGRIDIENTS.HEADER,
    INGRIDIENTS.IS_PASSABLE,
}
local MILEGATE_TOOLTIP_RECIPE = BRIDGE_TOOLTIP_RECIPE
--#endregion

local function Add(self, ingridient)
    if not addon.callbacks[ingridient] then error('Callback for ' .. tostring(ingridient) .. ' not found') end

    addon.callbacks[ingridient](self)
end

local function Cook(self, recipe)
    for _, ingridient in ipairs(recipe) do
        Add(self, ingridient)
    end
end

local tooltipRecipes = {
    [KEEPTYPE_KEEP] = USUAL_KEEP_TOOLTIP_RECIPE,
    [KEEPTYPE_RESOURCE] = RESOURCE_TOOLTIP_RECIPE,
    [KEEPTYPE_OUTPOST] = OUTPOST_TOOLTIP_RECIPE,
    [KEEPTYPE_TOWN] = TOWN_TOOLTIP_RECIPE,
    [KEEPTYPE_IMPERIAL_CITY_DISTRICT] = IC_DISTRICT_TOOLTIP_RECIPE,
    [KEEPTYPE_ARTIFACT_KEEP] = ARTIFACT_KEEP_TOOLTIP_RECIPE,
    [KEEPTYPE_ARTIFACT_GATE] = ARTIFACT_GATE_TOOLTIP_RECIPE,
    [KEEPTYPE_BRIDGE] = BRIDGE_TOOLTIP_RECIPE,
    [KEEPTYPE_MILEGATE] = MILEGATE_TOOLTIP_RECIPE,
    [KEEPTYPE_BORDER_KEEP] = nil,
}

function addon.GetRecipeByKeepType(keepType)
    return tooltipRecipes[keepType]
end

local function CookTooltip(self)
    local recipe = tooltipRecipes[self.keepType]
    if not recipe then error('No suitable recipe found') end

    Cook(self, recipe)
end

local function AddBorder(self)
    self.width = self.width + BORDER * 2
    self.height = self.height + BORDER * 2
    self:SetDimensions(self.width, self.height)
end
--#endregion COOKING

--#region HOOKING
local function LayoutKeepTooltip(self, keepId, battlegroundContext, historyPercent)
    if historyPercent < 1.0 then Log('Doesnt ment to work with history data') end

    self:Reset()

    self.keepId = keepId
    self.battlegroundContext = battlegroundContext
    self.historyPercent = historyPercent

    self.keepName = GetKeepName(keepId)
    if not self.keepName then return end

    self.keepType = GetKeepType(keepId)
    self.alliance = GetHistoricalKeepAlliance(keepId, battlegroundContext, historyPercent)

    CookTooltip(self)
    AddBorder(self)
end

local function RefreshKeepInfo(self)
    if not (self.keepId and self.battlegroundContext and self.historyPercent) then return end
    LayoutKeepTooltip(self, self.keepId, self.battlegroundContext, self.historyPercent)
end

function addon:HookKeepTooltip()
    local function silent_error(fn, ...)
        local status, error = pcall(fn, ...)
        if error then Log(error) end

        return status
    end

    ZO_PreHook(ZO_KeepTooltip, 'SetKeep', function(...)
        return silent_error(LayoutKeepTooltip, ...)
    end)

    ZO_PreHook(ZO_KeepTooltip, 'RefreshKeepInfo', function(...)
        return silent_error(RefreshKeepInfo, ...)
    end)
end
--#endregion HOOKING

--#region ADDON INITIALIZATION
function addon:InitializeChangedTooltips()
    if addon.enabled then return end

    local OldAddAllianceOwnerLine = self:GetIngridientCallback(INGRIDIENTS.ALLIANCE_OWNER)
    self:ReplaceIngridient(INGRIDIENTS.ALLIANCE_OWNER, function(tooltip)
        if true then return end
        OldAddAllianceOwnerLine(tooltip)
    end)

    self:HookKeepTooltip()

    addon.enabled = true
end

LibKeepTooltip = addon
--#endregion