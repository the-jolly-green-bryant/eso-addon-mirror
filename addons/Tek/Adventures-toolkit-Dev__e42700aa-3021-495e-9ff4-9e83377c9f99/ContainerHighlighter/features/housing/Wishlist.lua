function NWT.BuildWishlistItems()
    local hd = NWT.HousingDashboard
    local sv = NWT.savedVars.wishlist
    hd.wishlistItems = {}
    if sv then
        local activeProject = sv.activeProject or "Default"
        local items = sv.projects and sv.projects[activeProject] or {}
        for key, data in pairs(items) do
            table.insert(hd.wishlistItems, { key = key, name = data.name or key, data = data })
        end
        table.sort(hd.wishlistItems, function(a, b) return a.name < b.name end)
    end
    
    if hd.selectedWishlistIndex > #hd.wishlistItems then
        hd.selectedWishlistIndex = math.max(1, #hd.wishlistItems)
    end
end

function NWT.SyncHiddenPlannerList()
    local hd = NWT.HousingDashboard
    for i, item in ipairs(hd.wishlistItems or {}) do
        local entryData = ZO_GamepadEntryData:New(item.name or item.key or "Item")
        entryData.key = item.key
        entryData.index = i
        NWT.HiddenHouseList:AddEntry("ZO_GamepadItemEntryTemplate", entryData)
    end
    NWT.HiddenHouseList:Commit()
    if hd.selectedWishlistIndex and hd.wishlistItems and hd.selectedWishlistIndex <= #hd.wishlistItems then
        NWT.HiddenHouseList:SetSelectedIndexWithoutAnimation(hd.selectedWishlistIndex)
    end
end

function NWT.UpdateHousingWishlistVisuals()
    local ui = ATK_Housing_UI
    if not ui then return end
    
    local hd = NWT.HousingDashboard
    local rightPanel = ui:GetNamedChild("RightPanel") or ui:GetNamedChild("RightCol")
    if not rightPanel then return end
    
    local sv = NWT.savedVars and NWT.savedVars.wishlist
    local isActivePanel = (hd.activePanel == "wishlist")
    
    if not sv then return end
    local activeProject = sv.activeProject or "Default"
    
    local header = rightPanel:GetNamedChild("Header")
    if header then
        header:SetText(isActivePanel and string.format("|cFFD700>> %s <<|r", activeProject) or string.format("|cAAFFAA%s|r", activeProject))
    end
    
    for i = 1, 15 do
        local itemLabel = rightPanel:GetNamedChild("Item" .. i)
        if itemLabel then
            if hd.wishlistItems and hd.wishlistItems[i] then
                local item = hd.wishlistItems[i]
                local prefix = (i == hd.selectedWishlistIndex and isActivePanel) and "|cFFD700> |r" or ""
                itemLabel:SetText(prefix .. (item.name or item.key or "Unknown"))
            else
                itemLabel:SetText("")
            end
        end
    end
end

function NWT.UpdateHousingWishlistPanel()
    local ui = ATK_Housing_UI
    if not ui then return end
    
    local hd = NWT.HousingDashboard
    local rightPanel = ui:GetNamedChild("RightPanel") or ui:GetNamedChild("RightCol")
    if not rightPanel then return end
    
    local sv = NWT.savedVars and NWT.savedVars.wishlist
    if not sv then return end
    
    local activeProject = sv.activeProject or "Default"
    local items = sv.projects and sv.projects[activeProject] or {}
    
    local projectCount = 0
    for _ in pairs(sv.projects or {}) do projectCount = projectCount + 1 end
    
    local header = rightPanel:GetNamedChild("Header")
    if header then header:SetText("|cFFD700Planner: " .. activeProject .. "|r") end
    local projInfo = rightPanel:GetNamedChild("ProjectInfo")
    if projInfo then
        projInfo:SetText("Folder " .. (hd.projectIndex or 1) .. "/" .. projectCount .. " | " .. #hd.wishlistItems .. " items")
    end
    
    if not hd.wishlistIndex then hd.wishlistIndex = 1 end
    if hd.wishlistIndex > #hd.wishlistItems then hd.wishlistIndex = math.max(1, #hd.wishlistItems) end
    if not hd.wishlistScroll then hd.wishlistScroll = 0 end
    
    local maxVisible = 15
    for i = 1, maxVisible do
        local itemLabel = rightPanel:GetNamedChild("Item" .. i)
        local itemIdx = hd.wishlistScroll + i
        if itemLabel then
            if hd.wishlistItems[itemIdx] then
                local item = hd.wishlistItems[itemIdx]
                itemLabel:SetText(itemIdx == hd.wishlistIndex and "|cFFFF00►►► " .. item.name .. " ◄◄◄|r" or "    |cAAAAAA" .. item.name .. "|r")
            else
                itemLabel:SetText("")
            end
        end
    end
    
    local summary = rightPanel:GetNamedChild("Summary")
    if summary then
        summary:SetText("|c888888Use D-Pad to navigate\nLB/RB to switch projects\nX to remove selected item|r")
    end
end

function NWT.HousingWishlistNavigate(direction)
    local hd = NWT.HousingDashboard
    local maxVisible = 15
    local itemCount = hd.wishlistItems and #hd.wishlistItems or 0
    if direction == "up" then
        if hd.wishlistIndex > 1 then
            hd.wishlistIndex = hd.wishlistIndex - 1
            if hd.wishlistIndex <= hd.wishlistScroll then hd.wishlistScroll = hd.wishlistIndex - 1 end
        end
    elseif direction == "down" then
        if hd.wishlistIndex < itemCount then
            hd.wishlistIndex = hd.wishlistIndex + 1
            if hd.wishlistIndex > hd.wishlistScroll + maxVisible then hd.wishlistScroll = hd.wishlistIndex - maxVisible end
        end
    end
    NWT.UpdateHousingWishlistPanel()
end

function NWT.HousingWishlistSwitchProject(direction)
    local sv = NWT.savedVars.wishlist
    if not sv or not sv.projects then return end
    local hd = NWT.HousingDashboard
    local projects = {}
    for name, _ in pairs(sv.projects) do table.insert(projects, name) end
    table.sort(projects)
    
    local currentIdx = 1
    for i, name in ipairs(projects) do if name == sv.activeProject then currentIdx = i break end end
    
    if direction == "left" then
        currentIdx = currentIdx - 1
        if currentIdx < 1 then currentIdx = #projects end
    else
        currentIdx = currentIdx + 1
        if currentIdx > #projects then currentIdx = 1 end
    end
    
    sv.activeProject = projects[currentIdx]
    hd.projectIndex = currentIdx
    hd.wishlistIndex = 1
    hd.wishlistScroll = 0
NWT.Debug("|cFFD700[Wishlist]|r Active: " .. sv.activeProject)
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateHousingWishlistPanel()
end

function NWT.HousingWishlistRemoveItem()
    local hd = NWT.HousingDashboard
    local sv = NWT.savedVars.wishlist
    if not sv or not hd.wishlistItems or #hd.wishlistItems == 0 then return end
    local item = hd.wishlistItems[hd.selectedWishlistIndex] or hd.wishlistItems[hd.wishlistIndex]
    if not item then return end
    local activeProject = sv.activeProject
    if sv.projects[activeProject] and sv.projects[activeProject][item.key] then
        sv.projects[activeProject][item.key] = nil
NWT.Debug("|cFF6666[Wishlist]|r Removed: " .. (item.name or "Item"))
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        NWT.UpdateHousingDashboard()
    end
end

function NWT.GetActiveWishlist()
    local sv = NWT.savedVars.wishlist
    if not sv.projects[sv.activeProject] then sv.projects[sv.activeProject] = {} end
    return sv.projects[sv.activeProject]
end

function NWT.AddToWishlist(itemLink, projectName)
    if not itemLink or itemLink == "" then return end
    local sv = NWT.savedVars.wishlist
    local project = projectName or sv.activeProject
    if not sv.projects[project] then sv.projects[project] = {} end
    local itemId = GetItemLinkItemId(itemLink)
    if not itemId or itemId == 0 then return end
    local itemName = GetItemLinkName(itemLink)
    if not itemName or itemName == "" then return end
    if sv.projects[project][itemId] then sv.projects[project][itemId].count = (sv.projects[project][itemId].count or 1) + 1
    else sv.projects[project][itemId] = { name = itemName, link = itemLink, count = 1, added = GetTimeStamp() } end
NWT.Debug(string.format("|c00FF00[Housing Planner]|r Added %s to folder '|cFFFFFF%s|r'", itemLink, project))
end

function NWT.RemoveFromWishlist(itemId, projectName)
    local sv = NWT.savedVars.wishlist
    local project = projectName or sv.activeProject
    if sv.projects[project] and sv.projects[project][itemId] then
        local name = sv.projects[project][itemId].name
        sv.projects[project][itemId] = nil
NWT.Debug(string.format("|cFFFF00[Housing Planner]|r Removed %s from folder '|cFFFFFF%s|r'", name, project))
    end
end

function NWT.CreateWishlistProject(name)
    if not name or name == "" then return end
    local sv = NWT.savedVars.wishlist
    if not sv.projects[name] then
        sv.projects[name] = {}
NWT.Debug(string.format("|c00FF00[Housing Planner]|r Folder '|cFFFFFF%s|r' created.", name))
    end
    sv.activeProject = name
end

function NWT.SetActiveWishlistProject(name)
    local sv = NWT.savedVars.wishlist
    if sv.projects[name] then
        sv.activeProject = name
NWT.Debug(string.format("|c00FF00[Housing Planner]|r Active folder set to '|cFFFFFF%s|r'", name))
    else
NWT.Debug(string.format("|cFF0000Error:|r Folder '|cFFFFFF%s|r' not found.", name))
    end
end

function NWT.DeleteWishlistProject(name)
    local sv = NWT.savedVars.wishlist
    if name == "Default" then NWT.Debug("|cFF0000Error:|r Cannot delete the 'Default' folder.") return end
    if sv.projects[name] then
        sv.projects[name] = nil
        if sv.activeProject == name then sv.activeProject = "Default" end
NWT.Debug(string.format("|cFFFF00[Housing Planner]|r Folder '|cFFFFFF%s|r' deleted.", name))
    else d(string.format("|cFF0000Error:|r Folder '|cFFFFFF%s|r' not found.", name)) end
end

function NWT.RenameWishlistProject(oldName, newName)
    if not newName or newName == "" then return end
    local sv = NWT.savedVars.wishlist
    if oldName == "Default" then NWT.Debug("|cFF0000Error:|r Cannot rename the 'Default' folder.") return end
    if sv.projects[oldName] then
        if sv.projects[newName] then d(string.format("|cFF0000Error:|r Folder '|cFFFFFF%s|r' already exists.", newName)) return end
        sv.projects[newName] = sv.projects[oldName]
        sv.projects[oldName] = nil
        if sv.activeProject == oldName then sv.activeProject = newName end
NWT.Debug(string.format("|c00FF00[Housing Planner]|r Folder '|cFFFFFF%s|r' renamed to '|cFFFFFF%s|r'.", oldName, newName))
    else d(string.format("|cFF0000Error:|r Folder '|cFFFFFF%s|r' not found.", oldName)) end
end

function NWT.ListWishlist(projectName)
    local sv = NWT.savedVars.wishlist
    local project = projectName or sv.activeProject
    local list = sv.projects[project]
    if not list or next(list) == nil then d(string.format("|c00BFFF[Wishlist]|r Project '|cFFFFFF%s|r' is empty.", project)) return end
NWT.Debug(string.format("|c00FF00========== WISHLIST: %s ==========|r", string.upper(project)))
    local totalItems = 0
    for itemId, data in pairs(list) do
        local displayName = data.link or data.name or ("Item " .. tostring(itemId))
        local count = data.count or 1
NWT.Debug(string.format("  - %s x%d", displayName, count))
        totalItems = totalItems + count
    end
NWT.Debug(string.format("|c00FF00Total: %d items|r", totalItems))
NWT.Debug("|c00FF00========================================|r")
end

function NWT.AddTargetedFurnitureToWishlist()
    local browserGamepad = GAMEPAD_HOUSING_FURNITURE_BROWSER or ZO_HOUSING_FURNITURE_BROWSER_GAMEPAD or HOUSING_FURNITURE_BROWSER_GAMEPAD or _G["GAMEPAD_HOUSING_FURNITURE_BROWSER"] or _G["ZO_HousingFurnitureBrowser_Gamepad"]
    if not browserGamepad then NWT.Debug("|cFFFF00[Wishlist]|r Open the furniture browser first") return end
    local targetData, itemLink, itemName = nil, nil, nil
    if browserGamepad.GetCurrentList then local cl = browserGamepad:GetCurrentList() if cl then targetData = cl:GetTargetData() end end
    if not targetData and browserGamepad.GetTargetData then targetData = browserGamepad:GetTargetData() end
    if not targetData and browserGamepad.currentList then local l = browserGamepad.currentList if l.selectedData then targetData = l.selectedData elseif l.GetTargetData then targetData = l:GetTargetData() end end
    if targetData then
        itemName = targetData.name or targetData.formattedName or targetData.displayName or targetData.text or targetData.label or targetData.rawName
        if targetData.bagId and targetData.slotIndex then itemLink, itemName = GetItemLink(targetData.bagId, targetData.slotIndex), itemName or GetItemName(targetData.bagId, targetData.slotIndex)
        elseif targetData.collectibleId then itemName = itemName or GetCollectibleName(targetData.collectibleId)
        elseif targetData.furnitureDataId then local name = GetFurnitureDataInfo(targetData.furnitureDataId) itemName = itemName or name
        elseif targetData.dataEntry and targetData.dataEntry.data then local nested = targetData.dataEntry.data itemName = itemName or nested.name or nested.formattedName end
    else NWT.Debug("|cFFFF00[Wishlist]|r No item selected") return end
    if itemLink and itemLink ~= "" then NWT.AddToWishlist(itemLink) PlaySound(SOUNDS.POSITIVE_CLICK)
    elseif itemName and itemName ~= "" then
        local sv = NWT.savedVars.wishlist
        local project = sv.activeProject
        if not sv.projects[project] then sv.projects[project] = {} end
        local itemId = targetData.collectibleId or targetData.furnitureDataId or ("name_" .. itemName)
        if sv.projects[project][itemId] then sv.projects[project][itemId].count = (sv.projects[project][itemId].count or 1) + 1
        else sv.projects[project][itemId] = { name = itemName, link = nil, count = 1, timestamp = GetTimeStamp(), isCollectible = (targetData.collectibleId ~= nil) } end
NWT.Debug(string.format("|c00FF00[Wishlist]|r Added |cFFFFFF%s|r to '%s'", itemName, project))
        PlaySound(SOUNDS.POSITIVE_CLICK)
    else NWT.Debug("|cFFFF00[Wishlist]|r Could not get item name") end
end

function NWT.AddWishlistKeybinds()
    if not NWT.wishlistKeybindsAdded and KEYBIND_STRIP then
        if not NWT.wishlistKeybindGroup then
            NWT.wishlistKeybindGroup = { { name = "Add to Wishlist", order = 100, keybind = "UI_SHORTCUT_QUATERNARY", callback = function() NWT.AddTargetedFurnitureToWishlist() end }, }
        end
        KEYBIND_STRIP:AddKeybindButtonGroup(NWT.wishlistKeybindGroup)
        NWT.wishlistKeybindsAdded = true
    end
end

function NWT.RemoveWishlistKeybinds()
    if NWT.wishlistKeybindsAdded and KEYBIND_STRIP then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.wishlistKeybindGroup)
        KEYBIND_STRIP:PushKeybindGroupState()
        KEYBIND_STRIP:PopKeybindGroupState()
        NWT.wishlistKeybindsAdded = false
    end
end

function NWT.SetupHousingWishlistKeybinds()
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, newState)
        if scene:GetName() == "gamepad_housing_furniture_scene" then
            if newState == SCENE_SHOWING then zo_callLater(function() NWT.AddWishlistKeybinds() end, 200)
            elseif newState == SCENE_HIDING then NWT.RemoveWishlistKeybinds() end
        end
    end)
end
