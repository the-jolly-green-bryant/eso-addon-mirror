-- $Revision: 1.20 $
-- Author: Cal, Yskaya

local ADDON_NAME = "GN_GuildHall"
local GUILD_MASTER_ID = "@RubyRedorDead" 
local HOUSE_ID = 98 -- Fogbreak Lighthouse

-- 1. LOCAL HELPER: Travel logic
local function TravelToGuildHall()
    PlaySound(SOUNDS.HOUSING_JUMP_TO_HOUSE)
    d("|cFF0000[GN]|r Traveling to the GN Guild Village...")

    if GetDisplayName() == GUILD_MASTER_ID then
        RequestJumpToHouse(HOUSE_ID)
    else
        JumpToHouse(GUILD_MASTER_ID)
    end
end

-- 2. LOCAL FUNCTION: UI Creation (Fixed "Global Leak")
local function CreateGNButton()
    local parent = ZO_GuildHome
    if not parent then return end

    -- Use local references for UI controls
    local btn = _G["GN_GuildHall_Button"] or WINDOW_MANAGER:CreateControl("GN_GuildHall_Button", parent, CT_BUTTON)
    
    btn:SetDimensions(128, 128)
    btn:ClearAnchors()
    btn:SetAnchor(TOPLEFT, parent, TOPLEFT, 40, 540) 
    
    local texturePath = "GN_GuildHall/GuildHallButton.dds"
    btn:SetNormalTexture(texturePath)
    btn:SetAlpha(0.8) 
    
    btn:SetDrawLayer(DL_OVERLAY)
    btn:SetDrawTier(DT_HIGH)
    btn:SetHidden(false)
    btn:SetMouseEnabled(true)

    btn:SetHandler("OnMouseEnter", function(self)
        self:SetAlpha(1.0) 
        PlaySound(SOUNDS.QUICKSLOT_MOUSEOVER)
    end)

    btn:SetHandler("OnMouseExit", function(self)
        self:SetAlpha(0.8)
    end)

    btn:SetHandler("OnClicked", function()
        TravelToGuildHall()
    end)

    local lbl = _G["GN_GuildHall_Label"] or WINDOW_MANAGER:CreateControl("GN_GuildHall_Label", parent, CT_LABEL)
    lbl:SetFont("ZoFontWinH4")
    lbl:SetText("Girls Night Guild Village")
    lbl:SetColor(1, 0, 0, 1) 
    lbl:ClearAnchors()
    lbl:SetAnchor(TOP, btn, BOTTOM, 0, 5) 
end

-- 3. INITIALIZATION
local function OnPlayerActivated()
    if GUILD_HOME_SCENE then
        GUILD_HOME_SCENE:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN then
                -- Creating button when guild home scene opens
                CreateGNButton()
            end
        end)
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    
    -- Setup the scene callback once player is ready
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)