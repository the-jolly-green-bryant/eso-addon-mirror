local lib = GearOverview
local libScroll = LibScroll
local LAM = LibAddonMenu2

local localStorage = {
    displayWeapons = "WEAPONS_ALL"
}

local weaponTypeChoices = {
	["WEAPONS_ALL"] = "All",
	["WEAPONS_TANK"] = "Tank (S&B, Ice staff)",
	["WEAPONS_HEALER"] = "Healer (All staffs)",
    ["WEAPONS_DD"] = "DD (No resto, no heal)",
}

local NO_PRESET = "No preset"

--- Callback function to render on set
--- @param rowControl
--- @param data table
--- @param _
local function SetupDataRow(rowControl, data, _)
    local itemSetId = data.id
    local itemSetName = GetItemSetName(itemSetId)
    local skipOrderNumbers = {}

    lib.log(lib.LOG_LEVEL_VERBOSE, "SetupDataRow with displayWeapons", localStorage.displayWeapons)
    if localStorage.displayWeapons == "WEAPONS_TANK" then
        skipOrderNumbers = { 14, 15, 16, 17, 18, 19, 21 }
    elseif localStorage.displayWeapons == "WEAPONS_HEALER" then
        skipOrderNumbers = { 10, 11, 12, 13, 14, 15, 16, 17, 22 }
    elseif localStorage.displayWeapons == "WEAPONS_DD" then
        skipOrderNumbers = { 18, 22 }
    end

    for i = 1, 22 do
        local button = rowControl:GetNamedChild("Box" .. i)
        if not button then
            button = WINDOW_MANAGER:CreateControl("$(parent)Box" .. i, rowControl, CT_TEXTURE)
        end

        button:SetHidden(false)
        button:SetDimensions(24, 24)
        button:SetAnchor(LEFT, rowControl, LEFT, 260 + (i - 1) * 30, 0)
        button:SetMouseEnabled(false)

        local isUnlocked = false
        local isAvailable = false

        for idx = 1, GetNumItemSetCollectionPieces(itemSetId) do
            local pieceId, _ = GetItemSetCollectionPieceInfo(itemSetId, idx)
            local itemLink = GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE, nil)
            local orderNumber = lib.getOrderNumber(itemLink)

            if i == orderNumber then
                if not isUnlocked then
                    isUnlocked = IsItemSetCollectionPieceUnlocked(pieceId)
                end
                isAvailable = true
            end
        end

        local bagItem
        if lib.bag[itemSetId] then
            bagItem = lib.bag[itemSetId][i]
        end

        local skipColumn = false
        for _, OrderIdx in pairs(skipOrderNumbers) do
            if OrderIdx == i then
                skipColumn = true
            end
        end

        if skipColumn then
            button:SetHidden(true)
        elseif bagItem then
            button:SetTexture("/esoui/art/cadwell/check.dds")
            local quality = bagItem
            local red, green, blue, alpha = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
            button:SetColor(red, green, blue, alpha)
        elseif isUnlocked then
            button:SetTexture("/esoui/art/icons/servicemappins/servicepin_transmute.dds")
            button:SetColor(1, 1, 1)
        elseif isAvailable then
            button:SetTexture("/esoui/art/buttons/swatchframe_down.dds")  -- little square box
            button:SetColor(1, 1, 1)
        else
            button:SetHidden(true)
        end
    end

    rowControl:GetNamedChild("Name"):SetText(itemSetName)
end

function lib.getSetList()
    if not next(lib.setList) then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "|cff0000Please select a preset or enter custom sets!|r")
    end
    return lib.setList
end

function lib.refreshGearList()
    local myList = lib.getSetList()
    if not myList then
        return
    end

    lib.fetchItems()
    lib.scrollList:Clear()
    lib.scrollList:Update(myList)
end

function lib.showWindow()
    lib.switchTab("SETTINGS")

    -- Close all other scenes
    SCENE_MANAGER:OnNewMovementInUIMode()

    -- Hide all other UI elements except GearOverview
    SCENE_MANAGER:SetHUDScene("GearOverviewUI")

    -- Show the mouse
    SCENE_MANAGER:SetInUIMode(true)

    -- Face the player to the camera
    SetFrameLocalPlayerInGameCamera(true)
    SetFrameLocalPlayerTarget(0.25, 0.54)

    GearOverviewUI:SetHandler("OnHide", lib.onWindowClose)

    zo_callLater(function()
        -- Register for changes to hide the window
        EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, lib.onWindowClose)
    end, 10)
end

function lib.onWindowClose()
    SCENE_MANAGER:SetInUIMode(false)
    SCENE_MANAGER:RestoreHUDScene()
    SetFrameLocalPlayerInGameCamera(false)
    EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED)
end

function lib.switchTab(tab)
    if tab == "SETTINGS" then
        GearOverviewUIWindowSubtitle:SetText("Settings")
        GearOverviewUISettingsView:SetHidden(false)
        GearOverviewUIGearView:SetHidden(true)
        GearOverviewUITabSettings:SetState(BSTATE_PRESSED)
        GearOverviewUITabSettings:SetScale(1.25)
        GearOverviewUITabGear:SetState(BSTATE_NORMAL)
        GearOverviewUITabGear:SetScale(1)
    elseif tab == "GEAR" then
        lib.refreshGearList()
        GearOverviewUIWindowSubtitle:SetText("Gear")
        GearOverviewUISettingsView:SetHidden(true)
        GearOverviewUIGearView:SetHidden(false)
        GearOverviewUITabGear:SetState(BSTATE_PRESSED)
        GearOverviewUITabGear:SetScale(1.25)
        GearOverviewUITabSettings:SetState(BSTATE_NORMAL)
        GearOverviewUITabSettings:SetScale(1)
    end
end

local function CreateOptions(parent, options)
    local w, h = parent:GetWidth(), 26
    local labelWidth = w / 3
    local controlWidth = w / 3 * 2
    local space = 5
    local anchor = { TOPLEFT, TOPLEFT, 0, 0, parent }
    for i, data in pairs(options) do
        local frame
        if data.type == "button" then
            frame = lib.UI.Control("$(parent)_Frame" .. i, parent, { w, h }, anchor)
            local button = WINDOW_MANAGER:CreateControlFromVirtual(data.reference or "$(parent)_Button", frame, "ZO_DefaultButton")
            button:SetWidth(180, 28)
            button:SetFont("ZoFontGameLargeBold")
            button:SetText(data.name)
            button:SetAnchor(TOP, frame, TOP, 0, 0)
            button:SetClickSound("Click")
            button:SetHandler("OnClicked", data.func)
            anchor = { TOPLEFT, BOTTOMLEFT, 0, space, frame }
        elseif data.type == "dropdown" then
            frame = lib.UI.Control("$(parent)_Drop" .. i, parent, { w, h }, anchor)
            frame.label = lib.UI.Label("$(parent)_Label", frame, { labelWidth, h }, { TOPLEFT, TOPLEFT, 0, 0 }, font_bold, { .8, .8, .6, 1 }, { 0, 1 }, data.name)
            frame.control = lib.UI.ComboBox(data.reference or "$(parent)_DropBox", frame.label, { controlWidth, 28 }, { TOPLEFT, TOPRIGHT, 0, 0 }, data.choices, data.getFunc(), data.setFunc, false, data.scrollable)
            anchor = { TOPLEFT, BOTTOMLEFT, 0, space, frame }
        elseif data.type == "editbox" then
            local height = h
            if data.isMultiline then
                height = 500
            end
            frame = lib.UI.Control("$(parent)_Edit" .. i, parent, { w, height }, anchor)
            frame.label = lib.UI.Label("$(parent)_Label", frame, { labelWidth, height }, { TOPLEFT, TOPLEFT, 0, 0 }, font_bold, { .8, .8, .6, 1 }, { 0, 1 }, data.name)
            frame.control = lib.UI.TextBox("$(parent)_EditBox", frame.label, { controlWidth, height }, { TOPLEFT, TOPRIGHT, 0, 0 }, 3000, data.getFunc, data.setFunc, false, data.isMultiline)
            anchor = { TOPLEFT, BOTTOMLEFT, 0, space, frame }
        end
        if frame then
            options[i].frame = frame
        end
    end
end

local function updateWeaponsChoiceDrop(displayWeapons)
    local weaponsDrop = GearOverviewUISettingsView_Drop2.control
		local weaponsDropIndex = 1
		for index, iValue in pairs(lib.getTableKeys(weaponTypeChoices)) do
			if (iValue == displayWeapons) then
				weaponsDropIndex = index
			end
		end
		lib.debug("SelectItemByIndex", weaponsDropIndex, displayWeapons, lib.activePreset)
		weaponsDrop.m_comboBox:SelectItemByIndex(weaponsDropIndex, true)
		weaponsDrop.value = weaponsDropIndex
		weaponsDrop:UpdateParent()
		localStorage.displayWeapons = displayWeapons
end

local function pasteSetsToEditbox(sets)
    local editboxText = ''
    for _, row in pairs(sets) do
        editboxText = editboxText .. GetItemSetName(row.id) .. '\n'
    end
    GearOverviewUISettingsView_Edit3_Label_EditBox.eb:SetText(editboxText)
end

local function setPreset(value)
    if value == NO_PRESET then
        lib.activePreset = nil
    else
        lib.activePreset = value
        local preset = lib.getPresetByName(value)

        updateWeaponsChoiceDrop(preset.displayWeapons)

		lib.setList = preset.sets
        pasteSetsToEditbox(preset.sets)
    end
end

local function createSettingsTab()
    local presetNames = {}
    table.insert(presetNames, NO_PRESET)
    for _, preset in pairs(lib.applicablePresets) do
        table.insert(presetNames, preset.name)
    end

	local weaponTypeLabels = {}
	for _, label in pairs(weaponTypeChoices) do
		table.insert(weaponTypeLabels, label)
	end

    local Options = {
        {
            type = "dropdown",
            name = "Set Preset",
            tooltip = "Which gear preset should be displayed.",
            choices = presetNames,
            getFunc = function()
                return NO_PRESET
            end,
            setFunc = function(_, value)
                setPreset(value)
            end,
            disabled = function()
                return false
            end,
        }, {
            type = "dropdown",
            name = "Weapon types",
            tooltip = "Click here to show the window.",
            choices = weaponTypeLabels,
            getFunc = function()
                return weaponTypeChoices["WEAPONS_ALL"]
            end,
            setFunc = function(i, _)
                localStorage.displayWeapons = lib.getTableKeys(weaponTypeChoices)[i]
            end,
            disabled = function()
                return false
            end,
        }, {
            type = "editbox",
            isMultiline = true,
            name = "Custom list of sets (one per line)",
            tooltip = "Paste here the sets you want to list",
            getFunc = function()
                return ''
            end,
            setFunc = function(text)
                lib.activePreset = nil
                lib.parseSets(text)
            end,
            disabled = function()
                return not false
            end,
        },
        {
            type = "button",
            name = "Show my gear",
            func = function()
                lib.switchTab("GEAR")
            end,
            reference = "GO_TO_GEAR",
        },
    }
    local parent = GearOverviewUISettingsView
    CreateOptions(parent, Options)
end

local function createScrollList()
    local scrollData = {
        name = "GearOverviewUIGearViewList",
        parent = GearOverviewUIGearView,
        rowTemplate = "GearOverviewUIGearViewRow",
        setupCallback = SetupDataRow,
        width = 944,
        height = 600,
    }

    local scrollList = libScroll:CreateScrollList(scrollData)
    scrollList:SetAnchor(TOPLEFT, GearOverviewUIGearView, TOPLEFT, 0, 50)

    return scrollList
end

local function createLAMSettings()
    if LAM then
        local panelName = "GearOverviewSettingsPanel"
        LAM:RegisterAddonPanel(panelName, {
            type = "panel",
            name = lib.name,
            author = lib.author,
            version = lib.version,
        })

        LAM:RegisterOptionControls(panelName, {
            {
                type = "button",
                name = "Show Window",
                warning = "Use the /gear command to show the window",
                tooltip = "Click here to show the window.",
                width = "half",
                func = lib.showWindow,
            },
        })
    end
end

function lib.createSettings()
    createSettingsTab()
    lib.scrollList = createScrollList()
    createLAMSettings()
end