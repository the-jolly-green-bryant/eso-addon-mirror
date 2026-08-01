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

  
  --TEST TEST TEST TEST