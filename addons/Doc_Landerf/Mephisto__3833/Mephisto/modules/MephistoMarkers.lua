Mephisto = Mephisto or {}
local MP = Mephisto

MP.markers = {}
local MPM = MP.markers

function MPM.Init()
	MPM.name = MP.name .. "Markers"
	MPM.gearList = {}
	MPM.markList = {}
	
	if not MP.settings.inventoryMarker then return end
	
	MPM.BuildGearList()
	MPM.HookInventories()
end

function MPM.BuildGearList()
	if not MP.settings.inventoryMarker then return end
	MPM.gearList = {}
	for entry in MP.SetupIterator() do
		local setup = entry.setup
		for _, gearSlot in ipairs(MP.GEARSLOTS) do
			local item = setup.gear[gearSlot]
			if item then
				if not MPM.gearList[item.id] then
					MPM.gearList[item.id] = {}
				end
				table.insert(MPM.gearList[item.id], {tag = entry.zone.tag, pageId = entry.pageId, index = entry.index})
			end
		end
	end
end

function MPM.HookInventories()
	for i, inventory in ipairs(MP.MARKINVENTORIES) do
		SecurePostHook(inventory.dataTypes[1], "setupCallback", function(control, slot)
			MPM.AddMark(control)
		end)
	end
end

function MPM.GetTooltip(itemData)
	local text = {}
	for _, data in ipairs(itemData) do
		if data and data.tag and data.pageId and data.index then
			local pageName = MP.pages[data.tag][data.pageId].name
			local setupName = MP.setups[data.tag][data.pageId][data.index].name
			table.insert(text, string.format("%s (%s, %s)", setupName, data.tag, pageName))
		end
	end
	return table.concat(text, "\n")
end

function MPM.AddMark(control)
	local slot = control.dataEntry.data
	local mark = MPM.GetMark(control)
	
	local lookupId = Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))
	local itemData = MPM.gearList[lookupId]
	mark:SetHidden(not itemData)
	
	mark:SetHandler("OnMouseEnter", function(self)
		if itemData then
			ZO_Tooltips_ShowTextTooltip(self, RIGHT, MPM.GetTooltip(itemData))
		end
	end)
	mark:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
end

function MPM.GetMark(control)
	local name = control:GetName()
	local mark = MPM.markList[name]
	if not mark then
		mark = WINDOW_MANAGER:CreateControl(name .. "MephistoMarker", control, CT_TEXTURE)
		MPM.markList[name] = mark
		mark:SetTexture("/Mephisto/assets/mark.dds")
		mark:SetColor(0.09, 0.75, 0.85, 1)
		mark:SetDrawLayer(3)
		mark:SetHidden(true)
		mark:SetDimensions(12, 12)
		mark:SetAnchor(RIGHT, control, LEFT, 38)
		mark:SetMouseEnabled(true)
	end
	return mark
end