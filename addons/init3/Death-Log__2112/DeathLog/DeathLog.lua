DeathLog = DeathLog or {}

--[[
     Current Version Changes: 1.2
          Fixed the issue with raid enemies showing up in the death log.
          The Death Log now correctly loses focus when your mouse cursor leaves the window
          Added a function for debugging to prevent spamming the chatbox with left in debug lines
          Improved scrolling in the death log so it feels less clunky and doesn't scroll downwards when you scroll up too quickly
          Changed the color of the text when you select all of the text in the log
]]

DeathLog.version = "1.2"
DeathLog.variableVersion = 1
DeathLog.author = "init3"
DeathLog.name = "DeathLog"
DeathLog.groupMembers = {}
DeathLog.table = {}
DeathLog.outOfBounds = false
DeathLog.defaults = {
     window_offsetX = 0,
     window_offsetY = 0,
     isWindowOpen = false,
     DeathLog = {},
     isMinimized = false,
     isPinned = false,
     debug = false,
}
SLASH_COMMANDS["/deathlog"] = function() DeathLog.ToggleWindow() end
SLASH_COMMANDS["/printdeaths"] = function() DeathLog.PrintDeaths() end

local function dbg(text)
     if DeathLog.sv.debug then
          d(text)
     end
end

function DeathLog.IndexGroupMembers()
     local groupSize = GetGroupSize()
     if groupSize == 0 then
          DeathLog.groupMembers[GetUnitName("player")] = GetUnitDisplayName("player")
     else
          for i = 1, groupSize do -- For each member in your group
               local memberCharacterName = GetUnitName("group" .. i) -- The member's character name
               local memberDisplayName = GetUnitDisplayName("group" .. i) -- The member's @DisplayName
               DeathLog.groupMembers[memberCharacterName] = memberDisplayName -- Store them in the groupMembers table
          end
     end
end

function DeathLog.OnTrialStart(_, trialName, weekly)
     DeathLog.ResetLog()
     DeathLogWindow:SetHidden(false)
end

local LibUnit = LibStub:GetLibrary("LibUnits")
local function UnitIdToString(unitId)
     local name = LibUnit:GetNameForUnitId(unitId) -- Character name for the specified TargetUnitId
     if name == "" then
          name = "#nil"
     else
          name = zo_strformat("<<1>>", name) -- trims the ^M from the end of the character name
          if DeathLog.groupMembers[name] ~= nil then
               name = DeathLog.groupMembers[name] -- Looks up the @DisplayName for the corresponding Character
          elseif GetUnitName("player") == name then
               name = GetUnitDisplayName("player")
          else
               name = "#nil"
          end
     end
     return name
end

function DeathLog.Scroll()
     DeathLogWindowTextbox:SetHandler("OnMouseWheel", function(self, delta)
          if self:HasFocus() then
               local cursorPos = self:GetCursorPosition()
               local text = self:GetText()
               local textLen = text:len()
               local newPos
               dbg("Delta: " .. delta)
               if delta > 0 then
                    local reverseText = text:reverse()
                    local revCursorPos = textLen - cursorPos
                    local revPos = reverseText:find("\n", revCursorPos+1)
                    newPos = revPos and textLen - revPos
               else
                    newPos = text:find("\n", cursorPos+1)
               end
               if newPos then
                    self:SetCursorPosition(newPos)
               end
          end
     end)
end

function DeathLog.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
     DeathLog.IndexGroupMembers()
     local playerDisplayName = ""
     local killedBy = GetAbilityName(abilityId)

     if GetGroupSize() ~= 0 then
          playerDisplayName = UnitIdToString(targetUnitId) -- If in a group, get the member of the group
     else
          if GetUnitName("player") == zo_strformat("<<1>>", targetName) then -- If it's me
               playerDisplayName = GetUnitDisplayName("player")
          else
               playerDisplayName = "#nil" -- If it's something else
          end
     end
     if playerDisplayName == "#nil" then
          return
     end
     if killedBy == "" then
          killedBy = "Unknown"
     end
     if not DeathLog.table[playerDisplayName] then
          DeathLog.table[playerDisplayName] = {}
          DeathLog.table[playerDisplayName]["total_deaths"] = 1
          DeathLog.table[playerDisplayName]["DeathRecap"] = {}
          DeathLog.table[playerDisplayName]["DeathRecap"][killedBy] = 1
     else
          DeathLog.table[playerDisplayName]["total_deaths"] = DeathLog.table[playerDisplayName]["total_deaths"] + 1
          if DeathLog.table[playerDisplayName]["DeathRecap"][killedBy] then
               DeathLog.table[playerDisplayName]["DeathRecap"][killedBy] = DeathLog.table[playerDisplayName]["DeathRecap"][killedBy] + 1
          else
               DeathLog.table[playerDisplayName]["DeathRecap"][killedBy] = 1
          end
     end
     DeathLog.UpdateDeaths()
end

function DeathLog.UpdateDeaths()
     local log = ""
     for x, y in pairs(DeathLog.table) do
          if DeathLog.table[x]["total_deaths"] == 1 then
               log = log .. x .. ": " .. DeathLog.table[x]["total_deaths"] .. " death \n"
          else
               log = log .. x .. ": " .. DeathLog.table[x]["total_deaths"] .. " deaths \n"
          end
          for key, value in pairs(DeathLog.table[x]["DeathRecap"]) do
               log = log .. "\t\t\t\t\t\t\t" .. key .. ": " .. value .. "\n"
          end
          log = log .. "\n"
     end
     DeathLogWindowTextbox:SetText(log)
     DeathLog.sv["DeathLog"] = DeathLog.table
end

function DeathLog.PrintDeaths()
     local deathString = "Death Log: "
     for x, y in pairs(DeathLog.table) do
          local playerDisplayName = x
          local deaths = DeathLog.table[x]["total_deaths"]
          deathString = deathString .. playerDisplayName .. ": " .. deaths .. " | "
     end
     if deathString == "Death Log: " then
          d("There are no deaths.")
     else
          StartChatInput(deathString:sub(1, -3))
     end
end

function DeathLog.ToggleWindow()
     if not DeathLog.sv["isWindowOpen"] then
          DeathLogWindow:SetAlpha(1)
          DeathLogWindow:SetMouseEnabled(true)
          DeathLogWindow:BringWindowToTop()
          DeathLogWindow:SetHidden(false)
          DeathLog.sv["isWindowOpen"] = true
     else
          DeathLogWindow:SetHidden(true)
          DeathLog.sv["isWindowOpen"] = false
     end
end

function DeathLog.MinimizeWindow()
     DeathLogWindowTextbox:SetHidden(true)
     DeathLogWindowBackdrop:SetHidden(true)
     DeathLogWindowMinimizeButton:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds")
     DeathLogWindowMinimizeButton:SetPressedTexture("EsoUI/Art/Buttons/plus_down.dds")
     DeathLogWindowMinimizeButton:SetMouseOverTexture("EsoUI/Art/Buttons/plus_over.dds")
     DeathLogWindowMinimizeButton:SetDisabledTexture("EsoUI/Art/Buttons/plus_disabled.dds")
     DeathLog.sv["isMinimized"] = true
end

function DeathLog.MaximizeWindow()
     DeathLogWindowTextbox:SetHidden(false)
     DeathLogWindowBackdrop:SetHidden(false)
     DeathLogWindowMinimizeButton:SetNormalTexture("EsoUI/Art/Buttons/minus_up.dds")
     DeathLogWindowMinimizeButton:SetPressedTexture("EsoUI/Art/Buttons/minus_down.dds")
     DeathLogWindowMinimizeButton:SetMouseOverTexture("EsoUI/Art/Buttons/minus_over.dds")
     DeathLogWindowMinimizeButton:SetDisabledTexture("EsoUI/Art/Buttons/minus_disabled.dds")
     DeathLog.sv["isMinimized"] = false
end

function DeathLog.PinWindow()
     DeathLogWindow:SetMovable(false)
     DeathLogWindowPinnedButton:SetNormalTexture("EsoUI/Art/Buttons/pinned_normal.dds")
     DeathLogWindowPinnedButton:SetPressedTexture("EsoUI/Art/Buttons/pinned_down.dds")
     DeathLogWindowPinnedButton:SetMouseOverTexture("EsoUI/Art/Buttons/pinned_over.dds")
     DeathLogWindowPinnedButton:ClearAnchors()
     DeathLogWindowPinnedButton:SetAnchor(TOPLEFT, DeathLogWindow, TOPLEFT, 26, -1)
     DeathLog.sv["isPinned"] = true
end

function DeathLog.UnpinWindow()
     DeathLogWindow:SetMovable(true)
     DeathLogWindowPinnedButton:SetNormalTexture("EsoUI/Art/Buttons/unpinned_normal.dds")
     DeathLogWindowPinnedButton:SetPressedTexture("EsoUI/Art/Buttons/unpinned_down.dds")
     DeathLogWindowPinnedButton:SetMouseOverTexture("EsoUI/Art/Buttons/unpinned_over.dds")
     DeathLogWindowPinnedButton:ClearAnchors()
     DeathLogWindowPinnedButton:SetAnchor(TOPLEFT, DeathLogWindow, TOPLEFT, 26, -4)
     DeathLog.sv["isPinned"] = false
end

function DeathLog.SavePosition()
     DeathLog.sv["window_offsetX"] = DeathLogWindow:GetLeft()
     DeathLog.sv["window_offsetY"] = DeathLogWindow:GetTop()
end

function DeathLog.ResetLog()
     DeathLog.sv.DeathLog = nil
     DeathLog.table = {}
     DeathLogWindowTextbox:SetText("")
end

function DeathLog.ResetAnchors()
     DeathLogWindow:ClearAnchors()
     DeathLogWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DeathLog.sv["window_offsetX"], DeathLog.sv["window_offsetY"])
end

local function OnZoneChanged()
     if IsUnitInDungeon('player') then
          EVENT_MANAGER:RegisterForEvent(DeathLog.name, EVENT_COMBAT_EVENT, DeathLog.OnCombatEvent)
          EVENT_MANAGER:AddFilterForEvent(DeathLog.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
     else
          EVENT_MANAGER:UnregisterForEvent(DeathLog.name, EVENT_COMBAT_EVENT)
     end
end

function DeathLog.Initialize()
     DeathLog.savedVars = ZO_SavedVars:NewCharacterIdSettings("DeathLogVars", DeathLog.variableVersion, nil, DeathLog.defaults) -- Defines saved variables
     DeathLog.sv = DeathLogVars["Default"][GetDisplayName()][GetCurrentCharacterId()]
     DeathLog.ResetAnchors()
     CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnZoneChanged)
     if DeathLog.sv["isWindowOpen"] then
          DeathLogWindow:SetHidden(false)
     end
     if DeathLog.sv["DeathLog"] ~= nil then
          DeathLog.table = DeathLog.sv["DeathLog"]
          DeathLog.UpdateDeaths()
     end
     if DeathLog.sv["isPinned"] then
          DeathLog.PinWindow()
     else
          DeathLog.UnpinWindow()
     end
     if DeathLog.sv["isMinimized"] then
          DeathLog.MinimizeWindow()
     else
          DeathLog.MaximizeWindow()
     end
     DeathLog.Scroll()
     DeathLogWindowTextbox:SetSelectionColor(255, 0, 0, 0.7)
     DeathLog.IndexGroupMembers()
end

function DeathLog.OnAddOnLoaded(event, addonName)
     if DeathLog.name ~= addonName then return end
     DeathLog.Initialize()
     EVENT_MANAGER:UnregisterForEvent(DeathLog.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(DeathLog.name, EVENT_ADD_ON_LOADED, DeathLog.OnAddOnLoaded)
