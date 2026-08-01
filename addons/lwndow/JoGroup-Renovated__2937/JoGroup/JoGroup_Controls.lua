JoGroup = JoGroup or {}
local Jo = JoGroup
local wim = GetWindowManager()
local anm = GetAnimationManager()
local sf = 1/GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)

Jo.container = {}
Jo.vetIcon = {}
Jo.frame = {}
Jo.maxArrows = 3

-------------------------------------------------------------------------------------------------
--  Create Controls --
-------------------------------------------------------------------------------------------------
function Jo.CreateControls()
	local tlw = {}

	tlw = wim:CreateTopLevelWindow()
	tlw:SetDimensions(145, 60)
	tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT)
	tlw:SetMovable(false)
	tlw:SetMouseEnabled(false)
	tlw:SetClampedToScreen(true)
	tlw:SetHidden(false)

	tlw.backdrop = wim:CreateControl(nil, tlw, CT_BACKDROP)
	tlw.backdrop:SetAnchorFill()
	tlw.backdrop:SetDrawLayer(1)
	tlw.backdrop:SetHidden(true)
	tlw.backdrop:SetCenterColor(1, 1, 1, 0)
	tlw.backdrop:SetEdgeColor(1, 1, 1, 0.6)
	tlw.backdrop:SetEdgeTexture(nil, 1, 1, (2*sf))

	Jo.container = tlw
--[[
	Jo.vetIcon = wim:CreateControl(nil, Jo.container, CT_TEXTURE)
	Jo.vetIcon:SetDimensions(32, 32)
	Jo.vetIcon:SetAnchor(TOPRIGHT, Jo.container, TOPLEFT)
	Jo.vetIcon:SetTexture("esoui/art/lfg/gamepad/lfg_activityicon_veterandungeon.dds")
	Jo.vetIcon:SetHidden(true)
--]]

	for i = 1, GROUP_SIZE_MAX do
		local frame = {}

		frame = wim:CreateControl("JoGroupUnit"..i, Jo.container, CT_CONTROL)
		frame:SetDimensions(145, 60)
		frame:SetAnchor(TOPLEFT, Jo.container, TOPLEFT)
		frame:SetMouseEnabled(true)

		frame.backdrop = wim:CreateControl(nil, frame, CT_BACKDROP)
		frame.backdrop:SetAnchorFill()
		frame.backdrop:SetDrawLayer(0)
		frame.backdrop:SetDrawLevel(0)
		frame.backdrop:SetHidden(true)
		frame.backdrop:SetCenterColor(0, 0, 0, 0)
		frame.backdrop:SetEdgeColor(0, 0, 1, 1)
		frame.backdrop:SetEdgeTexture(nil, 1, 1, (2*sf))

		frame.bgColor = wim:CreateControl(nil, frame, CT_BACKDROP)
		frame.bgColor:SetAnchorFill()
		frame.bgColor:SetDrawLayer(0)
		frame.bgColor:SetDrawLevel(0)
		frame.bgColor:SetCenterColor(0, 0, 0, 0)
		frame.bgColor:SetEdgeColor(0, 0, 0, 0)
		frame.bgColor:SetEdgeTexture(nil, 1, 1, (2*sf))

		frame.bg = wim:CreateControl(nil, frame, CT_TEXTURE)
		frame.bg:SetDimensions(150, 80)
		frame.bg:SetAnchor(BOTTOMLEFT, frame, BOTTOMLEFT, 0, 0)
		frame.bg:SetDrawLayer(0)
		frame.bg:SetDrawLevel(1)
		frame.bg:SetTexture("EsoUI/Art/HUD/Gamepad/LootHistoryBG.dds")
		frame.bg:SetAlpha(0.8)
		frame.bg:SetInheritAlpha(false)

		-- Healthbar
		frame.statusBar = wim:CreateControl(nil, frame, CT_CONTROL)
		frame.statusBar:SetDimensions(140, 20)
		frame.statusBar:SetAnchor(BOTTOM, frame, BOTTOM, 0, -(3*sf))

			frame.barBg = wim:CreateControl(nil, frame.statusBar, CT_BACKDROP)
			frame.barBg:SetAnchorFill()
			frame.barBg:SetDrawLayer(1)
			frame.barBg:SetDrawLevel(0)
			frame.barBg:SetCenterColor(0, 0, 0, 0.6)
			frame.barBg:SetEdgeColor(0, 0, 0, 1)
			frame.barBg:SetEdgeTexture(nil, 1, 1, (2*sf))
			frame.barBg:SetInheritAlpha(false)

			frame.bar = wim:CreateControl(nil, frame.statusBar, CT_STATUSBAR)
			frame.bar:SetDimensions(frame.statusBar:GetWidth()-(4*sf), frame.statusBar:GetHeight()-(4*sf))
			frame.bar:SetAnchor(TOP, frame.statusBar, TOP, 0, (2*sf))
			frame.bar:SetDrawLayer(1)
			frame.bar:SetDrawLevel(1)
			frame.bar:SetColor(0.4, 0.4, 0.4, 1)
			frame.bar:SetBarAlignment(0)
			frame.bar:SetMinMax(0, 1000)
			frame.bar:SetValue(1000)

				frame.gloss = wim:CreateControl(nil, frame.bar, CT_STATUSBAR)
				frame.gloss:SetDimensions(frame.bar:GetDimensions())
				frame.gloss:SetAnchor(TOP, frame.bar, TOP)
				frame.gloss:SetDrawLayer(1)
				frame.gloss:SetDrawLevel(3)
				frame.gloss:SetTexture("EsoUI/Art/Miscellaneous/timerBar_genericFill_gloss.dds")
				frame.gloss:SetTextureCoords(0, 1, 0, 0.8125)
				frame.gloss:SetBarAlignment(0)
				frame.gloss:SetMinMax(0, 1000)
				frame.gloss:SetValue(1000)

			frame.shieldBar = wim:CreateControl(nil, frame.statusBar, CT_STATUSBAR)
			frame.shieldBar:SetDimensions(frame.bar:GetDimensions())
			frame.shieldBar:SetAnchor(TOP, frame.statusBar, TOP, 0, (2*sf))
			frame.shieldBar:SetHidden(true)
			frame.shieldBar:SetDrawLayer(1)
			frame.shieldBar:SetDrawLevel(2)
			frame.shieldBar:SetBarAlignment(0)
			frame.shieldBar:SetMinMax(0, 1000)
			frame.shieldBar:SetValue(1000)

				frame.shieldGloss = wim:CreateControl(nil, frame.shieldBar, CT_STATUSBAR)
				frame.shieldGloss:SetDimensions(frame.shieldBar:GetDimensions())
				frame.shieldGloss:SetAnchor(TOP, frame.shieldBar, TOP)
				frame.shieldGloss:SetHidden(true)
				frame.shieldGloss:SetDrawLayer(1)
				frame.shieldGloss:SetDrawLevel(3)
				frame.shieldGloss:SetTexture("EsoUI/Art/Miscellaneous/timerBar_genericFill_gloss.dds")
				frame.shieldGloss:SetTextureCoords(0, 1, 0, 0.8125)
				frame.shieldGloss:SetBarAlignment(0)
				frame.shieldGloss:SetMinMax(0, 1000)
				frame.shieldGloss:SetValue(1000)
				ZO_PreHookHandler(frame.shieldBar, "OnMinMaxValueChanged", function(_, min, max)
					frame.shieldGloss:SetMinMax(min, max)
					frame.shieldGloss:SetDimensions(frame.shieldBar:GetDimensions())
				end)
				ZO_PreHookHandler(frame.shieldBar, "OnValueChanged", function(_, value)
					frame.shieldGloss:SetValue(value)
				end)

			frame.barBorder = wim:CreateControl(nil, frame.statusBar, CT_BACKDROP)
			frame.barBorder:SetAnchorFill()
			frame.barBorder:SetDrawLayer(1)
			frame.barBorder:SetDrawLevel(9)
			frame.barBorder:SetCenterColor(0, 0, 0, 0)
			frame.barBorder:SetEdgeColor(0, 0, 0, 1)
			frame.barBorder:SetEdgeTexture(nil, 1, 1, (2*sf))
			frame.barBorder:SetInheritAlpha(false)

		local newMax = 1000
		ZO_PreHookHandler(frame.bar, "OnMinMaxValueChanged", function(_, min, max)
			frame.gloss:SetMinMax(min, max)
			newMax = max
		end)
		ZO_PreHookHandler(frame.bar, "OnValueChanged", function(_, value)
			frame.gloss:SetValue(value)
			local offsetX = (value*frame.bar:GetWidth())/newMax
			frame.shieldBar:ClearAnchors()
			frame.shieldBar:SetAnchor(TOPLEFT, frame.statusBar, TOPLEFT, (2*sf)+offsetX, (2*sf))
			frame.shieldBar:SetWidth(frame.bar:GetWidth()-offsetX)
			frame.shieldGloss:SetDimensions(frame.shieldBar:GetDimensions())
		end)

		-- Labels
		frame.dead = wim:CreateControl(nil, frame, CT_TEXTURE)
		frame.dead:SetDimensions(48, 48)
		frame.dead:SetAnchor(BOTTOM, frame, BOTTOM, 0, (2*sf))
		frame.dead:SetDrawLayer(2)
		frame.dead:SetDrawLevel(0)
		frame.dead:SetHidden(true)
		frame.dead:SetTexture("EsoUI/Art/Icons/Mapkey/mapkey_groupboss.dds")

		frame.info = wim:CreateControl(nil, frame, CT_LABEL)
		frame.info:SetAnchor(CENTER, frame.bar, CENTER)
		frame.info:SetDrawLayer(2)
		frame.info:SetDrawLevel(1)
		frame.info:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		frame.info:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
		frame.info:SetAlpha(0.9)
		frame.info:SetFont("$(BOLD_FONT)|13|soft-shadow-thick")
		frame.info:SetText("18k / 18k (100%)")

		frame.class = wim:CreateControl(nil, frame, CT_LABEL)
		frame.class:SetDimensions(140, 15)
		frame.class:SetAnchor(BOTTOMLEFT, frame.statusBar, TOPLEFT, -(2*sf), -(4*sf))
		frame.class:SetDrawLayer(2)
		frame.class:SetDrawLevel(1)
		frame.class:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		frame.class:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
		frame.class:SetText("  50")

		frame.shield = wim:CreateControl(nil, frame, CT_TEXTURE)
		frame.shield:SetDimensions(0, 18)
		frame.shield:SetAnchor(BOTTOMRIGHT, frame.statusBar, TOPRIGHT, -sf, 0)
		frame.shield:SetDrawLayer(2)
		frame.shield:SetDrawLevel(2)
		frame.shield:SetTexture("esoui/art/lfg/gamepad/lfg_activityicon_normaldungeon.dds")

		frame.hidden = wim:CreateControl(nil, frame, CT_TEXTURE)
		frame.hidden:SetDimensions(0, 18)
		frame.hidden:SetAnchor(TOPRIGHT, frame.shield, TOPLEFT, -sf, 0)
		frame.hidden:SetDrawLayer(2)
		frame.hidden:SetDrawLevel(2)
		frame.hidden:SetTexture("esoui/art/inventory/inventory_icon_hiddenby.dds")

		frame.food = wim:CreateControl(nil, frame, CT_TEXTURE)
		frame.food:SetDimensions(0, 18)
		frame.food:SetAnchor(TOPRIGHT, frame.hidden, TOPLEFT, -sf, 0)
		frame.food:SetDrawLayer(2)
		frame.food:SetDrawLevel(2)
		frame.food:SetTexture("esoui/art/icons/mapkey/mapkey_farm.dds")

		frame.name = wim:CreateControl(nil, frame, CT_LABEL)
		frame.name:SetDimensions(140, 15)
		frame.name:SetAnchor(BOTTOMLEFT, frame.class, TOPLEFT, (3*sf), -sf)
		frame.name:SetDrawLayer(2)
		frame.name:SetDrawLevel(1)
		frame.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		frame.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		frame.name:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
		frame.name:SetText("@Name")

		frame.arrow = {}
		for i = 1, Jo.maxArrows do
			frame.arrow[i] = wim:CreateControlFromVirtual(nil, frame, "ZO_ArrowRegeneration_Gamepad_Template")
			frame.arrow[i]:SetDimensions(16, 16)
			frame.arrow[i]:SetDrawLayer(3)
			frame.arrow[i]:SetDrawLevel(0)
			frame.arrow[i]:SetHidden(true)
			frame.arrow[i].animation = anm:CreateTimelineFromVirtual("ArrowRegenerationAnimation", frame.arrow[i])
			frame.arrow[i].animation:SetHandler("OnStop", function() 
				frame.arrow[i]:SetHidden(true) 
			end)
		end

		Jo.frame["group"..i] = frame
	end
end
