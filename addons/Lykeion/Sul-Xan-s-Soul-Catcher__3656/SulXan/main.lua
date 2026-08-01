SulXan = {
    name = "SulXan",
    version = "1.5",
    author = "Lykeion",
    varVersion = 1, -- savedVariables version
    defaultSettings = {
    }
}

local BUFF_ID = 154737 -- Buff id
local SOUL_ID = 154720 -- Soul Drop id

local SX = SulXan
local NAME = SX.name
local EM = EVENT_MANAGER
local SV

local inCombat = false

local stFragment
local sxSlotted = false
local soulEnd = 0
local buffEnd = 0

local function Initialize()
    
    SV = ZO_SavedVars:New("SXSV", SX.varVersion, nil, SX.defaultSettings)
    SX.RestorePosition()
    SX.AddonMenu()

    -- Create UI fragment.
    stFragment = ZO_SimpleSceneFragment:New(SulXanControl)
    stFragment:SetConditional(function()
        return 
        sxSlotted and inCombat or 
        buffEnd - GetGameTimeSeconds() > 0 or
        soulEnd - GetGameTimeSeconds() > 0
    end)
    HUD_SCENE:AddFragment(stFragment)
    HUD_UI_SCENE:AddFragment(stFragment)

    -- Update CW duration.
    local function UpdateDuration()
        local buffRemain = buffEnd - GetGameTimeSeconds()
        if buffRemain < 0 then
            buffRemain = 0
        end
        local soulRemain = soulEnd - GetGameTimeSeconds()
        if soulRemain < 0 then
            soulRemain = 0
        end

        SulXanControl_CWDuration:SetText(zo_ceil(buffRemain))
        SulXanControl_MEDuration:SetText(zo_ceil(soulRemain))

        if buffRemain > 0 then
            SulXanControl_BG:SetColor(0, 0, 1)
        elseif soulRemain > 0 then
            SulXanControl_BG:SetColor(1 - (6 - 6 / soulRemain) / 6, 0 + (6 - 6 / soulRemain) / 6, 0)
        else
            SulXanControl_BG:SetColor(1, 0, 0)
        end
    end

    local function OnSoul(_, changeType, _, _, _, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId)
        soulEnd = endTime
        UpdateDuration()
    end

    local function OnBuff(_, changeType, _, _, _, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId)
        buffEnd = endTime
        UpdateDuration()
        -- if changeType == EFFECT_RESULT_FADED then
        --     buffActive = false
        -- elseif changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        --     buffActive = true
        -- end
    end

    -- Combat state changes.
    local function CombatState()
        inCombat = IsUnitInCombat("player")
        -- EM:UnregisterForUpdate(NAME .. 'Update')
        if inCombat and sxSlotted then
            EM:RegisterForUpdate(NAME .. 'Update', 200, function()
                UpdateDuration()
            end)
        end
        stFragment:Refresh()
    end

    -- Check if CW is slotted.
    local function SetCheck()
        local sxNum = 0
        local psxNum = 0
        _, _, _, sxNum, _, _, psxNum = GetItemLinkSetInfo(
            "|H1:item:174533:364:50:26848:370:50:26:0:0:0:0:0:0:0:2049:122:0:1:0:348:0|h|h", true)
        if (sxNum + psxNum) >= 3 then
            sxSlotted = true
        else
            sxSlotted = false
        end
        CombatState()
    end

    EM:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, SetCheck)
    EM:RegisterForEvent(NAME, EVENT_PLAYER_COMBAT_STATE, CombatState)
    EM:RegisterForEvent(NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SetCheck)

    EM:RegisterForEvent(NAME .. "S", EVENT_EFFECT_CHANGED, OnSoul)
    EM:AddFilterForEvent(NAME .. "S", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, SOUL_ID)
    EM:AddFilterForEvent(NAME .. "S", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
    COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "B", EVENT_EFFECT_CHANGED, OnBuff)
    EM:AddFilterForEvent(NAME .. "B", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, BUFF_ID)
    EM:AddFilterForEvent(NAME .. "B", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER)

end

function SX.Move()

    SV.controlCenterX, SV.controlCenterY = SulXanControl:GetCenter()

    SulXanControl:ClearAnchors()
    SulXanControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)

end

function SX.RestorePosition()

    local controlCenterX = SV.controlCenterX
    local controlCenterY = SV.controlCenterY

    if controlCenterX or controlCenterY then
        SulXanControl:ClearAnchors()
        SulXanControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, controlCenterX, controlCenterY)
    end

    SulXanControl_Icon:SetTexture(GetAbilityIcon(BUFF_ID))

end

local function OnAddOnLoaded(event, addonName)
    if addonName == NAME then
        EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

function SX.AddonMenu()
    LAM = LibAddonMenu2
    if LAM then
        local menuOptions
        if IsConsoleUI() then
            menuOptions = {
                type = "panel",
                name = "Lykeion's Sul-Xan Soul Catcher",
                displayName = "Lykeion's Sul-Xan Soul Catcher",
                author = SX.author,
                version = SX.version,
                slashCommand = "/sulxan",
                registerForRefresh = true
            }
        else
            menuOptions = {
                type = "panel",
                name = "|c2c5c8dSul-Xan's |cb48b39Soul Catcher|r",
                displayName = "|c2c5c8dS|r|c335e88u|r|c3a6184l|r|c42637f-|r|c49667bX|r|c506877a|r|c576b72n|r|c5e6d6e'|r|c657069s|r |c6d7265S|r|c747561o|r|c7b775cu|r|c827a58l|r |c897c53C|r|c907f4fa|r|c97814bt|r|c9f8446c|r|ca68642h|r|cad893de|r|cb48b39r|r",
                author = "|c2c5c8dLykeion|r",
                version = "|cb48b39" .. SX.version .. "|r",
                slashCommand = "/sulxan",
                registerForRefresh = true
            }
        end
    
        local dataTable = {
            {
                type = "button",
                name = GetString(SI_INTERFACE_OPTIONS_FRAMERATE_LATENCY_POSITION_RESET),
                func = function()
                    SV.controlCenterX = 0
                    SV.controlCenterY = 0
                    SulXanControl:ClearAnchors()
                    SulXanControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)
                end
            },
            {
                type = "slider",
                name = GetString(SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_HORIZONTAL_OFFSET),
                min = 0,
                max = 4000,
                step = 50,
                getFunc = function()
                    return SV.controlCenterX
                end,
                setFunc = function(value)
                    SV.controlCenterX = value
                    SulXanControl:ClearAnchors()
                    SulXanControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)
                end,
                default = 0
            },
            {
                type = "slider",
                name = GetString(SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_VERTICAL_OFFSET),
                min = 0,
                max = 3000,
                step = 50,
                getFunc = function()
                    return SV.controlCenterY
                end,
                setFunc = function(value)
                    SV.controlCenterY = value
                    SulXanControl:ClearAnchors()
                    SulXanControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)
                end,
                default = 0
            },
        }
        local settingPanel = LAM:RegisterAddonPanel(SX.name .. "Options", menuOptions)
        LAM:RegisterOptionControls(SX.name .. "Options", dataTable)

        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
            if panel ~= settingPanel then
                return
            end
            SulXanControl:SetHidden(false)
        end)
    
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
            if panel ~= settingPanel then
                return
            end
            SulXanControl:SetHidden(true)
            stFragment:SetConditional(function()
                return 
                sxSlotted and inCombat or 
                buffEnd - GetGameTimeSeconds() > 0 or
                soulEnd - GetGameTimeSeconds() > 0
            end)
            stFragment:Refresh()
        end)
    end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- SLASH_COMMANDS["/sulxan"] = function(str)

-- end

-- SLASH_COMMANDS["/sulxan combatshow"] = function(str)

-- end
