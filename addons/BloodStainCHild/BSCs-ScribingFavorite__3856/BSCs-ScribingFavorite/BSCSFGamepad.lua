-- ============================================================================
-- BSCs-ScribingFavorite (Gamepad)
-- Favorites-Liste für Scribing inkl. Dialog, Keybinds und Tooltip-Handling
-- ============================================================================

BSCScribingFavorite = BSCScribingFavorite or {}
local BSCSF = BSCScribingFavorite

-- ============================================================================
-- Konstanten & Shortcuts
-- ============================================================================
local FAVORITES_ICON = "EsoUI/Art/Crafting/Gamepad/gp_crafting_menuIcon_recent.dds"
local ZO_SCRIBING_GAMEPAD_MODE_FAVORITE = 3
local A = ZO_RECENT_SCRIBE_SAVED_VAR_INDEX -- Indexe in Favoriten-Tuple

local function GetCraftedAbilityName(abilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId)
    local cad = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(abilityId)
    if not cad then return "" end

    cad:SetScriptIdSelectionOverride(primaryScriptId, secondaryScriptId, tertiaryScriptId)

    local repAbilityId = cad:GetRepresentativeAbilityId()
    if repAbilityId and repAbilityId ~= 0 then
        local repName = GetAbilityName(repAbilityId)
        if repName and repName ~= "" then
            return ZO_CachedStrFormat(SI_ABILITY_NAME, repName)
        end
    end
    return cad:GetFormattedName() or "Unknown Skill"
end

local function GetFavoriteDisplayName(fav)
    local abilityId         = fav[A.CRAFTED_ABILITY]
    local primaryScriptId   = fav[A.PRIMARY_SCRIPT]
    local secondaryScriptId = fav[A.SECONDARY_SCRIPT]
    local tertiaryScriptId  = fav[A.TERTIARY_SCRIPT]
    local customName        = fav[5]

    local baseName = GetCraftedAbilityName(abilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId)
    if customName and customName ~= "" then
        baseName = string.format("%s - %s", baseName, customName)
    end
    return baseName
end

local function GetCraftedAbilityIcon(abilityId)
    local cd = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(abilityId)
    return (cd and cd:GetIcon()) or "EsoUI/Art/Icons/icon_missing.dds"
end

local function UnpackFavorite(fav)
    return fav[A.CRAFTED_ABILITY], fav[A.PRIMARY_SCRIPT], fav[A.SECONDARY_SCRIPT], fav[A.TERTIARY_SCRIPT]
end

-- ============================================================================
-- Dialoge
-- ============================================================================

-- Öffnen mit: ZO_Dialogs_ShowGamepadDialog("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM_GAMEPAD", { AbilityData = favTuple })
local function SetupAddFavoriteConfirmDialog_Gamepad()
    local parametricDialog = ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC)

    ZO_Dialogs_RegisterCustomDialog("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM_GAMEPAD", {
        canQueue   = true,
        gamepadInfo= { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        setup      = function(dialog) dialog:setupFunc() end,

        title    = { text = GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE) },
        mainText = { text = "Custom Name (optional):" },

        parametricList = {
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    nameField = true,
                    textChangedCallback = function(control)
                        local input = control:GetText()
                        if parametricDialog.data then
                            parametricDialog.data.customName = input
                        end
                        KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
                    end,
                    setup = function(control, data)
                        control.editBoxControl.textChangedCallback = data.textChangedCallback
                        control.editBoxControl:SetMaxInputChars(32)
                        data.control = control
                        if parametricDialog.data then
                            control.editBoxControl:SetText(parametricDialog.data.customName or "")
                        end
                    end,
                    narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
                },
            },
        },

        blockDialogReleaseOnPress = true,

        buttons = {
            -- A: Fokus ins Textfeld
            {
                keybind  = "DIALOG_PRIMARY",
                text     = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    if data and data.control and data.control.editBoxControl then
                        data.control.editBoxControl:TakeFocus()
                    end
                end,
            },
            -- X/Y: Speichern
            {
                keybind    = "DIALOG_SECONDARY",
                text       = SI_COLLECTIBLE_ACTION_ADD_FAVORITE,
                clickSound = SOUNDS.DIALOG_ACCEPT,
                visible    = function()
                    --return not not (parametricDialog.data and parametricDialog.data.customName)
					return true
                end,
                callback   = function(dialog)
                    local fav  = dialog.data.AbilityData
                    local name = parametricDialog.data and parametricDialog.data.customName
                    local newFav = { fav[1], fav[2], fav[3], fav[4], (name ~= "" and name) or nil }

                    BSCSF:AddToFavorite(newFav)
                    BSCSF:RefreshFavoritesView_AfterChange()
                    BSCSF:ShowFavoriteCraftedAbilities_Gamepad()

                    ZO_Dialogs_ReleaseDialogOnButtonPress("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM_GAMEPAD")
                end,
            },
            -- B: Abbrechen
            {
                keybind  = "DIALOG_NEGATIVE",
                text     = SI_DIALOG_CANCEL,
                callback = function()
                    ZO_Dialogs_ReleaseDialogOnButtonPress("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM_GAMEPAD")
                end,
            },
        },
    })
end

local function SetupRemoveFavoriteConfirmDialog_Gamepad()
    ZO_Dialogs_RegisterCustomDialog("SCRIBING_REMOVE_FAVORITE_SKILLS_CONFIRM_GAMEPAD", {
        canQueue   = true,
        gamepadInfo= { dialogType = GAMEPAD_DIALOGS.BASIC },
        title      = { text = GetString(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE) },
        mainText   = { text = function(dialog) return GetFavoriteDisplayName(dialog.data.AbilityData) end },
        buttons    = {
            {
                keybind  = "DIALOG_PRIMARY",
                text     = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    BSCSF:RemoveFavoriteSkill(dialog.data.AbilityData)
                    BSCSF:RefreshFavoritesView_AfterChange()
                end,
            },
            { keybind = "DIALOG_NEGATIVE", text = SI_DIALOG_CANCEL },
        },
    })
end

-- ============================================================================
-- Liste anlegen (PostHook auf InitializeLists)
-- ============================================================================
ZO_PostHook(ZO_ScribingLayout_Gamepad, "InitializeLists", function(self)
    if self.favoriteAbilityList then return end

    -- Liste wie ESO-Listen anlegen (Mask/Scroll via AddList)
    self.favoriteAbilityList = self:AddList("favoriteAbilityList")

    -- Einträge-Template (SubMenu mit Icon + Text)
    self.favoriteAbilityList:AddDataTemplate(
        "ZO_GamepadSubMenuEntryTemplate",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction
    )

    -- Tooltip-Update beim Fokuswechsel (nur aktiv in unserer Liste)
    self.favoriteAbilityList:SetOnTargetDataChangedCallback(function(_, data)
        if self:GetCurrentList() ~= self.favoriteAbilityList then return end

        if data and data.AbilityData then
            local id, p, s, t = UnpackFavorite(data.AbilityData)
            local cad = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(id)
            if cad then
                cad:SetScriptIdSelectionOverride(p, s, t)
                self._bscsfActiveDetails = { craftedAbilityId = id, primaryScriptId = p, secondaryScriptId = s, tertiaryScriptId = t }
                self:LayoutTooltipForCraftedAbilityData(cad)
            else
                self._bscsfActiveDetails = nil
                self:LayoutTooltipForCraftedAbilityData(nil)
            end
        else
            self._bscsfActiveDetails = nil
            self:LayoutTooltipForCraftedAbilityData(nil)
        end
    end)
	
	self.favoriteAbilityList:SetOnSelectedDataChangedCallback(function(_, data)
		if self:GetCurrentList() ~= self.favoriteAbilityList then return end

		local fav = data and data.AbilityData
		if fav then
			local id  = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]
			local p   = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.PRIMARY_SCRIPT]
			local s   = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.SECONDARY_SCRIPT]
			local t   = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.TERTIARY_SCRIPT]

			local cad = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(id)
			if cad then
				cad:SetScriptIdSelectionOverride(p, s, t)
				self._bscsfActiveDetails = { craftedAbilityId = id, primaryScriptId = p, secondaryScriptId = s, tertiaryScriptId = t }
				self:LayoutTooltipForCraftedAbilityData(cad)
			else
				self._bscsfActiveDetails = nil
				self:LayoutTooltipForCraftedAbilityData(nil)
			end
		else
			self._bscsfActiveDetails = nil
			self:LayoutTooltipForCraftedAbilityData(nil)
		end
	end)
end)

-- ============================================================================
-- Ansicht aktualisieren, wenn sich Favoriten ändern
-- ============================================================================
function BSCSF:RefreshFavoritesView_AfterChange()
    local gp = SCRIBING_GAMEPAD
    if not gp then return end

    if gp.favoriteAbilityList and gp:GetCurrentList() == gp.favoriteAbilityList then
        local list = gp.favoriteAbilityList
        local oldIndex = list:GetSelectedIndex() or 1

        self:ShowFavoriteCraftedAbilities_Gamepad()

        local count = gp.favoriteAbilityList:GetNumEntries()
        if count == 0 then
            gp.currentListType = nil
            gp:SetSelectedCraftedAbilityId(0)
            gp:ShowCraftedAbilities()
            gp:RefreshKeybinds()
            if gp.LayoutTooltipForCraftedAbilityData then
                gp:LayoutTooltipForCraftedAbilityData(nil)
            end
            return
        end

        local newIndex = zo_clamp(oldIndex, 1, count)
        gp.favoriteAbilityList:SetSelectedIndexWithoutAnimation(newIndex)

        local data = gp.favoriteAbilityList:GetTargetData()
        if data and data.AbilityData then
            local id, p, s, t = UnpackFavorite(data.AbilityData)
            local cad = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(id)
            if cad then
                cad:SetScriptIdSelectionOverride(p, s, t)
                gp._bscsfActiveDetails = { craftedAbilityId = id, primaryScriptId = p, secondaryScriptId = s, tertiaryScriptId = t }
                gp:LayoutTooltipForCraftedAbilityData(cad)
            else
                gp._bscsfActiveDetails = nil
                gp:LayoutTooltipForCraftedAbilityData(nil)
            end
        else
            gp._bscsfActiveDetails = nil
            gp:LayoutTooltipForCraftedAbilityData(nil)
        end
    else
        -- Hauptliste neu befüllen, damit Favoriten-Kategorie ggf. verschwindet
        if gp.RefreshCraftedAbilityList then
            gp:RefreshCraftedAbilityList()
        end
    end
end

-- ============================================================================
-- Favorit anwenden (Ability + Scripts setzen, Wechsel zu Scripts-Ansicht)
-- ============================================================================
local function ApplyFavoriteToScreen(screenSelf, fav)
    local id, p, s, t = UnpackFavorite(fav)
    local cad = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(id)
    if not cad then
        screenSelf:SetSelectedCraftedAbilityId(0)
        BSCSF:ShowFavoriteCraftedAbilities_Gamepad()
        return
    end

    if screenSelf.SelectCraftedAbilityId then
        screenSelf:SelectCraftedAbilityId(id)
    else
        screenSelf:SetSelectedCraftedAbilityId(id)
    end

    -- Wechsel auf Scripts; wir verlassen unseren Favoriten-„Modus“
    screenSelf.currentListType     = nil
    screenSelf._bscsfActiveDetails = nil
    screenSelf:ShowScripts()

    -- Skripte in Slots einlegen
    local function ensureScript(scriptId)
        if not scriptId or scriptId == 0 then return true end
        local sd = SCRIBING_DATA_MANAGER:GetCraftedAbilityScriptData(scriptId)
        if not sd then return false end
        local slot = sd:GetScribingSlot()

        if screenSelf.GetScriptIdBySlot and screenSelf.SelectScriptId then
            local cur = screenSelf:GetScriptIdBySlot(slot)
            if cur ~= scriptId then
                screenSelf:SelectScriptId(scriptId)
                return screenSelf:GetScriptIdBySlot(slot) == scriptId
            end
            return true
        end
        return false
    end

    ensureScript(p); ensureScript(s); ensureScript(t)

    screenSelf:RefreshKeybinds()
    screenSelf:RefreshHeader()
end

-- ============================================================================
-- Favoriten-Liste befüllen & anzeigen
-- ============================================================================
function BSCSF:ShowFavoriteCraftedAbilities_Gamepad()
    local gp = SCRIBING_GAMEPAD
    if not gp or not gp.favoriteAbilityList then return end

    local list = gp.favoriteAbilityList
    list:Clear()

    local favs = (BSCSF.SV_ACC and BSCSF.SV_ACC.SCAL) or {}
    for _, fav in ipairs(favs) do
        local id = fav[A.CRAFTED_ABILITY]
        local entry = ZO_GamepadEntryData:New(GetFavoriteDisplayName(fav), GetCraftedAbilityIcon(id))
        entry._isBSCSFFavoritesEntry = true
        entry.AbilityData = fav
        entry.callback = function(screenSelf)
            ApplyFavoriteToScreen(screenSelf, fav)
        end
        list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
    end

    list:Commit()

    ZO_GamepadGenericHeader_RefreshData(gp.header, { titleText = GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER) })

    gp:SetCurrentList(list)
    gp.currentListType = "BSCSF_FAVORITES"
    list:Activate()
    gp:RefreshKeybinds()

    -- Initialer Tooltip
    local first = list:GetTargetData()
    if first and first.AbilityData then
        local id, p, s, t = UnpackFavorite(first.AbilityData)
        gp._bscsfActiveDetails = { craftedAbilityId = id, primaryScriptId = p, secondaryScriptId = s, tertiaryScriptId = t }
        local cad = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(id)
        if cad then
            cad:SetScriptIdSelectionOverride(p, s, t)
            gp:LayoutTooltipForCraftedAbilityData(cad)
        end
    else
        gp._bscsfActiveDetails = nil
        gp:LayoutTooltipForCraftedAbilityData(nil)
    end
end

-- ============================================================================
-- „Favorites“-Kategorie in Hauptliste anhängen
-- ============================================================================
function BSCSF:HookFavoritesEntryIntoCraftedAbilityList_Gamepad()
    if self._favoritesListHooked then return end
    self._favoritesListHooked = true

    ZO_PostHook(SCRIBING_GAMEPAD, "RefreshCraftedAbilityList", function(gpSelf)
        local list = gpSelf and gpSelf.craftedAbilityList
        if not list then return end

        -- Doppelte entfernen
        for i = #list.dataList, 1, -1 do
            local d = list.dataList[i].data
            if d and d._isBSCSFFavoritesCategory then
                table.remove(list.dataList, i)
            end
        end

        if BSCSF:HasAnyFavoriteCraftedAbilities() then
            local entryData = ZO_GamepadEntryData:New(GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER), FAVORITES_ICON)
            entryData._isBSCSFFavoritesCategory = true
            entryData.callback = function(screenSelf)
                BSCSF:ShowFavoriteCraftedAbilities_Gamepad()
            end
            list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entryData)
            list:Commit()
        end
    end)
end


-- ============================================================================
-- Auswahl abfangen: Kategorie → unsere Favoriten-Liste öffnen
-- ============================================================================
function BSCSF:HookFavoritesSelectHandler()
    if self._favoritesSelectHooked then return end
    self._favoritesSelectHooked = true

    ZO_PreHook(ZO_ScribingLayout_Gamepad, "SelectCraftedAbility", function(self)
        local curList = self:GetCurrentList()
        if not curList then return end
        local entryData = curList:GetTargetData()
        if entryData and entryData._isBSCSFFavoritesCategory then
            BSCSF:ShowFavoriteCraftedAbilities_Gamepad()
            return true -- ESO-Standard verhindern
        end
    end)
end

-- ============================================================================
-- Zurück-Verhalten: zurück zur Hauptliste
-- ============================================================================
local function BackToNormal()
    local gp = SCRIBING_GAMEPAD
    if gp and gp:GetCurrentList() == gp.favoriteAbilityList then
        if gp.craftedAbilityList then
            gp:SetCurrentList(gp.craftedAbilityList)
            gp.craftedAbilityList:Activate()
        end
        gp.currentListType = nil
        gp:SetSelectedCraftedAbilityId(0)
        if gp.LayoutTooltipForCraftedAbilityData then
            gp:LayoutTooltipForCraftedAbilityData(nil)
        end
        gp:RefreshHeader()
        gp:RefreshKeybinds()
        return true
    end
end

function BSCSF:HookBackBehavior()
    if self._backHooked then return end
    self._backHooked = true

    ZO_PreHook(SCRIBING_GAMEPAD, "OnBackButtonClicked", function(self)
        if self:GetCurrentList() == self.favoriteAbilityList then
            if self.craftedAbilityList then
                self:SetCurrentList(self.craftedAbilityList)
                self.craftedAbilityList:Activate()
            end
            self.currentListType = nil
            self:SetSelectedCraftedAbilityId(0)
            if self.LayoutTooltipForCraftedAbilityData then
                self:LayoutTooltipForCraftedAbilityData(nil)
            end
            self:RefreshHeader()
            self:RefreshKeybinds()
            return true
        end
    end)

    ZO_PostHook(SCRIBING_GAMEPAD, "OnHiding", BackToNormal)
end

-- ============================================================================
-- Keybind: Favorit hinzufügen/entfernen (Right Stick)
-- ============================================================================
function BSCSF:ShouldCraftButtonBeEnabledGamepad()
    if ZO_CraftingUtils_IsPerformingCraftProcess() then
        return false
    end

    local p, s, t = SCRIBING_GAMEPAD:GetSlottedScriptIds()
    if p == 0 or s == 0 or t == 0 then
        return false, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_EMPTY_SCRIPT_SLOT)
    end
    if not (SCRIBING_GAMEPAD:IsScriptIdUnlocked(p) and SCRIBING_GAMEPAD:IsScriptIdUnlocked(s) and SCRIBING_GAMEPAD:IsScriptIdUnlocked(t)) then
        return false, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_UNOWNED_SCRIPT)
    end

    local data = SCRIBING_GAMEPAD:GetSlottedCraftedAbilityData()
    if not data:IsScribableScriptIdCombination(p, s, t) then
        return false, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_INVALID_SCRIBING_COMBINATION)
    end

    local id = SCRIBING_GAMEPAD:GetSlottedCraftedAbilityId()
    local cad = { id, p, s, t }
    if BSCSF.IsInFavorite and BSCSF:IsInFavorite(cad) then
        return false, GetString(SI_ITEM_FORMAT_STR_ALREADY_IN_COLLECTION)
    end

    return true
end

local function AddFavoriteKeybind_Gamepad()
    ZO_PostHook(SCRIBING_GAMEPAD, "InitializeKeybindStripDescriptors", function(self)
        if self._bscsfKeybindAdded then return end
        self._bscsfKeybindAdded = true

        local descriptor = {
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            name    = function()
                if self:GetCurrentList() == self.favoriteAbilityList then
                    return GetString(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE)
                else
                    return GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE)
                end
            end,
            callback = function()
                if self:GetCurrentList() == self.favoriteAbilityList then
                    local entryData = self:GetCurrentList():GetTargetData()
                    if entryData and entryData.AbilityData then
                        ZO_Dialogs_ShowGamepadDialog("SCRIBING_REMOVE_FAVORITE_SKILLS_CONFIRM_GAMEPAD", { AbilityData = entryData.AbilityData })
                    end
                elseif self:GetCurrentList() == self.scriptsList then
                    local craftedAbilityId = self:GetSlottedCraftedAbilityId()
                    local primaryScriptId, secondaryScriptId, tertiaryScriptId = self:GetSlottedScriptIds()
                    local cad = { craftedAbilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId }
                    ZO_Dialogs_ShowGamepadDialog("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM_GAMEPAD", { AbilityData = cad })
                end
            end,
            sound   = SOUNDS.GAMEPAD_MENU_FORWARD,
            visible = function()
                return (self:GetCurrentList() == self.favoriteAbilityList) or (self:GetCurrentList() == self.scriptsList)
            end,
            enabled = function()
                if self:GetCurrentList() == self.favoriteAbilityList then
                    return true
                elseif self:GetCurrentList() == self.scriptsList then
                    return BSCSF:ShouldCraftButtonBeEnabledGamepad()
                else
                    return false
                end
            end,
        }

        table.insert(self.keybindStripDescriptor, descriptor)
    end)
end

-- ============================================================================
-- Init
-- ============================================================================
function BSCSF:InitGamepad()
    SetupAddFavoriteConfirmDialog_Gamepad()
    SetupRemoveFavoriteConfirmDialog_Gamepad()

    self:HookFavoritesEntryIntoCraftedAbilityList_Gamepad()
    self:HookFavoritesSelectHandler()
    self:HookBackBehavior()

    -- Safety-Patch: sichtbarkeits-Fehler in fremden visible()-Funktionen einkapseln
    ZO_PostHook(SCRIBING_GAMEPAD, "InitializeKeybindStripDescriptors", function(self)
        if not self.keybindStripDescriptor then return end
        for _, descriptor in ipairs(self.keybindStripDescriptor) do
            local oldVisible = descriptor.visible
            if type(oldVisible) == "function" then
                descriptor.visible = function(...)
                    local ok, result = pcall(oldVisible, ...)
                    if not ok then
                        if self:GetCurrentList() == self.favoriteAbilityList then
                            return false
                        end
                        return false
                    end
                    return result
                end
            end
        end
    end)

    AddFavoriteKeybind_Gamepad()

    -- Linker Tooltip: in unserer Liste immer mit aktiven Script-IDs rendern
    ZO_PostHook(SCRIBING_GAMEPAD, "LayoutTooltipForCraftedAbilityData", function(self, _)
        if self.currentListType ~= "BSCSF_FAVORITES" then return end
        if not self._bscsfActiveDetails then return end
        if not (GAMEPAD_TOOLTIPS and GAMEPAD_TOOLTIPS.LayoutCraftedAbilityByIds) then return end

        local d = self._bscsfActiveDetails
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
        GAMEPAD_TOOLTIPS:LayoutCraftedAbilityByIds(
            GAMEPAD_LEFT_TOOLTIP,
            d.craftedAbilityId, d.primaryScriptId, d.secondaryScriptId, d.tertiaryScriptId,
            { allowDisabled = true, showConfigure = true }
        )
    end)

    -- A-Button („UI_SHORTCUT_PRIMARY“) erweitern: Auswahl in Favoriten-Liste anwenden
    ZO_PostHook(SCRIBING_GAMEPAD, "InitializeKeybindStripDescriptors", function(self)
        if not self.keybindStripDescriptor then return end
        for _, desc in ipairs(self.keybindStripDescriptor) do
            if desc.keybind == "UI_SHORTCUT_PRIMARY" and not desc._bscsfWrapped then
                local oldCb = desc.callback
                desc.callback = function()
                    if self:GetCurrentList() == self.favoriteAbilityList then
                        local entryData = self.favoriteAbilityList:GetTargetData()
                        if entryData and entryData.AbilityData then
                            ApplyFavoriteToScreen(self, entryData.AbilityData)
                        end
                        return
                    end
                    if oldCb then oldCb() end
                end
                desc._bscsfWrapped = true
                break
            end
        end
    end)
end
