NikaBraveGUHall = NikaBraveGUHall or {}

function NikaBraveGUHall_Initialize(eventCode, addOnName)

  if (addOnName ~= "NikaBraveGUHall") then return end

    NBtextures = "NikaBraveGUHall/nb.dds"
    MHtextures = "NikaBraveGUHall/MyHome.dds"

    -- textures for NYear days

    local ld = os.date("*t")
    if (ld.month == 12 and ld.day >= 17) or (ld.month == 1 and ld.day <= 15) then
        -- New year (ng)
        NBtextures = "NikaBraveGUHall/nb_ng.dds"
        MHtextures = "NikaBraveGUHall/MyHome_ng.dds"
    end

    -- end textures for NYear days

    local button1 =  WINDOW_MANAGER:CreateControl("NikaBraveGUHall1", ZO_ChatWindow, CT_BUTTON)

    button1:SetDimensions(30, 30)
    button1:SetAnchor(TOPRight, ZO_ChatWindowOptions, TOPRight, -130, 0)
    button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "@NikaBrave") end)
    button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)

    button1:SetNormalTexture(NBtextures)
    button1:SetPressedTexture(NBtextures)
    button1:SetMouseOverTexture(NBtextures)

    button1:SetHandler("OnClicked", function(...)
                        JumpToHouse("@NikaBrave")
            end)

    local button2 =  WINDOW_MANAGER:CreateControl("NikaBraveGUHall2", ZO_ChatWindow, CT_BUTTON)

    button2:SetDimensions(30, 30)
    button2:SetAnchor(TOPRight, ZO_ChatWindowOptions, TOPRight, -90, 0)
    button2:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, GetString(MH_text_0)) end)
    button2:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)

    button2:SetNormalTexture(MHtextures)
    button2:SetPressedTexture(MHtextures)
    button2:SetMouseOverTexture(MHtextures)

    button2:SetHandler("OnClicked", function(...)
--                      button menu
			ClearMenu()
			AddCustomMenuItem(GetString(MH_text_1), function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(GetString(MH_text_06) .. " - " .. GetString(MH_text_in),  function() RequestJumpToHouse(6, true) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(GetString(MH_text_13) .. " - " .. GetString(MH_text_out), function() RequestJumpToHouse(13, true) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(GetString(MH_text_47) .. " - " .. GetString(MH_text_out), function() RequestJumpToHouse(47, true) end)
			ShowMenu()
            end)
end
EVENT_MANAGER:RegisterForEvent("NikaBraveGUHallLoaded", EVENT_ADD_ON_LOADED, function(...) 	NikaBraveGUHall_Initialize(...) 	end)
