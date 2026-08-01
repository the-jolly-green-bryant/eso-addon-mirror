LPEmotesTable = {}

LPEmotesTable.allEmotesTable = {}


local function AddLoopingStatusToEmotes()
	local allEmotesTable = LPEmotesTable.allEmotesTable
	allEmotesTable["/attention"]["doesLoop"] = true
	allEmotesTable["/blessing"]["doesLoop"] = true
	allEmotesTable["/kneel"]["doesLoop"] = true
	allEmotesTable["/kneelpray"]["doesLoop"] = true
	allEmotesTable["/pray"]["doesLoop"] = true
	allEmotesTable["/ritual"]["doesLoop"] = true
	allEmotesTable["/saluteloop"]["doesLoop"] = true
	allEmotesTable["/saluteloop2"]["doesLoop"] = true
	allEmotesTable["/saluteloop3"]["doesLoop"] = true
	allEmotesTable["/clap"]["doesLoop"] = true
	allEmotesTable["/handsonhips"]["doesLoop"] = true
	allEmotesTable["/impatient"]["doesLoop"] = true
	allEmotesTable["/armscrossed"]["doesLoop"] = true
	allEmotesTable["/cry"]["doesLoop"] = true
	allEmotesTable["/crying"]["doesLoop"] = true
	allEmotesTable["/downcast"]["doesLoop"] = true
	allEmotesTable["/drunk"]["doesLoop"] = true
	allEmotesTable["/heartbroken"]["doesLoop"] = true
	allEmotesTable["/humble"]["doesLoop"] = true
	allEmotesTable["/sad"]["doesLoop"] = true
	allEmotesTable["/surrender"]["doesLoop"] = true
	allEmotesTable["/celebrate"]["doesLoop"] = true
	allEmotesTable["/dance"]["doesLoop"] = true
	allEmotesTable["/dancealtmer"]["doesLoop"] = true
	allEmotesTable["/danceargonian"]["doesLoop"] = true
	allEmotesTable["/dancebosmer"]["doesLoop"] = true
	allEmotesTable["/dancebreton"]["doesLoop"] = true
	allEmotesTable["/dancedarkelf"]["doesLoop"] = true
	allEmotesTable["/dancedrunk"]["doesLoop"] = true
	allEmotesTable["/dancedunmer"]["doesLoop"] = true
	allEmotesTable["/dancehighelf"]["doesLoop"] = true
	allEmotesTable["/danceimperial"]["doesLoop"] = true
	allEmotesTable["/dancekhajiit"]["doesLoop"] = true
	allEmotesTable["/dancenord"]["doesLoop"] = true
	allEmotesTable["/danceorc"]["doesLoop"] = true
	allEmotesTable["/danceredguard"]["doesLoop"] = true
	allEmotesTable["/dancewoodelf"]["doesLoop"] = true
	allEmotesTable["/drum"]["doesLoop"] = true
	allEmotesTable["/flute"]["doesLoop"] = true
	allEmotesTable["/lute"]["doesLoop"] = true
	allEmotesTable["/juggleflame"]["doesLoop"] = true
	allEmotesTable["/drink"]["doesLoop"] = true
	allEmotesTable["/drink2"]["doesLoop"] = true
	allEmotesTable["/drink3"]["doesLoop"] = true
	allEmotesTable["/eat"]["doesLoop"] = true
	allEmotesTable["/eat2"]["doesLoop"] = true
	allEmotesTable["/eat3"]["doesLoop"] = true
	allEmotesTable["/eat4"]["doesLoop"] = true
	allEmotesTable["/eatbread"]["doesLoop"] = true
	allEmotesTable["/cower"]["doesLoop"] = true
	allEmotesTable["/crouch"]["doesLoop"] = true
	allEmotesTable["/jumpingjacks"]["doesLoop"] = true
	allEmotesTable["/lookup"]["doesLoop"] = true
	allEmotesTable["/pushup"]["doesLoop"] = true
	allEmotesTable["/pushups"]["doesLoop"] = true
	allEmotesTable["/sit"]["doesLoop"] = true
	allEmotesTable["/sit2"]["doesLoop"] = true
	allEmotesTable["/sit3"]["doesLoop"] = true
	allEmotesTable["/sit4"]["doesLoop"] = true
	allEmotesTable["/sit5"]["doesLoop"] = true
	allEmotesTable["/sit6"]["doesLoop"] = true
	allEmotesTable["/situps"]["doesLoop"] = true
	allEmotesTable["/sleep"]["doesLoop"] = true
	allEmotesTable["/sleep2"]["doesLoop"] = true
	allEmotesTable["/breathless"]["doesLoop"] = true
	allEmotesTable["/colder"]["doesLoop"] = true
	allEmotesTable["/faint"]["doesLoop"] = true
	allEmotesTable["/idle"]["doesLoop"] = true
	allEmotesTable["/idle2"]["doesLoop"] = true
	allEmotesTable["/idle3"]["doesLoop"] = true
	allEmotesTable["/idle4"]["doesLoop"] = true
	allEmotesTable["/idle5"]["doesLoop"] = true
	allEmotesTable["/knockeddown"]["doesLoop"] = true
	allEmotesTable["/leanback"]["doesLoop"] = true
	allEmotesTable["/leanbackcoin"]["doesLoop"] = true
	allEmotesTable["/leanside"]["doesLoop"] = true
	allEmotesTable["/playdead"]["doesLoop"] = true
	allEmotesTable["/sick"]["doesLoop"] = true
	allEmotesTable["/controlrod"]["doesLoop"] = true
	allEmotesTable["/hammer"]["doesLoop"] = true
	allEmotesTable["/hammerwall"]["doesLoop"] = true
	allEmotesTable["/hammerlow"]["doesLoop"] = true
	allEmotesTable["/letter"]["doesLoop"] = true
	allEmotesTable["/rake"]["doesLoop"] = true
	allEmotesTable["/read"]["doesLoop"] = true
	allEmotesTable["/shovel"]["doesLoop"] = true
	allEmotesTable["/sitchair"]["doesLoop"] = true
	allEmotesTable["/sweep"]["doesLoop"] = true
	allEmotesTable["/torch"]["doesLoop"] = true
	allEmotesTable["/wand2"]["doesLoop"] = true
	allEmotesTable["/write"]["doesLoop"] = true
	allEmotesTable["/beggar"]["doesLoop"] = true
	allEmotesTable["/kowtow"]["doesLoop"] = true
end


function LPEmotesTable.CreateAllEmotesTable()
	local slashName
	local allEmotesTable = LPEmotesTable.allEmotesTable
	for i = 1, GetNumEmotes(), 1 do
		slashName = GetEmoteSlashNameByIndex(i)
		allEmotesTable[slashName] = {
			["index"] = i
		}
	end
	AddLoopingStatusToEmotes()
end