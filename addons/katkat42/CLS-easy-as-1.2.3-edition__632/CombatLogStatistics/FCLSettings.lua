--[[----------------------------------------------------------
	FCL Settings
 ]]-----------------------------------------------------------
function FCL.InitSettings()
	local FCLSet = FCL.Chain(WINDOW_MANAGER:CreateTopLevelWindow("FCLSettings"))
		:SetDimensions(570,420)
		:SetHidden(true)
		:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
		:SetMovable(true)
		:SetMouseEnabled(true)
	.__END

	FCLSet.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BD", FCLSet, CT_BACKDROP))
		:SetCenterColor(0,0,0,.5)
		:SetEdgeColor(0,0,0,.2)
		:SetEdgeTexture("", 8, 1, 1)
		:SetAlpha(0.75)
		:SetAnchorFill(FCLSet)
	.__END

	FCLSet.title = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Title", FCLSet , CT_LABEL))
		:SetFont("ZoFontBookTablet")
		:SetColor(255,255,255,255)
		:SetText("|cFFCC00CLS Settings|r")
		:SetAnchor(TOP,FCLSet,TOP,0,0)
	.__END

	-- COLOR WHEEL
	FCLSet.color = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Color", FCLSet , CT_COLORSELECT))
		:SetDimensions(200,200)
		:SetAnchor(LEFT,FCLSet,LEFT,50,0)
		:SetMouseEnabled(true)
		:SetHandler("OnColorSelected", function( self , r , g , b ) ColorSelected( self , r , g , b ) end)
	.__END

	-- COLOR BOX
	FCLSet.ColorBox = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_CB", FCLSet , CT_LABEL))
		:SetAnchor(BOTTOM,FCLSet.color,TOP,0,-20)
		:SetDimensions(100, 50)
	.__END

	FCLSet.ColorBox.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_CBbd", FCLSet.ColorBox, CT_BACKDROP))
		:SetAnchorFill(FCLSet.ColorBox)
	.__END

	-- COLOR TEXT
	FCLSet.ColorText = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_CT", FCLSet , CT_LABEL))
		:SetFont("ZoFontGame")
		:SetAnchor(TOP,FCLSet.ColorBox,BOTTOM,25,0)
		:SetDimensions(100, 50)
		:SetText("HEX")
	.__END

	-- ALPHA SLIDER	
	local tex2 = "/esoui/art/buttons/dropbox_arrow_disabled.dds"
	FCLSet.aslider = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_ASlider" , FCLSet , CT_SLIDER))
		:SetMouseEnabled(true)
		:SetDimensions(20, 200)
		:SetThumbTexture(tex2,tex2,tex2,20,25,0,0,1,1)
		:SetMinMax(0,1)
		:SetOrientation(0)
		:SetValueStep(0.01)
		:SetAnchor(LEFT,FCLSet.color,RIGHT,10,0)
		:SetValue(0)
		:SetHandler( "OnValueChanged" , function(self,value,eventReason) Alpha(self,value,eventReason) end)
	.__END

	FCLSet.asliderbg = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_ASliderbg" , FCLSet.aslider , CT_TEXTURE))
		:SetTexture("/esoui/art/unitframes/unitframe_player.dds")
		:SetBlendMode(1)
		:SetColor(1,1,1,1)
		:SetDimensions(20,270)
		:SetAnchor(TOPLEFT,FCLSet.aslider,TOPLEFT,0,0)
	.__END

	FCLSet.alpText = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_AText" , FCLSet , CT_LABEL))
		:SetFont("ZoFontGame")
		:SetAnchor(TOP,FCLSet.asliderbg,TOP,-5,0)
		:SetDimensions(100, 30)
		:SetText("Alpha")
	.__END

	-- DARKER/LIGHTER SLIDER	
	local tex2 = "/esoui/art/buttons/dropbox_arrow_disabled.dds"
	FCLSet.dslider = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_DSlider" , FCLSet , CT_SLIDER))
		:SetMouseEnabled(true)
		:SetDimensions(20, 200)
		:SetThumbTexture(tex2,tex2,tex2,20,25,0,0,1,1)
		:SetMinMax(-1,1)
		:SetOrientation(0)
		:SetValueStep(0.01)
		:SetAnchor(RIGHT,FCLSet.color,LEFT,-10,0)
		:SetValue(0)
		:SetHandler( "OnValueChanged" , function(self,value,eventReason) DChange(self,value,eventReason) end)
	.__END

	FCLSet.dsliderbg = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_DSliderbg" , FCLSet.dslider , CT_TEXTURE))
		:SetTexture("/esoui/art/unitframes/unitframe_player.dds")
		:SetBlendMode(1)
		:SetColor(1,1,1,1)
		:SetDimensions(20,270)
		:SetAnchor(TOPLEFT,FCLSet.dslider,TOPLEFT,0,0)
	.__END

	-- WHITE & BLACK BUTTONS
	FCLSet.White = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_White", FCLSet , CT_BUTTON))
		:SetDimensions(50,20)
		:SetAnchor(TOPRIGHT, FCLSet.ColorBox , TOPLEFT , -10,0)
		:SetFont("ZoFontCreditsText")
		:SetText("|cffffff" .. "WHITE|r")
		:SetHandler("OnClicked",function(self,but) White(self.but)end)
	.__END

	FCLSet.Whitebd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_White_BD", FCLSet.White ,CT_BACKDROP))
		:SetCenterColor(0,0,0,1)
		:SetEdgeColor(0,0,0,1)
		:SetAnchorFill(FCLSet.White)
	.__END

	FCLSet.Black = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Black", FCLSet , CT_BUTTON))
		:SetDimensions(50,20)
		:SetAnchor(TOP, FCLSet.White , BOTTOM, 0,0)
		:SetFont("ZoFontCreditsText")
		:SetText("|c000000" .. "BLACK|r")
		:SetHandler("OnClicked",function(self,but) Black(self.but)end)
	.__END

	FCLSet.Blackbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Black_BD", FCLSet.Black ,CT_BACKDROP))
		:SetCenterColor(1,1,1,1)
		:SetEdgeColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Black)
	.__END

	FCLSet.Close = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Close", FCLSet , CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(TOPRIGHT, FCLSet , TOPRIGHT, 0,0)
		:SetFont("ZoFontCreditsText")
		:SetText("X")
		:SetHandler("OnClicked",function( self , but ) FCLSet:SetHidden(true) end)
	.__END

	FCLSet.Close = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Close_BD", FCLSet.Close ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Close)
	.__END

	----- FIRST COLUMN -----
	FCLSet.Heal = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Heal", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOPLEFT, FCLSet.aslider , TOPRIGHT, 20,-20)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.HealColor .. "Heal|r")
		:SetHandler("OnClicked",function( self , but ) HealColor(self,but) end)
	.__END

	FCLSet.Healbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Heal_BD", FCLSet.Heal ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Heal)
	.__END

	FCLSet.Generic = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Generic", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Heal , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.GenericColor .. "Generic|r")
		:SetHandler("OnClicked",function( self , but ) GenericColor(self,but) end)
	.__END

	FCLSet.Genericbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Generic_BD", FCLSet.Generic ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Generic)
	.__END

	FCLSet.Physical = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Physical", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Generic , BOTTOM,0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.PhysicalColor .. "Physical|r")
		:SetHandler("OnClicked",function( self , but ) PhysicalColor(self,but) end)
	.__END

	FCLSet.Physicalbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Physical_BD", FCLSet.Physical,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Physical)
	.__END

	FCLSet.Fire = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Fire", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Physical , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.FireColor .. "Fire|r")
		:SetHandler("OnClicked",function( self , but ) FireColor(self,but) end)
	.__END

	FCLSet.Firebd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Fire_BD", FCLSet.Fire ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Fire)
	.__END

	FCLSet.Shock = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Shock", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Fire , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.ShockColor .. "Shock|r")
		:SetHandler("OnClicked",function( self , but ) ShockColor(self,but) end)
	.__END

	FCLSet.Shockbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Shock_BD", FCLSet.Shock ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Shock)
	.__END

	FCLSet.Oblivion = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Oblivion", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Shock , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.OblivionColor .. "Oblivion|r")
		:SetHandler("OnClicked",function( self , but ) OblivionColor(self,but) end)
	.__END

	FCLSet.Oblivionbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Oblivion_BD", FCLSet.Oblivion ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Oblivion)
	.__END

	FCLSet.Cold = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Cold", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Oblivion , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.ColdColor .. "Cold|r")
		:SetHandler("OnClicked",function( self , but ) ColdColor(self,but) end)
	.__END

	FCLSet.Coldbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Cold_BD", FCLSet.Cold ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Cold)
	.__END

	FCLSet.Earth = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Earth", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Cold , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.EarthColor .. "Earth|r")
		:SetHandler("OnClicked",function( self , but ) EarthColor(self,but) end)
	.__END

	FCLSet.Earthbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Earth_BD", FCLSet.Earth ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Earth)
	.__END

	FCLSet.Magic = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Magic", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Earth , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.MagicColor .. "Magic|r")
		:SetHandler("OnClicked",function( self , but ) MagicColor(self,but) end)
	.__END

	FCLSet.Magicbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Magic_BD", FCLSet.Magic ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Magic)
	.__END

	FCLSet.Drown = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Drown", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Magic , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.DrownColor .. "Drown|r")
		:SetHandler("OnClicked",function( self , but ) DrownColor(self,but) end)
	.__END

	FCLSet.Drownbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Drown_BD", FCLSet.Drown ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Drown)
	.__END

	FCLSet.Disease = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Disease", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Drown , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.DiseaseColor .. "Disease|r")
		:SetHandler("OnClicked",function( self , but ) DiseaseColor(self,but) end)
	.__END

	FCLSet.Diseasebd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Disease_BD", FCLSet.Disease ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Disease)
	.__END

	FCLSet.Poison = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Poison", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Disease ,BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.PoisonColor .. "Poison|r")
		:SetHandler("OnClicked",function( self , but ) PoisonColor(self,but) end)
	.__END

	FCLSet.Poisonbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Poison_BD", FCLSet.Poison ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Poison)
	.__END

	----- SECOND COLUMN -----
	FCLSet.You = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_You", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOPLEFT, FCLSet.Heal , TOPRIGHT, 10,0)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.YouColor .."You|r")
		:SetHandler("OnClicked",function( self , but ) YouColor(self,but,name) end)
	.__END

	FCLSet.Youbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_You_BD", FCLSet.You ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.You)
	.__END

	FCLSet.Group = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Group", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.You , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.GroupColor .. "Group|r")
		:SetHandler("OnClicked",function( self , but ) GroupColor(self,but) end)
	.__END

	FCLSet.Groupbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Group_BD", FCLSet.Group ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Group)
	.__END

	FCLSet.Ally = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Ally", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Group , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.AllyColor .. "Ally|r")
		:SetHandler("OnClicked",function( self , but ) AllyColor(self,but) end)
	.__END

	FCLSet.Allybd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Ally_BD", FCLSet.Ally ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Ally)
	.__END

	FCLSet.NPC = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_NPC", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Ally , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.NPCColor .. "NPC|r")
		:SetHandler("OnClicked",function( self , but ) NPCColor(self,but) end)
	.__END

	FCLSet.NPCbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_NPC_BD", FCLSet.NPC ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.NPC)
	.__END

	FCLSet.Enemy = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Enemy", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.NPC , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.EnemyColor .. "Enemy|r")
		:SetHandler("OnClicked",function( self , but ) EnemyColor(self,but) end)
	.__END

	FCLSet.Enemybd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Enemy_BD", FCLSet.Enemy ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Enemy)
	.__END

	FCLSet.Pet = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Pet", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Enemy , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.PetColor .. "Pet|r")
		:SetHandler("OnClicked",function( self , but ) PetColor(self,but) end)
	.__END

	FCLSet.Petbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Pet_BD", FCLSet.Pet ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Pet)
	.__END

	----- THIRD COLUMN -----
	FCLSet.Sp = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Sp", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOPLEFT, FCLSet.You , TOPRIGHT, 10,0)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.SpecialColor .. "Specials|r")
		:SetHandler("OnClicked",function( self , but ) SpecialColor(self,but) end)
	.__END

	FCLSet.Spbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_Sp_BD", FCLSet.Sp ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.Sp)
	.__END

	FCLSet.GoodB = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_GoodB", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.Sp , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.GoodBuffColor .. "GoodBuffs|r")
		:SetHandler("OnClicked",function( self , but ) GoodBuffColor(self,but) end)
	.__END

	FCLSet.GoodBbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_GoodB_BD", FCLSet.GoodB ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.GoodB)
	.__END

	FCLSet.BadB = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BadB", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.GoodB , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.BadBuffColor .. "BadBuffs|r")
		:SetHandler("OnClicked",function( self , but ) BadBuffColor(self,but) end)
	.__END

	FCLSet.BadBbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BadB_BD", FCLSet.BadB ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.BadB)
	.__END

	FCLSet.FoodB = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_FoodB", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(TOP, FCLSet.BadB , BOTTOM, 0,2)
		:SetFont("ZoFontCreditsText")
		:SetText(FCL.CText.FoodBuffColor .. "FoodBuffs|r")
		:SetHandler("OnClicked",function( self , but ) FoodBuffColor(self,but) end)
	.__END

	FCLSet.FoodBbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_FoodB_BD", FCLSet.FoodB ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.FoodB)
	.__END

	-- Colors On/Off
	FCLSet.NameColor = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_NameColor", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(BOTTOM, FCLSet.You , TOP, 0,-2)
		:SetFont("ZoFontCreditsText")
		:SetText("On/Off")
		:SetHandler("OnClicked",function( self , but )
			if FCL.CText.NameColor == true then
				FCL.CText.NameColor = false
				d("Name Colors Turned OFF")
			elseif FCL.CText.NameColor == false then
				FCL.CText.NameColor = true
				d("Name Colors Turned ON")
			end
		end)
	.__END

	FCLSet.NameColorbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_NameColor_BD", FCLSet.NameColor ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.NameColor)
	.__END

	FCLSet.BuffColor = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BuffColor", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(BOTTOM, FCLSet.Sp , TOP, 0,-2)
		:SetFont("ZoFontCreditsText")
		:SetText("On/Off")
		:SetHandler("OnClicked",function( self , but )
			if FCL.CText.BuffColor == true then
				FCL.CText.BuffColor = false
				d("Buff Colors Turned OFF")
			elseif FCL.CText.BuffColor == false then
				FCL.CText.BuffColor = true
				d("Buff Colors Turned ON")
			end
		end)
	.__END

	FCLSet.BuffColorbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BuffColor_BD", FCLSet.BuffColor ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.BuffColor)
	.__END

	FCLSet.AbilityColor = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_AbilityColor", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(BOTTOM, FCLSet.Heal , TOP, 0,-2)
		:SetFont("ZoFontCreditsText")
		:SetText("On/Off")
		:SetHandler("OnClicked",function( self , but )
			if FCL.CText.AbilityColor == true then
				FCL.CText.AbilityColor = false
				d("Ability Colors Turned OFF")
			elseif FCL.CText.AbilityColor == false then
				FCL.CText.AbilityColor = true
				d("Ability Colors Turned ON")
			end
		end)
	.__END

	FCLSet.AbilityColorbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_AbilityColor_BD", FCLSet.AbilityColor ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.AbilityColor)
	.__END

	-- Background Box
	FCLSet.BGBox = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BGBox", FCLSet , CT_LABEL))
		:SetAnchor(BOTTOMRIGHT,FCLSet,BOTTOMRIGHT,-10,-10)
		:SetDimensions(100, 50)
	.__END

	FCLSet.BGBox.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BGBoxbd", FCLSet.BGBox, CT_BACKDROP))
		:SetAnchorFill(FCLSet.BGBox)
		:SetCenterColor(FCL.CText.BGColor[1],FCL.CText.BGColor[2],FCL.CText.BGColor[3],FCL.CText.BGColor[4])
		:SetEdgeColor(1,1,1,1)
	.__END

	FCLSet.BGBoxB = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BGBoxButton", FCLSet.BGBox , CT_BUTTON))
		:SetDimensions(100,50)
		:SetAnchor(CENTER, FCLSet.BGBox , CENTER, 0,0)
		:SetFont("ZoFontCreditsText")
		:SetHandler("OnClicked",function( self , but ) FCL.BGColor() end)
	.__END

	FCLSet.BGBoxTB = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BGBoxTButton", FCLSet , CT_BUTTON))
		:SetDimensions(80,20)
		:SetAnchor(BOTTOM, FCLSet.BGBox , TOP, 0,-5)
		:SetFont("ZoFontCreditsText")
		:SetText("ToggleBG")
		:SetHandler("OnClicked",function( self , but )
			if FCL.CText.ShowBG == true then
				FCL.CText.ShowBG = false
				d("Background Turned OFF")
			elseif FCL.CText.ShowBG == false then
				FCL.CText.ShowBG = true
				d("Background Turned ON")
			end		
			end)
	.__END

	FCLSet.BGBoxTBbd = FCL.Chain(WINDOW_MANAGER:CreateControl("FCLSettings_BGBoxTB_BD", FCLSet.BGBoxTB ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(FCLSet.BGBoxTB)
	.__END
end

--[[----------------------------------------------------------
	Frame Handlers
 ]]-----------------------------------------------------------
--[[--
 * Function to record color
 ]]--
function CSMouseDown(self)
end


--[[----------------------------------------------------------
	SETTING HANDLERS
 ]]-----------------------------------------------------------
-- RESET TO DEFAULTS
function BacktoDefault()
	for key, value in pairs(FCL.Default) do
		FCL.CText[key] = value
	end
	ReloadUI()
end

-- BACKGROUND Color
function FCL.BGColor()
	if FCL.ColorRGB == nil then return end
	if FCL.Alpha == 0 then return end
	if FCL.ColorRGB.newR == nil then
	FCL.CText.BGColor[1] = FCL.ColorRGB.red
	FCL.CText.BGColor[2] = FCL.ColorRGB.green
	FCL.CText.BGColor[3] = FCL.ColorRGB.blue
	FCL.CText.BGColor[4] = FCL.Alpha
	else
	FCL.CText.BGColor[1] = FCL.ColorRGB.newR
	FCL.CText.BGColor[2] = FCL.ColorRGB.newG
	FCL.CText.BGColor[3] = FCL.ColorRGB.newB
	FCL.CText.BGColor[4] = FCL.Alpha
	end
	_G["FCLSettings_BGBoxbd"]:SetCenterColor(FCL.CText.BGColor[1],FCL.CText.BGColor[2],FCL.CText.BGColor[3],FCL.CText.BGColor[4])
	_G["CombatLog_BD"]:SetCenterColor(FCL.CText.BGColor[1],FCL.CText.BGColor[2],FCL.CText.BGColor[3],FCL.CText.BGColor[4])
end

-- SOURCE/TARGET COLORs
function YouColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.YouColor = FCL.ColorTemp
	self:SetText(FCL.CText.YouColor .. "You|r")
	d(FCL.CText.YouColor .. "You Color is Now Saved|r")
end
function GroupColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.GroupColor = FCL.ColorTemp
	self:SetText(FCL.CText.GroupColor .. "Group|r")
	d(FCL.CText.GroupColor .. "Group Color is Now Saved|r")
end
function AllyColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.AllyColor = FCL.ColorTemp
	self:SetText(FCL.CText.AllyColor .. "Ally|r")
	d(FCL.CText.AllyColor .. "Ally Color is Now Saved|r")
end
function EnemyColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.EnemyColor = FCL.ColorTemp
	self:SetText(FCL.CText.EnemyColor .. "Enemy|r")
	d(FCL.CText.EnemyColor .. "Enemy Color is Now Saved|r")
end
function NPCColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.NPCColor = FCL.ColorTemp
	self:SetText(FCL.CText.NPCColor .. "NPC|r")
	d(FCL.CText.NPCColor .. "NPC Color is Now Saved|r")
end
function PetColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.PetColor = FCL.ColorTemp
	self:SetText(FCL.CText.PetColor .. "Pet|r")
	d(FCL.CText.PetColor .. "Pet Color is Now Saved|r")
end

-- BUFFS/SPECIAL COLOR
function SpecialColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.SpecialColor = FCL.ColorTemp
	self:SetText(FCL.CText.SpecialColor .. "Specials|r")
	d(FCL.CText.SpecialColor .. "Special Color is Now Saved|r")
end
function GoodBuffColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.GoodBuffColor = FCL.ColorTemp
	self:SetText(FCL.CText.GoodBuffColor .. "GoodBuffs|r")
	d(FCL.CText.GoodBuffColor .. "Good Buffs Color is Now Saved|r")
end
function BadBuffColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.BadBuffColor = FCL.ColorTemp
	self:SetText(FCL.CText.BadBuffColor .. "BadBuffs|r")
	d(FCL.CText.BadBuffColor .. "Bad Buffs Color is Now Saved|r")
end
function FoodBuffColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.FoodBuffColor = FCL.ColorTemp
	self:SetText(FCL.CText.FoodBuffColor .. "FoodBuffs|r")
	d(FCL.CText.FoodBuffColor .. "Food Buffs Color is Now Saved|r")
end

-- ABILITIES COLOR
function HealColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.HealColor = FCL.ColorTemp
	self:SetText(FCL.CText.HealColor .. "Heal|r")
	d(FCL.CText.HealColor .. "Heal Color is Now Saved|r")
end
function GenericColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.GenericColor = FCL.ColorTemp
	self:SetText(FCL.CText.GenericColor .. "Generic|r")
	d(FCL.CText.GenericColor .. "Generic Color is Now Saved|r")
end
function PhysicalColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.PhysicalColor = FCL.ColorTemp
	self:SetText(FCL.CText.PhysicalColor .. "COLOR|r")
	d(FCL.CText.PhysicalColor .. "Physical Color is Now Saved|r")
end
function FireColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.FireColor = FCL.ColorTemp
	self:SetText(FCL.CText.FireColor .. "Fire|r")
	d(FCL.CText.FireColor .. "Fire Color is Now Saved|r")
end
function ShockColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.ShockColor = FCL.ColorTemp
	self:SetText(FCL.CText.ShockColor .. "Shock|r")
	d(FCL.CText.ShockColor .. "Shock Color is Now Saved|r")
end
function OblivionColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.OblivionColor = FCL.ColorTemp
	self:SetText(FCL.CText.OblivionColor .. "Oblivion|r")
	d(FCL.CText.OblivionColor .. "Oblivion Color is Now Saved|r")
end
function ColdColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.ColdColor = FCL.ColorTemp
	self:SetText(FCL.CText.ColdColor .. "Cold|r")
	d(FCL.CText.ColdColor .. "Cold Color is Now Saved|r")
end
function EarthColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.EarthColor = FCL.ColorTemp
	self:SetText(FCL.CText.EarthColor .. "Earth|r")
	d(FCL.CText.EarthColor .. "Earth Color is Now Saved|r")
end
function MagicColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.MagicColor = FCL.ColorTemp
	self:SetText(FCL.CText.MagicColor .. "Magic|r")
	d(FCL.CText.MagicColor .. "Magic Color is Now Saved|r")
end
function DrownColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.DrownColor = FCL.ColorTemp
	self:SetText(FCL.CText.DrownColor .. "Drown|r")
	d(FCL.CText.DrownColor .. "Drown Color is Now Saved|r")
end
function DiseaseColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.DiseaseColor = FCL.ColorTemp
	self:SetText(FCL.CText.DiseaseColor .. "Disease|r")
	d(FCL.CText.DiseaseColor .. "Disease Color is Now Saved|r")
end
function PoisonColor( self , but )
	if FCL.ColorTemp == nil then return end
	FCL.CText.PoisonColor = FCL.ColorTemp
	self:SetText(FCL.CText.PoisonColor .. "Poison|r")
	d(FCL.CText.PoisonColor .. "Poison Color is Now Saved|r")
end

-- WHITE/BLACK BUTTONS
function White(self,but)
	local colortext = _G["FCLSettings_CT"]
	local colorbox = _G["FCLSettings_CBbd"]

	FCL.ColorTemp = "|cffffff"

	colortext:SetText(FCL.ColorTemp .. "ffffff|r")
	colorbox:SetCenterColor(1,1,1,1)
end

function Black(self,but)
	local colortext = _G["FCLSettings_CT"]
	local colorbox = _G["FCLSettings_CBbd"]

	FCL.ColorTemp = "|c000000"

	colortext:SetText(FCL.ColorTemp .. "000000|r")
	colorbox:SetCenterColor(0,0,0,1)
end

-- ALPHA SLIDER
function Alpha(self,value,eventReason)
	local colorbox = _G["FCLSettings_CBbd"]
	local textbox = _G["FCLSettings_AText"]

	value = math.abs(value-1)
	FCL.Alpha = value

	colorbox:SetAlpha(FCL.Alpha)
	local display = math.floor(value * 100) .. "\%"
	textbox:SetText(display)
end

-- TINT/SHADER SLIDER
function DChange(self,value,eventReason)
	if FCL.ColorRGB == nil then return end
	
	local red = FCL.ColorRGB.red * 255
	local green = FCL.ColorRGB.green * 255
	local blue = FCL.ColorRGB.blue * 255

	if value < 0 then
		red = math.abs((255 - red)*value) + red
		green = math.abs((255 - green)*value) + green
		blue = math.abs((255 - blue)*value) + blue
	elseif value > 0 then
		red = red*(1-value)
		green = green*(1-value)
		blue = blue*(1-value)
	end
	local colorbox = _G["FCLSettings_CBbd"]	
	FCL.ColorRGB.newR = red/255
	FCL.ColorRGB.newG = green/255
	FCL.ColorRGB.newB = blue/255
	if FCL.Alpha == 0 then
		colorbox:SetCenterColor(red/255,green/255,blue/255,1)
	else
		colorbox:SetCenterColor(red/255,green/255,blue/255,FCL.Alpha)
	end

	red = num2hex(red)
	green = num2hex(green)
	blue = num2hex(blue)
	FCL.ColorTemp = "|c" .. red .. green .. blue

	local colortext = _G["FCLSettings_CT"]
	colortext:SetText(FCL.ColorTemp .. red .. green .. blue .. "|r")
end

-- MAX LINES SLIDER
function MLChange(self,value,eventReason)
	FCL.CText.MaxLines = value
	local text = _G["FCLSettings_MLText"]
	text:SetText("Max Lines = " .. FCL.CText.MaxLines .. " /reloadui to change")
end

-- COLOR SELECTOR WHEEL
function ColorSelected( self , r , g , b )
	--d( r*255 .. " / " .. g*255 .. " / " .. b*255)
	local colorbox = _G["FCLSettings_CBbd"]
	colorbox:SetCenterColor(r,g,b,1)

	local red = num2hex(r*255)
	local green = num2hex(g*255)
	local blue = num2hex(b*255)
	--debug
	--d(red .. green .. blue)
	FCL.ColorTemp = "|c" .. red .. green .. blue
	FCL.ColorRGB = {["red"] = r, ["green"] = g, ["blue"]=b}

	local colortext = _G["FCLSettings_CT"]
	colortext:SetText(FCL.ColorTemp .. red .. green .. blue .. "|r")
end

--- Returns HEX representation of num
function num2hex(num)
	local hexstr = '0123456789abcdef'
	local s = ''
	while num > 0 do
		local mod = math.fmod(num, 16)
		mod = math.floor(mod)
		s = string.sub(hexstr, mod+1, mod+1) .. s
		num = math.floor(num / 16)
	end
	if s == '' then s = '00' end
	if (string.len(s) < 2) then
		s = '0' .. s
	end
	return s
end
