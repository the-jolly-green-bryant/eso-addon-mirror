local ADDON_NAME,VERSION="MinerMiniGame",1.5
local work,anim_step=false,1
local Animated=false
local STEPS=30
local bar_w=70
local Skills_init=false
local COIN="|t16:16:/esoui/art/currency/gold_mipmap.dds|t"
local GEM="|t16:16:/esoui/art/icons/crafting_jewelry_base_emerald_r2.dds|t"
local BASE_SIZE=100
local CART_SIZE=BASE_SIZE
local BASE_SPEED=1000/4
local BASE_STAMINA,BASE_PICKAXE=50,100
local POTION_VALUE=BASE_STAMINA/2
local POTION_PRICE=2
local PICKAXE_PRICE=10
local WORKER_PRICE=2000
local Stamina=BASE_STAMINA
local SavedVars
local Gems={
"/esoui/art/icons/crafting_jewelry_base_amethyst_r3.dds",
"/esoui/art/icons/crafting_jewelry_base_diamond_r3.dds",
"/esoui/art/icons/crafting_jewelry_base_emerald_r2.dds",
"/esoui/art/icons/crafting_jewelry_base_garnet_r3.dds",
"/esoui/art/icons/crafting_jewelry_base_ruby_r3.dds",
"/esoui/art/icons/crafting_jewelry_base_turquoise_r3.dds"
}
local Gem_Path={{},{}}
local Reset={
--Stats
	Pickaxe	=true,
--Skills
	Vitality	=true,
	Speed		=true,
	Accuracy	=true,
	UsePotion	=true,
	UsePickaxe	=true,
	DoubleSwing	=0,

	Wisdom	=true,
	Mining	=true,
	Trading	=true,
	AutoSell	=true,
	AutoBuy	=true,
	CartSize	=0,
--Skill points
	P_Vit		=true,
	P_Wis		=true,
}
local Default={
	Minimized	=false,
	Position	={BOTTOMRIGHT,GuiRoot,BOTTOMRIGHT,-300,-10},
	LastSale	=0,
--Resources
	Gold		=0,
	Potions	=0,	--99
	Gems		=0,	--CART_SIZE
	Workers	=0,
--Stats
	Pickaxe	=BASE_PICKAXE,
	Traveling	=false,
--Skills
	Vitality	=0,
	Speed		=0,	--10
	Accuracy	=0,	--10
	UsePotion	=false,
	UsePickaxe	=false,
	DoubleSwing	=0,

	Wisdom	=0,
	Mining	=0,	--10
	Trading	=0,	--10
	AutoBuy	=false,
	AutoSell	=false,
	CartSize	=0,

	Traders	=0,
	Esquire	=false,
	Carrier	=false,
--Skill points
	P_Vit		=0,
	P_Wis		=0,
}
local Icons={
	Vitality	="esoui/art/icons/ability_buff_minor_force.dds",
	Speed		="esoui/art/icons/ability_warrior_029.dds",
	Accuracy	="esoui/art/icons/ability_warrior_034.dds",
	UsePotion	="esoui/art/icons/placeholder/icon_potion_full.dds",
	UsePickaxe	="esoui/art/icons/placeholder/icon_weapon_axe01.dds",
	DoubleSwing	="esoui/art/icons/ability_warrior_016.dds",

	Wisdom	="esoui/art/icons/ability_mage_045.dds",
	Mining	="esoui/art/icons/ability_buff_major_brutality.dds",
	Trading	="esoui/art/icons/ability_mageguild_003.dds",
	AutoSell	="esoui/art/icons/housing_gen_csb_minecart001.dds",
	AutoBuy	="esoui/art/vendor/vendor_tabicon_buyback_up.dds",
	CartSize	="esoui/art/icons/delivery_box_001.dds",

	Traders	="esoui/art/icons/ability_mageguild_003_a.dds",
	Esquire	="esoui/art/icons/ability_mage_060.dds",
	Carrier	="esoui/art/icons/ability_warrior_011.dds",
}
local Localization={
	en={
		Tooltip={
			Vitality	="Worer vitality.\nReduces stamina consumption, increases potion efficiency.",
			Speed		="Worer speed.\nIncreases work and travel speed.",
			Accuracy	="Worer accuracy.\nReduces chance to damage pickaxe.",
			UsePotion	="Auto use potion when stamina drops to 0.\nCost: 10 vitality points.",
			UsePickaxe	="Auto buy new pickaxe when it destroyed.\nCost: 10 vitality points.",
			DoubleSwing	="Crushing blow.\nChance to take double effect from one swing (%).\nCost: 10 vitality points.",

			Wisdom	="Worker wisdom.\nEffects on chance to dig a gemstone and selling price.",
			Mining	="Worker mining skill.\nIncreases chance to dig a gemstone.",
			Trading	="Worker trading skill.\nIncrease selling price. Do not affects additional workers.",
			AutoSell	="Auto sell gemstones when cart is full.\nCost: 10 wisdom points.",
			AutoBuy	="Auto buy new potions when it's count drops to 0.\nCost: 10 wisdom points.",
			CartSize	="Cart size.\nCost: 10 wisdom points.\nCurrent: ",

			Traders	="Traders.\nIncrease offline income by 10%\nCost: 1 worker.\nCurrent: ",
			Esquire	="Esquire.\nDeliver new pickaxe wen old is destroyed.\nCost: 1 worker.",
			Carrier	="Carrier. Auto sell gemstones when cart is full.\nCost: 1 worker.",
		},
		Header	="Miner skills",
		SkillsTree	="Skills tree",
		PotionUse	="Use potion",
		PickaxeBuy	="Buy new pickaxe.\nCost: ",
		CartTravel	="Sell all gemstones.\nAmount: ",
		PotionBuy	="Buy potion.\nCost: ",
		WorkerHire	="Hire new worker.\nNew worker will have no skills. Each additional worker will sell mined gemstones each 30 min. They also works offline with lowered efficiency.\nCost: "
	},
	ru={
		Tooltip={
			Vitality	="Энергичность работника.\nУвеличивает выносливость и эффективность зелий.",
			Speed		="Скорость работника.\nУвеличивает скорость работы и передвижения.",
			Accuracy	="Аккуратность работника.\nСнижает шанс повредить кирку.",
			UsePotion	="Автоматическое использование зелья когда заканчивается выносливость.\nСтоимость: 10 очков энергичности.",
			UsePickaxe	="Автоматическая покупка новой кирки.\nСтоимость: 10 очков энергичности.",
			DoubleSwing	="Сокрушающий удар.\nШанс получить двойной эффект от одного замаха (%).\nСтоимость: 10 очков энергичности.",

			Wisdom	="Мудрость работника.\nВлияет на шанс добычи драгоценных камней и доход с продаж.",
			Mining	="Горное дело.\nВлияет на шанс добычи драгоценных камней.",
			Trading	="Способность работника торговаться.\nУвеличивает доход с продажи драгоценных камней. Не влияет на дополнительных работников.",
			AutoSell	="Автоматическая продажа драгоценных камней когда тележка заполнена.\nСтоимость: 10 очков мудрости.",
			AutoBuy	="Автоматическая покупка зелий когда они заканчиваются.\nСтоимость: 10 очков мудрости.",
			CartSize	="Размер тележки.\nСтоимость: 10 очков мудрости.\nТекущий размер: ",

			Traders	="Торговцы.\nУвеличение дохода вне игры на 10%\nСтоимость: 1 работник.\nТекущий размер: ",
			Esquire	="Помощник.\nDeviver new pickaxe wen old is destroyed.\nСтоимость: 1 работник.",
			Carrier	="Автоматическая продажа драгоценных камней когда тележка заполнена.\nСтоимость: 1 работник.",
		},
		Header	="Способности работника",
		SkillsTree	="Дерево умений",
		PotionUse	="Использовать зелье",
		PickaxeBuy	="Купить новую крику.\nСтоимость: ",
		CartTravel	="Продать драгоценные камни.\nКоличество: ",
		PotionBuy	="Купить зелье.\nСтоимость: ",
		WorkerHire	="Нанять нового работника.\nНовый работник не будет обладать навыками. Дополнительные работники будут приносить прибыль с продажи драгоценных камней каждые 30 минут. Вне игры работа так же продолжается но со сниженной эффективностью.\nСтоимость: "
	}
}
local lang=GetCVar("language.2") if not Localization[lang] then lang="en" end
local PickaxeBuy,PotionBuy,PotionUse,WorkerHire,SwitchWork,CartTravel
--Functions
local function WorkerCost()
	return WORKER_PRICE+WORKER_PRICE/2*SavedVars.Workers^2
end

local function WorkersIncome()
	return math.floor(SavedVars.Workers*CART_SIZE*(1+math.random()*.5))
end

local function HeaderChange()
	n=tostring(SavedVars.Gold)
	local k=1
	while k~=0 do n,k=string.gsub(n,"^(-?%d+)(%d%d%d)", '%1\'%2') end

	Miner_Header_Label:SetText(COIN.." "..n.." |t16:16:/esoui/art/tutorial/pointsplus_up.dds|t "..math.floor(SavedVars.P_Vit)+math.floor(SavedVars.P_Wis))

	if Miner_Skills_Vit_Val then Miner_Skills_Vit_Val:SetText(math.floor(SavedVars.P_Vit)) end
	if Miner_Skills_Wis_Val then Miner_Skills_Wis_Val:SetText(math.floor(SavedVars.P_Wis)) end
end

local function DimondsChange()
	Miner_Diamond_Bar:SetWidth((bar_w-4)*SavedVars.Gems/CART_SIZE)
end

local function DimondsSell()
	SavedVars.Gold=math.floor(SavedVars.Gold+SavedVars.Gems*(1+math.random()*(.5+SavedVars.Trading/10+math.min(SavedVars.Wisdom,100)/100)))
	SavedVars.Gems=0
	DimondsChange()
	HeaderChange()
end

local function PickaxeChange()
	Miner_Pickaxe_Bar:SetWidth((bar_w-4)*SavedVars.Pickaxe/BASE_PICKAXE)
end

local function FlyAnimation(path)
	if Animated or SavedVars.Minimized then return end
	Animated=true
	local gem=math.floor(1+math.random()*6)
	Miner_Animation:SetTexture(Gems[gem])
	Miner_Animation:ClearAnchors()
	Miner_Animation:SetAnchor(TOPLEFT,nil,TOPLEFT,path[2][1],path[2][2])
	Miner_Animation:SetHidden(false)
--	Miner_Animation_Glow:SetHidden(false)
	local step=1
	local dx,dy=(path[1][1]-path[2][1])/STEPS,(path[1][2]-path[2][2])/STEPS
	local function Animation()
		Miner_Animation:ClearAnchors()
		Miner_Animation:SetAnchor(TOPLEFT,nil,TOPLEFT,path[2][1]+dx*step,path[2][2]+dy*step)
--		Miner_Animation_Glow:ClearAnchors()
--		Miner_Animation_Glow:SetAnchor(TOPLEFT,nil,TOPLEFT,path[2][1]+dx*(step-1)+2,path[2][2]+dy*(step-1)+2)
		step=step+1
		if step>STEPS then
			Miner_Animation:SetHidden(true)
--			Miner_Animation_Glow:SetHidden(true)
			EVENT_MANAGER:UnregisterForUpdate("Miner_Loop_Anim")
			Animated=false
		end
	end
	EVENT_MANAGER:RegisterForUpdate("Miner_Loop_Anim",600/STEPS,Animation)
end

--Management
PickaxeBuy=function()
	if SavedVars.Pickaxe==BASE_PICKAXE then return end
	SavedVars.Gold=SavedVars.Gold-10
	SavedVars.Pickaxe=BASE_PICKAXE
	PickaxeChange()
	HeaderChange()
	if not work then
		Miner_Status:SetColor(.6,.57,.46,1)
		SwitchWork()
	end
end

PotionBuy=function(self,_,_,_,shift)
	if SavedVars.Gold<POTION_PRICE or SavedVars.Potions>=99 then return end
	local amount=shift and math.min(10,SavedVars.Gold/POTION_PRICE,99-SavedVars.Potions) or 1
	SavedVars.Gold=SavedVars.Gold-amount*POTION_PRICE
	SavedVars.Potions=SavedVars.Potions+amount
	Miner_Potion_Label:SetText(SavedVars.Potions)
	HeaderChange()
end

PotionUse=function()
	if SavedVars.Potions<=0 then return end
	SavedVars.Potions=SavedVars.Potions-1
	Miner_Potion_Label:SetText(SavedVars.Potions)
	Stamina=math.min(Stamina+POTION_VALUE+SavedVars.Vitality,BASE_STAMINA)
	Miner_Stamina_Bar:SetWidth((bar_w-4)*Stamina/BASE_STAMINA)
end

WorkerHire=function()
	if SavedVars.Gold<WorkerCost() then return end
	if SavedVars.Workers==0 then SavedVars.LastSale=GetTimeStamp() end
	SavedVars.Gold=SavedVars.Gold-WorkerCost()
	SavedVars.Workers=SavedVars.Workers+1
	Miner_Workers_Label:SetText(SavedVars.Workers)
	DimondsSell()
	for param in pairs(Reset) do SavedVars[param]=Default[param] end
	Stamina=BASE_STAMINA
	CART_SIZE=BASE_SIZE
	HeaderChange()
	DimondsChange()
	PickaxeChange()
end

--Loop
SwitchWork=function()
	if work=="Cart" then return end
	local function Work_Loop()
		anim_step=anim_step+1
		if anim_step>4 then
			anim_step=1
			for i=0, (SavedVars.DoubleSwing>=math.random()*100 and 1 or 0) do	--DoubleSwing
				SavedVars.P_Vit=SavedVars.P_Vit+.005
				HeaderChange()
				--Stamina
				Stamina=Stamina-1/(1+SavedVars.Vitality/10)
				Miner_Stamina_Bar:SetWidth((bar_w-4)*Stamina/BASE_STAMINA)
				--Dimonds
				local chance=SavedVars.Mining*2.5+math.random()*(100-SavedVars.Mining*2.5)+SavedVars.Wisdom>85
				if chance then
					SavedVars.Gems=SavedVars.Gems+1 DimondsChange()
					SavedVars.P_Wis=SavedVars.P_Wis+.01
					HeaderChange()
					FlyAnimation(Gem_Path)
				end
				--Pickaxe
				local chance=SavedVars.Accuracy*2.5+math.random()*(100-SavedVars.Accuracy*2.5)<40
				if chance then SavedVars.Pickaxe=SavedVars.Pickaxe-1 PickaxeChange() end
			end
			--Summary
			if Stamina<=0 or SavedVars.Pickaxe<=0 or SavedVars.Gems>=CART_SIZE then SwitchWork() return end
		end
		Miner_Miner:SetTextureCoords(.25*(anim_step-1),.25*anim_step,0,1)
	end
	local function Rest_Loop()
		Stamina=Stamina+1
		Miner_Stamina_Bar:SetWidth((bar_w-4)*Stamina/BASE_STAMINA)
		if Stamina>=BASE_STAMINA then SwitchWork() return end
	end
	work=not work
	if work then
		EVENT_MANAGER:UnregisterForUpdate("Miner_Loop_Rest")
		if SavedVars.Pickaxe<=0 then
			if SavedVars.UsePickaxe or SavedVars.Esquire then
				PickaxeBuy()
			else
				Miner_Status:SetColor(.7,.18,.18,1)
				work=false
				return
			end
		end
		if SavedVars.Gems>=CART_SIZE then
			if SavedVars.AutoSell or SavedVars.Carrier then
				CartTravel()
				return
			else
				Miner_Status:SetColor(.7,.18,.18,1)
				work=false
				return
			end
		end
		Miner_Miner:SetTexture("/MinerMiniGame/Miner_Working.dds")
		Miner_Miner:SetTextureCoords(0,.25,0,1)
		anim_step=1
		EVENT_MANAGER:RegisterForUpdate("Miner_Loop_Work",BASE_SPEED-SavedVars.Speed*10,Work_Loop)
	else
		if Stamina<=0 and SavedVars.UsePotion then
			if SavedVars.Potions<=0 and SavedVars.AutoBuy then PotionBuy(nil,nil,nil,nil,true) end
			PotionUse()
		end
		EVENT_MANAGER:UnregisterForUpdate("Miner_Loop_Work")
		Miner_Miner:SetTexture("/MinerMiniGame/Miner_Idle.dds")
		Miner_Miner:SetTextureCoords(0,1,0,1)
		EVENT_MANAGER:RegisterForUpdate("Miner_Loop_Rest",(BASE_SPEED-SavedVars.Speed*10)/2,Rest_Loop)
	end
end

CartTravel=function()
	if SavedVars.Gems<=0 then return end
	Miner_Status:SetColor(.6,.57,.46,1)
	work="Cart"
	SavedVars.Traveling=true
	local path=100
	local delta=50
	local function Travel_Loop()
		anim_step=anim_step+1
		if anim_step>4 then
			anim_step=1
			path=path-1
			if path==50 then
				DimondsSell()
				Miner_Cart_Bar:ClearAnchors()
				Miner_Cart_Bar:SetAnchor(RIGHT,Miner_Cart_Progress,RIGHT,-2,0)
				delta=0
				Miner_Miner:SetTexture("/MinerMiniGame/Miner_Walk.dds")
			elseif path<=0 then
				EVENT_MANAGER:UnregisterForUpdate("Miner_Loop_Cart")
				Miner_Cart_Progress:SetHidden(true)
				work=false
				Miner_Miner:SetTexture("/MinerMiniGame/Miner_Idle.dds")
				Miner_Miner:SetTextureCoords(0,1,0,1)
				SwitchWork()
			end
			Miner_Cart_Bar:SetWidth((Miner_Cart_Bar.w-4)*(path-delta)*2/100)
		end
		Miner_Miner:SetTextureCoords(.25*(anim_step-1),.25*anim_step,0,1)
	end

	Miner_Cart_Progress:SetHidden(false)
	Miner_Cart_Bar:ClearAnchors()
	Miner_Cart_Bar:SetAnchor(LEFT,Miner_Cart_Progress,LEFT,2,0)
	Miner_Cart_Bar:SetWidth(Miner_Cart_Bar.w-4)
	EVENT_MANAGER:UnregisterForUpdate("Miner_Loop_Rest")
	EVENT_MANAGER:UnregisterForUpdate("Miner_Loop_Work")
	Miner_Miner:SetTexture("/MinerMiniGame/Miner_Cart.dds")
	Miner_Miner:SetTextureCoords(0,.25,0,1)
	anim_step=1
	EVENT_MANAGER:RegisterForUpdate("Miner_Loop_Cart",BASE_SPEED-SavedVars.Speed*10,Travel_Loop)
end

local function WorkersDelivery()
	SavedVars.Gold=SavedVars.Gold+WorkersIncome()
--	d("Miners. Income: "..WorkersIncome()..COIN)
	HeaderChange()
	SavedVars.LastSale=GetTimeStamp()
end

--UI
local function UI_Skills()
	local skill_check=5
	local enabled,disabled={1,1,1,1},{.5,.5,.5,1}
	local highlight,normal={.2,.4,.7,1},{.3,.3,.3,1}

	local function PointsChange()
		--Vitality
		Miner_Skills_Vit_Val:SetText(math.floor(SavedVars.P_Vit))
		Miner_Skills_Vit_L1:SetColor(unpack(SavedVars.P_Vit>=1 and highlight or normal))

		Miner_Skills_Vitality:SetColor(unpack(SavedVars.Vitality>0 and enabled or disabled))
		Miner_Skills_Vitality_Val:SetText(math.floor(SavedVars.Vitality))
		Miner_Skills_Vit_L2:SetColor(unpack(SavedVars.Vitality>=skill_check and highlight or normal))
		Miner_Skills_Vit_L3:SetColor(unpack(SavedVars.Vitality>=skill_check and highlight or normal))
		Miner_Skills_Vit_L4:SetColor(unpack(SavedVars.Vitality>=skill_check and highlight or normal))

		Miner_Skills_Speed:SetColor(unpack(SavedVars.Speed>0 and enabled or disabled))
		Miner_Skills_Speed_Val:SetText(math.floor(SavedVars.Speed))
		Miner_Skills_Vit_L5:SetColor(unpack(SavedVars.Speed>=skill_check and highlight or normal))

		Miner_Skills_Accuracy:SetColor(unpack(SavedVars.Accuracy>0 and enabled or disabled))
		Miner_Skills_Accuracy_Val:SetText(math.floor(SavedVars.Accuracy))
		Miner_Skills_Vit_L6:SetColor(unpack(SavedVars.Accuracy>=skill_check and highlight or normal))

		Miner_Skills_UsePotion:SetColor(unpack(SavedVars.UsePotion and enabled or disabled))
		Miner_Skills_UsePickaxe:SetColor(unpack((SavedVars.UsePickaxe or SavedVars.Esquire) and enabled or disabled))
		Miner_Skills_Vit_L7:SetColor(unpack((SavedVars.UsePickaxe or (SavedVars.Esquire and SavedVars.Accuracy>=skill_check)) and highlight or normal))

		Miner_Skills_DoubleSwing:SetColor(unpack(SavedVars.DoubleSwing>0 and enabled or disabled))
		Miner_Skills_DoubleSwing_Val:SetText(math.floor(SavedVars.DoubleSwing))

		--Wisdom
		Miner_Skills_Wis_Val:SetText(math.floor(SavedVars.P_Wis))
		Miner_Skills_Wis_L1:SetColor(unpack(SavedVars.P_Wis>=1 and highlight or normal))

		Miner_Skills_Wisdom:SetColor(unpack(SavedVars.Wisdom>0 and enabled or disabled))
		Miner_Skills_Wisdom_Val:SetText(math.floor(SavedVars.Wisdom))
		Miner_Skills_Wis_L2:SetColor(unpack(SavedVars.Wisdom>=skill_check and highlight or normal))
		Miner_Skills_Wis_L3:SetColor(unpack(SavedVars.Wisdom>=skill_check and highlight or normal))
		Miner_Skills_Wis_L4:SetColor(unpack(SavedVars.Wisdom>=skill_check and highlight or normal))

		Miner_Skills_Trading:SetColor(unpack(SavedVars.Trading>0 and enabled or disabled))
		Miner_Skills_Trading_Val:SetText(math.floor(SavedVars.Trading))
		Miner_Skills_Wis_L5:SetColor(unpack(SavedVars.Trading>=skill_check and highlight or normal))

		Miner_Skills_Mining:SetColor(unpack(SavedVars.Mining>0 and enabled or disabled))
		Miner_Skills_Mining_Val:SetText(math.floor(SavedVars.Mining))
		Miner_Skills_Wis_L6:SetColor(unpack(SavedVars.Mining>=skill_check and highlight or normal))

		Miner_Skills_AutoBuy:SetColor(unpack(SavedVars.AutoBuy and enabled or disabled))
		Miner_Skills_AutoSell:SetColor(unpack((SavedVars.AutoSell or SavedVars.Carrier) and enabled or disabled))
		Miner_Skills_Wis_L7:SetColor(unpack((SavedVars.AutoSell or SavedVars.Carrier) and highlight or normal))

		Miner_Skills_CartSize:SetColor(unpack(SavedVars.CartSize>0 and enabled or disabled))
		Miner_Skills_CartSize_Val:SetText(math.floor(SavedVars.CartSize))

		--Workers
		Miner_Skills_Work_Val:SetText(SavedVars.Workers)
		Miner_Skills_Work_L1:SetColor(unpack(SavedVars.Workers>=1 and highlight or normal))
		Miner_Skills_Work_L2:SetColor(unpack(SavedVars.Workers>=1 and highlight or normal))
		Miner_Skills_Work_L4:SetColor(unpack(SavedVars.Workers>=1 and highlight or normal))
		Miner_Skills_Traders:SetColor(unpack(SavedVars.Traders>0 and enabled or disabled))
		Miner_Skills_Traders_Val:SetText(SavedVars.Traders)
		Miner_Skills_Esquire:SetColor(unpack(SavedVars.Esquire and enabled or disabled))
		Miner_Skills_Work_L3:SetColor(unpack(SavedVars.Esquire and highlight or normal))
		Miner_Skills_Carrier:SetColor(unpack(SavedVars.Carrier and enabled or disabled))
		Miner_Skills_Work_L5:SetColor(unpack(SavedVars.Carrier and highlight or normal))
	end

	if not Skills_init then
		local size=40
		local space=20
		local w1,h1=size+space*2,size+space
		local w,h=w1*5+space*2+size,20+space+h1*3+(size+space)*2
		local ui	=BUI.UI.TopLevelWindow("Miner_Skills", GuiRoot, {w,h}, {CENTER,CENTER,0,0})
		BUI.UI.Backdrop(	"Miner_Skills_Bg", ui, {w,h}, {TOPLEFT,TOPLEFT,0,0}, {0,0,0,1}, {.7,.7,.5,.3}, nil, false)
		BUI.UI.Texture("Miner_Skills_Status", ui, {24,24}, {TOPLEFT,TOPLEFT,10,8}, "/esoui/art/icons/poi/poi_mine_compete.dds") Miner_Skills_Status:SetColor(.6,.57,.46,1)
		BUI.UI.Label("Miner_Skills_Header", ui, {w,18}, {TOPLEFT,TOPLEFT,36,8}, "ZoFontWinT1", {.7,.7,.5,1}, {0,1}, Localization[lang].Header)
		BUI.UI.SimpleButton("Miner_Skills_Close", ui, {32,32}, {TOPRIGHT,TOPRIGHT,0,10}, "/esoui/art/buttons/closebutton_disabled.dds", false, function()
			Miner_Skills:SetHidden(true)
			Miner_Skills:UnregisterForEvent(EVENT_NEW_MOVEMENT_IN_UI_MODE)
		end)

		--Vitality
		BUI.UI.Texture("Miner_Skills_Vit_Bg", ui, {size,size}, {TOPLEFT,TOPLEFT,space,20+space}, "/MinerMiniGame/Miner_Icons.dds", false, nil, {0,.25,0,1})
		BUI.UI.Label("Miner_Skills_Vit_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space,20+space}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Vitality", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1,20+space}, Icons.Vitality)
		BUI.UI.Label("Miner_Skills_Vitality_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1,20+space}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Speed", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space}, Icons.Speed)
		BUI.UI.Label("Miner_Skills_Speed_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Accuracy", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1}, Icons.Accuracy)
		BUI.UI.Label("Miner_Skills_Accuracy_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_UsePotion", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*3,20+space}, Icons.UsePotion)
		BUI.UI.Texture("Miner_Skills_UsePickaxe", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*3,20+space+h1}, "/MinerMiniGame/Miner_Icons.dds", false, nil, {.5,.75,0,1})
		BUI.UI.Texture("Miner_Skills_DoubleSwing", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*4,20+space+h1}, Icons.DoubleSwing)
		BUI.UI.Texture("Miner_Skills_DoubleSwing_Bg", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*4,20+space+h1}, "/MinerMiniGame/Miner_Icons.dds", false, 2, {0,.25,0,1})
		BUI.UI.Label("Miner_Skills_DoubleSwing_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*4,20+space+h1}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")

		Miner_Skills_Vitality:SetMouseEnabled(true)
		Miner_Skills_Vitality:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Vitality) end)
		Miner_Skills_Vitality:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Vitality:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Vit>=1 then
				local amount=shift and math.min(10,math.floor(SavedVars.P_Vit)) or 1
				SavedVars.P_Vit=SavedVars.P_Vit-amount
				SavedVars.Vitality=SavedVars.Vitality+amount
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_Speed:SetMouseEnabled(true)
		Miner_Skills_Speed:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Speed) end)
		Miner_Skills_Speed:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Speed:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Vit>=1 and SavedVars.Vitality>=skill_check and SavedVars.Speed<10 then
				local amount=shift and math.min(10,math.floor(SavedVars.P_Vit),10-SavedVars.Speed) or 1
				SavedVars.P_Vit=SavedVars.P_Vit-amount
				SavedVars.Speed=SavedVars.Speed+amount
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_Accuracy:SetMouseEnabled(true)
		Miner_Skills_Accuracy:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Accuracy) end)
		Miner_Skills_Accuracy:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Accuracy:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Vit>=1 and SavedVars.Vitality>=skill_check and SavedVars.Accuracy<10 then
				local amount=shift and math.min(10,math.floor(SavedVars.P_Vit),10-SavedVars.Accuracy) or 1
				SavedVars.P_Vit=SavedVars.P_Vit-amount
				SavedVars.Accuracy=SavedVars.Accuracy+amount
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_UsePotion:SetMouseEnabled(true)
		Miner_Skills_UsePotion:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.UsePotion) end)
		Miner_Skills_UsePotion:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_UsePotion:SetHandler("OnMouseDown", function(self)
			if SavedVars.P_Vit>=10 and SavedVars.Speed>=skill_check and not SavedVars.UsePotion then
				SavedVars.P_Vit=SavedVars.P_Vit-10
				SavedVars.UsePotion=true
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_UsePickaxe:SetMouseEnabled(true)
		Miner_Skills_UsePickaxe:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.UsePickaxe) end)
		Miner_Skills_UsePickaxe:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_UsePickaxe:SetHandler("OnMouseDown", function(self)
			if SavedVars.P_Vit>=10 and SavedVars.Accuracy>=skill_check and not SavedVars.UsePickaxe and not SavedVars.Esquire then
				SavedVars.P_Vit=SavedVars.P_Vit-10
				SavedVars.UsePickaxe=true
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_DoubleSwing:SetMouseEnabled(true)
		Miner_Skills_DoubleSwing:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.DoubleSwing) end)
		Miner_Skills_DoubleSwing:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_DoubleSwing:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Vit>=10 and (SavedVars.UsePickaxe or SavedVars.Esquire) and SavedVars.DoubleSwing<100 then
				local amount=shift and math.min(1000,math.floor(SavedVars.P_Vit/10)*10,(100-SavedVars.DoubleSwing)*10) or 10
				SavedVars.P_Vit=SavedVars.P_Vit-amount
				SavedVars.DoubleSwing=SavedVars.DoubleSwing+amount/10
				PointsChange()
				HeaderChange()
			end
		end)

		BUI.UI.Line("Miner_Skills_Vit_L1", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+size,20+space+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Vit_L2", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1+size,20+space+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Vit_L3", ui, {0,h1}, {TOPLEFT,TOPLEFT,space+w1+(w1+size)/2,20+space+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Vit_L4", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1+(w1+size)/2,20+space+h1+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Vit_L5", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1*2+size,20+space+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Vit_L6", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1*2+size,20+space+h1+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Vit_L7", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1*3+size,20+space+h1+size/2}, {.2,.4,.7,1}, 2)

		--Wisdom
		BUI.UI.Texture("Miner_Skills_Wis_Bg", ui, {size,size}, {TOPLEFT,TOPLEFT,space,20+space+h1*2}, "/MinerMiniGame/Miner_Icons.dds", false, nil, {0,.25,0,1})
		BUI.UI.Label("Miner_Skills_Wis_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space,20+space+h1*2}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Wisdom", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1,20+space+h1*2}, Icons.Wisdom)
		BUI.UI.Label("Miner_Skills_Wisdom_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1,20+space+h1*2}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Trading", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1*2}, Icons.Trading)
		BUI.UI.Label("Miner_Skills_Trading_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1*2}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Mining", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1*3}, Icons.Mining)
		BUI.UI.Label("Miner_Skills_Mining_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1*3}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_AutoBuy", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*4,20+space+h1*2}, "/MinerMiniGame/Miner_Icons.dds", false, nil, {.75,1,0,1})
		BUI.UI.Texture("Miner_Skills_AutoSell", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*4,20+space+h1*3}, "/MinerMiniGame/Miner_Icons.dds", false, nil, {.25,.5,0,1})
		BUI.UI.Texture("Miner_Skills_CartSize", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*5,20+space+h1*3}, Icons.CartSize)
		BUI.UI.Texture("Miner_Skills_CartSize_Bg", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*5,20+space+h1*3}, "/MinerMiniGame/Miner_Icons.dds", false, nil, {0,.25,0,1})
		BUI.UI.Label("Miner_Skills_CartSize_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*5,20+space+h1*3}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")

		Miner_Skills_Wisdom:SetMouseEnabled(true)
		Miner_Skills_Wisdom:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Wisdom) end)
		Miner_Skills_Wisdom:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Wisdom:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Wis>=1 then
				local amount=shift and math.min(10,math.floor(SavedVars.P_Wis)) or 1
				SavedVars.P_Wis=SavedVars.P_Wis-amount
				SavedVars.Wisdom=SavedVars.Wisdom+amount
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_Trading:SetMouseEnabled(true)
		Miner_Skills_Trading:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Trading) end)
		Miner_Skills_Trading:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Trading:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Wis>=1 and SavedVars.Wisdom>=skill_check and SavedVars.Trading<10 then
				local amount=shift and math.min(10,math.floor(SavedVars.P_Wis),10-SavedVars.Trading) or 1
				SavedVars.P_Wis=SavedVars.P_Wis-amount
				SavedVars.Trading=SavedVars.Trading+amount
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_Mining:SetMouseEnabled(true)
		Miner_Skills_Mining:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Mining) end)
		Miner_Skills_Mining:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Mining:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Wis>=1 and SavedVars.Wisdom>=skill_check and SavedVars.Mining<10 then
				local amount=shift and math.min(10,math.floor(SavedVars.P_Wis),10-SavedVars.Mining) or 1
				SavedVars.P_Wis=SavedVars.P_Wis-amount
				SavedVars.Mining=SavedVars.Mining+amount
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_AutoBuy:SetMouseEnabled(true)
		Miner_Skills_AutoBuy:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.AutoBuy) end)
		Miner_Skills_AutoBuy:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_AutoBuy:SetHandler("OnMouseDown", function(self)
			if SavedVars.P_Wis>=10 and SavedVars.Trading>=skill_check and not SavedVars.AutoBuy then
				SavedVars.P_Wis=SavedVars.P_Wis-10
				SavedVars.AutoBuy=true
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_AutoSell:SetMouseEnabled(true)
		Miner_Skills_AutoSell:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.AutoSell) end)
		Miner_Skills_AutoSell:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_AutoSell:SetHandler("OnMouseDown", function(self)
			if SavedVars.P_Wis>=10 and SavedVars.Mining>=skill_check and not SavedVars.AutoSell then
				SavedVars.P_Wis=SavedVars.P_Wis-10
				SavedVars.AutoSell=true
				PointsChange()
				HeaderChange()
			end
		end)
		Miner_Skills_CartSize:SetMouseEnabled(true)
		Miner_Skills_CartSize:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.CartSize..CART_SIZE) end)
		Miner_Skills_CartSize:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_CartSize:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.P_Wis>=10 and (SavedVars.AutoSell or SavedVars.Carrier) then
				local amount=shift and math.floor(SavedVars.P_Wis/10)*10 or 10
				SavedVars.P_Wis=SavedVars.P_Wis-amount
				SavedVars.CartSize=SavedVars.CartSize+amount/10
				PointsChange()
				HeaderChange()
				CART_SIZE=BASE_SIZE+BASE_SIZE/10*SavedVars.CartSize
			end
		end)

		BUI.UI.Line("Miner_Skills_Wis_L1", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+size,20+space+h1*2+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Wis_L2", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1+size,20+space+h1*2+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Wis_L3", ui, {0,h1}, {TOPLEFT,TOPLEFT,space+w1+(w1+size)/2,20+space+h1*2+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Wis_L4", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1+(w1+size)/2,20+space+h1*3+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Wis_L5", ui, {w1*2-size,0}, {TOPLEFT,TOPLEFT,space+w1*2+size,20+space+h1*2+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Wis_L6", ui, {w1*2-size,0}, {TOPLEFT,TOPLEFT,space+w1*2+size,20+space+h1*3+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Wis_L7", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1*4+size,20+space+h1*3+size/2}, {.2,.4,.7,1}, 2)
		Skills_init=true

		--Workers
		BUI.UI.Texture("Miner_Skills_Work_Bg", ui, {size,size}, {TOPLEFT,TOPLEFT,space,20+space+h1*4}, "/MinerMiniGame/Miner_Icons.dds", false, nil, {0,.25,0,1})
		BUI.UI.Label("Miner_Skills_Work_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space,20+space+h1*4}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Traders", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1*4}, Icons.Traders)
		BUI.UI.Label("Miner_Skills_Traders_Val", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*2,20+space+h1*4}, "ZoFontWinT1", {.7,.7,.5,1}, {1,1}, "")
		BUI.UI.Texture("Miner_Skills_Esquire", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*3,20+space+h1*4}, Icons.Esquire)
		BUI.UI.Texture("Miner_Skills_Carrier", ui, {size,size}, {TOPLEFT,TOPLEFT,space+w1*4,20+space+h1*4}, Icons.Carrier)

		Miner_Skills_Traders:SetMouseEnabled(true)
		Miner_Skills_Traders:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Traders..SavedVars.Traders*10 .."%") end)
		Miner_Skills_Traders:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Traders:SetHandler("OnMouseDown", function(self,_,_,_,shift)
			if SavedVars.Workers>=1 and SavedVars.Traders<10 then
				local amount=shift and math.min(10,SavedVars.Workers,10-SavedVars.Traders) or 1
				SavedVars.Workers=SavedVars.Workers-amount
				SavedVars.Traders=SavedVars.Traders+amount
				PointsChange()
				Miner_Workers_Label:SetText(SavedVars.Workers)
			end
		end)
		Miner_Skills_Esquire:SetMouseEnabled(true)
		Miner_Skills_Esquire:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Esquire) end)
		Miner_Skills_Esquire:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Esquire:SetHandler("OnMouseDown", function(self)
			if SavedVars.Workers>=1 and not SavedVars.Esquire then
				SavedVars.Workers=SavedVars.Workers-1
				SavedVars.Esquire=true
				PointsChange()
				Miner_Workers_Label:SetText(SavedVars.Workers)
			end
		end)
		Miner_Skills_Carrier:SetMouseEnabled(true)
		Miner_Skills_Carrier:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, Localization[lang].Tooltip.Carrier) end)
		Miner_Skills_Carrier:SetHandler("OnMouseExit", function()ZO_Tooltips_HideTextTooltip()end)
		Miner_Skills_Carrier:SetHandler("OnMouseDown", function(self)
			if SavedVars.Workers>=1 and not SavedVars.Carrier then
				SavedVars.Workers=SavedVars.Workers-1
				SavedVars.Carrier=true
				PointsChange()
				Miner_Workers_Label:SetText(SavedVars.Workers)
			end
		end)

		BUI.UI.Line("Miner_Skills_Work_L1", ui, {w1*2-size,0}, {TOPLEFT,TOPLEFT,space+size,20+space+h1*4+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Work_L2", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1*2+size,20+space+h1*4+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Work_L3", ui, {0,h1*2+size}, {TOPLEFT,TOPLEFT,space+w1*3+size/2,20+space+h1+size}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Work_L4", ui, {w1-size,0}, {TOPLEFT,TOPLEFT,space+w1*3+size,20+space+h1*4+size/2}, {.2,.4,.7,1}, 2)
		BUI.UI.Line("Miner_Skills_Work_L5", ui, {0,h1-size}, {TOPLEFT,TOPLEFT,space+w1*4+size/2,20+space+h1*3+size}, {.2,.4,.7,1}, 2)
	else
		Miner_Skills:SetHidden(false)
	end
	Miner_Skills:RegisterForEvent(EVENT_NEW_MOVEMENT_IN_UI_MODE,function()
		Miner_Skills:SetHidden(true)
		Miner_Skills:UnregisterForEvent(EVENT_NEW_MOVEMENT_IN_UI_MODE)
	end)
	PointsChange()
end

local function UI_Main()
	local size,space=16,2
	local h1=size+space*2
	local w,h=bar_w+128+h1*2,128+h1
	local par_w=bar_w+size*2+space*2
	local cp,cs,cd={.55,.5,.5,1},{0,.5,.12,1},{.7,.6,.18,1}
	local bar_texture="/BanditsUserInterface/textures/theme/progressbar_right_2.dds"
	local ui	=WINDOW_MANAGER:CreateTopLevelWindow("Miner_UI")
	ui:SetParent(GuiRoot)
	ui:SetDimensions(w,SavedVars.Minimized and size or h)
	ui:SetAnchor(unpack(SavedVars.Position))
	ui:SetMouseEnabled(true) ui:SetMovable(true)
	ui:SetHandler("OnMoveStop", function(self)
		local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY=self:GetAnchor()
		if not isValidAnchor then return end
		SavedVars.Position={point,nil,relativePoint,math.floor(offsetX),math.floor(offsetY)}
	end)
	local fragment=ZO_HUDFadeSceneFragment:New(Miner_UI)
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
	--Controls
	ui.status	=BUI.UI.Texture("Miner_Status", ui, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/icons/poi/poi_mine_compete.dds")
	ui.status:SetColor(.6,.57,.46,1)
	ui.header	=BUI.UI.Label("Miner_Header_Label", ui, {w-40-h1*2,size}, {TOPLEFT,TOPLEFT,h1,-2}, "ZoFontWinT2", {.7,.7,.5,1}, {1,1}, "")
	ui.skills	=BUI.UI.SimpleButton("Miner_SkillsTree", ui, {size,size}, {TOPRIGHT,TOPRIGHT,-40-size,0}, "/esoui/art/hud/gamepad/gp_radialicon_trade_down.dds", false, UI_Skills, Localization[lang].SkillsTree)
	ui.switch	=BUI.UI.Texture("Miner_Minimize", ui, {size-4,size-4}, {TOPRIGHT,TOPRIGHT,-40,2}, "/esoui/art/miscellaneous/gamepad/arrow_down.dds")
	ui.switch:SetColor(.6,.57,.46,1)
	ui.switch:SetTextureRotation(SavedVars.Minimized and math.pi or 0)
	ui.switch:SetMouseEnabled(true)
	ui.switch:SetHandler("OnMouseEnter", function(self)self:SetColor(.9,.9,.8,1)end)
	ui.switch:SetHandler("OnMouseExit", function(self)self:SetColor(.6,.57,.46,1)end)
	ui.switch:SetHandler("OnMouseDown", function(self)
		SavedVars.Minimized=not SavedVars.Minimized
		self:SetTextureRotation(SavedVars.Minimized and math.pi or 0)
		Miner_Area:SetHidden(SavedVars.Minimized)
		Miner_UI:SetHeight(SavedVars.Minimized and size or h)
	end)	--function() return SavedVars.Minimized and "Maximize" or "Minimize" end)
	local ar	=BUI.UI.Control("Miner_Area", ui, {w,h-h1}, {TOPLEFT,TOPLEFT,0,h1}, SavedVars.Minimized)
	--Miner
	ui.miner	=BUI.UI.Texture("Miner_Miner", ar, {128,128}, {BOTTOMRIGHT,BOTTOMRIGHT,0,0}, "/MinerMiniGame/Miner_Idle.dds")
--	ui.miner:SetMouseEnabled(true) ui.miner:SetHandler("OnMouseUp", SwitchWork)
	--Parameters
--[[	ui.gold	=BUI.UI.Control("Miner_Gold", ar, {par_w,size}, {TOPLEFT,TOPLEFT,0,h1*0})
	BUI.UI.Texture("Miner_Gold_Icon", ui.gold, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/currency/gold_mipmap.dds")
	BUI.UI.Label("Miner_Gold_Label", ui.gold, {bar_w,size}, {TOPLEFT,TOPLEFT,size+space,-2}, "ZoFontWinT2", {.7,.7,.5,1}, {2,1}, 10)

	ui.points	=BUI.UI.Control("Miner_Points", ar, {par_w,size}, {TOPLEFT,TOPLEFT,0,h1*1})
	BUI.UI.Texture("Miner_Points_Icon", ui.points, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/tutorial/pointsplus_up.dds")
	BUI.UI.Label("Miner_Points_Label", ui.points, {bar_w,size}, {TOPLEFT,TOPLEFT,size+space,-2}, "ZoFontWinT2", {.7,.7,.5,1}, {2,1}, 0)
--]]
	ui.stamina	=BUI.UI.Control("Miner_Stamina", ar, {par_w,size}, {TOPLEFT,TOPLEFT,0,h1*0})
	BUI.UI.Texture("Miner_Stamina_Icon", ui.stamina, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/icons/gear_minotaur_light_hands_a.dds")	--"/esoui/art/champion/champion_points_stamina_icon-hud-32.dds"
	local progress	=BUI.UI.Backdrop("Miner_Stamina_Progress",	ui.stamina,	{bar_w,8},	{TOPLEFT,TOPLEFT,size+space,4},	{0,0,0,0}, {1,1,1,1})
	progress:SetEdgeTexture(bar_texture,32,4,4) progress:SetEdgeColor(0,0,0,1)
	ui.stamina.bar	=BUI.UI.Statusbar("Miner_Stamina_Bar",	progress,	{bar_w-4,4},	{LEFT,LEFT,2,0},	cs, "/esoui/art/screens/gamepad/loadingbar_fill.dds")
	BUI.UI.SimpleButton("Miner_Potion_Use", ui.stamina, {size,size}, {TOPRIGHT,TOPRIGHT,0,0}, "/esoui/art/icons/consumable_potion_003_type_004.dds", false, PotionUse, Localization[lang].PotionUse)

	ui.pickaxe	=BUI.UI.Control("Miner_Pickaxe", ar, {par_w,size}, {TOPLEFT,TOPLEFT,0,h1*1})
	BUI.UI.Texture("Miner_Pickaxe_Icon", ui.pickaxe, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/icons/gear_argonian_2haxe_c.dds")
	local progress	=BUI.UI.Backdrop("Miner_Pickaxe_Progress",	ui.pickaxe,	{bar_w,8},	{TOPLEFT,TOPLEFT,size+space,4},	{0,0,0,0}, {1,1,1,1})
	progress:SetEdgeTexture(bar_texture,32,4,4) progress:SetEdgeColor(0,0,0,1)
	ui.pickaxe.bar	=BUI.UI.Statusbar("Miner_Pickaxe_Bar",	progress,	{bar_w-4,4},	{LEFT,LEFT,2,0},	cp, "/esoui/art/screens/gamepad/loadingbar_fill.dds")
	BUI.UI.SimpleButton("Miner_Pickaxe_Buy", ui.pickaxe, {size,size}, {TOPRIGHT,TOPRIGHT,0,0}, "esoui/art/buttons/gamepad/pointsplus_up.dds", false, PickaxeBuy, Localization[lang].PickaxeBuy..PICKAXE_PRICE..COIN)

	ui.gem	=BUI.UI.Control("Miner_Diamond", ar, {par_w,size}, {TOPLEFT,TOPLEFT,0,h1*2})
	BUI.UI.Texture("Miner_Diamond_Icon", ui.gem, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/icons/crafting_jewelry_base_emerald_r2.dds")
	local progress	=BUI.UI.Backdrop("Miner_Diamond_Progress",	ui.gem,	{bar_w,8},	{TOPLEFT,TOPLEFT,size+space,4},	{0,0,0,0}, {1,1,1,1})
	progress:SetEdgeTexture(bar_texture,32,4,4) progress:SetEdgeColor(0,0,0,1)
	ui.gem.bar	=BUI.UI.Statusbar("Miner_Diamond_Bar",	progress,	{bar_w-4,4},	{LEFT,LEFT,2,0},	cd, "/esoui/art/screens/gamepad/loadingbar_fill.dds")
	BUI.UI.SimpleButton("Miner_Diamond_Buy", ui.gem, {size,size}, {TOPRIGHT,TOPRIGHT,0,0}, "/esoui/art/guild/gamepad/gp_guild_menuicon_purchases.dds", false, CartTravel, function() return Localization[lang].CartTravel..SavedVars.Gems..GEM end)
	Gem_Path={{0,h1*2},{w-20,h-size*2}}

	ui.potion	=BUI.UI.Control("Miner_Potion", ar, {par_w/2,size}, {TOPLEFT,TOPLEFT,0,h1*3})
	BUI.UI.Texture("Miner_Potion_Icon", ui.potion, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/icons/consumable_potion_003_type_004.dds")
	BUI.UI.Label("Miner_Potion_Label", ui.potion, {bar_w/2-h1,size}, {TOPLEFT,TOPLEFT,size+space,-2}, "ZoFontWinT2", {.7,.7,.5,1}, {2,1}, SavedVars.Potions)
	BUI.UI.SimpleButton("Miner_Potion_Buy", ui.potion, {size,size}, {TOPRIGHT,TOPRIGHT,0,0}, "/esoui/art/buttons/gamepad/pointsplus_up.dds", false, PotionBuy, Localization[lang].PotionBuy..POTION_PRICE..COIN)

	ui.workers	=BUI.UI.Control("Miner_Workers", ar, {par_w/2,size}, {TOPLEFT,TOPLEFT,0,h1*4})
	BUI.UI.Texture("Miner_Workers_Icon", ui.workers, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/inventory/inventory_currencytab_oncharacter_up.dds")
	BUI.UI.Label("Miner_Workers_Label", ui.workers, {bar_w/2-h1,size}, {TOPLEFT,TOPLEFT,size+space,-2}, "ZoFontWinT2", {.7,.7,.5,1}, {2,1}, SavedVars.Workers)
	BUI.UI.SimpleButton("Miner_Workers_Buy", ui.workers, {size,size}, {TOPRIGHT,TOPRIGHT,0,0}, "/esoui/art/buttons/gamepad/pointsplus_up.dds", false, WorkerHire, function() return Localization[lang].WorkerHire..WorkerCost()..COIN end)

	local w=w-40
	local progress	=BUI.UI.Backdrop("Miner_Cart_Progress",	ar,	{w,8},	{BOTTOMLEFT,BOTTOMLEFT,0,-4},	{0,0,0,1}, {0,0,0,1}, nil, true)
	progress.bar	=BUI.UI.Statusbar("Miner_Cart_Bar",	progress,	{w-4,4},	{LEFT,LEFT,2,0},	cs, "/esoui/art/screens/gamepad/loadingbar_fill.dds")
	progress.bar.w=w

	BUI.UI.Texture("Miner_Animation", ar, {size,size}, {TOPLEFT,TOPLEFT,0,0}, "", true, 2)
	BUI.UI.Texture("Miner_Animation_Glow", ar, {size/1.5,size/1.5}, {TOPLEFT,TOPLEFT,0,0}, "/esoui/art/charactercreate/triangle_selector_pip_glow.dds", true, 1)
end

local function OnLoad(_,name)
	if name~=ADDON_NAME then return true end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME,EVENT_ADD_ON_LOADED)
	SavedVars=ZO_SavedVars:NewAccountWide("Miner_SavedVars",1,nil,Default)
	UI_Main()
	if SavedVars.Traveling then SavedVars.Traveling=false DimondsSell() end
	if SavedVars.Workers>0 then
		local income=math.floor((GetTimeStamp()-SavedVars.LastSale)/30000*WorkersIncome()/5*(1+SavedVars.Traders/10))
--		pl("Miners. Offline income: "..income..COIN)
		SavedVars.Gold=SavedVars.Gold+income
		SavedVars.LastSale=GetTimeStamp()
	end
	CART_SIZE=BASE_SIZE+BASE_SIZE/10*SavedVars.CartSize

	HeaderChange()
	DimondsChange()
	PickaxeChange()
	SwitchWork()
	EVENT_MANAGER:RegisterForUpdate("Miner_Loop_Workers", 30*60*1000, WorkersDelivery)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME,EVENT_ADD_ON_LOADED,OnLoad)