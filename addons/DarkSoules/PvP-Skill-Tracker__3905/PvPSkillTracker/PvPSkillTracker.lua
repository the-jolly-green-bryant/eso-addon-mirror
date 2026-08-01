Skill = Skill or {}
Skill.Name = "PvPSkillTracker"
Skill.Version = "1.2"

Skill.Spells = {
    --arcanist Skill
    [182988] = {
        ["Icon"] = "/esoui/art/icons/ability_arcanist_004_b.dds",
        ["Cooldown"] = 14,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6}
    },
    --warden shalk
    [86009] = {
        ["Icon"] = "/esoui/art/icons/ability_warden_015.dds",
        ["Cooldown"] = 8,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3}
    },
    [86015] = {
        ["Icon"] = "/esoui/art/icons/ability_warden_015_a.dds",
        ["Cooldown"] = 20,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,1,1,2,2,3,3}
    },
    [86019] = {
        ["Icon"] = "/esoui/art/icons/ability_warden_015_b.dds",
        ["Cooldown"] = 14,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,1,1,2,2,3,3}
    },
    --sorcer curse
    [24326] = {
        ["Icon"] = "/esoui/art/icons/ability_sorcerer_daedric_curse.dds",
        ["Cooldown"] = 14,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6}
    },
    [24330] = {
        ["Icon"] = "/esoui/art/icons/ability_sorcerer_velocious_curse.dds",
        ["Cooldown"] = 26,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,8,1,1,2,2,3,3,3}
    },
    [24328] = {
        ["Icon"] = "/esoui/art/icons/ability_sorcerer_explosive_curse.dds",
        ["Cooldown"] = 14,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6}
    },
    --necro blastbones
    [117690] = {
        ["Icon"] = "/esoui/art/icons/ability_necromancer_002_a.dds",
        ["Cooldown"] = 8,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3}
    },
    --templar power
    [21761] = {
        ["Icon"] = "/esoui/art/icons/ability_templar_backlash.dds",
        ["Cooldown"] = 14,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6}
    },
    [21765] = {
        ["Icon"] = "/esoui/art/icons/ability_templar_purifying_light.dds",
        ["Cooldown"] = 14,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6}
    },
    [21763] = {
        ["Icon"] = "/esoui/art/icons/ability_templar_power_of_the_light.dds",
        ["Cooldown"] = 14,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6}
    },
    --dragonknight Incinerate
    [32853] = {
        ["Icon"] = "/esoui/art/icons/ability_dragonknight_002_a.dds",
        ["Cooldown"] = 33,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4,5,5,1,1,2,2,3,3,4,4,5,5,1,1,2,2,3,3,4,4,5,5,5}
    },
	--dragonknight Core of Flame
    [31837] = {
        ["Icon"] = "/esoui/art/icons/ability_dragonknight_012.dds",
        ["Cooldown"] = 10,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4}
    },
	[32792] = {
        ["Icon"] = "/esoui/art/icons/ability_dragonknight_012_a.dds",
        ["Cooldown"] = 10,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4}
    },
	[32785] = {
        ["Icon"] = "/esoui/art/icons/ability_dragonknight_012_b.dds",
        ["Cooldown"] = 10,
        ["Mylist"] = {0,0,0,1,1,2,2,3,3,4,4}
    },
}

Skill.ActivePanels = {}

function Skill.MakePanelMovable(panel, abilityId)
    panel:SetHandler("OnMouseUp", function(self, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
            
            local left = self:GetLeft()
            local top = self:GetTop()

            Skill.SavedVariables.Panel[abilityId] = { Left = left, Top = top }
        end
    end)

end

-- Create new panel
function Skill.CreatePanelForAbility(abilityId)
    if Skill.ActivePanels[abilityId] then
        Skill.ActivePanels[abilityId].Countdown = Skill.Spells[abilityId].Cooldown
        Skill.ActivePanels[abilityId].Control:SetHidden(false)
        return
    end

    local controlName = "SkillTrackerPanel" .. tostring(abilityId)
    local existing = GetControl(controlName)
	if existing then
		Skill.ActivePanels[abilityId] = {
			Control = existing,
			Label = existing:GetNamedChild("Label"),
			Countdown = Skill.Spells[abilityId].Cooldown,
			Mylist = Skill.Spells[abilityId].Mylist or {},
			Fragment = ZO_SimpleSceneFragment:New(existing),
		}
		Skill.UIUpdate()
		return
	end

    local panel = CreateControlFromVirtual(controlName, GuiRoot, "SkillTrackerTemplate")
    if not panel then return end

    local icon = panel:GetNamedChild("Icon")
    local label = panel:GetNamedChild("Label")
    if not icon or not label then return end

    panel:ClearAnchors()
    local savedPos = Skill.SavedVariables.Panel[abilityId]
    if savedPos and savedPos.Left and savedPos.Top and savedPos.Left ~= -1 and savedPos.Top ~= -1 then
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.Left, savedPos.Top)
    else
        local count = 0
        for _ in pairs(Skill.ActivePanels) do count = count + 1 end
        panel:SetAnchor(CENTER, GuiRoot, CENTER, 100 + count * 70, 100)
    end

    panel:SetHidden(false)
    icon:SetTexture(Skill.Spells[abilityId].Icon)
    label:SetText("0")

    Skill.MakePanelMovable(panel, abilityId)
	
	local fragment = ZO_SimpleSceneFragment:New(panel)
	
    Skill.ActivePanels[abilityId] = {
        Control = panel,
        Label = label,
        Countdown = Skill.Spells[abilityId].Cooldown,
        Mylist = Skill.Spells[abilityId].Mylist or {},
		Fragment = fragment,
    }
	Skill.UIUpdate()
end

-- Update all active panels
function Skill.UpdatePanel(abilityId)
    local data = Skill.ActivePanels[abilityId]
    if not data then return end
	
	Skill.UIUpdate()
    local label = data.Label
    local countdown = data.Countdown
    local number = data.Mylist[countdown + 1] or 0

    if number == 1 then
        label:SetColor(0, 1, 0, 1)
        label:SetText("1")
    elseif number == 2 then
        label:SetColor(1, 1, 0, 1)
        label:SetText("2")
    else
        label:SetColor(1, 1, 1, 1)
        label:SetText(tostring(number))
    end
	
	data.Countdown = countdown - 1
    if data.Countdown < 0 then
        EVENT_MANAGER:UnregisterForUpdate("SkillTrackerLoop" .. tostring(abilityId))
        data.Control:SetHidden(true)
		HUD_SCENE:RemoveFragment(data.Fragment)
		HUD_UI_SCENE:RemoveFragment(data.Fragment)
		Skill.ActivePanels[abilityId] = nil
    end
end

-- Handle ability used
function Skill.OnEffectChanged(_, skillpos)
    local currentHotbarCategory = GetActiveHotbarCategory()
    local abilityId = GetSlotBoundId(skillpos, currentHotbarCategory)
    if Skill.Spells[abilityId] ~= nil then
        Skill.CreatePanelForAbility(abilityId)
		Skill.UpdatePanel(abilityId)
        EVENT_MANAGER:UnregisterForUpdate("SkillTrackerLoop" .. tostring(abilityId))
        EVENT_MANAGER:RegisterForUpdate("SkillTrackerLoop" .. tostring(abilityId), 500, function()
            Skill.UpdatePanel(abilityId)
        end)
    end
end

-- Saved variables
function Skill.InitSavedVariables()
    local defaults = { Panel = {} }
    local visible = {
        ["Ind"] = true,
    }
    Skill.SavedVariables = ZO_SavedVars:NewAccountWide("SkillTrackerSV", 1, nil, defaults)
    Skill.Visible = ZO_SavedVars:NewCharacterNameSettings("SkillTrackerSV", 1, nil, visible)
end

-- UI toggle
function Skill.UIUpdate()
    for _, data in pairs(Skill.ActivePanels) do
        if Skill.Visible.Ind then
            data.Control:SetHidden(false)
			HUD_SCENE:AddFragment(data.Fragment)
			HUD_UI_SCENE:AddFragment(data.Fragment)
        else
            data.Control:SetHidden(true)
			HUD_SCENE:RemoveFragment(data.Fragment)
			HUD_UI_SCENE:RemoveFragment(data.Fragment)
        end
    end
end

-- Slash command
local function slashCommandFunction(extra)
    Skill.Visible.Ind = not Skill.Visible.Ind
    Skill.UIUpdate()
end

SLASH_COMMANDS["/pvpskill"] = slashCommandFunction

-- Load event
function Skill.OnAddOnLoaded(_, addonName)
    if addonName ~= Skill.Name then return end

    Skill.InitSavedVariables()
    Skill.UIUpdate()

    EVENT_MANAGER:RegisterForEvent(Skill.Name, EVENT_ACTION_SLOT_ABILITY_USED, Skill.OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(Skill.Name, EVENT_ACTION_SLOT_ABILITY_USED, REGISTER_FILTER_UNIT_TAG, "player")
end

EVENT_MANAGER:RegisterForEvent(Skill.Name, EVENT_ADD_ON_LOADED, Skill.OnAddOnLoaded)
