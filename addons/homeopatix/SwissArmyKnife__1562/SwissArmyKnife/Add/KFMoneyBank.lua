-- MoneyBank Addon File
-- @author    : Homeo
-- @lastModif : 06/01/2017

--------------------
--- MONEY DEPOSIT --
--------------------
function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function DepositSavings()

	local currMoney = GetCurrentMoney()
	local currTelVar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local currAll = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
	local currWrit = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
	local gdep = currMoney - SAK.settings.MINIMUM_GOLD_SAVINGS
	local tdep = currTelVar - SAK.settings.MINIMUM_TELVAR_SAVINGS
	local adep = currAll - SAK.settings.MINIMUM_ALLIANCE_SAVINGS
	local wdep = currWrit - SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS
	local bool = false
	local dep = "Déposé en banque "

	d("**************** AUTO BANK DEPOSIT ****************")

	if(SAK.settings.DEPOSIT_MONEY == true) then
		if (currMoney > SAK.settings.MINIMUM_GOLD_SAVINGS) then
			DepositCurrencyIntoBank(CURT_MONEY,gdep)
			d(string.format("%s |cFFFFFF%s|r %s",SAK.lang.KF_RAD, comma_value(gdep), SAK.GoldIcon))
			bool = true
		end
	end

	
	if(SAK.settings.DEPOSIT_TELVAR == true) then
		if (currTelVar > SAK.settings.MINIMUM_TELVAR_SAVINGS) then
			DepositTelvarStonesIntoBank(tdep)
			d(string.format("%s |c5EA4FF%s|r %s",SAK.lang.KF_RAD, comma_value(tdep), SAK.TelVarIcon))
		end
	end

	if(SAK.settings.DEPOSIT_ALLIANCE == true) then
		if (currAll > SAK.settings.MINIMUM_ALLIANCE_SAVINGS) then
			DepositCurrencyIntoBank(CURT_ALLIANCE_POINTS, adep)
			d(string.format("%s |c33FF33%s|r %s",SAK.lang.KF_RAD, comma_value(adep), SAK.AlliIcon))
		end
	end

	if(SAK.settings.DEPOSIT_WRIT == true) then
		if (currWrit > SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS) then
			DepositCurrencyIntoBank(CURT_WRIT_VOUCHERS, wdep)
			d(string.format("%s |cFF9933%s|r %s",SAK.lang.KF_RAD, comma_value(wdep), SAK.IconVoucher))
		end
	end

	if (currTelVar <= SAK.settings.MINIMUM_TELVAR_SAVINGS) and (currMoney <= SAK.settings.MINIMUM_GOLD_SAVINGS) and (currAll <= SAK.settings.MINIMUM_ALLIANCE_SAVINGS) and (currWrit <= SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS) then
		d(SAK.lang.KF_RAD_1)
		d(string.format("%s |cFFFFFF%s|r %s, |c5EA4FF%s|r %s, |c33FF33%s|r %s %s |cFF9933%s|r %s %s",SAK.lang.KF_RAD_2, comma_value(currMoney), SAK.GoldIcon, comma_value(currTelVar), SAK.TelVarIcon, comma_value(currAll), SAK.AlliIcon, SAK.lang.KF_RAD_3, comma_value(currWrit), SAK.IconVoucher, SAK.lang.KF_RAD_4))
	end

	d("****************************************************")
end


