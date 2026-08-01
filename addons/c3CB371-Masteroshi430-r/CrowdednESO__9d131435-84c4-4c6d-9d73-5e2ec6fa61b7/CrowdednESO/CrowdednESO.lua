CrowdednESO = {}
CrowdednESO.name = "CrowdednESO"

function CrowdednESO.start() 

   local numGuilds = GetNumGuilds()
   local total = 0
   local online = 0   

    for i=1, numGuilds do
	   local guildID = GetGuildId(i) 
	   local numMembers, numOnline = GetGuildInfo(guildID)
	   total = total + numMembers
       online = online + numOnline	   
    end
	
   local numFriends = GetNumFriends()
   
   if numFriends ~= 0 then
       for i=1, numFriends do
	   local __,__,friendStatus = GetFriendInfo(i) 
	       if friendStatus ~= PLAYER_STATUS_OFFLINE then   
               online = online + 1
           end	   
       end
     total = total + numFriends
   end
	
	
   local campaignTotal = 0
   local campaignOnline = 0 
   local campaigns = GetNumSelectionCampaigns()


	for C=1, campaigns do
         local aldPop = GetSelectionCampaignPopulationData(C,ALLIANCE_ALDMERI_DOMINION)
		 local dagPop = GetSelectionCampaignPopulationData(C,ALLIANCE_DAGGERFALL_COVENANT)
		 local eboPop = GetSelectionCampaignPopulationData(C,ALLIANCE_EBONHEART_PACT)
		 local lTotal = 1800
		 
		 campaignOnline = campaignOnline + CrowdednESO.getCampaignNumbers(aldPop) + CrowdednESO.getCampaignNumbers(dagPop) + CrowdednESO.getCampaignNumbers(eboPop)

		 campaignTotal = campaignTotal + lTotal
    end	
	
    local gOnline = online + campaignOnline
	local gTotal = total + campaignTotal


    local campaignPercentage = math.floor(campaignOnline/campaignTotal*100) 
    local guildPercentage = math.floor(online/total*100)
	
    local percentage = math.floor(gOnline/gTotal*100)
	
	if guildPercentage > campaignPercentage then -- guild population alone is more accurate for the percentage when low campaign population.   
	   percentage = guildPercentage 
	   gOnline = online
	   gTotal = total 
	end 
	
	
	local crowdMeter = " Very Low"
	if percentage > 50 then crowdMeter = " Overcrowded!" -- 24 35
	elseif percentage > 40 then crowdMeter = " Very High"
	elseif percentage > 30 then crowdMeter = " High" -- 19 28
	elseif percentage > 20 then crowdMeter = " Medium High" -- 14 21
	elseif percentage > 10 then crowdMeter = " Medium" -- 9 14
	elseif percentage > 5 then crowdMeter = " Medium Low" -- 3 7
	elseif percentage > 2 then crowdMeter = " Low" -- x 3
	end 
	
	
	CHAT_SYSTEM:AddMessage("|cC3C09CGame Crowdedness:|r |cFFFFFF"..crowdMeter.."|r |c9DFE00"..percentage.."%|r |cC3C09C("..gOnline.."/"..gTotal..")|r")
end


function CrowdednESO.getCampaignNumbers(pop)
   if pop == CAMPAIGN_POP_FULL then return 600
   elseif pop == CAMPAIGN_POP_HIGH then return 400 
   elseif pop == CAMPAIGN_POP_MEDIUM then return 200
   elseif pop == CAMPAIGN_POP_LOW then return 0
   end
end	


ZO_PreHookHandler(ZO_CampaignBrowser, "OnHide", function() CrowdednESO.start() end)
ZO_PreHookHandler(ZO_CampaignBrowser_GamepadTopLevelAvaRankFooter, "OnHide", function() CrowdednESO.start() end)


