--[[
Author: Jarth
Filename: MoveFrame.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function base:GetMoveFrameSnapPosition(frame, positionTargetXY, snapSize)
	base:Verbose("GetMoveFrameSnapPosition", frame, positionTargetXY, snapSize)
	local left, top = frame:GetLeft(), frame:GetTop()
	local width, height = frame:GetWidth(), frame:GetHeight()
	local x, y = left, top

	if positionTargetXY == LEFT or positionTargetXY == CENTER or positionTargetXY == RIGHT then
		y = top + height / 2
	elseif positionTargetXY == BOTTOMLEFT or positionTargetXY == BOTTOM or positionTargetXY == BOTTOMRIGHT then
		y = top + height
	end

	if positionTargetXY == TOP or positionTargetXY == CENTER or positionTargetXY == BOTTOM then
		x = left + width / 2
	elseif positionTargetXY == TOPRIGHT or positionTargetXY == RIGHT or positionTargetXY == BOTTOMRIGHT then
		x = left + width
	end

	return (zo_round(x / snapSize) * snapSize), (zo_round(y / snapSize) * snapSize)
end

function base:UpdateMoveFrame(category)
	base:Debug("UpdateMoveFrame", category)
	local moveFrame = category.Frames.Move
	local targetFrame = category.Frames.Frame
	local onMouseEnter, onMouseExit, onMouseDown, onMouseUp = nil, nil, nil, nil

	if base.Global.IsMoveEnabled and (category.Name == "Combine" or not category.IsEmpty and not category.Saved.Bar.IsCombined) then
		moveFrame = base:GetOrCreateMoveFrame(targetFrame, category)

		onMouseEnter = function(frame)
			frame.MoveFrameUpdateText(frame, true)
		end
		onMouseExit = function(frame)
			frame.MoveFrameUpdateText(frame, false)
		end
		onMouseDown = function(frame)
			frame:SetHandler("OnUpdate", frame.MoveFrameOnUpdate)
		end
		onMouseUp = function(frame)
			local saved = frame.category.Saved
			frame.MoveFrameOnUpdate(frame)
			frame.MoveFrameUpdateText(frame, false)
			frame:SetHandler("OnUpdate", nil)
			saved.Bar.Offset.X, saved.Bar.Offset.Y = base:GetMoveFrameSnapPosition(frame, category.Saved.Label.PositionTarget, frame.Saved.Bar.SnapSize)
		end
	end

	if moveFrame then
		moveFrame:SetHandler("OnMouseEnter", onMouseEnter)
		moveFrame:SetHandler("OnMouseExit", onMouseExit)
		moveFrame:SetHandler("OnMouseDown", onMouseDown)
		moveFrame:SetHandler("OnMouseUp", onMouseUp)
		moveFrame:SetHidden(not base.Global.IsMoveEnabled)
		moveFrame.overlay:SetHidden(not base.Global.IsMoveEnabled)
		moveFrame.labelCenter:SetHidden(not base.Global.IsMoveEnabled)
		moveFrame.labelTopLeft:SetHidden(not base.Global.IsMoveEnabled)
		moveFrame.MoveFrameUpdateText(moveFrame)
		moveFrame.MoveFrameUpdateColor(moveFrame)
		moveFrame:ClearAnchors()
		moveFrame:SetDimensions(targetFrame:GetWidth(), targetFrame:GetHeight())
		moveFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, targetFrame:GetLeft(), targetFrame:GetTop())
	end
end

function base:GetOrCreateMoveFrame(targetFrame, category)
	base:Debug("GetOrCreateMoveFrame", targetFrame, category)
	if category.Frames.Move == nil then
		local moveFrameName = string.format("%s_MoveFrame", category.Name)
		local newMoveFrame = base.WM:CreateControlFromVirtual(moveFrameName, GuiRoot, string.format(texts.FormatAbbreviationLowDash, "MoveFrame"))

		-- Variable is used to define what savedVariable the Frame refers to.
		newMoveFrame.TargetFrame = targetFrame
		newMoveFrame.Saved = base.Saved
		newMoveFrame.category = category
		newMoveFrame["MoveFrameUpdateText"] = function(frame, position)
			local labelTextTopLeft = ""

			if (position) then
				labelTextTopLeft = string.format(texts.Format.Comma, base:GetMoveFrameSnapPosition(frame.TargetFrame, category.Saved.Label.PositionTarget, frame.Saved.Bar.SnapSize))
			end

			frame.labelCenter:SetText(string.format(texts.Format.Comma, frame:GetWidth(), frame:GetHeight()))
			frame.labelTopLeft:SetText(labelTextTopLeft)
		end
		newMoveFrame["MoveFrameOnUpdate"] = function(frame)
			local x, y = base:GetMoveFrameSnapPosition(frame, category.Saved.Label.PositionTarget, frame.Saved.Bar.SnapSize)
			frame.TargetFrame:ClearAnchors()
			frame.TargetFrame:SetAnchor(category.Saved.Label.PositionTarget, GuiRoot, TOPLEFT, x, y)
			frame.MoveFrameUpdateText(frame, true)
		end
		newMoveFrame["MoveFrameUpdateColor"] = function(frame)
			frame.overlay:SetCenterColor(0.88, 0.88, 0.88, 0.4)
			frame.overlay:SetEdgeColor(0.88, 0.88, 0.88, 0)
			frame.labelCenter:SetColor(0.9, 0.9, 0.9, 0.9)
			frame.labelTopLeft:SetColor(0.9, 0.9, 0.9, 0.9)
		end
		newMoveFrame:SetAnchorFill(targetFrame)
		newMoveFrame:SetParent(GuiRoot)

		-- -- overlay
		if newMoveFrame.overlay == nil then
			newMoveFrame.overlay = GetControl(string.format("%sBG", moveFrameName))
		end

		-- labels
		if newMoveFrame.labelTopLeft == nil or newMoveFrame.labelCenter == nil then
			newMoveFrame.labelTopLeft = GetControl(string.format("%sLabelTopLeft", moveFrameName))
			newMoveFrame.labelTopLeft:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			newMoveFrame.labelTopLeft:SetVerticalAlignment(TEXT_ALIGN_TOP)

			newMoveFrame.labelCenter = GetControl(string.format("%sLabelCenter", moveFrameName))
			newMoveFrame.labelCenter:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			newMoveFrame.labelCenter:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		end

		category.Frames.Move = newMoveFrame
	end

	return category.Frames.Move
end
