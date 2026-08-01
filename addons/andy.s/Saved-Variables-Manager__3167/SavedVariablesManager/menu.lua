local M = SavedVariablesManager
local LAM = LibAddonMenu2
local VISIBLE_ROWS = 15 -- max rows in dropdown lists before showing scroll bar

local WARNING = "|cFF2200WARNING! Always make a backup of your SavedVariables folder before modifying data inside it!|r"--|t32:32:/esoui/art/miscellaneous/eso_icon_warning.dds|t

-- Remember currently open panel and reload UI.
local function ReloadPanel()
    local saveData = ZO_Ingame_SavedVariables["LAM"] or {}
    saveData.reopenPanel = LAM.currentAddonPanel:GetName()
    ZO_Ingame_SavedVariables["LAM"] = saveData
	ReloadUI()
end

-- Error message.
local function Alert(msg)
	ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, msg)
end

local function IsEmpty(s)
	return not s or s == ""
end

local function trim(s)
	return s:match("^%s*(.-)%s*$")
end

function M.BuildMenu(SV)

	local panel = {
		type = "panel",
		name = "Saved Variables Manager",
		displayName = "Saved Variables Manager",
		author = "|cFFFF00@andy.s|r",
		version = string.format("|c00FF00%s|r", M.version),
		--website = "https://www.esoui.com/downloads/info2918-PerfectWeave.html",
		donation = "https://www.esoui.com/downloads/info2311-HodorReflexes-DPSampUltimateShare.html#donate",
		registerForRefresh = true,
	}

	local UpdateAddons, UpdateUsers, UpdateSourceCharacters, UpdateTargetCharacters, UpdateNamespaces
	local emptyTable = {}

	-- Get or set saved variable's value.
	local function sv(name, value)
		if not value then
			return SV[name] == nil and "" or SV[name]
		else
			SV[name] = value
		end
	end

	local addons = {}
	local selectedAddon = sv("addon")
	function UpdateAddons()
		addons = {}
		-- Form a list from addon names.
		for k in pairs(M.GetAddons()) do
			table.insert(addons, k)
		end
		-- Sort alphabetically.
		table.sort(addons)
		-- Fill addons dropdown.
		SavedVariablesManager_AddonList:UpdateChoices(addons, addons)
		-- Update users list.
		if SavedVariablesManager_AddonList.choices[selectedAddon] then UpdateUsers() end
	end

	local sourceUser = sv("sourceUser")
	local targetUser = sv("targetUser") or sourceUser
	function UpdateUsers()
		-- GetUsers() returns already sorted @ names, so we don't need to do anything with them.
		local users = M.GetUsers(selectedAddon)
		-- Update dropdown lists.
		SavedVariablesManager_SourceUserList:UpdateChoices(users, users)
		SavedVariablesManager_TargetUserList:UpdateChoices(users, users)
		 -- Change selected user if the new list doesn't contain current user.
		if not SavedVariablesManager_SourceUserList.choices[sourceUser] then sourceUser = users[1] end
		if not SavedVariablesManager_TargetUserList.choices[targetUser] then targetUser = users[1] end
		-- Update characters list.
		UpdateSourceCharacters()
		UpdateTargetCharacters()
	end

	local sourceCharacter = sv("sourceCharacter")
	local targetCharacter = sv("targetCharacter")
	function UpdateSourceCharacters()
		local characters = {}
		local charactersNames = {}
		data = M.GetCharacters(selectedAddon, sourceUser)
		for _, v in ipairs(data) do
			table.insert(characters, v.id)
			table.insert(charactersNames, v.full_name)
		end
		SavedVariablesManager_SourceCharacterList:UpdateChoices(charactersNames, characters)
		 -- Change selected character if the new list doesn't contain current character.
		if not SavedVariablesManager_SourceCharacterList.choices[sourceCharacter] then sourceCharacter = characters[1] end
		-- Update namespaces list.
		UpdateNamespaces()
	end
	function UpdateTargetCharacters()
		local characters = {}
		local charactersNames = {}
		data = M.GetCharacters(selectedAddon, targetUser)
		for _, v in ipairs(data) do
			table.insert(characters, v.id)
			table.insert(charactersNames, v.full_name)
		end
		SavedVariablesManager_TargetCharacterList:UpdateChoices(charactersNames, characters)
		if not SavedVariablesManager_TargetCharacterList.choices[targetCharacter] then targetCharacter = characters[1] end
	end

	local selectedNamespace = sv("namespace")
	function UpdateNamespaces()
		-- GetUsers() returns already sorted @ names, so we don't need to do anything with them.
		local namespaces = M.GetNamespaces(selectedAddon, sourceUser, sourceCharacter, true)
		-- Update dropdown list.
		SavedVariablesManager_NamespaceList:UpdateChoices(namespaces, namespaces)
		-- Choose all namespaces by default.
		if not SavedVariablesManager_NamespaceList.choices[selectedNamespace] then selectedNamespace = "*" end
	end

	local oldAccountName, newAccountName = sv("oldAccountName"), GetDisplayName()
	--if IsEmpty(newAccountName) then newAccountName = GetDisplayName() end

	local options = {
		{
			type = "description",
			text = WARNING,
		},
		{
			reference = "SavedVariablesManager_AddonList",
			type = "dropdown",
			name = "Saved Variables:",
			tooltip = "List of loaded variables. Every addon names them differently and can even has multiple tables of data, but usually it's obvious from the name to which addon they belong.",
			getFunc = function() return selectedAddon end,
			setFunc = function(value)
				selectedAddon = value
				sv("addon", selectedAddon)
				UpdateUsers()
			end,
			scrollable = VISIBLE_ROWS,
			choices = emptyTable,
			choicesValues = emptyTable,
		},
		{
			type = "header",
			name = "|cFFFACDSource|r",
		},
		{
			reference = "SavedVariablesManager_SourceUserList",
			type = "dropdown",
			name = "Account:",
			tooltip = "UserID inside selected Saved Variables.",
			getFunc = function() return sourceUser end,
			setFunc = function(value)
				sourceUser = value
				sv("sourceUser", sourceUser)
				UpdateSourceCharacters()
			end,
			scrollable = VISIBLE_ROWS,
			choices = emptyTable,
			choicesValues = emptyTable,
			disabled = function() return IsEmpty(selectedAddon) end,
		},
		{
			reference = "SavedVariablesManager_SourceCharacterList",
			type = "dropdown",
			name = "Character:",
			tooltip = "Character name inside selected Account. $AccountWide is a special name for account wide settings. It's not always a good idea to copy account wide data into character's data and vice versa, because their structure can be different.",
			getFunc = function() return sourceCharacter end,
			setFunc = function(value)
				sourceCharacter = value
				sv("sourceCharacter", sourceCharacter)
				UpdateNamespaces()
			end,
			scrollable = VISIBLE_ROWS,
			choices = emptyTable,
			choicesValues = emptyTable,
			disabled = function() return IsEmpty(sourceUser) end,
		},
		{
			reference = "SavedVariablesManager_NamespaceList",
			type = "dropdown",
			name = "Namespace:",
			tooltip = "Some addons categorize their settings, but most likely you want to copy all of them (*).",
			getFunc = function() return selectedNamespace end,
			setFunc = function(value)
				selectedNamespace = value
				sv("namespace", selectedNamespace)
			end,
			scrollable = VISIBLE_ROWS,
			choices = emptyTable,
			choicesValues = emptyTable,
			disabled = function() return IsEmpty(sourceCharacter) end,
		},
		{
			type = "header",
			name = "|cFFFACDTarget|r",
		},
		{
			reference = "SavedVariablesManager_TargetUserList",
			type = "dropdown",
			name = "Account:",
			getFunc = function() return targetUser end,
			setFunc = function(value)
				targetUser = value
				sv("targetUser", targetUser)
				UpdateTargetCharacters()
			end,
			scrollable = VISIBLE_ROWS,
			choices = emptyTable,
			choicesValues = emptyTable,
			disabled = function() return IsEmpty(selectedAddon) end,
		},
		{
			reference = "SavedVariablesManager_TargetCharacterList",
			type = "dropdown",
			name = "Character:",
			getFunc = function() return targetCharacter end,
			setFunc = function(value)
				targetCharacter = value
				sv("targetCharacter", targetCharacter)
			end,
			scrollable = VISIBLE_ROWS,
			choices = emptyTable,
			choicesValues = emptyTable,
			disabled = function() return IsEmpty(targetUser) end,
		},
		{
			type = "button",
			name = "Copy character data",
			func = function()
				local ns = selectedNamespace == "*" and "" or string.format(" |caaaaaa(%s)|r", selectedNamespace)
				local s = string.format(
					"Do you want to copy |cFFFF00%s|r into |cFFFF00%s|r%s?\n\n%s",
					SavedVariablesManager_SourceCharacterList.choices[sourceCharacter],
					SavedVariablesManager_TargetCharacterList.choices[targetCharacter],
					ns,
					WARNING)
				LAM.util.ShowConfirmationDialog("Copy Data", s, function()
					if M.CopyCharacter(selectedAddon, sourceUser, sourceCharacter, targetUser, targetCharacter, selectedNamespace) then
						ReloadPanel()
					else
						Alert("Couldn't copy the character.")
					end
				end)
			end,
			width = "half",
			disabled = function() return IsEmpty(sourceCharacter) or IsEmpty(targetCharacter) end,
		},
		{
			type = "button",
			name = "Delete character",
			func = function()
				local s = string.format(
					"Do you want to delete all data for |cFFFF00%s|r?\n\n%s",
					SavedVariablesManager_TargetCharacterList.choices[targetCharacter],
					WARNING)
				LAM.util.ShowConfirmationDialog("Delete Character", s, function()
					if M.DeleteCharacter(selectedAddon, targetUser, targetCharacter) then
						ReloadPanel()
					else
						Alert("Couldn't delete the character.")
					end
				end)
			end,
			width = "half",
			disabled = function() return IsEmpty(targetCharacter) end,
		},
		{
			type = "submenu",
			name = "|cFFFACDAccount rename & delete|r",
			controls = {
				{
					type = "description",
					text = "|cFFFF00Account names are CaSe sEnSiTiVe. Don't forget the @ sign too!|r",
				},
				{
					type = "editbox",
					name = "Old account name:",
					getFunc = function() return oldAccountName end,
					setFunc = function(value)
						oldAccountName = trim(value)
						sv("oldAccountName", oldAccountName)
					end,
					width = "half",
				},
				{
					type = "editbox",
					name = "New account name:",
					getFunc = function() return newAccountName end,
					setFunc = function(value)
						newAccountName = trim(value)
						--sv("newAccountName", newAccountName)
					end,
					width = "half",
				},
				{
					type = "button",
					name = "Rename old account",
					func = function()
						if oldAccountName == newAccountName then
							Alert("Account names must be different.")
							return
						end
						local s = string.format(
							"Do you want to rename |cFFFF00%s|r to |cFFFF00%s|r in |cFFFFFFALL|r saved variables?\n\n%s",
							oldAccountName,
							newAccountName,
							WARNING)
						LAM.util.ShowConfirmationDialog("Rename Account", s, function()
							local n = M.RenameUser(oldAccountName, newAccountName)
							if n > 0 then
								ReloadPanel()
							else
								Alert(string.format("Account \"%s\" not found.", oldAccountName))
							end
						end)
					end,
					width = "half",
					disabled = function() return IsEmpty(oldAccountName) or IsEmpty(newAccountName) end,
				},
				{
					type = "button",
					name = "Delete old account",
					func = function()
						if oldAccountName == "" then
							Alert("Account name is not specified.")
							return
						end
						local s = string.format(
							"Do you want to delete |cFFFF00%s|r from |cFFFFFFALL|r saved variables?\n\n%s",
							oldAccountName,
							WARNING)
						LAM.util.ShowConfirmationDialog("Delete Account", s, function()
							local n = M.DeleteUser(oldAccountName)
							if n > 0 then
								ReloadPanel()
							else
								Alert(string.format("Account \"%s\" not found.", oldAccountName))
							end
						end)
					end,
					width = "half",
					disabled = function() return IsEmpty(oldAccountName) end,
				},
			},
		},
	}

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(p)
		if p.data.name == panel.name then
			UpdateAddons()
			-- Need to call it twice like this to trigger both setFunc and dropdown refresh.
			SavedVariablesManager_AddonList:UpdateValue(false, selectedAddon)
			SavedVariablesManager_AddonList:UpdateValue()
		end
	end)

	local name = M.name .. "Menu"
    LAM:RegisterAddonPanel(name, panel)
    LAM:RegisterOptionControls(name, options)

end