-- The MIT License (MIT)
-- Copyright (c) 2015 Eugene Aksenov
-- Copyright (c) 2016 Eugene Aksenov, @Dr_Z (ESO NA Server)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-------------------------------------------------------------------------------
-- Main user interface
-------------------------------------------------------------------------------

MyBuild.UI = {}

local WM = WINDOW_MANAGER

-- update all character information in window
function MyBuild.UI.UpdateUI()
    MyBuild.CharacterView:UpdateCharacterInfo(MyBuild.Char)
    MyBuild.AttributeView:UpdateCharacterInfo(MyBuild.Char)
    MyBuild.EquipmentView:UpdateCharacterInfo(MyBuild.Char)
    MyBuild.ChampionView:UpdateCharacterInfo(MyBuild.Char)
	
-- added by tenderlunar_yp 
	MyBuild.SkillView:UpdateCharacterInfo()
-- added by tenderlunar_yp 
end

function MyBuild.UI.CreateUI()
    local ui = {}
    ui.mainWindow = MyBuild.UI.MainWindow(760, 800)

    MyBuild.AttributeView:Create(ui.mainWindow)
    MyBuild.EquipmentView:Create(ui.mainWindow)
    MyBuild.ChampionView:Create(ui.mainWindow)
    MyBuild.CharacterView:Create(ui.mainWindow)
	
-- added by tenderlunar_yp 
	MyBuild.SkillView:Create(ui.mainWindow)
-- added by tenderlunar_yp 

    MyBuild.UI.ToggleHidden = function ()
        ui.mainWindow:ToggleHidden()
    end
    return ui
end


local function ShowTooltipRB(self)
   InitializeTooltip(InformationTooltip, self, TOPRIGHT, 30, -95, BOTTOMRIGHT)
   SetTooltipText(InformationTooltip, "Refresh Stats")
end
 
local function ShowTooltipCL(self)
   InitializeTooltip(InformationTooltip, self, TOPRIGHT, 55, -75, BOTTOMRIGHT)
   SetTooltipText(InformationTooltip, "Close MyBuild")
end

local function HideTooltip(self)
   ClearTooltip(InformationTooltip)
end

function MyBuild.UI.MainWindow(width, height)
  local mainWindow = WM:CreateTopLevelWindow("MyBuild_MainWindow")
  mainWindow:SetDimensions(width, height)
  mainWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  mainWindow:SetHidden(false)
  mainWindow:SetMovable(true)
  mainWindow:SetMouseEnabled(true)
  mainWindow:SetClampedToScreen(true)

  WM:CreateControlFromVirtual("MainWindowbackdrop", mainWindow, "ZO_DefaultBackdrop")

  -- Close / Hide Button
  local closeButton = WM:CreateControl("MyBuild_closeButton", mainWindow, CT_BUTTON)
  closeButton:SetAnchor(TOPRIGHT, mainWindow, TOPRIGHT, -5, 5)
  closeButton:SetDimensions(24, 24)
  closeButton:SetNormalTexture("/esoui/art/buttons/clearslot_disabled.dds")
  closeButton:SetMouseOverTexture("/esoui/art/buttons/clearslot_up.dds")
  closeButton:SetPressedTexture("/esoui/art/buttons/clearslot_down.dds")
  closeButton:SetHidden(false)
  closeButton:SetHandler("OnMouseEnter", function(self) ShowTooltipCL(self) end)
  closeButton:SetHandler("OnMouseExit", function(self) HideTooltip(self) end)
  closeButton:SetHandler("OnClicked", function() mainWindow:SetHidden(true) MyBuild.Char:UpdateInfo() MyBuild.UI.UpdateUI() end)

  -- Refresh Stats Button
  local refreshButton = WM:CreateControl("MyBuild_refreshButton", mainWindow, CT_BUTTON)
  refreshButton:SetAnchor(TOPRIGHT, mainWindow, TOPRIGHT, -40, -15)
  refreshButton:SetDimensions(64, 64)
  refreshButton:SetNormalTexture("/esoui/art/hud/radialicon_trade_up.dds")
  refreshButton:SetMouseOverTexture("/esoui/art/hud/radialicon_trade_over.dds")
  refreshButton:SetPressedTexture("/esoui/art/hud/radialicon_trade_disabled.dds")
  refreshButton:SetHidden(false)
  refreshButton:SetHandler("OnMouseEnter", function(self) ShowTooltipRB(self) end)
  refreshButton:SetHandler("OnMouseExit", function(self) HideTooltip(self) end)
  refreshButton:SetHandler("OnClicked", function() mainWindow:SetHidden(false) MyBuild.Char:UpdateInfo() MyBuild.UI.UpdateUI() end)

  return mainWindow
end
