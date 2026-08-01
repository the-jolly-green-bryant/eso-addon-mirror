local LIB = LibBSCWizardBridge
if not LIB then return end

local PROVIDER_KEY = "WizardsWardrobe"
local WWB = {
    providerKey = PROVIDER_KEY,
    initialized = false,
    pendingLoadContext = nil,
    pendingDeletePage = nil,
    pendingCryptCanonFix = nil,
}

local function makeContext(zone, pageId, index, scope)
    if not zone or not zone.tag or not pageId then return nil end

    local context = {
        zoneTag = zone.tag,
        pageId = pageId,
    }

    if index ~= nil then
        context.index = index
    end

    context.scope = LIB:NormalizeScope(scope)

    if context.scope == LIB.SCOPE_SETUP and context.index == nil then
        return nil
    end

    return context
end

local function getSetupName(context)
    if not context then return "" end
    local ww = WizardsWardrobe
    local setups = ww and ww.setups
    local setup = setups and setups[context.zoneTag] and setups[context.zoneTag][context.pageId] and setups[context.zoneTag][context.pageId][context.index]
    return setup and setup.name or ""
end

local function getPageName(context)
    if not context then return "" end
    local ww = WizardsWardrobe
    local pages = ww and ww.pages
    local page = pages and pages[context.zoneTag] and pages[context.zoneTag][context.pageId]
    return page and page.name or ""
end

local CRYPTCANON_ITEM_ID = 194509
local CRYPTCANON_SET_ID = 516
local CRYPTCANON_ULTIMATE_ABILITY_ID = 195031

local function isCryptCanonGear(gear)
    if not gear then return false end

    local link = gear.link
    if link and link ~= "" then
        local itemId = GetItemLinkItemId(link)
        if itemId == CRYPTCANON_ITEM_ID then
            return true
        end

        local setId = select(6, GetItemLinkSetInfo(link, false))
        if setId == CRYPTCANON_SET_ID then
            return true
        end
    end

    return gear.setId == CRYPTCANON_SET_ID or gear.itemId == CRYPTCANON_ITEM_ID
end

local function setupHasCryptCanon(setup)
    if not setup or not setup.GetGearInSlot then return false end
    return isCryptCanonGear(setup:GetGearInSlot(EQUIP_SLOT_CHEST))
end

local function getSetupUltimateSkills(setup)
    local skills = setup and setup.GetSkills and setup:GetSkills()
    return {
        [0] = skills and skills[0] and skills[0][8] or nil,
        [1] = skills and skills[1] and skills[1][8] or nil,
    }
end

local function shouldUseCryptCanonUltimateFix(setup)
    local ww = WizardsWardrobe
    if not ww or not setup or setupHasCryptCanon(setup) then return false end
    if ww.HasCryptCanon and ww.HasCryptCanon() then return true end

    local chestLink = GetItemLink(BAG_WORN, EQUIP_SLOT_CHEST, LINK_STYLE_DEFAULT)
    if chestLink and chestLink ~= "" then
        if GetItemLinkItemId(chestLink) == CRYPTCANON_ITEM_ID then
            return true
        end
        local setId = select(6, GetItemLinkSetInfo(chestLink, false))
        if setId == CRYPTCANON_SET_ID then
            return true
        end
    end

    return false
end

function WWB:PrepareCryptCanonFix(zone, pageId, index)
    self.pendingCryptCanonFix = nil

    local ww = WizardsWardrobe
    if not ww or not Setup or not zone or not zone.tag or pageId == nil or index == nil then return end

    local setup = Setup:FromStorage(zone.tag, pageId, index)
    if not setup or setup:IsEmpty() then return end
    if not shouldUseCryptCanonUltimateFix(setup) then return end

    self.pendingCryptCanonFix = {
        zoneTag = zone.tag,
        pageId = pageId,
        index = index,
        ultimates = getSetupUltimateSkills(setup),
    }
end

function WWB:RunCryptCanonFixIfNeeded()
    local fix = self.pendingCryptCanonFix
    self.pendingCryptCanonFix = nil
    if not fix then return end

    local ww = WizardsWardrobe
    if not ww then return end

    local attempts = 0
    local maxAttempts = 60

    local function tryApply()
        attempts = attempts + 1

        local stillHasCryptCanon = (ww.HasCryptCanon and ww.HasCryptCanon()) or false
        if stillHasCryptCanon or (ww.IsReadyToSwap and not ww.IsReadyToSwap()) then
            if attempts < maxAttempts then
                zo_callLater(tryApply, 50)
            end
            return
        end

        for hotbarCategory = 0, 1 do
            local abilityId = fix.ultimates and fix.ultimates[hotbarCategory]
            if abilityId ~= CRYPTCANON_ULTIMATE_ABILITY_ID then
                ww.SlotSkill(hotbarCategory, 8, abilityId)
            end
        end
    end

    zo_callLater(tryApply, 50)
end

local function wrapControlHandler(control, eventName, uniqueKey, handler, runOriginalFirst)
    if not control or not handler then return end
    control.__libBSCWrappedHandlers = control.__libBSCWrappedHandlers or {}

    local existingWrapper = control.__libBSCWrappedHandlers[uniqueKey]
    local currentHandler = control:GetHandler(eventName)
    if existingWrapper and currentHandler == existingWrapper then
        return
    end

    local original = currentHandler
    local wrapper = function(...)
        if runOriginalFirst and original then
            original(...)
        end
        handler(...)
        if not runOriginalFirst and original then
            original(...)
        end
    end

    control.__libBSCWrappedHandlers[uniqueKey] = wrapper
    control:SetHandler(eventName, wrapper)
end

local function wrapButtonHandler(button, eventName, uniqueKey, handler)
    wrapControlHandler(button, eventName, uniqueKey, handler, false)
end

local function normalizeChampionSlotId(rawId)
    local id = tonumber(rawId) or 0
    if id <= 0 then
        return 0, 0
    end

    local championSkillType = GetChampionSkillType(id)
    if championSkillType ~= nil then
        local abilityId = GetChampionAbilityId(id)
        if abilityId and abilityId > 0 then
            return id, abilityId
        end
        return id, id
    end

    return id, id
end

local function areChampionSlotIdsEqual(leftId, rightId)
    local leftRaw, leftComparable = normalizeChampionSlotId(leftId)
    local rightRaw, rightComparable = normalizeChampionSlotId(rightId)

    if leftRaw == rightRaw then
        return true
    end

    if leftComparable == rightComparable then
        return true
    end

    return leftComparable == 0 and rightComparable == 0
end

local function getCurrentChampionSlotIds(slotIndex)
    local ww = WizardsWardrobe
    local currentRawId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION) or 0
    local currentAbilityId = currentRawId

    if ww and ww.GetSlotBoundAbilityId then
        currentAbilityId = ww.GetSlotBoundAbilityId(slotIndex, HOTBAR_CATEGORY_CHAMPION) or currentRawId
    end

    return currentRawId, currentAbilityId
end

local function isChampionSlotDifferent(slotIndex, savedId)
    local currentRawId, currentAbilityId = getCurrentChampionSlotIds(slotIndex)
    return not areChampionSlotIdsEqual(savedId, currentRawId)
        and not areChampionSlotIdsEqual(savedId, currentAbilityId)
end

local function compareChampionPointsSmart(setup)
    if not setup or not setup.GetCP then return false end

    for slotIndex = 1, 12 do
        local savedId = setup:GetCP()[slotIndex] or 0
        if isChampionSlotDifferent(slotIndex, savedId) then
            return false
        end
    end

    return true
end

local MONITOR_NAME = LIB.name .. "_WWEditorMonitor"

function WWB:StartEditorMonitor()
    if self.monitoring then return end
    self.monitoring = true
    EVENT_MANAGER:RegisterForUpdate(MONITOR_NAME, 100, function()
        if LIB.activeProviderKey ~= WWB.providerKey then return end

        local activeScope = LIB:NormalizeScope(LIB.activeContext and LIB.activeContext.scope)
        local windowHidden = not WizardsWardrobeWindow or WizardsWardrobeWindow:IsHidden()

        if activeScope == LIB.SCOPE_PAGE then
            if windowHidden then
                LIB:HideEditorForProvider(WWB.providerKey)
                WWB:StopEditorMonitor()
                return
            end

            if LIB.activeOptions and LIB.activeOptions.matchAnchorHeight == true and LIB.editor and LIB.editor.win and not LIB.editor.win:IsHidden() then
                local height = WizardsWardrobeWindow.GetHeight and WizardsWardrobeWindow:GetHeight() or 0
                local lastHeight = tonumber(WWB.lastPageEditorAnchorHeight) or 0
                if height > 0 and math.abs(height - lastHeight) >= 1 then
                    WWB.lastPageEditorAnchorHeight = height
                    LIB:_RelayoutEditor(LIB.editor.currentContentHeight or 1)
                end
            end
            return
        end

        local modifyHidden = not WizardsWardrobeModify or WizardsWardrobeModify:IsHidden()
        local modifyDialogHidden = WizardsWardrobeModifyDialog and WizardsWardrobeModifyDialog:IsHidden()

        if windowHidden or modifyHidden or modifyDialogHidden then
            LIB:HideEditorForProvider(WWB.providerKey)
            WWB:StopEditorMonitor()
        end
    end)
end

function WWB:StopEditorMonitor()
    if not self.monitoring then return end
    self.monitoring = false
    EVENT_MANAGER:UnregisterForUpdate(MONITOR_NAME)
end

function WWB.getContextText(context)
    local pageName = getPageName(context)
    local text = string.format("WizardsWardrobe | Zone: %s | Page %s", tostring(context.zoneTag), tostring(context.pageId))
    if pageName and pageName ~= "" then
        text = text .. string.format(" (%s)", pageName)
    end

    if LIB:NormalizeScope(context and context.scope) == LIB.SCOPE_PAGE then
        return text
    end

    local setupName = getSetupName(context)
    text = text .. string.format(" | Setup %s", tostring(context.index))
    if setupName and setupName ~= "" then
        text = text .. string.format(" (%s)", setupName)
    end
    return text
end

function WWB:GetCurrentPageContext()
    local ww = WizardsWardrobe
    if not ww or not ww.selection then return nil end
    return makeContext(ww.selection.zone, ww.selection.pageId, nil, LIB.SCOPE_PAGE)
end

function WWB:IsPageEditorActive()
    return LIB.activeProviderKey == self.providerKey
        and LIB:NormalizeScope(LIB.activeContext and LIB.activeContext.scope) == LIB.SCOPE_PAGE
end

function WWB:PageContextEquals(left, right)
    if not left or not right then return false end
    return left.zoneTag == right.zoneTag
        and left.pageId == right.pageId
        and LIB:NormalizeScope(left.scope) == LIB:NormalizeScope(right.scope)
end

function WWB:HasPageClients()
    return LIB:HasClientsForScope(self.providerKey, LIB.SCOPE_PAGE)
end

function WWB:ShouldShowPageEditor()
    return self:HasPageClients()
        and WizardsWardrobeWindow ~= nil
        and not WizardsWardrobeWindow:IsHidden()
end

function WWB:ShowOrRefreshPageEditor(forceReload)
    if not self:ShouldShowPageEditor() then return false end

    if self:IsPageEditorActive() then
        return self:RefreshPageEditor(forceReload)
    end

    return self:OpenPageEditor()
end

function WWB:RestorePageEditorIfNeeded(forceReload)
    if not self:ShouldShowPageEditor() then
        LIB:HideEditorForProvider(self.providerKey)
        self:StopEditorMonitor()
        return false
    end

    return self:ShowOrRefreshPageEditor(forceReload)
end

function WWB:GetPageEditorOptions(baseOptions)
    local options = {}
    if type(baseOptions) == "table" then
        for key, value in pairs(baseOptions) do
            options[key] = value
        end
    end

    options.anchorTo = options.anchorTo or WizardsWardrobeWindow
    options.title = options.title or "Page Links"
    options.drawTier = options.drawTier or DT_LOW
    options.hideSaveButton = true
    options.hideCloseButton = true
	options.hideClearButton = true
    options.collapsible = true
    options.startCollapsed = true
    options.collapsedWidth = options.collapsedWidth or 250
    options.collapseKey = options.collapseKey or (self.providerKey .. ":page")
    options.matchAnchorHeight = true


    return options
end

function WWB:GetModifyEditorOptions(baseOptions)
    local options = {}
    if type(baseOptions) == "table" then
        for key, value in pairs(baseOptions) do
            options[key] = value
        end
    end

    options.anchorTo = options.anchorTo or WizardsWardrobeModifyDialog or WizardsWardrobeModify
    options.hideSaveButton = false
    options.hideCloseButton = true
    options.footerButtons = options.footerButtons or {}
    options.footerButtons.save = options.footerButtons.save or {
        onClick = function(args)
            args.lib:CommitActiveEditor(true)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Setup Links saved.")
            return true
        end,
    }

    return options
end

function WWB:RefreshPageEditor(forceReload)
    if not self:ShouldShowPageEditor() then return false end

    local context = self:GetCurrentPageContext()
    if not context then
        self:ClosePageEditor()
        return false
    end

    local activeContext = LIB.activeContext
    local shouldReload = forceReload == true or not self:PageContextEquals(activeContext, context)

    if shouldReload then
        local options = self:GetPageEditorOptions(LIB.activeOptions)
        LIB:OpenEditor(self.providerKey, context, options)
    else
        LIB.activeContext = {
            zoneTag = context.zoneTag,
            pageId = context.pageId,
            scope = context.scope,
        }
        if LIB.editor and LIB.editor.subtitle then
            LIB.editor.subtitle:SetText(LIB:_GetContextText(self.providerKey, context))
        end
    end

    self:StartEditorMonitor()
    return true
end

function WWB:OnModifyDialogOpened(index)
    local ww = WizardsWardrobe
    if not ww or not ww.selection then return end
    if not LIB:HasClientsForScope(self.providerKey, LIB.SCOPE_SETUP) then return end

    local context = makeContext(ww.selection.zone, ww.selection.pageId, index, LIB.SCOPE_SETUP)
    if not context then return end

    LIB:OpenEditor(self.providerKey, context, self:GetModifyEditorOptions({
        anchorTo = WizardsWardrobeModifyDialog or WizardsWardrobeModify,
    }))
    self:StartEditorMonitor()

    if WizardsWardrobeModifyDialogSave then
        wrapButtonHandler(WizardsWardrobeModifyDialogSave, "OnClicked", "modify_dialog_save_bridge", function(...)
            LIB:SaveActiveEditorPayload()
            WWB:StopEditorMonitor()
        end)
    end

    if WizardsWardrobeModifyDialogClear then
        wrapButtonHandler(WizardsWardrobeModifyDialogClear, "OnClicked", "modify_dialog_clear_bridge", function(...)
            LIB:ClearActiveEditor(true)
            WWB:StartEditorMonitor()
        end)
    end

    if WizardsWardrobeModifyDialogHide then
        wrapButtonHandler(WizardsWardrobeModifyDialogHide, "OnClicked", "modify_dialog_hide_button_bridge", function(...)
            LIB:HideEditorForProvider(WWB.providerKey)
            WWB:StopEditorMonitor()
        end)
    end
end

function WWB:OpenPageEditor()
    local ww = WizardsWardrobe
    if not ww or not ww.selection then return false end
    if not self:HasPageClients() then return false end

    local context = makeContext(ww.selection.zone, ww.selection.pageId, nil, LIB.SCOPE_PAGE)
    if not context then return false end

    LIB:OpenEditor(self.providerKey, context, self:GetPageEditorOptions())
    self:StartEditorMonitor()
    return true
end

function WWB:ClosePageEditor()
    LIB:HideEditorForProvider(self.providerKey)
    self:StopEditorMonitor()
end


function WWB:InitHooks()
    local ww = WizardsWardrobe
    if not ww or not ww.gui or not ww.callbackManager then return false end

    LIB:RegisterProvider(self.providerKey, self)

    if not ww._libBSCOriginalCompareCP then
        ww._libBSCOriginalCompareCP = ww.CompareCP
    end

    if not ww._libBSCOriginalLoadCP then
        ww._libBSCOriginalLoadCP = ww.LoadCP
    end

    if not ww._libBSCOriginalAddHotbarSlotToChampionPurchaseRequest then
        ww._libBSCOriginalAddHotbarSlotToChampionPurchaseRequest = AddHotbarSlotToChampionPurchaseRequest
    end

    if not ww._libBSCOriginalSendChampionPurchaseRequest then
        ww._libBSCOriginalSendChampionPurchaseRequest = SendChampionPurchaseRequest
    end

    ww.CompareCP = function(setup)
        return compareChampionPointsSmart(setup)
    end

    ww.LoadCP = function(setup)
        WWB.activeChampionPointLoad = nil

        local cpTable = setup and setup.GetCP and setup:GetCP()
        if not cpTable or #cpTable == 0 then
            return ww._libBSCOriginalLoadCP(setup)
        end

        if compareChampionPointsSmart(setup) then
            return ww._libBSCOriginalLoadCP(setup)
        end

        WWB.activeChampionPointLoad = {
            setup = setup,
            touchedSlots = 0,
        }

        return ww._libBSCOriginalLoadCP(setup)
    end

    AddHotbarSlotToChampionPurchaseRequest = function(slotIndex, starId)
        local state = WWB.activeChampionPointLoad
        local original = ww._libBSCOriginalAddHotbarSlotToChampionPurchaseRequest
        if not state or not original then
            return original(slotIndex, starId)
        end

        local targetId = tonumber(starId) or 0
        if not isChampionSlotDifferent(slotIndex, targetId) then
            return
        end

        state.touchedSlots = (state.touchedSlots or 0) + 1
        return original(slotIndex, starId)
    end

    SendChampionPurchaseRequest = function(...)
        local state = WWB.activeChampionPointLoad
        local original = ww._libBSCOriginalSendChampionPurchaseRequest
        if not state or not original then
            return original(...)
        end

        WWB.activeChampionPointLoad = nil

        if (state.touchedSlots or 0) <= 0 then
            return
        end

        return original(...)
    end

    ZO_PostHook(ww.gui, "ShowModifyDialog", function(arg1, arg2)
        local index = arg2 or arg1
        WWB:OnModifyDialogOpened(index)
    end)
    ZO_PostHook(ww.gui, "BuildPage", function(zone, pageId)
        if not zone or not zone.tag or not pageId then return end
        if not WWB:ShouldShowPageEditor() then return end

        local activeContext = LIB.activeContext
        local forceReload = not activeContext
            or activeContext.zoneTag ~= zone.tag
            or activeContext.pageId ~= pageId
            or LIB:NormalizeScope(activeContext.scope) ~= LIB.SCOPE_PAGE

        WWB:ShowOrRefreshPageEditor(forceReload)
    end)


    ZO_PreHook(ww, "LoadSetup", function(zone, pageId, index)
        WWB.pendingLoadContext = makeContext(zone, pageId, index, LIB.SCOPE_SETUP)
        WWB:PrepareCryptCanonFix(zone, pageId, index)
        return false
    end)

    ww.callbackManager:RegisterCallback("WW_OnSetupSwapSuccess", function()
        if WWB.pendingLoadContext then
            LIB:ApplyContext(WWB.providerKey, WWB.pendingLoadContext, "setup_loaded")
            WWB.pendingLoadContext = nil
        end
        WWB:RunCryptCanonFixIfNeeded()
    end)

    ZO_PostHook(ww, "DuplicateSetup", function(zone, pageId, index)
        local context = makeContext(zone, pageId, index, LIB.SCOPE_SETUP)
        if context then LIB:DuplicateSetup(WWB.providerKey, context) end
    end)

    ZO_PostHook(ww, "DeleteSetup", function(zone, pageId, index)
        local context = makeContext(zone, pageId, index, LIB.SCOPE_SETUP)
        if context then LIB:DeleteSetup(WWB.providerKey, context) end
    end)

    ZO_PostHook(ww, "ClearSetup", function(zone, pageId, index)
        local context = makeContext(zone, pageId, index, LIB.SCOPE_SETUP)
        if context then LIB:ClearSetup(WWB.providerKey, context) end
    end)

    ZO_PostHook(ww.gui, "RearrangeSetups", function(sortTable, zone, pageId)
        if zone and zone.tag and pageId then
            LIB:RearrangeSetups(WWB.providerKey, zone.tag, pageId, sortTable)
        end
    end)

    ZO_PostHook(ww.gui, "DuplicatePage", function()
        local selection = ww.selection
        if selection and selection.zone and selection.pageId then
            LIB:DuplicatePage(WWB.providerKey, selection.zone.tag, selection.pageId)
        end
    end)

    ZO_PreHook(ww.gui, "DeletePage", function()
        local selection = ww.selection
        if selection and selection.zone and selection.pageId then
            WWB.pendingDeletePage = {
                zoneTag = selection.zone.tag,
                pageId = selection.pageId,
            }
        end
        return false
    end)

    ZO_PostHook(ww.gui, "DeletePage", function()
        if WWB.pendingDeletePage then
            LIB:DeletePage(WWB.providerKey, WWB.pendingDeletePage.zoneTag, WWB.pendingDeletePage.pageId)
            WWB.pendingDeletePage = nil
        end
    end)

    ZO_PostHook(ww.gui, "RearrangePages", function(sortTable, zone)
        if zone and zone.tag then
            LIB:RearrangePages(WWB.providerKey, zone.tag, sortTable)
        end
    end)

    wrapControlHandler(WizardsWardrobeWindow, "OnShow", "window_show_bridge", function()
        zo_callLater(function()
            WWB:RestorePageEditorIfNeeded(true)
        end, 0)
    end, false)

    wrapControlHandler(WizardsWardrobeWindow, "OnHide", "window_hide_bridge", function()
        LIB:HideEditorForProvider(WWB.providerKey)
        WWB:StopEditorMonitor()
    end, false)

    wrapControlHandler(WizardsWardrobeModify, "OnHide", "modify_hide_bridge", function()
        zo_callLater(function()
            WWB:RestorePageEditorIfNeeded(true)
        end, 0)
    end, false)

    if WizardsWardrobeModifyDialog then
        wrapControlHandler(WizardsWardrobeModifyDialog, "OnHide", "modify_dialog_hide_bridge", function()
            zo_callLater(function()
                WWB:RestorePageEditorIfNeeded(true)
            end, 0)
        end, false)
    end

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
        if LIB.activeProviderKey ~= WWB.providerKey then return end
        if newState ~= SCENE_HIDING then return end

        zo_callLater(function()
            if LIB.activeProviderKey ~= WWB.providerKey then return end

            local activeScope = LIB:NormalizeScope(LIB.activeContext and LIB.activeContext.scope)
            local windowHidden = not WizardsWardrobeWindow or WizardsWardrobeWindow:IsHidden()

            if activeScope == LIB.SCOPE_PAGE then
                if windowHidden then
                    LIB:HideEditorForProvider(WWB.providerKey)
                    WWB:StopEditorMonitor()
                end
                return
            end

            local modifyHidden = not WizardsWardrobeModify or WizardsWardrobeModify:IsHidden()
            local modifyDialogHidden = WizardsWardrobeModifyDialog and WizardsWardrobeModifyDialog:IsHidden()

            if windowHidden or modifyHidden or modifyDialogHidden then
                LIB:HideEditorForProvider(WWB.providerKey)
                WWB:StopEditorMonitor()
            end
        end, 0)
    end)

    self.initialized = true
    return true
end

local function tryInit()
    if WWB.initialized then return end
    if WWB:InitHooks() then
        EVENT_MANAGER:UnregisterForUpdate(LIB.name .. "_WWRetry")
    end
end

EVENT_MANAGER:RegisterForEvent(LIB.name .. "_WWLoad", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(LIB.name .. "_WWLoad", EVENT_PLAYER_ACTIVATED)
    tryInit()
    if not WWB.initialized then
        EVENT_MANAGER:RegisterForUpdate(LIB.name .. "_WWRetry", 1000, tryInit)
    end
end)
