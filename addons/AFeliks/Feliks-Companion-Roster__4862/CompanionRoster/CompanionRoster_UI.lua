CompanionRoster = CompanionRoster or {}
local CompanionRoster = CompanionRoster -- local reference, faster than repeated _G lookups

-- Display name for the keybind action declared in Bindings.xml (action name
-- COMPANIONROSTER_TOGGLE). Must run before the Keybindings menu is ever
-- opened, so top-level code here is fine.
ZO_CreateStringId("SI_BINDING_NAME_COMPANIONROSTER_TOGGLE", "Toggle Companion Roster")

-- Number of pre-created row controls (CompanionRosterWindowRow1..N in the
-- XML) - a display ceiling, not a data limit. CompanionRoster.Data.GetAllCompanions()
-- discovers however many companions actually exist live; if that count ever
-- exceeds this, the extras simply won't have a row to show in. Bump this,
-- add one more RowN to the XML, and grow the window's height by one row
-- (26px) if that happens.
local MAX_COMPANION_ROWS = 8

local characterDropdown = nil
local selectedCharacterKey = nil

-- Level column width (55) + gap (6) + Rapport's own normal width (90) -
-- how wide the Rapport label needs to be to span both columns when it's
-- showing a status message instead of real data (see SetRowBlank), since
-- Level is blank in that case anyway.
local RAPPORT_NORMAL_WIDTH = 90
local RAPPORT_SPANNED_WIDTH = 55 + 6 + 90

-- The addon's own ESOUI download page - opened when the footer is clicked.
local ESOUI_PAGE_URL = "https://www.esoui.com/downloads/info4862.html"
local FOOTER_COLOR = { 0.6, 0.6, 0.6, 1 }
local FOOTER_HOVER_COLOR = { 0.6, 0.8, 1, 1 }

local function SetRowBlank(row)
    row.hasInfo = false
    row.rapportLevelText = nil
    row.passivePerkName = nil
    row.passivePerkDescription = nil

    row:GetNamedChild("Level"):SetText("")

    local rapport = row:GetNamedChild("Rapport")
    if not row.isOwned then
        rapport:SetText("Not Owned")
    elseif row.canSummon == false then
        rapport:SetText("Quest Not Done")
    else
        rapport:SetText("No Info")
    end
    rapport:SetColor(0.7, 0.7, 0.7, 1)

    -- These status messages are too wide for the Rapport column alone to
    -- fit on one line - span it across the (blank) Level column too
    -- instead of wrapping and overflowing into the row below.
    rapport:SetWidth(RAPPORT_SPANNED_WIDTH)
    rapport:ClearAnchors()
    rapport:SetAnchor(LEFT, row:GetNamedChild("Companion"), RIGHT, 6)
end

local function SetRowData(row, info)
    row.hasInfo = true
    row.rapportLevelText = info.rapportLevelText
    row.passivePerkName = info.passivePerkName
    row.passivePerkDescription = info.passivePerkDescription

    row:GetNamedChild("Level"):SetText(info.level and ("Lv." .. info.level) or "Lv.?")

    local rapport = row:GetNamedChild("Rapport")
    rapport:SetText(info.rapportValue .. "/" .. info.rapportMax)
    if info.rapportValue >= info.rapportMax then
        rapport:SetColor(0.4, 1, 0.4, 1)
    else
        rapport:SetColor(1, 0.8, 0.4, 1)
    end

    -- Back to its normal position/width, in case a previous refresh had it
    -- spanned across the Level column (see SetRowBlank).
    rapport:SetWidth(RAPPORT_NORMAL_WIDTH)
    rapport:ClearAnchors()
    rapport:SetAnchor(LEFT, row:GetNamedChild("Level"), RIGHT, 6)
end

-- On the CompanionRoster table (not a separate bare global) because the XML
-- OnMouseEnter handler on the Rapport label calls this by name.
function CompanionRoster.OnRapportMouseEnter(control)
    local row = control:GetParent()
    if row.hasInfo == false then
        if not row.isOwned then
            ZO_Tooltips_ShowTextTooltip(control, TOP, "You don't own this companion yet.")
        elseif row.canSummon == false then
            ZO_Tooltips_ShowTextTooltip(control, TOP, "You haven't completed this companion's recruitment quest on this character yet.")
        else
            ZO_Tooltips_ShowTextTooltip(control, TOP, "Rapport data will be recorded when this companion is summoned.")
        end
    elseif row.rapportLevelText then
        ZO_Tooltips_ShowTextTooltip(control, TOP, row.rapportLevelText)
    end
end

-- On the CompanionRoster table (not a separate bare global) because the XML
-- OnMouseEnter handler on the Companion label calls this by name.
function CompanionRoster.OnCompanionMouseEnter(control)
    local row = control:GetParent()
    if row.passivePerkName == nil then
        return
    end

    local nameLine = row.passivePerkName
    if row.keepsakeUnlocked then
        nameLine = nameLine .. " |c66FF66- Unlocked|r"
    end

    ZO_Tooltips_ShowTextTooltip(control, TOP, nameLine .. "\n" .. row.passivePerkDescription)
end

local function RefreshGrid()
    local companions = CompanionRoster.Data.GetAllCompanions()
    local companionsForCharacter = selectedCharacterKey and CompanionRoster.Data.GetCompanionsForCharacter(selectedCharacterKey) or {}

    for i = 1, MAX_COMPANION_ROWS do
        local row = _G["CompanionRosterWindowRow" .. i]
        local companion = companions[i]

        if companion == nil then
            row:SetHidden(true)
        else
            row:SetHidden(false)
            row.keepsakeUnlocked = CompanionRoster.Data.IsKeepsakeUnlocked(companion.name)
            row.isOwned = CompanionRoster.Data.IsCompanionOwned(companion.id)
            row.canSummon = selectedCharacterKey and CompanionRoster.Data.CanSummonCompanion(selectedCharacterKey, companion.id)

            local companionLabel = row:GetNamedChild("Companion")
            companionLabel:SetText(companion.name)
            if row.keepsakeUnlocked then
                companionLabel:SetColor(0.4, 1, 0.4, 1)
            else
                companionLabel:SetColor(1, 1, 1, 1)
            end

            if i % 2 == 0 then
                row:GetNamedChild("Stripe"):SetCenterColor(1, 1, 1, 0.13)
            else
                row:GetNamedChild("Stripe"):SetCenterColor(0, 0, 0, 0)
            end

            local info = companionsForCharacter[companion.id]
            if info then
                SetRowData(row, info)
            else
                SetRowBlank(row)
            end

            if row.passivePerkName == nil then
                row.passivePerkName, row.passivePerkDescription = CompanionRoster.Data.GetPassivePerkInfo(companion.id)
            end
        end
    end
end

local function OnCharacterSelected(comboBoxControl, entryText, entry)
    selectedCharacterKey = entry.characterKey
    RefreshGrid()
end

local function PopulateDropdown()
    characterDropdown:ClearItems()

    -- On first open since a reload, default to whichever character is
    -- actually logged in right now, not just whoever sorts first
    -- alphabetically. A manual pick made later this session (selectedCharacterKey
    -- already set) is preserved rather than reset every time the window reopens.
    local preferredKey = selectedCharacterKey or CompanionRoster.Data.GetCurrentCharacterName()

    local firstEntry = nil
    local entryToSelect = nil

    for _, characterKey in ipairs(CompanionRoster.Data.GetCharacterNames()) do
        local entry = characterDropdown:CreateItemEntry(characterKey, OnCharacterSelected)
        entry.characterKey = characterKey
        characterDropdown:AddItem(entry)

        if firstEntry == nil then
            firstEntry = entry
        end
        if characterKey == preferredKey then
            entryToSelect = entry
        end
    end

    local IGNORE_CALLBACKS = true
    if entryToSelect then
        selectedCharacterKey = preferredKey
        characterDropdown:SelectItem(entryToSelect, IGNORE_CALLBACKS)
    elseif firstEntry then
        selectedCharacterKey = firstEntry.characterKey
        characterDropdown:SelectItem(firstEntry, IGNORE_CALLBACKS)
    else
        selectedCharacterKey = nil
    end
end

-- On the CompanionRoster table (not a separate bare global) because the
-- XML OnMouseUp/OnMouseEnter/OnMouseExit handlers on the Footer label call
-- these by name.
function CompanionRoster.OnFooterClicked()
    RequestOpenUnsafeURL(ESOUI_PAGE_URL)
end

function CompanionRoster.OnFooterMouseEnter(control)
    control:SetColor(unpack(FOOTER_HOVER_COLOR))
end

function CompanionRoster.OnFooterMouseExit(control)
    control:SetColor(unpack(FOOTER_COLOR))
end

-- On the CompanionRoster table (not a separate bare global) because the
-- XML OnMoveStop handler calls this by name.
function CompanionRoster.OnWindowMoveStop(control)
    local _, point, _, relativePoint, offsetX, offsetY = control:GetAnchor(0)
    CompanionRoster.Data.SaveWindowPosition(point, relativePoint, offsetX, offsetY)
end

-- On the CompanionRoster table (not a separate bare global) because both
-- the <Down> handler in Bindings.xml and the /fcr slash command call this
-- by name.
function CompanionRoster.ToggleWindow()
    if CompanionRosterWindow:IsHidden() then
        PopulateDropdown()
        RefreshGrid()
        CompanionRosterWindow:SetHidden(false)
    else
        CompanionRosterWindow:SetHidden(true)
    end
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= CompanionRoster.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("CompanionRoster_UI", EVENT_ADD_ON_LOADED)

    characterDropdown = ZO_ComboBox_ObjectFromContainer(CompanionRosterWindowCharacterDropdown)
    characterDropdown:SetSortsItems(false)

    local savedPosition = CompanionRoster.Data.GetWindowPosition()
    if savedPosition then
        CompanionRosterWindow:ClearAnchors()
        CompanionRosterWindow:SetAnchor(savedPosition.point, nil, savedPosition.relativePoint, savedPosition.offsetX, savedPosition.offsetY)
    end

    CompanionRosterWindowFooter:SetText("Feliks' Companion Roster - Version: " .. CompanionRoster.version)
    CompanionRosterWindowFooter:SetColor(unpack(FOOTER_COLOR))

    LibSlashCommander:Register("/fcr", CompanionRoster.ToggleWindow, "Feliks' Companion Roster")
end

EVENT_MANAGER:RegisterForEvent("CompanionRoster_UI", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
