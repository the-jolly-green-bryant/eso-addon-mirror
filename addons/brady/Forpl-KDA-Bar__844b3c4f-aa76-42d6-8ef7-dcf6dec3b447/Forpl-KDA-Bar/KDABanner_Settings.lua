--[[ Forpl KDA Bar - OPTIONAL settings panel (LibAddonMenu-2)

     If LibAddonMenu-2.0 is installed this registers a panel under
     Settings > Add-Ons (PC and console -- on console LAM bridges to
     LibHarvensAddonSettings). It lets you change the bar's position and toggle
     it on/off. If LAM is NOT installed we skip silently: the addon still works
     and is moved/shown via keybinds (Settings > Controls > Keybindings) or /kda.

     Console note: the color pickers and the mouse live-preview are PC-only,
     because the console (LHAS) bridge does not reliably support them. Position
     and the on/off toggle work everywhere.
--]]

local KDA = KDABanner

function KDA.SetupSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        return   -- no library: console keybinds / slash commands handle everything
    end

    local console = IsConsoleUI and IsConsoleUI()
    local screenW = GuiRoot:GetWidth()
    local screenH = GuiRoot:GetHeight()

    local panelData = {
        type                = "panel",
        name                = "Forpl KDA Bar",
        displayName         = "Forpl KDA Bar",
        author              = "brady",
        version             = KDA.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
    local panel = LAM:RegisterAddonPanel("KDABanner_Panel", panelData)

    -- live preview (show bar + outline while the panel is open) is a PC mouse aid
    if panel and not console and type(ZO_PreHookHandler) == "function" then
        ZO_PreHookHandler(panel, "OnEffectivelyShown",  function() KDA.SetPreview(true)  end)
        ZO_PreHookHandler(panel, "OnEffectivelyHidden", function() KDA.SetPreview(false) end)
    end

    local options = {
        {
            type = "description",
            text = "Move the bar with the X / Y sliders, or toggle it on/off below. " ..
                   "On PC you can also drag it with the mouse when unlocked.",
        },
        {
            type    = "checkbox",
            name    = "Show bar",
            getFunc = function() return not KDA.sv.hidden end,
            setFunc = function(v)
                KDA.sv.hidden = not v
                if KDA.window then KDA.window:SetHidden(KDA.sv.hidden) end
            end,
        },
        {
            type    = "header",
            name    = "Position & Size",
        },
        {
            type    = "slider",
            name    = "Horizontal position (X)",
            min     = 0, max = zo_floor(screenW), step = 1,
            getFunc = function() return zo_floor(KDA.sv.posLeft or (screenW / 2)) end,
            setFunc = function(v) KDA.sv.posLeft = v; KDA.ApplyPosition() end,
            width   = "full",
        },
        {
            type    = "slider",
            name    = "Vertical position (Y)",
            min     = 0, max = zo_floor(screenH), step = 1,
            getFunc = function() return zo_floor(KDA.sv.posTop or 110) end,
            setFunc = function(v) KDA.sv.posTop = v; KDA.ApplyPosition() end,
            width   = "full",
        },
        {
            type    = "slider",
            name    = "Size (%)",
            min     = 50, max = 250, step = 5,
            getFunc = function() return zo_floor((KDA.sv.scale or 1) * 100) end,
            setFunc = function(v) KDA.sv.scale = v / 100; KDA.ApplyScale() end,
        },
        {
            type    = "checkbox",
            name    = "Lock position",
            tooltip = "When locked the bar is click-through and can't be dragged.",
            getFunc = function() return KDA.sv.locked end,
            setFunc = function(v) KDA.SetLocked(v) end,
        },
    }

    -- Color pickers: PC only (LHAS bridge on console doesn't support them well).
    if not console then
        options[#options + 1] = { type = "header", name = "Text Colors" }
        options[#options + 1] = {
            type    = "colorpicker",
            name    = "Kills (K) color",
            getFunc = function() local c = KDA.sv.colKill;   return c[1], c[2], c[3] end,
            setFunc = function(r, g, b) KDA.sv.colKill   = { r, g, b }; KDA.UpdateLabel() end,
        }
        options[#options + 1] = {
            type    = "colorpicker",
            name    = "Deaths (D) color",
            getFunc = function() local c = KDA.sv.colDeath;  return c[1], c[2], c[3] end,
            setFunc = function(r, g, b) KDA.sv.colDeath  = { r, g, b }; KDA.UpdateLabel() end,
        }
        options[#options + 1] = {
            type    = "colorpicker",
            name    = "Assists (A) color",
            getFunc = function() local c = KDA.sv.colAssist; return c[1], c[2], c[3] end,
            setFunc = function(r, g, b) KDA.sv.colAssist = { r, g, b }; KDA.UpdateLabel() end,
        }
    end

    options[#options + 1] = { type = "header", name = "Counters" }
    options[#options + 1] = {
        type    = "slider",
        name    = "Assist credit window (seconds)",
        tooltip = "How long after you damage an enemy you can still be credited " ..
                  "with an assist when they die.",
        min     = 5, max = 300, step = 5,
        getFunc = function() return KDA.sv.assistSec end,
        setFunc = function(v) KDA.sv.assistSec = v end,
    }
    options[#options + 1] = {
        type    = "button",
        name    = "Reset K / D / A to zero",
        func    = function() KDA.Reset() end,
        warning = "Clears the current session's kills, deaths and assists.",
    }

    LAM:RegisterOptionControls("KDABanner_Panel", options)
end
