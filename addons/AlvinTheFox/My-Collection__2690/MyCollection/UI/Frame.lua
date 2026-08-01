local Saved = MyCollection.Internals.Saved
local Constants = MyCollection.Internals.Constants
local Dependencies = MyCollection.Internals.Dependencies
local Logger = MyCollection.Internals.Dependencies.Logger
local EventManager = MyCollection.Internals.Dependencies.Officials.EventManager
local SceneManager = MyCollection.Internals.Dependencies.Officials.SceneManager
local SlashCommands = MyCollection.Internals.Dependencies.Officials.SlashCommands
local UI = MyCollection.UI
local Controls = MyCollection.UI.Controls

UI.Frame = {}
UI.Frame.__index = UI.Frame

local Frame = UI.Frame

-- UI containers
Frame.Element = nil

-- Sub Elements
Frame.MenuBar = nil
Frame.Grid = nil
Frame.AddSet = nil

-- Properties
Frame.initialized = false
Frame.scene = nil
Frame.sceneName = nil

Frame.modes = {
    grid = 1,
    new = 2,
}

-- Functions
function Frame.ShowSettings()
    Frame.ToggleOpenClose()
	--Dependencies.LibAddonMenu:OpenToPanel(addOnPanel)
end

function Frame.ToggleOpenClose()
    Dependencies.LibMainMenu:Refresh()
    Dependencies.LibMainMenu:SelectMenuItem(MyCollection.Name)
end

function Frame.OnReposition()
    Saved.Settings.Window.Position.Left = Frame.Element:GetLeft()
    Saved.Settings.Window.Position.Top = Frame.Element:GetTop()
end

function Frame.SetPosition()
    local left = Saved.Settings.Window.Position.Left
    local top = Saved.Settings.Window.Position.Top

    Frame.Element:ClearAnchors()
    Frame.Element:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Frame:RefreshUI()
    if (not self.initialized) then return end

    Frame.Grid:RefreshData()
end

function Frame.Initialize()
    if Frame.initialized then return end

    Frame.initialized = true
    Frame.Element = MyCollectionUIFrame
    Frame.sceneName = MyCollection.Name .. "Scene"

    Frame.scene = ZO_Scene:New(Frame.sceneName, SceneManager)
	Frame.scene:AddFragment(ZO_SetTitleFragment:New(MYCOLLECTION_TITLE))
	Frame.scene:AddFragment(ZO_FadeSceneFragment:New(Frame.Element))
	Frame.scene:AddFragment(TITLE_FRAGMENT)
	Frame.scene:AddFragment(RIGHT_BG_FRAGMENT)
	Frame.scene:AddFragment(FRAME_EMOTE_FRAGMENT_MAP)
	Frame.scene:AddFragment(CODEX_WINDOW_SOUNDS)
    Frame.scene:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
	Frame.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    --Frame.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED)
    Frame.scene:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    
    Frame.Grid = Controls.Grid:New(Frame.Element:GetNamedChild("Grid"))
    Frame.AddSet = Controls.AddSet.New(Frame.Element:GetNamedChild("AddSet"))
    Frame.MenuBar = Controls.MenuBar.New(Frame.Element:GetNamedChild("MenuBar"))
    Frame.MenuBar:DefaultPage()

	Dependencies.LibMainMenu:Init()

	-- Add to main menu
	local categoryLayoutInfo = {
		binding = "MYCOLLECTION_MENU_TOGGLE",
		categoryName = MYCOLLECTION_NAME,
		callback = function(buttonData)
			if not SceneManager:IsShowing(Frame.sceneName) then
                SceneManager:Show(Frame.sceneName)
                Frame:RefreshUI()
			else
				SceneManager:ShowBaseScene()
			end
		end,
		visible = function(buttonData)
			return true
        end,

		normal = "esoui/art/collections/collections_tabicon_outfitstyles_up.dds",
		pressed = "esoui/art/collections/collections_tabicon_outfitstyles_down.dds",
		highlight = "esoui/art/collections/collections_tabicon_outfitstyles_over.dds",
		disabled = "esoui/art/collections/collections_tabicon_outfitstyles_up.dds"
	}
	Dependencies.LibMainMenu:AddMenuItem(MyCollection.Name, Frame.sceneName, categoryLayoutInfo, nil)

    SlashCommands["/mycollection"] = Frame.ToggleOpenClose

    Frame.InitDialogs()    
end

function Frame.InitDialogs()
    -- Dialogs
    ESO_Dialogs["MyCollection_SetOrderNumber"] = {    
      title = {
          text = "Set Ordering number",
      },
      mainText = {
          text = "Custom ordering number for the tracked set. This is the default ordering value.",
      },
      --updateFn = function (dialog) d("uodate") d(dialog) d(self) end,
      --callback = function (dialog) d("setup") d(dialog) d(self) end,
      editBox = {
          textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
          maxInputCharacters = 4,
          defaultText = 0,
      },
      buttons = {
          [1] = {
              text = "Set",
              visible = true,
              callback = function (dialog) 
                  dialog.data.currentSet:SetOrderNumber(tonumber(ZO_Dialogs_GetEditBoxText(dialog))) 
                  UI.Frame.Grid:RefreshData()
              end,
          },
          [2] = {
              text = "Cancel",
              visible = true,
              callback = function (dialog) end,
          },
      },
    }
  
    
end