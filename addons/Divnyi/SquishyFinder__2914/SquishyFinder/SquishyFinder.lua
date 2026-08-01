local LAM2 = LibAddonMenu2

-- Initialization section

SquishyFinder = {}

SquishyFinder.Default = {
  isShowInPVPOnly = false,
  isOnlyForAttackable = false,
  isDamageShieldsShown = true,
  isShowingPercentage = true,
  executeRange = 0.25,
  executeMessage = "Execute!",
  executeColor = {r=1.0, g=0.3, b=0.3, a=1.0},
  percentageColor = {r=1.0, g=1.0, b=1.0, a=0.6},
  playerGroups = {
    [1] = { hp=17000, title="Glass √√√√√", color={r=0.0, g=1.0, b=1.0, a=0.6} },
    [2] = { hp=21000, title="Squishiest √√√", color={r=0.0, g=1.0, b=0.0, a=0.6} },
    [3] = { hp=25000, title="Squishy √", color={r=0.5, g=1.0, b=0.0, a=0.6} },
    [4] = { hp=29000, title="Average", color={r=1.0, g=1.0, b=0.0, a=0.6} },
    [5] = { hp=34000, title="Advanced ×", color={r=1.0, g=0.7, b=0.0, a=0.7} },
    [6] = { hp=50000, title="Tanky ×××", color={r=1.0, g=0.0, b=0.0, a=0.7} },
    [7] = { hp=100000, title="Monstrous ×××××", color={r=1.0, g=0.0, b=0.3, a=0.7} },
    [8] = { hp=0, title="××× WHAT IS THIS ×××", color={r=1.0, g=0.0, b=0.6, a=0.7} },
  },
  npcGroups = {
    [1] = { hp=1, title="", color={r=1.0, g=1.0, b=1.0, a=0.5} },
    [2] = { hp=20000, title="", color={r=0.7, g=1.0, b=1.0, a=0.6 } },
    [3] = { hp=50000, title="", color={r=0.7, g=1.0, b=0.7, a=0.6 } },
    [4] = { hp=100000, title="", color={r=1.0, g=1.0, b=0.7, a=0.6 } },
    [5] = { hp=500000, title="", color={r=1.0, g=0.7, b=0.7, a=0.6 } },
    [6] = { hp=0, title="= Boss =", color={r=1.0, g=0.7, b=1.0, a=0.7} },
  },
  topOffset = { x = 0, y = 0 },
  leftOffset = { x = 0, y = 0 },
  rightOffset = { x = 0, y = 0 },
  bottomOffset = { x = 0, y = 0 },
  fontSize = 30,
}

SquishyFinder.name = "SquishyFinder"
SquishyFinder.version = "1.6"
SquishyFinder.databaseVersion = "1.6"
SquishyFinder.loaded = false
 
function SquishyFinder:Initialize()
  SquishyFinder.db = ZO_SavedVars:NewAccountWide("SquiFVars", SquishyFinder.databaseVersion, nil, SquishyFinder.Default)
  SquishyFinder.CreateSettingsWindow()
  SquishyFinder.reCreateAnchors()
  SquishyFinder.updateFont()
  
  SquishyFinder.loaded = true
  
  EVENT_MANAGER:RegisterForEvent(SquishyFinder.name, EVENT_RETICLE_TARGET_CHANGED, SquishyFinder.ReticleTargetChanged)
  EVENT_MANAGER:RegisterForEvent(SquishyFinder.name, EVENT_COMBAT_EVENT, SquishyFinder.CombatEvent)
end
 
function SquishyFinder.OnAddOnLoaded(event, addonName)
  if addonName == SquishyFinder.name then
    EVENT_MANAGER:UnregisterForEvent(SquishyFinder.name, EVENT_ADD_ON_LOADED)
    SquishyFinder:Initialize()
  end
end

function SquishyFinder.reCreateAnchors()
  SquishyFinderViewTop:ClearAnchors()
  SquishyFinderViewTop:SetAnchor(TOP, SquishyFinderView, TOP, SquishyFinder.db.topOffset.x, SquishyFinder.db.topOffset.y)
  SquishyFinderViewLeft:ClearAnchors()
  SquishyFinderViewLeft:SetAnchor(TOPRIGHT, SquishyFinderView, CENTER, SquishyFinder.db.leftOffset.x-40, SquishyFinder.db.leftOffset.y-18)
  SquishyFinderViewRight:ClearAnchors()
  SquishyFinderViewRight:SetAnchor(TOPLEFT, SquishyFinderView, CENTER, SquishyFinder.db.rightOffset.x+40, SquishyFinder.db.rightOffset.y-18)
  SquishyFinderViewBottom:ClearAnchors()
  SquishyFinderViewBottom:SetAnchor(BOTTOM, SquishyFinderView, BOTTOM, SquishyFinder.db.bottomOffset.x, SquishyFinder.db.bottomOffset.y)
end

function SquishyFinder.updateFont()
  local font = "$(BOLD_FONT)|" .. SquishyFinder.db.fontSize .. "|soft-shadow-thick"
  SquishyFinderViewTop:SetFont(font)
  SquishyFinderViewLeft:SetFont(font)
  SquishyFinderViewRight:SetFont(font)
  SquishyFinderViewBottom:SetFont(font)
end

function SquishyFinder.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "SquishyFinder",
		displayName = "Squishy Finder",
		author = "Divnyi",
		version = SquishyFinder.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
  local cntrlOptionsPanel = LAM2:RegisterAddonPanel("SquishyFinderPanel", panelData)
	local optionsData = {
	    {
			type = "checkbox",
			name = "Show in PvP only",
			tooltip = "Addon will only work in battlegrounds, cyrodiil and imperial city.",
			default = SquishyFinder.Default.isShowInPVPOnly,
			getFunc = function() return SquishyFinder.db.isShowInPVPOnly end,
			setFunc = function(newValue) 
				SquishyFinder.db.isShowInPVPOnly = newValue
			end,
		},
		{
			type = "checkbox",
			name = "Show for targetable units only",
			tooltip = "Uncheck to show for friendly units too.",
			default = SquishyFinder.Default.isOnlyForAttackable,
			getFunc = function() return SquishyFinder.db.isOnlyForAttackable end,
			setFunc = function(newValue) 
				SquishyFinder.db.isOnlyForAttackable = newValue
			end,
		},
		{
			type = "checkbox",
			name = "Show damage shields",
			tooltip = "Addon will only work in battlegrounds, cyrodiil and imperial city.",
			default = SquishyFinder.Default.isDamageShieldsShown,
			getFunc = function() return SquishyFinder.db.isDamageShieldsShown end,
			setFunc = function(newValue) 
				SquishyFinder.db.isDamageShieldsShown = newValue
			end,
		},
		{
			type = "checkbox",
			name = "Show hitpoint percentage at bottom",
			tooltip = "Shows hitpoint percentage while above execute range",
			default = SquishyFinder.Default.isShowingPercentage,
			getFunc = function() return SquishyFinder.db.isShowingPercentage end,
			setFunc = function(newValue) 
				SquishyFinder.db.isShowingPercentage = newValue
			end,
		},
		{
			type = "editbox",
			name = "Font size",
			textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
			tooltip = "default: 30",
			default = SquishyFinder.Default.fontSize,
			getFunc = function() return SquishyFinder.db.fontSize end,
			setFunc = function(text)
				SquishyFinder.db.fontSize = tonumber(text)
				SquishyFinder.updateFont()
			end,
		},
		{
			type = "header",
			name = "Position offsets",
		},
		{
			type = "description",
			text = "Point {x=0, y=0} is where labels are by default."
		},
		{
			type = "editbox",
			name = "Top label X offset",
			tooltip = "Positive values to the right, negative - to the left",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.topOffset.x,
			getFunc = function() return SquishyFinder.db.topOffset.x end,
			setFunc = function(text)
				SquishyFinder.db.topOffset.x = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "editbox",
			name = "Top label Y offset",
			tooltip = "Positive values - down, negative - up",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.topOffset.y,
			getFunc = function() return SquishyFinder.db.topOffset.y end,
			setFunc = function(text)
				SquishyFinder.db.topOffset.y = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "editbox",
			name = "Left label X offset",
			tooltip = "Positive values to the right, negative - to the left",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.leftOffset.x,
			getFunc = function() return SquishyFinder.db.leftOffset.x end,
			setFunc = function(text)
				SquishyFinder.db.leftOffset.x = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "editbox",
			name = "Left label Y offset",
			tooltip = "Positive values - down, negative - up",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.leftOffset.y,
			getFunc = function() return SquishyFinder.db.leftOffset.y end,
			setFunc = function(text)
				SquishyFinder.db.leftOffset.y = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "editbox",
			name = "Right label X offset",
			tooltip = "Positive values to the right, negative - to the left",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.rightOffset.x,
			getFunc = function() return SquishyFinder.db.rightOffset.x end,
			setFunc = function(text)
				SquishyFinder.db.rightOffset.x = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "editbox",
			name = "Right label Y offset",
			tooltip = "Positive values - down, negative - up",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.rightOffset.y,
			getFunc = function() return SquishyFinder.db.rightOffset.y end,
			setFunc = function(text)
				SquishyFinder.db.rightOffset.y = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "editbox",
			name = "Bottom label X offset",
			tooltip = "Positive values to the right, negative - to the left",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.bottomOffset.x,
			getFunc = function() return SquishyFinder.db.bottomOffset.x end,
			setFunc = function(text)
				SquishyFinder.db.bottomOffset.x = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "editbox",
			name = "Bottom label Y offset",
			tooltip = "Positive values - down, negative - up",
			textType = TEXT_TYPE_NUMERIC_INT,
			default = SquishyFinder.Default.bottomOffset.y,
			getFunc = function() return SquishyFinder.db.bottomOffset.y end,
			setFunc = function(text)
				SquishyFinder.db.bottomOffset.y = tonumber(text)
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "button",
			name = "Reset positions",
			tooltip = "Reset all label positions back to defaults.",
			func = function() 
				SquishyFinder.db.topOffset = SquishyFinder.Default.topOffset
				SquishyFinder.db.leftOffset = SquishyFinder.Default.leftOffset
				SquishyFinder.db.rightOffset = SquishyFinder.Default.rightOffset
				SquishyFinder.db.bottomOffset = SquishyFinder.Default.bottomOffset
				SquishyFinder.reCreateAnchors()
			end,
		},
		{
			type = "header",
			name = "Execute settings",
		},
		{
			type = "slider",
			name = "Execute range",
			tooltip = "Execute range, in percentage",
			min = 0,
			max = 100,
			step = 1,
			default = SquishyFinder.Default.executeRange*100,
			getFunc = function() return SquishyFinder.db.executeRange*100 end,
			setFunc = function(newValue) 
				SquishyFinder.db.executeRange = newValue/100
		  end,
		},
		{
			type = "editbox",
			name = "Execute message",
			tooltip = "Execute text displayed under the cursor",
			default = SquishyFinder.Default.executeMessage,
			getFunc = function() return SquishyFinder.db.executeMessage end,
			setFunc = function(text) 
				SquishyFinder.db.executeMessage = text
			end,
		},
		{
			type = "colorpicker",
			name = "Execute color",
			tooltip = "Color of the execute text under the cursor",
			default = SquishyFinder.Default.executeColor,
			getFunc = function() return SquishyFinder.ColorUnpack( SquishyFinder.db.executeColor ) end,
			setFunc = function(r,g,b,a) 
				SquishyFinder.db.executeColor = { r=r, g=g, b=b, a=a }
			end,
		},
		{
			type = "colorpicker",
			name = "Percentage color",
			tooltip = "Color of the percentage text (while above execute range)",
			default = SquishyFinder.Default.percentageColor,
			getFunc = function() return SquishyFinder.ColorUnpack( SquishyFinder.db.percentageColor ) end,
			setFunc = function(r,g,b,a) 
				SquishyFinder.db.percentageColor = { r=r, g=g, b=b, a=a }
			end,
		},
		{
			type = "header",
			name = "Player group settings",
		},
  }
  local optionsIndex = table.getn(optionsData)+1
  
  for idx=1,table.getn(SquishyFinder.Default.playerGroups) do -- player groups
    local result = SquishyFinder.createControlsForGroup(idx, SquishyFinder.db.playerGroups[idx], SquishyFinder.Default.playerGroups[idx])
    for resultIdx=1,table.getn(result) do
      optionsData[optionsIndex] = result[resultIdx]
      optionsIndex = optionsIndex + 1
    end
  end
  
  optionsData[optionsIndex] = {
			type = "header",
			name = "NPC group settings",
	}
  optionsIndex = optionsIndex + 1
  for idx=1,table.getn(SquishyFinder.Default.npcGroups) do -- NPC groups
    local result = SquishyFinder.createControlsForGroup(idx, SquishyFinder.db.npcGroups[idx], SquishyFinder.Default.npcGroups[idx])
    for resultIdx=1,table.getn(result) do
      optionsData[optionsIndex] = result[resultIdx]
      optionsIndex = optionsIndex + 1
    end
  end
  
	LAM2:RegisterOptionControls("SquishyFinderPanel", optionsData)
end

function SquishyFinder.createControlsForGroup(idx, group, default)
  local options = { }
  if group.hp ~= 0 then
    table.insert(options, {
        type = "editbox",
        name = "Group " .. idx .. " HP (upper bound)",
        tooltip = "Color group defined by HP under this value",
        textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
        default = default.hp,
        getFunc = function() return group.hp end,
        setFunc = function(text)
          group.hp = tonumber(text)
        end,
    })
  end
	table.insert(options, {
			type = "editbox",
			name = "Group " .. idx .. " message",
      default = default.title,
			getFunc = function() return group.title end,
			setFunc = function(text) 
				group.title = text
			end,
	})
  table.insert(options, {
			type = "colorpicker",
			name = "Group " .. idx .. " color",
      default = default.color,
			getFunc = function() return SquishyFinder.ColorUnpack( group.color ) end,
			setFunc = function(r,g,b,a) 
				group.color = { r=r, g=g, b=b, a=a }
			end,
	})
  return options
end

-- Events section

function SquishyFinder.ReticleTargetChanged()
	SquishyFinder.UpdateUI()
end

function SquishyFinder.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
  SquishyFinder.UpdateUI()
end

-- UI section

function SquishyFinder.UpdateUI()
  if SquishyFinder.loaded == true then
	local isInCampaign = IsPlayerInAvAWorld()
	local isInBattlegroud = GetCurrentBattlegroundId() ~= 0
	local isInPvPArea = isInCampaign or isInBattlegroud
    local enemyName = GetUnitName("reticleover")
	local isAttackable = IsUnitAttackable("reticleover")
	local shieldStrength = (GetUnitAttributeVisualizerEffectInfo("reticleover", ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH))
	local isHasShield = shieldStrength and shieldStrength > 0
    if (enemyName == "") or 
	(isInPvPArea==false and SquishyFinder.db.isShowInPVPOnly==true) or
	(isAttackable==false and SquishyFinder.db.isOnlyForAttackable==true) then
      SquishyFinderView:SetAlpha(0)
    else
      SquishyFinderView:SetAlpha(1)
      local current, max, effectiveMax = GetUnitPower("reticleover", POWERTYPE_HEALTH)
      local percentHP = current / max
      local isPlayer = IsUnitPlayer("reticleover")
	  
	  -- right panel
	  SquishyFinderViewRight:SetText(SquishyFinder.ShortHP(max))

	  -- left panel
	  local effectiveCurrentHP = current
	  if SquishyFinder.db.isDamageShieldsShown == true then
	    if isHasShield then
	      effectiveCurrentHP = effectiveCurrentHP + shieldStrength
	      SquishyFinderViewLeft:SetText(SquishyFinder.ShortHP(current) .. "\n+" .. SquishyFinder.ShortHP(shieldStrength))
        else 
		  SquishyFinderViewLeft:SetText(SquishyFinder.ShortHP(current))
		end
	  else 
		SquishyFinderViewLeft:SetText(SquishyFinder.ShortHP(current))
	  end
	  
      -- bottom panel
	  if current == 0 or (current == max and not isHasShield) then 
		SquishyFinderViewBottom:SetText("")
	  else
		if percentHP <= SquishyFinder.db.executeRange then
	      SquishyFinderViewBottom:SetText(SquishyFinder.db.executeMessage)
		  SquishyFinder.SetColor(SquishyFinder.db.executeColor, { SquishyFinderViewBottom })
		else
		  SquishyFinder.SetColor(SquishyFinder.db.percentageColor, { SquishyFinderViewBottom })
		  if SquishyFinder.db.isShowingPercentage then
			if isHasShield then
			  shieldPercentage = shieldStrength/max
			  SquishyFinderViewBottom:SetText(SquishyFinder.PercentageHP(percentHP) .. "% +" .. SquishyFinder.PercentageHP(shieldPercentage) .. "%")
			else
			  SquishyFinderViewBottom:SetText(SquishyFinder.PercentageHP(percentHP) .. "%")
			end
		  else
			SquishyFinderViewBottom:SetText("")
		  end
		end
	  end
	  
      -- HP group stuff
      local groups = SquishyFinder.db.npcGroups
      if isPlayer then
        groups = SquishyFinder.db.playerGroups
      end
        
      local currentHpGroup = SquishyFinder.FindGroupForHP(effectiveCurrentHP, groups)
      local maxHpGroup = SquishyFinder.FindGroupForHP(max, groups)
      SquishyFinderViewTop:SetText(maxHpGroup.title)
      SquishyFinder.SetColor(currentHpGroup.color, { SquishyFinderViewLeft })
      SquishyFinder.SetColor(maxHpGroup.color, { SquishyFinderViewTop, SquishyFinderViewRight })
    end
  end
end

function SquishyFinder.FindGroupForHP(hp, groups) 
  for idx=1,table.getn(groups) do
    local group = groups[idx]
    if group.hp == 0 or hp < group.hp then
      return group
    end
  end
end

function SquishyFinder.SetColor(color, views)
  local red, green, blue, alpha = SquishyFinder.ColorUnpack(color)
  for k, v in pairs(views) do
    v:SetColor(red, green, blue, alpha)
  end
end

function SquishyFinder.ColorUnpack(color)
  return color.r, color.g, color.b, color.a
end

function SquishyFinder.ShortHP(hpIntValue)
  if hpIntValue == 0 then 
    return "dead"
  end    
  local short = hpIntValue
  local shortSuffix = ""
  while short > 1000 do
    short = math.floor(short / 100) / 10
    shortSuffix = shortSuffix .. "k"
  end
  return short .. shortSuffix
end

function SquishyFinder.PercentageHP(hpValue)
  return math.ceil(hpValue*100)
end 

EVENT_MANAGER:RegisterForEvent(SquishyFinder.name, EVENT_ADD_ON_LOADED, SquishyFinder.OnAddOnLoaded)