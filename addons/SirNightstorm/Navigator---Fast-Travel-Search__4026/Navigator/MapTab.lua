local Nav = Navigator

local MapTab = ZO_InitializingObject:Subclass()

MapTab.currentView = nil
MapTab.needsRefresh = Nav.REFRESH_NONE
MapTab.collapsedCategories = {}
MapTab.targetNode = 0

function MapTab:Initialize(control, view)
    self.control = control
    self.currentView = view

    Nav.log(control:GetName() .. "[shared]:init")
end

function MapTab:SetHandlers()
    self.control:SetHandler("OnEffectivelyShown", function(control)
        Nav.log(control:GetName() .. ".OnEffectivelyShown")
        Nav.lastTab = self
        self.visible = true
        if self.needsRefresh then
            self:ImmediateRefresh()
        else
            self:buildScrollList()
        end
        if Nav.Locations.keepsDirty then
            Nav.Locations:UpdateKeeps()
        end
    end)
    self.control:SetHandler("OnEffectivelyHidden", function(control)
        Navigator.log(control:GetName() .. ".OnEffectivelyHidden")
        self.visible = false
    end)
    --self.editControl:SetHandler("OnEffectivelyShown", function(control)
    --    Navigator.log("EditBox.OnEffectivelyShown 1")
    --    self:ResetSearch()
    --    Navigator.log("EditBox.OnEffectivelyShown 2")
    --    if Navigator.saved.autoFocus then
    --        Navigator.log("EditBox.OnEffectivelyShown 3")
    --        control:TakeFocus()
    --    end
    --    Navigator.log("EditBox.OnEffectivelyShown 4")
    --
    --end)
end

function MapTab:queueRefresh(refreshMode)
    if refreshMode == nil then refreshMode = Nav.REFRESH_REBUILD end

    if self.needsRefresh == Nav.REFRESH_NONE then
        self.needsRefresh = refreshMode
        if self.visible and not self.menuOpen then
            zo_callLater(function()
                if self.needsRefresh ~= Nav.REFRESH_NONE and self.visible and not self.menuOpen then
                    self:ImmediateRefresh(self.needsRefresh)
                else
                    -- Nav.log("MT:queueRefresh: skipped")
                end
            end, 50)
            -- Nav.log("MT:queueRefresh: queued")
        else
            -- Nav.log("MT:queueRefresh: not queued")
        end
    end
end

function MapTab:ShowUndiscovered()
    self.currentView = "all"
    self:ImmediateRefresh()
end

function MapTab:UpdateContent(searchString, keepTargetNode)
    self.searchString = searchString

    local zone = Nav.Locations:getCurrentMapZone()
    self.content = Nav.ViewManager:Build(self.searchString, self.currentView, zone)

    self:buildScrollList(keepTargetNode)
end

--- Add bookmark-related menu items to a Menu
--- @param menu Menu
--- @param data any
function MapTab:AddStandardMenuItems(menu, data)
    if data.dataEntry.categoryId == "bookmarks" then
        local yPad = 12
        if data.indexInCategory > 1 then
            menu:AddItem(GetString(NAVIGATOR_MENU_MOVEBOOKMARKUP), function()
                Nav.Bookmarks:Move(data.node, -1)
                self.menuOpen = false
                zo_callLater(function() self:ImmediateRefresh() end, 10)
            end, yPad)
            yPad = 0
        end
        if data.indexInCategory < data.categoryEntryCount then
            menu:AddItem(GetString(NAVIGATOR_MENU_MOVEBOOKMARKDOWN), function()
                Nav.Bookmarks:Move(data.node, 1)
                self.menuOpen = false
                zo_callLater(function() Nav.callback:FireCallbacks("Refresh") end, 10)
            end, yPad)
            yPad = 0
        end
        menu:AddItem(GetString(NAVIGATOR_MENU_REMOVEBOOKMARK), function()
            Nav.Bookmarks:remove(data.node)
            self.menuOpen = false
            zo_callLater(function() Nav.callback:FireCallbacks("Refresh") end, 10)
        end)
    end
end

function MapTab:IsViewingInitialZone()
    local zone = Nav.Locations:getCurrentMapZone()
    return not zone or zone.zoneId == Nav.initialMapZoneId
end

function MapTab:OnMapChanged()
    local mapId = GetCurrentMapId()
    if Nav.mapVisible and mapId ~= self.currentMapId then
        self.currentMapId = mapId
        local zone = Nav.Locations:getCurrentMapZone()
        Nav.log("OnMapChanged: now zoneId=%d mapId=%d initial=%d", zone and zone.zoneId or 0, mapId or 0, Nav.initialMapZoneId or 0)
        if zone and Nav.Locations:ShouldCollapseCategories(zone.zoneId) then
            self.collapsedCategories = { bookmarks = true, recents = true }
        else
            self.collapsedCategories = {}
        end

        if (self.searchString or "") == "" and self.currentView == nil then
            Nav.log("MT:OnMapChanged: UpdateContent")
            self.targetNode = 0
            self:UpdateContent("", false)
        end

        Nav.Node.RemovePings()
    end
end

function MapTab:onTextChanged(editbox)
    local searchString = string.lower(editbox:GetText())
    local setView = function(view)
        Nav.log("MapTab.onTextChanged: currentView = %d", view)
        self.currentView = view
        editbox:SetText("")
        editbox.editTextChanged = false
        searchString = ""
        self:UpdateViewControl()
    end

    if searchString == "z:" then
        setView("zones")
    elseif searchString == "h:" then
        setView("houses")
    elseif searchString == '@' or searchString == "p:" then
        setView("players")
    elseif searchString == "t:" then
        setView("guildTraders")
    elseif searchString == "m:" then
        setView("treasureMaps")
    elseif searchString == "a:" then
        self.currentView = "all"
        editbox:SetText("")
        editbox.editTextChanged = false
        searchString = ""
    else
        self.editControl.editTextChanged = true
    end

    self:UpdateContent(searchString, false)
end

function MapTab:OnEnter()
    local data = self:getTargetData()
    if data and data.node then
        if data.node.OnEnter then
            data.node:OnEnter()
        elseif data.node.OnClick then
            data.node:OnClick(false)
        end
    end
end

Nav.MapTab = MapTab
