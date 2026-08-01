local LAM = LibAddonMenu2

V.Menu = {
    optionControls = {},

    RegisterOptionControls = function(self, options)
        for key, value in pairs(options) do
            table.insert(self.optionControls, value)
        end
    end,

    Build = function(self)
        local panel = {
            type = "panel",
            name = V.name,
            displayName = V.name,
            author = "|c0a9999Vesiath|r",
			version = "|c0a9999" .. V.version .. "|r",
        }

        local options = {}

        for key, value in pairs(self.optionControls) do
            table.insert(options, value)
        end

        LAM:RegisterAddonPanel(V.name .. "Options", panel)
        LAM:RegisterOptionControls(V.name .. "Options", options)
    end,
}