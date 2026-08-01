-- Local variables
local isregain = false
local str = DuelRPG.Strings[DuelRPG.GetLanguage()].TEXT
local _

-- DuelRPG Declaration
if DuelRPG == nil then DuelRPG = {} end

function DuelRPG.drpgregain()
	local timestampcalc = GetTimeStamp()
	local regainlife = 0
	
	timestampcalc = GetTimeStamp() - DuelRPG.settings.timestamp
	regainlife = zo_round(timestampcalc/3600)

	if DuelRPG.GetLife() < DuelRPG.GetMaxLife() then
		
		if regainlife > 0 then		
			DuelRPG.settings.timestamp = GetTimeStamp()
		end
	
		if DuelRPG.GetLife() + regainlife > DuelRPG.GetMaxLife() then
			isregain = true
			DuelRPG.settings.lifem = 0
		else
			isregain = true
			DuelRPG.settings.lifem = DuelRPG.settings.lifem - regainlife
		end
	else
		DuelRPG.settings.timestamp = GetTimeStamp()
	end
	
	if isregain and regainlife > 0 then	
		if DuelRPG.GetLife() == DuelRPG.GetMaxLife() then
			isregain = false			
			infostring = str.strprefix..str.strlifeprefix..str.strlifeend1
			d(infostring)
		else
			infostring = str.strprefix..str.strlifeprefix..regainlife..str.strlifeend2
			d(infostring)
		end
	end
	
end	

function DuelRPG.OnItemSlotChanged(eventId, bagId, slotId, isNewItem)	
	
	DuelRPG.GetMultiArmor()
	
end