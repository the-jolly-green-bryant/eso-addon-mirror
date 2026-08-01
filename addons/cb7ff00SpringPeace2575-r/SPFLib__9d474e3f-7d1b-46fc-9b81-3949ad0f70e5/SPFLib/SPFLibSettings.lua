-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Settings library (SpringPeace Framework)
-----------------------------------------------------------

SPFLibSettings = SPFLibSettings or {}

local LAM = LibAddonMenu2
local LHAS = LHASFork

local function isConsoleUI()
    return IsConsoleUI ~= nil and IsConsoleUI()
end

function SPFLibSettings.ConvertLAMToLHASParams(options)
    local out = {}
    if not LHAS then return out end

    for _, c in ipairs(options) do
        if c.type == "description" then
            local txt = c.text
            if type(txt) == "function" then txt = txt() end
            table.insert(out, {
                type = LHAS.ST_LABEL,
                label = txt,
                canSelect = c.canSelect or false,
                tooltip = c.tooltip,
            })
        elseif c.type == "checkbox" then
            table.insert(out, {
                type = LHAS.ST_CHECKBOX,
                label = c.name,
                tooltip = c.tooltip,
                default = c.default,
                getFunction = c.getFunc,
                setFunction = c.setFunc,
				width = c.width,
                disable = c.disabled,
            })
        elseif c.type == "slider" then
            table.insert(out, {
                type = LHAS.ST_SLIDER,
                label = c.name,
                tooltip = c.tooltip,
                min = c.min,
                max = c.max,
                step = c.step,
                default = c.default,
                getFunction = c.getFunc,
                setFunction = c.setFunc,
                disable = c.disabled,
            })
        elseif c.type == "button" then
            table.insert(out, {
                type = LHAS.ST_BUTTON,
                label = c.name,
                tooltip = c.tooltip,
                buttonText = c.buttonText or "Select",
                clickHandler = c.func,
				width = c.width,
                disable = c.disabled,
            })
		elseif c.type == "dropdown" then
			local choicesMap = SPFLibUtils.GetChoicesMap(c.choices, c.choicesValues)
			local choicesOrder = SPFLibUtils.GetChoicesOrder(c.choices, c.choicesValues)
			table.insert(out, {
				type = LHAS.ST_DROPDOWN,
				label = c.name,
				tooltip = c.tooltip,
				items = SPFLibUtils.GetChoicesOrderedItems(choicesMap, choicesOrder),
				default = c.default,
				getFunction = function()
					return choicesMap[c.getFunc()]
				end,
				setFunction = function(co, n, v)
					c.setFunc(v.data or n)
				end,
			})
        elseif c.type == "submenu" then
            table.insert(out, {
                type = LHAS.ST_SECTION,
                label = c.name,
                tooltip = c.tooltip,
            })
            if c.controls then
                local nested = SPFLibSettings.ConvertLAMToLHASParams(c.controls)
                for _, nestedParam in ipairs(nested) do
                    table.insert(out, nestedParam)
                end
            end
        elseif c.type == "divider" then
			-- Simple visual separator
			table.insert(out, {
				type = LHAS.ST_LABEL,
				label = "|c555555------------------------------|r",
			})
		elseif c.type == "label" then
			-- Simple visual separator
			table.insert(out, {
				type = LHAS.ST_LABEL,
				label = c.name,
			})
		elseif c.type == "space" then
			-- Simple visual separator
			table.insert(out, {
				type = LHAS.ST_LABEL,
				label = "",
			})
        elseif c.type == "image" then
            table.insert(out, {
                type = LHAS.ST_LABEL,
                label = string.format("|t%d:%d:%s|t", c.imageWidth or 72, c.imageHeight or 72, c.texture or ""),
                tooltip = c.tooltip,
                canSelect = c.canSelect or false,
            })
        end
    end

    return out
end

function SPFLibSettings.RefreshSettings()
    if not LAM then return end
    if isConsoleUI() then
        if LHAS and LHAS.addons then
            for i = 1, #LHAS.addons do
                local addon = LHAS.addons[i]
                if addon and addon.selected and addon.UpdateControls then
                    addon:UpdateControls()
                    return
                end
            end
        end
    end
end

--[[ function SPFLibSettings.OpenSettings(settingsPanelId)
    if LAM and LAM.OpenToPanel then
        LAM:OpenToPanel(settingsPanelId)
    end
end ]]

function SPFLibSettings.RegisterSettingsPanel(settingsPanelId, panelData, options, defaults, state)
    if isConsoleUI() and LHAS and LHAS.AddAddon then
        local addonSettings = LHAS:AddAddon(panelData.displayName, { version = panelData.version, author = panelData.author })
        if addonSettings then
            addonSettings.settingsPanelId = settingsPanelId
            addonSettings.allowDefaults = true
            addonSettings.hasDefaults = true
            addonSettings.ResetToDefaults = function()
                ZO_DeepTableCopy(defaults, state)
                SPFLibSettings.RefreshSettings()
            end
            addonSettings:AddSettings(SPFLibSettings.ConvertLAMToLHASParams(options), 1, false)
        end
    else
        LAM:RegisterAddonPanel(settingsPanelId, panelData)
        LAM:RegisterOptionControls(settingsPanelId, options)
    end
end

function SPFLibSettings.RegisterSettingsPanelControlled(settingsPanelId, panelData, options, resetToDefaults, setSettings)
    if isConsoleUI() and LHAS and LHAS.AddAddon then
        local addonSettings = LHAS:AddAddon(panelData.displayName, { version = panelData.version, author = panelData.author })
        if addonSettings then
            addonSettings.settingsPanelId = settingsPanelId
            addonSettings.allowDefaults = true
            addonSettings.hasDefaults = true
            addonSettings.ResetToDefaults = function()
                if type(resetToDefaults) =="function" then
                    resetToDefaults()
                end
                SPFLibSettings.RefreshSettings()
            end
            addonSettings:AddSettings(SPFLibSettings.ConvertLAMToLHASParams(options), 1, false)
            if type(setSettings) =="function" then
                setSettings(addonSettings)
            end
        end
    else
        LAM:RegisterAddonPanel(settingsPanelId, panelData)
        LAM:RegisterOptionControls(settingsPanelId, options)
    end
end

function SPFLibSettings.GetSelectedHarvensAddon()
    if not LHAS or not LHAS.addons then return nil end

    for i = 1, #LHAS.addons do
        local addon = LHAS.addons[i]
        if addon and addon.selected then
            return addon
        end
    end

    return nil
end

SPFLibSettings.harvensHooked = false
SPFLibSettings.origHarvensGoBack = nil
SPFLibSettings.harvensGoBackHandlers = {}

function SPFLibSettings.HookHarvensNavigation(settingsPanelId, onGoBack)
    if not isConsoleUI() then return end
    if not LHAS or not LHAS.GoBack then return end
    if not settingsPanelId or type(onGoBack) ~= "function" then return end

	SPFLibSettings.harvensGoBackHandlers = SPFLibSettings.harvensGoBackHandlers or {}
    SPFLibSettings.harvensGoBackHandlers[settingsPanelId] = onGoBack

    if SPFLibSettings.harvensHooked then return end

    SPFLibSettings.harvensHooked = true
    SPFLibSettings.origHarvensGoBack = LHAS.GoBack

	LHAS.GoBack = function(self, ...)
        if SCENE_MANAGER and SCENE_MANAGER.GetCurrentSceneName then
            local sceneName = SCENE_MANAGER:GetCurrentSceneName()
            if sceneName ~= "LHASForkScene" then
                if type(SPFLibSettings.origHarvensGoBack) == "function" then
                    return SPFLibSettings.origHarvensGoBack(self, ...)
                end
            end
        end

        local addon = SPFLibSettings.GetSelectedHarvensAddon()
        local panelId = addon and addon.settingsPanelId

        if panelId and SPFLibSettings.harvensGoBackHandlers then
            local handler = SPFLibSettings.harvensGoBackHandlers[panelId]
            if type(handler) == "function" then
                local handled = handler()
                if handled == true then
                    return
                end
            end
        end

        if type(SPFLibSettings.origHarvensGoBack) == "function" then
            return SPFLibSettings.origHarvensGoBack(self, ...)
        end
    end
end

function SPFLibSettings.ReplaceSettings(addonSettings, lamControls, preserveFocus, selectedIndex)
	if addonSettings == nil or addonSettings.settings == nil then return end

	-- Rebuild current console settings page. Optionally preserve scroll/focus position.
	local list = LHAS and LHAS.list

	-- Preserve focus efficiently (FindFirstIndexByEval is expensive on large lists)
	if selectedIndex == nil and preserveFocus and list then
		if list.GetSelectedIndex then
			selectedIndex = list:GetSelectedIndex()
		elseif list.GetSelectedData and list.GetDataListIndex then
			local selectedData = list:GetSelectedData()
			if selectedData ~= nil then
				selectedIndex = list:GetDataListIndex(selectedData)
			end
		end
	end

	local params = SPFLibSettings.ConvertLAMToLHASParams(lamControls)

	if addonSettings.settings and #addonSettings.settings > 0 and addonSettings.RemoveSettings then
		addonSettings:RemoveSettings(1, #addonSettings.settings, false)
	end
	if addonSettings.AddSettings then
		addonSettings:AddSettings(params, 1, false)
	end

	if preserveFocus and selectedIndex and list and list.SetSelectedIndex then
		-- Clamp / fall back to first selectable row
		local idx = selectedIndex
		if list.GetNumItems and idx and idx > list:GetNumItems() then
			idx = list:GetNumItems()
		end
		if list.CalculateFirstSelectableIndex and (idx == nil or idx < 1) then
			idx = list:CalculateFirstSelectableIndex()
		end
		if idx and list.SetSelectedIndex then
			-- Reduce visible scroll jumps when rebuilding
			if list.EnableAnimation then list:EnableAnimation(false) end
			list:SetSelectedIndex(idx)
			zo_callLater(function() if list and list.EnableAnimation then list:EnableAnimation(true) end end, 10)
		end
	end
end

function SPFLibSettings.GetSelectedIndex()
    local listObj = LHAS and LHAS.list
    if listObj and listObj.GetSelectedIndex then
        return listObj:GetSelectedIndex()
    end
    return nil
end
