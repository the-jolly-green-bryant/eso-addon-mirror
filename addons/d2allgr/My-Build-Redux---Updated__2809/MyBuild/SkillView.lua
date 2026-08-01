-- added by tenderlunar_yp 

MyBuild.SkillView = {}

function MyBuild.SkillView:Create(parent)
  self.box = MyBuild.UI2.Box(parent, 400, 200)
  self.box:SetAnchor(TOP, parent, TOP, 170, 65)
	
	sizepic = 25
	sizedelta = 30
	
	self.mainhandSkills = {}
	self.offhandSkills = {}
  for i = 1, 6, 1
  do
    self.mainhandSkills[i] = MyBuild.UI2.Texture(self.box, sizepic, sizepic)
    self.mainhandSkills[i]:SetMouseEnabled(true)
    self.mainhandSkills[i].tooltipText = ""
    self.mainhandSkills[i]:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, BOTTOM, self.tooltipText)
    end)
 
    self.mainhandSkills[i]:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)
    self.offhandSkills[i] = MyBuild.UI2.Texture(self.box, sizepic, sizepic)
    self.offhandSkills[i]:SetMouseEnabled(true)
    self.offhandSkills[i].tooltipText = ""
    self.offhandSkills[i]:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, BOTTOM, self.tooltipText)
    end)
 
    self.offhandSkills[i]:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)
  end
  
  self.mainhandSkills[1]:SetAnchor(TOP, self.box, TOP, 0, -sizedelta)
  self.mainhandSkills[2]:SetAnchor(TOP, self.box, TOP, sizedelta, -sizedelta)
  self.mainhandSkills[3]:SetAnchor(TOP, self.box, TOP, sizedelta * 2, -sizedelta)
  self.mainhandSkills[4]:SetAnchor(TOP, self.box, TOP, sizedelta * 3, -sizedelta)
  self.mainhandSkills[5]:SetAnchor(TOP, self.box, TOP, sizedelta * 4, -sizedelta)
  self.mainhandSkills[6]:SetAnchor(TOP, self.box, TOP, sizedelta * 5 + 15, -sizedelta)
	self.offhandSkills[1]:SetAnchor(TOP, self.box, TOP, 0, 0)
  self.offhandSkills[2]:SetAnchor(TOP, self.box, TOP, sizedelta, 0)
  self.offhandSkills[3]:SetAnchor(TOP, self.box, TOP, sizedelta * 2, 0)
  self.offhandSkills[4]:SetAnchor(TOP, self.box, TOP, sizedelta * 3, 0)
  self.offhandSkills[5]:SetAnchor(TOP, self.box, TOP, sizedelta * 4, 0)
  self.offhandSkills[6]:SetAnchor(TOP, self.box, TOP, sizedelta * 5 + 15, 0)
end

function MyBuild.SkillView:UpdateCharacterInfo(char)
	local function SetTexture(control, abilityId)
	  if type(abilityId) == "number" and abilityId ~= 0 then
      control:SetTexture(GetAbilityIcon(abilityId))
      control:SetHidden(false)
      control.tooltipText = GetAbilityName(abilityId)
    elseif type(abilityId) == "string" and abilityId ~= "" then
      control:SetTexture(abilityId)
      control:SetHidden(false)
      control.tooltipText = ""
    else
      control:SetHidden(true)
      control.tooltipText = ""
    end
	end
	for i = 1, 6, 1
	do
    SetTexture(self.mainhandSkills[i], GetSlotBoundId(2 + i, HOTBAR_CATEGORY_PRIMARY))
    SetTexture(self.offhandSkills[i], GetSlotBoundId(2 + i, HOTBAR_CATEGORY_BACKUP))
	end
end