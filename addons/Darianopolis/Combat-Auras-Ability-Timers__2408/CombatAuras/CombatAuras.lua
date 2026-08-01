-- local Util = DAL:Use("DariansUtilities", 6)
-- CombatAuras = DAL:Def("CombatAuras", 4, 2, {
-- 	onLoad = function(self) self:Init() end,
-- })

CombatAuras = {
    name = "CombatAuras",
    major = 5,
    minor = 2,
    version = "1.5.2"
}

local LAM = LibAddonMenu2

local Util = DariansUtilities
local Tracker = Util.AbilityTracker
-- local Log = Util.Logger

Util.onLoad(CombatAuras, function(self) self:Init() end)

local MIN_SIZE = 20
local MAX_SIZE = 80

function CombatAuras:Update()
	local time = GetFrameTimeMilliseconds()

	local evidence = { }
	for _, tag in ipairs({ "player", "reticleover" }) do
		local buffCount = GetNumBuffs(tag)
		for i = 1, buffCount do
			-- (b)uff | (t)exture | (e)ffect | (s)tatus(E)ffect | (a)bility
			local bName, started, ending, bSlot, stacks,      icon,        bType, 
			      eType, aType,   sEType, aId,   canClickOff, castByPlayer = GetUnitBuffInfo(tag, i)

			-- if tag == "reticleover" then
			-- 	log("Found "..bName.." on target"..tostring(castByPlayer))
			-- end

			if castByPlayer then
				
				local index = self.buffToSlot[bName]
				if index then

					local ability = self.slotToAbility[index]
					if (ability.aura.target == tag) then
						local remaining = (ending * 1000) - time
						
						-- if remaining < 0 then
						-- 	return
						-- end

						local duration = 1000 * (ending - started)

						-- log("Found evidence of ", ability.name, " R = ", remaining, " D = ", duration)

						local existing = evidence[bName]
						if (existing) then
							existing.stacks = existing.stacks + stacks
							existing.duration = math.max(existing.duration, duration)
							existing.remaining = math.max(existing.remaining, remaining)
						else
							evidence[bName] = {
								duration = duration,
								remaining = remaining,
								stacks = stacks,
							}
						end
					end
				end
			end
		end
	end

	for slot, ability in pairs(self.slotToAbility) do
		local info = evidence[ability.aura.buff]
		local cooldown = self.cooldowns[slot]

		if info then
			cooldown:UpdateCooldown(info.duration, info.remaining)
			cooldown.stacks = info.stacks
		elseif DoesUnitExist("reticleover") then
			cooldown:UpdateCooldown(0)
		end
	end
end

local DEFAULT_SIZE = 55

function CombatAuras:Init()
	self.config = ZO_SavedVars:NewCharacterIdSettings("CombatAurasSavedVars", 1, nil, {
		["xOffset"] = math.floor((GuiRoot:GetWidth() - (DEFAULT_SIZE * 5)) / 2),
		["yOffset"] = math.floor((GuiRoot:GetHeight() - (DEFAULT_SIZE * 2)) / 2),
		["size"] = DEFAULT_SIZE,
		["sweepColour"] = { 0, 1, 0, 1 },
		["backgroundColour"] = { 0, 0, 0, 0.5 },
		["showOOC"] = false,
	})

	self.log = true
	self.remaining = 0

	self.buffToSlot = { }
	self.slotToAbility = { }

	self.auras = { }

	self:BuildUI()
	self:BuildMenu()

	EVENT_MANAGER:RegisterForUpdate(
		self.name.."Update",
		1000 / 60,
		function(...) self:Update() end
	)

	EVENT_MANAGER:RegisterForUpdate(
		self.name.."UpdateVisibility",
		1000 / 10,
		function(...) 
			local show = Util.Targeting.isUnitValidCombatTarget("reticleover") 
								or IsUnitInCombat("player") 
								or self.config.showOOC
								or (CombatMetronome and CombatMetronome.force)

			self.display:SetHidden(not show)
		end
	)

	Util.Ability.Tracker.CombatAuras = self
	Util.Ability.Tracker:Start()
end

CombatAuras.NO_AURA = 0
CombatAuras.DEFAULT_ICD = { }

function CombatAuras:GetAuraForAbility(ability)
	local aura = self.auraoverrides[ability.name]

	if not aura and ability.morph ~= 0 then
		aura = self.auraoverrides[ability.baseName]
	end

    if not aura then
        aura = { }

        if ability.duration == 0 then aura.buff = ability.name end

        if ability.target == "Self" then
            aura.buff = ability.name
            aura.target = "player"
        end

        if ability.target == "Enemy" then
            aura.buff = ability.name
            aura.target = "reticleover"
        end

        -- if aura.buff then
        --     for i = 1, 100000 do
        --         local check = GetAbilityName(i)
        --         if #check > #ability.name and check:sub(1, #ability.name) == ability.name then
        --             aura.buff = check
        --             break
        --         end
        --     end
        -- end
    end

    -- d("--- aura for "..ability.name.." --")
    -- d(aura)

    return aura
end

function CombatAuras:HandleAbilityActivated(event)
	local ability = event.ability

	-- if not ability.aura then return end -- Ability has no trackable aura, ignore
	if event.slot < 3 or event.slot > 7 then return end -- Ignore light / heavy / ultimate attacks

	if not ability.aura then
		ability.aura = self:GetAuraForAbility(ability)
	end

	if ability.aura == CombatAuras.NO_AURA then return end -- Ignore abilities with no triggerable aura

	local index = (event.slot - 2) + (event.hotbar == HOTBAR_CATEGORY_PRIMARY and 0 or 5)
	local cooldown = self.cooldowns[index]
	cooldown.icon:SetCenterTexture(GetAbilityIcon(event.ability.id))

	if not ability.aura.buff then
		cooldown:UpdateCooldown(ability.aura.duration or ability.duration)
		return
	end

	local existing = self.slotToAbility[index]
	if not existing or existing.id ~= ability.id then
		if existing then
			self.buffToSlot[existing.aura.buff] = nil
		end

		self.slotToAbility[index] = ability
		self.buffToSlot[ability.aura.buff] = index
	end
end

function CombatAuras:BuildUI()
	local size = self.config.size
	local width = size * 5
	local height = size * 2
	local edge = (4 / 55) * size

    if not self.frame then
        self.frame = Util.Controls:NewFrame(self.name.."Frame")
        self.frame:SetHandler("OnMoveStop", function(...)
            self.config.xOffset = math.floor(self.frame:GetLeft())
            self.config.yOffset = math.floor(self.frame:GetTop())
            self:BuildUI()
        end)
    end
    self.frame:SetDimensions(width, height)
    self.frame:ClearAnchors()
    self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.config.xOffset, self.config.yOffset)

    self.display = self.display or Util.Controls:New(CT_BACKDROP, self.name.."Display", self.frame)
    self.display:ClearAnchors()
    self.display:SetAnchorFill()
    self.display:SetCenterColor(0, 0, 0, 0)

	self.cooldowns = self.cooldowns or { }
	for i = 1, 10 do
		if not self.cooldowns[i] then self.cooldowns[i] = Util.Cooldown:New(self.name.."Cooldown") end
		local cooldown = self.cooldowns[i]
		cooldown.frame = self.display
		cooldown.size = size
		cooldown.edge = edge
		cooldown.xOffset = size * ((i - 1) % 5)
		cooldown.yOffset = (i > 5) and size or 0
		cooldown.cooldownColour = self.config.sweepColour
		cooldown.backgroundColour = self.config.backgroundColour
		cooldown:Build()
	end
end

function CombatAuras:BuildMenu()
	self.menu = { }
	self.menu.metadata = {
		type = "panel",
		name = "Combat Auras",
		displayName = "Combat Auras",
		author = "Darianopolis",
		version = ""..self.version,
		slashCommand = "/ca",
		registerForRefresh = true,
	}
	self.menu.options = {
		{
			type = "header",
			name = "Position / Size",
		},
		{
			type = "checkbox",
			name = "Unlock",
			tooltip = "Reposition / resize bar by dragging center / edges.",
			getFunc = function() return self.frame.IsUnlocked() end,
			setFunc = function(value)
			    self.frame:SetUnlocked(value)
			end,
		},
		{
			type = "slider",
			name = "X Offset",
			min = 0,
			max = math.floor(GuiRoot:GetWidth() - (self.config.size * 5)),
			step = 1,
			getFunc = function() return self.config.xOffset end,
			setFunc = function(value)
			    self.config.xOffset = value
			    self:BuildUI()
			end
		},
		{
			type = "button",
			name = "Center Horizontally",
			func = function()
			    self.config.xOffset = math.floor((GuiRoot:GetWidth() - (self.config.size * 5)) / 2)
			    self:BuildUI()
			end
		},
		{
            type = "slider",
            name = "Y Offset",
            min = 0,
            max = math.floor(GuiRoot:GetHeight() - (self.config.size * 2)),
            step = 1,
            getFunc = function() return self.config.yOffset end,
            setFunc = function(value) 
                self.config.yOffset = value 
                self:BuildUI()
            end,
        },
        {
            type = "button",
            name = "Center Vertically",
            func = function()
                self.config.yOffset = math.floor((GuiRoot:GetHeight() - (self.config.size * 2)) / 2)
                self:BuildUI()
            end
        },
        {
            type = "slider",
            name = "Size",
            min = MIN_SIZE,
            max = MAX_SIZE,
            step = 1,
            getFunc = function() return self.config.size end,
            setFunc = function(value) 
                self.config.size = value 
                self:BuildUI()
            end,
        },
        {
            type = "header",
            name = "Colour / Layout",
        },
        {
            type = "colorpicker",
            name = "Cooldown Colour",
            tooltip = "Colour of the cooldown sweep",
            getFunc = function() return unpack(self.config.sweepColour) end,
            setFunc = function(r, g, b, a)
                self.config.sweepColour = {r, g, b, a}
                self:BuildUI()
            end,
        },
        {
            type = "colorpicker",
            name = "Background Colour",
            tooltip = "Colour of the cooldown background",
            getFunc = function() return unpack(self.config.backgroundColour) end,
            setFunc = function(r, g, b, a)
                self.config.backgroundColour = {r, g, b, a}
                self:BuildUI()
            end,
        },
        {
            type = "checkbox",
            name = "Show OOC",
            tooltip = "Track GCDs whilst out of combat",
            getFunc = function() return self.config.showOOC end,
            setFunc = function(value)
                self.config.showOOC = value
            end
        },
	}

	self.menu.panel = LAM:RegisterAddonPanel(self.name.."Options", self.menu.metadata)
	LAM:RegisterOptionControls(self.name.."Options", self.menu.options)
end

-- EVENT_MANAGER:RegisterForEvent(CombatAuras.name.."Load", EVENT_ADD_ON_LOADED, function(...)
-- 	if (CombatAuras.loaded) then return end
-- 	CombatAuras.loaded = true

-- 	CombatAuras:Init()
-- end)