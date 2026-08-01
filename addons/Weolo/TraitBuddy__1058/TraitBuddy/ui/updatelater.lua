--Update later logic for events which cant fire off now
local sf = string.format

TB_UpdateLater = ZO_Object:Subclass()

function TB_UpdateLater:New()
    local object = ZO_Object.New(self)
    object:Initialize()
    return object
end

function TB_UpdateLater:Initialize()
    self.updateui = {}
	self.isUpdating = false
	self.updatemotifui = false
	self.updateresearchui = false
	self.deletecharacter = {}
	self.researchCompleted = {}
	self.nonCombatBonus = {}
	self.updateResearching = false
end

function TB_UpdateLater:IsUpdating()
	return self.isUpdating
end

function TB_UpdateLater:UpdateUI(craftingSkillType)
    if self.updateui[craftingSkillType] then return end
	self.updateui[craftingSkillType] = {craftingSkillType=craftingSkillType}
end

function TB_UpdateLater:UpdateMotifUI()
	self.updatemotifui = true
end

function TB_UpdateLater:UpdateResearchUI()
	self.updateresearchui = true
end

function TB_UpdateLater:DeleteCharacter(id)
    if self.deletecharacter[id] then return end
	self.deletecharacter[id] = {id=id}
end

function TB_UpdateLater:ResearchCompleted(craftingSkillType, researchLineIndex, traitIndex)
	local id = sf("c%dr%dt%d", craftingSkillType, researchLineIndex, traitIndex)
    if self.researchCompleted[id] then return end
	self.researchCompleted[id] = {craftingSkillType=craftingSkillType, researchLineIndex=researchLineIndex, traitIndex=traitIndex}
	self:UpdateResearchUI()
	self:UpdateUI(craftingSkillType)
	self:UpdateResearching()
end

function TB_UpdateLater:NonCombatBonusChanged(craftingSkillType)
    if self.nonCombatBonus[craftingSkillType] then return end
	self.nonCombatBonus[craftingSkillType] = true
	self:UpdateResearching()
	self:UpdateResearchUI()
	self:UpdateUI(craftingSkillType)
end

function TB_UpdateLater:UpdateResearching()
	if self.updateResearching then return end
	self.updateResearching = true
end

function TB_UpdateLater:CheckCompletedEarlier()
	local c = TraitBuddy:GetCharacter(TraitBuddy.characterId)
	if c then
		if c.completed then
			for k,v in pairs(c.completed) do
				self:ResearchCompleted(v.craftingSkillType, v.researchLineIndex, v.traitIndex)
			end
			c.completed = nil
		end
	end
end

function TB_UpdateLater:Update()
	if TraitBuddy.ui:IsCreated() then
		self.isUpdating = true
		for k,v in pairs(self.deletecharacter) do
			TraitBuddy:DeleteCharacter(v.id)
			self.deletecharacter[k] = nil
		end
		for k,v in pairs(self.researchCompleted) do
			TraitBuddy:ResearchCompleted(v.craftingSkillType, v.researchLineIndex, v.traitIndex)
			self.researchCompleted[k] = nil
		end
		for k,v in pairs(self.updateui) do
			TraitBuddy.ui:UpdateUI(v.craftingSkillType)
			self.updateui[k] = nil
		end
		if self.updateResearching then
			TraitBuddy:UpdateResearching()
			self.updateResearching = false
		end
		for k,v in pairs(self.nonCombatBonus) do
			TraitBuddy.ui:UpdateCurrentMaxSimultaneousResearch(v.craftingSkillType)
			self.nonCombatBonus[k] = nil
		end
		if self.updatemotifui then
			TraitBuddy.ui.motifs:UpdateUI()
			self.updatemotifui = false
		end
		if self.updateresearchui then
			TraitBuddy.ui.research:UpdateUI()
			self.updateresearchui = false
		end
		self.isUpdating = false
	end
end
