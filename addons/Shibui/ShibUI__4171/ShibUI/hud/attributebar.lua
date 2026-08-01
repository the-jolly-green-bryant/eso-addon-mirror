--------------------------------------------------
-- ShibUI Attribute Bar Module
--------------------------------------------------

local SUI = SUI
local sv

SUI.AttributeBar = SUI.AttributeBar or {}
local AttributeBar = SUI.AttributeBar

local Log = function(...) SUI.Debug:Log("Attribute Bar", ...) end

---------------------------------------------------
-- Texture Redirection for Attribute Bar
---------------------------------------------------
local blankTexture = "/esoui/art/icons/heraldrycrests_misc_blank_01.dds"
local basePath = "/esoui/art/unitattributevisualizer/"

local defaultTextures = {
    basePath .. "attributebar_dynamic_bg.dds",
    basePath .. "attributebar_dynamic_frame.dds",
    basePath .. "attributebar_dynamic_increasedarmor_bg.dds",
    basePath .. "attributebar_dynamic_increasedarmor_frame.dds",
    basePath .. "attributebar_small_base_center.dds",
    basePath .. "attributebar_small_base.dds",
    basePath .. "attributebar_small_frame_center.dds",
    basePath .. "attributebar_small_frame.dds",
}

local function BlankTextures()
    for _, tex in ipairs(defaultTextures) do
        RedirectTexture(tex, blankTexture)
    end
end

local function DefaultTextures()
    for _, tex in ipairs(defaultTextures) do
        RedirectTexture(tex, tex)
    end
end

---------------------------------------------------
-- Attribute Bar Size and Layout Control
---------------------------------------------------

-- ESO default width values from ZO_UnitVisualizer_ShrinkExpandModule
local SHRUNK_WIDTH = 141
local NORMAL_WIDTH = 237
local EXPANDED_WIDTH = 323

local pBar = ZO_PlayerAttribute
local hpBar = ZO_PlayerAttributeHealth
local mpBar = ZO_PlayerAttributeMagicka
local spBar = ZO_PlayerAttributeStamina
local mountBar = ZO_PlayerAttributeMountStamina

local bars = { hpBar, mpBar, spBar }

-- Get individual bar controls for manipulation
local hpBarLeft = GetControl(hpBar, "BarLeft")
local hpBarRight = GetControl(hpBar, "BarRight")
local mpBarSingle = GetControl(mpBar, "Bar")
local spBarSingle = GetControl(spBar, "Bar")
local mountBarSingle = mountBar and GetControl(mountBar, "Bar")

---------------------------------------------------
-- Bar Size Control
---------------------------------------------------

local function LockBarWidth(bar, width)
    bar:SetWidth(width)
end

local function OnAttributeBarRelevantUpdate()
    if sv and sv.attributeBarSize then
        AttributeBar:ApplySize(sv.attributeBarSize)
    end
end

function AttributeBar:ApplySize(mode)
    if mode == "default" then
        EVENT_MANAGER:UnregisterForEvent("ShibUI_AttributeBarLock_Stats", EVENT_STATS_UPDATED)
        EVENT_MANAGER:UnregisterForEvent("ShibUI_AttributeBarLock_Power", EVENT_POWER_UPDATE)
        
        for _, bar in ipairs(bars) do
            bar:SetWidth(NORMAL_WIDTH)
        end
    elseif mode == "normal" then
        EVENT_MANAGER:RegisterForEvent("ShibUI_AttributeBarLock_Stats", EVENT_STATS_UPDATED, OnAttributeBarRelevantUpdate)
        EVENT_MANAGER:RegisterForEvent("ShibUI_AttributeBarLock_Power", EVENT_POWER_UPDATE, function(_, unitTag)
            if unitTag == "player" then
                OnAttributeBarRelevantUpdate()
            end
        end)
        
        for _, bar in ipairs(bars) do
            LockBarWidth(bar, NORMAL_WIDTH)
        end
    elseif mode == "expanded" then
        EVENT_MANAGER:RegisterForEvent("ShibUI_AttributeBarLock_Stats", EVENT_STATS_UPDATED, OnAttributeBarRelevantUpdate)
        EVENT_MANAGER:RegisterForEvent("ShibUI_AttributeBarLock_Power", EVENT_POWER_UPDATE, function(_, unitTag)
            if unitTag == "player" then
                OnAttributeBarRelevantUpdate()
            end
        end)
        
        for _, bar in ipairs(bars) do
            LockBarWidth(bar, EXPANDED_WIDTH)
        end
    end
end

---------------------------------------------------
-- Bar Layout Control
---------------------------------------------------

local function ClearAllBarAnchors()
    for _, bar in ipairs(bars) do
        bar:ClearAnchors()
    end
end

local function SetLayoutDefault()
    ClearAllBarAnchors()
    
    hpBar:SetAnchor(CENTER, pBar, CENTER, 0, 0)
    mpBar:SetAnchor(RIGHT, pBar, LEFT, 237, 0)
    spBar:SetAnchor(LEFT, pBar, RIGHT, -237, 0)
    
    pBar:ClearAnchors()
    pBar:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -74)
end

local function SetLayoutShibui()
    ClearAllBarAnchors()
    
    hpBar:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -94)
    mpBar:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOM, -200, -94)
    spBar:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOM, 200, -94)
end

local function SetLayoutPyramid()
    ClearAllBarAnchors()
    
    hpBar:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -115)
    mpBar:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOM, -5, -90)
    spBar:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOM, 5, -90)
end

local function SetLayoutStacked()
    ClearAllBarAnchors()
    
    -- Stack all bars vertically with health on top, centered
    hpBar:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -120)
    spBar:SetAnchor(TOP, hpBar, BOTTOM, 0, 2)
    mpBar:SetAnchor(TOP, spBar, BOTTOM, 0, 2)
    
    -- Mount stamina bar positioned to the side when mounted
    if mountBar then
        mountBar:ClearAnchors()
        mountBar:SetAnchor(LEFT, spBar, RIGHT, 10, 0)
    end
    
    -- Set bar heights to half
    local halfHeight = 15
    hpBar:SetHeight(halfHeight)
    spBar:SetHeight(halfHeight)
    mpBar:SetHeight(halfHeight)
    if mountBar then
        mountBar:SetHeight(halfHeight)
    end
    
    -- Set sub-bar controls heights
    if hpBarLeft then hpBarLeft:SetHeight(halfHeight) end
    if hpBarRight then hpBarRight:SetHeight(halfHeight) end
    if spBarSingle then spBarSingle:SetHeight(halfHeight) end
    if mpBarSingle then mpBarSingle:SetHeight(halfHeight) end
    if mountBarSingle then mountBarSingle:SetHeight(halfHeight) end
end

function AttributeBar:ApplyLayout(layout)
    if layout == "default" then
        SetLayoutDefault()
    elseif layout == "shibui" then
        SetLayoutShibui()
    elseif layout == "pyramid" then
        SetLayoutPyramid()
    elseif layout == "stacked" then
        SetLayoutStacked()
    end
end

---------------------------------------------------
-- Initialization
---------------------------------------------------
function AttributeBar:Initialize()
    sv = SUI.SavedVars.saved
    
    BlankTextures()
    
    self:ApplySize(sv.attributeBarSize)
    self:ApplyLayout(sv.attributeBarLayout)
    
    EVENT_MANAGER:RegisterForEvent("ShibUI_AttributeBarLayout", EVENT_STATS_UPDATED, function()
        AttributeBar:ApplyLayout(sv.attributeBarLayout)
    end)
    
    Log("Initialized")
end