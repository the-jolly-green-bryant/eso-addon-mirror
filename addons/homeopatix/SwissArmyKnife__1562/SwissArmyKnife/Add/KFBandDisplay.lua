-- BandDisplay Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017
	

function EmptyDisplay()
	SwissArmyKnifeContainerSigilIcon:SetTexture("")
	SwissArmyKnifeContainerSigilIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerSigilLabel:SetText("")  

	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetTexture("")
	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetColor(0, 0, 0, 0)
    	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetText("")   

	SwissArmyKnifeContainerKeyIcon:SetTexture("")
	SwissArmyKnifeContainerKeyIcon:SetColor(0, 0, 0, 0)
    	SwissArmyKnifeContainerKeyLabel:SetText("")  

	SwissArmyKnifeContainerDaedricEmbersIcon2:SetTexture("")
	SwissArmyKnifeContainerDaedricEmbersIcon2:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerDaedricEmbersLabel2:SetText("")

	SwissArmyKnifeContainerDaedricEmbersIcon:SetTexture("")
	SwissArmyKnifeContainerDaedricEmbersIcon:SetColor(0, 0, 0, 0)
    	SwissArmyKnifeContainerDaedricEmbersLabel:SetText("")  

	SwissArmyKnifeContainerBankIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBankIcon:SetTexture("")
	SwissArmyKnifeContainerBagIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBagIcon:SetTexture("")
end

function EmptyWrit()
	SwissArmyKnifeContainerWritIcon_1:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerWritLabel_1:SetText("")
	SwissArmyKnifeContainerWritIcon_2:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerWritLabel_2:SetText("")
	SwissArmyKnifeContainerWritIcon_3:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerWritLabel_3:SetText("")
	SwissArmyKnifeContainerWritIcon_4:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerWritLabel_4:SetText("")
	SwissArmyKnifeContainerWritIcon_5:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerWritLabel_5:SetText("")
	SwissArmyKnifeContainerWritIcon_6:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerWritLabel_6:SetText("")
end

function PotionDisplay()
	SwissArmyKnifeContainerSigilIcon:SetTexture("")
	SwissArmyKnifeContainerSigilIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerSigilLabel:SetText("")

	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetTexture(SAK.iconPoHeal_2)
	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetText(GetItemLinkStacks(SAK.iconPoHeal))
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerKeyIcon:SetTexture(SAK.iconPoMana_2)
	SwissArmyKnifeContainerKeyIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetText(GetItemLinkStacks(SAK.iconPoMana))
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon2:SetTexture("")
	SwissArmyKnifeContainerDaedricEmbersIcon2:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerDaedricEmbersLabel2:SetText("")

	SwissArmyKnifeContainerDaedricEmbersIcon:SetTexture(SAK.iconPoStam_2)
	SwissArmyKnifeContainerDaedricEmbersIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel:SetText(GetItemLinkStacks(SAK.iconPoStam))

	SwissArmyKnifeContainerBankIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBankIcon:SetTexture("")
	SwissArmyKnifeContainerBagIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBagIcon:SetTexture("")
end

function PotionCombatDisplay()
	SwissArmyKnifeContainerSigilIcon:SetTexture("")
	SwissArmyKnifeContainerSigilIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerSigilLabel:SetText("")

	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetTexture(SAK.iconCombat_2)
	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetText(GetItemLinkStacks(SAK.iconCombat_22))
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerKeyIcon:SetTexture(SAK.iconCombat_3)
	SwissArmyKnifeContainerKeyIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetText(GetItemLinkStacks(SAK.iconCombat_33))
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon2:SetTexture("")
	SwissArmyKnifeContainerDaedricEmbersIcon2:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerDaedricEmbersLabel2:SetText("")

	SwissArmyKnifeContainerDaedricEmbersIcon:SetTexture(SAK.iconCombat_1)
	SwissArmyKnifeContainerDaedricEmbersIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel:SetText(GetItemLinkStacks(SAK.iconCombat_11))

	SwissArmyKnifeContainerBankIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBankIcon:SetTexture("")
	SwissArmyKnifeContainerBagIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBagIcon:SetTexture("")
end

function StealingDisplay()
	local valtemp = 0

	SwissArmyKnifeContainerSigilIcon:SetTexture(SAK.iconLockPick_2)
	SwissArmyKnifeContainerSigilIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerSigilLabel:SetText(GetItemLinkStacks(SAK.iconLockPick))
	SwissArmyKnifeContainerSigilLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetTexture(SAK.IconMonk)
	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetText(GetItemLinkStacks(SAK.IconMonk_2))
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerKeyIcon:SetTexture(SAK.IconEdit)
	SwissArmyKnifeContainerKeyIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetText(GetItemLinkStacks(SAK.IconEdit_2))
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon:SetTexture(SAK.IconPoInvi)
	SwissArmyKnifeContainerDaedricEmbersIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel:SetText(GetItemLinkStacks(SAK.IconPoInvi_2))
	SwissArmyKnifeContainerDaedricEmbersLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon2:SetTexture(SAK.IconPoVanish)
	SwissArmyKnifeContainerDaedricEmbersIcon2:SetColor(255, 255, 255, 255)

	valtemp = GetItemLinkStacks(SAK.IconPoSpeed_2)
	if(valtemp == 0)then
		SwissArmyKnifeContainerDaedricEmbersLabel2:SetText(GetItemLinkStacks(SAK.IconPoVanish_2))
	else
		SwissArmyKnifeContainerDaedricEmbersLabel2:SetText(GetItemLinkStacks(SAK.IconPoSpeed_2))
	end
	
	SwissArmyKnifeContainerDaedricEmbersLabel2:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerBankIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBankIcon:SetTexture("")
	SwissArmyKnifeContainerBagIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBagIcon:SetTexture("")
end

function SoulGemDisplay()
	SwissArmyKnifeContainerSigilIcon:SetTexture("")
	SwissArmyKnifeContainerSigilIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerSigilLabel:SetText("")

	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetTexture(SAK.iconLockPick_2)
	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetText(GetItemLinkStacks(SAK.iconLockPick))
	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerKeyIcon:SetTexture(SAK.iconSoulGemEmpty_2)
	SwissArmyKnifeContainerKeyIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerKeyLabel:SetText(GetItemLinkStacks(SAK.iconSoulGemEmpty))
	SwissArmyKnifeContainerKeyLabel:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon2:SetTexture("")
	SwissArmyKnifeContainerDaedricEmbersIcon2:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerDaedricEmbersLabel2:SetText("")

	SwissArmyKnifeContainerDaedricEmbersIcon:SetTexture(SAK.iconSoulGemFilled_2)
	SwissArmyKnifeContainerDaedricEmbersIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel:SetText(GetItemLinkStacks(SAK.iconSoulGemFilled))
	
	SwissArmyKnifeContainerBankIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBankIcon:SetTexture("")
	SwissArmyKnifeContainerBagIcon:SetColor(0, 0, 0, 0)
	SwissArmyKnifeContainerBagIcon:SetTexture("")
end

function DeadricDisplay()
	local DaedricEmbersBag, DaedricEmbersBank = processInventoryData()
    	local DaedricEmbersNumber = DaedricEmbersBag + DaedricEmbersBank
	local sigilBag = GetItemLinkStacks(SAK.sigil)

	SwissArmyKnifeContainerSigilIcon:SetTexture(SAK.iconSigil)
	SwissArmyKnifeContainerSigilIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerSigilLabel:SetText(sigilBag) 
    	SwissArmyKnifeContainerSigilLabel:SetColor(sigilBag < 1 and 1 or 255,sigilBag < 1 and 1 or 200,sigilBag < 1 and 1 or 0, 255)  

	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetTexture(SAK.iconCembers)
	SwissArmyKnifeContainerDaedricEmbersIcon_2:SetColor(255, 255, 255, 255)
    	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetText(DaedricEmbersNumber)   
    	SwissArmyKnifeContainerDaedricEmbersLabel_2:SetColor(DaedricEmbersNumber < 60 and 1 or 0,DaedricEmbersNumber < 60 and 1 or 255,DaedricEmbersNumber < 60 and 1 or 0, 255)

	SwissArmyKnifeContainerKeyIcon:SetTexture(SAK.iconClef)
	SwissArmyKnifeContainerKeyIcon:SetColor(255, 255, 255, 255)
    	local KeyNumber, restKey  = processInventoryDataForKey()
    	SwissArmyKnifeContainerKeyLabel:SetText(KeyNumber)  
    	SwissArmyKnifeContainerKeyLabel:SetColor(tonumber(KeyNumber) < 1 and 1 or 255,tonumber(KeyNumber) < 1 and 1 or 0,tonumber(KeyNumber) < 1 and 1 or 0, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon2:SetTexture(SAK.iconCembers)
	SwissArmyKnifeContainerDaedricEmbersIcon2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerDaedricEmbersLabel2:SetText(DaedricEmbersBank)
	SwissArmyKnifeContainerDaedricEmbersLabel2:SetColor(DaedricEmbersBank < 60 and 1 or 0,DaedricEmbersBank < 60 and 1 or 255,DaedricEmbersBank < 60 and 1 or 0, 255)

	SwissArmyKnifeContainerDaedricEmbersIcon:SetTexture(SAK.iconCembers)
	SwissArmyKnifeContainerDaedricEmbersIcon:SetColor(255, 255, 255, 255)
    	SwissArmyKnifeContainerDaedricEmbersLabel:SetText(DaedricEmbersBag)  
	SwissArmyKnifeContainerDaedricEmbersLabel:SetColor(DaedricEmbersBag < 60 and 1 or 0,DaedricEmbersBag < 60 and 1 or 255,DaedricEmbersBag < 60 and 1 or 0, 255)

	SwissArmyKnifeContainerBankIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerBankIcon:SetTexture(SAK.iconBank)
	SwissArmyKnifeContainerBagIcon:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerBagIcon:SetTexture(SAK.iconBag)
end

function WichOneDisplay()
	if(SAK.settings.DISPLAY_DEADRIC == true) then
		EmptyWrit()
		DeadricDisplay()
	end

	if(SAK.settings.DISPLAY_POTION == true) then
		EmptyWrit()
		PotionDisplay()
	end

	if(SAK.settings.DISPLAY_SOULGEM == true) then
		EmptyWrit()
		SoulGemDisplay()
	end

	if(SAK.settings.DISPLAY_WRIT == true) then
		EmptyDisplay()
		GetWrit()
	end

	if(SAK.settings.DISPLAY_COMBAT_POPO == true) then
		EmptyWrit()
		PotionCombatDisplay()
	end

	if(SAK.settings.DISPLAY_STEALING == true) then
		EmptyWrit()
		StealingDisplay()
	end
end