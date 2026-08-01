GRT.UI = {}
GRT.UI.frames = {}
GRT.UI.frames["ESO"] = {["Group"]={},["Raid"] = {},}
GRT.UI.frames["LUI"] = {["Group"]={},["Raid"] = {},}
GRT.UI.frames["FTC"] = {["Group"]={},["Raid"] = {},}
GRT.UI.frames["AUI"] = {["Group"]={},["Raid"] = {},}
GRT.UI.frames["JO"]  = {["Group"]={},["Raid"] = {},}
GRT.UI.frames["BUI"] = {["Group"]={},["Raid"] = {},}
local function createBar(barIndex,barName,num,groupSize,targetAddon,myMainControl)
	local barBG = {}
	local addon = targetAddon
	local barHeight = GRT.SavedVar.savedVariables.barHeight or GRT.SavedVar.Default.barHeight
	local barOffsetX = GRT.SavedVar.savedVariables.barOffsetX or GRT.SavedVar.Default.barOffsetX
	local barOffsetY = GRT.SavedVar.savedVariables.barOffsetY or GRT.SavedVar.Default.barOffsetY
	local after2ndBarOffsetY = GRT.SavedVar.savedVariables.after2ndBarOffsetY or GRT.SavedVar.Default.after2ndBarOffsetY
	
	barBG[barName] = WINDOW_MANAGER:CreateControl("GRT_"..groupSize..barName..addon..num.."BG", myMainControl, CT_BACKDROP)
	barBG[barName]:SetAnchor(0, GRT.target[addon][groupSize].bar(num), TOPLEFT, 0, GRT.target[addon][groupSize].bar(num):GetHeight())
	barBG[barName]:SetDimensions(GRT.target[addon][groupSize].bar(num):GetDesiredWidth(), barHeight)
	barBG[barName]:SetCenterColor(0, 0, 0, 0)
	barBG[barName]:SetEdgeColor(0, 0, 0, 0)
	barBG[barName]:SetDrawLayer(3)
	barBG[barName]:SetDrawLevel(1)
	barBG[barName]:SetDrawTier(2)
	barBG[barName].bar = WINDOW_MANAGER:CreateControl("GRT_"..groupSize..barName..addon..num.."Bar", myMainControl, CT_STATUSBAR)
	barBG[barName].anchor = myMainControl
	barBG[barName].anchorBar = GRT.target[addon][groupSize].bar(num)
	--Texture
	if GRT.target[addon][groupSize].texture.Path ~= nil then
		barBG[barName].bar:SetTexture(GRT.target[addon][groupSize].texture.Path())
		barBG[barName].bar:SetTextureCoords(0, 1, 0, 1)
		if GRT.target[addon][groupSize].texture.EdgePath ~= nil then
			barBG[barName].bar:SetLeadingEdge(GRT.target[addon][groupSize].texture.EdgePath, GRT.target[addon][groupSize].texture.EdgeW, GRT.target[addon][groupSize].texture.EdgeH)
			barBG[barName].bar:SetLeadingEdgeTextureCoords(0, 1, 0, 1)
			barBG[barName].bar:EnableLeadingEdge(true)
		end
	end
	barBG[barName]:SetHeight(barHeight)
	barBG[barName].bar:SetAnchorFill(barBG[barName])
	barBG[barName].bar:SetMinMax(0, 100)
	barBG[barName].bar:SetValue(0)
	local r1,g1,b1,a1 = unpack(GRT.SavedVar.savedVariables.bar[barName].color1 or GRT.SavedVar.Default.bar[barName].color1)
	local r2,g2,b2,a2 = unpack(GRT.SavedVar.savedVariables.bar[barName].color2 or GRT.SavedVar.Default.bar[barName].color2)
	barBG[barName].bar:SetGradientColors(r1,g1,b1,a1,r2,g2,b2,a2)
	barBG[barName].bar:SetDrawLayer(3)
	barBG[barName].bar:SetDrawLevel(1)
	barBG[barName].bar:SetDrawTier(2)
	--Gloss
	if GRT.target[addon][groupSize].textureGloss.enable then
		barBG[barName].bar.gloss = WINDOW_MANAGER:CreateControl("GRT_"..groupSize..barName..addon..num.."BarGloss", barBG[barName].bar, CT_STATUSBAR)
		if GRT.target[addon][groupSize].textureGloss.Path ~= nil then
			barBG[barName].bar.gloss:SetTexture(GRT.target[addon][groupSize].textureGloss.Path)
			barBG[barName].bar.gloss:SetTextureCoords(0, 1, 0, 1)
			if GRT.target[addon][groupSize].texture.EdgePath ~= nil then
				barBG[barName].bar.gloss:SetLeadingEdge(GRT.target[addon][groupSize].textureGloss.EdgePath, GRT.target[addon][groupSize].textureGloss.EdgeW, GRT.target[addon][groupSize].textureGloss.EdgeH)
				barBG[barName].bar.gloss:SetLeadingEdgeTextureCoords(0, 1, 0, 1)
				barBG[barName].bar.gloss:EnableLeadingEdge(true)
			end
			local r3,g3,b3,a3 = unpack(GRT.SavedVar.savedVariables.bar[barName].color1gloss or GRT.SavedVar.Default.bar[barName].color1gloss)
			local r4,g4,b4,a4 = unpack(GRT.SavedVar.savedVariables.bar[barName].color2gloss or GRT.SavedVar.Default.bar[barName].color2gloss)
			barBG[barName].bar.gloss:SetGradientColors(r3,g3,b3,a3,r4,g4,b4,a4)
		end
		barBG[barName].bar.gloss:SetAnchorFill(barBG[barName].bar)
		barBG[barName].bar.gloss:SetMinMax(0, 100)
		barBG[barName].bar.gloss:SetValue(0)
		barBG[barName].bar.gloss:SetDrawLayer(1)
		barBG[barName].bar:SetHandler('OnValueChanged', function(bar, value) bar.gloss:SetValue(value) end)
	end
	barBG[barName].barIndex = barIndex
	barBG[barName].startTime = 0
	barBG[barName].endTime = 0
	barBG[barName].maxValue = 0
	return barBG[barName]
end
function GRT.UI.BarAlign(addon,groupSize,num)
	local barHeight = GRT.SavedVar.savedVariables.barHeight or GRT.SavedVar.Default.barHeight
	local barOffsetX = GRT.SavedVar.savedVariables.barOffsetX or GRT.SavedVar.Default.barOffsetX
	local barOffsetY = GRT.SavedVar.savedVariables.barOffsetY or GRT.SavedVar.Default.barOffsetY
	local after2ndBarOffsetY = GRT.SavedVar.savedVariables.after2ndBarOffsetY or GRT.SavedVar.Default.after2ndBarOffsetY
	local offsetY
	if GRT.UI.frames[addon][groupSize][num] ~= nil then 
		for barName, ver1 in pairs(GRT.Bar) do
			local barEnable = GRT.SavedVar.savedVariables.bar[barName].enable or GRT.SavedVar.Default.bar[barName].enable
			if barEnable and GRT.UI.frames[addon][groupSize][num].barBG[barName].bar:GetValue() > 0.01 then
				GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetHeight(barHeight)
				GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetWidth(GRT.UI.frames[addon][groupSize][num].barBG[barName].anchorBar:GetDesiredWidth())
			else
				GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetHeight(0)
			end
			offsetY = GRT.UI.frames[addon][groupSize][num].barBG[barName].anchor:GetHeight() + after2ndBarOffsetY
			if GRT.UI.frames[addon][groupSize][num].barBG[barName].anchor:GetHeight() == 0 then offsetY = 0 end
			if (barName == "Shield") then offsetY = 0 end
			GRT.UI.frames[addon][groupSize][num].main:SetAnchor(0, GRT.target[addon][groupSize].bar(num), TOPLEFT, barOffsetX, GRT.target[addon][groupSize].bar(num):GetHeight() + barOffsetY)
			GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetAnchor(0, GRT.UI.frames[addon][groupSize][num].barBG[barName].anchor, TOPLEFT, 0, offsetY)
		end
	end
end
function GRT.UI.CreateUnitFrame(addon,groupSize,num)
	if GRT.target[addon][groupSize].anchor(num) == nil then return end
	if GRT.target[addon][groupSize].bar(num) == nil then return end
	local unitTag = "group"..num
	if GRT.UI.frames[addon][groupSize][num] ~= nil then 
		return 
	end
	local barHeight = GRT.SavedVar.savedVariables.barHeight or GRT.SavedVar.Default.barHeight
	local barOffsetX = GRT.SavedVar.savedVariables.barOffsetX or GRT.SavedVar.Default.barOffsetX
	local barOffsetY = GRT.SavedVar.savedVariables.barOffsetY or GRT.SavedVar.Default.barOffsetY
	local after2ndBarOffsetY = GRT.SavedVar.savedVariables.after2ndBarOffsetY or GRT.SavedVar.Default.after2ndBarOffsetY

	local unitFrame = {}
	unitFrame.unitTag = unitTag
	unitFrame.main = WINDOW_MANAGER:CreateControl("GRT_"..groupSize.."_Frame"..addon..num, GRT.target[addon][groupSize].anchor(num), CT_CONTROL)
	--unitFrame.main = WINDOW_MANAGER:CreateControl("GRT_"..groupSize.."_Frame"..addon..num, GRT.UI.MainAnchor, CT_CONTROL)
	unitFrame.main:SetDrawLayer(3)
	unitFrame.main:SetDrawLevel(1)
	unitFrame.main:SetDrawTier(2)

	unitFrame.main:SetDimensions(GRT.target[addon][groupSize].bar(num):GetDesiredWidth(), GRT.target[addon][groupSize].bar(num):GetHeight())
	unitFrame.main:SetAnchor(0, GRT.target[addon][groupSize].bar(num), TOPLEFT, barOffsetX, GRT.target[addon][groupSize].bar(num):GetHeight() + barOffsetY)
	unitFrame.barBG = {}
	unitFrame.barBG["Shield"] 	= createBar(1,"Shield"	,num,groupSize,addon,	unitFrame.main	)
	unitFrame.barBG["Regen"] 	= createBar(2,"Regen"	,num,groupSize,addon,	unitFrame.barBG["Shield"]	)
	unitFrame.barBG["CP"] 		= createBar(3,"CP"		,num,groupSize,addon,	unitFrame.barBG["Regen"]	)
	unitFrame.barBG["SPC"] 		= createBar(4,"SPC"		,num,groupSize,addon,	unitFrame.barBG["CP"]		)
	unitFrame.barBG["Spear"] 	= createBar(5,"Spear"	,num,groupSize,addon,	unitFrame.barBG["SPC"]		)

	unitFrame.text = WINDOW_MANAGER:CreateControl("GRT_"..groupSize.."_Frame"..addon..num.."_Name", unitFrame.main, CT_LABEL)
	unitFrame.text:SetFont("ZoFontGame")
	unitFrame.text:SetAnchor(TOPLEFT, unitFrame.main, TOPLEFT, GRT.target[addon][groupSize].bar(num):GetDesiredWidth(), 0)
	unitFrame.text:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	unitFrame.text:SetWidth(300)
	unitFrame.text:SetDrawLayer(2)
	unitFrame.text:SetText("Name"..num)
	unitFrame.text:SetHidden(true)
	unitFrame.created = true
	GRT.UI.frames[addon][groupSize][num]= unitFrame
end
function GRT.UI.ReflectSetting()
	local barHeight = GRT.SavedVar.savedVariables.barHeight or GRT.SavedVar.Default.barHeight
	local barOffsetX = GRT.SavedVar.savedVariables.barOffsetX or GRT.SavedVar.Default.barOffsetX
	local barOffsetY = GRT.SavedVar.savedVariables.barOffsetY or GRT.SavedVar.Default.barOffsetY
	local after2ndBarOffsetY = GRT.SavedVar.savedVariables.after2ndBarOffsetY or GRT.SavedVar.Default.after2ndBarOffsetY
	local offsetY
	for addon, ver1 in pairs(GRT.UI.frames) do
		for groupSize, ver2 in pairs(GRT.UI.frames[addon]) do
			for num, ver3 in pairs(GRT.UI.frames[addon][groupSize]) do
				for barName, ver4 in pairs(GRT.Bar) do
					local barEnable = GRT.SavedVar.savedVariables.bar[barName].enable or GRT.SavedVar.Default.bar[barName].enable
					if(GRT.UI.frames[addon][groupSize][num].barBG[barName] ~= nil) then
						GRT.UI.frames[addon][groupSize][num].barBG[barName]:SetHeight(GRT.SavedVar.savedVariables.barHeight or GRT.SavedVar.Default.barHeight)
						GRT.UI.frames[addon][groupSize][num].barBG[barName].bar:SetTexture(GRT.target[addon][groupSize].texture.Path())
						local r1,g1,b1,a1 = unpack(GRT.SavedVar.savedVariables.bar[barName].color1 or GRT.SavedVar.Default.bar[barName].color1)
						local r2,g2,b2,a2 = unpack(GRT.SavedVar.savedVariables.bar[barName].color2 or GRT.SavedVar.Default.bar[barName].color2)
						GRT.UI.frames[addon][groupSize][num].barBG[barName].bar:SetGradientColors(r1,g1,b1,a1,r2,g2,b2,a2)
						GRT.UI.frames[addon][groupSize][num].main:SetAnchor(0, GRT.target[addon][groupSize].bar(num), TOPLEFT, barOffsetX, GRT.target[addon][groupSize].bar(num):GetHeight() + barOffsetY)
						if GRT.target[addon][groupSize].textureGloss.enable then
							local r3,g3,b3,a3 = unpack(GRT.SavedVar.savedVariables.bar[barName].color1gloss or GRT.SavedVar.Default.bar[barName].color1gloss)
							local r4,g4,b4,a4 = unpack(GRT.SavedVar.savedVariables.bar[barName].color2gloss or GRT.SavedVar.Default.bar[barName].color2gloss)
							GRT.UI.frames[addon][groupSize][num].barBG[barName].bar.gloss:SetGradientColors(r3,g3,b3,a3,r4,g4,b4,a4)
						end
					end
				end
			end
		end
	end
end

















