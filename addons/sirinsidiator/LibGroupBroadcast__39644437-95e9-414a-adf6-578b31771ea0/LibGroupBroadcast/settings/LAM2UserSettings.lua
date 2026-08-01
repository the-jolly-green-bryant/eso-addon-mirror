local internal = LibGroupBroadcast.internal

--- @class LAM2UserSettings
--- @field New fun(self: LAM2UserSettings, options?: table): LAM2UserSettings Create a new LAM2UserSettings object and optionally initialize it with options.
local LAM2UserSettings = internal.class.UserSettings:Subclass()
internal.class.LAM2UserSettings = LAM2UserSettings

--- @param options? table
function LAM2UserSettings:Initialize(options)
    self.options = options or {}
end

--- Append a LibAddonMenu-2.0 option to the user settings.
---@param option table
function LAM2UserSettings:AddOption(option)
    self.options[#self.options + 1] = option
end

--- Get the LibAddonMenu-2.0 options.
--- @return table options The LibAddonMenu-2.0 options.
function LAM2UserSettings:GetOptions()
    return self.options
end
