local WM = WINDOW_MANAGER
CCTracker = CCTracker or {}

CCTracker.DEFAULT_SAVED_VARS = {
	["version"] = 1,
	["showBetaMessage"] = true,
	["lastAddOnVersion"] = 0,
	["global"] = true,
	["UI"] = {
		["xOffsets"] = {},
		["yOffsets"] = {},
		["sizes"] = {
			["oneForAll"] = true,
			["size"] = 50,
		},
		["debugWindow"] = {
			["xOffset"] = 50,
			["yOffset"] = 50,
			["height"] = 50,
			["width"] = 50,
		},
		["size"] = 50,
		["alpha"] = {
			["oneForAll"] = true,
			["alpha"] = 100,
		},
		["timers"] = {
			["oneForAll"] = true,
			["showTimer"] = true,
			["timerColor"] = {1, 1, 1, 1},
			["timerAnchor"] = "ICON",
			["showTimerBar"] = true,
			["timerBarColor"] = {1, 1, 1, 0.7},
			["timerBarOrientation"] = "LEFT",
		},
	},
	["settings"] = {
		["tracked"] = {},
		["unlocked"] = true,
		["sample"] = false,
		["ccIgnoreLinks"] = false,
	},
	["sound"] = {
		["MuteOnHardCC"] = false,
	},
	["ignored"] = {},
	["additionalRoots"] = {},
	["actualSnares"] = {},
	["debug"] = {
		["enabled"] = false,
		["ccCache"] = false,
		["roots"] = false,
		["ignoreList"] = false,
		["ccActive"] = false,
		["ccAdded"] = false,
		["actualSnares"] = false,
		["additionalRootList"] = false,
		["activeCCList"] = false,
	},
}

CCTracker.CC_VARIABLES = {
		["charm"] = {["icon"] = "/esoui/art/icons/ability_u34_sea_witch_mindcontrol.dds", ["res"] = 3510, ["name"] = "Charm", ["isHardCC"] = true,}, --ACTION_RESULT_CHARMED
		[32] = {["icon"] = "/esoui/art/icons/ability_debuff_disorient.dds", ["res"] = 2340, ["name"] = "Disoriented", ["isHardCC"] = false,}, --ABILITY_TYPE_DISORIENT
		[27] = {["icon"] = "/esoui/art/icons/ability_debuff_fear.dds", ["res"] = 2320, ["name"] = "Fear", ["isHardCC"] = true,}, --ABILITY_TYPE_FEAR
		[17] = {["icon"] = "/esoui/art/icons/ability_debuff_knockback.dds", ["res"] = 2475, ["name"] = "Knockback", ["isHardCC"] = true,}, --ABILITY_TYPE_KNOCKBACK
		[48] = {["icon"] = "/esoui/art/icons/ability_debuff_levitate.dds", ["res"] = 2400, ["name"] = "Levitating", ["isHardCC"] = true,}, --ABILITY_TYPE_LEVITATE
		[53] = {["icon"] = "/esoui/art/icons/ability_debuff_offbalance.dds", ["res"] = 2440, ["name"] = "Offbalance", ["isHardCC"] = false,}, --ABILITY_TYPE_OFFBALANCE
		["root"] = {["icon"] = "/esoui/art/icons/ability_debuff_root.dds", ["res"] = 2480, ["name"] = "Root", ["isHardCC"] = false,}, --ACTION_RESULT_ROOTED
		[11] = {["icon"] = "/esoui/art/icons/ability_debuff_silence.dds", ["res"] = 2010, ["name"] = "Silence", ["isHardCC"] = false,}, --ABILITY_TYPE_SILENCE
		[10] = {["icon"] = "/esoui/art/icons/ability_debuff_snare.dds", ["res"] = 2025, ["name"] = "Snare", ["isHardCC"] = false,}, --ABILITY_TYPE_SNARE
		[33] = {["icon"] = "/esoui/art/icons/ability_debuff_stagger.dds", ["res"] = 2470, ["name"] = "Stagger", ["isHardCC"] = false,}, --ABILITY_TYPE_STAGGER
		[9] = {["icon"] = "/esoui/art/icons/ability_debuff_stun.dds", ["res"] = 2020, ["name"] = "Stun", ["isHardCC"] = true,}, --ABILITY_TYPE_STUN
	}
	
	-- populate default sv
do
	local i = 0
	local defaultSize = 50
	local defaultAlpha = 100
	for _, entry in pairs(CCTracker.CC_VARIABLES) do
		CCTracker.DEFAULT_SAVED_VARS.UI.xOffsets[entry.name] = i*defaultSize
		CCTracker.DEFAULT_SAVED_VARS.UI.yOffsets[entry.name] = 0
		CCTracker.DEFAULT_SAVED_VARS.UI.sizes[entry.name] = defaultSize
		CCTracker.DEFAULT_SAVED_VARS.UI.alpha[entry.name] = defaultAlpha
		CCTracker.DEFAULT_SAVED_VARS.UI.timers[entry.name] = {
			showTimer = true,
			timerColor = {1, 1, 1, 1},
			timerAnchor = "ICON",
			showTimerBar = true,
			timerBarColor = {1, 1, 1, 0.7},
			timerBarOrientation = "LEFT",
		}
		CCTracker.DEFAULT_SAVED_VARS.settings.tracked[entry.name] = false
		CCTracker.DEFAULT_SAVED_VARS.sound[entry.name] = {
			enabled = false,
			sound = "General_Alert_Error",
		}
		i = i + 1
	end
end

	-------------------
	---- Constants ----
	-------------------
CCTracker.constants = CCTracker.constants or {
	["possibleRoots"] = {1856,5655,5656,5657,8373,8668,10896,14138,14467,14468,14469,14523,16353,16668,18391,20527,20816,21114,21776,22004,23277,23402,23831,23916,23924,26118,26869,27145,27156,27167,27303,27304,27306,27307,27309,27311,28025,28308,29721,30083,30085,30087,30089,30092,30095,30218,30221,30224,31713,32685,33903,33912,33921,34183,34187,34578,35750,37001,38705,38984,38989,40372,40382,40769,40773,40777,40977,40988,40995,41000,41006,41013,42008,42706,42713,42720,42727,42737,42747,42757,42764,42771,45481,47084,47086,47109,47210,48287,49557,49630,50286,50287,50544,50981,52436,54795,54819,55485,56731,60790,60792,60798,60799,60801,64133,65892,65893,65894,67514,68564,70246,72208,73652,76423,76448,76449,79122,79124,80574,80812,80815,80821,80822,80823,80830,80831,80834,82054,82055,82318,84434,85128,86175,86176,86177,86178,86179,86180,86181,86182,86183,86184,86185,86186,86238,86506,86508,86510,86518,86520,86522,87236,87260,87264,87560,88310,88462,89680,89812,91224,91227,91246,91627,92038,92038,92039,92039,92058,92060,97002,97005,98637,99367,100420,101755,102008,102023,104196,104686,104688,104897,104900,105011,105017,105232,105235,105286,105292,105293,105627,105641,105642,107238,107303,107305,107311,107312,110190,110916,110919,110920,110922,110923,110940,110965,110966,110968,110969,110970,110971,110975,110976,110977,110978,111346,111570,111571,111847,112131,112550,112763,113133,113261,113513,113566,114162,115177,116798,117133,118308,118352,119035,119068,124575,126700,127193,127194,127226,127227,129348,129897,129907,137917,137918,141310,142962,146956,149956,149957,157747,160299,160301,160302,163569,165357,165363,165379,165871,167678,169698,169701,171560,171566,171581,171582,171583,171584,171603,171742,171751,171752,171759,171760,171761,171789,171879,171880,172831,172833,174174,174455,174958,175540,175810,175811,176658,176659,176660,177194,177195,177196,177197,177564,177578,177595,178464,178566,178863,178864,178865,178875,178969,179089,179205,179413,179553,181211,182338,182401,183006,183401,185817,185823,187362,188624,188627,188678,188679,188680,188695,188696,188699,191568,193017,195893,198781,201973,201974,201978,201979,201980,201981,202047,202048,202049,202050,202075,202718,202725,202727,202728,202729,202777,203033,203034,203035,203036,203378,204176,204942,206265,206266,206296,206297,206298,206299,206762,206763,206764,206765,206766,207298,209479,209483,209884,209886,209891,209892,209894,209904,209905,209906,209907,209908,209910,209911,209912,209913,210053,210054,210107,210415,210417,210424,210433,210434,210435,210436,210460,210461,210477,214487,215348,215349,215350,215351,215358,215662,215663,215664,216393,216399,216972,217190,217208,217209,217529,217529,218162,218251,218252,218334,218335,219388,219407,219418,222594,222595,222597,222611,222612,222614
		},
	["definiteRoots"] = {14550,20253,21733,28452,34706,35391,36964,38707,38990,43146,44305,61785,76533,98447,98834,103493,103653,103666,143948,183009,186772,186773,186832,217066,217611,223065
		},
	["definiteSnares"] = {2612,5273,7145,8239,9039,9516,10650,11339,12288,14221,18054,18515,18546,19225,20528,20780,20971,21019,21539,21733,21837,21941,21942,22525,26380,26635,27326,28504,31085,31197,31248,31480,31606,32712,33085,33551,34627,34919,34946,35142,35278,36945,36958,37109,37132,38217,38834,38842,39357,40492,41803,41952,43817,46524,46563,47318,47838,49203,49597,51646,51879,53200,54855,55863,55911,58241,59772,61108,61388,63168,65318,65549,65698,66293,66344,67494,67507,67525,68046,68151,68231,70068,70420,70428,70545,72584,72815,72863,73214,73243,73296,73375,73716,74083,75706,76827,76912,76916,76939,76966,77030,78350,79065,79092,79094,79102,79191,79367,79457,79459,79743,79924,81191,81196,81216,81506,82868,83072,85656,87241,87301,87443,87448,87491,88477,88801,88858,88861,88915,89307,90269,91851,91949,92492,92932,92970,92971,92972,92973,93408,94907,95580,95643,95771,96869,97545,98015,99608,99844,99847,99910,100405,100958,100972,101443,101693,101884,102397,103673,103719,103784,104894,105765,105861,106379,106656,106724,107811,108516,108796,109473,109672,109673,109675,109676,109808,110799,111768,112496,113317,113319,113348,113659,113769,113771,114059,114061,114065,114067,114118,114345,114354,116180,116964,118354,118928,118936,118938,119284,120331,120571,120713,120901,121278,121416,121442,121526,121671,122568,123663,125797,125936,126409,127316,127787,127790,127795,130895,130966,131688,133248,133405,133812,133956,134522,134775,135745,135787,137807,138090,138491,138492,138835,139567,139870,142606,143659,143663,146332,146870,150540,155008,156552,158609,158641,159391,160080,160949,163898,164175,164176,164340,166040,166724,166824,167679,167683,168590,169320,169654,170346,170759,174606,175049,184291,184635,190179,190229,191889,205126,208861,212324,213838,213901,215451,217246,217477,218509,219029,220519,220630,221173,222565,222567,222568,223477
		},
	["rollDodge"] = {["abilityId"] = 28549,	["buffId"] = 29721},
	["breakFree"] = 16565,
	["exceptions"] = {
		-- [41952] = "Cower",
		},
	["ignore"] = {
		[194570] = "IA - entering IA",
		[194571] = "IA - advancing to next arena",
		[193049] = "IA - leaving IA",
		[194634] = "IA - leaving IA",
		[211431] = "IA - entering special arena",
		[202995] = "IA - choosing vision/verse",
		[203101] = "IA - choosing vision/verse",
		[203124] = "IA - choosing vision/verse",
		[203125] = "IA - choosing vision/verse",
		[166794] = "DSR - Raging Current",
		[167949] = "DSR - Raging Current",
		[37139] = "Mount",
		[36434] = "Mount",
		[36419] = "Dismount",
		[36417] = "Dismount",
		[36432] = "Dismount",
		[165424] = "Arsenal (Stun)",
		[156451] = "Arsenal (Stun)",
		[72712] = "Hideyhole",
		[75747] = "Hideyhole",
		[28549] = "RollDodge",
		[39518] = "Vampire Initiation",
		[14646] = "Revive (Snare)",
		[14644] = "Revive (Stun)",
		-- [40602] = "MQ - Returning home after final quest",
		-- [80290] = "Goldcoast MQ - Travel to Jarell",
		-- [80298] = "Goldcoast MQ - Travel to Anvil",
		[57993] = "ICP - Flesh granade",
		-- [39358] = "Fighters Guild - Destroying Mortuum Vivicus",
	},
	["specialCC"] = {
	},
}
	--------------------------
	---- Helper functions ----
	--------------------------
	
function CCTracker:CropZOSString(zosString, formatter)
    -- local _, zosStringDivider = string.find(zosString, "%^")
    
    -- if zosStringDivider then
        -- return string.sub(zosString, 1, zosStringDivider - 1)
    -- else
        -- return zosString
    -- end
	if formatter == "ability" then
		return zo_strformat(SI_ABILITY_NAME, zosString)
	elseif formatter == "name" then
		return zo_strformat(SI_TOOLTIP_UNIT_NAME, zosString)
	elseif formatter == "location" then
		return zo_strformat(SI_WORLD_MAP_LOCATION_NAME, zosString)
	end
end

function CCTracker:AbilityInList(aId, list)--, cacheId)
	if type(list[1]) == "table" then
		for i, entry in ipairs(list) do
			if entry.id == aId or entry.cacheId == aId then
				return true, i		-- 'aId' found
			end
		end
		return false -- 'aId' not found
	elseif type(list[1]) == "number" then
		for i, entry in ipairs(list) do
			if entry == aId then
				return true, i
			end
		end
		return false
	end
end

function CCTracker:ClearCCThatIsNotBuff()
	-- if NonContiguousCount(self.ccActive) then
		local ccChanged = false
		local time = GetFrameTimeMilliseconds()
		local cache = {}
		for _, entry in ipairs(self.ccActive) do
			if entry.endTime ~= 0 or entry.startTime == time then
				table.insert(cache, entry)
			else
				ccChanged = true
				if entry.isSubeffect then self:ClearSubeffects(entry.id, time) end
			end
		end
		if ccChanged then
			self.ccActive = cache
			self:CCChanged()
			self:PrintDebug("enabled", "Zone was changed. Cleared all active CC effects that are not debuffs at time: "..time)
		end
	-- end
end

function CCTracker:IsSpecialIgnore(aId)
	if self.status.zoneId == 976 and aId == 119292 then
		return true
	end
	return false
end

-- function CCTracker:TypeInList(cachedType)
	-- for _, entry in ipairs(self.ccActive) do
        -- if entry.type == cachedType then
            -- return true -- 'cachedType' found
        -- end
    -- end
    -- return false -- 'cachedType' not found
-- end

function CCTracker:IsRoot(id)
	local possibleRoot , _ = self:AbilityInList(id, self.constants.possibleRoots)
	local markedAsDefiniteRoot, _ = self:AbilityInList(id, self.constants.definiteRoots)
	local markedAsRoot, _ = self:AbilityInList(id, self.SV.additionalRoots)
	
	if markedAsRoot or markedAsDefiniteRoot then
		self:PrintDebug("roots", "Checked "..self:CropZOSString(GetAbilityName(id), "ability").." - "..id..". It was specificly marked as root!")
		return true
	elseif possibleRoot then
		self:PrintDebug("roots", "Found possible root "..self:CropZOSString(GetAbilityName(id), "ability").." with ID: "..id)
		return true
	else
		table.insert(self.SV.actualSnares, id)
		self:PrintDebug("roots", "Checked "..self:CropZOSString(GetAbilityName(id), "ability").." - "..id.." for possible root, it seems you were simply hit by a snare.")
		return false
	end
end

function CCTracker:CCChanged(playSound)
	self.UI.ApplyIcons()
	-- self:PrintDebug("ccActive", "CC changed, doing stuff")
	self.menu.CreateListOfActiveCC()
	self:UpdateTimers()
	
	self:RestoreAudioVolume()
	if playSound then
		self:PlayCCSound()
	end
	
	if self.SV.debug.activeCCList then self:CreateActiveCCString() end
end

----------------------
-- CC Timer updater --
----------------------

local function RegisterTimerUpdater()	
	EVENT_MANAGER:RegisterForUpdate(
        CCTracker.name.."UpdateTimers",
        1000 / 60,
        function(...) CCTracker:UpdateTimers() end
    )
	CCTracker.updaterRegistered = true
end

local function UnregisterTimerUpdater()	
	EVENT_MANAGER:UnregisterForUpdate(
        CCTracker.name.."UpdateTimers")
	
	CCTracker.updaterRegistered = false
end

function CCTracker:UpdateTimers()
	local updaterNeeded = false
	if self.ccActive and next(self.ccActive) then
		for _, entry in pairs(self.ccActive) do
			local name = self.ccVariables[entry.type].name
			local sv = self.SV.UI.timers.oneForAll and self.SV.UI.timers or self.SV.UI.timers[name]
			if entry.duration and entry.duration > 0 then
				local timeRemaining = (entry.endTime - GetFrameTimeMilliseconds())/1000
				if sv.showTimer then
					if timeRemaining >= 60 then
						local minutes = math.floor(timeRemaining/60)
						local seconds = math.floor(timeRemaining-minutes*60)
						self.UI.indicator[name].controls.timer:SetText(string.format("%d:%02d", minutes, seconds))
						self.UI.indicator[name].controls.timer:SetHidden(false)
						updaterNeeded = true
					elseif timeRemaining >= 10 then
						self.UI.indicator[name].controls.timer:SetText(string.format("%ds", math.floor(timeRemaining)))
						self.UI.indicator[name].controls.timer:SetHidden(false)
						updaterNeeded = true
					elseif timeRemaining > 0 then
						self.UI.indicator[name].controls.timer:SetText(string.format("%.1fs", timeRemaining))
						self.UI.indicator[name].controls.timer:SetHidden(false)
						updaterNeeded = true
					else 
						self.UI.indicator[name].controls.timer:SetHidden(true)
					end
					if sv.timerAnchor == "ICON" then
						local size = self.SV.UI.sizes.oneForAll and self.SV.UI.sizes.size or self.SV.UI.sizes[name]
						for i = math.floor(size*0.6), 1, -1 do
							self.UI.indicator[name].controls.timer:SetFont("$(MEDIUM_FONT)|"..i.."|outline")
							if self.UI.indicator[name].controls.timer:GetWidth() < size*0.9 then break end
						end
					end
				end
				if sv.showTimerBar and timeRemaining > 0 then
					self.UI.indicator[name].controls.timerBar:SetValue(timeRemaining/(entry.duration/1000))
					self.UI.indicator[name].controls.timerBar:SetHidden(false)
					self.UI.indicator[name].controls.timerBarBackdrop:SetHidden(false)
					self.UI.indicator[name].controls.timerBarGloss:SetHidden(false)
					updaterNeeded = true
				else
					self.UI.indicator[name].controls.timerBar:SetHidden(true)
					self.UI.indicator[name].controls.timerBarBackdrop:SetHidden(true)
					self.UI.indicator[name].controls.timerBarGloss:SetHidden(true)
				end
			else
				self.UI.indicator[name].controls.timer:SetHidden(true)
				self.UI.indicator[name].controls.timerBar:SetHidden(true)
				self.UI.indicator[name].controls.timerBarBackdrop:SetHidden(true)
				self.UI.indicator[name].controls.timerBarGloss:SetHidden(true)
			end
		end
	else
		for _, entry in pairs(self.ccVariables) do
			self.UI.indicator[entry.name].controls.timer:SetHidden(true)
			self.UI.indicator[entry.name].controls.timerBar:SetHidden(true)
			self.UI.indicator[entry.name].controls.timerBarBackdrop:SetHidden(true)
			self.UI.indicator[entry.name].controls.timerBarGloss:SetHidden(true)
		end
	end
	
	if updaterNeeded and not self.updaterRegistered then
		RegisterTimerUpdater()
	elseif not updaterNeeded and self.updaterRegistered then
		UnregisterTimerUpdater()	
	end
end

--------------------
-- Live CC Window --
--------------------

function CCTracker:CreateActiveCCString()
	local stringOfAllActiveCC
	for i, entry in ipairs(self.menu.ccList.active.string) do
		if i == 1 then
			stringOfAllActiveCC = tostring(self.menu.ccList.active.id[i].." "..entry)
		else
			stringOfAllActiveCC = tostring(stringOfAllActiveCC.."\n"..self.menu.ccList.active.id[i].." "..entry)
		end
	end
	self.UI.liveCCWindow.controls.tlwLabel:SetText(stringOfAllActiveCC)
	self:ResizeLiveCCWindow()
end

function CCTracker:ResizeLiveCCWindow()
	local window = self.UI.liveCCWindow.controls
	local height = window.tlwLabel:GetHeight()
	local width = window.tlwLabel:GetWidth() + 8
	
	window.tlw:SetDimensions(width, height)
	
	local guiWidth = GuiRoot:GetWidth()
	if (self.SV.UI.debugWindow.xOffset + width > guiWidth) then
		window.tlw:ClearAnchors()
		window.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, (guiWidth - width - 8), self.SV.UI.debugWindow.yOffset)
	else
		window.tlw:ClearAnchors()
		window.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.UI.debugWindow.xOffset, self.SV.UI.debugWindow.yOffset)
	end
end

function CCTracker:ClearOutdatedLists(time, client)
	-- deleting outdated cc entries
	if self.ccActive and next(self.ccActive) then
		ccChanged = self:ClearOutdatedCC(time)
	end
	-- deleting outdated cache entries
	-- if self.ccCache and next(self.ccCache) then
		-- self:ClearOutdatedCache(client, time)
	-- end
	-- deleting outdated "couldBeRoot" entries
	if self.couldBeRoot and next(self.couldBeRoot) then
		self:ClearOutdatedRootCache(time)
	end
	
	if self.activeEffects and next(self.activeEffects) then
		self:ClearOutdatedActiveEffects(time)
	end
	
	self:UpdateTimers()
end

function CCTracker:IsInPvPZone()
	if IsActiveWorldBattleground() or IsPlayerInAvAWorld() then
		self.inPVPZone = true
	else
		self.inPVPZone = false
	end
	return self.inPVPZone
end

	-------------------
	---- CC active ----
	-------------------
function CCTracker:ClearAllCC()
	if NonContiguousCount(self.ccActive) > 0 then
		local time = GetFrameTimeMilliseconds()
		for i = #self.ccActive, 1, -1 do
			local entry = self.ccActive[i]
			if entry.isSubeffect then self:ClearSubeffects(entry.id, time) end
			self.ccActive[i] = nil
		end
		self:CCChanged()
	end
end

function CCTracker:ClearOutdatedActiveEffects(time)
	for eId, entry in pairs(self.activeEffects) do
		if entry.time ~= time then
			self.activeEffects[eId] = nil
			self:PrintDebug("ccActive", "Clearing active effect "..eId.." - "..self:CropZOSString(GetAbilityName(eId), "ability"))
		end
	end
end

function CCTracker:ClearSubeffects(id, time)
	-- local removedAbility = false
	for eId, entry in pairs(self.activeEffects) do
		if entry.subeffects and next(entry.subeffects) then
			local inList, num = self:AbilityInList(id, entry.subeffects)
			if inList then
				table.remove(entry.subeffects, num)
				-- removedAbility = true
			end
		end
	end
	
	-- if removedAbility then 
		self:ClearOutdatedActiveEffects(time)
		self:PrintDebug("ccActive", "Cleared out all instances of subeffect "..id.." - "..self:CropZOSString(GetAbilityName(id), "ability").." at time: "..time)
	-- end
end

function CCTracker:ClearOutdatedCC(time)	
	local newActive = {}
	for _, entry in ipairs(self.ccActive) do
		if entry.endTime == 0 or entry.endTime > time then
			table.insert(newActive, entry)
		elseif entry.isSubeffect then
			self:ClearSubeffects(entry.id, time)
			self:PrintDebug("ccActive", "Removing outdated CC ability "..self:CropZOSString(GetAbilityName(entry.id), "ability").." - "..entry.id)
		end
	end
	if #self.ccActive == #newActive then
		return false
	else
		self.ccActive = newActive
		self:CCChanged()
		return true
	end
end

function CCTracker:DoesBreakFreeWork()
	for _, entry in ipairs(self.ccActive) do
		--				"charm"					"stun"				"fear"
		if entry.type == "charm" or entry.type == 9 or entry.type == 27 then
			return true
		end
	end
	return false
end

function CCTracker:BreakFreeDetected()
	local newActive = {}
	for _, entry in ipairs(self.ccActive) do
		if not (entry.type == "charm" or entry.type == 9 or entry.type == 27) then
			table.insert(newActive, entry)
		end
	end
	self.ccActive = newActive
	self:CCChanged()
end

function CCTracker:RolldodgeDetected()
	local newActive = {}
	local time = GetFrameTimeMilliseconds()
	for _, entry in ipairs(self.ccActive) do
		local markedAsRoot, _  = self:AbilityInList(entry.id, self.SV.additionalRoots)
		local markedAsDefiniteRoot, _ = self:AbilityInList(entry.id, self.constants.definiteRoots)
		local markedAsSnare, _ = self:AbilityInList(entry.id, self.SV.actualSnares)
		
		if not markedAsRoot and not markedAsSnare and not markedAsDefiniteRoot then
		
			if entry.type ~= "root" then
				table.insert(newActive, entry)
							-- "snare"
				if entry.type == 10 then
					local couldBeRoot = {}
					couldBeRoot.time = time
					if entry.cacheId == 0 then
						couldBeRoot.id = entry.id
					else
						couldBeRoot.id = entry.cacheId
					end
					table.insert(self.couldBeRoot, couldBeRoot)
				end
			else
				local couldJustBeSnare = {}
				couldJustBeSnare.time = time
				if entry.cacheId == 0 then
					couldJustBeSnare.id = entry.id
				else
					couldJustBeSnare.id = entry.cacheId
				end
				self:PrintDebug("actualSnares", "Saving ability "..couldJustBeSnare.id..": "..self:CropZOSString(GetAbilityName(couldJustBeSnare.id), "ability")..", for possible snare list")
				table.insert(self.couldJustBeSnare, couldJustBeSnare)
				table.insert(self.couldBeRoot, couldJustBeSnare)
			end
		end
	end
	self.ccActive = newActive
	self:CCChanged()
	zo_callLater(function() self:ClearSnareCache() end, 1)
	-- self:PrintDebug("enabled", "Found a dodgeRoll, you lucky guy")
end

function CCTracker:SnareRootCheck(id, num, name)
	-- if self.ccActive[num].type == 10 or self.ccActive[num] == "root" then 
		-- local ccType
		-- if self.ccActive[num].type == 10 then
			-- ccType = "Snare"
		-- else
			-- ccType = "Root"
		-- end
		-- self:PrintDebug("actualSnares", "additionalRootList", ccType.." effect "..id..": "..name.." faded, checking for actual "..ccType)
	-- end
	
	if self.ccActive[num].type == 10 and next(self.couldBeRoot) and self:AbilityInList(id, self.couldBeRoot) then
		table.insert(self.SV.additionalRoots, id)				-- add ability id to saved variables
		-- table.insert(self.constants.possibleRoots, id)			-- add ability it to possibleRoots list to be sorted correctly in the future without reloading ui
		self:PrintDebug("additionalRootList", "Added "..self:CropZOSString(GetAbilityName(id), "ability").." - "..id.." - to additional roots")
	elseif self.ccActive[num].type == "root" and next(self.couldJustBeSnare) then
		local inList, num = self:AbilityInList(id, self.couldJustBeSnare)
		if inList then
			table.remove(self.couldJustBeSnare, num)
		end
	end
end
	
	------------------
	---- CC Cache ----
	------------------

-- function CCTracker:ClearOutdatedCache(client, time)
    -- local newCache = {}
    -- for _, entry in ipairs(self.ccCache) do
        -- if entry.recorded == time then
            -- table.insert(newCache, entry)
        -- else
			-- self:PrintDebug("ccCache", client.." clearing outdated CC from cache: "..entry.name)
        -- end
    -- end
    -- self.ccCache = newCache
-- end

function CCTracker:ClearOutdatedRootCache(time)
	local newCache = {}
	for _, entry in ipairs(self.couldBeRoot) do
		if entry.time == time then
			table.insert(newCache, entry)
		end
	end
	self.couldBeRoot = newCache
end

function CCTracker:ClearSnareCache()
	if self.couldJustBeSnare and next(self.couldJustBeSnare) then
		self:PrintDebug("actualSnares", "Clearing actual snares list")
		for i, entry in ipairs(self.couldJustBeSnare) do
			-- if self:AbilityInList(entry.id, self.SV.additionalRoots) or self:AbilityInList(entry.id, self.constants.definiteRoots) then
				-- self:PrintDebug("actualSnares", "The ability "..entry.id.." - "..self:CropZOSString(GetAbilityName(entry.id), "ability").." was specificly marked as root. Skipping check on this one.")
				-- self.couldJustBeSnare[i] = nil
			-- elseif self:AbilityInList(entry.id, self.SV.actualSnares) then
				-- self:PrintDebug("actualSnares", "The ability "..entry.id.." - "..self:CropZOSString(GetAbilityName(entry.id), "ability").." was already marked as snare. Skipping check on this one.")
				-- self.couldJustBeSnare[i] = nil
			-- else
				table.insert(self.SV.actualSnares, entry.id)
				local inList, num = self:AbilityInList(entry.id, self.constants.possibleRoots)
				if inList then
					table.remove(self.constants.possibleRoots, num)
				end
				self:PrintDebug("actualSnares", "There seems to be a misidentified root. Added "..entry.id.." - "..self:CropZOSString(GetAbilityName(entry.id), "ability").." to actual snares list.")
				self.couldJustBeSnare[i] = nil
			-- end
		end
	end
end
	
	------------
	---- UI ----
	------------

function CCTracker:IsUnlocked()
	for _, entry in pairs(self.ccVariables) do
		if self.UI.indicator[entry.name].controls.tlw.IsUnlocked() then
			return true
		end
	end
	return false
end
	
	--------------
	---- Menu ----
	--------------
	
function CCTracker:HandleLibChatMessage()
	local value = (self.SV.debug.enabled or self.SV.settings.ccIgnoreLinks)
	if self.debug then self.debug:SetEnabled(value) end
end
	
function CCTracker.menu.CreateMenuIconsPath(ControlName)
	local number
	for i, entry in ipairs(barnysCCTrackerOptions.controlsToRefresh) do
		if ControlName == entry.data.name then
			number = i
			return number
		end
	end
end

function CCTracker.menu.UpdateLists()
	CCTracker.menu.CreateListOfActiveCC()
	CCTracker.menu.CreateIgnoredCCList()
	CCTracker.menu.CreateAdditionalRootList()
	CCTracker.menu.CreateActualSnaresList()
end

function CCTracker.menu.CreateAdditionalRootList()
	for i in ipairs(CCTracker.menu.additionalRootList) do
		CCTracker.menu.additionalRootList[i] = nil
	end
	
	for i, id in ipairs(CCTracker.SV.additionalRoots) do
		local str = tostring("|t20:20:"..GetAbilityIcon(id).."|t "..id.." - "..CCTracker:CropZOSString(GetAbilityName(id), "ability"))
		table.insert(CCTracker.menu.additionalRootList, str)
	end
	
	local panelControls = CCTracker.menu.panel.controlsToRefresh
	for i, entry in ipairs(panelControls) do
		local control = panelControls[i]
		if (control.data and control.data.name == "Current additional roots") then
			control:UpdateChoices()
			control:UpdateValue()
			break
		end
	end
end

function CCTracker.menu.CreateActualSnaresList()
	for i in ipairs(CCTracker.menu.actualSnaresList) do
		CCTracker.menu.actualSnaresList[i] = nil
	end
	
	for i, id in ipairs(CCTracker.SV.actualSnares) do
		local str = tostring("|t20:20:"..GetAbilityIcon(id).."|t "..id.." - "..CCTracker:CropZOSString(GetAbilityName(id), "ability"))
		table.insert(CCTracker.menu.actualSnaresList, str)
	end
	
	local panelControls = CCTracker.menu.panel.controlsToRefresh
	for i, entry in ipairs(panelControls) do
		local control = panelControls[i]
		if (control.data and control.data.name == "Current actual snares") then
			control:UpdateChoices()
			control:UpdateValue()
			break
		end
	end
end

function CCTracker.menu.CreateListOfActiveCC()
	for i in ipairs(CCTracker.menu.ccList.active.string) do
		CCTracker.menu.ccList.active.string[i] = nil
		CCTracker.menu.ccList.active.id[i] = nil
		CCTracker.menu.ccList.active.type[i] = nil
	end
	
	if NonContiguousCount(CCTracker.ccActive) ~= 0 then
		for i, entry in ipairs(CCTracker.ccActive) do
			if entry then
				local abilityString = tostring("|t20:20:"..GetAbilityIcon(entry.id).."|t "..CCTracker:CropZOSString(GetAbilityName(entry.id), "ability")..", "..CCTracker.ccVariables[entry.type].name)
				CCTracker.menu.ccList.active.string[i] = abilityString
				-- if entry.cacheId and entry.cacheId ~= 0 then
					-- CCTracker.menu.ccList.active.id[i] = entry.cacheId
				-- else
					CCTracker.menu.ccList.active.id[i] = entry.id
				-- end
				CCTracker.menu.ccList.active.type[i] = CCTracker.ccVariables[entry.type].name
			end
		end
	else
		CCTracker.menu.ccList.active.string[1] = "No cc active"
		CCTracker.menu.ccList.active.id[1] = 0
		CCTracker.menu.ccList.active.type[1] = "-"
	end
	
	local panelControls = CCTracker.menu.panel.controlsToRefresh
	for i, entry in ipairs(panelControls) do
		local control = panelControls[i]
		if (control.data and control.data.name == "List of current cc abilities") then
			control:UpdateChoices()
			control:UpdateValue()
			break
		end
	end
end

function CCTracker.menu.CreateIgnoredCCList()
	for i in ipairs(CCTracker.menu.ccList.ignored.string) do
		CCTracker.menu.ccList.ignored.string[i] = nil
	end
	for i in ipairs(CCTracker.menu.ccList.ignored.id) do
		CCTracker.menu.ccList.ignored.id[i] = nil
	end
	
	if NonContiguousCount(CCTracker.SV.ignored) ~= 0 then
		for id, ccType in pairs(CCTracker.SV.ignored) do
			local num = #CCTracker.menu.ccList.ignored.string + 1
			local ignoredAbilityString = tostring("|t20:20:"..GetAbilityIcon(id).."|t "..ccType)
			CCTracker.menu.ccList.ignored.string[num] = ignoredAbilityString
			CCTracker.menu.ccList.ignored.id[num] = id
		end
	else
		-- CCTracker.debug:Print("No ignored abilities")
		CCTracker.menu.ccList.ignored.string[1] = "No ignored abilities"
		CCTracker.menu.ccList.ignored.id[1] = 0
	end
	
	
	local panelControls = CCTracker.menu.panel.controlsToRefresh
	for i, entry in ipairs(panelControls) do
		local control = panelControls[i]
		if (control.data and control.data.name == "List of ignored cc abilities") then
			control:UpdateChoices()
			control:UpdateValue()
			break
		end
	end
end

	----------------
	---- Sounds ----
	----------------

function CCTracker:RestoreAudioVolume()
	if tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME)) == 0 then
		-- check if hard cc is over
		if #self.ccActive > 0 then
			for _, entry in pairs(self.ccVariables) do
				if entry.active and entry.isHardCC then
					self:PrintDebug("audioMute", "Hard cc still ongoing. Will not restore audio volume")
					return
				end
			end
		end
		-- restore original UI Volume
		self:PrintDebug("audioMute", "No more hard cc. Restoring audio volume")
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, self.audioVolume)
	end
end

function CCTracker:PlayCCSound()
	-- self.debug:Print("Sound requested")
	if #self.ccActive > 0 then
		-- self.debug:Print("Checking which sound needs to be played")
		for _, entry in pairs(self.ccVariables) do
			if self.SV.sound.MuteOnHardCC and entry.isHardCC then
				self:PrintDebug("audioMute", "Hard cc. Setting audio volume to 0")
				SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, 0)
			elseif entry.playSound then
				PlaySound(self.SV.sound[entry.name].sound)
				-- self.debug:Print("Playing sound for "..entry.name)
				entry.playSound = false
			end
		end
	end
end	
	
	----------------------
	---- Ignore Links ----
	----------------------

function CCTracker:HandleIgnoreLinks(link, button, text, color, linkType, name, id, zone)
    if linkType ~= "CC_ABILITY_IGNORE_LINK" then
		-- self.debug:Print("Not my kind of link")
        return
    end
	local aId = tonumber(id)
    if button then
		if self.SV.ignored[aId] then 
			self.debug:Print("Ability is already ignored")
			return true -- link has been handled
		end
		self.SV.ignored[aId] = tostring(name.." - "..zone.." - added manually")
		self.debug:Print("CC ability "..name.." will be ignored in the future.")
		for i, entry in ipairs(self.ccActive) do
			if entry.id == aId or (entry.cacheId and entry.cacheId == aId) then
				table.remove(self.ccActive, i)
			end
		end
		self.UI.ApplyIcons()
		self.menu.UpdateLists()
    end
    return true -- link has been handled
end

function CCTracker:InitLinkHandler()
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, self.HandleIgnoreLinks, self)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, self.HandleIgnoreLinks, self)
end

function CCTracker:PrintIgnoreLink(name, id)
	self.debug:Print("New cc ability detected "..name)
	self.debug:Print("Click |c2a52be|H1:CC_ABILITY_IGNORE_LINK:"..name..":"..id..":"..self:CropZOSString(GetUnitZone('player'), "location").."|h[here]|h|r to ignore it in the future,")
	self.debug:Print("or ignore the ID: "..id.." manually in the |c2a52be/bcc|r menu")
end

	-----------------------
	---- Notifications ----
	-----------------------

local function RemoveNotification(provider, identifier)
	local notifications = provider.notifications
	for i = #notifications, 1, -1 do
		if notifications[i].heading == identifier then
			table.remove(notifications, i)
			provider:UpdateNotifications()
			break
		end
	end
end

local function BetaNotification(provider)
	local identifier = "CCTracker Beta User"
	local function accept()
		CCTracker.SV.showBetaMessage = false
		RemoveNotification(provider, identifier) 
	end

	local msg = {
	dataType = NOTIFICATIONS_REQUEST_DATA,
	secsSinceRequest = ZO_NormalizeSecondsSince(0),
	note = "If you encounter any unwanted 'features' pls report them in the ESOUI 'Comment' section (You can find the link in the menu metadata).\nAccepting this message will disable it until a new version is detected.",
	message = "You are currently using CCTracker's beta version",
	heading = identifier,
	texture = "/esoui/art/miscellaneous/eso_icon_warning.dds",
	shortDisplayText = "CCTracker beta warning",
	controlsOwnSounds = false,
	keyboardAcceptCallback = accept,
    keyboardDeclineCallback = function() RemoveNotification(provider, identifier) end,
    gamepadAcceptCallback = accept,
    gamepadDeclineCallback = function() RemoveNotification(provider, identifier) end,
	data = {}, -- Place any custom data you want to store here
    }
	
	-- CCTracker:PrintDebug("enabled", "You're currently using self's beta version")
	
	return msg
end

local function NewVersionAlert(provider)
	local identifier = "CCTracker version update"
	local function decline()
		CCTracker.SV.lastAddOnVersion = CCTracker.versionCheck
		RemoveNotification(provider, identifier)
	end

	local msg = {
	dataType = NOTIFICATIONS_ALERT_DATA,
	secsSinceRequest = ZO_NormalizeSecondsSince(0),
	note = "Your new version is: "..CCTracker.versionCheck.."\nDue to updates some values in your saved vars might have been reset and you need to adjust your options. Apologies for the inconvenience.",
	message = "You are now using CCTracker version "..CCTracker.versionCheck.."\nCheck the changelog for new features. Dismiss to disable this message.",
	heading = identifier,
	texture = "/esoui/art/journal/u26_progress_digsite_checked_complete.dds",
	shortDisplayText = "CCTracker updated",
	controlsOwnSounds = false,
	keyboardAcceptCallback = function() RemoveNotification(provider, identifier) end,
	keyboardDeclineCallback = decline,
	gamepadAcceptCallback = function() RemoveNotification(provider, identifier) end,
	gamepadDeclineCallback = decline,
	data = {}, -- Place any custom data you want to store here
    }
	
	-- CCTracker:PrintDebug("enabled", "New Version was detected. Current version: "..tostring(CCTracker.versionCheck))
	
	return msg
end

function CCTracker:CreateNotifications()
	local provider = self.msg:CreateProvider()
	local msg
	
	if self.beta and self.SV.showBetaMessage then
		msg = BetaNotification(provider)
		table.insert(provider.notifications, msg)
	end
	
	if self.versionCheck ~= self.SV.lastAddOnVersion then
		msg = NewVersionAlert(provider)
		table.insert(provider.notifications, msg)
	end
	
	provider:UpdateNotifications()
end


	---------------
	---- Debug ----
	---------------

function CCTracker:SetAllDebugFalse()
	for option, _ in pairs(self.SV.debug) do
		if option ~= "activeCCList" then self.SV.debug[option] = false end
	end
end

function CCTracker:PrintDebug(debugType1, arg1, arg2)
	local debugType2, message
	if arg2 then
		debugType2 = arg1
		message = arg2
	else
		debugType2 = nil
		message = arg1
	end
	
	if self.SV.debug[debugType1] or (debugType2 and self.SV.debug[debugType2]) then
		self.debug:Print(message)
	end
end