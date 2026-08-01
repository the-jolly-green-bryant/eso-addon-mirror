CarosLootListOverrideButton = {}
CarosLootListOverrideButton.__index = CarosLootListOverrideButton

local function overrideCLLB()
	if not CarosLootList then return end
	if not CarosLootList.optionButton then return end
	local button = LibChatMenuButton.addChatButton("CarosLootListLCMB", {"esoui/art/inventory/inventory_tabicon_misc_up.dds", "esoui/art/inventory/inventory_tabicon_misc_over.dds", "esoui/art/inventory/inventory_tabicon_misc_down.dds", "esoui/art/inventory/inventory_tabicon_misc_disabled.dds"}, "", function() end)
	local f1 = CarosLootList.optionButton:GetHandler("OnMouseUp")
	local f2 = CarosLootList.optionButton:GetHandler("OnMouseEnter")
	local f3 = CarosLootList.optionButton:GetHandler("OnMouseExit")
	button:overrideFunctions(f1, f2, f3)
	button.ui.caro = WINDOW_MANAGER:CreateControl(nil, button.ui, CT_TEXTURE)
	button.ui.caro:SetTexture("esoui/art/crafting/crafting_alchemy_badslot.dds")
	button.ui.caro:SetAnchor(CENTER, button.ui, CENTER, -1)
	button.ui.caro:SetDimensions(20,20)
	button.ui.caro:SetTextureRotation(math.pi/4, 0.5,0.5)

	if not CarosLootList.sV.showButton then
		button:hide()
	else
		button:show()
	end
	CarosLootList.optionButton:SetHidden(true)
	CarosLootList.optionButton = {}
	setmetatable(CarosLootList.optionButton, CarosLootListOverrideButton)
	CarosLootList.optionButton.button = button
end

local function override()
	if not CarosLootList then return end
	if not CarosLootList.optionButton then return end
	if CarosLootList.optionButton.button ~= nil then return end
	if CarosLootList.cllButton then 
		CarosLootList.cllButton = function()
			CarosLootList.cllButton()
			overrideCLLB()
		end
	end
	overrideCLLB()
end

function CarosLootListOverrideButton.SetHidden(self, bool)
	if bool then
		self.button:hide()
	else
		self.button:show()
	end
end

function CarosLootListOverrideButton.SetAnchor(self, v1, v2, v3, v4, v5)
	
end

function CarosLootListOverrideButton.ClearAnchors(self)
	
end

table.insert(LibChatMenuButton.override, override)