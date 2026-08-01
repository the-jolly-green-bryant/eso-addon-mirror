SAMURAI = SAMURAI or { }
local sam = SAMURAI

local function renameHeroism()
	local old = ZO_SharedInventoryManager.CreateOrUpdateSlotData
        ZO_SharedInventoryManager.CreateOrUpdateSlotData = function(self, existingSlotData, bagId, slotIndex, isNewItem)
                local slot, added = old(self, existingSlotData, bagId, slotIndex, isNewItem)
               	local link = GetItemLink(bagId, slotIndex)
               	local text, style, itemtype, id, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, data = ZO_LinkHandler_ParseLink(link)
               	if itemtype == "item" and id ~= "55262" and not string.find(GetItemLinkName(link), "Writ") and data then
               	        data = tonumber(data)
               	        local e1 = math.floor(data / 65536) % 256
               	        local e2 = math.floor(data / 256) % 256
               	        local e3 = data % 256
               	        if sam.savedVars.modules.potions.renameHeroism and (e1 == 31 or e2 == 31 or e3 == 31) then
               	                slot.displayQuality = 6
               	                slot.name = "Essence of Heroism"
               	                slot.rawName = "Essence of Heroism"
	       		elseif sam.savedVars.modules.potions.renameTri and (e1 == 129 or e1 == 1) and e2 == 3 and e3 == 5 then
               	                slot.displayQuality = 6
               	                slot.name = "Essence of Tri-Restoration"
               	                slot.rawName = "Essence of Tri-Restoration"
	       		elseif sam.savedVars.modules.potions.renameVitality and (e1 == 29 or e2 == 29 or e3 == 29) then
               	                slot.displayQuality = 6
               	                slot.name = "Essence of Vitality"
               	                slot.rawName = "Essence of Vitality"
               	        end
               	end
                return slot, added
        end
end

function sam.setupPotionModule()
	renameHeroism()
end
