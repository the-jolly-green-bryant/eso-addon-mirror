local EM = V.Emotes.EmoteMenu

EM.MenuSettings = {
    Build = function(self)
        local options = {
            {
                type = "header",
                name = "|cFFFACD" .. "Emote Menu Settings" .. "|r",
            },
            {
                type = "colorpicker",
                name = "Background color",
                tooltip = "Change the background color",
                default = EM.defaults.backgroundColor,
                getFunc = function() return EM:GetColor(EM.sv.backgroundColor) end,
                setFunc = function(r,g,b,a) EM:SetBackgroundColor(r,g,b,a) end,
            },
            {
                type = "colorpicker",
                name = "Edge color",
                tooltip = "Change the edge color",
                default = EM.defaults.edgeColor,
                getFunc = function() return EM:GetColor(EM.sv.edgeColor) end,
                setFunc = function(r,g,b,a) EM:SetEdgeColor(r,g,b,a) end,
            },
            {
                type = "colorpicker",
                name = "Text color",
                tooltip = "Change the text color",
                default = EM.defaults.textColor,
                getFunc = function() return EM:GetColor(EM.sv.textColor) end,
                setFunc = function(r,g,b) EM:SetTextColor(r,g,b) end,
            }
        }
        V.Menu:RegisterOptionControls(options);
    end,
}