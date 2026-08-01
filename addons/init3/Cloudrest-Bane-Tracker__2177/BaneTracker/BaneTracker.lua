BaneTracker = BaneTracker or {}

BaneTracker.name = "BaneTracker"
BaneTracker.author = "init3"
BaneTracker.version = "1.1.1"
BaneTracker.variableVersion = 1
BaneTracker.isInCombat = false
BaneTracker.isInCR = false
BaneTracker.isInExecute = false
BaneTracker.baneId = 107082
BaneTracker.executeId = 106023
BaneTracker.timeRemaining = 0
BaneTracker.displayResolution = {
     width = GuiRoot:GetWidth(),
     height = GuiRoot:GetHeight()
}

BaneTracker.defaults = {
     offsetX = (BaneTracker.displayResolution.width / 2) - 40,
     offsetY = BaneTracker.displayResolution.height / 3,
     fontSize = 48,
     hex = "1f74a8"
}

local function dbg(text)
     if BaneTracker.sv.dbg then
          d("|cff0096BaneTracker:|r " .. text)
     end
end

local function OnZoneChanged()
     local cloudrestZoneId = 1051 --Cloudrest zoneId
     local currentZoneId = GetZoneId(GetCurrentMapZoneIndex())
     local currentZoneName = ZO_CachedStrFormat("<<C:1>>", GetUnitZone("player"))
     if currentZoneId == cloudrestZoneId
             or (currentZoneName == "Cloudrest" -- EN
             or currentZoneName == "Wolkenruh" --DE
             or currentZoneName == "Le Pas-des-Nuées" --FR
             or currentZoneName == "Клаудрест" -- RU
             or currentZoneName == "クラウドレスト" --JP
     )
     then
          BaneTracker.isInCR = true
          if not BaneTracker.isRegistered then
               BaneTracker.RegisterEvents()
               BaneTracker.isRegistered = true
          end
     else
          BaneTracker.isInCR = false
          if BaneTracker.isRegistered then
               BaneTracker.UnregisterEvents()
               BaneTracker.isRegistered = false
          end
     end
end

local function SetTimer(value) BaneTracker.timeRemaining = value end

local function UpdateTimer()
     if BaneTracker.isInCombat then
          if BaneTracker.isInExecute then
               if BaneTrackerWindow:IsHidden() then
                    BaneTrackerWindow:SetHidden(false)
               end
          else
               return
          end
          BaneTracker.timeRemaining = BaneTracker.timeRemaining - 1
          if BaneTracker.timeRemaining > 0 then
               if BaneTracker.timeRemaining > 5 then
                    BaneTrackerWindowLabel:SetText("|c" .. BaneTracker.sv.hex .. "BANE: " .. BaneTracker.timeRemaining .. "|r")
               else
                    BaneTrackerWindowLabel:SetText("|c" .. BaneTracker.sv.hex .. "BANE:|r |cc41f1f" .. BaneTracker.timeRemaining .. "|r")
               end
          else
               BaneTrackerWindowLabel:SetText("|c" .. BaneTracker.sv.hex .. "BANE:|r |cc41f1fSOON|r")
          end
     end
end

function BaneTracker.CombatState(event, isInCombat)
     if BaneTracker.isInCombat ~= isInCombat then
          BaneTracker.isInCombat = isInCombat
     end

     if not BaneTracker.isInCombat then
          BaneTracker.isInExecute = false
          BaneTrackerWindow:SetHidden(true)
     end
end

function BaneTracker.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
     if result == ACTION_RESULT_EFFECT_GAINED then
          if abilityId == BaneTracker.executeId then
               BaneTracker.isInExecute = true
--d("[BaneTracker]Execute Buff gefunden")
               dbg("Entering Execute Phase")
          elseif abilityId == BaneTracker.baneId then
--d("[BaneTracker]Heal Debuff gefunden - Setze Timer 18 Sekunden")
               SetTimer(18)
               dbg("abilityName: " .. abilityName)
               dbg("result: " .. result)
          end
     end
end

function BaneTracker.RegisterEvents()
     local EM = EVENT_MANAGER

     if BaneTracker.isInCR then
--d("[BaneTracker]In CloudRest!")
          local function RegisterForAbility(abilityId)
               EM:RegisterForEvent(BaneTracker.name .. "_id_" .. abilityId, EVENT_COMBAT_EVENT, BaneTracker.OnCombatEvent)
--d("[BaneTracker]Registriere Überprüfungen für CloudRest - Kampf, abilityId: " ..tostring(GetAbilityName(abilityId)))
               dbg("Registering " .. GetAbilityName(abilityId))
               EM:AddFilterForEvent(BaneTracker.name .. "_id_" .. abilityId, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
          end

          RegisterForAbility(BaneTracker.baneId)
          RegisterForAbility(BaneTracker.executeId)
          EM:RegisterForEvent(BaneTracker.name, EVENT_PLAYER_COMBAT_STATE, BaneTracker.CombatState)
          EM:RegisterForUpdate(BaneTracker.name, 1000, UpdateTimer)
     end
end

function BaneTracker.UnregisterEvents()
     local EM = EVENT_MANAGER

     if not BaneTracker.isInCR then
--d("[BaneTracker]Nicht in CloudRest! - Prüfungen werden ausgeschaltet")
          EM:UnregisterForEvent(BaneTracker.name .. "_id_" .. BaneTracker.baneId, EVENT_COMBAT_EVENT)
          EM:UnregisterForEvent(BaneTracker.name .. "_id_" .. BaneTracker.executeId, EVENT_COMBAT_EVENT)
          EM:UnregisterForEvent(BaneTracker.name, EVENT_PLAYER_COMBAT_STATE)
          EM:UnregisterForUpdate(BaneTracker.name)
     end
end

function BaneTracker.ToggleMovable()
     BaneTracker.isMovable = not BaneTracker.isMovable
     if BaneTracker.isMovable then
          BaneTrackerWindowLabel:SetText("|c" .. BaneTracker.sv.hex .. "BANE: 0|r")
          BaneTrackerWindow:SetHidden(false)
          BaneTrackerWindow:SetMovable(true)
     else
          if not BaneTracker.isInExecute then BaneTrackerWindow:SetHidden(true) end
          BaneTrackerWindow:SetMovable(false)
     end
end

function BaneTracker.SetFontSize(label, size)
     local path = "EsoUI/Common/Fonts/univers67.otf"
     local outline = "soft-shadow-thick"
     label:SetFont(path .. "|" .. size .. "|" .. outline)
end

function BaneTracker.ResetAnchors()
     BaneTrackerWindow:ClearAnchors()
     BaneTrackerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BaneTracker.sv.offsetX, BaneTracker.sv.offsetY)
end

function BaneTracker.SavePosition()
     BaneTracker.sv.offsetX = BaneTrackerWindow:GetLeft()
     BaneTracker.sv.offsetY = BaneTrackerWindow:GetTop()
end

function BaneTracker.Initialize()
     BaneTracker.savedVars = ZO_SavedVars:NewCharacterIdSettings("BaneTrackerVars", BaneTracker.variableVersion, nil, BaneTracker.defaults)
     BaneTracker.sv = BaneTrackerVars["Default"][GetDisplayName()][GetCurrentCharacterId()]
     BaneTracker.ResetAnchors()
     BaneTracker.SetFontSize(BaneTrackerWindowLabel, BaneTracker.sv.fontSize)
     SLASH_COMMANDS["/btmove"] = function() BaneTracker.ToggleMovable() end
     SLASH_COMMANDS["/bttest"] = function() SetTimer(22) end
end

function BaneTracker.OnAddOnLoaded(event, addonName)
     if BaneTracker.name ~= addonName then return end
     CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnZoneChanged)
     BaneTracker.Initialize()
     EVENT_MANAGER:UnregisterForEvent(BaneTracker.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(BaneTracker.name, EVENT_ADD_ON_LOADED, BaneTracker.OnAddOnLoaded)
