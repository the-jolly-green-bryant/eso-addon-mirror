local STORAGE_VERSION = 1
local SAVED_VARS_VERSION = 2
local DEFAULT_EXPORT_ENDPOINT = ""

local function ValidateSavedVars()
    local previousVersion = tonumber(HF.savedVars.savedVarsVersion) or 1
    if type(HF.savedVars.layouts) ~= "table" then HF.savedVars.layouts = {} end
    if type(HF.savedVars.marketplaceLayouts) ~= "table" then HF.savedVars.marketplaceLayouts = {} end
    if type(HF.savedVars.blueprintGroups) ~= "table" then HF.savedVars.blueprintGroups = {} end
    if type(HF.savedVars.settings) ~= "table" then HF.savedVars.settings = ZO_DeepTableCopy(HF.defaults.settings) end
    if type(HF.savedVars.calibration) ~= "table" then HF.savedVars.calibration = ZO_DeepTableCopy(HF.defaults.calibration) end
    if type(HF.savedVars.calibration.markerFurnitureDataIds) ~= "table" then HF.savedVars.calibration.markerFurnitureDataIds = {} end
    if type(HF.savedVars.calibration.rooms) ~= "table" then HF.savedVars.calibration.rooms = {} end
    if type(HF.savedVars.settings.showMissingMarkers) ~= "boolean" then HF.savedVars.settings.showMissingMarkers = true end
    if type(HF.savedVars.settings.markerOpacity) ~= "number" then HF.savedVars.settings.markerOpacity = 0.9 end
    if type(HF.savedVars.settings.maxMarkers) ~= "number" then HF.savedVars.settings.maxMarkers = 30 end
    if type(HF.savedVars.settings.autoRecordBeforeCleanup) ~= "boolean" then HF.savedVars.settings.autoRecordBeforeCleanup = true end
    if type(HF.savedVars.settings.maxRecoverySnapshots) ~= "number" then HF.savedVars.settings.maxRecoverySnapshots = HF.defaults.settings.maxRecoverySnapshots end
    if type(HF.savedVars.settings.housingRequestDelayMs) ~= "number" then HF.savedVars.settings.housingRequestDelayMs = HF.defaults.settings.housingRequestDelayMs end
    if type(HF.savedVars.settings.exportEndpoint) ~= "string" then HF.savedVars.settings.exportEndpoint = HF.defaults.settings.exportEndpoint end
    if HF.savedVars.settings.exportFormat ~= "v1" and HF.savedVars.settings.exportFormat ~= "v2" then HF.savedVars.settings.exportFormat = HF.defaults.settings.exportFormat end
    if HF.savedVars.settings.applyMode ~= "owned" and HF.savedVars.settings.applyMode ~= "cleanapply" and HF.savedVars.settings.applyMode ~= "noclean" and HF.savedVars.settings.applyMode ~= "preview" then HF.savedVars.settings.applyMode = HF.defaults.settings.applyMode end
    if type(HF.savedVars.settings.miniMapFilter) ~= "string" then HF.savedVars.settings.miniMapFilter = HF.defaults.settings.miniMapFilter end
    if type(HF.savedVars.settings.miniMapMaxPins) ~= "number" then HF.savedVars.settings.miniMapMaxPins = HF.defaults.settings.miniMapMaxPins end
    if HF.savedVars.settings.exportEndpoint == "http://localhost:8787/ingest"
        or HF.savedVars.settings.exportEndpoint == "https://120b-67-246-109-167.ngrok-free.app/ingest"
        or HF.savedVars.settings.exportEndpoint == "https://email-instructions-shopping-int.trycloudflare.com/ingest"
        or HF.savedVars.settings.exportEndpoint == "https://gary-subjects-curious-renaissance.trycloudflare.com/ingest"
        or HF.savedVars.settings.exportEndpoint == "https://publishers-cuisine-gadgets-concerned.trycloudflare.com/ingest" then
        HF.savedVars.settings.exportEndpoint = DEFAULT_EXPORT_ENDPOINT
    end
    for _, layout in pairs(HF.savedVars.layouts) do
        if type(layout) == "table" then
            layout.snapshotVersion = tonumber(layout.snapshotVersion) or 1
            layout.coordinateSpace = layout.coordinateSpace or "world"
        end
    end
    if previousVersion < 2 then
        -- 1.3 stored this unused flag as false. Enable the new safety feature on upgrade.
        HF.savedVars.settings.autoRecordBeforeCleanup = true
        HF.savedVars.precisionUndo = nil
        HF.savedVars.blueprintRecovery = nil
    end
    HF.savedVars.savedVarsVersion = SAVED_VARS_VERSION
end

local function CreateSettingsMenu()
    if not LibAddonMenu2 then return end

    local panelData = {
        type = "panel",
        name = "HousingForge",
        displayName = "|cAAFFAAHousingForge|r",
        author = "Tek",
        version = HF.version,
        slashCommand = "/hfsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        { type = "description", text = "Console-first housing layout recorder, applier, and missing item marker system." },
        {
            type = "checkbox",
            name = "Auto-show Missing Markers",
            tooltip = "Automatically show 3D missing item markers after applying a layout.",
            getFunc = function() return HF.savedVars.settings.showMissingMarkers end,
            setFunc = function(value) HF.savedVars.settings.showMissingMarkers = value end,
            default = true,
        },
        {
            type = "slider",
            name = "Marker Opacity",
            min = 0.2,
            max = 1.0,
            step = 0.1,
            getFunc = function() return HF.savedVars.settings.markerOpacity or 0.9 end,
            setFunc = function(value) HF.savedVars.settings.markerOpacity = value end,
            default = 0.9,
        },
        {
            type = "slider",
            name = "Maximum Markers",
            min = 5,
            max = 50,
            step = 5,
            getFunc = function() return HF.savedVars.settings.maxMarkers or 30 end,
            setFunc = function(value) HF.savedVars.settings.maxMarkers = value end,
            default = 30,
        },
        {
            type = "checkbox",
            name = "Safety Snapshot Before Cleanup",
            tooltip = "Save a recovery layout before clean or clean-then-apply. Cleanup is blocked when links or paths cannot be restored; disabling this is the destructive override.",
            getFunc = function() return HF.savedVars.settings.autoRecordBeforeCleanup ~= false end,
            setFunc = function(value) HF.savedVars.settings.autoRecordBeforeCleanup = value end,
            default = true,
        },
        {
            type = "slider",
            name = "Recovery Snapshots Per House",
            min = 1,
            max = 20,
            step = 1,
            getFunc = function() return HF.savedVars.settings.maxRecoverySnapshots or 5 end,
            setFunc = function(value) HF.savedVars.settings.maxRecoverySnapshots = value end,
            default = 5,
        },
        {
            type = "slider",
            name = "Housing Request Delay",
            tooltip = "Delay between housing place/remove requests. Lower is faster but more likely to hit ESO Error 318.",
            min = 10,
            max = 1000,
            step = 10,
            getFunc = function() return HF.savedVars.settings.housingRequestDelayMs or HF.defaults.settings.housingRequestDelayMs end,
            setFunc = function(value) HF.savedVars.settings.housingRequestDelayMs = value end,
            default = HF.defaults.settings.housingRequestDelayMs,
        },
        {
            type = "editbox",
            name = "Export Endpoint",
            tooltip = "Open ingestion endpoint. Include /ingest at the end.",
            getFunc = function() return HF.savedVars.settings.exportEndpoint or "" end,
            setFunc = function(value) HF.savedVars.settings.exportEndpoint = value end,
            default = HF.defaults.settings.exportEndpoint,
        },
        {
            type = "checkbox",
            name = "Mini Map Enabled",
            tooltip = "Show the HousingForge essentials mini map overlay in houses.",
            getFunc = function() return HF.MiniMap and HF.MiniMap.enabled or false end,
            setFunc = function(value)
                if not HF.MiniMap then return end
                if value then HF.MiniMap.Enable() else HF.MiniMap.Disable() end
            end,
            default = false,
        },
        {
            type = "dropdown",
            name = "Mini Map Filter",
            tooltip = "Choose which housing essentials appear on the mini map.",
            choices = { "essentials", "crafting", "set", "mundus", "services", "storage", "dummies", "utilities" },
            getFunc = function() return HF.savedVars.settings.miniMapFilter or HF.defaults.settings.miniMapFilter end,
            setFunc = function(value) if HF.MiniMap then HF.MiniMap.SetFilter(value) end end,
            default = HF.defaults.settings.miniMapFilter,
        },
    }

    LibAddonMenu2:RegisterAddonPanel("HousingForge_Settings", panelData)
    LibAddonMenu2:RegisterOptionControls("HousingForge_Settings", options)
end

local function RegisterSlashCommands()
    SLASH_COMMANDS["/hf"] = function(args)
        local cmd = args and args:lower():match("^%s*(%S*)") or ""
        local rest = args and args:match("^%s*%S+%s*(.-)%s*$") or ""
        if cmd == "help" then
            HF.Chat("/hf - open UI")
            HF.Chat("/hf record [name] - record current owned house")
            HF.Chat("/hf copy [name] - copy current visited house")
            HF.Chat("/hf rename <name> - rename selected local layout")
            HF.Chat("/hf recovery - create a manual safety snapshot")
            HF.Chat("/hf safety on|off - toggle cleanup recovery snapshots")
            HF.Chat("/hf recoverylimit <1-20> - snapshots retained per house")
            HF.Chat("/hf import <HFv2 data> - import a shared layout")
            HF.Chat("/hf precision - open controller precision tools")
            HF.Chat("/hf select, selectall, clearselect - manage furniture selection")
            HF.Chat("/hf group save|load|delete|list <name> - reusable named groups")
            HF.Chat("/hf align <x|y|z> <min|center|max|first>")
            HF.Chat("/hf distribute <x|y|z>, /hf mirror <x|z>")
            HF.Chat("/hf move <x> <y> <z>, /hf rotate <degrees>, /hf undo")
            HF.Chat("/hf delete - delete selected local layout")
            HF.Chat("/hf apply - apply selected saved layout")
            HF.Chat("/hf export - export selected saved layout")
            HF.Chat("/hf export v1 - export selected layout in legacy format")
            HF.Chat("/hf map - export selected layout for the server map viewer")
            HF.Chat("/hf next - open the next queued export URL")
            HF.Chat("/hf queue - show export queue")
            HF.Chat("/hf status - open current export status page")
            HF.Chat("/hf retrymissing 1,2,3 - queue only missing chunks from status page")
            HF.Chat("/hf preview - preview owned/missing items for selected layout")
            HF.Chat("/hf marketplace - open bundled marketplace")
            HF.Chat("/hf applymode <owned|cleanapply|noclean|preview>")
            HF.Chat("/hf pause, /hf resume, /hf cancel, /hf retryfailed - manage apply/clean queue")
            HF.Chat("/hf format v1|v2 - set export format")
            HF.Chat("/hf exportowned or /hf eo - export owned furnishing inventory")
            HF.Chat("/hf speed <safe|normal|fast> - set housing request delay")
            HF.Chat("/hf endpoint <url> - set open export endpoint")
            HF.Chat("/hf calibrate - show fixed calibration marker recipe")
            HF.Chat("/hf scanroom <name> - scan one room using the marker recipe")
            HF.Chat("/hf calmark <role> - optional override for a recipe marker")
            HF.Chat("/hf markers - toggle missing markers")
            HF.Chat("/hf minimap - toggle essentials mini map")
            HF.Chat("/hf minimap <crafting|set|mundus|services|storage|dummies|utilities>")
            HF.Chat("/hf clean - remove all placed furniture after confirmation")
        elseif cmd == "record" then
            HF.RecordCurrentHouse(rest ~= "" and rest or nil)
        elseif cmd == "copy" then
            HF.CopyCurrentHouse(rest ~= "" and rest or nil)
        elseif cmd == "rename" then
            HF.RenameSelectedLayout(rest)
        elseif cmd == "recovery" then
            HF.LayoutRecorder.RecordRecoverySnapshot("manual snapshot")
        elseif cmd == "safety" then
            local value = string.lower(rest or "")
            if value == "on" or value == "true" or value == "1" then
                HF.savedVars.settings.autoRecordBeforeCleanup = true
                HF.Chat("Cleanup safety snapshots enabled.")
            elseif value == "off" or value == "false" or value == "0" then
                HF.savedVars.settings.autoRecordBeforeCleanup = false
                HF.Chat("Cleanup safety snapshots disabled. Clean operations will not be recoverable, and furnishing links or paths may be permanently lost.")
            else
                HF.Chat("Usage: /hf safety on|off")
            end
            if HF.RefreshUI then HF.RefreshUI() end
        elseif cmd == "recoverylimit" then
            local limit = tonumber(rest)
            if not limit then
                HF.Chat("Usage: /hf recoverylimit <1-20>")
            else
                limit = math.max(1, math.min(20, math.floor(limit)))
                HF.savedVars.settings.maxRecoverySnapshots = limit
                HF.Chat(string.format("Keeping up to %d recovery snapshot(s) per house.", limit))
                if HF.RefreshUI then HF.RefreshUI() end
            end
        elseif cmd == "import" then
            if HF.LayoutExport and HF.LayoutExport.ImportLayoutData then
                HF.LayoutExport.ImportLayoutData(rest)
            else
                HF.Chat("Layout import is unavailable.")
            end
        elseif cmd == "precision" or cmd == "tools" then
            HF.OpenPrecisionUI()
        elseif cmd == "select" then
            HF.BlueprintTools.Select()
        elseif cmd == "selectall" then
            HF.BlueprintTools.SelectAll()
        elseif cmd == "clearselect" then
            HF.BlueprintTools.Clear()
        elseif cmd == "group" then
            local groupAction, groupName = string.match(rest or "", "^%s*(%S*)%s*(.-)%s*$")
            groupAction = string.lower(groupAction or "")
            if groupAction == "save" then
                HF.BlueprintTools.SaveGroup(groupName)
            elseif groupAction == "load" then
                HF.BlueprintTools.LoadGroup(groupName, false)
            elseif groupAction == "append" then
                HF.BlueprintTools.LoadGroup(groupName, true)
            elseif groupAction == "delete" then
                HF.BlueprintTools.DeleteGroup(groupName)
            elseif groupAction == "list" then
                HF.BlueprintTools.ListGroups()
            else
                HF.Chat("Usage: /hf group save|load|append|delete|list <name>")
            end
        elseif cmd == "align" then
            local axis, mode = string.match(string.lower(rest or ""), "^%s*(%S+)%s+(%S+)")
            HF.BlueprintTools.Align(axis, mode)
        elseif cmd == "distribute" then
            HF.BlueprintTools.Distribute(string.match(string.lower(rest or ""), "^%s*(%S+)"))
        elseif cmd == "mirror" then
            HF.BlueprintTools.Mirror(string.match(string.lower(rest or ""), "^%s*(%S+)"))
        elseif cmd == "move" then
            local x, y, z = string.match(rest or "", "^%s*([%+%-]?[%d%.]+)%s+([%+%-]?[%d%.]+)%s+([%+%-]?[%d%.]+)")
            x, y, z = tonumber(x), tonumber(y), tonumber(z)
            if x and y and z then
                HF.BlueprintTools.Move(x, y, z)
            else
                HF.Chat("Usage: /hf move <x> <y> <z>, in centimeters")
            end
        elseif cmd == "rotate" then
            HF.BlueprintTools.Rotate(tonumber(string.match(rest or "", "^%s*([%+%-]?[%d%.]+)")))
        elseif cmd == "undo" then
            HF.BlueprintTools.Undo()
        elseif cmd == "precisioncancel" then
            HF.BlueprintTools.Cancel()
        elseif cmd == "delete" then
            HF.ShowDeleteLayoutDialog()
        elseif cmd == "apply" then
            HF.ApplySelectedLayout()
        elseif cmd == "export" then
            HF.ExportSelectedLayout(rest)
        elseif cmd == "map" then
            HF.ExportSelectedMap()
        elseif cmd == "next" then
            HF.LayoutExport.OpenNextQueuedUrl()
        elseif cmd == "queue" then
            HF.OpenExportQueueUI()
        elseif cmd == "status" then
            HF.LayoutExport.OpenStatusUrl()
        elseif cmd == "retrymissing" then
            HF.LayoutExport.QueueMissing(rest)
        elseif cmd == "preview" then
            HF.PreviewSelectedLayout()
        elseif cmd == "marketplace" then
            HF.OpenMarketplaceUI()
        elseif cmd == "applymode" then
            HF.SetApplyMode(rest)
        elseif cmd == "pause" then
            HF.LayoutApplier.PauseQueue()
        elseif cmd == "resume" then
            HF.LayoutApplier.ResumeQueue()
        elseif cmd == "cancel" then
            HF.LayoutApplier.CancelQueue()
        elseif cmd == "retryfailed" then
            HF.LayoutApplier.RetryFailed()
        elseif cmd == "format" then
            HF.LayoutExport.SetFormat(rest)
        elseif cmd == "exportowned" or cmd == "eo" then
            HF.OwnedFurnishingsExport.Export()
        elseif cmd == "speed" then
            HF.SetHousingRequestSpeed(rest)
        elseif cmd == "settings" then
            HF.OpenSettingsUI()
        elseif cmd == "endpoint" then
            HF.LayoutExport.SetEndpoint(rest)
        elseif cmd == "calibrate" then
            HF.Calibration.ShowHelp()
        elseif cmd == "calmarkers" then
            HF.Calibration.ShowMarkerChecklist()
        elseif cmd == "calrecipe" then
            HF.Calibration.ShowMarkerChecklist()
        elseif cmd == "calmark" then
            HF.Calibration.RegisterSelectedMarker(rest)
        elseif cmd == "scanroom" then
            HF.Calibration.ScanRoom(rest)
        elseif cmd == "markers" then
            HF.MissingItemMarkers.Toggle()
        elseif cmd == "minimap" or cmd == "mini" then
            HF.MiniMap.HandleCommand(rest)
        elseif cmd == "clean" then
            HF.ShowCleanHouseDialog()
        else
            HF.ToggleUI()
        end
    end
    SLASH_COMMANDS["/housingforge"] = SLASH_COMMANDS["/hf"]
    SLASH_COMMANDS["/hfrecord"] = function() HF.RecordCurrentHouse() end
    SLASH_COMMANDS["/hfcopy"] = function() HF.CopyCurrentHouse() end
    SLASH_COMMANDS["/hfdelete"] = function() HF.ShowDeleteLayoutDialog() end
    SLASH_COMMANDS["/hfclean"] = function() HF.ShowCleanHouseDialog() end
    SLASH_COMMANDS["/hfexport"] = function() HF.ExportSelectedLayout() end
    SLASH_COMMANDS["/hfmap"] = function() HF.ExportSelectedMap() end
    SLASH_COMMANDS["/hfnext"] = function() HF.LayoutExport.OpenNextQueuedUrl() end
    SLASH_COMMANDS["/hfqueue"] = function() HF.OpenExportQueueUI() end
    SLASH_COMMANDS["/hfstatus"] = function() HF.LayoutExport.OpenStatusUrl() end
    SLASH_COMMANDS["/hfretrymissing"] = function(args) HF.LayoutExport.QueueMissing(args) end
    SLASH_COMMANDS["/hfpreview"] = function() HF.PreviewSelectedLayout() end
    SLASH_COMMANDS["/hfmarketplace"] = function() HF.OpenMarketplaceUI() end
    SLASH_COMMANDS["/hfprecision"] = function() HF.OpenPrecisionUI() end
    SLASH_COMMANDS["/hfundo"] = function() HF.BlueprintTools.Undo() end
    SLASH_COMMANDS["/hfpause"] = function() HF.LayoutApplier.PauseQueue() end
    SLASH_COMMANDS["/hfresume"] = function() HF.LayoutApplier.ResumeQueue() end
    SLASH_COMMANDS["/hfcancel"] = function() HF.LayoutApplier.CancelQueue() end
    SLASH_COMMANDS["/hfexportowned"] = function() HF.OwnedFurnishingsExport.Export() end
    SLASH_COMMANDS["/hfsettingsui"] = function() HF.OpenSettingsUI() end
    SLASH_COMMANDS["/hfcalibrate"] = function() HF.Calibration.ShowHelp() end
    SLASH_COMMANDS["/hfcalmarkers"] = function() HF.Calibration.ShowMarkerChecklist() end
    SLASH_COMMANDS["/hfcalrecipe"] = function() HF.Calibration.ShowMarkerChecklist() end
    SLASH_COMMANDS["/hfscanroom"] = function(args) HF.Calibration.ScanRoom(args) end
    SLASH_COMMANDS["/hfminimap"] = function(args) HF.MiniMap.HandleCommand(args) end
    SLASH_COMMANDS["/hfmini"] = SLASH_COMMANDS["/hfminimap"]
end

function HF.GetHousingRequestDelayMs()
    local delay = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.housingRequestDelayMs
    if type(delay) ~= "number" then delay = HF.defaults.settings.housingRequestDelayMs end
    if delay < 10 then delay = 10 end
    if delay > 1500 then delay = 1500 end
    return delay
end

function HF.SetHousingRequestSpeed(value)
    value = value and value:lower():match("^%s*(%S+)") or ""
    local delays = {
        safe = 500,
        normal = 350,
        fast = 250,
    }
    local delay = delays[value] or tonumber(value)
    if not delay then
        HF.Chat("Usage: /hf speed safe|normal|fast or /hf speed <milliseconds>")
        return
    end
    delay = math.max(10, math.min(1500, delay))
    HF.savedVars.settings.housingRequestDelayMs = delay
    HF.Chat("Housing request delay set to " .. tostring(delay) .. "ms.")
    if HF.RefreshUI then HF.RefreshUI() end
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.AdjustHousingRequestDelay(delta)
    local current = HF.GetHousingRequestDelayMs()
    HF.SetHousingRequestSpeed(tostring(current + (delta or 0)))
end

function HF.GetApplyMode()
    local mode = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.applyMode or "cleanapply"
    if mode ~= "owned" and mode ~= "cleanapply" and mode ~= "noclean" and mode ~= "preview" then mode = "cleanapply" end
    return mode
end

function HF.SetApplyMode(value)
    value = value and value:lower():match("^%s*(%S+)") or ""
    if value == "clean" then value = "cleanapply" end
    if value ~= "owned" and value ~= "cleanapply" and value ~= "noclean" and value ~= "preview" then
        HF.Chat("Usage: /hf applymode owned|cleanapply|noclean|preview")
        return false
    end
    HF.savedVars.settings.applyMode = value
    HF.Chat("Apply mode set to " .. value .. ".")
    if HF.RefreshUI then HF.RefreshUI() end
    return true
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= HF.name then return end
    EVENT_MANAGER:UnregisterForEvent(HF.name, EVENT_ADD_ON_LOADED)

    local ok = pcall(function()
        HF.savedVars = ZO_SavedVars:NewAccountWide("HousingForge_Data", STORAGE_VERSION, nil, HF.defaults)
    end)
    if not ok or not HF.savedVars then
        HF.savedVars = ZO_DeepTableCopy(HF.defaults)
    end

    ValidateSavedVars()
    if HF.MiniMap then
        HF.MiniMap.filter = HF.savedVars.settings.miniMapFilter or HF.defaults.settings.miniMapFilter
    end
    RegisterSlashCommands()
    CreateSettingsMenu()
    if HF.MainMenu then HF.MainMenu.Register() end

    EVENT_MANAGER:RegisterForEvent(HF.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        HF.initialized = true
    end)

    HF.Chat("Loaded. Use /hf to open.")
end

EVENT_MANAGER:RegisterForEvent(HF.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
