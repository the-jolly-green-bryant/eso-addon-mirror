WhatsLeft = {
    name = "WhatsLeft",
    version = "1.0.2",
    author = "@Complicative",
    mainFragment1 = ZO_SimpleSceneFragment:New(WhatsLeftTLC1),
    mainFragment2 = ZO_SimpleSceneFragment:New(WhatsLeftTLC2),
    mainFragment3 = ZO_SimpleSceneFragment:New(WhatsLeftTLC3),
    mainFragment4 = ZO_SimpleSceneFragment:New(WhatsLeftTLC4),
}

WhatsLeft.Settings = {}

WhatsLeft.Default = {
    Label1 = {
        ["OffsetX"] = 0,
        ["OffsetY"] = 0,
        ["Hidden"] = false,
        ["Text"] = "Left",
        ["Color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 0, ["a"] = 1 }
    },
    Label2 = {
        ["OffsetX"] = 200,
        ["OffsetY"] = 0,
        ["Hidden"] = false,
        ["Text"] = "Right",
        ["Color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 0, ["a"] = 1 }
    },
    Label3 = {
        ["OffsetX"] = 400,
        ["OffsetY"] = 0,
        ["Hidden"] = true,
        ["Text"] = "3",
        ["Color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 0, ["a"] = 1 }
    },
    Label4 = {
        ["OffsetX"] = 600,
        ["OffsetY"] = 0,
        ["Hidden"] = true,
        ["Text"] = "4",
        ["Color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 0, ["a"] = 1 }
    },

}

function WhatsLeft.SetHidden(fragment, hidden)
    -- Removes adds to Scenes (proper way to hide/unhide windows)
    if hidden then
        HUD_SCENE:RemoveFragment(fragment)
        HUD_UI_SCENE:RemoveFragment(fragment)
    end
    if not hidden then
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)
    end
end

local LAM2 = LibAddonMenu2

function WhatsLeft.saveLocation()
    WhatsLeft.Settings.Label1.OffsetX = WhatsLeftTLC1:GetLeft()
    WhatsLeft.Settings.Label1.OffsetY = WhatsLeftTLC1:GetTop()

    WhatsLeft.Settings.Label2.OffsetX = WhatsLeftTLC2:GetLeft()
    WhatsLeft.Settings.Label2.OffsetY = WhatsLeftTLC2:GetTop()

    WhatsLeft.Settings.Label3.OffsetX = WhatsLeftTLC3:GetLeft()
    WhatsLeft.Settings.Label3.OffsetY = WhatsLeftTLC3:GetTop()

    WhatsLeft.Settings.Label4.OffsetX = WhatsLeftTLC4:GetLeft()
    WhatsLeft.Settings.Label4.OffsetY = WhatsLeftTLC4:GetTop()
end

function WhatsLeft.OnAddOnLoaded(event, addonName)
    if addonName ~= WhatsLeft.name then
        return
    end
    -- SavedSettings
    WhatsLeft.Settings = ZO_SavedVars:NewAccountWide("WhatsLeftSettings", 7, nil, WhatsLeft.Default)
    WhatsLeftTLC1:ClearAnchors()
    WhatsLeftTLC1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WhatsLeft.Settings.Label1.OffsetX,
        WhatsLeft.Settings.Label1.OffsetY)

    WhatsLeftTLC2:ClearAnchors()
    WhatsLeftTLC2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WhatsLeft.Settings.Label2.OffsetX,
        WhatsLeft.Settings.Label2.OffsetY)

    WhatsLeftTLC3:ClearAnchors()
    WhatsLeftTLC3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WhatsLeft.Settings.Label3.OffsetX,
        WhatsLeft.Settings.Label3.OffsetY)

    WhatsLeftTLC4:ClearAnchors()
    WhatsLeftTLC4:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WhatsLeft.Settings.Label4.OffsetX,
        WhatsLeft.Settings.Label4.OffsetY)


    WhatsLeft.SetHidden(WhatsLeft.mainFragment1, WhatsLeft.Settings.Label1.Hidden)
    WhatsLeft.SetHidden(WhatsLeft.mainFragment2, WhatsLeft.Settings.Label2.Hidden)
    WhatsLeft.SetHidden(WhatsLeft.mainFragment3, WhatsLeft.Settings.Label3.Hidden)
    WhatsLeft.SetHidden(WhatsLeft.mainFragment4, WhatsLeft.Settings.Label4.Hidden)
    --[[ WhatsLeftTLC1:SetHidden(WhatsLeft.Settings.Label1.Hidden)
    WhatsLeftTLC2:SetHidden(WhatsLeft.Settings.Label2.Hidden)
    WhatsLeftTLC3:SetHidden(WhatsLeft.Settings.Label3.Hidden)
    WhatsLeftTLC4:SetHidden(WhatsLeft.Settings.Label4.Hidden) ]]
    WhatsLeftTLC1Label:SetText(WhatsLeft.Settings.Label1.Text)
    WhatsLeftTLC2Label:SetText(WhatsLeft.Settings.Label2.Text)
    WhatsLeftTLC3Label:SetText(WhatsLeft.Settings.Label3.Text)
    WhatsLeftTLC4Label:SetText(WhatsLeft.Settings.Label4.Text)

    WhatsLeftTLC1Label:SetColor(WhatsLeft.Settings.Label1.Color.r, WhatsLeft.Settings.Label1.Color.g,
        WhatsLeft.Settings.Label1.Color.b, WhatsLeft.Settings.Label1.Color.a)
    WhatsLeftTLC2Label:SetColor(WhatsLeft.Settings.Label2.Color.r, WhatsLeft.Settings.Label2.Color.g,
        WhatsLeft.Settings.Label2.Color.b, WhatsLeft.Settings.Label2.Color.a)
    WhatsLeftTLC3Label:SetColor(WhatsLeft.Settings.Label3.Color.r, WhatsLeft.Settings.Label3.Color.g,
        WhatsLeft.Settings.Label3.Color.b, WhatsLeft.Settings.Label3.Color.a)
    WhatsLeftTLC4Label:SetColor(WhatsLeft.Settings.Label4.Color.r, WhatsLeft.Settings.Label4.Color.g,
        WhatsLeft.Settings.Label4.Color.b, WhatsLeft.Settings.Label4.Color.a)

    local panelData = {
        type = "panel",
        name = "What's Left?",
        author = 'Complicative',
        version = WhatsLeft.version,
        website = "https://www.esoui.com/downloads/author-68201.html"
    }

    LAM2:RegisterAddonPanel("WhatsLeftOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "This addon adds 4 text labels that appear on your screen.\n" ..
            "Originally intended to display \"Left\" and \"Right\", but can be changed.\n" ..
            "\n/whatsleft will hide all labels instantly!"
    }

    optionsData[#optionsData + 1] = {
        type = "divider"
    }
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "Label 1"
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Text",
        tooltip = "Type in the text to show in this label",
        getFunc = function()
            return WhatsLeftTLC1Label:GetText()
        end,
        setFunc = function(text)
            WhatsLeft.Settings.Label1.Text = text
            WhatsLeftTLC1Label:SetText(text)
        end
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Colour",
        tooltip = "Pick the colour for the label",
        getFunc = function() return WhatsLeftTLC1Label:GetColor() end,
        setFunc = function(r, g, b, a)
            WhatsLeft.Settings.Label1.Color = { ["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a }
            WhatsLeftTLC1Label:SetColor(r, g, b, a)
        end,
        width = "full",
    }

    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enable the label?",
        getFunc = function()
            return not WhatsLeft.Settings.Label1.Hidden
        end,
        setFunc = function(value)
            WhatsLeft.Settings.Label1.Hidden = not value
            WhatsLeft.SetHidden(WhatsLeft.mainFragment1, not value)
            --[[ WhatsLeftTLC1:SetHidden(not value) ]]
        end
    }

    optionsData[#optionsData + 1] = {
        type = "divider"
    }
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "Label 2"
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Text",
        tooltip = "Type in the text to show in this label",
        getFunc = function()
            return WhatsLeftTLC2Label:GetText()
        end,
        setFunc = function(text)
            WhatsLeft.Settings.Label2.Text = text

            WhatsLeftTLC2Label:SetText(text)
        end
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Colour",
        tooltip = "Pick the colour for the label",
        getFunc = function() return WhatsLeftTLC2Label:GetColor() end,
        setFunc = function(r, g, b, a)
            WhatsLeft.Settings.Label2.Color = { ["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a }
            WhatsLeftTLC2Label:SetColor(r, g, b, a)
        end,
        width = "full",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enable the label?",
        getFunc = function()
            return not WhatsLeft.Settings.Label2.Hidden
        end,
        setFunc = function(value)
            WhatsLeft.Settings.Label2.Hidden = not value
            WhatsLeft.SetHidden(WhatsLeft.mainFragment2, not value)
        end
    }

    optionsData[#optionsData + 1] = {
        type = "divider"
    }
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "Label 3"
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Text",
        tooltip = "Type in the text to show in this label",
        getFunc = function()
            return WhatsLeftTLC3Label:GetText()
        end,
        setFunc = function(text)
            WhatsLeft.Settings.Label3.Text = text
            WhatsLeftTLC3Label:SetText(text)
        end
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Colour",
        tooltip = "Pick the colour for the label",
        getFunc = function() return WhatsLeftTLC3Label:GetColor() end,
        setFunc = function(r, g, b, a)
            WhatsLeft.Settings.Label3.Color = { ["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a }
            WhatsLeftTLC3Label:SetColor(r, g, b, a)
        end,
        width = "full",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enable the label?",
        getFunc = function()
            return not WhatsLeft.Settings.Label3.Hidden
        end,
        setFunc = function(value)
            WhatsLeft.Settings.Label3.Hidden = not value
            WhatsLeft.SetHidden(WhatsLeft.mainFragment3, not value)
        end
    }

    optionsData[#optionsData + 1] = {
        type = "divider"
    }
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "Label 4"
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Text",
        tooltip = "Type in the text to show in this label",
        getFunc = function()
            return WhatsLeftTLC4Label:GetText()
        end,
        setFunc = function(text)
            WhatsLeft.Settings.Label4.Text = text
            WhatsLeftTLC4Label:SetText(text)
        end
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Colour",
        tooltip = "Pick the colour for the label",
        getFunc = function() return WhatsLeftTLC4Label:GetColor() end,
        setFunc = function(r, g, b, a)
            WhatsLeft.Settings.Label4.Color = { ["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a }
            WhatsLeftTLC4Label:SetColor(r, g, b, a)
        end,
        width = "full",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enable the label?",
        getFunc = function()
            return not WhatsLeft.Settings.Label4.Hidden
        end,
        setFunc = function(value)
            WhatsLeft.Settings.Label4.Hidden = not value
            WhatsLeft.SetHidden(WhatsLeft.mainFragment4, not value)
        end
    }

    optionsData[#optionsData + 1] = {
        type = "description",
        text =
            "If this addon is a life changer, please say \"Thank you\" to @postthemelon on EU or check out her stream at twitch.tv/postthemelon.\n"
            ..
            "She is the one, who asked for this addon and I'm sure, she'll enjoy hearing from another left-right blind person :D"
    }

    LAM2:RegisterOptionControls("WhatsLeftOptions", optionsData)
end

EVENT_MANAGER:RegisterForEvent(WhatsLeft.name, EVENT_ADD_ON_LOADED, WhatsLeft.OnAddOnLoaded)

SLASH_COMMANDS["/whatsleft"] = function()
    WhatsLeft.Settings.Label1.Hidden = true
    WhatsLeft.Settings.Label2.Hidden = true
    WhatsLeft.Settings.Label3.Hidden = true
    WhatsLeft.Settings.Label4.Hidden = true

    WhatsLeft.SetHidden(WhatsLeft.mainFragment1, WhatsLeft.Settings.Label1.Hidden)
    WhatsLeft.SetHidden(WhatsLeft.mainFragment2, WhatsLeft.Settings.Label2.Hidden)
    WhatsLeft.SetHidden(WhatsLeft.mainFragment3, WhatsLeft.Settings.Label3.Hidden)
    WhatsLeft.SetHidden(WhatsLeft.mainFragment4, WhatsLeft.Settings.Label4.Hidden)
end
