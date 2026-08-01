---------------------------------------------------------------------------------------------------
-- BSCASynergy – Priority Menu (Tab 7)
---------------------------------------------------------------------------------------------------
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

---------------------------------------------------------------------------------------------------
-- 🔧 Helper Functions
---------------------------------------------------------------------------------------------------
local function AddControl(data)
    BSCAS:AddControlToTab(7, data)
end

local function AddDivider()
    AddControl({ type = "divider" })
end

---------------------------------------------------------------------------------------------------
-- ⚙️ Basic Settings Section
---------------------------------------------------------------------------------------------------
local function AddBasicSettings()

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SETTING_ACC),
        getFunc = function() return BSCAS.SV.PRIO_USE_ACCOUNT end,
        setFunc = function(v) 
			BSCAS.SetUseAccount("PRIO", v)
		end,
	})
	
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_CHAT_PRESET_INFO),
        getFunc = function() return BSCAS.SV.PRINT_PRIORITY_PRESET_LOADED end,
        setFunc = function(v) 
			BSCAS.SV.PRINT_PRIORITY_PRESET_LOADED = v
		end,
	})
	
	AddDivider()
	
    AddControl({
        type = "checkbox",
        name = GetString(SI_SYNERGY_UI_PRIO_UI),
        getFunc = function() return BSCAS.SV.PRIO_UI_ENABLE end,
        setFunc = function(v)
            BSCAS.SV.PRIO_UI_ENABLE = v
            BSCAS:UpdatePrioSettings()
        end,
    })

    AddControl({
        type = "checkbox",
        name = GetString(SI_SYNERGY_UI_LOCK),
        disabled = function() return not BSCAS.SV.PRIO_UI_ENABLE end,
        getFunc = function() return BSCAS.SV.PRIO_LOCK_UI end,
        setFunc = function(v)
            BSCAS.SV.PRIO_LOCK_UI = v
            BSCASynergyPUI:SetMovable(not v)
        end,
    })

    AddDivider()

    AddControl({
        type = "checkbox",
        name = GetString(SI_SYNERGY_UI_NAME_WWPLUGIN),
        tooltip = function() 
			if LibBSCWizardBridge then
				return GetString(SI_SYNERGY_UI_DESC_WWPLUGIN)
			else
				return "LibBSCWizardBridge missing/not enabled"
			end
		end,
		disabled = function() return not LibBSCWizardBridge end,
        getFunc = function() return BSCAS.SV.ADD_WW_PLUGIN end,
        setFunc = function(v)
            BSCAS.SV.ADD_WW_PLUGIN = v
            zo_callLater(function() ReloadUI() end, 300)
        end,
        warning = GetString(SI_SYNERGY_INFO_RELOAD),
    })
end

---------------------------------------------------------------------------------------------------
-- 🧠 Auto-Load Preset by Role
---------------------------------------------------------------------------------------------------
local function AddAutoLoadPreset()
    AddControl({
        type = "header",
        name = GetString(SI_SYNERGY_NAME_PRE) .. " - " ..
               GetString(SI_GROUP_LIST_PANEL_PREFERRED_ROLES_LABEL) ..
               " (Default = no change)",
    })

    local roles = {
        { role = LFG_ROLE_TANK, icon = "EsoUI/Art/LFG/LFG_tank_up_64.dds", ref = "Tank" },
        { role = LFG_ROLE_HEAL, icon = "EsoUI/Art/LFG/LFG_healer_up_64.dds", ref = "Heal" },
        { role = LFG_ROLE_DPS,  icon = "EsoUI/Art/LFG/LFG_dps_up_64.dds",  ref = "Dps" },
    }

    for _, r in ipairs(roles) do
        AddControl({
            type = "dropdown",
            name = string.format("|t23:23:%s|t|r%s",
                r.icon, GetString("SI_LFGROLE", r.role)),
            choices = BSCAS:GetListPrioNames(),
            getFunc = function() return BSCAS.SV["SELECTED_PRIO_PRESET_" .. string.upper(r.ref)] end,
            setFunc = function(value)
                local key = "SELECTED_PRIO_PRESET_" .. string.upper(r.ref)
                BSCAS.SV[key] = value
                if GetSelectedLFGRole() == r.role then
                    CHAT_ROUTER:AddSystemMessage(zo_strformat(
                        "|cFFFFFFBSCs-AS Loading Priority <<1>> Preset: <<2>>|r",
                        GetString("SI_LFGROLE", r.role), value))
                    BSCAS.PlaySound(1, SOUNDS.OUTFIT_GAMEPAD_UNDO_CHANGES)
                    BSCAS.SV.SELECTED_PRIO_PRESET = value
                    BSCAS:ApplyPrioPreset(value)
                end
            end,
            scrollable = 12,
            reference = "BSCAS_PrioPresetDropdown" .. r.ref,
        })
    end
end

---------------------------------------------------------------------------------------------------
-- 🧩 Manual Preset Management
---------------------------------------------------------------------------------------------------
local function AddPresetSettings()
    AddControl({
        type = "header",
        name = GetString(SI_SYNERGY_NAME_PRE_H),
    })
	
    -- Preset Name Entry
    AddControl({
        type = "editbox",
        name = GetString(SI_SYNERGY_NAME_PRE_N),
        getFunc = function() return BSCAS.SV.SELECTED_PRIO_PRESET end,
        setFunc = function(_) end,
        reference = "BSCAS_PresetPrioEditbox",
    })

    AddControl({
        type = "button",
        name = GetString(SI_SYNERGY_NAME_PRE_B_S),
        func = function()
            local name = BSCAS_PresetPrioEditbox.editbox:GetText()
            BSCAS:CreatePrioPreset(name, true)
        end,
    })

    -- Preset Dropdown
    AddControl({
        type = "dropdown",
        name = GetString(SI_SYNERGY_NAME_PRE_S),
        choices = BSCAS:GetListPrioNames(),
        getFunc = function() return BSCAS.SV.SELECTED_PRIO_PRESET end,
        setFunc = function(value)
            CHAT_ROUTER:AddSystemMessage(zo_strformat(
                "|cFFFFFFBSCs-AS Loading Priority Preset: <<1>>|r", value))
            BSCAS.PlaySound(1, SOUNDS.OUTFIT_GAMEPAD_UNDO_CHANGES)
            BSCAS:ApplyPrioPreset(value)
        end,
        scrollable = 12,
        reference = "BSCAS_PresetPrioDropdown",
    })

    AddControl({
        type = "button",
        name = GetString(SI_SYNERGY_NAME_PRE_B_D),
        func = function()
            local name = BSCAS_PresetPrioDropdown.data.getFunc()
            BSCAS:DeletePrioPreset(name)
        end,
        isDangerous = true,
        warning = GetString(SI_SYNERGY_NAME_PRE_B_D) .. "?",
    })
    
	AddDivider()
	AddControl({
        type = "editbox",
        name = GetString(SI_SYNERGY_NAME_PRE_EB),
        tooltip = GetString(SI_SYNERGY_NAME_PRE_EB_I),
        isMultiline = true,
        isExtraWide = true,
        maxChars = 6000,
        getFunc = function() return BSCAS:ExportPrioPreset(BSCAS.SV.SELECTED_PRIO_PRESET) end,
        setFunc = function(value)  end,
        reference = "BSCAS_PresetPrioAddEditBox",
    })	
    AddControl({
        type = "button",
        name = GetString(SI_SYNERGY_NAME_PRE_IMP),
        func = function()
			BSCAS:ImportPrioPreset(BSCAS_PresetPrioAddEditBox.editbox:GetText())
        end,
        isDangerous = true,
        warning = GetString(SI_SYNERGY_NAME_PRE_W),
    })
end

---------------------------------------------------------------------------------------------------
-- ⚙️ Synergy Override List
---------------------------------------------------------------------------------------------------
local function AddSynergyOverride()
    AddControl({
        type = "header",
        name = GetString(SI_SYNERGY_UI_PRIO_SPO),
    })
	
	local MAX_GROUPS = 25 -- only 25 unique AvA rank icons available
	local SelectedGroup = nil
	BSCAS._knownSearchText = BSCAS._knownSearchText or ""
	BSCAS._knownSearchFilter = BSCAS._knownSearchFilter or ""
		
	local function GetSelectedTitleName()
		local retname = GetString(SI_SYNERGY_UI_PRIO_PRIO_SELECT_TITLE)
		local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
		if not preset then return retname end
		local idx = SelectedGroup
		if not idx then return retname end
		preset.groups = preset.groups or retname
		if not preset or not preset.groups then return retname end
		local group = preset.groups[idx]
		if not group then return retname end	
		
		return string.format("%s [%s]", retname, group.name)		
	end

	-- Helper to generate a short, 32-bit safe unique ID
	local function GenerateShortId()
		-- Kombiniert Zeitrest + Zufall (max ca. 99 Mio)
		return (GetTimeStamp() % 1000000) * 100 + math.random(1, 99)
	end

	AddControl({
		type = "orderlistbox",
		name = GetString(SI_SYNERGY_UI_PRIO_APP),
		minHeight = 150, maxHeight = 150, rowHeight = 30,
		showPosition = true,
		disableDrag = false,
		disableButtons = false,
		showRemoveEntryButton = true,
		askBeforeRemoveEntry = true,
		isExtraWide = true,
		reference = "BSCAS_OrderListBoxPriority",

		-- Einträge aus dem aktuellen Preset (Quelle der Wahrheit: preset.groups)
		getFunc = function()
			local entries = {}
			local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
			if not preset then
				return { { uniqueKey = 1, value = 1, text = "-", tooltip = GetString(SI_SYNERGY_UI_PRIO_NO_GROUPS) } }
			end
			preset.groups = preset.groups or {}

			for i, group in ipairs(preset.groups) do
				-- 32-Bit-safe numerische ID erzeugen, falls fehlt
				if not group.id or type(group.id) ~= "number" then
					group.id = GenerateShortId()
				end

				local prio = i -- 1 = höchste Priorität
				local rankIconIndex = math.max(1, (MAX_GROUPS - prio + 1) * 2) -- 1..25 → 50..2
				local iconPath = GetAvARankIcon(rankIconIndex) or "/esoui/art/icons/icon_missing.dds"
				local name = group.name or ("Group " .. i)
				local count = (group.synergies and #group.synergies or 0)

				table.insert(entries, {
					uniqueKey = group.id,    -- stabil pro Gruppe
					value     = group.id,    -- setFunc bekommt ID zurück
					text      = string.format("|t24:24:%s|t %s  |c808080(%d)|r", iconPath, name, count),
					tooltip   = string.format("Group '%s' – contains %d synergies\nPriority: %d", name, count, prio),
				})
			end

			if #entries == 0 then
				entries[1] = { uniqueKey = 1, value = 1, text = "-", tooltip = GetString(SI_SYNERGY_UI_PRIO_NO_GROUPS_A) }
			end
			return entries
		end,

		-- Reorder anwenden (nur Reihenfolge/Prio)
		setFunc = function(newOrder)
			local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
			if not preset or not preset.groups then return end

			-- ID → Group Lookup
			local byId = {}
			for _, g in ipairs(preset.groups) do
				if g.id then byId[g.id] = g end
			end

			local reordered = {}
			for _, entry in ipairs(newOrder) do
				local g = byId[entry.value]
				if g then table.insert(reordered, g) end
			end

			-- Safety: auf 25 begrenzen
			while #reordered > MAX_GROUPS do
				table.remove(reordered)
			end

			preset.groups = reordered

			-- UI neu zeichnen (ohne Rekursion)
			zo_callLater(function()
				local ctrl = _G["BSCAS_OrderListBoxPriority"]
				if ctrl and ctrl.UpdateValue then
					ctrl:UpdateValue(false)
				end
			end, 10)
		end,

		-- Dialog zum Hinzufügen
		addEntryDialog = {
			title = GetString(SI_SYNERGY_UI_PRIO_PRIO_TITLE_ADD), -- "Add new group"
			text  = GetString(SI_SYNERGY_UI_PRIO_PRIO_TEXT),      -- "Enter a unique name for the new group"
			textType = TEXT_TYPE_ALL,
			maxInputCharacters = 30,
			selectAll = true,
			defaultText = "",
			validatesText = true,
			validator = function(text)
				text = zo_strtrim(text or "")
				if text == "" then return false end

				local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
				if not preset then return false end
				preset.groups = preset.groups or {}

				if #preset.groups >= MAX_GROUPS then
					ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR,
						string.format("Maximum of %d groups reached!", MAX_GROUPS))
					return false
				end

				-- keine Doppel-Namen
				for _, g in ipairs(preset.groups) do
					if zo_strlower(g.name or "") == zo_strlower(text) then
						ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR,
							GetString(SI_SYNERGY_UI_PRIO_PRIO_ALERT))
						return false
					end
				end
				return true
			end,
		},

		-- Nach dem Dialog: hinzufügen & UI refresh
		addEntryCallbackFunction = function(orderListBox, newAddedEntry)
			local newName = newAddedEntry and zo_strtrim(newAddedEntry.text or "")
			if not newName or newName == "" then return false end

			local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
			if not preset then return false end
			preset.groups = preset.groups or {}

			if #preset.groups >= MAX_GROUPS then
				ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR,
					string.format("Maximum of %d groups reached!", MAX_GROUPS))
				return false
			end

			table.insert(preset.groups, {
				id = GenerateShortId(),
				name = newName,
				synergies = {},
			})

			local ctrl = _G["BSCAS_OrderListBoxPriority"]
			if ctrl and ctrl.UpdateValue then
				ctrl:UpdateValue(false)
			end

			-- Optional: Export-String aktualisieren
			if BSCAS_PresetPrioAddEditBox and BSCAS_PresetPrioAddEditBox.editbox then
				BSCAS_PresetPrioAddEditBox.editbox:SetText(BSCAS:ExportPrioPreset(BSCAS.SV.SELECTED_PRIO_PRESET))
			end
			return true
		end,

		-- Gruppe löschen (nach ID)
		removeEntryCallbackFunction = function(_, selectedEntry)
			local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
			if not preset or not preset.groups then return false end
			if not selectedEntry or not selectedEntry.value then return false end

			local id = selectedEntry.value
			local newgroups = {}
			for _, g in ipairs(preset.groups) do
				if g.id ~= id then
					table.insert(newgroups, g)
				end
			end
			preset.groups = newgroups

			local ctrl = _G["BSCAS_OrderListBoxPriority"]
			if ctrl and ctrl.UpdateValue then
				ctrl:UpdateValue(false)
			end
			SelectedGroup = nil
			BSCAS_OrderListBoxPrioSynergy.label:SetText(GetSelectedTitleName())
			return true
		end,
		
		rowSelectedCallback = function()
			return function(orderListBox, previouslySelectedData, selectedData, reselectingDuringRebuild)
				if selectedData then
					local idx = ZO_ScrollList_GetSelectedDataIndex(orderListBox.scrollListControl)
					local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
					if not preset or not preset.groups then return end
					local group = preset.groups[idx]
					if not group then return end
					SelectedGroup = idx
					BSCAS_OrderListBoxPrioSynergy:UpdateValue(false)
					BSCAS_OrderListBoxPrioSynergy.label:SetText(GetSelectedTitleName())
				end
			end
		end,
	})
	
	local function GetSynergysFromSelectedPreset()
		local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
		if not preset then return {} end
		preset.groups = preset.groups or {}
		if not preset or not preset.groups then return {} end
		local usedSynegyies = { }
		for i, group in ipairs(preset.groups) do
			local list = group.synergies or {}
			for i, id in pairs(list) do
				usedSynegyies[id] = true
			end
		end		
		return usedSynegyies
	end
	
	local function NormalizeKnownSearchText(value)
		return zo_strlower(zo_strtrim(value or ""))
	end
	
	local function RefreshKnownSynergyList()
		local ctrl = _G["BSCAS_OrderListBoxSynergy"]
		if ctrl and ctrl.UpdateValue then
			ctrl:UpdateValue(false)
			zo_callLater(function()
				if BSCAS.Known_Paint then
					BSCAS.Known_Paint()
				end
			end, 10)
		end
	end
	
	local function SetKnownSearchText(value)
		value = value or ""
		local searchText = NormalizeKnownSearchText(value)
		if BSCAS._knownSearchText == value and BSCAS._knownSearchFilter == searchText then return end
		BSCAS._knownSearchText = value
		BSCAS._knownSearchFilter = searchText
		RefreshKnownSynergyList()
	end
	
	AddControl({
		width = "half",
		type = "custom",
		minHeight = 40,
	})
	AddControl({
		type = "editbox",
		--name = "",
		width = "half",
		isExtraWide = true,
		getFunc = function() return BSCAS._knownSearchText or "" end,
		setFunc = function(value)
			SetKnownSearchText(value)
		end,
		reference = "BSCAS_KnownSynergySearchEditbox",
	})
	
	zo_callLater(function()
		if BSCAS_KnownSynergySearchEditbox and BSCAS_KnownSynergySearchEditbox.editbox then
			BSCAS_KnownSynergySearchEditbox.editbox:SetHandler("OnTextChanged", function(editbox)
				SetKnownSearchText(editbox:GetText())
			end)
		end
	end, 100)

	-- Selected Group
    AddControl({
        type = "orderlistbox",
        name = GetSelectedTitleName(),
        width = "half",
        minHeight = 250, maxHeight = 250, rowHeight = 30,
        showPosition = false, disableDrag = true, disableButtons = true,
        isExtraWide = true,
        reference = "BSCAS_OrderListBoxPrioSynergy", 
        getFunc = function() 
			local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
			if not preset then return {} end
			local idx = SelectedGroup
			if not idx then return {} end
			preset.groups = preset.groups or {}
			if not preset or not preset.groups then return {} end
			local group = preset.groups[idx]
			if not group then return {} end		
		
			local list = group.synergies or {}
			
            local entries, sorted = {}, {}
			for i, id in pairs(list) do
                table.insert(sorted, {
                    id = id,
                    name = zo_strformat("<<1>>", GetAbilityName(id)),
                })
            end
            table.sort(sorted, function(a, b) return a.name < b.name end)
			
            for k, s in ipairs(sorted) do
                table.insert(entries, {
                    uniqueKey = k,
                    value = s.id,
                    text = string.format("|t24:24:%s|t %s", GetAbilityIcon(s.id), s.name),
                    tooltip = zo_strformat("ID: <<2>> Prio: <<1>>", idx, s.id),
                })
            end
						
            if #entries == 0 then
				return {}
            end
            return entries
		end,
		setFunc = function(newOrder)			
        end,
		removeEntryCallbackFunction = function(_, selectedEntry)
			local preset = BSCAS.SV_acc.PRIO_PRESETS[BSCAS.SV.SELECTED_PRIO_PRESET]
			if not SelectedGroup then return false end
			if not preset or not preset.groups then return false end
			if not selectedEntry or not selectedEntry.value then return false end

			local abilityId = selectedEntry.value
			BSCAS:RemoveSynergyFromGroup(BSCAS.SV.SELECTED_PRIO_PRESET, SelectedGroup, abilityId)			
			BSCAS_OrderListBoxPrioSynergy:UpdateValue(false)
			BSCAS_OrderListBoxSynergy:UpdateValue(false)
			return true
		end,
    })
	
    -- Known Synergies
	
	-- globale Auswahlstruktur
	BSCAS._knownSel = { ids = {}, lastIndex = nil }
	BSCAS._knownIndexToId = {}

	local function _KnownGetSL()
		local ctrl = _G["BSCAS_OrderListBoxSynergy"]
		return ctrl and ctrl.orderListBox and ctrl.orderListBox.scrollListControl
	end

	function BSCAS.Known_RebuildIndexMap(sl)
		sl = sl or _KnownGetSL()
		if not sl or not sl.data then return end
		BSCAS._knownIndexToId = {}
		for i, entry in ipairs(sl.data) do
			BSCAS._knownIndexToId[i] = entry.data.value
			-- Basistext einmal puffern, damit wir Farben umschalten können
			if entry.data._baseText == nil then
				entry.data._baseText = entry.data.text
			end
		end
	end

	function BSCAS.Known_Paint(sl)
		sl = sl or _KnownGetSL()
		if not sl or not sl.data then return end
		for _, entry in ipairs(sl.data) do
			local id   = entry.data.value
			local base = entry.data._baseText or entry.data.text
			if BSCAS._knownSel.ids[id] then
				entry.data.text = "|c00FF00" .. base .. "|r"   -- grün markiert
			else
				entry.data.text = base
			end
		end
		ZO_ScrollList_RefreshVisible(sl)  -- nur sichtbare Zeilen neu aufbauen (Selektion bleibt!)
	end
	
	function BSCAS:ClearSelectedKnown()
		if BSCAS._knownSel then BSCAS._knownSel.ids = {} end
		if BSCAS_OrderListBoxSynergy and BSCAS_OrderListBoxSynergy.orderListBox then
			local sl = BSCAS_OrderListBoxSynergy.orderListBox.scrollListControl
			BSCAS.Known_Paint(sl)
		end
	end

	-- Generic: holt IDs aus einem Set; optional in UI-Reihenfolge anhand eines ScrollListControls
	function BSCAS:GetSelectedIds(selectionSet, scrollListControl)
		local set = selectionSet or {}
		local out = {}

		if scrollListControl and scrollListControl.data then
			-- in der Reihenfolge, wie sie im UI steht
			for i = 1, #scrollListControl.data do
				local id = scrollListControl.data[i].data.value
				if set[id] then table.insert(out, id) end
			end
		else
			-- beliebige Reihenfolge
			for id in pairs(set) do table.insert(out, id) end
			table.sort(out) -- optional
		end
		return out
	end

	-- Speziell für die "Known Synergies" OrderListBox
	function BSCAS:GetSelectedKnownIds(keepUiOrder)
		local set = (BSCAS._knownSel and BSCAS._knownSel.ids) or {}
		if keepUiOrder and _G["BSCAS_OrderListBoxSynergy"]
		   and _G["BSCAS_OrderListBoxSynergy"].orderListBox then
			local sl = _G["BSCAS_OrderListBoxSynergy"].orderListBox.scrollListControl
			return self:GetSelectedIds(set, sl)
		end
		return self:GetSelectedIds(set, nil)
	end
	
	AddControl({
        type = "orderlistbox",
        name = GetString(SI_SYNERGY_UI_PRIO_KNOWN),
        width = "half",
        minHeight = 250, maxHeight = 250, rowHeight = 30,
        showPosition = false, disableDrag = true, disableButtons = true,
        isExtraWide = true,
        reference = "BSCAS_OrderListBoxSynergy",

        getFunc = function()
            local entries, sorted = {}, {}
            local list = BSCAS.SV_acc.SYNERGY_LIST or {}
			local searchText = BSCAS._knownSearchFilter or ""
			
			local usedSynegyies = GetSynergysFromSelectedPreset()
			local visibleIds = {}

            for id, data in pairs(list) do
				local name = zo_strformat("<<1>>", GetAbilityName(id))
				local lowerName = zo_strlower(name or "")
				local matchesSearch = searchText == ""
					or string.find(lowerName, searchText, 1, true)
					or string.find(tostring(id), searchText, 1, true)
				
				if not usedSynegyies[id] and matchesSearch then
					table.insert(sorted, {
						id = id,
						prio = data.priority or 0,
						zoneid = data.zoneid or -1,
						name = name,
					})
				end
            end

            table.sort(sorted, function(a, b)
				local nameA = zo_strlower(a.name or "")
				local nameB = zo_strlower(b.name or "")
				if nameA == nameB then
					return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
				end
				return nameA < nameB
            end)
			
			BSCAS._knownIndexToId = {}

            for k, s in ipairs(sorted) do
				BSCAS._knownIndexToId[k] = s.id
				visibleIds[s.id] = true
                local tt = s.zoneid ~= -1
                    and zo_strformat("ID: <<3>> Prio: <<2>>\nSeen at: <<1>> ", GetZoneNameById(s.zoneid), s.prio, s.id)
                    or zo_strformat("ID: <<2>> Prio: <<1>>", s.prio, s.id)
                table.insert(entries, {
                    uniqueKey = k,
                    value = s.id,
                    prio = s.prio,
                    text = string.format("|t24:24:%s|t %s", GetAbilityIcon(s.id), s.name),
                    tooltip = tt,
                })
            end
			
			if BSCAS._knownSel and BSCAS._knownSel.ids then
				for id in pairs(BSCAS._knownSel.ids) do
					if not visibleIds[id] then
						BSCAS._knownSel.ids[id] = nil
					end
				end
			end

            if #entries == 0 then
                entries[1] = { uniqueKey = 1, value = 0, text = "-", tooltip = GetString(SI_SYNERGY_UI_PRIO_UNKNOWN) }
            end
            return entries
        end,
        setFunc = function(_) end,
		rowSelectedCallback = function()
			return function(orderListBox, previouslySelectedData, selectedData, reselectingDuringRebuild)
				if not selectedData then return end
				if selectedData.value == 0 then return end

				local sl  = orderListBox.scrollListControl
				local idx = ZO_ScrollList_GetSelectedDataIndex(sl)
				if not idx then return end

				-- Map (Index -> AbilityId) aktualisieren, falls nötig
				BSCAS.Known_RebuildIndexMap(sl)

				local id        = selectedData.value
				local sel       = BSCAS._knownSel          -- { ids = {[abilityId]=true,...}, lastIndex = number }
				local shiftDown = IsShiftKeyDown and IsShiftKeyDown()
				local ctrlDown  = IsControlKeyDown and IsControlKeyDown()

				if shiftDown then
					-- SHIFT = TOGGLE-ONLY (kein Range). Bereits markiert? -> abwählen, sonst hinzufügen
					if sel.ids[id] then
						sel.ids[id] = nil
					else
						sel.ids[id] = true
					end
					sel.lastIndex = idx
					BSCAS.Known_Paint(sl)                             -- nur Farben aktualisieren
					ZO_ScrollList_SelectData(sl, nil, nil, nil, true) -- native Auswahl raus
					return
				end

				if ctrlDown then
					-- CTRL = ebenfalls Toggle, multi-select
					sel.ids[id] = sel.ids[id] and nil or true
					sel.lastIndex = idx
					BSCAS.Known_Paint(sl)
					ZO_ScrollList_SelectData(sl, nil, nil, nil, true)
					return
				end

				-- Plain Click = Einzelauswahl
				sel.ids = { [id] = true }
				sel.lastIndex = idx
				BSCAS.Known_Paint(sl)
				ZO_ScrollList_SelectData(sl, nil, nil, nil, true)
			end
		end,
    })

    -- Buttons
    AddControl({
        type = "button",
        width = "half",
        name = GetString(SI_SYNERGY_UI_PRIO_REMOVE),
        func = function()
            BSCAS_OrderListBoxPrioSynergy.orderListBox:RemoveSelectedEntry()
        end,
    })

    AddControl({
        type = "button",
        width = "half",
        name = GetString(SI_SYNERGY_UI_PRIO_ADD),
        func = function()
			if SelectedGroup then
				local list = BSCAS:GetSelectedKnownIds(true)
				for i, abilityId  in pairs(list) do
					BSCAS:AddSynergyToGroup(BSCAS.SV.SELECTED_PRIO_PRESET, SelectedGroup, abilityId)
				end
				BSCAS:ClearSelectedKnown()
			end
        end,
    })
end

---------------------------------------------------------------------------------------------------
-- 🚀 Init
---------------------------------------------------------------------------------------------------
function BSCAS:InitPriorityMenu()
    AddBasicSettings()
    AddAutoLoadPreset()
    AddPresetSettings()
    AddSynergyOverride()
end
