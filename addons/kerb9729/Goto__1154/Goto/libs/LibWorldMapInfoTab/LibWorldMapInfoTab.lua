-- Register with LibStub
local MAJOR, MINOR = "LibWorldMapInfoTab", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- the same or newer version of this lib is already loaded into memory

if lib.Unload then
	lib:Unload()
end

local orgAddButton = WORLD_MAP_INFO.modeBar.menuBar.m_object.AddButton

function lib:Unload()
	WORLD_MAP_INFO.modeBar.menuBar.m_object.AddButton = orgAddButton
end

function WORLD_MAP_INFO.modeBar.menuBar.m_object:AddButton(buttonData)

	local numButtons = #self.m_buttons + 1
	if numButtons <= 6 then
		self.m_buttonPadding = 20
		self.m_downSize = 64
		self.m_normalSize = 51
	else
		self.m_downSize = 64 -(numButtons - 7) * 4
		self.m_normalSize = self.m_downSize * 0.8
		self.m_buttonPadding = 20 -(numButtons - 6) * 4.4
	end

	for _, data in ipairs(self.m_buttons) do
		local button = data[1].m_object
		local normalSize, downSize = button:GetAnimationData()
		local size = button:GetState() == BSTATE_PRESSED and downSize or normalSize
		button.m_image:SetDimensions(size, size)
	end

	return orgAddButton(self, buttonData)
end
