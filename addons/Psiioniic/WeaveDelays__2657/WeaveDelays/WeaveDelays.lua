WeaveDelays = WeaveDelays or { }
local WeaveDelays = WeaveDelays
local self = WeaveDelays

local DELAY_CLAMP_MAX_MS         = 950
local DELAY_CLAMP_MIN_MS         = 1
local DELAY_MISSED_SENTINEL_MS   = 1000
local RECENT_ACTION_THRESHOLD_MS = 100
local HIDE_AFTER_COMBAT_GRACE_MS = 50
local RELOAD_NOTICE_THROTTLE_MS  = 5000

local FONT_FACE  = "EsoUI/Common/Fonts/Univers57.slug"
local FONT_STYLE = "soft-shadow-thick"

local prefix = "WEAVEDELAYSBAR"

self.name             = 'WeaveDelays'
self.slash            = "/weavedelays"
self.DefaultSavedVars = {
	["accountWide"]=false,
	["delayBarOffsetX"]=300,
	["delayBarOffsetY"]=400,
	["delayBarAlpha"]=0.9,
	["numDelayBarSlots"]=10,
	["numDelayBarRows"]=1,
	["showDelayBar"]=true,
	["showSkillsInDelayBar"]=true,
	["showAverageDelay"]=true,
	["showDelayBarOnlyInCombat"]=true,
	["showDelayBarOnlyInHomes"]=false,
	["showDelayBarAfterCombat"]=10,
	["unlockUI"]=false,
	["delayBarPalette"]="greenred",
	["delayBarFrameR"]=0.8,
	["delayBarFrameG"]=0.8,
	["delayBarFrameB"]=0.8,
	["delayBarFrameA"]=1.0,
	["delayBarFrameThickness"]=1,
	["scale"]=50.0,
	["textLightAttackMissed"]="M",
	["textLightAttackDisappeared"]="X",
	["textLightAttackQueued"]="Q",
	["textBashed"]="B",
	["highLatencyMode"]=false,
	["confirmSkillCasts"]=false,
}
self.playerName          = GetRawUnitName("player")
self.visible             = false

-- combat
self.inCombat      = false
self.combatCounter = 0

-- UI
self.barMarkerScale       = 450
self.delayBarSlotControls = {}

-- constants
self.abilityIdBash = 21970

self.abilityIdCrystalFragments = 114716
self.abilityIdAssassinsWill    = 61930

-- fixes
self.textureCache = {}
self.textureCache[self.abilityIdCrystalFragments] = "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds"
self.textureCache[self.abilityIdAssassinsWill]    = "/esoui/art/icons/ability_rogue_058.dds"

self.palettes = {
	["delay"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,   90.0, 1.0, 1.0},
		[4] = {100,  60.0, 1.0, 1.0},
		[5] = {150,  33.0, 1.0, 1.0},
		[6] = {200,  18.0, 1.0, 1.0},
		[7] = {400,  10.0, 1.0, 1.0},
		[8] = {9999,  0.0, 0.0, 0.0}
	},
	["greenred"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,   90.0, 1.0, 1.0},
		[4] = {100,  60.0, 1.0, 1.0},
		[5] = {150,  33.0, 1.0, 1.0},
		[6] = {200,  18.0, 1.0, 1.0},
		[7] = {400,  10.0, 1.0, 1.0},
		[8] = {9999,  1.0, 1.0, 1.0},
	},
	["greenred2"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  120.0, 1.0, 1.0},
		[4] = {100,  90.0, 1.0, 1.0},
		[5] = {150,  60.0, 1.0, 1.0},
		[6] = {200,  30.0, 1.0, 1.0},
		[7] = {400,  20.0, 1.0, 1.0},
		[8] = {9999,  0.0, 1.0, 1.0}
	},
	["greenredpink"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  90.0, 1.0, 1.0},
		[4] = {100,  60.0, 1.0, 1.0},
		[5] = {150,  33.0, 1.0, 1.0},
		[6] = {200,  18.0, 1.0, 1.0},
		[7] = {400,  10.0, 1.0, 1.0},
		[8] = {950,  1.0, 1.0, 1.0},
		[9] = {1000,  300.0, 1.0, 1.0},
		[10] = {9999,  310.0, 1.0, 1.0}
	},
	["rainbow"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  120.0, 1.0, 1.0},
		[4] = {100,  90.0, 1.0, 1.0},
		[5] = {150,  60.0, 1.0, 1.0},
		[6] = {200,  30.0, 1.0, 1.0},
		[7] = {250,  0.0, 1.0, 1.0},
		[8] = {300,  330.0, 1.0, 1.0},
		[9] = {400,  270.0, 1.0, 1.0},
		[10] = {950,  240.0, 1.0, 1.0},
		[11] = {1000,  300.0, 1.0, 1.0},
		[12] = {9999,  320.0, 1.0, 1.0},
	},
	["purplegreenyellow"] = {
		[1] = {-9999, 265.0, 0.63, 0.14},
		[2] = {0,    263.0, 0.79, 0.25},
		[3] = {50,  235.0, 0.61, 0.41},
		[4] = {100,  198.0, 0.63, 0.45},
		[5] = {150,  172.0, 0.68, 0.44},
		[6] = {200,  139.0, 0.68, 0.72},
		[7] = {250,  67.0 , 0.75, 0.77},
		[8] = {450,  49.0, 0.97, 1.0},
		[9] = {950,  40.0, 1.0, 1.0},
		[10] = {1000,  10.0, 1.0, 1.0},
		[11] = {9999,  0.0, 1.0, 1.0},
	},
	["cividis"] = {
		[1]  = {-500, 213.4, 1.00, 0.30},
		[2]  = {0,    220.0, 0.70, 0.43},
		[3]  = {50,   223.8, 0.30, 0.42},
		[4]  = {100,  223.5, 0.30, 0.45},
		[5]  = {115,  218.1, 0.30, 0.46},
		[6]  = {135,  47.6,  0.30, 0.51},
		[7]  = {150,  47.5,  0.30, 0.56},
		[8]  = {200,  48.8,  0.37, 0.70},
		[9]  = {400,  50.5,  0.58, 0.85},
		[10] = {9999, 53.3,  0.78, 1.00},
	},
	["okabeito"] = {
		[1] = {-500, 201.6, 1.00, 0.70},
		[2] = {0,    201.6, 0.63, 0.91},
		[3] = {50,   163.7, 1.00, 0.62},
		[4] = {100,  55.9,  0.73, 0.94},
		[5] = {150,  41.5,  1.00, 0.90},
		[6] = {200,  26.5,  1.00, 0.84},
		[7] = {400,  326.7, 0.41, 0.80},
		[8] = {500,  0.0,   0.00, 0.00},
		[9] = {9999, 0.0,   0.00, 0.00},
	},
	["viridis"] = {
		[1]  = {-500, 288.5, 0.99, 0.33},
		[2]  = {0,    256.0, 0.61, 0.50},
		[3]  = {50,   214.0, 0.62, 0.55},
		[4]  = {100,  189.0, 0.73, 0.56},
		[5]  = {150,  167.9, 0.81, 0.63},
		[6]  = {200,  137.8, 0.62, 0.76},
		[7]  = {400,  81.7,  0.74, 0.85},
		[8]  = {450,  67.75, 0.80, 0.92},
		[9]  = {500,  53.8,  0.86, 0.99},
		[10] = {9999, 53.8,  0.86, 0.99},
	},
	["strict"] = {
		[1] = {-500, 201.6, 1.00, 0.9},
		[2] = {0,    201.6, 1.00, 0.91},
		[3] = {50,   163.7, 1.00, 0.62},
		[4] = {80,   55.9,  1.00, 0.94},
		[5] = {120,  41.5,  1.00, 0.90},
		[6] = {150,  26.5,  1.00, 0.84},
		[7] = {250,  326.7, 0.5, 0.80},
		[8] = {500,  0.0,   0.00, 0.00},
		[9] = {9999, 0.0,   0.00, 0.00},
	},
}

function WeaveDelays.Reset()
	self.log.reset()
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 UI
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.ToggleWindow()
	self.visible = not self.visible
	if self.visible then
		self.ShowDelayBar()
	else
		self.HideDelayBar()
	end
end

function WeaveDelays.ShowDelayBar()
	self.visible = true
	self.UpdateDelayBarVisibility()
end

function WeaveDelays.HideDelayBar()
	self.visible = false
	self.UpdateDelayBarVisibility()
end

function WeaveDelays.HideDelayBarIfNotInCombat(counter)
	if self.savedVariables.showDelayBarOnlyInCombat then
		if not self.inCombat and counter >= self.combatCounter then
			self.visible = false
			self.UpdateDelayBarVisibility()
		end
	end
end

function WeaveDelays.UpdateDelayBarVisibility()
	if IsScryingInProgress() or IsDiggingGameActive() then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(true)
		end
		return
	end
	if self.savedVariables.showDelayBarOnlyInHomes and GetCurrentZoneHouseId() == 0 then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(true)
		end
		return
	end
	local reticleHidden = IsReticleHidden()
	if reticleHidden and not self.savedVariables.unlockUI then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(true)
		end
	elseif reticleHidden and self.savedVariables.unlockUI and not self.visible then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(true)
		end
	elseif not reticleHidden then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(not self.visible)
		end
	end
end

function WeaveDelaysSaveDelayBarPosition()
	self.savedVariables.delayBarOffsetX = math.floor(WEAVEDELAYSBAR:GetLeft() + 0.5)
	self.savedVariables.delayBarOffsetY = math.floor(WEAVEDELAYSBAR:GetTop() + 0.5)
	if LibHarvensAddonSettings ~= nil then
		LibHarvensAddonSettings:RefreshAddonSettings()
	end
end

function WeaveDelays.restoreDelayBarPosition()
	WEAVEDELAYSBAR:ClearAnchors()
	WEAVEDELAYSBAR:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVariables.delayBarOffsetX, self.savedVariables.delayBarOffsetY)
end

function WeaveDelays.SetDelayBarOffsetX(value)
	self.savedVariables.delayBarOffsetX = tonumber(value)
	self.restoreDelayBarPosition()
end

function WeaveDelays.SetDelayBarOffsetY(value)
	self.savedVariables.delayBarOffsetY = tonumber(value)
	self.restoreDelayBarPosition()
end

function WeaveDelays.OnReticleHiddenUpdate()
	WeaveDelays.UpdateDelayBarVisibility()
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 helper functions
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.SetColor(c, delay, n, palette)
	if palette == nil then
		palette = "greenred"
	end
	if c ~= nil then
		if n > 0 then
			local h,s,v = self.GetPaletteColor(self.palettes[palette], delay)
			local r,g,b = HSVToRGB(h,s,v)
			c:SetColor(r, g, b, 1.0)
		elseif delay == -1 then
			c:SetColor(0.8,0.8,0.8,0.4)
		else
			c:SetColor(1.0,1.0,1.0,0.2)
		end
	end
end

function WeaveDelays.GetPaletteColor(p, v)
	local nPoints = #p
	for i=1,nPoints-1 do
		if v > p[i][1] and v <= p[i+1][1] then
			local r = (v-p[i][1])/(p[i+1][1]-p[i][1])
			local deltaH = (p[i+1][2] - p[i][2] + 180.0) % 360.0 - 180.0
			local h = (p[i][2] + r*deltaH) % 360.0
			return h,p[i][3]+r*(p[i+1][3]-p[i][3]),p[i][4]+r*(p[i+1][4]-p[i][4])
		end
	end
	return 0,0,0
end

function HSVToRGB(h,s,v)
	if s == 0 then
		return v, v, v
	end
	local c = math.floor( h / 60 );
	local d = ( h / 60 ) - c;
	local p = v * ( 1 - s );
	local q = v * ( 1 - s * d );
	local t = v * ( 1 - s * ( 1 - d ) );
	if c == 0 then
		return v, t, p
	elseif c == 1 then
		return q, v, p
	elseif c == 2 then
		return p, v, t
	elseif c == 3 then
		return p, q, v
	elseif c == 4 then
		return t, p, v
	elseif c == 5 then
		return v, p, q
	end
end

function WeaveDelays.ClipRange(s, s_min, s_max)
	return math.max(math.min(s, s_max), s_min)
end

function WeaveDelays.getPalettesList()
	local palettes = {}
	for name, _ in pairs(self.palettes) do
		table.insert(palettes, name)
	end
	table.sort(palettes)
	return palettes
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 draw UI
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.Update()
	self.UpdateDelayBar()
end

function WeaveDelays.UpdateDelayBar()

	if not self.savedVariables.showDelayBar then
		return
	end

	local sv        = self.savedVariables
	local n         = sv.numDelayBarSlots * sv.numDelayBarRows
	local combos    = self.log.getCombos()
	local numCombos = #combos
	local gameTime  = GetGameTimeMilliseconds()

	for i = 1, n do
		local slotControls  = self.delayBarSlotControls[i]
		local barBox        = slotControls ~= nil and slotControls.box or nil
		local barMarker     = slotControls ~= nil and slotControls.marker or nil
		local barPicture    = slotControls ~= nil and slotControls.picture or nil
		local barStatusFlag = slotControls ~= nil and slotControls.statusFlag or nil

		if barBox ~= nil then
			-- rightmost slot (i == n) shows the newest combo
			local combo = combos[numCombos - n + i]
			if combo ~= nil then
				local la                = combo.la
				local lightAttackMissed = la == nil or not la.confirmed
				local settled           = gameTime - combo.skill.time > RECENT_ACTION_THRESHOLD_MS
				local t                 = combo.delay

				local flagText = ""
				if settled then
					if not lightAttackMissed then
						if combo.skill.bashed then
							flagText = sv.textBashed
						end
					elseif la == nil then
						flagText = sv.textLightAttackMissed
					elseif la.queued then
						flagText = sv.textLightAttackQueued
					else
						flagText = sv.textLightAttackDisappeared
					end
				end
				barStatusFlag:SetText(flagText)

				barMarker:SetColor(1.0, 1.0, 1.0, lightAttackMissed and 0.0 or 1.0)
				t = lightAttackMissed and DELAY_MISSED_SENTINEL_MS or self.ClipRange(t, DELAY_CLAMP_MIN_MS, DELAY_CLAMP_MAX_MS)

				if settled then
					self.SetColor(barBox, t, 1, sv.delayBarPalette)
				else
					barBox:SetColor(1.0,1.0,1.0,0.1)
				end

				barMarker:SetAnchor(TOPLEFT, barBox, TOPLEFT, math.ceil(math.min(t,self.barMarkerScale) * sv.scale * 0.002), -math.ceil(0.08*sv.scale))

				if sv.showSkillsInDelayBar and barPicture ~= nil then
					barPicture:SetColor(1.0,1.0,1.0,1.0)
					barPicture:SetTexture(self.GetTextureFromAbilityId(combo.skill.boundId))
				end
			else
				barMarker:SetColor(1.0,1.0,1.0,0.2)
				barBox:SetColor(1.0,1.0,1.0,0.2)
				if sv.showSkillsInDelayBar and barPicture ~= nil then
					barPicture:SetTexture(nil)
					barPicture:SetColor(1.0,1.0,1.0,0.1)
				end
				barStatusFlag:SetText("")
			end
		end
	end

	if self.averageDelayLabel ~= nil then
		local avgDelayMs = self.log.getAverageDelay()
		if avgDelayMs ~= nil and sv.showAverageDelay then
			self.averageDelayLabel:SetText(string.format("%.2f", avgDelayMs * 0.001))
		else
			self.averageDelayLabel:SetText("")
		end
	end
end

function WeaveDelays.ColorTest()

	self.ShowDelayBar()

	local n           = self.savedVariables.numDelayBarSlots * self.savedVariables.numDelayBarRows
	local minT, maxT  = -50, 450
	local step        = (n > 1) and (maxT - minT) / (n - 1) or 0
	local abilityIds  = self.GetTestAbilityIds()

	for i = 1, n do
		local slotControls = self.delayBarSlotControls[i]
		if slotControls ~= nil then
			local barBox        = slotControls.box
			local barMarker     = slotControls.marker
			local barPicture    = slotControls.picture
			local barStatusFlag = slotControls.statusFlag

			local t = minT + (i - 1) * step

			barMarker:SetColor(1.0, 1.0, 1.0, 1.0)
			self.SetColor(barBox, t, 1, self.savedVariables.delayBarPalette)

			local markerT = self.ClipRange(t, DELAY_CLAMP_MIN_MS, DELAY_CLAMP_MAX_MS)
			barMarker:SetAnchor(TOPLEFT, barBox, TOPLEFT, math.ceil(math.min(markerT,self.barMarkerScale) * self.savedVariables.scale * 0.002), -math.ceil(0.08*self.savedVariables.scale))

			if self.savedVariables.showSkillsInDelayBar and barPicture ~= nil then
				local abilityId = abilityIds[math.random(#abilityIds)]
				barPicture:SetColor(1.0,1.0,1.0,1.0)
				barPicture:SetTexture(self.GetTextureFromAbilityId(abilityId))
			end

			barStatusFlag:SetText(tostring(math.floor(t+0.5)))
		end
	end
end

function WeaveDelays.GetTestAbilityIds()
	local ids = {}
	for slotId = 3, 8 do
		local boundId = GetSlotBoundId(slotId)
		if boundId ~= nil and boundId ~= 0 then
			table.insert(ids, boundId)
		end
	end
	if #ids == 0 then
		ids = {self.abilityIdCrystalFragments, self.abilityIdAssassinsWill}
	end
	return ids
end

function WeaveDelays.GetTextureFromAbilityId(abilityId)
	if abilityId == nil then
		return nil
	end

    if IsCraftedAbilityScribed(abilityId) then
        abilityId = GetAbilityIdForCraftedAbilityId(abilityId)
    end

    if self.textureCache[abilityId] ~= nil then
        return self.textureCache[abilityId]
    else
        local texture = GetAbilityIcon(abilityId)
        self.textureCache[abilityId] = texture
        return texture
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 combat events
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.OnCombatEvent(eventCode,  result, isError,  abilityName,  abilityGraphic,  abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,  powerType,  damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	if not self.inCombat then return end
	if abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK and sourceName == self.playerName then
		if result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL then
			self.log.confirmLightAttack()
			self.Update()
		elseif result == ACTION_RESULT_QUEUED then
			self.log.flagLightAttackQueued()
		end
	end
	if abilityActionSlotType == ACTION_SLOT_TYPE_BLOCK and abilityId == self.abilityIdBash and (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE) and sourceName == self.playerName then
		self.log.confirmBash()
		self.Update()
	end
	if sourceName == self.playerName and self.log.resolvePendingSkill(abilityId, isError) then
		self.Update()
	end
end

function WeaveDelays.playerActionSlotAbilityUsed(e, slotId)
	self.log.slotUsed(slotId)
	if self.inCombat then
		self.Update()
	end
end

function WeaveDelays.OnWeaponSwap(_, activeWeaponPair, locked)
	if self.inCombat then
		self.UpdateDelayBar()
	end
end

function WeaveDelays.OnPlayerCombatState(event, inCombat)
	if inCombat and not self.inCombat then
		self.inCombat = inCombat
		self.enterCombat()
	elseif not inCombat and self.inCombat then
		self.Update()
		self.inCombat = inCombat
		self.leaveCombat()
	end
end

function WeaveDelays.enterCombat()
	self.log.startCombat()
	self.Update()
	if self.savedVariables.showDelayBarOnlyInCombat then
		WeaveDelays.ShowDelayBar()
	end
end

function WeaveDelays.leaveCombat()
	self.log.endCombat()

	if self.savedVariables.showDelayBarOnlyInCombat then
		self.combatCounter = self.combatCounter + 1
		local counter = self.combatCounter
		if self.visible then
			zo_callLater(function () WeaveDelays.HideDelayBarIfNotInCombat(counter) end, HIDE_AFTER_COMBAT_GRACE_MS + self.savedVariables.showDelayBarAfterCombat*1000)
		end
	end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 init
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays:LoadSavedVariables()
	self.characterSavedVariables = ZO_SavedVars:NewCharacterNameSettings("WeaveDelaysVars", 1, nil, self.DefaultSavedVars)
	if self.characterSavedVariables.accountWide then
		self.accountWideSavedVariables = ZO_SavedVars:NewAccountWide("WeaveDelaysVars", 1, nil, self.DefaultSavedVars)
		self.savedVariables = self.accountWideSavedVariables
		self.savedVariables.accountWide = true
	else
		self.savedVariables = self.characterSavedVariables
	end
end

function WeaveDelays:Initialize()
	WeaveDelays:LoadSavedVariables()

	if self.savedVariables.numDelayBarSlots == nil or self.savedVariables.numDelayBarSlots < 1 then
		self.savedVariables.numDelayBarSlots = 1
	end
	self.log = WeaveDelayLog.new()
	self.log.reset()
	self.log.SetMaxCombos(self.savedVariables.numDelayBarSlots * self.savedVariables.numDelayBarRows)

	-- Events
	EVENT_MANAGER:RegisterForEvent(self.name.."playerActionSlotAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED, self.playerActionSlotAbilityUsed)
	EVENT_MANAGER:RegisterForEvent(self.name.."WeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, self.OnWeaponSwap)
	EVENT_MANAGER:RegisterForEvent(self.name.."PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:RegisterForEvent(self.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, self.OnReticleHiddenUpdate)
	SCENE_MANAGER:RegisterCallback("SceneStateChanged", self.UpdateDelayBarVisibility)
	EVENT_MANAGER:RegisterForEvent(self.name.."PlayerActivated", EVENT_PLAYER_ACTIVATED, self.UpdateDelayBarVisibility)

	ZO_CreateStringId("SI_BINDING_NAME_WD_TOGGLE", "Toggle WeaveDelays window")

	--- delay bar
	local bg = WINDOW_MANAGER:GetControlByName(prefix..'BG')
	local n = self.savedVariables.numDelayBarSlots
	local r = self.savedVariables.numDelayBarRows
	local w = self.savedVariables.scale
	local m = 2
	local h = 2+math.ceil(w*0.4)

	if self.savedVariables.showSkillsInDelayBar then
		h = h + w + 3
	end

	if self.savedVariables.showDelayBar then
		self.restoreDelayBarPosition()

		local avgLabelHeight, avgGap = math.ceil(w*0.44), 2

		WEAVEDELAYSBAR:SetDimensions((w+m)*n+2, h*r + avgLabelHeight + avgGap)
		bg:ClearAnchors()
		bg:SetAnchor(TOPLEFT, WEAVEDELAYSBAR, TOPLEFT, 0, avgLabelHeight + avgGap)
		bg:SetDimensions((w+m)*n+2, h*r)

		if not self.savedVariables.showDelayBarOnlyInCombat then
			self.visible = true
		else
			self.visible = false
		end
		self.UpdateDelayBarVisibility()

		bg:SetAlpha(self.savedVariables.delayBarAlpha)

		local textureControl,markerTextureControl,skillTextureControl,labelControl
		local k=1
		local chatFontSize = GetChatFontSize()
		local fontName = string.format("%s|%s|%s", FONT_FACE, math.ceil(0.016*chatFontSize*w), FONT_STYLE)

		local avgLabelFontName = string.format("%s|%s|%s", FONT_FACE, math.ceil(0.024*chatFontSize*w), FONT_STYLE)
		self.averageDelayLabel = WINDOW_MANAGER:CreateControl(prefix.."Avg", WEAVEDELAYSBAR, CT_LABEL)
		self.averageDelayLabel:SetFont(avgLabelFontName)
		self.averageDelayLabel:SetDimensions((w+m)*n, avgLabelHeight)
		self.averageDelayLabel:SetAnchor(TOPRIGHT, WEAVEDELAYSBAR, TOPRIGHT, -2, 0)
		self.averageDelayLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

		for j=1, r do
			for i=1, n do
				textureControl = WINDOW_MANAGER:CreateControl(prefix.."L"..k, bg, CT_TEXTURE)
				textureControl:SetDimensions(w, math.ceil(w*0.28))
				textureControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, math.max(math.ceil(w/10.0),1)+(j-1)*h)
				textureControl:SetColor(1.0,1.0,1.0,0.2)
				markerTextureControl = WINDOW_MANAGER:CreateControl(prefix.."B"..k, bg, CT_TEXTURE)
				markerTextureControl:SetDimensions(math.max(math.ceil(w/10.0),1), math.ceil(w*0.4))
				markerTextureControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, math.max(math.ceil(w*0.02),1)+(j-1)*h)
				markerTextureControl:SetColor(1.0,1.0,1.0,0.3)
				if self.savedVariables.showSkillsInDelayBar then
					skillTextureControl = WINDOW_MANAGER:CreateControl(prefix.."S"..k, bg, CT_TEXTURE)
					skillTextureControl:SetDimensions(w, w)
					skillTextureControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, math.max(math.ceil(w*0.4),1)+(j-1)*h)
					skillTextureControl:SetColor(1.0,1.0,1.0,0.1)
				end
				labelControl = WINDOW_MANAGER:CreateControl(prefix.."Q"..k, bg, CT_LABEL)
				labelControl:SetFont(fontName)
				labelControl:SetDimensions(math.ceil(w*0.28), math.ceil(w*0.28))
				labelControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+math.max(math.ceil(w*0.7),1), math.max(math.ceil(w*0.08),1)+(j-1)*h)
				self.delayBarSlotControls[k] = {
					box        = textureControl,
					marker     = markerTextureControl,
					picture    = skillTextureControl,
					statusFlag = labelControl,
				}
				k = k+1
			end
		end
	end

	self.UpdateUIcustomizations()
	self.UpdateDelayBarVisibility()

	--- menu
	self.InitializeMenu()

	--- latency
	self.log.SetHighLatencyMode(self.savedVariables.highLatencyMode)

	--- advanced
	self.log.SetSkillConfirmationEnabled(self.savedVariables.confirmSkillCasts)

end

function WeaveDelays.UpdateUIcustomizations()
	WEAVEDELAYSBARBG:SetEdgeColor(self.savedVariables.delayBarFrameR,self.savedVariables.delayBarFrameG,self.savedVariables.delayBarFrameB,self.savedVariables.delayBarFrameA)
	WEAVEDELAYSBARBG:SetEdgeTexture(nil, 1, 1, self.savedVariables.delayBarFrameThickness, 0)
end

local lastReloadNoticeMs = 0
local function NotifyReloadUI()
	local now = GetGameTimeMilliseconds()
	if now - lastReloadNoticeMs < RELOAD_NOTICE_THROTTLE_MS then return end
	lastReloadNoticeMs = now
	d("WeaveDelays: Reload UI to apply.")
end

function WeaveDelays.InitializeMenu()
	local LHAS = LibHarvensAddonSettings
	local settings = LHAS:AddAddon(self.name, {
		allowDefaults = true,
		allowRefresh  = true,
	})

	local paletteItems = {}
	for _, name in ipairs(self.getPalettesList()) do
		table.insert(paletteItems, { name = name, data = name })
	end

	settings:AddSettings({
	{
		type  = LHAS.ST_SECTION,
		label = "WeaveDelays",
	},
	{
		type  = LHAS.ST_LABEL,
		label = "If account wide settings are enabled, the character specific settings are preserved and can be restored by disabling account wide settings.",
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Account wide settings",
		getFunction = function()
			return self.savedVariables.accountWide
		end,
		setFunction = function(value)
			self.characterSavedVariables.accountWide = value
			self.savedVariables.accountWide = value
			NotifyReloadUI()
		end,
		default = false,
	},
	{
		type  = LHAS.ST_LABEL,
		label = "Unlock the UI to move around the bars. If enabled, bars are not hidden automatically.",
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Unlock UI",
		getFunction = function()
			return self.savedVariables.unlockUI
		end,
		setFunction = function(value)
			self.savedVariables.unlockUI = value
			self.OnReticleHiddenUpdate()
			if self.savedVariables.unlockUI and self.savedVariables.showDelayBar then
				WeaveDelays.ShowDelayBar()
			end
		end,
		default = false,
	},
	{
		type  = LHAS.ST_SECTION,
		label = "Cast delay bar",
	},
	{
		type  = LHAS.ST_LABEL,
		label = "The cast delay bar shows the time wasted between skill casts and if light attacks have been correctly weaved. The number of skills to be kept in the history can be chosen with rows and columns settings.",
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Show delay bar",
		getFunction = function()
			return self.savedVariables.showDelayBar
		end,
		setFunction = function(value)
			self.savedVariables.showDelayBar = value
			NotifyReloadUI()
		end,
		default = true,
	},
	{
		type        = LHAS.ST_COLOR,
		label       = "Frame color",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.delayBarFrameR, self.savedVariables.delayBarFrameG, self.savedVariables.delayBarFrameB, self.savedVariables.delayBarFrameA
		end,
		setFunction = function(r, g, b, a)
			self.savedVariables.delayBarFrameR, self.savedVariables.delayBarFrameG, self.savedVariables.delayBarFrameB, self.savedVariables.delayBarFrameA = r, g, b, a
			WeaveDelays.UpdateUIcustomizations()
		end,
		default = {0.8, 0.8, 0.8, 1.0},
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "Delay bar frame thickness",
		tooltip     = "Delay bar frame thickness",
		min         = 0,
		max         = 10,
		step        = 1,
		getFunction = function()
			return self.savedVariables.delayBarFrameThickness
		end,
		setFunction = function(value)
			self.savedVariables.delayBarFrameThickness = tonumber(value)
			WeaveDelays.UpdateUIcustomizations()
		end,
		default = 1,
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "Delay bar opacity",
		tooltip     = "Opacity for delay bar (0=transparent)",
		min         = 0,
		max         = 100,
		step        = 1,
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.delayBarAlpha * 100
		end,
		setFunction = function(value)
			self.savedVariables.delayBarAlpha = 0.01 * tonumber(value)
			if self.savedVariables.showDelayBar then
				WINDOW_MANAGER:GetControlByName(prefix..'BG'):SetAlpha(self.savedVariables.delayBarAlpha)
			end
		end,
		default = 90,
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "UI scaling 50=default",
		min         = 25,
		max         = 100,
		step        = 1,
		getFunction = function()
			return self.savedVariables.scale
		end,
		setFunction = function(value)
			self.savedVariables.scale = tonumber(value)
			NotifyReloadUI()
		end,
		default = 50,
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "Horizontal position",
		tooltip     = "Distance from the left edge of the screen. Can also be changed by dragging the bar while the UI is unlocked.",
		min         = -200,
		max         = GuiRoot:GetWidth(),
		step        = 1,
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return math.floor(self.savedVariables.delayBarOffsetX + 0.5)
		end,
		setFunction = function(value)
			WeaveDelays.SetDelayBarOffsetX(value)
		end,
		default = 300,
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "Vertical position",
		tooltip     = "Distance from the top edge of the screen. Can also be changed by dragging the bar while the UI is unlocked.",
		min         = -200,
		max         = GuiRoot:GetHeight(),
		step        = 1,
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return math.floor(self.savedVariables.delayBarOffsetY + 0.5)
		end,
		setFunction = function(value)
			WeaveDelays.SetDelayBarOffsetY(value)
		end,
		default = 400,
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "Delay bar slots (columns)",
		tooltip     = "Number of slots (columns)",
		min         = 1,
		max         = 40,
		step        = 1,
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.numDelayBarSlots
		end,
		setFunction = function(value)
			self.savedVariables.numDelayBarSlots = tonumber(value)
			NotifyReloadUI()
		end,
		default = 10,
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "Delay bar rows",
		tooltip     = "Number of rows",
		min         = 1,
		max         = 20,
		step        = 1,
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.numDelayBarRows
		end,
		setFunction = function(value)
			self.savedVariables.numDelayBarRows = tonumber(value)
			NotifyReloadUI()
		end,
		default = 1,
	},
	{
		type        = LHAS.ST_EDIT,
		label       = "Text (light attack not pressed)",
		tooltip     = "shown if the light attack button was not pressed before this skill",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.textLightAttackMissed
		end,
		setFunction = function(value)
			self.savedVariables.textLightAttackMissed = value
		end,
		default = "M",
	},
	{
		type        = LHAS.ST_EDIT,
		label       = "Text (light attack disappeared)",
		tooltip     = "shown if the light attack button was pressed before this skill, but the light attack was not registered, e.g. when casting too rapidly",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.textLightAttackDisappeared
		end,
		setFunction = function(value)
			self.savedVariables.textLightAttackDisappeared = value
		end,
		default = "X",
	},
	{
		type        = LHAS.ST_EDIT,
		label       = "Text (light attack queued)",
		tooltip     = "shown if the light attack button was pressed before this skill, the light attack was queued, but did not succeed, e.g. because of range/hit box or the enemy died before",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.textLightAttackQueued
		end,
		setFunction = function(value)
			self.savedVariables.textLightAttackQueued = value
		end,
		default = "Q",
	},
	{
		type        = LHAS.ST_EDIT,
		label       = "Text (bash cancelled)",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.textBashed
		end,
		setFunction = function(value)
			self.savedVariables.textBashed = value
		end,
		default = "B",
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Show only in combat",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.showDelayBarOnlyInCombat
		end,
		setFunction = function(value)
			self.savedVariables.showDelayBarOnlyInCombat = value
			if value then
				WeaveDelays.HideDelayBarIfNotInCombat(math.huge)
			else
				WeaveDelays.ShowDelayBar()
			end
		end,
		default = true,
	},
	{
		type        = LHAS.ST_SLIDER,
		label       = "Keep visible after combat",
		min         = 1,
		max         = 60,
		step        = 1,
		disable     = function()
			return (not self.savedVariables.showDelayBarOnlyInCombat) or (not self.savedVariables.showDelayBar)
		end,
		getFunction = function()
			return self.savedVariables.showDelayBarAfterCombat
		end,
		setFunction = function(value)
			self.savedVariables.showDelayBarAfterCombat = tonumber(value)
		end,
		default = 10,
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Show only in player homes",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.showDelayBarOnlyInHomes
		end,
		setFunction = function(value)
			self.savedVariables.showDelayBarOnlyInHomes = value
			WeaveDelays.UpdateDelayBarVisibility()
		end,
		default = false,
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Show skills",
		tooltip     = "Show skill symbols below delay indicator.",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.showSkillsInDelayBar
		end,
		setFunction = function(value)
			self.savedVariables.showSkillsInDelayBar = value
			NotifyReloadUI()
		end,
		default = true,
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Show average delay",
		tooltip     = "Show the average weaving delay in seconds",
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.showAverageDelay
		end,
		setFunction = function(value)
			self.savedVariables.showAverageDelay = value
			NotifyReloadUI()
		end,
		default = true,
	},
	{
		type        = LHAS.ST_DROPDOWN,
		label       = "Palette",
		tooltip     = "Color palette to use for delay indicator.",
		items       = paletteItems,
		disable     = function()
			return not self.savedVariables.showDelayBar
		end,
		getFunction = function()
			return self.savedVariables.delayBarPalette or "greenred"
		end,
		setFunction = function(_cb, name, _item)
			self.savedVariables.delayBarPalette = name
			self.UpdateDelayBar()
		end,
		default = "greenred",
	},
	{
		type  = LHAS.ST_SECTION,
		label = "Experimental features",
	},
	{
		type        = LHAS.ST_CHECKBOX,
		label       = "Increase latency tolerance",
		tooltip     = "If you have a high latency and problems with this addon, try to enable this setting.",
		getFunction = function()
			return self.savedVariables.highLatencyMode
		end,
		setFunction = function(value)
			self.savedVariables.highLatencyMode = value
			self.log.SetHighLatencyMode(self.savedVariables.highLatencyMode)
		end,
		default = false,
	}
	})
end

function WeaveDelays.OnAddOnLoaded(eventCode, addonName)
	if addonName == self.name then
		WeaveDelays:Initialize()
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
	end
end

SLASH_COMMANDS[self.slash] = function (cmd)
    local commands = {}
    local index = 1

    for i in string.gmatch(cmd, "%S+") do
        if (i ~= nil and i ~= "") then
            commands[index] = i
            index = index + 1
        end
    end

    if #commands == 0 then
        self.ToggleWindow()
    end

    if #commands == 1 then
		if commands[1] == "reset" then
			self.Reset()
		elseif commands[1] == "update" then
			self.Update()
		end
	end
end

SLASH_COMMANDS["/wdcolortest"] = function()
	WeaveDelays.ColorTest()
end

EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, self.OnAddOnLoaded)