-- Addon: ShowRepairCosts
-- Version: 1.0
-- Created by P A G O O K

ShowRepairCosts = {}

function ShowRepairCosts.OnAddOnLoaded(event, addonName)
  if addonName == ShowRepairCosts.name then
  end
end

-- Fenster
local window = WINDOW_MANAGER:CreateTopLevelWindow("ShowRepairCostsWindow")
	ShowRepairCostsWindow:SetDimensions(230, 70)
	ShowRepairCostsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 40, 30)
	ShowRepairCostsWindow:SetMouseEnabled(true)

-- Label-Einstellungen
local Label = WINDOW_MANAGER:CreateControl("Label", ShowRepairCostsWindow, CT_LABEL)
	Label:SetAnchor(TOPLEFT, ShowRepairCostsWindow, TOPLEFT, 40, 30)
	Label:SetFont("ZoFontChat")
	Label:SetInheritAlpha(true)
	Label:SetMovable(false)
	Label.isToggled = true
	Label:SetHidden(false)

-- Automatische Reparatur An/Aus-Funktion (rechte Maustaste)
function AutomaticRepairOnOff()
	Label.isToggled = not Label.isToggled
		if Label.isToggled then
			d("Automatic repair: |c2dc50eENABLED")
				local function OnOpenStore()
					RepairAll()
			end
		EVENT_MANAGER:RegisterForEvent("ShowRepairCosts", EVENT_OPEN_STORE, OnOpenStore)

    else
        d("Automatic repair: |cf82121DISABLED")
		EVENT_MANAGER:UnregisterForEvent("ShowRepairCosts", EVENT_OPEN_STORE, OnOpenStore)
    end
end

-- Label verschieben (linke Maustaste)
Label:SetHandler("OnMouseUp", function(self, button)
    if button == MOUSE_BUTTON_INDEX_LEFT then
		Label:SetMovable(true)
	end

		if button == MOUSE_BUTTON_INDEX_RIGHT then
			AutomaticRepairOnOff()
			Label:SetMovable(false)
		end
end)
Label:SetMovable(false)
Label:SetMouseEnabled(true)

-- Spieler loggt sich ins Spiel ein
local function PlayerEinloggen()
    local bagId = BAG_BACKPACK
    local totalRepairKits = 0
    local bagSize = GetBagSize(bagId)

    for slotIndex = 0, bagSize - 1 do
        if IsItemRepairKit(bagId, slotIndex) then
            local _, RepairKitsAnzahl = GetItemInfo(bagId, slotIndex)
            totalRepairKits = totalRepairKits + RepairKitsAnzahl
        end
    end
			d("Automatic repair: |c2dc50eENABLED")
			local function OnOpenStore()
					RepairAll()
			end
			if totalRepairKits == 0 then
			df("Repair Kits|r: |cf82121%d |r", totalRepairKits)

		else 
			df("Repair Kits|r: |cFFFFFF%d |r", totalRepairKits)
		end
		EVENT_MANAGER:RegisterForEvent("ShowRepairCosts", EVENT_OPEN_STORE, OnOpenStore)
		EVENT_MANAGER:UnregisterForEvent("ShowRepairCosts", EVENT_PLAYER_ACTIVATED, PlayerEinloggen)
end

-- Gold-Icon
local GoldIcon = "|t16:16:EsoUI/Art/Currency/Currency_Gold.dds|t"

-- Label
function Label_RepairAllCost()
		Label:SetText(string.format("|cffffffRepair costs: |cf82121") .. GetRepairAllCost(repairCost) .. string.format(" ") .. GoldIcon)

		if (GetRepairAllCost(repairCost) == 0) then
			Label:SetText(string.format("|cffffffRepair costs: |cffffff") .. GetRepairAllCost(repairCost) .. string.format(" ") .. GoldIcon)
	end
end

-- Label aus- oder einblenden
local function LabelEinAusblenden()
    Label:SetHidden(not Label:IsHidden())
end

SLASH_COMMANDS["/src"] = LabelEinAusblenden

EVENT_MANAGER:RegisterForEvent("ShowRepairCosts", EVENT_ADD_ON_LOADED, ShowRepairCosts.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("ShowRepairCosts", EVENT_PLAYER_ACTIVATED, PlayerEinloggen)