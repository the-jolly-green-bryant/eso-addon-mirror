--[[
Author: Jarth
Filename: Buttons.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function base:Activate(button)
	base:Debug("Activate", button)

	if base:IsCollectibleUsable(button) then
		if button and base.Saved.Button.IsActiveActivationEnabled then
			local category = base.Categories[button.categoryId]
			local formatCategoryEvent = string.format(texts.FormatAbbreviation .. "%%s", category.Name)
			local activeEventName = string.format(formatCategoryEvent, tostring(category.EventTS))
			EVENT_MANAGER:UnregisterForEvent(activeEventName, EVENT_COLLECTIBLE_USE_RESULT)
			category.EventTS = GetTimeStamp()
			EVENT_MANAGER:RegisterForEvent(activeEventName, EVENT_COLLECTIBLE_USE_RESULT, function(_, result, isAttemptingActivation)
				local countDown = category.Cooldown
				local success = false

				if result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED and button.button then
					success = true
					countDown.CollectibleId = button.cId
					base:UpdateButtonsState(category, button.cId, isAttemptingActivation)
				end

				local successActivate = isAttemptingActivation and success
				countDown.StartTime = GetFrameTimeMilliseconds()

				EVENT_MANAGER:UnregisterForEvent(activeEventName, EVENT_COLLECTIBLE_USE_RESULT)

				if success then
					local countDownEvent = string.format(formatCategoryEvent, countDown.Event)
					EVENT_MANAGER:UnregisterForUpdate(countDownEvent)
					EVENT_MANAGER:RegisterForUpdate(countDownEvent, countDown.Tick, function()
						local remaining, duration = GetCollectibleCooldownAndDuration(countDown.CollectibleId)
						local cooldown = base:GetCooldownText(countDown, duration)

						base:UpdateButtonsCooldown(category, remaining, duration, cooldown)

						if duration == 0 then
							countDown.StartTime = nil
							local isActive = successActivate or IsCollectibleActive(button.cId)
							base:UpdateButtonsState(category, button.cId, isActive)
							EVENT_MANAGER:UnregisterForUpdate(countDownEvent)
						end
					end)
				end
			end)
		end

		button:UpdateUsable()
		button:OnClicked()
	end
end

function base:SetFrameAndCombineSize(category)
	base:Debug("SetFrameAndCombineSize", category)
	local width, height = base:GetBarWidthHeight(category)
	base:SetFrameSizeIfExists(category.Frames.Frame, width, height)

	if category.Saved.Bar.IsCombined and not category.Saved.Bar.HideAll then
		base:SetFrameSizeIfExists(base.Global.Combine.Frames.Frame, width, height)
	end
end

function base:GetFrame(name, virtual)
	base:Debug("GetFrame", name, virtual)

	local frame = GetControl(name)

	if frame == nil then
		frame = base.WM:CreateControlFromVirtual(name, GuiRoot, virtual)
	end

	base:Debug("GetFrame:return", frame)

	return frame
end

function base:GetButtonPosition(category, index)
	category.Bar.Depth, category.Bar.Width = base:GetMaxBarSize(category, "Depth", index), base:GetMaxBarSize(category, "Width", index)

	base:Debug("GetButtonPosition", category, index, category.Bar.Depth, base.Saved.Button.Size)

	local left = ((index - 1) % category.Bar.Depth) * base.Saved.Button.Size
	local top = (zo_floor((index - 1) / category.Bar.Depth)) * base.Saved.Button.Size

	base:Debug("GetButtonPosition", category.Name, index, left, top)

	if not category.Saved.Bar.Horizontal then
		return top, left
	else
		return left, top
	end
end

function base:SetupButtons(category)
	base:Debug("SetupButtons", category, category.Name, category.Bar.Depth, category.Bar.Width)

	local index = 1
	local autoSelectAll = category.Saved.AutoSelectAll
	local selected = category.Saved.Selected
	local frame = category.Frames.Frame
	local maxIndex = (category.Bar.Depth or 0) * (category.Bar.Width or 0)

	category.IsEmpty = true

	for _, _value in ipairs(category.CollectionOrdered) do
		local hideButton = true

		if category.Saved.Enabled and (autoSelectAll or selected[_value.Id]) and IsCollectibleUnlocked(_value.Id) and IsCollectibleValidForPlayer(_value.Id) then
			if category.Buttons[_value.Id] == nil then
				category.Buttons[_value.Id] = CBs_Button:New(category.Id, frame, _value.Id)
				base.AllButtons[_value.Id] = category.Buttons[_value.Id]
			end

			if not category.Saved.Bar.HideAll and (maxIndex == 0 or index <= maxIndex) then
				hideButton = false

				category.Buttons[_value.Id]:SetBindingText(base.Saved.Bindings.Show, _value.Id)
				category.Buttons[_value.Id]:Setup()
				category.Buttons[_value.Id]:UpdateAnchor(frame, base:GetButtonPosition(category, index))
				category.Buttons[_value.Id]:UpdatePlaySounds(base.Saved.Button.IsAudioEnabled)
				index = index + 1
			end

			category.IsEmpty = false
		end

		if category.Buttons[_value.Id] ~= nil then
			category.Buttons[_value.Id]:SetHidden(hideButton)

			if not hideButton then
				category.Buttons[_value.Id]:SetSize(base.Saved.Button.Size)
				category.Buttons[_value.Id]:UpdateState(nil, nil, base.Saved.Button.IsActiveActivationEnabled)
			end
		end
	end

	local isHidden = (category.IsEmpty or not category.Saved.Label.Show) and not base.Global.EnableSettings or not category.Saved.Enabled

	if category.Frames.Frame then
		category.Frames.Frame:SetHidden(isHidden)
	end

	if category.Frames.Label then
		category.Frames.Label:SetHidden(isHidden)
	end
end

function base:UpdateButtonsState(category, forceId, isAttemptingActivation)
	base:Debug("UpdateButtonsState", category, forceId, isAttemptingActivation)

	for _, button in pairs(category.Buttons) do
		if button ~= nil then
			button:UpdateState(forceId, isAttemptingActivation, base.Saved.Button.IsActiveActivationEnabled)
		end
	end
end

function base:UpdateButtonsCooldown(category, remaining, duration, cooldown)
	base:Debug("UpdateButtonsCooldown", category, remaining, duration, cooldown)

	for _cId, button in pairs(category.Buttons) do
		if button ~= nil and category.Collection[_cId] then
			button:UpdateCooldown(remaining, duration, cooldown)
		end
	end
end

function base:GetCooldownText(countDown, duration)
	base:Debug("GetCooldownText", countDown, duration)

	local cooldown = ""

	if type(duration) == "number" and countDown.StartTime ~= nil then
		local startTime = countDown.StartTime or 0
		local secondsRemaining = zo_max(startTime + duration - GetFrameTimeMilliseconds(), 0) / 1000
		cooldown = ZO_FormatTimeAsDecimalWhenBelowThreshold(secondsRemaining, 60)
	end

	return cooldown
end

function base:IsCollectibleUsable(button)
	base:Debug("IsCollectibleUsable", button)

	local category = base.Categories[button.categoryId]
	local isCollectibleUsable = button ~= nil and category.Cooldown.StartTime == nil and IsCollectibleUsable(button.cId)

	if not isCollectibleUsable and button.cId then
		local startTime = category.Cooldown.StartTime or 0
		local _, duration = GetCollectibleCooldownAndDuration(button.cId)
		isCollectibleUsable = startTime + duration < GetFrameTimeMilliseconds()
	end

	return isCollectibleUsable
end
