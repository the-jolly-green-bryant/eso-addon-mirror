--TEST TEST TEST TEST
function ElderScrollsOfAlts:DelTestData1()
  local pName = "Test1 McTesty1"
  if(ElderScrollsOfAlts.altData.players[pName] ~= nil) then
    ElderScrollsOfAlts.altData.players[pName] = {}
  end
  pName = "Perpugilliam Brown"
  if(ElderScrollsOfAlts.altData.players[pName] ~= nil) then
    ElderScrollsOfAlts.altData.players[pName] = {}
  end
  pName = "Very very long named character"
  if(ElderScrollsOfAlts.altData.players[pName] ~= nil) then
    ElderScrollsOfAlts.altData.players[pName] = {}
  end
end

function ElderScrollsOfAlts:LoadTestData1()
  local newPlayer = ElderScrollsOfAlts:deepcopy(ElderScrollsOfAlts.altData.players[1])
  newPlayer.name = "Very very long named character"
  table.insert( ElderScrollsOfAlts.altData.players, newPlayer)
end

 
function ElderScrollsOfAlts:ChangeESOAFontGame()
	local ef1 = ESOAFontGame --.font
	
    ElderScrollsOfAlts.debugMsg("ef1='"..tostring(ef1).."'")
    ElderScrollsOfAlts.debugMsg("ef1='"..tostring(ef1.font).."'")
    ElderScrollsOfAlts.debugMsg("ef1='"..tostring(ef1[0]).."'")
	ElderScrollsOfAlts.debugMsg("ef1='"..tostring(ef1[1]).."'")
	ElderScrollsOfAlts.debugMsg("ef1='"..tostring(ef1[2]).."'")
	
	ElderScrollsOfAlts.esoaFontGame[ ElderScrollsOfAlts.FONT_SIZE ] = "$(KB_20)"
	local fontGame = ElderScrollsOfAlts:GetFontDescriptor( ElderScrollsOfAlts.esoaFontGame )
	--$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin
	--local font = {value:GetFontInfo()}
	--ESOA_RowTemplate_Label	
	d("font fontGame='"..(fontGame).."'")
	for dHL = 1, #ESOA_GUI2_Body_ListHolder.dataHolderLines do
		local dataLine = ESOA_GUI2_Body_ListHolder.dataHolderLines[dHL] --ESOA_RowTemplate
		if(dataLine~=nil and dataLine.displayedEntries~=nil)then
			for k, dLine in pairs(dataLine.displayedEntries) do
				if(dLine~=nil) then
					--dLine:SetHidden(true)
					--d("font dLine='"..tostring(dLine).."'")
					--d("font linetype='"..tostring(dLine.linetype).."'")
					if(dLine.linetype=='label' or dLine.linetype=='name' ) then 					
						dLine:SetFont(fontGame)
						--d("font dLine set font done")
					end
				end
			end  
		end
	end
end

-- 81,732 - 67,332 = 14,400
function ElderScrollsOfAlts:TestTime1()
	local lhs = (GetTimeStamp() % 86400)
	d("lhs="..lhs)
	local secondsSinceMidnight = GetSecondsSinceMidnight()
	d("secondsSinceMidnight="..secondsSinceMidnight)
	local localTimeShift = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
	d("localTimeShift="..localTimeShift)
	if localTimeShift < -12 * 60 * 60 then 
		localTimeShift = localTimeShift + 86400
		d("localTimeShift="..localTimeShift)
	end
end

-- 
function ElderScrollsOfAlts:TestLaunder()
	--** _Returns:_ *integer* _totalLaunders_, *integer* _laundersUsed_, *integer* _resetTimeSeconds_
	local totalLaunders, laundersUsed, resetTimeSeconds = GetFenceLaunderTransactionInfo()
	d("totalLaunders="..tostring(totalLaunders))
	d("laundersUsed="..tostring(laundersUsed))
	d("resetTimeSeconds="..tostring(resetTimeSeconds))
	
	--
	--** _Returns:_ *integer* _totalSells_, *integer* _sellsUsed_, *integer* _resetTimeSeconds_
	local totalSells, sellsUsed, resetTimeSeconds2 = GetFenceSellTransactionInfo()
	d("totalSells="..tostring(totalSells))
	d("sellsUsed="..tostring(sellsUsed))
	d("resetTimeSeconds2="..tostring(resetTimeSeconds2))
	--
end 

--TEST TEST TEST TEST