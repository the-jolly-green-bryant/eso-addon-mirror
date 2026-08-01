-- The MIT License (MIT)
-- Copyright (c) 2015 Eugene Aksenov
-- Copyright (c) 2016-2017 Eugene Aksenov, @Dr_Z (ESO NA Server)
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
-- Create and register addon
-------------------------------------------------------------------------------

MyBuild = {}

MyBuild.name = "MyBuild"

function MyBuild:Chooselanguage()
    local lang = GetCVar("Language.2")
    if lang == "en" then
        self.LANG = MyBuild.EN
    elseif lang == "de" then
        self.LANG = MyBuild.DE
    elseif lang == "fr" then
        self.LANG = MyBuild.FR
    elseif lang == "ru" then
        self.LANG = MyBuild.RU
    end
end

function MyBuild:Initialize()
  --register all necessary events
  EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_PLAYER_ACTIVATED, MyBuild.OnPlayerActivated)
  self.updateEnabled = false
end

function MyBuild:ToggleUpdate()
    if self.updateEnabled then
        self.updateEnabled = true
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_STATS_UPDATED, MyBuild.OnUpdate)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_LEVEL_UPDATE, MyBuild.OnUpdate)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_TITLE_UPDATE, MyBuild.OnUpdate)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_MOUNTS_FULL_UPDATE, MyBuild.OnRefresh)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_MOUNT_UPDATE, MyBuild.OnRefresh)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_EFFECT_CHANGED, MyBuild.OnRefresh)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_EFFECTS_FULL_UPDATE, MyBuild.OnRefresh)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_ATTRIBUTE_UPGRADE_UPDATED, MyBuild.OnRefresh)
        EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_PLAYER_TITLES_UPDATE, MyBuild.OnRefresh)
    else
        self.updateEnabled = false
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_STATS_UPDATED)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_LEVEL_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_TITLE_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_MOUNTS_FULL_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_MOUNT_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_EFFECTS_FULL_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_ATTRIBUTE_UPGRADE_UPDATED)
        EVENT_MANAGER:UnregisterForEvent(MyBuild.name, EVENT_PLAYER_TITLES_UPDATE)
    end
end

function MyBuild.OnAddOnLoaded(_, addonName)
    if addonName == MyBuild.name then
        MyBuild:Initialize()
        MyBuild:Chooselanguage()
        MyBuild.ui = MyBuild.UI.CreateUI()
        MyBuild.ui.mainWindow:SetHidden(true)
    end
end

-- update information on player
function MyBuild.OnUpdate (_, unitTag)
    if unitTag == "player" then
        MyBuild.Char:UpdateInfo()
        MyBuild.UI.UpdateUI()
	self:RefreshFilters()
    end
end

-- refresh information on player
function MyBuild.OnRefresh (_)
    MyBuild.Char:UpdateInfo()
    MyBuild.UI.UpdateUI()
end

-- update info on player first time
function MyBuild.OnPlayerActivated(_)
    MyBuild.Char:UpdateInfo()
    MyBuild.UI.UpdateUI()
end

-- toggle visibility of main window
function MyBuild.ToggleHide()
     MyBuild.Char:UpdateInfo()
     MyBuild.UI.UpdateUI()
     MyBuild:ToggleUpdate()
     MyBuild.ui.mainWindow:ToggleHidden()
end

-- Register addon
EVENT_MANAGER:RegisterForEvent(MyBuild.name, EVENT_ADD_ON_LOADED, MyBuild.OnAddOnLoaded)

-- create command to show/hide information window
SLASH_COMMANDS["/mybuild"] = MyBuild.ToggleHide

-- register menu binding name
ZO_CreateStringId("SI_BINDING_NAME_MYBUILD_SHOWHIDE", "My Build: |cFFFFFFShow/Hide|r")
