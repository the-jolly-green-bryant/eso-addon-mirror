DifficultyIndicator = {}
DifficultyIndicator.name = "DifficultyIndicator"

DifficultyIndicator.variableVersion = 1
DifficultyIndicator.defaults = {
    DisplayOutside = false,
    Size = 48,
    Opacity = 50,
    Left = 0,
    Top = 0
}

local veteranIcon = "/esoui/art/tutorial/gamepad/gp_lfg_veteranldungeon.dds"
local normalIcon = "/esoui/art/tutorial/gamepad/gp_lfg_normaldungeon.dds"

function DifficultyIndicator:Initialize()    
    DifficultyIndicator.savedVariables = ZO_SavedVars:NewAccountWide("DifficultyIndicatorVars", DifficultyIndicator.variableVersion, nil, DifficultyIndicator.defaults)

    DifficultyIndicator.CreateSettings()

    DifficultyIndicatorUIIcon:SetHidden(true)
    DifficultyIndicator.UpdateDifficulty()
    DifficultyIndicator.SetPosition()
    DifficultyIndicator.SetSize()
    DifficultyIndicator.SetOpacity()

    DifficultyIndicator.fragment = ZO_HUDFadeSceneFragment:New(DifficultyIndicatorUI)
    HUD_SCENE:AddFragment(DifficultyIndicator.fragment)
    HUD_UI_SCENE:AddFragment(DifficultyIndicator.fragment)

    EVENT_MANAGER:RegisterForEvent(DifficultyIndicator.name, EVENT_ZONE_CHANGED, DifficultyIndicator.UpdateDifficulty)
    EVENT_MANAGER:RegisterForEvent(DifficultyIndicator.name, EVENT_VETERAN_DIFFICULTY_CHANGED, DifficultyIndicator.UpdateDifficulty)
    EVENT_MANAGER:RegisterForEvent(DifficultyIndicator.name, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, DifficultyIndicator.UpdateDifficulty)
    EVENT_MANAGER:RegisterForEvent(DifficultyIndicator.name, EVENT_GROUP_MEMBER_JOINED, function(_event, _charName, _displayName, localPlayer)
        if not localPlayer then return end
        DifficultyIndicator.UpdateDifficulty()
    end)
end

function DifficultyIndicator.OnAddOnLoaded(_event, addonName)
    if addonName == DifficultyIndicator.name then
        EVENT_MANAGER:UnregisterForEvent(DifficultyIndicator.name, EVENT_ADD_ON_LOADED)
        DifficultyIndicator:Initialize()
    end
end

function DifficultyIndicator.UpdateDifficulty(_event)
    local difficulty = DifficultyIndicator.GetDifficulty()
    DifficultyIndicator.SetDifficulty(difficulty)
end

function DifficultyIndicator.GetDifficulty()
    local difficulty = GetCurrentZoneDungeonDifficulty()
    if difficulty == DUNGEON_DIFFICULTY_NONE then
        if DifficultyIndicator.savedVariables.DisplayOutside == false then
            return difficulty
        end

        local groupSize = GetGroupSize()
        if groupSize == 0 then
            if IsUnitUsingVeteranDifficulty('player') == true then
                difficulty = DUNGEON_DIFFICULTY_VETERAN
            else
                difficulty = DUNGEON_DIFFICULTY_NORMAL
            end
        elseif IsGroupUsingVeteranDifficulty() == true then
            difficulty = DUNGEON_DIFFICULTY_VETERAN
        else
            difficulty = DUNGEON_DIFFICULTY_NORMAL
        end
    end

    return difficulty
end

function DifficultyIndicator.SetDifficulty(difficulty)
    if difficulty == DUNGEON_DIFFICULTY_VETERAN then
        DifficultyIndicatorUIIcon:SetTexture(veteranIcon)
    elseif difficulty == DUNGEON_DIFFICULTY_NORMAL then
        DifficultyIndicatorUIIcon:SetTexture(normalIcon)
    end

    if difficulty == DUNGEON_DIFFICULTY_NONE and DifficultyIndicator.savedVariables.DisplayOutside == false then
        DifficultyIndicatorUIIcon:SetHidden(true)
    else
        DifficultyIndicatorUIIcon:SetHidden(false)
    end
end

function DifficultyIndicator.CreateSettings()
    local LAM = LibAddonMenu2
    local panelName = DifficultyIndicator.name .. "Panel"

    local panelData = {
        type = "panel",
        name = "Difficulty Indicator",
        author = "@Jarva [EU]",
        registerForDefaults = true
    }

    local panel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Display Outside Dungeons",
            default = DifficultyIndicator.savedVariables.DisplayOutside,
            getFunc = function() return DifficultyIndicator.savedVariables.DisplayOutside end,
            setFunc = function(value)
                DifficultyIndicator.savedVariables.DisplayOutside = value
                DifficultyIndicator.UpdateDifficulty()
            end
        },
        {
            type = "slider",
            name = "Size",
            min = 8,
            max = 128,
            step = 8,
            default = DifficultyIndicator.savedVariables.Size,
            getFunc = function() return DifficultyIndicator.savedVariables.Size end,
            setFunc = function(value)
                DifficultyIndicator.savedVariables.Size = value
                DifficultyIndicator.SetSize(value)
            end
        },
        {
            type = "slider",
            name = "Opacity",
            min = 0,
            max = 100,
            step = 1,
            default = DifficultyIndicator.savedVariables.Opacity,
            getFunc = function() return DifficultyIndicator.savedVariables.Opacity end,
            setFunc = function(value)
                DifficultyIndicator.savedVariables.Opacity = value
                DifficultyIndicator.SetOpacity(value)
            end
        }
    }

    LAM:RegisterOptionControls(panelName, optionsData)
end

function DifficultyIndicator.SavePosition()
    DifficultyIndicator.savedVariables.Left = DifficultyIndicatorUILabelBG:GetLeft()
    DifficultyIndicator.savedVariables.Top = DifficultyIndicatorUILabelBG:GetTop()
end

function DifficultyIndicator.SetPosition(left, top, size)
    if left == nil or top == nil then
        left = DifficultyIndicator.savedVariables.Left
        top = DifficultyIndicator.savedVariables.Top
    end

    DifficultyIndicatorUILabelBG:ClearAnchors()
    DifficultyIndicatorUILabelBG:SetAnchor(TOPLEFT, DifficultyIndicatorUI, CENTER, left, top)
end

function DifficultyIndicator.SetSize(size)
    if size == nil then
        size = DifficultyIndicator.savedVariables.Size
    end

    DifficultyIndicatorUILabelBG:SetWidth(size)
    DifficultyIndicatorUILabelBG:SetHeight(size)
    DifficultyIndicatorUIIcon:SetWidth(size)
    DifficultyIndicatorUIIcon:SetHeight(size)
end

function DifficultyIndicator.SetOpacity(opacity)
    if opacity == nil then
        opacity = DifficultyIndicator.savedVariables.Opacity
    end

    if opacity > 0 then
        opacity = opacity / 100
    end

    DifficultyIndicatorUIIcon:SetAlpha(opacity)
end

EVENT_MANAGER:RegisterForEvent(DifficultyIndicator.name, EVENT_ADD_ON_LOADED, DifficultyIndicator.OnAddOnLoaded)
