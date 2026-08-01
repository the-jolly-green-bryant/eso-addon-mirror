--[[
    STARS MODULE TEMPLATE - PROJECT CONFIGURATION

    This is the only file that the reusable STARSConnect folder reads for
    project identity, SavedVariables and LibSTARSConnect registration values.

    Edit the values in PROJECT SETTINGS when creating a new addon.
    Do not move this file inside STARSConnect; it must load first.
]]

STARSModuleBootstrap = STARSModuleBootstrap or {}
local Bootstrap = STARSModuleBootstrap

local Config = {
    -- =============================================================
    -- PROJECT SETTINGS - EDIT THESE FOR EACH NEW ADDON
    -- =============================================================
    addonName = "ProjectName",
    namespace = "ProjectName",
    displayName = "Project Name",
    version = "0.0.1",

    savedVariablesName = "ProjectName_SV",
    savedVariablesVersion = 1,

    module = {
        id = "project_name",
        name = "Project Name",
        apiVersion = 1,
        presentationType = "game", -- game | correspondence | library
        description = "Describe what this connected module adds to STARS.",
        defaultActive = true,
    },

    diagnosticsPrefix = "Project Name",

    records = {
        historyLimit = 25,
    },

    hud = {
        enabled = false,
    },

    presentation = {
        title = "PROJECT NAME",
        subtitle = "STARS CONNECTED MODULE",
        emptyMessage = "Edit Project.lua to provide this module's presentation data.",
    },
}

local function IsIdentifier(value)
    return type(value) == "string" and value:match("^[%a_][%w_]*$") ~= nil
end

if not IsIdentifier(Config.namespace) then
    error("STARS module config: namespace must be a valid Lua identifier")
end
if type(Config.addonName) ~= "string" or Config.addonName == "" then
    error("STARS module config: addonName is required")
end
if type(Config.module.id) ~= "string" or Config.module.id == "" then
    error("STARS module config: module.id is required")
end

local Project = _G[Config.namespace] or {}
_G[Config.namespace] = Project

Project.Config = Config
Project.Defaults = Project.Defaults or {
    loaded = 0,
    settings = {
        diagnostics = false,
    },
    data = {
        records = {},
    },
}

-- The alias exists only while this addon's files are loading. Every reusable
-- STARSConnect file captures the project table locally, so multiple connected
-- addons can coexist without sharing runtime state.
Bootstrap.current = Project
