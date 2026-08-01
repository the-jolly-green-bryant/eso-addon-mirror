-- namespace
NtrGH = NtrGH or {}
NtrGH.name = "NtrGuildHall"
NtrGH.version = "0.4"

-- eventmanager
local EM = GetEventManager()

local defaultSettings = {
    ["PanelLeft"] = 0,
    ["PanelTop"] = GuiRoot:GetHeight()/2,
}

-- get the ui element
local panel = GetControl("NtrGHPanel")
NtrGH.fragment = ZO_HUDFadeSceneFragment:New(panel, nil, 0)

local buttonyq = panel:GetNamedChild("ButtonPortToYQ")
local buttonmk = panel:GetNamedChild("ButtonPortToMK")
local buttonls = panel:GetNamedChild("ButtonPortToLS")
local buttonhw = panel:GetNamedChild("ButtonPortToHW")
local buttonme = panel:GetNamedChild("ButtonPortToMe")

-- utility
function NtrGH:OnClicked(control)
    if control.name ~= "player" then
        JumpToHouse(control.name)
    else
        RequestJumpToHouse(GetHousingPrimaryHouse())
    end
end

function NtrGH:OnMouseEnter(control)
    InitializeTooltip(InformationTooltip, control, TOP, 0, 0)
    SetTooltipText(InformationTooltip, control.tooltiptext)
end

function NtrGH:OnMouseExit(control)
    ClearTooltip(InformationTooltip)
end

function NtrGH:OnPanelMoveStop()
    NtrGH.savedVars.PanelLeft = panel:GetLeft()
    NtrGH.savedVars.PanelTop = panel:GetTop()
end

local function RestorePosition()
    local left = NtrGH.savedVars.PanelLeft
    local top = NtrGH.savedVars.PanelTop

    panel:ClearAnchors()
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Init
local function Initialize()

    NtrGH.savedVars = ZO_SavedVars:NewAccountWide("NtrGHSettings", 1, nil, defaultSettings)

    local hudUI = SCENE_MANAGER:GetScene("hudui")
    hudUI:AddFragment(NtrGH.fragment)

    panel:SetHidden(true)
    RestorePosition()

    buttonyq.name = "@blessing-quan"
    buttonyq.tooltiptext = "木桩 星座石 吸血鬼 转化台"
    buttonmk.name = "@markmarc"
    buttonmk.tooltiptext = "木桩 星座石 吸血鬼"
    buttonls.name = "@nvsleep"
    buttonls.tooltiptext = "木桩 星座石 套装台 转化台"
    buttonhw.name = "@Firedance1012"
    buttonhw.tooltiptext = "木桩 转化台 吸血鬼 迎宾套餐"
    buttonme.name = "player"
    buttonme.tooltiptext = "回到自己家"
end

local function OnAddonLoaded(event, addonName)

    if addonName == NtrGH.name then

        EM:UnregisterForEvent(NtrGH.name, EVENT_ADD_ON_LOADED)
        Initialize()

    end

end
-- register load event
EM:RegisterForEvent(NtrGH.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
