local Saved = MyCollection.Internals.Saved
local Logger = MyCollection.Internals.Dependencies.Logger
local EventManager = MyCollection.Internals.Dependencies.Officials.EventManager
local UI = MyCollection.UI
local Controls = MyCollection.UI.Controls

Controls.MenuBar = {}
Controls.MenuBar.__index = Controls.MenuBar

local MenuBar = Controls.MenuBar

-- Constructor
function MenuBar.New(element)
    local instance = {}
    setmetatable(instance, MenuBar)

    instance:Initialize(element)
    return instance
end

-- UI containers
MenuBar.Element = nil

-- Sub Elements
MenuBar.Label = nil

-- Properties

-- Functions

function MenuBar:DefaultPage()
    ZO_MenuBar_SelectDescriptor(self.Element, UI.Frame.modes.grid, true)
    UI.Frame:RefreshUI()
end

function MenuBar:Initialize(element)
    self.Element = element

    ZO_MenuBar_AddButton(self.Element, {
		descriptor = UI.Frame.modes.grid,
		categoryName = MYCOLLECTION_MENU_GRID,
		normal = "EsoUI/Art/Guild/tabIcon_roster_up.dds",
		pressed = "EsoUI/Art/Guild/tabIcon_roster_down.dds",
		highlight = "EsoUI/Art/Guild/tabIcon_roster_over.dds",
		callback = MenuBar.HandleMenuSwitch,
	})
	
    ZO_MenuBar_AddButton(self.Element, {
		descriptor = UI.Frame.modes.new,
		categoryName = MYCOLLECTION_MENU_ADD,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_down.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_over.dds",
		callback = MenuBar.HandleMenuSwitch,
    })
end

function MenuBar.HandleMenuSwitch(button)    
    local label = ""
    if button.descriptor ~= UI.Frame.modes.new then
        label = "List"
    else
        label = "Add set"
    end
    UI.Frame.MenuBar.Element:GetNamedChild("Label"):SetText(label)
    UI.Frame.Grid.Element:SetHidden(button.descriptor ~= UI.Frame.modes.grid)
    UI.Frame.AddSet.Element:SetHidden(button.descriptor ~= UI.Frame.modes.new)
end