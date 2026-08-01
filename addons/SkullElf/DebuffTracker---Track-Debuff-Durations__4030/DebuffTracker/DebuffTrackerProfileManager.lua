DebuffTrackerProfileManager = DebuffTrackerProfileManager or {}

local PM = DebuffTrackerProfileManager
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 500
local MONITOR_WIDTH = 400
local HEADER_HEIGHT = 40

local ADVANCED_PANEL_WIDTH = 370
local EXPAND_BUTTON_HEIGHT = 30

PM.isVisible = false
PM.advancedVisible = false
PM.monitorData = {}
PM.profileData = {}

local function AddDebugBackdrop(control, r, g, b, alpha)
    local dbg = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    dbg:SetAnchorFill()
    dbg:SetCenterColor(r or 1, g or 0, b or 0, alpha or 0.4)
    dbg:SetEdgeColor(1, 1, 1, 0.7)
    dbg:SetEdgeTexture(nil, 1, 1, 1)
end

local function FormatSetting(label, value)
    if type(value) == "boolean" then
        return string.format("|cAAAAAA%s:|r %s", label, value and "|c00FF00ON|r" or "|c888888OFF|r")
    elseif type(value) == "number" then
        return string.format("|cAAAAAA%s:|r %.1f", label, value)
    end
end

local function CountEnabledAbilities(tbl)
    local count = 0
    for _, v in pairs(tbl) do
        if v == true then
            count = count + 1
        end
    end
    return count
end

function PM:GetSortedProfileData()
    local data = {}

    local currentProfile = DebuffTracker.savedVars.currentProfile
    local profiles = DebuffTracker.savedVars.profiles or {}

    for name, profile in pairs(profiles) do
        local folder = profile.folder or "Uncategorized"
        
        data[folder] = data[folder] or {}

        table.insert(data[folder], {
            name = name,
            description = string.format("Includes %d tracked abilities", profile.trackedAbilities and CountEnabledAbilities(profile.trackedAbilities) or 0),
            isActive = name == currentProfile,
        })
    end

    local sorted = {}
    for folderName, profiles in pairs(data) do
        table.sort(profiles, function(a, b) return a.name < b.name end)
        
        table.insert(sorted, { name = folderName, profiles = profiles })
    end

    table.sort(sorted, function(a, b) return a.name < b.name end)

    return sorted
end


local function BuildMonitorSection()
    local win = PM.window

    if not PM.monitorPanel then
        PM.monitorPanel = WINDOW_MANAGER:CreateControl("DebuffTrackerMonitorPanel", win, CT_CONTROL)
        PM.monitorPanel:SetDimensions(MONITOR_WIDTH, WINDOW_HEIGHT - 50)
        PM.monitorPanel:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 50)
    end

    if not PM.monitorScroll then
        local scroll = WINDOW_MANAGER:CreateControlFromVirtual("DebuffTrackerMonitorScroll", PM.monitorPanel, "ZO_ScrollContainer")
        scroll:ClearAnchors()
        scroll:SetAnchor(TOPLEFT, PM.monitorPanel, TOPLEFT, 0, 0)
        scroll:SetAnchor(BOTTOMRIGHT, PM.monitorPanel, BOTTOMRIGHT, 0, -40)
        PM.monitorScroll = scroll
    end

    local content = PM.monitorScroll:GetNamedChild("ScrollChild")

    if content.rows then
        for _, row in ipairs(content.rows) do
            row:SetHidden(true)
            row:SetParent(nil)
        end
    end
    content.rows = {}

    local generalLabel = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
    generalLabel:SetFont("ZoFontGameBold")
    generalLabel:SetText("General Settings")
    generalLabel:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 0)

    local prev = generalLabel

    local settings = {
		FormatSetting("Show Marker", DebuffTracker.savedVars.showMarker),
		FormatSetting("Track Debuffs Only", DebuffTracker.savedVars.trackDebuffsOnly),
		FormatSetting("Cast By You Only", DebuffTracker.savedVars.trackEffectsCastByYouOnly),
		FormatSetting("Cast To You Only", DebuffTracker.savedVars.trackEffectsCastToYouOnly),
		FormatSetting("Highlight Target", DebuffTracker.savedVars.HighlightTarget),
		FormatSetting("Show Uptime", DebuffTracker.savedVars.ShowUptime),
		FormatSetting("Bar Blink", DebuffTracker.savedVars.BarBlink),
		FormatSetting("Gradient Bars", DebuffTracker.savedVars.useGradientBarColor ~= false),
		FormatSetting("Always Show", DebuffTracker.savedVars.alwaysShow),
		FormatSetting("Decimals", DebuffTracker.savedVars.decimalNum),
		FormatSetting("Minimum Difficulty", DebuffTracker.savedVars.minimumDifficulty),
		FormatSetting("Max Rows", DebuffTracker.savedVars.maxRows),
		FormatSetting("Bars Above Header", DebuffTracker.savedVars.showBarsAboveHeader),
		FormatSetting("Marker Size", DebuffTracker.savedVars.markerSize),

		FormatSetting("UI Alpha", DebuffTracker.savedVars.ui and DebuffTracker.savedVars.ui.windowAlpha),
		FormatSetting("Bar Alpha", DebuffTracker.savedVars.ui and DebuffTracker.savedVars.ui.barAlpha),
		FormatSetting("Bar Width", DebuffTracker.savedVars.ui and DebuffTracker.savedVars.ui.barWidth),
		FormatSetting("Bar Height", DebuffTracker.savedVars.ui and DebuffTracker.savedVars.ui.barHeight),
	}

	for _, settingText in ipairs(settings) do
		if settingText then
			local line = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
			line:SetFont("ZoFontGame")
			line:SetText(settingText)
			line:SetAnchor(TOPLEFT, prev, BOTTOMLEFT, 0, 4)
			prev = line
		end
	end

    local divider = WINDOW_MANAGER:CreateControl(nil, content, CT_TEXTURE)
    divider:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
    divider:SetHeight(4)
    divider:SetAnchor(TOPLEFT, prev, BOTTOMLEFT, 0, 10)
    divider:SetAnchor(TOPRIGHT, prev, BOTTOMRIGHT, 0, 10)
    prev = divider

    local trackedLabel = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
    trackedLabel:SetFont("ZoFontGameBold")
    trackedLabel:SetText("Tracked Abilities")
    trackedLabel:SetAnchor(TOPLEFT, prev, BOTTOMLEFT, 0, 12)
    prev = trackedLabel

    local tracked = DebuffTracker.GetCurrentlyTrackedAbilities()
    local abilities = {}

    for abilityId in pairs(tracked) do
        table.insert(abilities, {
            id = abilityId,
            name = GetAbilityName(abilityId),
            icon = GetAbilityIcon(abilityId),
            settings = DebuffTracker.savedVars.abilitySettings and DebuffTracker.savedVars.abilitySettings[abilityId] or nil,
        })
    end

    for _, ability in ipairs(abilities) do
		local row = WINDOW_MANAGER:CreateControl(nil, content, CT_CONTROL)

		local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
		icon:SetDimensions(32, 32)
		icon:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
		icon:SetTexture(ability.icon)

		local nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
		nameLabel:SetFont("ZoFontGameBold")
		nameLabel:SetText(ability.name)
		nameLabel:SetAnchor(TOPLEFT, icon, TOPRIGHT, 10, 0)
		nameLabel:SetDimensions(200, 20)

		local s = ability.settings
		local settingsText = ""
		local displayMap = {
			showStacks = "Stacks (All)",
			showStacksOnPrimaryOnly = "Stacks (Primary)",
			showTimer = "Timer",
			ShowUptime = "Uptime",
			HighlightTarget = "Highlight",
			alwaysShow = "Always Show",
			onlyInCombat = "Combat Only",
			trackEffectsCastByYouOnly = "By You Only",
			trackEffectsCastToYouOnly = "To You Only",
			decimalNum = "Decimals",
			maxRows = "Rows",
			barHeight = "BarH",
			barWidth = "Width",
			windowAlpha = "WinAlpha",
			barAlpha = "BarAlpha",
		}

		local order = {
			"showStacks", "showStacksOnPrimaryOnly", "showTimer", "ShowUptime", "HighlightTarget",
			"alwaysShow", "onlyInCombat", "trackEffectsCastByYouOnly", "trackEffectsCastToYouOnly",
			"decimalNum", "maxRows", "barHeight", "barWidth", "windowAlpha", "barAlpha"
		}

		local hasSettings = false
		for _, key in ipairs(order) do
			local label = displayMap[key]
			local val = s and s[key]
			if val ~= nil then
				hasSettings = true
				if type(val) == "boolean" then
					settingsText = settingsText .. string.format("|cAAAAAA%s:|r %s\n", label, val and "|c00FF00Yes|r" or "|c888888No|r")
				elseif type(val) == "number" then
					settingsText = settingsText .. string.format("|cAAAAAA%s:|r %.1f\n", label, val)
				end
			end
		end


		if not hasSettings then
			settingsText = "|c666666Using global defaults|r"
		end
		
	


		local lineCount = select(2, settingsText:gsub("\n", "")) + 1
		local lineHeight = 16
		local padding = 4

		local rowHeight = 28 + (lineCount * lineHeight) + padding
		row:SetDimensions(MONITOR_WIDTH - 20, rowHeight)
		row:SetAnchor(TOPLEFT, prev, BOTTOMLEFT, 0, 4)

		local settingsLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
		settingsLabel:SetFont("ZoFontGameSmall")
		settingsLabel:SetText(settingsText)
		settingsLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 2)
		settingsLabel:SetDimensions(MONITOR_WIDTH - 100, lineCount * lineHeight)
		settingsLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		settingsLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)


		row:SetMouseEnabled(true)
		row:SetHandler("OnMouseEnter", function()
			InitializeTooltip(InformationTooltip, row, RIGHT, 0, 0)
			SetTooltipText(InformationTooltip, settingsText)
		end)
		row:SetHandler("OnMouseExit", function()
			ClearTooltip(InformationTooltip)
		end)

		prev = row
		table.insert(content.rows, row)
	end

end

function PM:ReleasePools()
    -- Ensure objects are reset and released properly
    PM.folderPool:ReleaseAllObjects()
    PM.profilePool:ReleaseAllObjects()
end

function PM:RefreshAdvancedPanel()
    if not PM.advancedPanel then return end
    self:ReleasePools()  -- Ensure pools are cleared properly
    BuildAdvancedPanel()  -- Rebuild the panel with fresh objects
end

function PM:RenameFolder(oldName, newName)
    if not oldName or not newName or oldName == "" or newName == "" or oldName == newName then return end

    local profiles = DebuffTracker.savedVars.profiles or {}
    for _, profile in pairs(profiles) do
        if profile.folder == newName then
            return
        end
    end

    for name, profile in pairs(profiles) do
        if profile.folder == oldName then
            profile.folder = newName
        end
    end

    PM:RefreshAdvancedPanel()
end


function PM:RenameProfile(oldName, newName)
    if not oldName or not newName or oldName == "" or newName == "" or oldName == newName then return end

    local profiles = DebuffTracker.savedVars.profiles or {}
    if profiles[newName] then
        return
    end

    local profile = profiles[oldName]
    if profile then
        profiles[newName] = profile
        profiles[oldName] = nil
    end

    PM:RefreshAdvancedPanel()
end


function PM:DeleteFolder(folderName)
    if not folderName or folderName == "" then return end

    local profiles = DebuffTracker.savedVars.profiles or {}
    for name, profile in pairs(profiles) do
        if profile.folder == folderName then
            profile.folder = "Uncategorized"
        end
    end

    PM:RefreshAdvancedPanel()
end

function PM:InitializeConfirmDialog()
	if PM.confirmDialog then return end

	local dialog = WINDOW_MANAGER:CreateTopLevelWindow("DebuffTrackerSimpleConfirmDialog")
	dialog:SetDimensions(400, 180)
	dialog:SetAnchor(CENTER, GuiRoot, CENTER)
	dialog:SetMovable(true)
	dialog:SetMouseEnabled(true)
	dialog:SetClampedToScreen(true)
	dialog:SetHidden(true)
	PM.confirmDialog = dialog

	-- Background
	local bg = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BACKDROP)
	bg:SetAnchorFill()
	bg:SetCenterColor(0.1, 0.1, 0.1, 0.95)
	bg:SetEdgeColor(0.6, 0.6, 0.6, 1)
	bg:SetEdgeTexture(nil, 1, 1, 1)
	bg:SetDrawLayer(DL_BACKGROUND)

	-- Title
	PM.confirmDialogTitle = WINDOW_MANAGER:CreateControl(nil, dialog, CT_LABEL)
	PM.confirmDialogTitle:SetFont("ZoFontWinH1")
	PM.confirmDialogTitle:SetAnchor(TOPLEFT, dialog, TOPLEFT, 16, 16)

	-- Body
	PM.confirmDialogBody = WINDOW_MANAGER:CreateControl(nil, dialog, CT_LABEL)
	PM.confirmDialogBody:SetFont("ZoFontGameLarge")
	PM.confirmDialogBody:SetWidth(360)
	PM.confirmDialogBody:SetAnchor(TOPLEFT, PM.confirmDialogTitle, BOTTOMLEFT, 0, 14)
	PM.confirmDialogBody:SetVerticalAlignment(TEXT_ALIGN_TOP)

	-- Yes button
	PM.confirmDialogYes = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BUTTON)
	local yesBtn = PM.confirmDialogYes
	yesBtn:SetDimensions(100, 30)
	yesBtn:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -20, -16)
	yesBtn:SetFont("ZoFontGame")
	yesBtn:SetText("Yes")
	yesBtn:SetClickSound(SOUNDS.DIALOG_ACCEPT)

	-- Cancel button
	PM.confirmDialogCancel = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BUTTON)
	local cancelBtn = PM.confirmDialogCancel
	cancelBtn:SetDimensions(100, 30)
	cancelBtn:SetAnchor(RIGHT, yesBtn, LEFT, -10, 0)
	cancelBtn:SetFont("ZoFontGame")
	cancelBtn:SetText("Cancel")
	cancelBtn:SetClickSound(SOUNDS.DIALOG_DECLINE)
	cancelBtn:SetHandler("OnClicked", function()
		dialog:SetHidden(true)
	end)

	dialog:SetHandler("OnKeyUp", function(_, key)
		if key == KEY_ESCAPE then
			dialog:SetHidden(true)
		end
	end)
end

function PM:InitializeModifyDialog()
    if PM.modifyDialog then return end

    local dialog = WINDOW_MANAGER:CreateTopLevelWindow("DebuffTrackerModifyProfileDialog")
    dialog:SetDimensions(400, 290)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER)
    dialog:SetMovable(true)
    dialog:SetMouseEnabled(true)
    dialog:SetClampedToScreen(true)
    dialog:SetHidden(true)
    PM.modifyDialog = dialog

    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.1, 0.1, 0.1, 0.95)
    bg:SetEdgeColor(0.6, 0.6, 0.6, 1)
    bg:SetEdgeTexture(nil, 1, 1, 1)
	bg:SetDrawLayer(DL_BACKGROUND)


    -- Title
    PM.modifyDialogTitle = WINDOW_MANAGER:CreateControl(nil, dialog, CT_LABEL)
    PM.modifyDialogTitle:SetFont("ZoFontWinH1")
    PM.modifyDialogTitle:SetText("Modify Profile")
    PM.modifyDialogTitle:SetAnchor(TOPLEFT, dialog, TOPLEFT, 16, 12)

    -- "Profile Name" Label
    PM.nameLabel = WINDOW_MANAGER:CreateControl(nil, dialog, CT_LABEL)
    PM.nameLabel:SetFont("ZoFontGame")
    PM.nameLabel:SetText("Profile Name:")
    PM.nameLabel:SetAnchor(TOPLEFT, PM.modifyDialogTitle, BOTTOMLEFT, 0, 20)

    -- Backdrop + Edit Box
    local nameBoxBackdrop = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BACKDROP)
    nameBoxBackdrop:SetDimensions(350, 28)
    nameBoxBackdrop:SetCenterColor(0.15, 0.15, 0.15, 0.8)
    nameBoxBackdrop:SetEdgeColor(0.4, 0.4, 0.4, 1)
    nameBoxBackdrop:SetEdgeTexture(nil, 1, 1, 1)
    nameBoxBackdrop:SetAnchor(TOPLEFT, PM.nameLabel, BOTTOMLEFT, 0, 2)

    local nameBox = WINDOW_MANAGER:CreateControlFromVirtual("DebuffTrackerModifyNameEdit", nameBoxBackdrop, "ZO_DefaultEdit")
    nameBox:SetDimensions(346, 24)
    nameBox:SetAnchor(CENTER, nameBoxBackdrop, CENTER, 0, 0)

    -- "Folder" Label
    PM.folderLabel = WINDOW_MANAGER:CreateControl(nil, dialog, CT_LABEL)
    PM.folderLabel:SetFont("ZoFontGame")
    PM.folderLabel:SetText("Folder:")
    PM.folderLabel:SetAnchor(TOPLEFT, nameBoxBackdrop, BOTTOMLEFT, 0, 14)

    -- Folder Dropdown
    local folderDropdown = WINDOW_MANAGER:CreateControlFromVirtual("DebuffTrackerModifyFolderDropdown", dialog, "ZO_ComboBox")
    folderDropdown:SetDimensions(200, 26)
    folderDropdown:SetAnchor(TOPLEFT, PM.folderLabel, BOTTOMLEFT, 0, 2)

    -- Save Button
    PM.modifyDialogSaveButton = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BUTTON)
	local saveBtn = PM.modifyDialogSaveButton

    saveBtn:SetDimensions(100, 30)
    saveBtn:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -20, -16)
    saveBtn:SetFont("ZoFontGame")
	saveBtn:SetText("Save")
    saveBtn:SetClickSound(SOUNDS.DEFAULT_CLICK)

    -- Cancel Button
	PM.modifyDialogCancelButton = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BUTTON)
	local cancelBtn = PM.modifyDialogCancelButton

    cancelBtn:SetDimensions(100, 30)
    cancelBtn:SetAnchor(RIGHT, saveBtn, LEFT, -10, 0)
    cancelBtn:SetFont("ZoFontGame")
	cancelBtn:SetText("Cancel")
    cancelBtn:SetClickSound(SOUNDS.DEFAULT_CLICK)
    cancelBtn:SetHandler("OnClicked", function()
        dialog:SetHidden(true)
    end)
	
end

function PM:ShowModifyDialog(profileName, defaultFolder, isFolderCreation)
    PM:InitializeModifyDialog()

    local dialog = PM.modifyDialog
	
    local nameBox = GetControl("DebuffTrackerModifyNameEdit")
	
	PM.modifyDialogSaveButton:SetHidden(false)
	PM.modifyDialogCancelButton:SetHidden(false)

		
    local folderDropdown = ZO_ComboBox_ObjectFromContainer(GetControl("DebuffTrackerModifyFolderDropdown"))
    local saveBtn = PM.modifyDialogSaveButton


    local isNewProfile = not profileName and not isFolderCreation

    if isFolderCreation then
		PM.modifyDialogTitle:SetText("New Folder")
		nameBox:SetText("")

		PM.nameLabel:SetText("Folder Name:")
		PM.folderLabel:SetHidden(true)
		folderDropdown:GetContainer():SetHidden(true)

		saveBtn:SetHandler("OnClicked", function()
			local folderName = nameBox:GetText()
			if folderName == "" then return end
			
			DebuffTracker.savedVars.profiles[folderName] = {
				folder = folderName,
				trackedAbilities = {},
			}
			
			PM:RefreshAdvancedPanel()
			
			dialog:SetHidden(true)
		end)

	else
		PM.modifyDialogTitle:SetText(profileName and "Modify Profile" or "New Profile")
		nameBox:SetText(profileName or "")

		PM.nameLabel:SetText("Profile Name:")
		PM.folderLabel:SetHidden(false)
		folderDropdown:GetContainer():SetHidden(false)


        folderDropdown:ClearItems()
        local folderMap = {}
        for _, folder in ipairs(PM:GetSortedProfileData()) do
            folderMap[folder.name] = true
            folderDropdown:AddItem(ZO_ComboBox:CreateItemEntry(folder.name, function()
                folderDropdown:SetSelectedItem(folder.name)
            end))
        end
        if not folderMap["Uncategorized"] then
            folderDropdown:AddItem(ZO_ComboBox:CreateItemEntry("Uncategorized", function()
                folderDropdown:SetSelectedItem("Uncategorized")
            end))
        end

        folderDropdown:SetSelectedItem(defaultFolder or (profileName and DebuffTracker.savedVars.profiles[profileName].folder) or "Uncategorized")

        saveBtn:SetHandler("OnClicked", function()
            local newName = nameBox:GetText()
            local newFolder = folderDropdown:GetSelectedItem()

            if newName == "" then return end

            if profileName and newName ~= profileName then
                PM:RenameProfile(profileName, newName)
            end

            DebuffTracker.savedVars.profiles[newName] = DebuffTracker.savedVars.profiles[newName] or {}
            DebuffTracker.savedVars.profiles[newName].folder = newFolder

            PM:RefreshAdvancedPanel()
            dialog:SetHidden(true)
        end)
    end

    dialog:SetHidden(false)

	dialog:SetDrawTier(DT_HIGH)
	dialog:BringWindowToTop()

	local nameBox = GetControl("DebuffTrackerModifyNameEdit")
	nameBox:TakeFocus()
	
	dialog:SetHandler("OnKeyUp", function(_, key, ctrl, alt, shift, command)
		if key == KEY_ESCAPE then
			dialog:SetHidden(true)
		elseif key == KEY_ENTER then
			if PM.modifyDialogSaveButton and not PM.modifyDialogSaveButton:IsHidden() then
				PM.modifyDialogSaveButton:OnClicked()
			end
		end
	end)




end

PM.folderPool = ZO_ObjectPool:New(
    function(pool)
        local control = WINDOW_MANAGER:CreateControl(nil, PM.advancedScrollContent, CT_CONTROL)
        control:SetDimensions(ADVANCED_PANEL_WIDTH - 20, 30)
        control.label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        control.label:SetFont("ZoFontWinH4")
        control.label:SetColor(0.9, 0.8, 0.5, 1)
        control.label:SetAnchor(LEFT, control, LEFT, 0, 0)
        control.actions = {}
        return control
    end,
	function(control, pool)
		control:SetHidden(true)
		for _, btn in ipairs(control.actions) do
			btn:SetHidden(true)
			btn:SetParent(nil)
		end
		ZO_ClearNumericallyIndexedTable(control.actions)
	end
)

PM.profilePool = ZO_ObjectPool:New(
    function(pool)
        local control = WINDOW_MANAGER:CreateControl(nil, PM.advancedScrollContent, CT_CONTROL)
        control:SetDimensions(ADVANCED_PANEL_WIDTH - 20, 30)
        control.label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        control.label:SetFont("ZoFontGame")
        control.label:SetAnchor(LEFT, control, LEFT, 20, 0)
        control.actions = {}
        return control
    end,
	function(control, pool)
		control:SetHidden(true)
		for _, btn in ipairs(control.actions) do
			btn:SetHidden(true)
			btn:SetParent(nil)
		end
		ZO_ClearNumericallyIndexedTable(control.actions)
	end
)

function PM:ShowSimpleConfirmDialog(title, body, onConfirm)
	PM:InitializeConfirmDialog()

	PM.confirmDialogTitle:SetText(title or "Confirm")
	PM.confirmDialogBody:SetText(body or "")

	PM.confirmDialogYes:SetHandler("OnClicked", function()
		PM.confirmDialog:SetHidden(true)
		if onConfirm then onConfirm() end
	end)

	PM.confirmDialog:SetHidden(false)
	PM.confirmDialog:SetDrawTier(DT_HIGH)
	PM.confirmDialog:BringWindowToTop()
end

function PM:RefreshMonitorPanel()
    if not PM.monitorScroll then return end

    local content = PM.monitorScroll:GetNamedChild("ScrollChild")

    for _, row in ipairs(content.rows) do
        row:SetHidden(true)
        row:SetParent(nil)
    end

    content.rows = {}

    BuildMonitorSection()
	DebuffTracker.RefreshDebuffsPanel()
end

local function BuildAdvancedPanel()
    local win = PM.window

    if not PM.advancedPanel then
        PM.advancedPanel = WINDOW_MANAGER:CreateControl("DebuffTrackerAdvancedPanel", win, CT_BACKDROP)
        PM.advancedPanel:SetDimensions(ADVANCED_PANEL_WIDTH, WINDOW_HEIGHT - 50)
        PM.advancedPanel:SetAnchor(TOPLEFT, PM.monitorPanel, TOPRIGHT, 10, 0)
        PM.advancedPanel:SetCenterColor(0.1, 0.1, 0.1, 0.85)
        PM.advancedPanel:SetEdgeColor(0.4, 0.4, 0.4, 0.6)
        PM.advancedPanel:SetEdgeTexture(nil, 1, 1, 1)
        PM.advancedPanel:SetHidden(true)

        PM.advancedScroll = WINDOW_MANAGER:CreateControlFromVirtual("DebuffTrackerAdvancedScroll", PM.advancedPanel, "ZO_ScrollContainer")
        PM.advancedScroll:SetAnchorFill()
        PM.advancedScrollContent = PM.advancedScroll:GetNamedChild("ScrollChild")
    end

    local content = PM.advancedScrollContent

    PM.folderPool:ReleaseAllObjects()
    PM.profilePool:ReleaseAllObjects()

    local offsetY = 0

    local headerRow = WINDOW_MANAGER:CreateControl(nil, content, CT_CONTROL)
    headerRow:SetDimensions(ADVANCED_PANEL_WIDTH - 20, 40)
    headerRow:SetAnchor(TOPLEFT, content, TOPLEFT, 10, offsetY)

    local headerLabel = WINDOW_MANAGER:CreateControl(nil, headerRow, CT_LABEL)
    headerLabel:SetFont("ZoFontWinH3")
    headerLabel:SetText("Folders")
    headerLabel:SetAnchor(LEFT, headerRow, LEFT, 0, 0)

	local uniqueID = "DebuffTrackerNewFolderBtn_" .. GetGameTimeMilliseconds()

	local newFolderBtn = WINDOW_MANAGER:CreateControlFromVirtual(uniqueID, headerRow, "ZO_DefaultButton")
	newFolderBtn:SetDimensions(140, 30)
	newFolderBtn:SetAnchor(RIGHT, headerRow, RIGHT, 0, 0)
	newFolderBtn:SetFont("ZoFontGameLargeBold")
	newFolderBtn:SetText("New Folder")
	newFolderBtn:SetClickSound(SOUNDS.DEFAULT_CLICK)
	newFolderBtn:SetHandler("OnClicked", function()
		PM:ShowModifyDialog(nil, nil, true)
	end)


    local glow = WINDOW_MANAGER:CreateControl(nil, newFolderBtn, CT_BACKDROP)
    glow:SetAnchorFill()
    glow:SetCenterColor(1, 1, 1, 0.05)
    glow:SetEdgeColor(1, 1, 1, 0.25)
    glow:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    glow:SetHidden(true)
    newFolderBtn:SetHandler("OnMouseEnter", function() glow:SetHidden(false) end)
    newFolderBtn:SetHandler("OnMouseExit", function() glow:SetHidden(true) end)

    offsetY = offsetY + 50

    local function CreateButton(parent, textureBase, tooltip, anchorTarget, offsetX, onClick)
        local btn = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
        btn:SetDimensions(24, 24)
        btn:SetAnchor(RIGHT, anchorTarget or parent, RIGHT, offsetX, 0)
        btn:SetNormalTexture(textureBase .. "_up.dds")
        btn:SetPressedTexture(textureBase .. "_down.dds")
        btn:SetMouseOverTexture(textureBase .. "_over.dds")
        btn:SetClickSound(SOUNDS.DEFAULT_CLICK)
        btn:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, btn, TOP, 0, 0)
            SetTooltipText(InformationTooltip, tooltip)
        end)
        btn:SetHandler("OnMouseExit", function()
			ClearTooltip(InformationTooltip)
		end)
        btn:SetHandler("OnClicked", onClick)
        return btn
    end

    for _, folder in ipairs(PM:GetSortedProfileData()) do
        local folderRow = PM.folderPool:AcquireObject()
        folderRow:SetHidden(false)
        folderRow:ClearAnchors()
        folderRow:SetAnchor(TOPLEFT, content, TOPLEFT, 10, offsetY)
        folderRow.label:SetText(folder.name)

		local deleteBtn = CreateButton(folderRow, "esoui/art/buttons/decline", "Delete Folder", nil, -4, function()
			PM:ShowSimpleConfirmDialog(
				"Delete Folder",
				zo_strformat("Move all profiles from '<<1>>' to 'Uncategorized'?", folder.name),
				function()
					PM:DeleteFolder(folder.name)
				end
			)
		end)
        table.insert(folderRow.actions, deleteBtn)

        local renameBtn = CreateButton(folderRow, "esoui/art/buttons/edit", "Rename Folder", deleteBtn, -28, function()
            ZO_Dialogs_ShowDialog("ESO_Dialog_TextPrompt", {
                callback = function(newName)
                    if newName and newName ~= "" then
                        PM:RenameFolder(folder.name, newName)
                    end
                end
            }, {
                title = { text = "Rename Folder" },
                mainText = { text = "Enter a new name for folder '" .. folder.name .. "':" },
                buttons = {
                    { text = SI_OK, callback = function(dialog)
                        local ctrl = dialog:GetNamedChild("TextInput")
                        dialog.data.callback(ctrl:GetText())
                    end },
                    { text = SI_CANCEL },
                }
            })
        end)

        table.insert(folderRow.actions, renameBtn)

        local addBtn = CreateButton(folderRow, "esoui/art/progression/addpoints", "Add Profile to '" .. folder.name .. "'", renameBtn, -28, function()
            PM:ShowModifyDialog(nil, folder.name)
        end)

        table.insert(folderRow.actions, addBtn)

        offsetY = offsetY + 34

        for _, profile in ipairs(folder.profiles) do
            local row = PM.profilePool:AcquireObject()
            row:SetHidden(false)
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, content, TOPLEFT, 10, offsetY)
            row.label:SetText(profile.name)

            row:SetMouseEnabled(true)
            row:SetHandler("OnMouseEnter", function()
                InitializeTooltip(InformationTooltip, row, RIGHT, 0, 0)
                SetTooltipText(InformationTooltip, profile.description)
            end)
			row:SetHandler("OnMouseExit", function()
				ClearTooltip(InformationTooltip)
			end)

            local deleteBtn = CreateButton(row, "/esoui/art/buttons/decline", "Delete Profile", nil, -4, function()
				PM:ShowSimpleConfirmDialog(
					"Delete Profile",
					zo_strformat("Delete profile '<<1>>'?", profile.name),
					function()
						DebuffTracker.DeleteProfile(profile.name)
						PM:RefreshAdvancedPanel()
					end
				)
			end)

            table.insert(row.actions, deleteBtn)
            local loadBtn = CreateButton(row, "/esoui/art/buttons/accept", "Load Profile", deleteBtn, -28, function()
				DebuffTracker.ApplyProfile(profile.name)
				PM:RefreshAdvancedPanel()
				PM:RefreshMonitorPanel()

			end)

            table.insert(row.actions, loadBtn)

            local modifyBtn = CreateButton(row, "/esoui/art/buttons/edit", "Modify Profile", loadBtn, -28, function()
                PM:ShowModifyDialog(profile.name)
            end)
            table.insert(row.actions, modifyBtn)

            local saveBtn = CreateButton(row, "/esoui/art/buttons/edit_save", "Overwrite Profile", modifyBtn, -28, function()
				DebuffTracker.SaveProfile(profile.name)
                PM:RefreshAdvancedPanel()
            end)
            table.insert(row.actions, saveBtn)

            offsetY = offsetY + 36
        end

        offsetY = offsetY + 10
    end
end


function PM:Show()
    if PM.window and not PM.window:IsHidden() then
        PM.window:SetHidden(true)
        PM.isVisible = false
        return
    end

    SCENE_MANAGER:SetInUIMode(true)
    SetGameCameraUIMode(true)

    if not PM.window then
        PM.window = WINDOW_MANAGER:CreateTopLevelWindow("DebuffTrackerProfileManagerWindow")
        local win = PM.window
        win:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        win:SetMovable(true)
        win:SetMouseEnabled(true)
        win:SetClampedToScreen(true)
        win:SetHidden(false)

        -- Background
        local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetCenterColor(0.1, 0.1, 0.1, 0.85)
        bg:SetEdgeColor(0.4, 0.4, 0.4, 0.6)
        bg:SetEdgeTexture(nil, 1, 1, 1.0)

        -- Header
        local header = WINDOW_MANAGER:CreateControl(nil, win, CT_LABEL)
        header:SetFont("ZoFontWinH1")
        header:SetText("DebuffTracker - Profile Manager")
        header:SetAnchor(TOP, win, TOP, 0, 10)
        header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        -- Close Button
        PM.closeButton = WINDOW_MANAGER:CreateControl(nil, PM.window, CT_BUTTON)
        PM.closeButton:SetDimensions(32, 32)
        PM.closeButton:SetAnchor(TOPRIGHT, PM.window, TOPRIGHT, -6, 6)
        PM.closeButton:SetNormalTexture("/esoui/art/buttons/closebutton_up.dds")
        PM.closeButton:SetPressedTexture("/esoui/art/buttons/closebutton_down.dds")
        PM.closeButton:SetMouseOverTexture("/esoui/art/buttons/closebutton_mouseover.dds")
        PM.closeButton:SetClickSound(SOUNDS.DIALOG_DECLINE)
        PM.closeButton:SetHandler("OnClicked", function()
            PM.window:SetHidden(true)
            PM.isVisible = false
        end)
        PM.closeButton:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, PM.closeButton, TOPLEFT, 0, 0)
            SetTooltipText(InformationTooltip, "Close")
        end)
        PM.closeButton:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)

        BuildMonitorSection()
        BuildAdvancedPanel()
        PM.advancedPanel:SetHidden(false)
    else
        PM:RefreshMonitorPanel()
    end

    PM.window:SetHidden(false)
    PM.window:SetHandler("OnKeyUp", function(_, key)
        if key == KEY_ESCAPE then
            PM.window:SetHidden(true)
            PM.isVisible = false
        end
    end)

    PM.isVisible = true
end




