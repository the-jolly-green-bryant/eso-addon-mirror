-- Initialize file
ZDAT           = ZDAT or {}
ZDAT.UI        = ZDAT.UI or {}
ZDAT.UI.Labels = {}

------------------------------------------------------------------------------------------------------------------
-- Basic Label  
------------------------------------------------------------------------------------------------------------------
function ZDAT.UI.Labels.basic(data)
	-- text values
	data.w     = data.w     or 150
	data.h     = data.h     or 23
	data.f     = data.f     or ZDAT.UI.Constants.defaultFont -- "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin"
	data.c     = data.c     or ZDAT.UI.Constants.rgbWhite 
	data.align = data.align or TEXT_ALIGN_LEFT
	data.vAlign = data.vAlign or TEXT_ALIGN_CENTER

	-- tooltip values
	data.tta = data.tta or BOTTOM -- tooltip anchor
	data.ttf = data.ttf or ZDAT.UI.Constants.tooltipFont
	data.ttc = data.ttc or ZDAT.UI.Constants.hexGold

	-- create control
	local control = WINDOW_MANAGER:CreateControl("$(parent)"..ZDAT.Utils.uid(), ZDAT_GUI, CT_LABEL)
	control:SetDimensions(data.w, data.h)
	control:SetColor(unpack(data.c))
	control:SetHorizontalAlignment(data.align)
	control:SetVerticalAlignment(data.vAlign)
	control:SetText(data.t)
	control:SetFont(data.f)
	control:SetWrapMode(1)

	-- optionally add tooltip
	if data.tt then
		control:SetMouseEnabled(true)
		control:SetHandler("OnMouseEnter", function(control) 
			ZO_Tooltips_ShowTextTooltip(control, data.tta)
			InformationTooltip:AddLine(string.format('|%s%s|r', data.ttc, data.tt), data.ttf)
			end)
		control:SetHandler("OnMouseExit", function (control) 
			ClearTooltip(InformationTooltip)
			end) 
		control:SetHandler("OnMouseUp", function(control, button)
			if button == 2 then
				ClearMenu()
			elseif button == 1 then -- RMB==2, LMB==1
				ClearMenu()

				if data.wayshrineId then 
					AddMenuItem("Teleport to", function() 
						ZDAT.UI.Layout.toggleWindow()
						d(ZDAT.name .. " > Porting to "..data.t)
						FastTravelToNode(data.wayshrineId)
						end)
				end
				ShowMenu(control)
			end
		end)
	end		

	-- optionally setup conditional visibility
	if data.v then
		ZDAT.UI.Layout.registerRefreshFn(function()
			control:SetHidden(not data.v())
			end)
	end

	return control
end

-- ------------------------------------------------------------------------------------------------------------------
-- -- Teleport Label 
-- ------------------------------------------------------------------------------------------------------------------
function ZDAT.UI.Labels.teleport(data)
	local control = ZDAT.UI.Labels.basic(data)
	control:SetMouseEnabled(true)

	control:SetHandler("OnMouseEnter", function(control) control:SetColor(unpack(ZDAT.UI.Constants.rgbWhite)) end )
	control:SetHandler("OnMouseExit",  function(control) control:SetColor(unpack(ZDAT.UI.Constants.rgbBlue)) end )
	control:SetHandler("OnMouseUp", function(control, button)
		if button == 2 then
			ClearMenu()
		elseif button == 1 then -- RMB==2, LMB==1
			ClearMenu()

			if data.wayshrineId then 
				AddMenuItem("Teleport to", function() 
					ZDAT.UI.Layout.toggleWindow()
					d(ZDAT.name .. " > Porting to "..data.t)
					FastTravelToNode(data.wayshrineId)
					end)
			end
			ShowMenu(control)
		end
	end)
	return control
end

------------------------------------------------------------------------------------------------------------------
-- Achievement Label  
------------------------------------------------------------------------------------------------------------------
function ZDAT.UI.Labels.achievement(data)
	-- default color to gray
	data.c = ZDAT.UI.Constants.rgbGray
	local control = ZDAT.UI.Labels.basic(data)

	-- use aid to dynamically color
	if data.a then
		ZDAT.UI.Layout.registerRefreshFn(function()
			control:SetColor(unpack(IsAchievementComplete(data.a) and ZDAT.UI.Constants.rgbWhite or  ZDAT.UI.Constants.rgbGray))
			end)
	end

	if data.a then
		ZDAT.UI.Layout.registerRefreshFn(function()
		local description, numCompleted, numRequired = GetAchievementCriterion(data.a, 1)
		local progress = zo_strformat("<<1>> (<<2>>/<<3>>)", ZDAT.Data.Achievements.GetAchivementName(data.a), numCompleted, numRequired)

		control:SetMouseEnabled(true)
		control:SetHandler("OnMouseEnter", function(control) 
			ZO_Tooltips_ShowTextTooltip(control, data.tta)
			InformationTooltip:AddLine(string.format('|%s%s|r', data.ttc, progress), data.ttf)
			end)
		control:SetHandler("OnMouseExit", function (control) 
			ClearTooltip(InformationTooltip)
			end)
		end)
	end
	return control
end