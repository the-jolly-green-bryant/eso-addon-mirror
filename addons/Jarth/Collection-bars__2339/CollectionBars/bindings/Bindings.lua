--[[
Author: Jarth
Filename: Bindings.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function CBs_ShowSettings()
	base:ToggleEnableSettings(base.ShowSettings())
end

function CBs_Clicked(keyId)
	base:Debug("CBs_Clicked", keyId)

	local control = base.WM:GetMouseOverControl()
	local existingCollectibleId = base.Saved.Bindings[keyId]

	if control ~= nil and control.CBs then
		local targetCollectibleId = control:GetId()

		if existingCollectibleId ~= targetCollectibleId then
			local existingTargetBinding = base.Global.ReverseBindings[targetCollectibleId]
			if existingTargetBinding ~= nil then
				base.Saved.Bindings[existingTargetBinding] = nil
				base.Global.ReverseBindings[targetCollectibleId] = nil
			end

			if existingCollectibleId ~= nil then
				local existingSourceBinding = base.Global.ReverseBindings[existingCollectibleId]
				if existingSourceBinding ~= nil then
					base.Saved.Bindings[existingSourceBinding] = nil
					base.Global.ReverseBindings[existingCollectibleId] = nil
					base:SetBindingText(existingCollectibleId)
				end
			end

			base.Saved.Bindings[keyId] = targetCollectibleId
			base.Global.ReverseBindings[targetCollectibleId] = keyId
			base:SetBindingText(targetCollectibleId)
		end
	elseif existingCollectibleId ~= nil and existingCollectibleId > 0 then
		if base.AllButtons[existingCollectibleId] then
			base:Activate(base.AllButtons[existingCollectibleId])
		else
			UseCollectible(existingCollectibleId)
		end
	end
end

function base:SetBindingText(cid)
	base:Debug("SetBindingText", cid)

	if base.AllButtons[cid] then
		base.AllButtons[cid]:SetBindingText(base.Saved.Bindings.Show, cid)
	end
end

function base:InitializeBindings()
	base:Debug("InitializeBindings", base.Saved.Bindings.Number)

	ZO_CreateStringId(string.format(texts.FormatBindingName, "Settings"), "Settings")

	for key = 1, base.Saved.Bindings.Number do
		ZO_CreateStringId(string.format(texts.FormatBindingName, key), string.format(texts.FormatAbbreviationLowDash, key))

		local collectibleId = base.Saved.Bindings[key]
		if collectibleId ~= nil and collectibleId > 0 then
			base.Global.ReverseBindings[collectibleId] = key
		end
	end
end
