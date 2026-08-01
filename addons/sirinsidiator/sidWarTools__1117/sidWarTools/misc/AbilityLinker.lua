local function Initialize(saveData)
	if(saveData.abilityLinkMenuEntries) then
		local L = sidWarTools.Localization
		local LAT = LibStub("LibAbilityTooltip")

		local function AddLinkToChat(abilityId)
			local link = LAT:CreateAbilityLink(abilityId, LINK_STYLE_BRACKETS)
			if(IsShiftKeyDown()) then
				link = CHAT_SYSTEM.textEntry:GetText() .. link
			end
			StartChatInput(link)
		end

		local function AppendLinkToChatMenuEntry(abilityId)
			AddCustomMenuItem(L["LINK_TO_CHAT"], function()
				AddLinkToChat(abilityId)
			end)
		end

		local originalZO_Skills_AbilitySlot_OnClick = ZO_Skills_AbilitySlot_OnClick
		ZO_Skills_AbilitySlot_OnClick = function(control)
			originalZO_Skills_AbilitySlot_OnClick(control)
			local ability = control.ability
			if not (ability.purchased and not ability.passive) then
				ClearMenu()
			end
			local abilityId = GetSkillAbilityId(control.skillType, control.lineIndex, control.index)
			AppendLinkToChatMenuEntry(abilityId)
			ShowMenu(control)
		end

		-- inject the modified right click handler in a way that does not break skill drag and drop
		local originalShowMenu = ShowMenu
		local function fakeShowMenu(abilitySlot)
			AppendLinkToChatMenuEntry(abilitySlot.actionId)
			originalShowMenu(abilitySlot)
		end

		local originalRunClickHandlers = RunClickHandlers
		function RunClickHandlers(AbilityClicked)
			local handlers = AbilityClicked[ABILITY_SLOT_TYPE_ACTIONBAR][MOUSE_BUTTON_INDEX_RIGHT]
			local originalRightClickHandler = handlers[1]
			handlers[1] = function(...)
				ShowMenu = fakeShowMenu
				local result = originalRightClickHandler(...)
				ShowMenu = originalShowMenu
				return result
			end
		end
		ZO_AbilitySlot_OnSlotClicked()
		RunClickHandlers = originalRunClickHandlers
	end
end
sidWarTools.InitializeAbilityLinkMenuEntries = Initialize
