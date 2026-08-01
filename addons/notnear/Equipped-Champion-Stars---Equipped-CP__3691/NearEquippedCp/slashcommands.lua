local addon = NEAR_EC
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
NEAR_EC.slash_commands = {}

local LSC = LibSlashCommander or false

---register chat command either with LibSlashCommander or traditional
---@param command string
---@param callback function
---@param description string
function NEAR_EC.slash_commands.register(command, callback, description)
	if LSC then
		LSC:Register(command, function(option) callback(option) end, description)
	else
        if type(command) == "table" then
            for _, value in ipairs(command) do
                SLASH_COMMANDS[value] = function(option) callback(option) end
            end
        else
            SLASH_COMMANDS[command] = function(option) callback(option) end
        end
	end
end

local function toggleAndShowByType(showTypeFlag)
    addon.ASV[showTypeFlag] = not addon.ASV[showTypeFlag]
    addon.ShowByType()
end

local function toggleHideByType(hideTypeFlag)
    addon.ASV.hide[hideTypeFlag] = not addon.ASV.hide[hideTypeFlag]

    if hideTypeFlag == "inCombat" then
        addon.events.combat()
    else
        addon.events.menu()
    end

end

local function toggleTextAlignment()
    local labelAnchors = addon.ASV.labelAnchors

    local current = labelAnchors.point

    if current == TOPRIGHT then
        labelAnchors.point = TOPLEFT
        labelAnchors.relativePoint = BOTTOMLEFT
    else
        labelAnchors.point = TOPRIGHT
        labelAnchors.relativePoint = BOTTOMRIGHT
    end

    addon.SetAnchors()
    addon.ShowByType()
end

local function toggleLockUI()
    addon.ASV.lockUI = not addon.ASV.lockUI
    addon.lockUI()
end

function NEAR_EC.slash_commands.activateSlashCommands()
    local register = addon.slash_commands.register

    register({"/equippedcp", "/ecp"},   function(v) addon.ToggleGui() end,                      GetString(NEAREC_Toggle))
    register({"/ecpall", "/ecpa"},      function(v) toggleAndShowByType("show_all") end,        GetString(NEAREC_Toggle_a))
    register("/ecpc",                   function(v) toggleAndShowByType("show_craft") end,      GetString(NEAREC_Toggle_c))
    register("/ecpw",                   function(v) toggleAndShowByType("show_warfare") end,    GetString(NEAREC_Toggle_w))
    register("/ecpf",                   function(v) toggleAndShowByType("show_fitness") end,    GetString(NEAREC_Toggle_f))

    register("/ecp/combat",             function(v) toggleHideByType("inCombat") end,           GetString(NEAREC_Toggle_inCombat))
    register("/ecp/menu",               function(v) toggleHideByType("inMenu") end,             GetString(NEAREC_Toggle_inMenu))
    register("/ecp/lockui",             function(v) toggleLockUI() end,                         GetString(NEAREC_Toggle_lockui))

    -- If LAM is not loaded add options as commands
    if not LibAddonMenu2 then
        register("/ecp/align",          function(v) toggleTextAlignment() end,                  GetString(NEAREC_Toggle_align))
        register("/ecp/resetposition",  function(v) addon.ResetPos() end,                       GetString(NEAREC_am_resetpos_name))
    end

end
