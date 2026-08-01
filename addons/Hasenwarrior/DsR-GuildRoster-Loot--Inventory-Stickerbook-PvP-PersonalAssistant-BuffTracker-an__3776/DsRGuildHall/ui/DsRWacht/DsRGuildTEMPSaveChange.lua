-- Create namespace
DsRGuildTEMPSaveChange = {}
local DsRGuildTEMPSaveChange = DsRGuildTEMPSaveChange or {}

DsRGuildTEMPSaveChange.name = "DsRGuildTEMPSaveChange"

function DsRGuildTEMPSaveChange.ChangeALL()
    zo_callLater(function() 
        if DsRVersion.UpdateVersion.UV ~= DsRGuildHall.version then
            for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
                local TROPHY_SURVEY_REPORT = DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT]             
                if TROPHY_SURVEY_REPORT == "nichts machen" or TROPHY_SURVEY_REPORT == "Do Nothing" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] = 1
                elseif TROPHY_SURVEY_REPORT == "|cFAA0A0In die Bank" or TROPHY_SURVEY_REPORT == "|cFAA0A0Deposit to Bank" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] = 2
                elseif TROPHY_SURVEY_REPORT == "|c35fc38Ins Inventar" or TROPHY_SURVEY_REPORT == "|c35fc38Withdraw to Backpack" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] = 3
                end

                local TROPHY_TREASURE_MAP = DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP]             
                if TROPHY_TREASURE_MAP == "nichts machen" or TROPHY_TREASURE_MAP == "Do Nothing" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = 1
                elseif TROPHY_TREASURE_MAP == "|cFAA0A0In die Bank" or TROPHY_TREASURE_MAP == "|cFAA0A0Deposit to Bank" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = 2
                elseif TROPHY_TREASURE_MAP == "|c35fc38Ins Inventar" or TROPHY_TREASURE_MAP == "|c35fc38Withdraw to Backpack" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = 3
                end

                local MASTER_WRIT = DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT]             
                if MASTER_WRIT == "nichts machen" or MASTER_WRIT == "Do Nothing" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] = 1
                elseif MASTER_WRIT == "|cFAA0A0In die Bank" or MASTER_WRIT == "|cFAA0A0Deposit to Bank" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] = 2
                elseif MASTER_WRIT == "|c35fc38Ins Inventar" or MASTER_WRIT == "|c35fc38Withdraw to Backpack" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] = 3
                end

                local TROPHY_RECIPE_FRAGMENT = DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT]             
                if TROPHY_RECIPE_FRAGMENT == "nichts machen" or TROPHY_RECIPE_FRAGMENT == "Do Nothing" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] = 1
                elseif TROPHY_RECIPE_FRAGMENT == "|cFAA0A0In die Bank" or TROPHY_RECIPE_FRAGMENT == "|cFAA0A0Deposit to Bank" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] = 2
                elseif TROPHY_RECIPE_FRAGMENT == "|c35fc38Ins Inventar" or TROPHY_RECIPE_FRAGMENT == "|c35fc38Withdraw to Backpack" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] = 3
                end

                local TROPHY_RUNEBOX_FRAGMENT = DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT]             
                if TROPHY_RUNEBOX_FRAGMENT == "nichts machen" or TROPHY_RUNEBOX_FRAGMENT == "Do Nothing" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] = 1
                elseif TROPHY_RUNEBOX_FRAGMENT == "|cFAA0A0In die Bank" or TROPHY_RUNEBOX_FRAGMENT == "|cFAA0A0Deposit to Bank" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] = 2
                elseif TROPHY_RUNEBOX_FRAGMENT == "|c35fc38Ins Inventar" or TROPHY_RUNEBOX_FRAGMENT == "|c35fc38Withdraw to Backpack" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] = 3
                end

                local TROPHY_COLLECTIBLE_FRAGMENT = DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT]             
                if TROPHY_COLLECTIBLE_FRAGMENT == "nichts machen" or TROPHY_COLLECTIBLE_FRAGMENT == "Do Nothing" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] = 1
                elseif TROPHY_COLLECTIBLE_FRAGMENT == "|cFAA0A0In die Bank" or TROPHY_COLLECTIBLE_FRAGMENT == "|cFAA0A0Deposit to Bank" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] = 2
                elseif TROPHY_COLLECTIBLE_FRAGMENT == "|c35fc38Ins Inventar" or TROPHY_COLLECTIBLE_FRAGMENT == "|c35fc38Withdraw to Backpack" then
                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] = 3
                end

                local siegeItems   = DsRGuildPersonalGlobals.SiegeWeapons[ALLIANCE_ALDMERI_DOMINION]
				for key, value in ipairs(siegeItems) do
                    local CheckName = "check"..value.settingName
					local CheckName = DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["BankingAvA"]["depo"..value.settingName]

                    if CheckName == "nichts machen" or CheckName == "Do Nothing" then 
                        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["BankingAvA"]["depo"..value.settingName] = 1
                    elseif CheckName == "|cFAA0A0In die Bank" or CheckName == "|cFAA0A0Deposit to Bank" then
                        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["BankingAvA"]["depo"..value.settingName] = 2
                    elseif CheckName == "|c35fc38Ins Inventar" or CheckName == "|c35fc38Withdraw to Backpack" then
                        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["BankingAvA"]["depo"..value.settingName] = 3
                    end
				end
            end
        end
    end, 250)
end
