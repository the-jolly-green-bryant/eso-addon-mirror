tv_CMMCovers = {
	name = "CircularMiniMap's Covers",
	Covers = {
			--Dust'n'Rust Pack
		["(C)[D&R] Bronze Wheel"] = "CircularMM_Covers/imgs/[D&R]_BronzeWheel.dds",
		["(C)[D&R] Old Wood Wheel"] = "CircularMM_Covers/imgs/[D&R]_OldWoodWheel.dds",
		["(C)[D&R] Elder Stone Wheel"] = "CircularMM_Covers/imgs/[D&R]_ElderStoneWheel.dds",
	},
}

local scale = (500 - 72 * 2)
local shortScale = (250 - 130) * 2 / scale
local longScale = (250 - 34) * 2 / scale
local borderScale = longScale * 500 / 410

local function applyClip()
	local width, height = ZO_WorldMapScroll:GetDimensions()
	if CircularMinimap.circularMode then
		CircularMinimap.background:SetDimensions(borderScale * width, borderScale * width)
		ZO_WorldMapScroll:SetAutoRectClipChildren(false)
		ZO_WorldMapScroll:SetCircularClip(ZO_WorldMapScroll:GetLeft() + width / 2, ZO_WorldMapScroll:GetTop() + height / 2, 1.25 * width / 2)
	else
		ZO_WorldMapScroll:ClearClips()
		ZO_WorldMapScroll:SetAutoRectClipChildren(true)
	end
end

for name, path in pairs(tv_CMMCovers.Covers) do
	VOTANS_MINIMAP:AddBorderStyle(
		name,
		name,
		function(settings, background, frame)
			CircularMinimap.circularMode = true

			-- default ESO style from votan's minimap
			local alpha = settings.borderAlpha / 100 or 1
			background:SetCenterColor(0, 0, 0, alpha)
			background:SetEdgeColor(0, 0, 0, alpha)
			background:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 256, 128, 16)
			background:SetCenterTexture("/esoui/art/chatwindow/chat_bg_center.dds")
			background:SetInsets(16, 16, -16, -16)

			-- we have to hide the old border frame
			frame:SetHidden(true)

			ZO_WorldMapTitle:ClearAnchors()
			ZO_WorldMapTitle:SetAnchor(TOP, background, TOP, 0, 4)
			
			if path == "" then
				CircularMinimap.background:SetHidden(true)
			else
				CircularMinimap.background:SetHidden(false)
				CircularMinimap.background:SetTexture(path)
			end

			-- move the old background to the bottom of the minimap
			-- and adjust draw levels, so it isn't hidden behind the minimap
			background:ClearAnchors()
			background:SetAnchor(TOPLEFT, ZO_WorldMap, BOTTOMLEFT, -8, -64)
			background:SetAnchor(BOTTOMRIGHT, ZO_WorldMap, BOTTOMRIGHT, 6, 8)

			CircularMinimap.oldBackgroundDrawLevel = CircularMinimap.oldBackgroundDrawLevel or background:GetDrawLevel()
			CircularMinimap.oldBackgroundDrawLayer = CircularMinimap.oldBackgroundDrawLayer or background:GetDrawLayer()
			background:SetDrawLevel(2)
			background:SetDrawLayer(1)

			applyClip()
		end,
		function(settings, background, frame)
			CircularMinimap.circularMode = false
			frame:SetHidden(false)

			background:ClearAnchors()
			background:SetAnchor(TOPLEFT, nil, TOPLEFT, -8, -4)
			background:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, 6, 0)

			background:SetDrawLevel(CircularMinimap.oldBackgroundDrawLevel)
			background:SetDrawLayer(CircularMinimap.oldBackgroundDrawLayer)

			CircularMinimap.background:SetHidden(true)

			applyClip()
		end
	)
end