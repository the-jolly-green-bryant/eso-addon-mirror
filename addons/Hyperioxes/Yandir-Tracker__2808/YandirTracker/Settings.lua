-- Settings menu.





function YT_LoadSettings()
    local panelData = {
        type = "panel",
        name = "Yandir Tracker",
        displayName = "Yandir Tracker",
        author = "Hyperioxes",
        version = "1.2a",
        website = "https://www.esoui.com/downloads/info2808-YandirTracker.html",
		feedback = "https://www.esoui.com/downloads/info2808-YandirTracker.html#comments",
		donation = "https://www.esoui.com/downloads/info2814-PowerfulAssaultTracker.html#donate",
        slashCommand = "/yt",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel("Yandir Tracker", panelData)

    local optionsTable = {}

      table.insert(optionsTable, {
        type = "button",
        name = "Show/Hide UI",
        func = function() YT_showUI() end,
        width = "half"

    })

    table.insert(optionsTable, {
                type = "colorpicker",
                name = "Circle Color",
                getFunc = function() return YTsavedVars.orbColor[1], YTsavedVars.orbColor[2], YTsavedVars.orbColor[3], YTsavedVars.orbColor[4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                YTsavedVars.orbColor[1] = r 
                YTsavedVars.orbColor[2] = g
                YTsavedVars.orbColor[3] = b
                YTsavedVars.orbColor[4] = a

                for i=0,9 do
                    local control = YandirTrackerUI:GetNamedChild("CircleInner"..i)
                    control:SetColor(r,g,b,a)
                end

                end,	--(alpha is optional)

            })

    table.insert(optionsTable, {
                type = "colorpicker",
                name = "Timer Bar Color",
                getFunc = function() return YTsavedVars.barColor[1], YTsavedVars.barColor[2], YTsavedVars.barColor[3], YTsavedVars.barColor[4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                YTsavedVars.barColor[1] = r 
                YTsavedVars.barColor[2] = g
                YTsavedVars.barColor[3] = b
                YTsavedVars.barColor[4] = a
                

                local control = YandirTrackerUI:GetNamedChild("StackTimerBar")
                control:SetColor(r,g,b,a)
                end,	--(alpha is optional)
            })

    table.insert(optionsTable, {
                type = "colorpicker",
                name = "Weapon Damage Text Color",
                getFunc = function() return YTsavedVars.weaponDamageColor[1], YTsavedVars.weaponDamageColor[2], YTsavedVars.weaponDamageColor[3], YTsavedVars.weaponDamageColor[4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                YTsavedVars.weaponDamageColor[1] = r 
                YTsavedVars.weaponDamageColor[2] = g
                YTsavedVars.weaponDamageColor[3] = b
                YTsavedVars.weaponDamageColor[4] = a

                local control = YandirTrackerUI:GetNamedChild("bonusText")
                control:SetColor(r,g,b,a)
                end,	--(alpha is optional)

                
            })

    table.insert(optionsTable, {
                type = "colorpicker",
                name = "Background Color",
                getFunc = function() return YTsavedVars.backgroundColor[1], YTsavedVars.backgroundColor[2], YTsavedVars.backgroundColor[3], YTsavedVars.backgroundColor[4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                YTsavedVars.backgroundColor[1] = r 
                YTsavedVars.backgroundColor[2] = g
                YTsavedVars.backgroundColor[3] = b
                YTsavedVars.backgroundColor[4] = a

                local control = YandirTrackerUI:GetNamedChild("StackCountBG")
                control:SetColor(r,g,b,a)
                end,	--(alpha is optional)

            })
    table.insert(optionsTable, {

                type = "checkbox",
                name = "Show UI only in combat",
                getFunc = function() return YTsavedVars.showOnlyInCombat end,
                setFunc = function(value) YTsavedVars.showOnlyInCombat = value 
                YT_UISwitch()
				end,
                width = "full",	--or "half" (optional)

            })
    table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only when you're wearing Yandir",
                getFunc = function() return YTsavedVars.onlyTrackWhenWearing end,
                setFunc = function(value) YTsavedVars.onlyTrackWhenWearing = value 
                YT_UISwitch()
				end,
                width = "full",	--or "half" (optional)

            })


    --[[

    table.insert(optionsTable, {
        type = "submenu",
        name = "General Settings",
        tooltip = "Turning on/off entire modules of this addon",	--(optional)
        controls = {
            [1] = {
                type = "checkbox",
                name = "Block UI visibility",
                getFunc = function() return HTTsavedVars.isBlockUIOn end,
                setFunc = function(value) HTTsavedVars.isBlockUIOn = value end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            },
            [2] = {
                type = "checkbox",
                name = "Debuff UI visibility",
                getFunc = function() return HTTsavedVars.isDebuffUIOn end,
                setFunc = function(value) HTTsavedVars.isDebuffUIOn = value end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            },
            [3] = {
                type = "checkbox",
                name = "Buff UI visibility",
                getFunc = function() return HTTsavedVars.isBuffUIOn end,
                setFunc = function(value) HTTsavedVars.isBuffUIOn = value end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            },
            [4] = {
                type = "checkbox",
                name = "Boss Debuff UI visibility",
                getFunc = function() return HTTsavedVars.isBossDebuffUIOn end,
                setFunc = function(value) HTTsavedVars.isBossDebuffUIOn = value end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            },
            [5] = {
                type = "dropdown",
                name = "Shield Texture",
                choices = shieldChoices,
                getFunc = function() return HTTsavedVars.customShield end,
                setFunc = function(var) HTTsavedVars.customShield = string.gsub(string.gsub(string.gsub(var,"[\n\n                           ]",""),"|t",""),"-64:64:","")
                shieldIcon = HTTBlock:GetNamedChild("Block")
                shieldIcon:SetTexture(HTTsavedVars.customShield)
                end,
                width = "half",	--or "half" (optional)
            },
            [6] = {
                type = "slider",
                name = "Shield Texture Height",
                --tooltip = "Slider's tooltip text.",
                min = 1,
                max = 500,
                step = 1,	--(optional)
                getFunc = function() return HTTsavedVars.shieldTextureHeight end,
                setFunc = function(value) HTTsavedVars.shieldTextureHeight = value 
                shieldIcon = HTTBlock:GetNamedChild("Block")
                shieldBlockCost = HTTBlock:GetNamedChild("blockCost")
                shieldBlockMitigation = HTTBlock:GetNamedChild("blockMitigation")
                shieldIcon:SetDimensions(HTTsavedVars.shieldTextureWidth,HTTsavedVars.shieldTextureHeight)
                shieldBlockCost:SetAnchor(BOTTOMLEFT, block, BOTTOMLEFT,HTTsavedVars.shieldTextureWidth,-20)
                shieldBlockMitigation:SetAnchor(BOTTOMLEFT, block, BOTTOMLEFT,HTTsavedVars.shieldTextureWidth,15)
                end,
                width = "half",	--or "half" (optional)

            },
            [7] = {
                type = "slider",
                name = "Shield Texture Width",
                --tooltip = "Slider's tooltip text.",
                min = 1,
                max = 500,
                step = 1,	--(optional)
                getFunc = function() return HTTsavedVars.shieldTextureWidth end,
                setFunc = function(value) HTTsavedVars.shieldTextureWidth = value 
                shieldIcon = HTTBlock:GetNamedChild("Block")
                shieldBlockCost = HTTBlock:GetNamedChild("blockCost")
                shieldBlockMitigation = HTTBlock:GetNamedChild("blockMitigation")
                shieldIcon:SetDimensions(HTTsavedVars.shieldTextureWidth,HTTsavedVars.shieldTextureHeight)
                shieldBlockCost:SetAnchor(BOTTOMLEFT, block, BOTTOMLEFT,HTTsavedVars.shieldTextureWidth,-20)
                shieldBlockMitigation:SetAnchor(BOTTOMLEFT, block, BOTTOMLEFT,HTTsavedVars.shieldTextureWidth,15)
                end,
                width = "half",	--or "half" (optional)

            },


        },
    })




		 table.insert(optionsTable, {
        type = "submenu",
        name = "Class Special Tracker",
        tooltip = "Settings of class special tracker (Stonefist for DK, Shimmering Shield for Warden)",	--(optional)
        controls = {

        },
    })

   

    table.insert(optionsTable[4].controls, {

                type = "checkbox",
                name = "Turned on",
                getFunc = function() return HTTsavedVars.classSpecialIsOn end,
                setFunc = function(value) HTTsavedVars.classSpecialIsOn = value end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            })
    table.insert(optionsTable[4].controls, {
                type = "colorpicker",
                name = "Bar color",
                getFunc = function() return HTTsavedVars.classSpecialColor[1], HTTsavedVars.classSpecialColor[2], HTTsavedVars.classSpecialColor[3], HTTsavedVars.classSpecialColor[4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                HTTsavedVars.classSpecialColor[1] = r 
                HTTsavedVars.classSpecialColor[2] = g
                HTTsavedVars.classSpecialColor[3] = b
                HTTsavedVars.classSpecialColor[4] = a
                end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",
            })

			 table.insert(optionsTable, {
        type = "submenu",
        name = "Debuffs",
        tooltip = "Settings of debuff tracking",	--(optional)
        controls = {

        },
    })


    table.insert(optionsTable[5].controls, {

                type = "header",
                name = ZO_HIGHLIGHT_TEXT:Colorize("Order of Debuffs"),
                width = "full",	--or "half" (optional)     
			})

     table.insert(optionsTable[5].controls, {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = "Current order of debuffs:",
        width = "full",	--or "half" (optional)
    })
    for k,v in pairs(HTTsavedVars.orderOfDebuffs) do
        table.insert(optionsTable[5].controls, {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = k..".     |t-16:16:"..HTTsavedVars.debuffTable["icons"][v].."|t    "..HTTsavedVars.debuffTable["names"][v],
        width = "full",	--or "half" (optional)
    })
    end

    table.insert(optionsTable[5].controls, {
         type = "dropdown",
         name = "Debuffs to swap",
         choices = rearrangeTable(HTTsavedVars.debuffTable["names"],HTTsavedVars.orderOfDebuffs),
         getFunc = function() return holdDebuffSwapValue1 end,
         setFunc = function(var) holdDebuffSwapValue1 = var end,
         width = "half",	--or "half" (optional)
    })

    table.insert(optionsTable[5].controls, {
         type = "dropdown",
         --name = "",
         choices = rearrangeTable(HTTsavedVars.debuffTable["names"],HTTsavedVars.orderOfDebuffs),
         getFunc = function() return holdDebuffSwapValue2 end,
         setFunc = function(var) holdDebuffSwapValue2 = var end,
         width = "half",	--or "half" (optional)
    })

     table.insert(optionsTable[5].controls, {
        type = "button",
        name = "Swap Debuffs",
        func = function() HTT_swapElementsInTable(HTTsavedVars.orderOfDebuffs,HTT_findPositionOfElementInTable(HTTsavedVars.debuffTable["names"],holdDebuffSwapValue1),HTT_findPositionOfElementInTable(HTTsavedVars.debuffTable["names"],holdDebuffSwapValue2)) end,
        width = "half",


    })



    table.insert(optionsTable[5].controls, {

                type = "header",
                name = ZO_HIGHLIGHT_TEXT:Colorize("Stagger"),
                width = "full",	--or "half" (optional)     
			})
    table.insert(optionsTable[5].controls, {
                type = "checkbox",
                name = "Stagger tracking",
                getFunc = function() return HTTsavedVars.debuffTable["isTurnedOn"][1] end,
                setFunc = function(value) HTTsavedVars.debuffTable["isTurnedOn"][1] = value end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            })
    table.insert(optionsTable[5].controls, {
                type = "colorpicker",
                name = "Bar color for 1 stack of Stagger",
                getFunc = function() return HTTsavedVars.debuffTable["colors"][1][1], HTTsavedVars.debuffTable["colors"][1][2], HTTsavedVars.debuffTable["colors"][1][3], HTTsavedVars.debuffTable["colors"][1][4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                HTTsavedVars.debuffTable["colors"][1][1] = r 
                HTTsavedVars.debuffTable["colors"][1][2] = g
                HTTsavedVars.debuffTable["colors"][1][3] = b
                HTTsavedVars.debuffTable["colors"][1][4] = a
                end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",
            })
    table.insert(optionsTable[5].controls, {
                type = "colorpicker",
                name = "Bar color for 2 stacks of Stagger",
                getFunc = function() return HTTsavedVars.stoneFistStackColorExceptions[2][1], HTTsavedVars.stoneFistStackColorExceptions[2][2], HTTsavedVars.stoneFistStackColorExceptions[2][3], HTTsavedVars.stoneFistStackColorExceptions[2][4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                HTTsavedVars.stoneFistStackColorExceptions[2][1] = r 
                HTTsavedVars.stoneFistStackColorExceptions[2][2] = g
                HTTsavedVars.stoneFistStackColorExceptions[2][3] = b
                HTTsavedVars.stoneFistStackColorExceptions[2][4] = a
                end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",
            })
    table.insert(optionsTable[5].controls, {
                type = "colorpicker",
                name = "Bar color for 3 stacks of Stagger",
                getFunc = function() return HTTsavedVars.stoneFistStackColorExceptions[3][1], HTTsavedVars.stoneFistStackColorExceptions[3][2], HTTsavedVars.stoneFistStackColorExceptions[3][3], HTTsavedVars.stoneFistStackColorExceptions[3][4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                HTTsavedVars.stoneFistStackColorExceptions[3][1] = r 
                HTTsavedVars.stoneFistStackColorExceptions[3][2] = g
                HTTsavedVars.stoneFistStackColorExceptions[3][3] = b
                HTTsavedVars.stoneFistStackColorExceptions[3][4] = a
                end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",
            })

      table.insert(optionsTable[5].controls, {

                type = "header",
                name = ZO_HIGHLIGHT_TEXT:Colorize("Off-Balance"),
                width = "full",	--or "half" (optional)     
			})
    table.insert(optionsTable[5].controls, {
                type = "checkbox",
                name = "Off-Balance tracking",
                getFunc = function() return HTTsavedVars.debuffTable["isTurnedOn"][1] end,
                setFunc = function(value) HTTsavedVars.debuffTable["isTurnedOn"][1] = value end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            })
    table.insert(optionsTable[5].controls, {
                type = "colorpicker",
                name = "Bar color for Off-Balance",
                getFunc = function() return HTTsavedVars.debuffTable["colors"][100][1], HTTsavedVars.debuffTable["colors"][100][2], HTTsavedVars.debuffTable["colors"][100][3], HTTsavedVars.debuffTable["colors"][100][4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                HTTsavedVars.debuffTable["colors"][100][1] = r 
                HTTsavedVars.debuffTable["colors"][100][2] = g
                HTTsavedVars.debuffTable["colors"][100][3] = b
                HTTsavedVars.debuffTable["colors"][100][4] = a
                end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",
            })
      table.insert(optionsTable[5].controls, {
                type = "colorpicker",
                name = "Bar color for Off-Balance Immunity",
                getFunc = function() return HTTsavedVars.orbColor[1], HTTsavedVars.orbColor[2], HTTsavedVars.orbColor[3], HTTsavedVars.orbColor[4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) 
                HTTsavedVars.orbColor[1] = r 
                HTTsavedVars.orbColor[2] = g
                HTTsavedVars.orbColor[3] = b
                HTTsavedVars.orbColor[4] = a
                end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",
            })



   for _,v in pairs(HTTsavedVars.orderOfDebuffs) do
        if v ~= 1 and v~= 100 then
       

		table.insert(optionsTable[5].controls, {
                    type = "header",
                    name = ZO_HIGHLIGHT_TEXT:Colorize( HTTsavedVars.debuffTable["names"][v]),
                    width = "full",	--or "half" (optional)     
			    })
				table.insert(optionsTable[5].controls, {
                    type = "checkbox",
                    name =  HTTsavedVars.debuffTable["names"][v].." tracking",
                    getFunc = function() return HTTsavedVars.debuffTable["isTurnedOn"][v] end,
                    setFunc = function(value) HTTsavedVars.debuffTable["isTurnedOn"][v] = value end,
                    width = "half",	--or "half" (optional)
                    warning = "Will need to reload the UI.",	--(optional)
                })
				table.insert(optionsTable[5].controls, {
                    type = "colorpicker",
                    name = "Bar color for ".. HTTsavedVars.debuffTable["names"][v],
                    getFunc = function() return HTTsavedVars.debuffTable["colors"][v][1], HTTsavedVars.debuffTable["colors"][v][2], HTTsavedVars.debuffTable["colors"][v][3], HTTsavedVars.debuffTable["colors"][v][4] end,	--(alpha is optional)
                    setFunc = function(r,g,b,a) 
                    HTTsavedVars.debuffTable["colors"][v][1] = r 
                    HTTsavedVars.debuffTable["colors"][v][2] = g
                    HTTsavedVars.debuffTable["colors"][v][3] = b
                    HTTsavedVars.debuffTable["colors"][v][4] = a
                    end,	--(alpha is optional)
                    width = "half",	--or "half" (optional)
                    warning = "Will need to reload the UI.",
                })
				table.insert(optionsTable[5].controls, {
				type = "button",
				name = "Delete Tracker",
				func = function() HTT_removeDebuff(v) end,
				width = "half",
                warning = "Will need to reload the UI.",
			})


       end
    end

	table.insert(optionsTable, {
        type = "submenu",
        name = "Buffs",
        tooltip = "Settings of buff tracking",	--(optional)
        controls = {

        },
    })


	
	table.insert(optionsTable[6].controls, {
                    type = "header",
                    name = ZO_HIGHLIGHT_TEXT:Colorize("Order of Buffs"),
                    width = "full",	--or "half" (optional)     
				})

    table.insert(optionsTable[6].controls, {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = "Current order of buffs:",
        width = "full",	--or "half" (optional)
    })
    for k,v in pairs(HTTsavedVars.orderOfBuffs) do
        table.insert(optionsTable[6].controls, {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = k..".     |t-16:16:"..HTTsavedVars.buffTable["icons"][v].."|t    "..HTTsavedVars.buffTable["names"][v],
        width = "full",	--or "half" (optional)
    })
    end

    table.insert(optionsTable[6].controls, {
         type = "dropdown",
         name = "Buffs to swap",
         choices = rearrangeTable(HTTsavedVars.buffTable["names"],HTTsavedVars.orderOfBuffs),
         getFunc = function() return holdBuffSwapValue1 end,
         setFunc = function(var) holdBuffSwapValue1 = var end,
         width = "half",	--or "half" (optional)
    })

    table.insert(optionsTable[6].controls, {
         type = "dropdown",
         --name = "",
         choices = rearrangeTable(HTTsavedVars.buffTable["names"],HTTsavedVars.orderOfBuffs),
         getFunc = function() return holdBuffSwapValue2 end,
         setFunc = function(var) holdBuffSwapValue2 = var end,
         width = "half",	--or "half" (optional)
    })

     table.insert(optionsTable[6].controls, {
        type = "button",
        name = "Swap Buffs",
        func = function() HTT_swapElementsInTable(HTTsavedVars.orderOfBuffs,HTT_findPositionOfElementInTable(HTTsavedVars.buffTable["names"],holdBuffSwapValue1),HTT_findPositionOfElementInTable(HTTsavedVars.buffTable["names"],holdBuffSwapValue2)) end,
        width = "half",


    })
    for k,v in pairs(HTTsavedVars.orderOfBuffs) do

    table.insert(optionsTable[6].controls, {
                    type = "header",
                    name = ZO_HIGHLIGHT_TEXT:Colorize( HTTsavedVars.buffTable["names"][v]),
                    width = "full",	--or "half" (optional)     
				})

	table.insert(optionsTable[6].controls, {
                    type = "checkbox",
                    name =  HTTsavedVars.buffTable["names"][v].." tracking",
                    getFunc = function() return HTTsavedVars.buffTable["isTurnedOn"][v] end,
                    setFunc = function(value) HTTsavedVars.buffTable["isTurnedOn"][v] = value end,
                    width = "half",	--or "half" (optional)
                    warning = "Will need to reload the UI.",	--(optional)
					})
	table.insert(optionsTable[6].controls, {
                    type = "colorpicker",
                    name = "Bar color for ".. HTTsavedVars.buffTable["names"][v],
                    getFunc = function() return HTTsavedVars.buffTable["colors"][v][1], HTTsavedVars.buffTable["colors"][v][2], HTTsavedVars.buffTable["colors"][v][3], HTTsavedVars.buffTable["colors"][v][4] end,	--(alpha is optional)
                    setFunc = function(r,g,b,a) 
                    HTTsavedVars.buffTable["colors"][v][1] = r 
                    HTTsavedVars.buffTable["colors"][v][2] = g
                    HTTsavedVars.buffTable["colors"][v][3] = b
                    HTTsavedVars.buffTable["colors"][v][4] = a
                    end,	--(alpha is optional)
                    width = "half",	--or "half" (optional)
                    warning = "Will need to reload the UI.",
					})
					table.insert(optionsTable[6].controls, {
				type = "button",
				name = "Delete Tracker",
				func = function() HTT_removeBuff(v) end,
				width = "half",
                warning = "Will need to reload the UI.",
			})
	end

 



	table.insert(optionsTable, {
        type = "submenu",
        name = "Add new debuff tracker",
        controls = {
			[1] = {
                type = "editbox",
                name = "Name of the tracker",
                getFunc = function() return createNewDebuffSavedVariables["name"]  end,
                setFunc = function(text) createNewDebuffSavedVariables["name"] = text end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[2] = {
                type = "editbox",
                name = "ID of tracked debuff",
                getFunc = function() return createNewDebuffSavedVariables["ID"] end,
                setFunc = function(text) createNewDebuffSavedVariables["ID"] = tonumber(text) end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[3] = {
                type = "editbox",
                name = "Text to display on the bar",
                getFunc = function() return createNewDebuffSavedVariables["text"] end,
                setFunc = function(text) createNewDebuffSavedVariables["text"] = text end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[4] = {
                type = "editbox",
                name = "Text to display when missing",
                getFunc = function() return createNewDebuffSavedVariables["textWhenMissing"] end,
                setFunc = function(text) createNewDebuffSavedVariables["textWhenMissing"] = text end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[5] = {
                type = "colorpicker",
                name = "My Color Picker",
                tooltip = "Color Picker's tooltip text.",
                getFunc = function() return createNewDebuffSavedVariables["color"][1], createNewDebuffSavedVariables["color"][2], createNewDebuffSavedVariables["color"][3], createNewDebuffSavedVariables["color"][4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) createNewDebuffSavedVariables["color"][1] = r
				createNewDebuffSavedVariables["color"][2] = g
				createNewDebuffSavedVariables["color"][3] = b
				createNewDebuffSavedVariables["color"][4] = a
				end,	--(alpha is optional)
                width = "half",	--or "half" (optional)

            },
            [6] = {
                type = "checkbox",
                name = "Track debuffs only applied by you",
                tooltip = "Checkbox's tooltip text.",
                getFunc = function() return createNewDebuffSavedVariables["onlyPlayer"] end,
                setFunc = function(value) createNewDebuffSavedVariables["onlyPlayer"]=value end,
                width = "half",	--or "half" (optional)

            },
            [7] = {
				type = "button",
				name = "Create Debuff Tracker",
				func = function() HTT_addDebuff(createNewDebuffSavedVariables["name"],createNewDebuffSavedVariables["ID"],#HTTsavedVars.orderOfDebuffs+1,createNewDebuffSavedVariables["text"],createNewDebuffSavedVariables["textWhenMissing"],createNewDebuffSavedVariables["color"],createNewDebuffSavedVariables["onlyPlayer"])  end,
				width = "half",
				warning = "Will need to reload the UI.",	--(optional)
			},
            
        },
    })

	table.insert(optionsTable, {
        type = "submenu",
        name = "Add new buff tracker",
        controls = {
			[1] = {
                type = "editbox",
                name = "Name of the tracker",
                getFunc = function() return createNewBuffSavedVariables["name"]  end,
                setFunc = function(text) createNewBuffSavedVariables["name"] = text end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[2] = {
                type = "editbox",
                name = "ID of tracked buff",
                getFunc = function() return createNewBuffSavedVariables["ID"] end,
                setFunc = function(text) createNewBuffSavedVariables["ID"] = tonumber(text) end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[3] = {
                type = "editbox",
                name = "Text to display on the bar",
                getFunc = function() return createNewBuffSavedVariables["text"] end,
                setFunc = function(text) createNewBuffSavedVariables["text"] = text end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[4] = {
                type = "editbox",
                name = "Text to display when missing",
                getFunc = function() return createNewBuffSavedVariables["textWhenMissing"] end,
                setFunc = function(text) createNewBuffSavedVariables["textWhenMissing"] = text end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)

                default = "",	--(optional)
            },
			[5] = {
                type = "colorpicker",
                name = "My Color Picker",
                tooltip = "Color Picker's tooltip text.",
                getFunc = function() return createNewBuffSavedVariables["color"][1], createNewBuffSavedVariables["color"][2], createNewBuffSavedVariables["color"][3], createNewBuffSavedVariables["color"][4] end,	--(alpha is optional)
                setFunc = function(r,g,b,a) createNewBuffSavedVariables["color"][1] = r
				createNewBuffSavedVariables["color"][2] = g
				createNewBuffSavedVariables["color"][3] = b
				createNewBuffSavedVariables["color"][4] = a
				end,	--(alpha is optional)
                width = "half",	--or "half" (optional)

            },
            [6] = {
				type = "button",
				name = "Create Buff Tracker",
				func = function() HTT_addBuff(createNewBuffSavedVariables["name"],createNewBuffSavedVariables["ID"],#HTTsavedVars.orderOfBuffs+1,createNewBuffSavedVariables["text"],createNewBuffSavedVariables["textWhenMissing"],createNewBuffSavedVariables["color"])  end,
				width = "half",
				warning = "Will need to reload the UI.",
			},
            
        },
    })
    ]]

	--[[
    -- Category. --
    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("My Header"),
        width = "full",	--or "half" (optional)
    })

    table.insert(optionsTable, {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = "My description text to display.",
        width = "full",	--or "half" (optional)
    })

    table.insert(optionsTable, {
        type = "dropdown",
        name = "My Dropdown",
        tooltip = "Dropdown's tooltip text.",
        choices = {"table", "of", "choices"},
        getFunc = function() return "of" end,
        setFunc = function(var) print(var) end,
        width = "half",	--or "half" (optional)
        warning = "Will need to reload the UI.",	--(optional)
    })

    table.insert(optionsTable, {
        type = "dropdown",
        name = "My Dropdown",
        tooltip = "Dropdown's tooltip text.",
        choices = {"table", "of", "choices"},
        getFunc = function() return "of" end,
        setFunc = function(var) print(var) end,
        width = "half",	--or "half" (optional)
        warning = "Will need to reload the UI.",	--(optional)
    })

    table.insert(optionsTable, {
        type = "slider",
        name = "My Slider",
        tooltip = "Slider's tooltip text.",
        min = 0,
        max = 20,
        step = 1,	--(optional)
        getFunc = function() return 3 end,
        setFunc = function(value) d(value) end,
        width = "half",	--or "half" (optional)
        default = 5,	--(optional)
    })

    table.insert(optionsTable, {
        type = "button",
        name = "My Button",
        tooltip = "Button's tooltip text.",
        func = function() d("button pressed!") end,
        width = "half",	--or "half" (optional)
        warning = "Will need to reload the UI.",	--(optional)
    })



    table.insert(optionsTable, {
        type = "submenu",
        name = "Submenu Title",
        tooltip = "My submenu tooltip",	--(optional)
        controls = {
            [1] = {
                type = "checkbox",
                name = "My Checkbox",
                tooltip = "Checkbox's tooltip text.",
                getFunc = function() return true end,
                setFunc = function(value) d(value) end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            },
            [2] = {
                type = "colorpicker",
                name = "My Color Picker",
                tooltip = "Color Picker's tooltip text.",
                getFunc = function() return 1, 0, 0, 1 end,	--(alpha is optional)
                setFunc = function(r,g,b,a) print(r, g, b, a) end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "warning text",
            },
            [3] = {
                type = "editbox",
                name = "My Editbox",
                tooltip = "Editbox's tooltip text.",
                getFunc = function() return "this is some text" end,
                setFunc = function(text) print(text) end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
                default = "",	--(optional)
            },
        },
    })

    table.insert(optionsTable, {
        type = "custom",
        reference = "MyAddonCustomControl",	--unique name for your control to use as reference
        refreshFunc = function(customControl) end,	--(optional) function to call when panel/controls refresh
        width = "half",	--or "half" (optional)
    })

    table.insert(optionsTable, {
        type = "texture",
        image = "EsoUI\\Art\\ActionBar\\abilityframe64_up.dds",
        imageWidth = 64,	--max of 250 for half width, 510 for full
        imageHeight = 64,	--max of 100
        tooltip = "Image's tooltip text.",	--(optional)
        width = "half",	--or "half" (optional)
    })]]
    
    LibAddonMenu2:RegisterOptionControls("Yandir Tracker", optionsTable)
end