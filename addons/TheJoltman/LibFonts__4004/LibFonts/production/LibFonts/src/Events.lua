--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function Test()  -- JMH DEBUG
    LibFonts.Window = GetWindowManager()
    LibFonts.InfoText = LibFonts.Window:CreateTopLevelWindow("LibFontsDisplayBar")
    LibFonts.InfoText:ClearAnchors()
    LibFonts.InfoText:SetDimensions(500, 50)
    LibFonts.InfoText:SetAnchor(0, GuiRoot, nil, 0, 0)
    LibFonts.InfoText.Text = LibFonts.Window:CreateControl("LibFonts.InfoText", LibFonts.InfoText, CT_LABEL)
    LibFonts.InfoText.Text:SetAnchor(CENTER, LibFonts.InfoText, CENTER, 0, 0)
    LibFonts.InfoText.Text:SetFont(LibFonts.GetFont(LibFonts.FontStyle.Blade_Runner).."|".."26".."|shadow")
    LibFonts.InfoText:SetClampedToScreen(true)
    LibFonts.InfoText.Text:SetText(LibFonts.GetFontCount().." fonts available.")
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnLoad(Event, AddonName)

    if AddonName ~= LibFonts.AddName then return end

    LibFonts.Logger:Debug("Fonts Initialized")

    -- Note: All slash commands must be lower case
    SLASH_COMMANDS["/lfversion"] = function() LibFonts.DisplayVersionInfo() end

    EVENT_MANAGER:RegisterForEvent(LibFonts.AddName.."_Player", EVENT_PLAYER_ACTIVATED,
            function()

                LibFonts.Logger:Debug("Initialization complete, "..LibFonts.GetFontCount().." fonts available.")

                --Test() -- JMH DEBUG

                -- Deregister Player Event No Longer Needed
                EVENT_MANAGER:UnregisterForEvent(LibFonts.AddName.."_Player", EVENT_PLAYER_ACTIVATED)

            end)

    EVENT_MANAGER:UnregisterForEvent(LibFonts.AddName.."_OnLoad", EVENT_ADD_ON_LOADED)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(LibFonts.AddName.."_OnLoad", EVENT_ADD_ON_LOADED, OnLoad)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------