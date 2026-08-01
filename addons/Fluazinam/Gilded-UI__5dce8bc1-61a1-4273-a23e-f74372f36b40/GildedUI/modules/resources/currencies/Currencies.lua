if not GildedUI then return end

local Addon = GildedUI

local EMPTY_SLOT_ICON = "/esoui/art/icons/icon_emptyslot.dds"
local ROW_HEIGHT = 23
local BASE_POS_X = 1700
local EXTRA_BASE_POS_Y = 120 -- stacks below Tel Var default (y = 97)

-- Turns a camelCase currency id into PascalCase for show keys and control names.
-- e.g. "gold" -> "Gold" (showGold), "crownGems" -> "CrownGems" (GildedUI_CrownGems).
local function CapitalizeId(id)
    return id:sub(1, 1):upper() .. id:sub(2)
end

local function ResolveNamedCurrency(names)
    for i = 1, #names do
        local value = _G[names[i]]
        if type(value) == "number" then
            return value
        end
    end
    return nil
end

local function NameMatchesHints(currencyName, hints, exact, excludeHints)
    if type(currencyName) ~= "string" or currencyName == "" then
        return false
    end

    local lower = zo_strlower(currencyName)
    if excludeHints then
        for i = 1, #excludeHints do
            if lower:find(excludeHints[i], 1, true) then
                return false
            end
        end
    end

    for i = 1, #hints do
        local hint = hints[i]
        if exact then
            if lower == hint or lower == hint .. "s" then
                return true
            end
        elseif lower:find(hint, 1, true) then
            return true
        end
    end
    return false
end

local function FindCurrencyTypeByHints(hints, exact, excludeHints, usedTypes)
    if type(GetCurrencyName) ~= "function" then
        return nil
    end

    local maxValue = rawget(_G, "CURT_MAX_VALUE")
    if type(maxValue) ~= "number" then
        maxValue = 64
    end

    for currencyType = 1, maxValue do
        if not usedTypes[currencyType] then
            local ok, name = pcall(GetCurrencyName, currencyType, false, false)
            if ok and NameMatchesHints(name, hints, exact, excludeHints) then
                return currencyType
            end
        end
    end
    return nil
end

local function ResolveCurrencyLocation(currencyType, locationMode)
    if locationMode == "character" then
        return CURRENCY_LOCATION_CHARACTER
    end
    if locationMode == "account" then
        return CURRENCY_LOCATION_ACCOUNT
    end
    if type(GetCurrencyPlayerStoredLocation) == "function" then
        local ok, location = pcall(GetCurrencyPlayerStoredLocation, currencyType)
        if ok and location ~= nil then
            return location
        end
    end
    return CURRENCY_LOCATION_ACCOUNT
end

local function BuildIconChoices(currencyType, fixedChoices)
    if fixedChoices then
        return fixedChoices
    end

    local choices = {}
    if type(ZO_Currency_GetPlatformCurrencyIcon) == "function" then
        local ok, icon = pcall(ZO_Currency_GetPlatformCurrencyIcon, currencyType)
        if ok and type(icon) == "string" and icon ~= "" then
            choices[#choices + 1] = icon
        end
    end
    if type(ZO_Currency_GetCurrencyIcon) == "function" then
        local ok, icon = pcall(ZO_Currency_GetCurrencyIcon, currencyType)
        if ok and type(icon) == "string" and icon ~= "" and icon ~= choices[1] then
            choices[#choices + 1] = icon
        end
    end
    if #choices == 0 then
        choices[1] = "/esoui/art/inventory/gamepad/gp_inventory_icon_currencies.dds"
    end
    choices[#choices + 1] = EMPTY_SLOT_ICON
    return choices
end

function Addon:GetCurrencyDef(id)
    if not self.currencyById then return nil end
    return self.currencyById[id]
end

function Addon:InitCurrencies()
    if self.currencies then
        return
    end

    local defs = {}
    local byId = {}
    local usedTypes = {}
    local extraIndex = 0

    for _, spec in ipairs(Addon.CURRENCY_SPECS) do
        local currencyType = ResolveNamedCurrency(spec.currencyNames)
        if not currencyType and spec.nameHints then
            currencyType = FindCurrencyTypeByHints(spec.nameHints, spec.nameExact, spec.excludeHints, usedTypes)
        end

        if currencyType and not usedTypes[currencyType] then
            usedTypes[currencyType] = true
            local cap = CapitalizeId(spec.id)
            local iconChoices = BuildIconChoices(currencyType, spec.iconChoices)
            local isCore = spec.posY ~= nil
            local defaultPosY = spec.posY
            if not defaultPosY then
                defaultPosY = EXTRA_BASE_POS_Y + extraIndex * ROW_HEIGHT
                extraIndex = extraIndex + 1
            end

            local def = {
                id = spec.id,
                name = spec.name,
                currencyType = currencyType,
                location = ResolveCurrencyLocation(currencyType, spec.location),
                showKey = spec.showKey or ("show" .. cap),
                posXKey = spec.id .. "PosX",
                posYKey = spec.id .. "PosY",
                fontKey = spec.id .. "FontSize",
                iconKey = spec.id .. "Icon",
                backgroundKey = spec.id .. "ShowBackground",
                paddingKey = spec.id .. "ShowPadding",
                opacityKey = spec.id .. "BackgroundOpacity",
                iconChoices = iconChoices,
                iconNoneIndex = #iconChoices,
                placeholder = spec.placeholder or "--",
                formatKey = spec.formatKey,
                useColorsKey = spec.useColorsKey,
                textColor = spec.textColor,
                onlyInCyrodiilKey = spec.onlyInCyrodiilKey,
                isCore = isCore,
            }
            defs[#defs + 1] = def
            byId[def.id] = def

            self.defaults[def.showKey] = spec.showDefault == true
            self.defaults[def.posXKey] = spec.posX or BASE_POS_X
            self.defaults[def.posYKey] = defaultPosY
            self.defaults[def.fontKey] = 16
            self.defaults[def.iconKey] = 1
            self.defaults[def.backgroundKey] = false
            self.defaults[def.paddingKey] = true
            self.defaults[def.opacityKey] = 0.5
            if def.formatKey then
                self.defaults[def.formatKey] = "groupedG"
            end
            if def.useColorsKey then
                self.defaults[def.useColorsKey] = true
            end
            if def.onlyInCyrodiilKey then
                self.defaults[def.onlyInCyrodiilKey] = false
            end
        end
    end

    self.currencies = defs
    self.currencyById = byId
    self.state.currencyReadouts = self.state.currencyReadouts or {}
end

-- Back-compat alias used by Initialize
function Addon:InitExtraCurrencies()
    self:InitCurrencies()
end

function Addon:GetCurrencyAmount(def)
    return GetCurrencyAmount(def.currencyType, def.location) or 0
end

function Addon:GetCurrencyIconPath(def)
    return self:GetIconPathForKey(def.iconKey, def.iconChoices, def.iconNoneIndex)
end

function Addon:GetCurrencyTextColor(def)
    local sv = self.state.sv
    if def.useColorsKey and sv and sv[def.useColorsKey] and def.textColor then
        return def.textColor[1], def.textColor[2], def.textColor[3]
    end
    return 1, 1, 1
end

function Addon:CreateCurrencyOverlays()
    if not self.currencies then return end
    local sv = self.state.sv
    local wm = WINDOW_MANAGER
    local readouts = self.state.currencyReadouts

    for _, def in ipairs(self.currencies) do
        local font = self:GetReadoutFont(sv[def.fontKey])
        local r, g, b = self:GetCurrencyTextColor(def)
        local window, backdrop, label, icon, content = self:CreateReadout(
            wm,
            self.name .. "_" .. CapitalizeId(def.id),
            font,
            r, g, b,
            def.placeholder,
            sv[def.posXKey],
            sv[def.posYKey],
            true
        )
        readouts[def.id] = {
            window = window,
            backdrop = backdrop,
            label = label,
            icon = icon,
            content = content,
        }
    end
end

function Addon:ApplyCurrencyPosition(def)
    local sv = self.state.sv
    local readout = self.state.currencyReadouts and self.state.currencyReadouts[def.id]
    if not sv or not readout then return end
    self:ApplyReadoutPosition(readout.window, sv[def.posXKey], sv[def.posYKey])
end

function Addon:ApplyCurrencyIcon(def)
    local sv = self.state.sv
    local readout = self.state.currencyReadouts and self.state.currencyReadouts[def.id]
    if not sv or not readout then return end

    self:ApplyReadoutLayout(
        readout.backdrop,
        readout.content,
        readout.label,
        readout.icon,
        sv[def.backgroundKey],
        sv[def.paddingKey],
        sv[def.opacityKey],
        self:GetCurrencyIconPath(def),
        sv[def.fontKey]
    )
end

function Addon:ApplyCurrencyColor(def)
    local readout = self.state.currencyReadouts and self.state.currencyReadouts[def.id]
    if not readout or not readout.label then return end
    local r, g, b = self:GetCurrencyTextColor(def)
    readout.label:SetColor(r, g, b, 1)
end

function Addon:ApplyCurrencyFont(def)
    local sv = self.state.sv
    local readout = self.state.currencyReadouts and self.state.currencyReadouts[def.id]
    if not sv or not readout then return end
    self:ApplyReadoutFont(readout.label, sv[def.fontKey])
    self:ApplyCurrencyIcon(def)
    if def.useColorsKey then
        self:ApplyCurrencyColor(def)
    end
end

function Addon:ApplyAllCurrencyFonts()
    if not self.currencies then return end
    for _, def in ipairs(self.currencies) do
        self:ApplyCurrencyFont(def)
    end
end

function Addon:ApplyAllCurrencyBackgrounds()
    if not self.currencies then return end
    for _, def in ipairs(self.currencies) do
        self:ApplyCurrencyIcon(def)
    end
end

function Addon:ApplyAllCurrencyPositions()
    if not self.currencies then return end
    for _, def in ipairs(self.currencies) do
        self:ApplyCurrencyPosition(def)
    end
end

function Addon:ApplyAllCurrencyColors()
    if not self.currencies then return end
    for _, def in ipairs(self.currencies) do
        if def.useColorsKey then
            self:ApplyCurrencyColor(def)
        end
    end
end

function Addon:SetCurrencyEnabled(def, enabled)
    self.state.sv[def.showKey] = enabled
    self:UpdateVisibility()
end

function Addon:UpdateCurrencyVisibility(showResources)
    if not self.currencies then return end
    local sv = self.state.sv
    local readouts = self.state.currencyReadouts
    for _, def in ipairs(self.currencies) do
        local readout = readouts[def.id]
        if readout and readout.window then
            local show = sv[def.showKey] and showResources
            if show and def.onlyInCyrodiilKey and sv[def.onlyInCyrodiilKey] then
                show = IsInCyrodiil()
            end
            readout.window:SetHidden(not show)
        end
    end
end

function Addon:UpdateCurrency(def)
    local readout = self.state.currencyReadouts and self.state.currencyReadouts[def.id]
    if not readout or not readout.window or readout.window:IsHidden() or not readout.label then
        return
    end

    local amount = self:GetCurrencyAmount(def)
    if def.formatKey then
        readout.label:SetText(self:FormatGoldAmount(amount))
    else
        readout.label:SetText(self:FormatCurrencyAmount(amount))
    end
end

function Addon:UpdateCurrencies()
    if not self.currencies then return end
    for _, def in ipairs(self.currencies) do
        self:UpdateCurrency(def)
    end
end

function Addon:SanitizeCurrencies()
    if not self.currencies then return end
    local sv = self.state.sv
    local defaults = self.defaults
    local limits = self.limits

    for _, def in ipairs(self.currencies) do
        if type(sv[def.posXKey]) ~= "number" then
            sv[def.posXKey] = defaults[def.posXKey]
        else
            sv[def.posXKey] = zo_clamp(sv[def.posXKey], limits.posX.min, limits.posX.max)
        end
        if type(sv[def.posYKey]) ~= "number" then
            sv[def.posYKey] = defaults[def.posYKey]
        else
            sv[def.posYKey] = zo_clamp(sv[def.posYKey], limits.posY.min, limits.posY.max)
        end
        if type(sv[def.opacityKey]) ~= "number" then
            sv[def.opacityKey] = defaults[def.opacityKey]
        else
            sv[def.opacityKey] = zo_clamp(sv[def.opacityKey], limits.backgroundOpacity.min, limits.backgroundOpacity.max)
            sv[def.opacityKey] = zo_round(sv[def.opacityKey] * 10) / 10
        end
        if not self.fontMap[sv[def.fontKey]] then
            sv[def.fontKey] = defaults[def.fontKey]
        end
        if type(sv[def.showKey]) ~= "boolean" then sv[def.showKey] = defaults[def.showKey] end
        if type(sv[def.backgroundKey]) ~= "boolean" then sv[def.backgroundKey] = defaults[def.backgroundKey] end
        if type(sv[def.paddingKey]) ~= "boolean" then sv[def.paddingKey] = defaults[def.paddingKey] end
        if def.useColorsKey then
            if type(sv[def.useColorsKey]) ~= "boolean" then sv[def.useColorsKey] = defaults[def.useColorsKey] end
        end
        if def.onlyInCyrodiilKey then
            if type(sv[def.onlyInCyrodiilKey]) ~= "boolean" then sv[def.onlyInCyrodiilKey] = defaults[def.onlyInCyrodiilKey] end
        end
        if def.formatKey then
            if not self:IsValidGoldFormat(sv[def.formatKey]) then
                sv[def.formatKey] = defaults[def.formatKey]
            end
        end
        if type(sv[def.iconKey]) == "string" then
            sv[def.iconKey] = self:IconPathToIndex(sv[def.iconKey], def.iconChoices, defaults[def.iconKey])
        end
        self:SanitizeIconIndex(def.iconKey, #def.iconChoices)
    end
end

function Addon:BuildCurrenciesMenu(H)
    local sv = self.state.sv
    local controls = {
        { type = "header", name = "Currencies" },
    }

    if not self.currencies then
        return controls
    end

    local goldFormatChoices, goldFormatValues = {}, {}
    for i, item in ipairs(self.goldFormatItems) do
        goldFormatChoices[i] = item.name
        goldFormatValues[i] = item.value
    end

    for _, def in ipairs(self.currencies) do
        local page = {
            H.Toggle(
                "Enable " .. def.name,
                function() return sv[def.showKey] end,
                function(v) Addon:SetCurrencyEnabled(def, v) end,
                Addon.defaults[def.showKey]
            ),
        }

        if def.onlyInCyrodiilKey then
            page[#page + 1] = H.Toggle(
                "Only show in Cyrodiil",
                function() return sv[def.onlyInCyrodiilKey] end,
                function(v)
                    sv[def.onlyInCyrodiilKey] = v
                    Addon:UpdateVisibility()
                end,
                Addon.defaults[def.onlyInCyrodiilKey],
                function() return not sv[def.showKey] end
            )
        end

        page[#page + 1] = H.FontSizeDropdown(def.fontKey)

        if def.formatKey then
            page[#page + 1] = {
                type = "selector",
                name = "Format",
                choices = goldFormatChoices,
                choicesValues = goldFormatValues,
                getFunc = function() return sv[def.formatKey] end,
                setFunc = function(value)
                    sv[def.formatKey] = value
                    Addon:UpdateCurrency(def)
                end,
                default = Addon.defaults[def.formatKey],
            }
        end

        page[#page + 1] = H.IconPicker(def.iconKey, def.iconChoices, function() Addon:ApplyCurrencyIcon(def) end)

        if def.useColorsKey then
            page[#page + 1] = H.Toggle(
                "Use Colors",
                function() return sv[def.useColorsKey] end,
                function(v)
                    sv[def.useColorsKey] = v
                    Addon:ApplyCurrencyColor(def)
                end,
                Addon.defaults[def.useColorsKey]
            )
        end

        H.Append(page, H.BackgroundControls(def.backgroundKey, def.paddingKey, def.opacityKey))
        H.Append(page, H.PositionSliders(
            def.name .. " X Position",
            def.name .. " Y Position",
            def.posXKey,
            def.posYKey,
            function() Addon:ApplyCurrencyPosition(def) end
        ))

        controls[#controls + 1] = {
            type = "submenu",
            name = def.name,
            controls = page,
        }
    end

    return controls
end

-- Thin wrappers kept for any leftover call sites / defaults reset.
function Addon:UpdateGold()
    local def = self:GetCurrencyDef("gold")
    if def then self:UpdateCurrency(def) end
end

function Addon:ApplyGoldColor()
    local def = self:GetCurrencyDef("gold")
    if def then self:ApplyCurrencyColor(def) end
end
