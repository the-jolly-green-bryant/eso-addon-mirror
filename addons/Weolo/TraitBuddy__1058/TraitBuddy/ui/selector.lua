local sf = string.format

-- TB_CharacterSelector
-- Drop-in replacement for the OG selector.  Uses a dropdown + class icon bar
-- (the "new" style from TraitGrid) instead of the old ZO_MenuBar button row.
-- Exposes exactly the same public interface so the rest of the addon needs no
-- changes:  Build, Show, Hide, IsCharacterSelected, IsCurrentCharacterSelected,
-- GetSelectedCharacter, GetSelectedID, TrySelectCharacter,
-- TrySelectCurrentCharacter, selectedId.

TB_CharacterSelector = ZO_Object:Subclass()

function TB_CharacterSelector:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_CharacterSelector:Initialize(parent)
    -- Initialized before TraitBuddy data is available
    self.parent     = parent
    self.selectedId = 0
    self.built      = false

    -- Build the bar control inside the parent that was passed in.
    -- The parent is TBAltsBar (a CT_CONTROL anchored at the bottom of TB).
    local wm = WINDOW_MANAGER

    -- Backdrop
    local bg = wm:CreateControl(nil, parent, CT_BACKDROP)
    bg:SetAnchorFill(parent)
    bg:SetCenterColor(0.08, 0.08, 0.08, 0.85)
    bg:SetEdgeColor(0.25, 0.25, 0.25, 1)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 32, 32, 4, 0)

    -- Class icon (left side)
    local classIcon = wm:CreateControl(nil, parent, CT_TEXTURE)
    classIcon:SetAnchor(LEFT, parent, LEFT, 8, 0)
    classIcon:SetDimensions(32, 32)
    self.classIcon = classIcon

    -- Dropdown (fills the rest of the bar)
    local combo = CreateControlFromVirtual("TBSelectorCombo", parent, "TB_SelectorCombo")
    combo:ClearAnchors()
    combo:SetAnchor(LEFT, classIcon, RIGHT, 6, 0)
    self.combo = combo

    local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
    comboObj:SetFont("ZoFontWinH3")
    comboObj:SetSpacing(4)

    -- item cache: characterId -> dropdown item entry
    self._items = {}
end

-- Internal: update the class icon for a given character id.
-- GetClassInfo takes a 1-based INDEX, not a classId — must loop to find the match.
function TB_CharacterSelector:_UpdateClassIcon(id)
    if not self.classIcon then return end
    -- First find this character's classId from the character list
    local targetClassId
    for i = 1, GetNumCharacters() do
        local _, _, _, classId, _, _, charId = GetCharacterInfo(i)
        if charId == id then
            targetClassId = classId
            break
        end
    end
    if not targetClassId then return end
    -- Now find the icon by looping class indices (GetClassInfo takes an index)
    for i = 0, GetNumClasses() do
        local classId, _, normalIcon = GetClassInfo(i)
        if classId == targetClassId then
            if normalIcon and normalIcon ~= "" then
                self.classIcon:SetTexture(normalIcon)
            else
                -- Arcanist and future classes: construct path from class name
                local gender = GENDER_MALE  -- gender doesn't affect class name
                local rawName = GetClassName(gender, classId) or ""
                local className = string.lower(string.gsub(rawName, "%s+", ""))
                self.classIcon:SetTexture("esoui/art/icons/class/class_" .. className .. ".dds")
            end
            return
        end
    end
end

-- Internal: select a dropdown item by character id using the cached item table.
function TB_CharacterSelector:_SelectDropdownById(id)
    local item    = self._items[id]
    local comboObj = ZO_ComboBox_ObjectFromContainer(self.combo)
    if item then
        comboObj:SelectItem(item, true)  -- silent = true, no callback fired
    else
        -- fallback: just update the display text
        local c = TraitBuddy:GetCharacter(id)
        if c and comboObj.SetSelectedItemText then
            comboObj:SetSelectedItemText(c.name)
        end
    end
end

-- Build (or re-build) the dropdown.  Called at startup and after DeleteCharacter.
function TB_CharacterSelector:Build(selectId)
    self.selectedId = 0
    self._items     = {}
	
    local comboObj = ZO_ComboBox_ObjectFromContainer(self.combo)
    comboObj:ClearItems()
    local sorted     = TraitBuddy:GetCharacters(true)
    local characters = TraitBuddy:GetCharacters()

    for _, id in ipairs(sorted) do
        local c = characters[id]
        if c.show.bs or c.show.cl or c.show.ww or c.show.motif or c.show.je then
            local capturedId = id
            local item = ZO_ComboBox:CreateItemEntry(c.name, function(cb, name, entry, selectionChanged)
                if selectionChanged then
                    self:_OnSelected(capturedId)
				end
            end)
            comboObj:AddItem(item, ZO_COMBOBOX_SUPRESS_UPDATE)
            self._items[id] = item
        end
    end
    comboObj:UpdateItems()

    self.built = true
    self:TrySelectCharacter(selectId or TraitBuddy.characterId)
end

-- Internal callback when the dropdown selection changes.
function TB_CharacterSelector:_OnSelected(id)
    self.selectedId = id
    self:_UpdateClassIcon(id)
    -- Refresh all crafting grids and motifs for the newly selected character.
    TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
    TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
    TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
    TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_JEWELRYCRAFTING)
    -- Re-run the current motif filter so the list reflects the new character.
    TraitBuddy.ui.motifs:SelectCurrentFilter()
end

-- Public interface

function TB_CharacterSelector:IsCharacterSelected()
    return self.selectedId ~= 0
end

function TB_CharacterSelector:IsCurrentCharacterSelected()
    return self.selectedId == TraitBuddy.characterId
end

function TB_CharacterSelector:GetSelectedID()
    return self.selectedId
end

function TB_CharacterSelector:GetSelectedCharacter()
    return TraitBuddy:GetCharacter(self.selectedId)
end

-- Select a specific character by id.  Returns true on success.
function TB_CharacterSelector:SelectCharacter(id)
    local c = TraitBuddy:GetCharacter(id)
    if c and (c.show.bs or c.show.cl or c.show.ww or c.show.motif or c.show.je) then
        local item = self._items[id]
        if item then
            ZO_ComboBox_ObjectFromContainer(self.combo):SelectItem(item)
            -- SelectItem fires the callback which calls _OnSelected, so
            -- selectedId and the class icon are already updated.
            return true
        end
    end
    return false
end

-- Try to select the given id; fall back to the first visible character,
-- then to the current character (mirrors OG TrySelectCharacter exactly).
function TB_CharacterSelector:TrySelectCharacter(selectId)
	local found = self:SelectCharacter(selectId)
    if not found then
        for _, id in ipairs(TraitBuddy:GetCharacters(true)) do
            found = self:SelectCharacter(id)
            if found then break end
        end
    end
    if not found then
        found = self:SelectCharacter(TraitBuddy.characterId)
    end
    if not found then
        -- Nothing selectable — still fire UpdateUI so the display clears.
        TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
        TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
        TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
        TraitBuddy.ui.motifs:UpdateUI()
    end
    return found
end

function TB_CharacterSelector:TrySelectCurrentCharacter()
    return self:TrySelectCharacter(TraitBuddy.characterId)
end

function TB_CharacterSelector:Show()
    if self.parent:IsHidden() then
        self.parent:SetHidden(false)
    end
end

function TB_CharacterSelector:Hide()
    if not self.parent:IsHidden() then
        self.parent:SetHidden(true)
	end
end