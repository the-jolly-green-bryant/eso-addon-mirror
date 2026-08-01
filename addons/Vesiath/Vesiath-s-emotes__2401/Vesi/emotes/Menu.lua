V.Emotes.Menu = {
    Build = function(self)
        local options = {
            {
                type = "header",
                name = "|cFFFACD" .. "Emote Settings" .. "|r",
            },
            {
                type = "slider",
                name = "Emote Size",
                tooltip = "Change the size the emotes will be displayed at",
                default = V.Emotes.defaults.emoteSize,
                min = 18,
                max = 24,
                getFunc = function() return V.Emotes.sv.emoteSize end,
                setFunc = function(value) V.Emotes.sv.emoteSize = value end,
            },
            {
                type = "checkbox",
                name = "Welcome Message",
                tooltip = "Enables or disables the welcome message",
                default = V.Emotes.defaults.message,
                getFunc = function() return V.Emotes.sv.message end,
                setFunc = function(value) V.Emotes.sv.message = value end,
            },
        }
        V.Menu:RegisterOptionControls(options)
    end,
}