Set4={
	name = "Seht's Flywheel",
	nR = 4,

	rounds = {			
		--first round
		[1] = {
			nMobTot = 7,
			nWave =3,
			Waves = {
				[1] = {
					nMOB = 2,
					Mobs = {
						[1] = {posx=102225, posy=50978, posz=24896, texture = "MAHelper/Icons/Signal.dds", X=0.69166666269302,Y=0.47499999403954, c = 1}, --est
						[2] = {posx=97388, posy = 50978, posz=24948, texture = "MAHelper/Icons/Signal.dds", X=0.30000001192093,Y=0.47499999403954, c  = 1}, --ovest
					},
				},
				[2] = {
					nMOB = 3,
					Mobs = {
						[1] = {posx=99806, posy=50981, posz=27501, texture = "MAHelper/Icons/Signal2.dds", X=0.49,Y=0.67500001192093, c = 1}, --sud
						[2] = {posx=97388, posy = 50978, posz=24948, texture = "MAHelper/Icons/Signal2.dds", X=0.30000001192093,Y=0.47499999403954, c = 1},--ovest
						[3] = {posx=99808, posy=50979, posz=22435, texture = "MAHelper/Icons/Signal2.dds", X=0.49,Y=0.26666668057442 , c = 1},--nord
					},
				},
				[3] = {
					nMOB = 2,
					Mobs = {
						[1] = {posx=102225, posy=50978, posz=24896, texture = "MAHelper/Icons/BossRMael.dds",  X=0.69166666269302,Y=0.47499999403954, c = 2}, 
						[2] = {posx=99806, posy=50981, posz=27501, texture = "MAHelper/Icons/Signal3.dds",  X=0.5, Y=0.67500001192093,c = 1}, --sud
					},
				},
			},
			
		},
		--second round
		[2] = {
			nMobTot = 10,
			nWave =4,
			Waves = {
				[1] = {
					nMOB = 1,
					Mobs = {
						[1] = {posx=102225, posy=50978, posz=24896, texture = "MAHelper/Icons/Signal.dds", X=0.69166666269302,Y=0.47499999403954, c = 1}, --est
					},
				},
				[2] = {
					nMOB = 3,
					Mobs = {
						[1] = {posx=99808, posy=50979, posz=22435, texture = "MAHelper/Icons/Signal2.dds", X=0.49,Y=0.26666668057442 , c = 1},--nord
						[2] = {posx=97388, posy = 50978, posz=24948, texture = "MAHelper/Icons/Signal2.dds", X=0.30000001192093,Y=0.47499999403954, c = 1},
						[3] = {posx=99806, posy=50981, posz=27501, texture = "MAHelper/Icons/Signal2.dds",  X=0.5, Y=0.67500001192093,c = 1}, --sud
					},
				},
				[3] = {
					nMOB = 3,
					Mobs = {
						[1] = {posx=99808, posy=50979, posz=22435, texture = "MAHelper/Icons/Signal3.dds", X=0.49,Y=0.26666668057442 , c = 1},--nord
						[2] = {posx=102225, posy=50978, posz=24896, texture = "MAHelper/Icons/Signal3.dds", X=0.69166666269302,Y=0.47499999403954, c = 1}, --est
						[3] = {posx=99806, posy=50981, posz=27501, texture = "MAHelper/Icons/Signal3.dds",  X=0.5, Y=0.67500001192093,c = 1}, --sud
					},
				},				
				[4] = {
					nMOB = 3,
					Mobs = {
						[1] = {posx=102225, posy=50978, posz=24896, texture = "MAHelper/Icons/Signal4.dds",  X=0.69166666269302,Y=0.47499999403954, c = 1}, 
						[2] = {posx=99806, posy=50981, posz=27501, texture = "MAHelper/Icons/BossRMael.dds",  X=0.5, Y=0.67500001192093,c = 2}, --sud
						[3] = {posx=97388, posy = 50978, posz=24948, texture = "MAHelper/Icons/Signal4.dds", X=0.30000001192093,Y=0.47499999403954, c  = 1}, --ovest
					},
				},
			},
		},	
		--third round
		[3] = {
			nMobTot = 12,		
			nWave =3,
			Waves = {
				[1] = {
					nMOB = 3,
					Mobs = {						
						[1] = {posx=102091, posy=50978, posz=24352, texture = "MAHelper/Icons/Signal.dds", X=0.68333333730698,Y=0.42500001192093, c = 1}, 
						[2] = {posx=98284 ,posy=50978 ,posz=23600, texture = "MAHelper/Icons/Signal.dds", X=0.36666667461395,Y=0.36666667461395, c = 1},
						[3] = {posx=98648, posy=50978, posz=26537, texture = "MAHelper/Icons/Signal.dds", X=0.40000000596046,Y=0.60833334922791, c = 1},
					},
				},
				[2] = {
					nMOB = 2,
					Mobs = {
						[1] = {posx =101425,posy =50978,posz =26227,X=0.63333332538605,Y=0.58333331346512, texture = "MAHelper/Icons/Signal2.dds", c = 1 }, 
						[2] = {posx =101179,posy =50978,posz =26505,X=0.60833334922791,Y=0.60833334922791, texture = "MAHelper/Icons/Signal2.dds", c = 1 },
					},
				},
				[3] = {
					nMOB = 4,
					Mobs = {
						[1] = {posx =102233,posy =50978,posz =25632,X=0.69999998807907,Y=0.53333336114883, texture = "MAHelper/Icons/Signal5.dds", c = 1 }, 
						[2] = {posx =98571,posy =50978,posz =23375,X=0.39166668057442,Y=0.34166666865349, texture = "MAHelper/Icons/Signal5.dds", c = 1 },
						[3] = {posx =97431,posy =50978,posz =25616,X=0.30000001192093,Y=0.53333336114883, texture = "MAHelper/Icons/Signal5.dds", c = 1 },
						[4] = {posx =98211,posy =50978,posz =26318,X=0.36666667461395,Y=0.59166663885117, texture = "MAHelper/Icons/Signal5.dds", c = 1 },
					},
				},
				
				[4] = {
					nMOB = 3,
					Mobs = {
						[1] = {posx =99880,posy =50978,posz =22946,X=0.5,Y=0.30833333730698, texture = "MAHelper/Icons/BossRMael.dds", c = 2},--nord
						[2] = {posx =100237,posy =50978,posz =22894,X=0.53333336114883,Y=0.30000001192093, texture = "MAHelper/Icons/Signal4.dds", c = 1},
						[3] = {posx =99493,posy =50978,posz =22941,X=0.46666666865349,Y=0.30833333730698, texture = "MAHelper/Icons/Signal4.dds", c = 1},
					},
				},
			},
		},
		--Boss	
		[4] = {
			nWave = 1,
			Waves = {
				[1] = {
					nMOB = 1,
					Mobs = {
						[1] = {posx =101289,posy =50978,posz =24952,X=0.61666667461395,Y=0.47499999403954, texture = "MAHelper/Icons/BossMaelMegaSpider.dds", c = 3 },
					},
				},
			},
		},
	},
}
CurrWeave = 1
NumK = 0
local CurrStageArena = 1
token = true
counterCurrStageArena = 0
function Set4.OnCheckingEffect( eventCode,  changeType,  effectSlot,  effectName,  unitTag,  beginTime,  endTime,  stackCount,  iconName,  buffType,  effectType,  abilityType,  statusEffectType,  unitName,  unitId,  abilityId,  sourceUnitType)
	if effectName == "Portal Spawn" and unitName == "Clockwork Sentry"  then
		counterCurrStageArena = counterCurrStageArena +1
		MAHelper.SetText("Clockwork Sentry spawned! Kill it!")
		do return end
	end 
	if effectName == "Portal Spawn" and NumK == 0 and token then
		token = false 
		zo_callLater(function() token = true end, 4000)
	end
	if effectName == "Portal Spawn" and NumK > 0 and token then
		token = false
		NumK = NumK - Set4.rounds[CurrStageArena].Waves[CurrWeave].nMOB 
		CurrWeave = CurrWeave + 1
		MAHelper.RemoveIcons()
		MAHelper.ListAddPosition(CurrStageArena , CurrWeave)
		zo_callLater(function() token = true end, 4000)
	end
end

function  Set4.OnTitleAnnounced(eventcode, title)
	NumK  = 0
	CurrWeave = 1
	CurrStageArena = MAHelper.OnTitleReturnRound(title)
	if CurrStageArena >= 1 then
		MAHelper.RemoveIcons()
		MAHelper.ListAddPosition(CurrStageArena , 1)
	end
end


function Set4.OnUnitKilled(eventCode,   result,  isError,  abilityName,  abilityGraphic,   abilityActionSlotType,  sourceName,   sourceType,   targetName,   targetType,  hitValue,   powerType,   damageType,  log,  sourceUnitId,  targetUnitId,  abilityId,  overflow)
	if targetName == "Clockwork Sentry" then 
		counterCurrStageArena = counterCurrStageArena -3  
		if counterCurrStageArena == 0 then
			MAHelper.StopText()
		end
		do return end
	end
	if CurrStageArena == 4 then
		if  targetName ~= "The Control Guardian" then
			do return end
		else
			MAHelper.StopText()
			MAHelper.RemoveIcons()
			Set4.RegUnloadEvents()
			do return end
		end
	end
	NumK = NumK + 1
	if CurrStageArena == 3  then 
		CheckRoundFinished()
		do return end
	end
	if NumK >= Set4.rounds[CurrStageArena].Waves[CurrWeave].nMOB then
		token = false 
		zo_callLater(function() token = true end, 5000)
		MAHelper.RemoveIcons()
		CurrWeave = CurrWeave +1
		if CurrWeave <= Set4.rounds[CurrStageArena].nWave then
			NumK = 0			
			MAHelper.ListAddPosition(CurrStageArena, CurrWeave)		
		else
			NumK=0
			CurrStageArena = CurrStageArena +1
			if CurrStageArena <= Set4.nR then 			
				MAHelper.ListAddPosition(CurrStageArena, 1)	
			end
		end
	end
end


t1 = 18000
f1 = true
function CheckRoundFinished()
	if CurrWeave == 1 then 
		zo_callLater(function() Ritardato() end, r1)
		if NumK == 2 then
			f1 = false
			NumK = NumK - 3		
			MAHelper.RemoveIcons()	
			MAHelper.ListAddPosition(CurrStageArena, 2)	
			CurrWeave = CurrWeave +1
		end
		do return end
	end
	
	if CurrWeave == 2 then 
		if NumK == 2 then
			NumK = NumK - 2		
			MAHelper.RemoveIcons()
			MAHelper.ListAddPosition(CurrStageArena, 3)	
			CurrWeave = CurrWeave +1
		end
		do return end
	end
	
	if CurrWeave == 3 then 		
		if NumK == 4 then
			NumK = NumK - 4		
			MAHelper.RemoveIcons()	
			MAHelper.ListAddPosition(CurrStageArena, 4)	
			CurrWeave = CurrWeave +1
		end
	end
	if CurrWeave == 4 then 		
		if NumK == 3 then
			CurrWeave = 0
			NumK = 0	
			CurrStageArena = CurrStageArena +1
			MAHelper.RemoveIcons()			
			MAHelper.ListAddPosition(CurrStageArena, 1)	
		end
	end
end

function Ritardato()	
		if f1 then
			MAHelper.RemoveIcons()
			MAHelper.ListAddPosition(CurrStageArena, 2)	
		end
end
