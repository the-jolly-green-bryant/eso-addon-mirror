function GS.Row(name, parent, offset, id, font, extended)
	if(name == nil or name == "" or id == nil) then return end
	
	local tag = "group"..id
	local row = {}
	
	local offsets = {0,0,0,0,0,0,0,0}
	for i = 1,#GS.savedVars.widths do
		for j = 1,i do
			offsets[i+1] = offsets[i+1] + GS.savedVars.widths[j]
		end
	end
	
	row = {
		cpLabel = GS.Label(name.."CPLabel", parent, "", {offset[1],offset[2]}, TOPLEFT, GS.savedVars.widths[1], font),
		allianceLabel = GS.Label(name.."AllianceLabel", parent, "", {offset[1]+offsets[2],offset[2]}, TOPLEFT, GS.savedVars.widths[2], font),
		raceLabel = GS.Label(name.."RaceLabel", parent, "", {offset[1]+offsets[3],offset[2]}, TOPLEFT, GS.savedVars.widths[3], font),
		rankLabel = GS.Label(name.."RankLabel", parent, "", {offset[1]+offsets[4],offset[2]}, TOPLEFT, GS.savedVars.widths[4], font),
		genderLabel = GS.Label(name.."GenderLabel", parent, "", {offset[1]+offsets[5],offset[2]}, TOPLEFT, GS.savedVars.widths[5], font),
		statusLabel = GS.StatusIndicator(name.."StatusLabel", parent, {offset[1]+offsets[6],offset[2]-2}, GS.savedVars.widths[6]/3),
		socialLabel = GS.Label(name.."SocialLabel", parent, "", {offset[1]+offsets[7],offset[2]}, TOPLEFT, GS.savedVars.widths[7], font),
		
		colour = "|c76bcc3",
		
		SetHidden = function (self, bool)
			if GS.savedVars.widths[1] ~= 0 then self.cpLabel:SetHidden(bool) end
			if GS.savedVars.widths[2] ~= 0 then self.allianceLabel:SetHidden(bool) end
			if GS.savedVars.widths[3] ~= 0 then self.raceLabel:SetHidden(bool) end
			if GS.savedVars.widths[4] ~= 0 then self.rankLabel:SetHidden(bool) end
			if GS.savedVars.widths[5] ~= 0 then self.genderLabel:SetHidden(bool) end
			if GS.savedVars.widths[6] ~= 0 then self.statusLabel:SetHidden(bool) end
			if GS.savedVars.widths[7] ~= 0 then self.socialLabel:SetHidden(bool) end
		end,
		
		SetOffline = function (self, bool)
			if bool == false then 
				colour = "|c76bcc3"
			else 
				colour = "|c666666" 
			end 
			if GS.savedVars.widths[1] ~= 0 then self.cpLabel:SetHidden(bool) end
			if GS.savedVars.widths[2] ~= 0 then self.allianceLabel:SetHidden(bool) end
			if GS.savedVars.widths[3] ~= 0 then self.raceLabel:SetHidden(bool) end
			if GS.savedVars.widths[4] ~= 0 then self.rankLabel:SetHidden(bool) end
			if GS.savedVars.widths[5] ~= 0 then self.genderLabel:SetHidden(bool) end
			if GS.savedVars.widths[6] ~= 0 then self.statusLabel:SetHidden(bool) end
			if GS.savedVars.widths[7] ~= 0 then self.socialLabel:SetHidden(bool) end
			self:SetText(colour)
		end,
		
		SetText = function (self, colour)
			local r, s = GetUnitAvARank(tag)
			local g = GetUnitGender(tag)
			local a = GetUnitAlliance(tag)
			local ss = ""
			if GetUnitName(tag) == GetUnitName("player") then ss = "Self"
			elseif IsUnitFriend(tag) == true then ss = "Friend"
			elseif IsUnitIgnored(tag) == true then ss = "Ignored"
			else ss = "Neutral" end
			if GS.savedVars.widths[1] ~= 0 then self.cpLabel:SetText(colour.."|t24:24:esoui/art/champion/champion_icon_32.dds|t"..GetUnitChampionPoints(tag)) end
			if GS.savedVars.widths[2] ~= 0 then 
				self.allianceLabel:SetText(colour..GS.alliances[a]) 
				self.allianceLabel:SetHandler("OnMouseEnter", function(self, ...)
					InitializeTooltip(InformationTooltip, self, TOP, -10, -50, TOP)
					SetTooltipText(InformationTooltip, GS.allianceNames[a])
				end)
				self.allianceLabel:SetHandler("OnMouseExit", function(self, ...) 
					ClearTooltip(InformationTooltip)
				end)
			end
			if GS.savedVars.widths[3] ~= 0 then self.raceLabel:SetText(colour..GetUnitRace(tag)) end
			if GS.savedVars.widths[4] ~= 0 then 
				self.rankLabel:SetText(colour.."|t24:24:"..GetAvARankIcon(r).."|t")
				self.rankLabel:SetHandler("OnMouseEnter", function(self, ...)
					InitializeTooltip(InformationTooltip, self, TOP, -10, -50, TOP)
					SetTooltipText(InformationTooltip, GetAvARankName(g, r))
				end)
				self.rankLabel:SetHandler("OnMouseExit", function(self, ...) 
					ClearTooltip(InformationTooltip)
				end)
			end
			if GS.savedVars.widths[5] ~= 0 then self.genderLabel:SetText(colour..(GS.genders[g] or "")) end
			if GS.savedVars.widths[6] ~= 0 then self.statusLabel:SetTextures(IsUnitInCombat(tag), IsUnitDead(tag), IsUnitInGroupSupportRange(tag)) end
			if GS.savedVars.widths[7] ~= 0 then self.socialLabel:SetText(colour..ss) end

		end,
	}
    return row
end

function GS.TitleRow(name, parent, offset, font, extended)
	if(name == nil or name == "") then return end
	local c = "|cc5c29e"
	local row = {}

	local offsets = {0,0,0,0,0,0,0,0}
	for i = 1,#GS.savedVars.widths do
		for j = 1,i do
			offsets[i+1] = offsets[i+1] + GS.savedVars.widths[j]
		end
	end
	
	row = {
		cpLabel = GS.Label(name.."CPLabel", parent, "CP", {offset[1],offset[2]}, TOPLEFT, GS.savedVars.widths[1], font),
		allianceLabel = GS.Label(name.."AllianceLabel", parent, "ALL.", {offset[1]+offsets[2],offset[2]}, TOPLEFT, GS.savedVars.widths[2], font),
		raceLabel = GS.Label(name.."RaceLabel", parent, "RACE", {offset[1]+offsets[3],offset[2]}, TOPLEFT, GS.savedVars.widths[3], font),
		rankLabel = GS.Label(name.."RankLabel", parent, "RANK", {offset[1]+offsets[4],offset[2]}, TOPLEFT, GS.savedVars.widths[4], font),
		genderLabel = GS.Label(name.."GenderLabel", parent, "GENDER", {offset[1]+offsets[5],offset[2]}, TOPLEFT, GS.savedVars.widths[5], font),
		statusLabel = GS.Label(name.."StatusLabel", parent, "STATUS", {offset[1]+offsets[6],offset[2]}, TOPLEFT, GS.savedVars.widths[6], font),
		socialLabel = GS.Label(name.."SocialLabel", parent, "SOCIAL", {offset[1]+offsets[7],offset[2]}, TOPLEFT, GS.savedVars.widths[7], font),
		
		SetHidden = function (self, bool)
			if GS.savedVars.widths[1] ~= 0 then self.cpLabel:SetHidden(bool) end
			if GS.savedVars.widths[2] ~= 0 then self.allianceLabel:SetHidden(bool) end
			if GS.savedVars.widths[3] ~= 0 then self.raceLabel:SetHidden(bool) end
			if GS.savedVars.widths[4] ~= 0 then self.rankLabel:SetHidden(bool) end
			if GS.savedVars.widths[5] ~= 0 then self.genderLabel:SetHidden(bool) end
			if GS.savedVars.widths[6] ~= 0 then self.statusLabel:SetHidden(bool) end
			if GS.savedVars.widths[7] ~= 0 then self.socialLabel:SetHidden(bool) end
		end,
		
		SetGrouped = function (self, bool)
			if bool == false then c = "|c666666" else c = "|cc5c29e" end
			self:SetText()
		end,
		
		SetText = function (self)
			if GS.savedVars.widths[1] ~= 0 then self.cpLabel:SetText(c.."CP") end
			if GS.savedVars.widths[2] ~= 0 then self.allianceLabel:SetText(c.."ALL.") end
			if GS.savedVars.widths[3] ~= 0 then self.raceLabel:SetText(c.."RACE") end
			if GS.savedVars.widths[4] ~= 0 then self.rankLabel:SetText(c.."RANK") end
			if GS.savedVars.widths[5] ~= 0 then self.genderLabel:SetText(c.."GENDER") end
			if GS.savedVars.widths[6] ~= 0 then self.statusLabel:SetText(c.."STATUS") end
			if GS.savedVars.widths[7] ~= 0 then self.socialLabel:SetText(c.."SOCIAL") end
		end,
		
	}
    return row
end

function GS.StatusIndicator(name, parent, offset, size)
	if (name == nil or name == "") then return end
	local indicator = {
		combatTexture = GS.Texture(name.."CombatTexture", parent, {offset[1], offset[2]+2}, TOPLEFT, size, size),
		deadTexture = GS.Texture(name.."DeadTexture", parent, {offset[1]+size+2, offset[2]}, TOPLEFT, size, size+4),
		supportTexture = GS.Texture(name.."SupportTexture", parent, {offset[1]+2*size+4, offset[2]+2}, TOPLEFT, size, size),
		
		SetHidden = function (self, bool)
			self.combatTexture:SetHidden(bool)
			self.deadTexture:SetHidden(bool)
			self.supportTexture:SetHidden(bool)
		end,
		
		SetTextures = function (self, combat, dead, support)
			local s1, s2, s3, t1, t2, t3
			if combat == true then 
				t1 = GS.stateTextures[1][1]
				s1 = GS.states[1][1]
			else 
				t1 = GS.stateTextures[1][2]
				s1 = GS.states[1][2]
			end
			if dead == true then 
				t2 = GS.stateTextures[2][1]
				s2 = GS.states[2][1]
			else 
				t2 = GS.stateTextures[2][2]
				s2 = GS.states[2][2]
			end
			if support == true then 
				t3 = GS.stateTextures[3][1]
				s3 = GS.states[3][1]
			else 
				t3 = GS.stateTextures[3][2]
				s3 = GS.states[3][2]
			end
			self.combatTexture:SetTexture(t1)
			self.deadTexture:SetTexture(t2)
			self.supportTexture:SetTexture(t3)
			
			self.combatTexture:SetHandler("OnMouseEnter", function(self, ...)
				InitializeTooltip(InformationTooltip, self, TOP, -10, -50, TOP)
				SetTooltipText(InformationTooltip, s1)
			end)
			self.combatTexture:SetHandler("OnMouseExit", function(self, ...) 
				ClearTooltip(InformationTooltip)
			end)
			
			self.deadTexture:SetHandler("OnMouseEnter", function(self, ...)
				InitializeTooltip(InformationTooltip, self, TOP, -10, -50, TOP)
				SetTooltipText(InformationTooltip, s2)
			end)
			self.deadTexture:SetHandler("OnMouseExit", function(self, ...) 
				ClearTooltip(InformationTooltip)
			end)
			
			self.supportTexture:SetHandler("OnMouseEnter", function(self, ...)
				InitializeTooltip(InformationTooltip, self, TOP, -10, -50, TOP)
				SetTooltipText(InformationTooltip, s3)
			end)
			self.supportTexture:SetHandler("OnMouseExit", function(self, ...) 
				ClearTooltip(InformationTooltip)
			end)
		end,
	}
	
	return indicator
end

function GS.Label(name, parent, text, offset, anchor, width, font)
    if (name == nil or name == "") then return end
	if width == 0 then return end
    local label = _G[name]
    if (label == nil) then label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL) end
    label:ClearAnchors()
	label:SetHorizontalAlignment(1)
    label:SetAnchor( anchor, parent, anchor, offset[1], offset[2])
	label:SetDimensions(width,24)
	label:SetFont(font)
	label:SetText(text)
    label:SetHidden(false)
	label:SetDrawLayer(2)
	label:SetMouseEnabled(true)
    return label
end

function GS.Texture(name, parent, offset, anchor, width, height, texture)
	if (name == nil or name == "") then return end
    local texture = _G[name]
	if (texture == nil) then texture = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE) end
    texture:ClearAnchors()
    texture:SetAnchor( anchor, parent, anchor, offset[1], offset[2])
	texture:SetDimensions(width,height)
    texture:SetHidden(false)
	texture:SetDrawLayer(3)
	texture:SetMouseEnabled(true)
    return texture
end