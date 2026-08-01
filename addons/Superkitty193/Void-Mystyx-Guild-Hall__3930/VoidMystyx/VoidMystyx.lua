-- 48 - Guild Hall
-- 66 - Arena


VoidMystyx = {
    name = "VoidMystyx",
    author = "@Superkitty193",
}

VoidMystyx.savedVars = {
    firstLoad = true,
    accountWide = true,
    vrxCoord = 360,
}

function VoidHall()
    local accountName = GetDisplayName()
    if accountName == "@SeraphRemiel" then
        RequestJumpToHouse(48)
    else
        JumpToSpecificHouse("@SeraphRemiel", 48)
    end
end

function VoidDuel()
    local accountName = GetDisplayName()
    if accountName == "@SeraphRemiel" then
        RequestJumpToHouse(66)
    else
        JumpToSpecificHouse("@SeraphRemiel", 66)
    end
end

function VoidMystyx_Initialize(eventCode, addOnName)
    if (addOnName ~= "VoidMystyx") then return end

    if VoidMystyx.savedVars.vrxCoord == nil then VoidMystyx.savedVars.vrxCoord = 360 end

    if VoidMystyx.savedVars.firstLoad then
        VoidMystyx.savedVars.firstLoad = false
        VoidMystyx.savedVars.vrxCoord = 360
    end

    voidIcon = WINDOW_MANAGER:CreateControl("VoidGuildHall", ZO_ChatWindow, CT_BUTTON)
    voidIcon:SetDimensions(25, 25)
    voidIcon:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control)
        SetTooltipText(InformationTooltip, "|c8831beSeraphRemiel's Guildhall|r")
    end)
    voidIcon:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)
    end)
    voidIcon:SetHandler("OnClicked", VoidHall)
    voidIcon:SetNormalTexture("VoidMystyx/imgs/Void.dds")
    voidIcon:SetHidden(false)
    voidIcon:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, VoidMystyx.savedVars.vrxCoord, 10)

    -- Create the Arena button/icon
--    arenaIcon = WINDOW_MANAGER:CreateControl("VoidGuildHall", ZO_ChatWindow, CT_BUTTON)
--    arenaIcon:SetDimensions(25, 25)
--    arenaIcon:SetHandler("OnMouseEnter", function(control)
--        InitializeTooltip(InformationTooltip, control)
--        SetTooltipText(InformationTooltip, "|c8831beSeraphRemiel's Guildhall|r")
--    end)
--    arenaIcon:SetHandler("OnMouseExit", function(control)
--        ClearTooltip(InformationTooltip)
--    end)
--    arenaIcon:SetHandler("OnClicked", VoidHall)
--    arenaIcon:SetNormalTexture("VoidMystyx/imgs/Void.dds")
--    arenaIcon:SetHidden(false)
--    arenaIcon:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, VoidMystyx.savedVars.vrxCoord, 10) 

    VoidMystyx_InitializeMenu()
end

local function ResetVoidIcon()
    VoidMystyx.savedVars.vrxCoord = 360 -- Reset to default position
    voidIcon:ClearAnchors()
    voidIcon:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, VoidMystyx.savedVars.vrxCoord, 10) -- Apply default anchor
end

local function UpdateVoidIconPosition(newCoord)
    VoidMystyx.savedVars.vrxCoord = newCoord
    voidIcon:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, VoidMystyx.savedVars.vrxCoord, 10)
end

function VoidMystyx_InitializeMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Void Mystyx Guildhall",
        author = VoidMystyx.author,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "slider",
            name = "Icon Position",
            tooltip = "Adjust the horizontal position of the Void Guild Hall icon.",
            min = 0,
            max = 800,
            step = 1,
            getFunc = function() return VoidMystyx.savedVars.vrxCoord end,
            setFunc = function(value) UpdateVoidIconPosition(value) end,
        },
        {
            type = "button",
            name = "Reset Icon Position",
            tooltip = "Resets the Void Guild Hall icon to its default position.",
            func = function() ResetVoidIcon() end,
        },
    }

    LAM:RegisterAddonPanel("VoidMystyxMenu", panelData)
    LAM:RegisterOptionControls("VoidMystyxMenu", optionsTable)
end


EVENT_MANAGER:RegisterForEvent("VoidMystyx", EVENT_ADD_ON_LOADED, VoidMystyx_Initialize)
