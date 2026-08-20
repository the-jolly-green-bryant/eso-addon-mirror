local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARS module: config.lua must load before Project.lua") end

--[[
    PROJECT-SPECIFIC CODE

    Keep addon behaviour here, or load additional project files before this
    file in the manifest. The STARSConnect folder should remain reusable.
]]

Project.entries = Project.entries or {
    {
        title = Project.Config.displayName,
        subtitle = "STARS CONNECTED MODULE",
        lines = {
            "The template is connected.",
            "Replace this example in Project.lua with your addon's data.",
        },
    },
}
Project.entryIndex = Project.entryIndex or 1

function Project:Initialize()
    -- Register project-specific events or prepare runtime data here.
end

function Project:OnPlayerActivated()
    -- Optional project-specific refresh hook.
end

function Project:GetEntryCount()
    return math.max(1, #self.entries)
end

function Project:ChangeEntry(delta)
    local count = self:GetEntryCount()
    self.entryIndex = ((tonumber(self.entryIndex) or 1) - 1 + delta) % count + 1
    return true
end

function Project:GetPresentationData()
    return self.entries[self.entryIndex] or self.entries[1]
end

function Project:GetActions()
    -- Return primary, secondary, tertiary and/or utility action definitions.
    return {}
end

function Project:Shutdown()
    -- Optional project cleanup hook.
end

Project.Controller:RegisterModule("Project", Project)
