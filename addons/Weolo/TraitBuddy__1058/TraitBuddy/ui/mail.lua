local sf = string.format

TB_Mail = ZO_Object:Subclass()

function TB_Mail:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Mail:Initialize()
	self.scene = "mailSend"
	self.scene_gamepad = "mailManagerGamepad"
end

function TB_Mail:Compose(craftingSkillType, researchLineIndex, known)
	local c = TraitBuddy.ui.selector:GetSelectedCharacter()
	if c then
		if IsInGamepadPreferredMode() then
			MAIL_MANAGER_GAMEPAD:GetSend():ComposeMailTo("")
			SCENE_MANAGER:CallWhen(self.scene_gamepad, SCENE_SHOWN, function() self:GetTraitsBody(c, craftingSkillType, researchLineIndex, known) end)
		else
			if self:IsSceneShowing() then
				self:GetTraitsBody(c, craftingSkillType, researchLineIndex, known)
			else
				MAIL_SEND:ComposeMailTo("")
				SCENE_MANAGER:CallWhen(self.scene, SCENE_SHOWN, function() self:GetTraitsBody(c, craftingSkillType, researchLineIndex, known) end)
			end
		end
	end
end

function TB_Mail:IsSceneShowing()
	if IsInGamepadPreferredMode() then
		return SCENE_MANAGER:IsShowing(self.scene_gamepad)
	else
		return SCENE_MANAGER:IsShowing(self.scene)
	end
end

function TB_Mail:GetTraitsBody(c, craftingSkillType, researchLineIndex, known)
	local body = ""
	local name, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
	for traitIndex = 1, numTraits do
		if not TraitBuddy:IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
			if c.research[craftingSkillType][researchLineIndex][traitIndex] == known then
				--I want name like Jack - Sturdy and then a link
				local traitType, _, _ = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
				body = sf("%s%s - %s\n", body, name, GetString("SI_ITEMTRAITTYPE", traitType))
			end
		end
	end
	self:SetBody(body)
end

function TB_Mail:SetBody(body)
	local bodyField
	if IsInGamepadPreferredMode() then
		--ZO_MailManager_GamepadSendRightPaneContainerMailViewBody
		--ZO_MailManager_Gamepad:GetNamedChild("Send"):GetNamedChild("RightPane"):GetNamedChild("Container"):GetNamedChild("MailView"):GetNamedChild("Body")
		bodyField = MAIL_MANAGER_GAMEPAD:GetSend().mailView.bodyEdit.edit
		body = sf("%s%s", bodyField:GetText(), body)
	else
		--ZO_MailSend:GetNamedChild("Body"):GetNamedChild("Field")
		bodyField = ZO_MailSendBodyField
		body = sf("%s%s", bodyField:GetText(), body)
		
	end
	bodyField:SetText(body)
end
