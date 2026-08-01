-- Function to handle jumping to the house
local function EquinoxeGuildHall()
    local accountName = GetDisplayName()
    if accountName == "@LadyChiv" then
        RequestJumpToHouse(69)
    else
        JumpToSpecificHouse("@LadyChiv", 69)
    end
end

-- Function to show tooltip on mouse enter
local function ShowTooltip()
    InitializeTooltip(InformationTooltip, IconoxeGH, TOPRIGHT, 90, -6, BOTTOMRIGHT)
    SetTooltipText(InformationTooltip, "|cc8831bMaison de guilde Equinoxe|r")
end

-- Function to hide tooltip on mouse exit
local function HideTooltip()
    ClearTooltip(InformationTooltip)
end

-- Function to initialize the addon
local function Iconoxe_Initialize(event, addonName)
    -- Only initialize if it's our addon loading
    if addonName ~= "Iconoxe" then return end

    -- Unregister the event as we only need it once
    EVENT_MANAGER:UnregisterForEvent("Iconoxe", EVENT_ADD_ON_LOADED)

    -- Check if control already exists to avoid duplicate creation
    if not IconoxeGH then
        -- Create the button/icon
        IconoxeGH = WINDOW_MANAGER:CreateControl("EquinoxeGuildHall", ZO_ChatWindow, CT_BUTTON)
        IconoxeGH:SetDimensions(32, 32)
        IconoxeGH:SetHidden(false)
        IconoxeGH:SetNormalTexture("Iconoxe/imgs/Equinoxe.dds")
        IconoxeGH:SetHandler("OnClicked", function() EquinoxeGuildHall() end)
        IconoxeGH:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 300, 6)
        
        -- Add tooltip handlers
        IconoxeGH:SetHandler("OnMouseEnter", ShowTooltip)
        IconoxeGH:SetHandler("OnMouseExit", HideTooltip)
    end
end

-- Register the event to initialize the addon
EVENT_MANAGER:RegisterForEvent("Iconoxe", EVENT_ADD_ON_LOADED, Iconoxe_Initialize)