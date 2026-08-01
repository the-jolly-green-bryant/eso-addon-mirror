local cbe    = CraftBagExtended
local util   = cbe.utility
local class  = cbe.classes
class.Module = ZO_Object:Subclass()

function class.Module:New(...)
    local instance = ZO_Object.New(self)
    instance:Initialize(...)
    return instance
end

local function AddFragment(self, fragment)
    if not fragment then return end
    if self.isFragmentTemporary then
        SCENE_MANAGER:AddFragment(fragment)
    else
        self.scene:AddFragment(fragment)
    end
end

local function RemoveFragment(self, fragment)
    if not fragment then return end
    if self.isFragmentTemporary == nil then
        self.isFragmentTemporary = self.scene.temporaryFragments and self.scene.temporaryFragments[fragment]
    end
    if self.isFragmentTemporary then
        SCENE_MANAGER:RemoveFragment(fragment)
    else
        self.scene:RemoveFragment(fragment)
    end
end

local function SwapFragments(self, removeFragment, addFragment, layoutFragment)
    -- Deactivate any active text search before swapping fragments
    for context, contextSearch in pairs(TEXT_SEARCH_MANAGER.contextSearches) do
        if contextSearch.isActive then
            TEXT_SEARCH_MANAGER:DeactivateTextSearch(context)
            break -- Only one can be active at a time
        end
    end

    if cbe.fragmentGroup then
        SCENE_MANAGER:RemoveFragmentGroup(cbe.fragmentGroup)
        for i = 1, #cbe.fragmentGroup do
            if cbe.fragmentGroup[i] == removeFragment then
                cbe.fragmentGroup[i] = addFragment
            end
        end
        SCENE_MANAGER:AddFragmentGroup(cbe.fragmentGroup)
    else
        RemoveFragment(self, layoutFragment)
        RemoveFragment(self, removeFragment)
        AddFragment(self, addFragment)
        AddFragment(self, layoutFragment)
    end
end

--[[ Button click callback for toggling between backpack and craft bag. ]]
local function OnCraftBagMenuButtonClicked(buttonData, playerDriven)-- Do nothing on menu button clicks when not trading.
    local self = buttonData.menu.craftBagExtendedModule
    if buttonData.menu:IsHidden() then
        return
    end
    if buttonData.descriptor == SI_INVENTORY_MODE_CRAFT_BAG then
        if CRAFT_BAG_FRAGMENT.state == SCENE_FRAGMENT_SHOWN then return end
        util.Debug(self.name..": swapping craft bag fragment in and inventory fragment out")
        SwapFragments(self, INVENTORY_FRAGMENT, CRAFT_BAG_FRAGMENT, self.layoutFragment)
    elseif CRAFT_BAG_FRAGMENT.state == SCENE_FRAGMENT_SHOWN then
        util.Debug(self.name..": swapping inventory fragment in and craft bag fragment out")
        SwapFragments(self, CRAFT_BAG_FRAGMENT, INVENTORY_FRAGMENT, self.layoutFragment)
    end
end

local function OnCraftBagFragmentStateChange(oldState, newState)
    if newState ~= SCENE_FRAGMENT_SHOWN then return end
    
    local self = cbe.currentModule
    if not self then return end
    
    -- Show menu whenever the craft bag fragment is first shown
    if self.menu:IsHidden() then
        util.Debug(self.name..": showing menu 1")
        self.menu:SetHidden(false)
    end

    -- Select items button on the menu if not already selected
    if ZO_MenuBar_GetSelectedDescriptor(self.menu) ~= SI_INVENTORY_MODE_CRAFT_BAG then
        util.Debug(self.name..": selecting craft bag button")
        ZO_MenuBar_SelectDescriptor(self.menu, SI_INVENTORY_MODE_CRAFT_BAG)
    end
end
local function OnInventoryFragmentStateChange(oldState, newState)
    
    if newState ~= SCENE_FRAGMENT_SHOWN then return end
        
    local self = cbe.currentModule
    if not self then return end
    
    -- Show menu whenever the inventory fragment is first shown
    if self.menu:IsHidden() then
        util.Debug(self.name..": showing menu 2")
        self.menu:SetHidden(false)
    end
    
    -- Select items button on the menu if not already selected
    if ZO_MenuBar_GetSelectedDescriptor(self.menu) ~= SI_INVENTORY_MODE_ITEMS then
        util.Debug(self.name..": selecting items button")
        ZO_MenuBar_SelectDescriptor(self.menu, SI_INVENTORY_MODE_ITEMS)
    end
    
    -- If the craft bag fragment is showing, hide it
    if not cbe.fragmentGroup then
        util.Debug(self.name..": removing craft bag fragment 1")
        SCENE_MANAGER:RemoveFragment(CRAFT_BAG_FRAGMENT)
    end
end

function class.Module:Initialize(name, sceneName, window, layoutFragment, hideMenuWhenSceneShown)

    self.name = name or cbe.name .. "Module"
    self.sceneName = sceneName
    self.scene = SCENE_MANAGER.scenes[sceneName]
    
    if not window or not self.scene then return end
    
    self.window = window
    self.layoutFragment = layoutFragment
    
    --[[ Create craft bag menu ]]
    self.menu = CreateControlFromVirtual(self.name.."Menu", self.window, "ZO_LabelButtonBar")
    self.menu.craftBagExtendedModule = self
    
    -- Items button
    util.AddItemsButton(self.menu, OnCraftBagMenuButtonClicked)
    
    -- Craft bag button
    util.AddCraftBagButton(self.menu, OnCraftBagMenuButtonClicked)
    
    -- Hide menu by default
    self.menu:SetHidden(true)
    
    --[[ Handle scene open close events ]]
    self.scene:RegisterCallback("StateChange", 
        function (oldState, newState)
            if newState == SCENE_HIDING then
                INVENTORY_FRAGMENT:UnregisterCallback("StateChange", OnInventoryFragmentStateChange)
                CRAFT_BAG_FRAGMENT:UnregisterCallback("StateChange", OnCraftBagFragmentStateChange)
                cbe.currentModule = nil
                cbe.fragmentGroup = nil
                util.Debug(self.name..": hiding menu")
                self.menu:SetHidden(true)
                
                -- When closing the module scene, undo any in-process retrieve operations from
                -- the craft bag so that they don't attempt to run their callbacks on a closed scene.
                local retrieveQueue = util.transferQueueCache[BAG_BACKPACK] 
                              and util.transferQueueCache[BAG_BACKPACK][BAG_VIRTUAL]
                if retrieveQueue then
                    retrieveQueue:ReturnToCraftBag()
                end
                
            elseif newState == SCENE_SHOWING then
                INVENTORY_FRAGMENT:RegisterCallback("StateChange", OnInventoryFragmentStateChange)
                CRAFT_BAG_FRAGMENT:RegisterCallback("StateChange", OnCraftBagFragmentStateChange)
                cbe.currentModule = self
                local hide
                if type(hideMenuWhenSceneShown) == "function" then
                    hide = hideMenuWhenSceneShown()
                else
                    hide = hideMenuWhenSceneShown
                end
                util.Debug(self.name..": setting menu hidden to "..tostring(hide))
                self.menu:SetHidden(hide)
            end
        end)
end

function class.Module:IsSceneShown()
    return self.scene and self.scene.state == SCENE_SHOWN
end

function class.Module.PreTabButtonClicked(buttonData, playerDriven)
    local self = buttonData.craftBagExtendedModule
    if buttonData.categoryName == self.tabName then
        util.Debug(self.name..": showing menu 3")
        self.menu:SetHidden(false)
    else
        self.menu:SetHidden(true)
        util.Debug(self.name..": removing craft bag fragment 2")
        SCENE_MANAGER:RemoveFragment(CRAFT_BAG_FRAGMENT)
    end
end