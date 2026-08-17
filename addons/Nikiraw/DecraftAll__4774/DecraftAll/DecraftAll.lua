DecraftAll = DecraftAll or {}

local ADDON_NAME = "DecraftAll"
local ACTION_NAME = "DECRAFTALL_SELECT_ALL"
local DEFAULT_KEY = KEY_T
local RETRY_DELAY_MS = 100

local function Chat(message)
    if CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage(string.format("|cC8A85ADecraftAll|r : %s", message))
    end
end

local function IsUniversalDeconstructionVisible()
    if IsInGamepadPreferredMode() then
        return false
    end

    if not UNIVERSAL_DECONSTRUCTION or not UNIVERSAL_DECONSTRUCTION.deconstructionPanel then
        return false
    end

    local scene = UNIVERSAL_DECONSTRUCTION_KEYBOARD_SCENE
    if not scene or type(scene.GetState) ~= "function" then
        return false
    end

    local state = scene:GetState()
    return state == SCENE_SHOWING or state == SCENE_SHOWN
end

local function GetPanel()
    if not IsUniversalDeconstructionVisible() then
        return nil
    end
    return UNIVERSAL_DECONSTRUCTION.deconstructionPanel
end

local function IsExternallyProtected(bagId, slotIndex)
    -- Compatibilité facultative avec FCO ItemSaver.
    if FCOIS and FCOIS.IsDeconstructionLocked then
        return FCOIS.IsDeconstructionLocked(bagId, slotIndex, nil) == true
    end
    return false
end

local function GetFilteredInventoryRows(panel)
    local inventory = panel and panel.inventory
    local list = inventory and inventory.list
    if not list then
        return nil
    end
    return ZO_ScrollList_GetDataList(list)
end

local function CanSelect(panel, bagId, slotIndex)
    if not bagId or slotIndex == nil then
        return false
    end

    if panel:IsSlotted(bagId, slotIndex) then
        return false
    end

    if IsItemPlayerLocked(bagId, slotIndex) then
        return false
    end

    if IsExternallyProtected(bagId, slotIndex) then
        return false
    end

    return true
end

local function SelectAllFromCurrentView()
    local panel = GetPanel()
    if not panel then
        Chat("ouvre d'abord le menu de déconstruction de l'assistant.")
        return false
    end

    if ZO_CraftingUtils_IsPerformingCraftProcess() then
        Chat("attends la fin de la déconstruction en cours.")
        return false
    end

    -- Le DataList est la liste réellement filtrée par l'interface ESO :
    -- onglet actif, types d'artisanat choisis, banque incluse ou non, etc.
    local rows = GetFilteredInventoryRows(panel)
    if not rows then
        Chat("la liste des objets n'est pas encore prête.")
        return false
    end

    local selected = 0
    local protected = 0
    local skipped = 0
    local reachedLimit = false

    for _, entry in ipairs(rows) do
        local data = entry and entry.data
        local bagId = data and data.bagId
        local slotIndex = data and data.slotIndex

        if bagId and slotIndex ~= nil then
            if IsExternallyProtected(bagId, slotIndex) then
                protected = protected + 1
            elseif CanSelect(panel, bagId, slotIndex) then
                local before = panel.extractionSlot:GetNumItems()
                panel:AddItemToCraft(bagId, slotIndex)
                local after = panel.extractionSlot:GetNumItems()

                if after > before then
                    selected = selected + 1
                else
                    -- AddItemToCraft peut refuser un objet lorsque la limite native
                    -- de slots / d'itérations d'ESO est atteinte.
                    skipped = skipped + 1
                    if after >= MAX_ITEM_SLOTS_PER_DECONSTRUCTION then
                        reachedLimit = true
                        break
                    end
                end
            end
        end
    end

    if UNIVERSAL_DECONSTRUCTION.UpdateKeybindStrip then
        UNIVERSAL_DECONSTRUCTION:UpdateKeybindStrip()
    end

    if selected > 0 then
        local message = string.format("%d objet%s sélectionné%s.",
            selected,
            selected > 1 and "s" or "",
            selected > 1 and "s" or "")

        if protected > 0 then
            message = message .. string.format(" %d objet%s protégé%s ignoré%s.",
                protected,
                protected > 1 and "s" or "",
                protected > 1 and "s" or "",
                protected > 1 and "s" or "")
        end

        if reachedLimit or skipped > 0 then
            message = message .. " La limite native de sélection d'ESO a été atteinte."
        end

        Chat(message)
        return true
    end

    if panel:HasSelections() then
        Chat("tous les objets disponibles sont déjà sélectionnés.")
    else
        Chat("aucun objet déconstructible n'est disponible dans le filtre actuel.")
    end
    return false
end

function DecraftAll.SelectAll()
    -- Sur l'ouverture de l'assistant, la liste peut être rafraîchie une frame
    -- après l'affichage. On tente immédiatement puis une seconde fois très
    -- brièvement si la liste n'était pas encore disponible.
    local panel = GetPanel()
    if not panel then
        Chat("ouvre d'abord le menu de déconstruction de l'assistant.")
        return
    end

    local rows = GetFilteredInventoryRows(panel)
    if rows and #rows > 0 then
        SelectAllFromCurrentView()
        return
    end

    zo_callLater(function()
        SelectAllFromCurrentView()
    end, RETRY_DELAY_MS)
end

local keybindStripDescriptor =
{
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
        keybind = ACTION_NAME,
        name = function()
            return GetString(SI_BINDING_NAME_DECRAFTALL_SELECT_ALL)
        end,
        callback = DecraftAll.SelectAll,
        visible = function()
            return IsUniversalDeconstructionVisible()
                and not ZO_CraftingUtils_IsPerformingCraftProcess()
        end,
        enabled = function()
            local panel = GetPanel()
            return panel ~= nil and not ZO_CraftingUtils_IsPerformingCraftProcess()
        end,
    },
}

local keybindShown = false

local function RefreshKeybindStrip()
    local shouldShow = IsUniversalDeconstructionVisible()

    if shouldShow and not keybindShown then
        KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripDescriptor)
        keybindShown = true
    elseif not shouldShow and keybindShown then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripDescriptor)
        keybindShown = false
    elseif shouldShow and keybindShown then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindStripDescriptor)
    end
end

local function HookUniversalDeconstructionScene()
    local scene = UNIVERSAL_DECONSTRUCTION_KEYBOARD_SCENE
    if not scene or DecraftAll.sceneHooked then
        return false
    end

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
            zo_callLater(RefreshKeybindStrip, 0)
        elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
            RefreshKeybindStrip()
        end
    end)

    DecraftAll.sceneHooked = true
    RefreshKeybindStrip()
    return true
end

local function RegisterDefaultKeybind()
    -- Bindings.xml est chargé par ESO en même temps que l'addon, mais l'action
    -- peut ne pas être indexée dès EVENT_ADD_ON_LOADED. On attend donc qu'elle
    -- existe réellement avant d'enregistrer T comme raccourci par défaut.
    local layerIndex = GetActionIndicesFromName(ACTION_NAME)
    if not layerIndex then
        return false
    end

    CreateDefaultActionBind(
        ACTION_NAME,
        DEFAULT_KEY,
        KEY_INVALID,
        KEY_INVALID,
        KEY_INVALID,
        KEY_INVALID
    )
    return true
end

local function Initialize()
    ZO_CreateStringId("SI_BINDING_NAME_DECRAFTALL_SELECT_ALL", "Tout sélectionner pour déconstruire")

    -- Les contrôles ZO_Ingame et les actions de Bindings.xml peuvent finir de
    -- s'enregistrer juste après l'addon. Ces deux initialisations sont donc
    -- retentées brièvement, sans boucle permanente.
    local attempts = 0
    local function TryInitializeRuntime()
        attempts = attempts + 1

        local sceneReady = HookUniversalDeconstructionScene() or DecraftAll.sceneHooked
        local bindingReady = RegisterDefaultKeybind()

        if (sceneReady and bindingReady) or attempts >= 20 then
            RefreshKeybindStrip()
            return
        end
        zo_callLater(TryInitializeRuntime, 250)
    end
    TryInitializeRuntime()
end


local function OnPlayerActivated()
    RegisterDefaultKeybind()
    RefreshKeybindStrip()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
