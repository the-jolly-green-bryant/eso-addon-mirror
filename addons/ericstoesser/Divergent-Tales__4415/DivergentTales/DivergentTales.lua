---@diagnostic disable: undefined-field
DivergentTales = {
    name = "DivergentTales",
    window = nil,
    sceneCallback = nil,
    savedVars = nil
}

local WINDOW_MANAGER = _G.WINDOW_MANAGER
local EVENT_MANAGER = _G.EVENT_MANAGER
local SLASH_COMMANDS = _G.SLASH_COMMANDS
local GuiRoot = _G.GuiRoot

local CT_TOPLEVELCONTROL = _G.CT_TOPLEVELCONTROL
local CT_CONTROL = _G.CT_CONTROL
local CT_TEXTURE = _G.CT_TEXTURE
local CT_LABEL = _G.CT_LABEL
local CT_BUTTON = _G.CT_BUTTON

local CENTER = _G.CENTER
local TOPLEFT = _G.TOPLEFT
local TOPRIGHT = _G.TOPRIGHT
local BOTTOM = _G.BOTTOM
local RIGHT = _G.RIGHT
local BOTTOMLEFT = _G.BOTTOMLEFT
local BOTTOMRIGHT = _G.BOTTOMRIGHT

local DL_OVERLAY = _G.DL_OVERLAY
local DT_HIGH = _G.DT_HIGH
local MOUSE_BUTTON_INDEX_LEFT = _G.MOUSE_BUTTON_INDEX_LEFT
local TEXT_WRAP_MODE_BASIC = _G.TEXT_WRAP_MODE_BASIC

local EVENT_ADD_ON_LOADED = _G.EVENT_ADD_ON_LOADED
local SCENE_SHOWN = _G.SCENE_SHOWN
local SCENE_HIDDEN = _G.SCENE_HIDDEN
local ZO_SavedVars = _G.ZO_SavedVars
local d = _G.d

local DEFAULT_SETTINGS = {
    autoOpenOnTribute = true,
}

local cheatSheetText = [[
|cFFD700[1] HOW DO I ACTUALLY WIN?|r
• |cBA55D3Score Victory:|r Reach 40 points (Prestige). If you end your turn at 40+ points, your opponent gets ONE final turn to try and beat your score. If they can't, you win!
• |cBA55D3Sudden Death:|r Reach 80 points. You win instantly.
• |c00FFFFPatron Victory:|r Make all 4 Patrons (the glowing faces on the right side of the screen) "Favor" you. You win instantly, no matter the score.

|cFFD700[2] WHAT AM I LOOKING AT? (THE PILES)|r
• |cFFFFFFThe Tavern (Center):|r 5 cards you can buy to make your deck stronger. 
• |cFFFFFFDraw Pile (Bottom Right):|r Where your turn's cards come from.
• |cFFFFFFCooldown Pile (Bottom Left):|r Where your played and newly bought cards go. When your Draw Pile is empty, this Cooldown pile shuffles and becomes your new Draw Pile!
• |cFFFFFFPatrons (Right Edge):|r Gods/Factions you can pay to do special tricks once per turn.

|cFFD700[3] THE RESOURCES (THE NUMBERS)|r
• |cFFFF00Coin (Gold):|r Used to buy cards from the Tavern or pay Patrons. |cFF0000(WARNING: Unused Coin disappears at the end of your turn! Spend it!)|r
• |cE22525Power (Red):|r Used to attack enemy Agents. |c00FF00(BONUS: Any Power you don't use automatically turns into Prestige/Score at the end of your turn!)|r
• |cBA55D3Prestige (Purple):|r Your actual score. This never resets.

|cFFD700[4] HOW TO PLAY A TURN|r
1. You automatically draw 5 cards. Play them! (Just click them all).
2. They will give you Coin or Power.
3. Use your Coin to buy better cards from the center Tavern. 
4. Hit "End Turn". All your played cards and bought cards go to your Cooldown pile to be drawn later.

|cFFD700[5] CARD TYPES & COMBOS|r
• |c00FFFFActions:|r Do their thing, then go to your Cooldown pile.
• |c00FFFFAgents (Shield icon):|r Stay on the board permanently! They block the enemy from scoring until the enemy uses Power to kill them.
• |c00FFFFContracts (Skull icon):|r Cards that activate *immediately* when you buy them from the Tavern, then disappear forever.
• |c00FFFFCombos:|r Playing 2 or more cards of the SAME COLOR in one turn makes them supercharged. Try to buy cards of only 1 or 2 colors to trigger massive combos!
]]

-- Function to create the UI programmatically (Robust & Beautiful)
local function CreateRulesWindow()
    if not WINDOW_MANAGER or not GuiRoot then
        return nil
    end

    local wm = WINDOW_MANAGER
    local tlw = wm:CreateControl(DivergentTales.name .. "Window", GuiRoot, CT_TOPLEVELCONTROL)

    -- Window Settings
    tlw:SetDimensions(450, 600)
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    tlw:SetClampedToScreen(true)
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(true)
    tlw:SetHidden(true)
    tlw:SetDrawLayer(DL_OVERLAY)
    tlw:SetDrawTier(DT_HIGH)
    tlw:SetDrawLevel(10)

    -- 1. Beautiful Backdrop (Standard ESO Style)
    local bg = wm:CreateControlFromVirtual("$(parent)Backdrop", tlw, "ZO_DefaultBackdrop")
    bg:SetAnchorFill()

    -- 2. Title Bar Area
    local titleBar = wm:CreateControl("$(parent)TitleBar", tlw, CT_CONTROL)
    titleBar:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
    titleBar:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, 0, 0)
    titleBar:SetHeight(40)
    titleBar:SetMouseEnabled(true)

    local titleBg = wm:CreateControlFromVirtual("$(parent)Backdrop", titleBar, "ZO_DefaultBackdrop")
    titleBg:SetAnchorFill()

    local titleGlow = wm:CreateControl("$(parent)Glow", titleBar, CT_TEXTURE)
    titleGlow:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    titleGlow:SetColor(1, 0.84, 0.3, 0.85)
    titleGlow:SetAnchor(TOPLEFT, titleBar, TOPLEFT, 8, 0)
    titleGlow:SetAnchor(TOPRIGHT, titleBar, TOPRIGHT, -8, 0)
    titleGlow:SetHeight(10)

    titleBar:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            tlw:StartMoving()
        end
    end)
    titleBar:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            tlw:StopMovingOrResizing()
        end
    end)

    -- Title Text
    local title = wm:CreateControl("$(parent)Label", titleBar, CT_LABEL)
    title:SetFont("ZoFontHeader2")
    title:SetText("Tales of Tribute Rules")
    title:SetColor(1, 0.93, 0.74, 1)
    title:SetAnchor(CENTER, titleBar, CENTER, 0, 0)

    -- Divider Line
    local divider = wm:CreateControl("$(parent)Divider", titleBar, CT_TEXTURE)
    divider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
    divider:SetAnchor(BOTTOM, titleBar, BOTTOM, 0, 0)
    divider:SetDimensions(430, 4)

    -- Close Button
    local closeBtn = wm:CreateControl("$(parent)Close", titleBar, CT_BUTTON)
    closeBtn:SetDimensions(25, 25)
    closeBtn:SetAnchor(RIGHT, titleBar, RIGHT, -10, 0)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
    closeBtn:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
    closeBtn:SetHandler("OnClicked", function() tlw:SetHidden(true) end)

    -- 3. Content Text
    local content = wm:CreateControl("$(parent)Content", tlw, CT_LABEL)
    content:SetFont("ZoFontGame")
    content:SetWrapMode(TEXT_WRAP_MODE_BASIC)
    content:SetText(cheatSheetText)
    content:SetAnchor(TOPLEFT, titleBar, BOTTOMLEFT, 20, 15)
    content:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -20, -15)
    content:SetColor(1, 1, 1, 1)

    return tlw
end

local function ToggleWindow()
    if DivergentTales.window then
        DivergentTales.window:SetHidden(not DivergentTales.window:IsHidden())
    end
end

local function IsAutoOpenEnabled()
    return DivergentTales.savedVars and DivergentTales.savedVars.autoOpenOnTribute == true
end

local function SetAutoOpenEnabled(enabled)
    if not DivergentTales.savedVars then
        return
    end

    DivergentTales.savedVars.autoOpenOnTribute = enabled == true
    if d then
        d(string.format("DivergentTales: Tribute auto-open %s.", enabled and "enabled" or "disabled"))
    end
end

local function OnTributeSceneStateChange(_, newState)
    if not DivergentTales.window then
        return
    end

    if newState == SCENE_SHOWN then
        if IsAutoOpenEnabled() then
            DivergentTales.window:SetHidden(false)
        end
    elseif newState == SCENE_HIDDEN then
        DivergentTales.window:SetHidden(true)
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= DivergentTales.name then return end
    if not EVENT_MANAGER then return end

    EVENT_MANAGER:UnregisterForEvent(DivergentTales.name, EVENT_ADD_ON_LOADED)

    if ZO_SavedVars then
        DivergentTales.savedVars = ZO_SavedVars:NewAccountWide("DivergentTalesSavedVars", 1, nil, DEFAULT_SETTINGS)
    else
        DivergentTales.savedVars = DEFAULT_SETTINGS
    end

    -- Initialize UI
    DivergentTales.window = CreateRulesWindow()
    if not DivergentTales.window then
        return
    end

    -- Register Slash Command
    if SLASH_COMMANDS then
        SLASH_COMMANDS["/totrules"] = ToggleWindow
        SLASH_COMMANDS["/totauto"] = function()
            SetAutoOpenEnabled(not IsAutoOpenEnabled())
        end
        SLASH_COMMANDS["/totautoon"] = function()
            SetAutoOpenEnabled(true)
        end
        SLASH_COMMANDS["/totautooff"] = function()
            SetAutoOpenEnabled(false)
        end
    end

    -- Handle Scene visibility
    local sceneManager = _G.SCENE_MANAGER
    local tributeScene = sceneManager and sceneManager:GetScene("tribute")
    if tributeScene then
        DivergentTales.sceneCallback = OnTributeSceneStateChange
        tributeScene:RegisterCallback("StateChange", DivergentTales.sceneCallback)
        if tributeScene:GetState() == SCENE_SHOWN then
            OnTributeSceneStateChange(nil, SCENE_SHOWN)
        end
    end
end

if EVENT_MANAGER and EVENT_ADD_ON_LOADED then
    EVENT_MANAGER:RegisterForEvent(DivergentTales.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end