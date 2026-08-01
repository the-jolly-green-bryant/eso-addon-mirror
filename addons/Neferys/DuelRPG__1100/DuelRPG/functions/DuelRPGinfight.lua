-- Local variables
local charname = GetUnitName("player")
local chararraylist={}
local charcreate = false
local charcurrentchar
local str = DuelRPG.Strings[DuelRPG.GetLanguage()].TEXT
local com = DuelRPG.Strings[DuelRPG.GetLanguage()].COMMANDS
local _

-- DuelRPG Declaration
if DuelRPG == nil then DuelRPG = {} end

function DuelRPG.Dice(type,advname)
	local upper = 20
	local infostring = ""
	local operastring = "+"
	
	if type == "init" then
		local resultdice = zo_random(1, upper)
		local resultotal = resultdice + DuelRPG.GetMultiDexPerso()
		
		if resultotal < 1 then
			resultotal = 1
		end
		
		if DuelRPG.GetMultiDexPerso() >= 0 then
			operastring = "+"
		else
			operastring = ""
		end
		
		infostring = str.strprefix..com.strdrpginitlaunch..charname .." : "..resultotal.." ("..resultdice..operastring..DuelRPG.GetMultiDexPerso()..")"
		StartChatInput(infostring, CHAT_CHANNEL_PARTY)
	end
	
	
	if type == "cac" or type == "dist" or type == "magie" then
		local nameadv = advname
		local caadv = chararraylist[nameadv].ca			
		local damage
		local invalid = false
		local resultdiceattaque
		local resuldicedegatmg
		local resuldicedegatmd
		local resultotalattaque		
		local resultotaldegat
		local attaquestring = ""
		local degatstring = ""
		local typestring = ""
		local multimg = 0
		local multimd = 0
		local multico = 0
		local damaweaponmg = DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetMainWeapon()].damaweapon
		local typeweaponmg = DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetMainWeapon()].typeweapon
		local nbhaweaponmg = DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetMainWeapon()].nbhaweapon
		local damaweaponmd = DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetOffWeapon()].damaweapon
		local typeweaponmd = DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetOffWeapon()].typeweapon
		local nbhaweaponmd = DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetOffWeapon()].nbhaweapon
		
		if type == "cac" and typeweaponmg == 2 then
			invalid = true
			infostring = str.strprefix..com.strdrpgcacerror
		end
		
		if type == "dist" and typeweaponmg == 1 then
			invalid = true
			infostring = str.strprefix..com.strdrpgdisterror
		end
		
		if not invalid then
			infostring = str.strprefix..charname.." ("..str.strlvl.." : "..DuelRPG.settings.level.." - "..str.strca2.." : "..DuelRPG.GetTotArmor().." - "..str.strlife.." : "..DuelRPG.GetLife()..") "..str.strattack.." "..nameadv.." ("..str.strca2.." = "..caadv.."). "
		
			if type == "cac" then		
				if nbhaweaponmg == 2 then					
					if DuelRPG.GetMultiCacPerso() >= 0 then	
						operastring = "+"
						multimg = zo_round(DuelRPG.GetMultiCacPerso() * 1.5)
					else
						operastring = ""
						multimg = DuelRPG.GetMultiCacPerso()
					end	
				else
					if DuelRPG.GetMultiCacPerso() >= 0 then	
						operastring = "+"
						multimg = DuelRPG.GetMultiCacPerso()
						multimd = zo_round(DuelRPG.GetMultiCacPerso() / 2)
					else
						operastring = ""
						multimg = DuelRPG.GetMultiCacPerso()
						multimd = DuelRPG.GetMultiCacPerso()
					end	
				end
				
				multico = DuelRPG.GetMultiCacPerso()
				typestring = str.strattackcac
			end
				
			if type == "dist" then				
				if DuelRPG.GetMultiDisPerso() >= 0 then	
					operastring = "+"
					multimg = zo_round(DuelRPG.GetMultiDisPerso() * 1.5)
				else
					operastring = ""
					multimg = DuelRPG.GetMultiDisPerso()
				end	
				
				multico = DuelRPG.GetMultiDisPerso()
				typestring = str.strattackdis
			end
			
			if type == "magie" then
				if DuelRPG.GetMultiMagPerso() >= 0 then	
					operastring = "+"
					multimg = zo_round(DuelRPG.GetMultiMagPerso() * 1.5)
				else
					operastring = ""
					multimg = DuelRPG.GetMultiMagPerso()
				end	
				
				multico = DuelRPG.GetMultiMagPerso()
				typestring = str.strattackmag
			end
		
			resultdiceattaque = zo_random(1, upper)
			resultotalattaque = resultdiceattaque + multico
			
			if resultotalattaque < 1 then
				resultotalattaque = 1
			end
			
			attaquestring = com.strattackroll..typestring..resultotalattaque.." ("..resultdiceattaque..""..operastring..""..multico..")"
			
			if nbhaweaponmg == 2 or (nbhaweaponmg==1 and typeweaponmd==0) then
				resuldicedegatmg = zo_random(1, damaweaponmg)
				resultotaldegat = resuldicedegatmg + multimg

				if resultotaldegat < 1 then
					resultotaldegat = 1
				end
				
				degatstring = com.strdegatroll..typestring..resultotaldegat.." ("..resuldicedegatmg..operastring..multimg.."). "
			else
				resuldicedegatmg = zo_random(1, damaweaponmg)
				resuldicedegatmd = zo_random(1, damaweaponmd)
				resultotaldegatmg = resuldicedegatmg + multimg
				resultotaldegatmd = resuldicedegatmd + multimd
				
				if resultotaldegatmg < 1 then
					resultotaldegatmg = 1
				end
				
				if resultotaldegatmd < 1 then
					resultotaldegatmd = 1
				end
				
				resultotaldegat = resultotaldegatmd + resultotaldegatmg

				degatstring = com.strdegatroll..typestring..resultotaldegat.." ("..resuldicedegatmg..operastring..multimg..", "..resuldicedegatmd..operastring..multimd.."). "
			end
						
			if resultotalattaque < tonumber(caadv) then
				infostring = infostring..attaquestring..str.strko
				StartChatInput(infostring, CHAT_CHANNEL_PARTY)
			else
				infostring = infostring..attaquestring..str.strok..degatstring..nameadv..str.strko2..resultotaldegat..str.strlifeend2
				StartChatInput(infostring, CHAT_CHANNEL_PARTY)
			end
		end	
	end

	d(infostring)
	
end

function DuelRPG.drpginfo()
	local infostring = str.strprefix..charname.." : "..str.strlvl.." = "..DuelRPG.settings.level..", "..str.strlife.." = "..DuelRPG.GetLife().." (= 10 + "..DuelRPG.GetAttrEndPerso().." + "..DuelRPG.GetMultiEndPerso().."), "..str.strca2.." = "..DuelRPG.GetTotArmor().." (= 10 + "..DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_ARMOR[DuelRPG.GetArmor()].defearmor + DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetMainWeapon()].armoweapon + DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetOffWeapon()].armoweapon.." + "..DuelRPG.GetMultiArmor()..")"
	StartChatInput(infostring, CHAT_CHANNEL_PARTY)
	d(infostring)
end

function DuelRPG.drpgaddchar(value)
	local infostring = ""	
	if value == "" then
		infostring = str.strprefix..str.strcommfailed1..DuelRPG.settings.drpgaddchar.." Bob"
	else
		if not charcreate then
			charcurrentchar = value
			charcreate = true
			infostring = str.strprefix..str.strcharacter..value.." "..str.strcharcrea3..".\nEx : /"..DuelRPG.settings.drpgaddcharca.." 10 (10 = "..str.stroppca..")"
			StartChatInput("/"..DuelRPG.settings.drpgaddcharca.." ", CHAT_CHANNEL_PARTY)
		else
			infostring = str.strprefix..str.strcharcrea1.." ("..charcurrentchar..")"
		end
	end
		
	d(infostring)	
end

function DuelRPG.drpgaddcharca(value)
	local infostring = ""
	if value == "" or tonumber(value) < 10 then
		if value == "" then
			infostring = str.strprefix..str.strcommfailed1..DuelRPG.settings.drpgaddcharca.." 10 (10 = "..str.stroppca..")"
		else
			infostring = str.strprefix..str.strcommfailed2.." 10.\nEx : /"..DuelRPG.settings.drpgaddcharca.." 10 (10 = "..str.stroppca..")"
		end
	else
		if charcreate then
			chararraylist[charcurrentchar] = {ca = value}
			charcreate = false	
			infostring = str.strprefix..str.strcharacter..charcurrentchar..str.strcharcrea4..value
		else
			infostring = str.strprefix..str.strcharcrea0..".\nEx : /"..DuelRPG.settings.drpgaddchar.." Bob"
		end
	end
		
	d(infostring)
end

function DuelRPG.drpgdelchar()
	local infostring = ""
	charcurrentchar = null
	charcreate = false
	chararraylist = {}
	infostring = str.strprefix..str.stroppdelete
	d(infostring)
end
  
function DuelRPG.drpginit()	
	DuelRPG.Dice("init")
end

function DuelRPG.drpgcac(advname)
	local infostring = ""
	local attfailed = false
	
	if charcreate then
		attfailed = true
		infostring = str.strprefix..str.strcharcrea1.." ("..charcurrentchar.."). "..str.strcharcrea2
		d(infostring)
	end
	
	if charcurrentchar == nil and not attfailed then
		attfailed = true
		infostring = str.strprefix..str.stroppneedcreate
		d(infostring)
	end
	
	if not attfailed then	
		if advname == "" then
			if chararraylist[charcurrentchar] == nil then
				attfailed = true
				infostring = str.strprefix..str.strcharacter..charcurrentchar..str.stropplist1
				d(infostring)
			else
				DuelRPG.Dice("cac",charcurrentchar)
			end
		else
			if chararraylist[advname] == nil then
				attfailed = true
				infostring = str.strprefix..str.strcharacter..advname..str.stropplist1
				d(infostring)
			else
				DuelRPG.Dice("cac",advname)
			end
		end
	end
end

function DuelRPG.drpgdist(advname)
	local infostring = ""
	local attfailed = false
	
	if charcreate then
		attfailed = true
		infostring = str.strprefix..str.strcharcrea1.." ("..charcurrentchar.."). "..str.strcharcrea2
		d(infostring)
	end
	
	if charcurrentchar == nil and not attfailed then
		attfailed = true
		infostring = str.strprefix..str.stroppneedcreate
		d(infostring)
	end
	
	if not attfailed then	
		if advname == "" then
			if chararraylist[charcurrentchar] == nil then
				attfailed = true
				infostring = str.strprefix..str.strcharacter..charcurrentchar..str.stropplist1
				d(infostring)
			else
				DuelRPG.Dice("dist",charcurrentchar)
			end
		else
			if chararraylist[advname] == nil then
				attfailed = true
				infostring = str.strprefix..str.strcharacter..advname..str.stropplist1
				d(infostring)
			else
				DuelRPG.Dice("dist",advname)
			end
		end
	end
end

function DuelRPG.drpgmagie(advname)
	local infostring = ""
	local attfailed = false
	
	if charcreate then
		attfailed = true
		infostring = str.strprefix..str.strcharcrea1.." ("..charcurrentchar.."). "..str.strcharcrea2
		d(infostring)
	end
	
	if charcurrentchar == nil and not attfailed then
		attfailed = true
		infostring = str.strprefix..str.stroppneedcreate
		d(infostring)
	end
	
	if not attfailed then	
		if advname == "" then
			if chararraylist[charcurrentchar] == nil then
				attfailed = true
				infostring = str.strprefix..str.strcharacter..charcurrentchar..str.stropplist1
				d(infostring)
			else
				DuelRPG.Dice("magie",charcurrentchar)
			end
		else
			if chararraylist[advname] == nil then
				attfailed = true
				infostring = str.strprefix..str.strcharacter..advname..str.stropplist1
				d(infostring)
			else
				DuelRPG.Dice("magie",advname)
			end
		end
	end
end

function DuelRPG.drpgdegat(value)
	local state = 0
	local command = ""
	local infostring = ""
	if value == "" or tonumber(value) < 1 then
		if value == "" then
			infostring = str.strprefix..str.strcommfailed1..DuelRPG.settings.drpgdegat.." 3 (3 = "..str.strlifelost..")"
			d(infostring)
		else
			infostring = str.strprefix..str.strcommfailed2.." 0.\nEx : /"..DuelRPG.settings.drpgdegat.." 3 (3 = "..str.strlifelost..")"
			d(infostring)
		end
	else
		isinit = false
		
		if DuelRPG.GetLife() - value < -9 then
			DuelRPG.settings.lifem = DuelRPG.GetMaxLife() + 10
		else
			DuelRPG.settings.lifem = DuelRPG.settings.lifem + value
		end
		
		infostring = str.strprefix..str.strcharacter..charname..str.strcharlost1..value..str.strlifeend2
		d(infostring)
		StartChatInput(infostring, CHAT_CHANNEL_PARTY)
		
		if DuelRPG.GetLife() > 0 and DuelRPG.GetLife() < 4 then	
			command = "/sick"
			infostring = str.strprefix..str.strstage1
			DoCommand(command)
			d(infostring)
		end
		
		
		if DuelRPG.GetLife() < 1 and DuelRPG.GetLife() > -10 then	
			command = "/sleep2"
			infostring = str.strprefix..str.strstage2
			DoCommand(command)
			d(infostring)
		end
		
		if DuelRPG.GetLife() < -9 then	
			command = "/playdead"
			infostring = str.strprefix..str.strstage3
			DoCommand(command)
			d(infostring)
		end
	end
end