SMMGuildhall = SMMGuildhall or {}

function SMMGuildhall_Initialize(eventCode, addOnName)

    if (addOnName ~= "SMMGuildhall") then return end
    
    local button1 =  WINDOW_MANAGER:CreateControl("SMMGuildHall", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(25, 25)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 25, 4)
    -- Below are tooltips
    button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "teleport to SMM's Guildhall") end)
    button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- End of tooltips
    button1:SetNormalTexture("SMMGuildhall/imgs/SkyrimUp.dds")
    button1:SetPressedTexture("SMMGuildhall/imgs/SkyrimDown.dds")
    button1:SetMouseOverTexture("SMMGuildhall/imgs/SkyrimOver.dds")
    
    
    button1:SetHandler("OnClicked", function(...)
        JumpToHouse("@richiemaldo")
    end)
    
    
            
end

EVENT_MANAGER:RegisterForEvent("SMMGuildhallLoaded", EVENT_ADD_ON_LOADED, function(...)     SMMGuildhall_Initialize(...)     end)