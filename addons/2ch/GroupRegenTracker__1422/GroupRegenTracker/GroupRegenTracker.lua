local myAddonName				 = 'GroupRegenTracker'
local isInit				= false
GRT	 = {
	debug = false,
	GROUP = "Group",
	RAID 	= "Raid",
	SavedVar = {},
	unitTags = {},
	targets = " ",
	target = {
		["ESO"] = {
			name = "ESO",
			enable = false,
			["Group"] = {
				anchor	= function(num) return _G["ZO_GroupUnitFramegroup"..num.."Hp"] end,
				bar			= function(num) return _G["ZO_GroupUnitFramegroup"..num.."Hp"] end,
				texture = {
					Path			= function() return "/esoui/art/unitattributevisualizer/attributebar_small_fill_center.dds" end,
					EdgePath	= "/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge.dds",
					EdgeW			= 8,
					EdgeH			= 8,
				},
				textureGloss = {
					enable = true,
					Path		= "/esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds",
					EdgePath	= "/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds",
					EdgeW			= 8,
					EdgeH			= 8,
				},
				shield = {
					enable = true,
					texture = {
						Path		= "/esoui/art/unitattributevisualizer/attributebar_small_fill_center.dds",
						EdgePath	= "/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge.dds",
						EdgeW			= 8,
						EdgeH			= 8,
					},
					textureGloss = {
						enable = true,
						Path			= "/esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds",
						EdgePath	= "/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds",
						EdgeW			= 8,
						EdgeH			= 8,
					},
				},
				getUnitTag	= function(num) 
					return "group"..num
				end,
			},
			["Raid"] = {
				anchor	= function(num) return _G["ZO_RaidUnitFramegroup"..num] end,
				bar			= function(num) return _G["ZO_RaidUnitFramegroup"..num.."Hp"] end,
				texture = {
					Path			= function() return "/esoui/art/unitattributevisualizer/attributebar_small_fill_center.dds" end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = true,
					Path			= "/esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds",
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					return "group"..num
				end,
			},
		},
		["FTC"]= {
			name = "FTC",
			enable = false,
			["Group"] = {
				anchor	= function(num) return _G["FTC_GroupFrame"..num.."_Health"] end,
				bar			= function(num) 
					_G["FTC_GroupFrame"..num.."_Shield"]:SetDrawLayer(2)
					_G["FTC_GroupFrame"..num.."_ShieldBar"]:SetDrawLayer(2)
					return _G["FTC_GroupFrame"..num.."_Health"] end,
				texture = {
					Path			= function() return "FoundryTacticalCombat/lib/textures/grainy.dds" end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = false,
					Path			= nil,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					local unitTag
					for i = 1 , 4 do
						unitTag = "group"..i
						if num == GetGroupIndexByUnitTag(unitTag) then
							return unitTag
						end
					end
					return unitTag
				end,
			},
			["Raid"] = {
				anchor	= function(num) return _G["FTC_RaidFrame"..num.."_Health"] end,
				bar			= function(num) return _G["FTC_RaidFrame"..num.."_Health"] end,
				texture = {
					Path			= function() return "FoundryTacticalCombat/lib/textures/grainy.dds" end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = false,
					Path			= nil,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					local unitTag
					for i = 1 , 24 do
						unitTag = "group"..i
						if num == GetGroupIndexByUnitTag(unitTag) then
							return unitTag
						end
					end
					return unitTag
				end,
			},
		},
		["AUI"]= {
			name = "AUI",
			enable = false,
			["Group"] = {
				auiStyle = nil,
				anchor	= function(num) 
					if _G["AUI_Tactical_GroupFrame"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Group"].auiStyle = "AUI_Tactical_GroupFrame"
					elseif _G["TESO_GroupFrame"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Group"].auiStyle = "TESO_GroupFrame"
					else
						GRT.target["AUI"]["Group"].auiStyle = "AUI_GroupFrame"
					end
					return _G[GRT.target["AUI"]["Group"].auiStyle..num.."_Bar"] 
				end,
				bar	= function(num) 
					if _G["AUI_Tactical_GroupFrame"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Group"].auiStyle = "AUI_Tactical_GroupFrame"
					elseif _G["TESO_GroupFrame"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Group"].auiStyle = "TESO_GroupFrame"
					else
						GRT.target["AUI"]["Group"].auiStyle = "AUI_GroupFrame"
					end
					return _G[GRT.target["AUI"]["Group"].auiStyle..num.."_Bar"] 
				end,
				texture = {
					Path			= function() return "AUI/images/attributes/aui/player/bar.dds" end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = true,
					Path			= "AUI/images/attributes/aui/player/bar_gloss.dds",
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					return _G[GRT.target["AUI"]["Group"].auiStyle..num].unitTag
				end,
			},
			["Raid"] = {
				auiStyle = nil,
				anchor	= function(num) 
					if _G["AUI_Tactical_RaidFramegroup"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Raid"].auiStyle = "AUI_Tactical_RaidFramegroup"
					elseif _G["TESO_RaidFramegroup"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Raid"].auiStyle = "TESO_RaidFramegroup"
					else
						GRT.target["AUI"]["Raid"].auiStyle = "AUI_RaidFramegroup"
					end
					return _G[GRT.target["AUI"]["Raid"].auiStyle..num.."_Bar"] 
				end,
				bar	= function(num) 
					if _G["AUI_Tactical_RaidFramegroup"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Raid"].auiStyle = "AUI_Tactical_RaidFramegroup"
					elseif _G["TESO_RaidFramegroup"..num.."_Bar"] ~= nil then
						GRT.target["AUI"]["Raid"].auiStyle = "TESO_RaidFramegroup"
					else
						GRT.target["AUI"]["Raid"].auiStyle = "AUI_RaidFramegroup"
					end
					return _G[GRT.target["AUI"]["Raid"].auiStyle..num.."_Bar"] 
				end,
				texture = {
					Path			= function() return "AUI/images/attributes/aui/player/bar.dds" end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = true,
					Path			= "AUI/images/attributes/aui/player/bar_gloss.dds",
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					return _G[GRT.target["AUI"]["Raid"].auiStyle..num].unitTag
				end,
			},
		},
		["LUI"]= {
			name = "LUI",
			enable = false,
			["Group"] = {
				anchor	= function(num) return LUIE.UnitFrames.CustomFrames["SmallGroup"..num].control end,
				bar			= function(num) return LUIE.UnitFrames.CustomFrames["SmallGroup"..num].control end,
				texture = {
--					Path			= "LuiExtended/media/unitframes/textures/Minimalistic.dds",
					Path			= function() return LUIE.StatusbarTextures[LUIE.UnitFrames.SV.CustomTexture] end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = true,
					Path			= nil,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					return LUIE.UnitFrames.CustomFrames["SmallGroup"..num].unitTag
				end,
			},
			["Raid"] = {
				anchor	= function(num) return LUIE.UnitFrames.CustomFrames["RaidGroup"..num].control end,
				bar			= function(num) return LUIE.UnitFrames.CustomFrames["RaidGroup"..num].control end,
				texture = {
					Path			= function() return nil end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = false,
					Path			= nil,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					return LUIE.UnitFrames.CustomFrames["RaidGroup"..num].unitTag
				end,
			},
		},
		["JO"] = {
			name = "JO",
			enable = false,
			["Group"] = {
				anchor	= function(num) return JoGroup.frame["group"..num] end,
				bar			= function(num) return JoGroup.frame["group"..num].bar end,
				texture = {
					Path			= function() return nil end,
					EdgePath	= nil,
					EdgeW			= 8,
					EdgeH			= 8,
				},
				textureGloss = {
					enable = true,
					Path			= "EsoUI/Art/Miscellaneous/timerBar_genericFill_gloss.dds",
					EdgePath	= nil,
					EdgeW			= 8,
					EdgeH			= 8,
				},
				shield = {
					enable = false,
					texture = {
						Path			= nil,
						EdgePath	= nil,
						EdgeW			= 8,
						EdgeH			= 8,
					},
					textureGloss = {
						enable = false,
						Path			= nil,
						EdgePath	= nil,
						EdgeW			= 8,
						EdgeH			= 8,
					},
				},
				getUnitTag	= function(num) 
					return "group"..num
				end,
			},
			["Raid"] = {
				anchor	= function(num) return JoGroup.frame["group"..num] end,
				bar			= function(num) return JoGroup.frame["group"..num].bar end,
				texture = {
					Path			= function() return nil end,
					EdgePath	= nil,
					EdgeW			= 8,
					EdgeH			= 8,
				},
				textureGloss = {
					enable = true,
					Path			= "EsoUI/Art/Miscellaneous/timerBar_genericFill_gloss.dds",
					EdgePath	= nil,
					EdgeW			= 8,
					EdgeH			= 8,
				},
				shield = {
					enable = false,
					texture = {
						Path			= nil,
						EdgePath	= nil,
						EdgeW			= 8,
						EdgeH			= 8,
					},
					textureGloss = {
						enable = false,
						Path			= nil,
						EdgePath	= nil,
						EdgeW			= 8,
						EdgeH			= 8,
					},
				},
				getUnitTag	= function(num) 
					return "group"..num
				end,
			},
		},

		["BUI"]= {
			name = "BUI",
			enable = false,
			["Group"] = {
				anchor	= function(num) return _G["BUI_RaidFrame"..num.."_Bar"] end,
				bar			= function(num) return _G["BUI_RaidFrame"..num.."_Bar"] end,
				texture = {
					Path			= function() return nil end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = false,
					Path			= nil,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					local unitTag
					for i = 1 , 4 do
						unitTag = "group"..i
						unitTag = GetGroupUnitTagByIndex(num)
						--if num == GetGroupIndexByUnitTag(unitTag) then
							--return unitTag
						--end
					end
					return unitTag
				end,
			},
			["Raid"] = {
				anchor	= function(num) return _G["BUI_RaidFrame"..num.."_Bar"] end,
				bar			= function(num) return _G["BUI_RaidFrame"..num.."_Bar"] end,
				texture = {
					Path			= function() return nil end,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				textureGloss = {
					enable = false,
					Path			= nil,
					EdgePath	= nil,
					EdgeW			= nil,
					EdgeH			= nil,
				},
				shield = {
					enable = false,
				},
				getUnitTag	= function(num) 
					local unitTag
					for i = 1 , 24 do
						unitTag = "group"..i
						unitTag = GetGroupUnitTagByIndex(num)
						--if num == GetGroupIndexByUnitTag(unitTag) then
							--return unitTag
						--end
					end
					return unitTag
				end,
			},
		},

	},
	Bar = {
		["Shield"] = {
			getValue = function(unitTag)
				return shieldValue(unitTag)
			end,
			abilityIds = {},
		},
		["Regen"] = {
			getValue = function(unitTag)
				return regenTime(unitTag)
			end,
			--abilityIds = { 61225,61224,46269,46268,46267,46266,46265,46264,46263,46262,46261,46260,46259,46257,45549,45548,43240,41269, 41270, 41271, 41272, 41273, 41274, 41276, 41278, 41280, 41281, 41283, 41285, 41286, 41288, 41290, 41291,},
			abilityIds = {8205,8926,26233,28536,28538,29639,31809,40076,40079,40081,40083,41269,41270,41271,41272,41274,41276,41278,41280,41281,41283,41285,41286,41288,41290,41291,43240,45548,45549,46257,46259,46260,46261,46262,46263,46264,46265,46266,46267,46268,46269,61224,61225,65967,67520,67534,67535,67536,68665,70581,71616,72384,80654,80655,80759,80760,81633,83538,87283,87284,87285,},
		},
		["SPC"] = {
			getValue = function(unitTag)
				return spcTime(unitTag)
			end,
			abilityIds = { 109966,66899, 66902,},
		},
		["CP"] = {
			getValue = function(unitTag)
				return cpTime(unitTag)
			end,
			abilityIds = {	62645,	62644,	62643,	61744, 62636, 62639, 62642, },
		},
		["Spear"] = {
			getValue = function(unitTag)
				return cpTime(unitTag)
			end,
			abilityIds = {	999999, },
		},
	},
}
GRT.SavedVar.Default = {
	bar = {
		["Shield"] = {
			enable = false,
			color1 = {0.8,0.2,0.2,1},
			color2 = {0.8,0.2,0.2,1},
			color1gloss = {1,1,1,0.0},
			color2gloss = {1,1,1,0.0},
		},
		["Regen"] = {
			enable = true,
			color1 = {0.70,0.70,0.15,1},
			color2 = {0.8,0.8,0.2,1},
			color1gloss = {1,1,1,0.0},
			color2gloss = {1,1,1,0.0},
		},
		["SPC"] = {
			enable = false,
			color1 = {1.00,0.05,0.90,1},
			color2 = {1.00,0.05,0.90,1},
			color1gloss = {1,1,1,0.0},
			color2gloss = {1,1,1,0.0},
		},
		["CP"] = {
			enable = false,
			color1 = {0.00,0.60,1.00,1},
			color2 = {0.00,0.60,1.00,1},
			color1gloss = {1,1,1,0.0},
			color2gloss = {1,1,1,0.0},
		},
		["Spear"] = {
			enable = false,
			color1 = {1,1,1,1},
			color2 = {1,1,1,1},
			color1gloss = {1,1,1,0.0},
			color2gloss = {1,1,1,0.0},
		},
	},
	barfreq = 100,
	barHeight = 8,
	barOffsetX = 0,
	barOffsetY = -2,
	after2ndBarOffsetY = -1,
}
local function detectFrame()
--ESO
	--if (_G["ZO_GroupUnitFramegroup1"] ~= nil) then
		GRT.target["ESO"].enable = true
	--end
--FTC
	if _G["FTC_GroupFrame"] ~= nil then GRT.target["FTC"].enable = true end
--AUI
	if _G[ "AUI_Attributes_Window_Group"] ~= nil then GRT.target["AUI"].enable = true end
--LUI
	if LUIE ~= nil then
		if LUIE.UnitFrames.CustomFrames["SmallGroup1"] ~= nil then GRT.target["LUI"].enable = true end
	end
--JoGroup
	if JoGroup ~= nil then GRT.target["JO"].enable = true end
--BUI
	if BUI ~= nil then GRT.target["BUI"].enable = true end

end
local function CreateUnitFrame()
	for addon, v001 in pairs(GRT.target) do
		if GRT.target[addon].enable then
			--グループフレーム用UIの作成
			for i = 1 , 4 do
				GRT.UI.CreateUnitFrame(GRT.target[addon].name,GRT.GROUP,i)
 			end
			--レイドフレーム用UIの作成
			for j = 1 , 24 do
				GRT.UI.CreateUnitFrame(GRT.target[addon].name,GRT.RAID,j)
			end
		end
	end
end
local function barUpdate()
	if not isInit then return end
	for addon, v001 in pairs(GRT.UI.frames) do
		if GRT.target[addon].enable then
			for groupSize, v002 in pairs(GRT.UI.frames[addon]) do
				for num, v003 in pairs(GRT.UI.frames[addon][groupSize]) do
					local unitTag = GRT.target[addon][groupSize].getUnitTag(num)
					GRT.UI.frames[addon][groupSize][num].unitTag = unitTag
					if DoesUnitExist(unitTag) then
						for barName, v004 in pairs(GRT.Bar) do
							local barEnable = GRT.SavedVar.savedVariables.bar[barName].enable or GRT.SavedVar.Default.bar[barName].enable
							if barEnable then
								if GRT.UI.frames[addon][groupSize][num].barBG[barName].endTime ~= 0 then
									local now = GetGameTimeMilliseconds()
									local beginTime = GRT.UI.frames[addon][groupSize][num].barBG[barName].startTime
									local endTime = GRT.UI.frames[addon][groupSize][num].barBG[barName].endTime
									local barValue = 100 - ((now/1000 - beginTime) / (endTime - beginTime) * 100)
									
									GRT.UI.frames[addon][groupSize][num].barBG[barName].bar:SetValue(barValue)
								end
							else
								GRT.UI.frames[addon][groupSize][num].barBG[barName].bar:SetValue(0)
							end
							if GRT.target[addon][groupSize].bar(num):IsHidden() then GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetHidden(true)
							else GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetHidden(false) end
							GRT.UI.BarAlign(addon,groupSize,num)
							GRT.UI.frames[addon][groupSize][num].text:SetText(GetUnitName(unitTag))
							GRT.UI.frames[addon][groupSize][num].text:SetHidden(not GRT.debug)
						end
					end
				end
			end
		end
	end
end
local function shieldValue(unitTag)
  local value, maxValue = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
  value = value or 0
  return value
end
local function OnUpdate()
	if not isInit then return end
	barUpdate()
end
local function OnShield(unitTag,value)
	if GetGroupSize() <= 4 then groupSize = "Group" else groupSize = "Raid" end
	for addon, v001 in pairs(GRT.UI.frames) do
		if GRT.target[addon].enable then
			for num, v003 in pairs(GRT.UI.frames[addon][groupSize]) do
				if GRT.UI.frames[addon][groupSize][num].unitTag == unitTag then
					local barEnable = GRT.SavedVar.savedVariables.bar["Shield"].enable or GRT.SavedVar.Default.bar["Shield"].enable
					if barEnable then
						local currentHp, maxHp, effectiveMaxHp = GetUnitPower(unitTag, POWERTYPE_HEALTH)
						GRT.UI.frames[addon][groupSize][num].barBG["Shield"].maxValue = maxHp
						value = value or 0
						value = (value / maxHp) * 100
						GRT.UI.frames[addon][groupSize][num].barBG["Shield"].bar:SetValue(value)
					else
						GRT.UI.frames[addon][groupSize][num].barBG["Shield"].bar:SetValue(0)
					end
					if GRT.target[addon][groupSize].bar(num):IsHidden() then GRT.UI.frames[addon][groupSize][num].barBG["Shield"]:SetHidden(true)
					else GRT.UI.frames[addon][groupSize][num].barBG["Shield"]:SetHidden(false) end
					GRT.UI.BarAlign(addon,groupSize,num)
					--DebugText
					GRT.UI.frames[addon][groupSize][num].text:SetText(GetUnitName(unitTag))
					GRT.UI.frames[addon][groupSize][num].text:SetHidden(not GRT.debug)
				end
			end
		end
	end
end
local function OnEffectChanged(eventCode,changeType,effectSlot,effectName,unitTag,beginTime,endTime,stackCount,iconName,buffType,effectType,abilityType,statusEffectType,unitName,unitId,abilityId,sourceUnitType)
	if string.match(unitTag,"group") == nil then return end
	if (abilityType == ABILITY_TYPE_DAMAGESHIELD)then
		OnShield(unitTag,shieldValue(unitTag))
		return
	end
	if GRT.debug then
		d("name:"..effectName)
		d("buffType:"..buffType)
		d("effectType:"..effectType)
		d("abilityType:"..abilityType)
		d("statusEffectType:"..statusEffectType)
		d("abilityId:"..abilityId)
	end
	local Spear = false
	if Spear then
		--return
	end
	if GetGroupSize() <= 4 then groupSize = "Group" else groupSize = "Raid" end
	for bn,value in pairs(GRT.Bar) do
		for id,value2 in ipairs(GRT.Bar[bn].abilityIds) do
			if value2 == abilityId then
				barName = bn
				for addon, v001 in pairs(GRT.UI.frames) do
					if GRT.target[addon].enable then
						for num, v003 in pairs(GRT.UI.frames[addon][groupSize]) do
							if GRT.UI.frames[addon][groupSize][num].unitTag == unitTag then
								local barEnable = GRT.SavedVar.savedVariables.bar[barName].enable or GRT.SavedVar.Default.bar[barName].enable
								if barEnable then
									local now = GetGameTimeMilliseconds()
									local barValue = 100 - ((now/1000 - beginTime) / (endTime - beginTime) * 100)
									GRT.UI.frames[addon][groupSize][num].barBG[barName].startTime = beginTime
									GRT.UI.frames[addon][groupSize][num].barBG[barName].endTime = endTime
									
									GRT.UI.frames[addon][groupSize][num].barBG[barName].bar:SetValue(barValue)
								else
									GRT.UI.frames[addon][groupSize][num].barBG[barName].bar:SetValue(0)
								end
								if GRT.target[addon][groupSize].bar(num):IsHidden() then GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetHidden(true)
								else GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetHidden(false) end
								GRT.UI.BarAlign(addon,groupSize,num)
								--DebugText
								GRT.UI.frames[addon][groupSize][num].text:SetText(GetUnitName(unitTag))
								GRT.UI.frames[addon][groupSize][num].text:SetHidden(not GRT.debug)
							end
						end
					end
				end
			end
		end
	end
end
local function OnUnitAttributeVisualAdded(eventCode,unitTag,unitAttributeVisual,statType,attributeType,powerType,value,maxValue)
	if not isInit then return end
	if unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
	if string.match(unitTag,"group") == nil then return end
	OnShield(unitTag,value)
end
local function OnUnitAttributeVisualUpdated(eventCode,unitTag,unitAttributeVisual,statType,attributeType,powerType,oldValue,newValue,oldMaxValue,newMaxValue)
	if not isInit then return end
	if unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
	if string.match(unitTag,"group") == nil then return end
	OnShield(unitTag,newValue)
end
local function OnUnitAttributeVisualRemoved(eventCode,unitTag,unitAttributeVisual,statType,attributeType,powerType,value,maxValue)
	if not isInit then return end
	if unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
	if string.match(unitTag,"group") == nil then return end
	OnShield(unitTag,value)
end
local function OnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,log,sourceUnitId,targetUnitId,abilityId)
end
local function OnPowerUpdate(eventCode,unitTag,powerIndex,powerType,powerValue,powerMax,powerEffectiveMax)
end
local function OnGroupUpdate()
	CreateUnitFrame()
	for addon, v001 in pairs(GRT.UI.frames) do
		for groupSize, v002 in pairs(GRT.UI.frames[addon]) do
			for num, v003 in pairs(GRT.UI.frames[addon][groupSize]) do
				if(GRT.UI.frames[addon][groupSize][num].barBG[barName] ~= nil) then
					GRT.UI.frames[addon][groupSize][num].unitTag = GRT.target[addon][groupSize].getUnitTag(num)
				end
			end
		end
	end
	GRT.UI.ReflectSetting()
end
local function eventRegister()
	EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_EFFECT_CHANGED, OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent(myAddonName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	--EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_COMBAT_EVENT, OnCombatEvent)
	--EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_POWER_UPDATE, OnPowerUpdate)

	--EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED  , OnUnitAttributeVisualAdded)
	--EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnUnitAttributeVisualUpdated)
	--EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnUnitAttributeVisualRemoved)
	--[[
		
		EVENT_MANAGER:AddFilterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
		EVENT_MANAGER:AddFilterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
		EVENT_MANAGER:AddFilterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
		EVENT_MANAGER:AddFilterForEvent(myAddonName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	--]]
		--[[
		for bn,value in pairs(GRT.Bar) do
			for id,value2 in ipairs(GRT.Bar[bn].abilityIds) do
				EVENT_MANAGER:AddFilterForEvent(myAddonName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, value2)
			end
		end
		--]]
	EVENT_MANAGER:RegisterForUpdate("grtUpdate", GRT.SavedVar.savedVariables.barfreq or GRT.SavedVar.Default.barfreq, OnUpdate)
	EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_GROUP_UPDATE, OnGroupUpdate)
	EVENT_MANAGER:RegisterForUpdate("grtUpdate2", 10000, OnGroupUpdate)
end
local function init( event, addon )
	if ( addon ~= myAddonName ) then return end
	GRT.SavedVar.savedVariables	 = ZO_SavedVars:NewAccountWide("GRTSavedVar", 4.3, nil, GRT.SavedVar.Default)
	GRT.CreateSettingsWindow()
	GRT.UI.MainAnchor = WINDOW_MANAGER:CreateTopLevelWindow("GRT_MainAnchor")
	detectFrame()
	CreateUnitFrame()
	GRT.UI.ReflectSetting()
	eventRegister()
	isInit = true
end
function GRT.EventRegisterUpdate()
	EVENT_MANAGER:UnregisterForUpdate("grtUpdate")
	EVENT_MANAGER:RegisterForUpdate("grtUpdate", GRT.SavedVar.savedVariables.barfreq or GRT.SavedVar.Default.barfreq , OnUpdate)
end
EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_ADD_ON_LOADED, init)
local function GRT_cmd(value)
	if(value == "test") then
		CreateUnitFrame()
	elseif(value == "off") then
		EVENT_MANAGER:UnregisterForUpdate("grtUpdate")
		EVENT_MANAGER:UnregisterForUpdate("grtUpdate2")
		EVENT_MANAGER:UnregisterForEvent(myAddonName, EVENT_GROUP_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(myAddonName, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
		EVENT_MANAGER:UnregisterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(myAddonName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
	elseif(value == "debug") then
		GRT.debug = not GRT.debug
		if GRT.debug then
			d("GRT: debug = true")
		else
			d("GRT: debug = false")
		end
	elseif(value == "aaa") then
		d(_G["ZO_PlayerAttribute"]:GetName())
		if(_G["ZO_PlayerAttribute"]:GetChildren() ~= nil) then
			for key, v0 in pairs(_G["ZO_PlayerAttribute"]:GetChildren()) do
			key = key or 0
			v0 = v0 or 0
				if(key ~= nil) then
					d("k:"..key)
				end
				if(v0 ~= nil) then
					d("v:"..v0)
				end
			end
		end
	end
end
SLASH_COMMANDS["/grt"] = GRT_cmd
