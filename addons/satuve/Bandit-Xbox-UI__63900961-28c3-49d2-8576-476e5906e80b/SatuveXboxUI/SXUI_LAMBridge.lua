-- Satuve Xbox UI - LibAddonMenu bridge
-- Uses LibAddonMenu-2.0 when available. The existing BUI menu remains a fallback.
-- LibGamepad can then expose the LAM panels in ESO's Gamepad UI without this addon
-- needing to depend on LibGamepad internals.

BUI = BUI or {}
BUI.SettingsBridge = BUI.SettingsBridge or {}
local Bridge = BUI.SettingsBridge

Bridge.mode = "internal"
Bridge.panels = Bridge.panels or {}
Bridge.firstPanel = Bridge.firstPanel or nil

local function GetLAM()
    if rawget(_G, "LibAddonMenu2") then
        return LibAddonMenu2
    end
    local libStub = rawget(_G, "LibStub")
    if libStub then
        local ok, lam = pcall(libStub, "LibAddonMenu-2.0")
        if ok and lam then return lam end
    end
    return nil
end

local function Loc(key)
    if type(key) ~= "string" then return key end
    if BUI and BUI.Localization then
        local lang = BUI.language
        local langTable = lang and BUI.Localization[lang]
        local enTable = BUI.Localization.en
        if langTable and langTable[key] then return langTable[key] end
        if enTable and enTable[key] then return enTable[key] end
    end
    return key
end

local function TooltipFor(data)
    if data.tooltip and data.tooltip ~= "" then
        return Loc(data.tooltip)
    end
    if data.name then
        local descKey = tostring(data.name) .. "Desc"
        local text = Loc(descKey)
        if text ~= descKey then return text end
    end
    return nil
end

local function FindChoiceIndex(choices, choicesValues, value)
    if choicesValues then
        for i, v in ipairs(choicesValues) do
            if v == value then return i end
        end
    end
    if choices then
        for i, v in ipairs(choices) do
            if v == value then return i end
        end
    end
    return type(value) == "number" and value or nil
end

local function CloneOption(data)
    local out = {}
    for k, v in pairs(data) do out[k] = v end

    if out.name then out.name = Loc(out.name) end
    if out.text then out.text = Loc(out.text) end
    local tt = TooltipFor(data)
    if tt then out.tooltip = tt end
    if type(out.warning) == "string" then out.warning = Loc(out.warning) end

    -- The original Satuve menu supports dropdown setFunc(index, value) and numeric
    -- getFunc() results. LAM uses the selected value. Adapt both conventions here.
    if data.type == "dropdown" then
        local originalGet = data.getFunc
        local originalSet = data.setFunc
        local choices = data.choices
        local choicesValues = data.choicesValues

        if originalGet then
            out.getFunc = function()
                local value = originalGet()
                if type(value) == "number" and not choicesValues and choices and choices[value] ~= nil then
                    return choices[value]
                end
                return value
            end
        end

        if originalSet then
            out.setFunc = function(value)
                local index = FindChoiceIndex(choices, choicesValues, value)
                originalSet(index or value, value)
            end
        end
    end

    -- BUI has a custom "gradient" widget. Represent it in LAM as two normal
    -- color pickers so both ends of the gradient remain fully editable.
    if data.type == "gradient" then
        return {
            type = "submenu",
            name = Loc(data.name),
            controls = {
                {
                    type = "colorpicker",
                    name = Loc(data.name) .. " 1",
                    getFunc = data.getFunc,
                    setFunc = data.setFunc,
                    disabled = data.disabled,
                },
                {
                    type = "colorpicker",
                    name = Loc(data.name) .. " 2",
                    getFunc = data.getFunc2,
                    setFunc = data.setFunc2,
                    disabled = data.disabled,
                },
            },
        }
    end

    if data.type == "submenu" and data.controls then
        out.controls = {}
        for _, child in ipairs(data.controls) do
            local converted = CloneOption(child)
            if converted then table.insert(out.controls, converted) end
        end
    end

    -- Decorative texture rows are not needed in the settings/gamepad list and
    -- are not supported consistently by every LAM/Gamepad adapter version.
    if data.type == "texture" then
        return nil
    end

    return out
end

local function ConvertOptions(options)
    local result = {}
    for _, data in ipairs(options or {}) do
        local converted = CloneOption(data)
        if converted then table.insert(result, converted) end
    end
    return result
end


function Bridge.Available()
    return GetLAM() ~= nil
end

-- Register one single top-level panel ("Bandit UI") and put all former
-- Bandits/Satuve settings pages inside it as submenus. This keeps LibGamepad
-- from exposing every settings page as a separate item in ESO's ADD-ONS list.
function Bridge.RegisterGrouped(panelName, panelData, sections)
    local lam = GetLAM()
    if not lam then return nil, "internal" end

    Bridge.mode = "lam"

    local panelCopy = {}
    for k, v in pairs(panelData or {}) do panelCopy[k] = v end
    panelCopy.name = panelCopy.name or "Bandit UI"
    panelCopy.displayName = panelCopy.displayName or panelCopy.name
    panelCopy.author = panelCopy.author or "Satuve"
    panelCopy.version = panelCopy.version or tostring(BUI.Version or "")
    panelCopy.registerForRefresh = true
    panelCopy.registerForDefaults = true

    local controls = {}
    for _, section in ipairs(sections or {}) do
        local converted = ConvertOptions(section.options or {})
        table.insert(controls, {
            type = "submenu",
            name = section.name or section.id or "Settings",
            controls = converted,
        })
    end

    local panel = lam:RegisterAddonPanel(panelName, panelCopy)
    lam:RegisterOptionControls(panelName, controls)
    Bridge.panels[panelName] = panel
    Bridge.firstPanel = panel
    return panel, "lam"
end

function Bridge.Register(panelName, panelData, options)
    local lam = GetLAM()
    if lam then
        Bridge.mode = "lam"

        local panelCopy = {}
        for k, v in pairs(panelData or {}) do panelCopy[k] = v end
        panelCopy.name = Loc(panelCopy.name or panelName)
        panelCopy.displayName = Loc(panelCopy.displayName or panelCopy.name)
        panelCopy.author = panelCopy.author or "Satuve"
        panelCopy.version = panelCopy.version or tostring(BUI.Version or "")
        panelCopy.registerForRefresh = true
        panelCopy.registerForDefaults = true

        local panel = lam:RegisterAddonPanel(panelName, panelCopy)
        lam:RegisterOptionControls(panelName, ConvertOptions(options))
        Bridge.panels[panelName] = panel
        Bridge.firstPanel = Bridge.firstPanel or panel
        return panel, "lam"
    end

    Bridge.mode = "internal"
    local panel = BUI.Menu.RegisterPanel(panelName, panelData)
    BUI.Menu.RegisterOptions(panelName, options)
    Bridge.panels[panelName] = panel
    Bridge.firstPanel = Bridge.firstPanel or panel
    return panel, "internal"
end

function Bridge.Open()
    local lam = GetLAM()
    if lam and Bridge.firstPanel and lam.OpenToPanel then
        lam:OpenToPanel(Bridge.firstPanel)
        return true
    end
    if BUI.Menu and BUI.Menu.Open then
        BUI.Menu.Open()
        return true
    end
    return false
end

function Bridge.UsingLAM()
    return Bridge.mode == "lam"
end
