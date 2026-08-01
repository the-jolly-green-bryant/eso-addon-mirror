local num_char  --track character number drawing for, for positioning

function RT.GRID_Remove_Expired()					--- Prevent display for completely expired crafting chars.
		for k, _ in pairs(RT.SV.data.Craft) do

			if ((RT.SV.data.Craft[k][0].Simu_craft == 0 and
				RT.SV.data.Craft[k][1].Simu_craft == 0 and
				RT.SV.data.Craft[k][2].Simu_craft == 0))
			then
				RT.SV.data.Craft[k] = nil
				if RT.debug then d("Expired char" .. k) end
			end
		end
end

function RT.GRID_Create()

		RT.UI.GRID_TLW = WINDOW_MANAGER:CreateTopLevelWindow("RT_GRID_TLW")
		RT.UI.GRID_TLW:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,5,0)
		RT.UI.GRID_TLW:SetClampedToScreen(false)
		RT.UI.GRID_TLW:SetMouseEnabled(true)
		RT.UI.GRID_TLW:SetDrawLayer(1)
		RT.UI.GRID_TLW:SetHidden(true)


		--/background
		RT.UI.GRID_BD = WINDOW_MANAGER:CreateControlFromVirtual("RT_GRID_BD",RT.UI.GRID_TLW, "ZO_DefaultBackdrop")

		-- Close Button
		RT.UI.GRID_BTN = WINDOW_MANAGER:CreateControl("RT_GRID_BTN" , RT.UI.GRID_TLW, CT_BUTTON)
		RT.UI.GRID_BTN:SetDimensions( 30 , 30 )
		RT.UI.GRID_BTN:SetAnchor(TOPRIGHT,RT.UI.GRID_TLW,TOPRIGHT,-10,5)
		RT.UI.GRID_BTN:SetState( BSTATE_NORMAL )
--		RT.UI.GRID_BTN:SetMouseOverBlendMode(0)
		RT.UI.GRID_BTN:SetNormalTexture("/esoui/art/buttons/decline_down.dds")
		RT.UI.GRID_BTN:SetMouseOverTexture("/esoui/art/buttons/decline_up.dds")
		RT.UI.GRID_BTN:SetHandler( "OnClicked" , RT.toggleGRID )
		--RT.UI.GRID_BTN:SetHandler( "OnClicked" , function(self) RT.UI.GRID_TLW:SetHidden(true); end )

		for k, _ in pairs(RT.SV.data.Craft) do
			RT.GRID_Create_Character(k)
		end
end

function RT.GRID_Create_Character(k)

	local width = 480
	local panelheight = 130  -- per character  at 100%
	local prevcontrol, ctl_headers
	local numchar = RT.UI.GRID_TLW
		ctl_headers = {}		-- controls at top of craft, indexed on craft
		if (num_char == nil) then
			num_char = 0
		end

				RT.UI.GRID_WD[k] = {}
				-- Containing window for character data. We can then move it as a group
				RT.UI.GRID_WD[k].panel = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_panel",RT.UI.GRID_TLW, CT_CONTROL)
				RT.UI.GRID_WD[k].panel:SetAnchor(TOPRIGHT,RT.UI.GRID_TLW,TOPRIGHT,0,panelheight*num_char)
				RT.UI.GRID_WD[k].panel:SetDimensions(width,panelheight)

				-- label for character name
				RT.UI.GRID_WD[k].label = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_label",RT.UI.GRID_WD[k].panel,CT_LABEL)
				RT.UI.GRID_WD[k].label:SetFont(RT.font)
				RT.UI.GRID_WD[k].label:SetDimensions(width,20)
				RT.UI.GRID_WD[k].label:SetAnchor(TOPLEFT,RT.UI.GRID_WD[k].panel,TOPLEFT,0,0)
				RT.UI.GRID_WD[k].label:SetHorizontalAlignment(1)
				RT.UI.GRID_WD[k].label:SetText(string.upper(k))

				prevcontrol = RT.UI.GRID_WD[k].label	-- use this to anchor the next control, in this case the row of skill headers


        -- Create section headers with dummy text for each skill
				--blacksmithing
				RT.UI.GRID_WD[k][0] = {}
				RT.UI.GRID_WD[k][0][0]	= {}
				RT.UI.GRID_WD[k][0][0]["BS_Icon"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_0_icon",RT.UI.GRID_WD[k].panel,CT_TEXTURE)
				RT.UI.GRID_WD[k][0][0]["BS_Icon"]:SetHidden(false)
				RT.UI.GRID_WD[k][0][0]["BS_Icon"]:SetDimensions(20,20)
				RT.UI.GRID_WD[k][0][0]["BS_Icon"]:SetAnchor(TOPLEFT,prevcontrol,BOTTOMLEFT,0,5)  -- below
				RT.UI.GRID_WD[k][0][0]["BS_Icon"]:SetTexture("/esoui/art/icons/ability_smith_007.dds")

				RT.UI.GRID_WD[k][0][0]["BS_Text"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_0_text",RT.UI.GRID_WD[k].panel,CT_LABEL)
				RT.UI.GRID_WD[k][0][0]["BS_Text"]:SetHidden(false)
				RT.UI.GRID_WD[k][0][0]["BS_Text"]:SetFont(RT.font)
				RT.UI.GRID_WD[k][0][0]["BS_Text"]:SetDimensions(width/4,20)
				RT.UI.GRID_WD[k][0][0]["BS_Text"]:SetAnchor(TOPLEFT,RT.UI.GRID_WD[k][0][0]["BS_Icon"],TOPRIGHT,0,0)   -- Side by the previous
				RT.UI.GRID_WD[k][0][0]["BS_Text"]:SetText(RT.L["Loading"])
				ctl_headers[0] = RT.UI.GRID_WD[k][0][0]["BS_Icon"]

				--Clothing
				RT.UI.GRID_WD[k][1] = {}
				RT.UI.GRID_WD[k][1][0] = {}
				RT.UI.GRID_WD[k][1][0]["CL_Icon"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_1_icon",RT.UI.GRID_WD[k].panel,CT_TEXTURE)
				RT.UI.GRID_WD[k][1][0]["CL_Icon"]:SetHidden(false)
				RT.UI.GRID_WD[k][1][0]["CL_Icon"]:SetDimensions(20,20)
				RT.UI.GRID_WD[k][1][0]["CL_Icon"]:SetAnchor(TOPLEFT,prevcontrol,BOTTOMLEFT,width/4,5)
				RT.UI.GRID_WD[k][1][0]["CL_Icon"]:SetTexture("/esoui/art/icons/ability_tradecraft_008.dds")

				RT.UI.GRID_WD[k][1][0]["CL_Text"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_1_text",RT.UI.GRID_WD[k].panel,CT_LABEL)
				RT.UI.GRID_WD[k][1][0]["CL_Text"]:SetHidden(false)
				RT.UI.GRID_WD[k][1][0]["CL_Text"]:SetFont(RT.font)
				RT.UI.GRID_WD[k][1][0]["CL_Text"]:SetDimensions(width/4,20)
				RT.UI.GRID_WD[k][1][0]["CL_Text"]:SetAnchor(TOPLEFT,RT.UI.GRID_WD[k][1][0]["CL_Icon"],TOPRIGHT,0,0)
				RT.UI.GRID_WD[k][1][0]["CL_Text"]:SetText(RT.L["Loading"])
				ctl_headers[1] = RT.UI.GRID_WD[k][1][0]["CL_Icon"]

				--Woodworking
				RT.UI.GRID_WD[k][2] = {}
				RT.UI.GRID_WD[k][2][0] = {}
				RT.UI.GRID_WD[k][2][0]["WO_Icon"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_2_icon",RT.UI.GRID_WD[k].panel,CT_TEXTURE)
				RT.UI.GRID_WD[k][2][0]["WO_Icon"]:SetHidden(false)
				RT.UI.GRID_WD[k][2][0]["WO_Icon"]:SetDimensions(20,20)
				RT.UI.GRID_WD[k][2][0]["WO_Icon"]:SetAnchor(TOPLEFT,prevcontrol,BOTTOMLEFT,(width/2),5)
				RT.UI.GRID_WD[k][2][0]["WO_Icon"]:SetTexture("/esoui/art/icons/ability_tradecraft_009.dds")

				RT.UI.GRID_WD[k][2][0]["WO_Text"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_2_text",RT.UI.GRID_WD[k].panel,CT_LABEL)
				RT.UI.GRID_WD[k][2][0]["WO_Text"]:SetHidden(false)
				RT.UI.GRID_WD[k][2][0]["WO_Text"]:SetFont(RT.font)
				RT.UI.GRID_WD[k][2][0]["WO_Text"]:SetDimensions(width/4,20)
				RT.UI.GRID_WD[k][2][0]["WO_Text"]:SetAnchor(TOPLEFT,RT.UI.GRID_WD[k][2][0]["WO_Icon"],TOPRIGHT,0,0)
				RT.UI.GRID_WD[k][2][0]["WO_Text"]:SetText(RT.L["Loading"])
				ctl_headers[2] = RT.UI.GRID_WD[k][2][0]["WO_Icon"]

				--Jewelrycrafting
				RT.UI.GRID_WD[k][3] = {}
				RT.UI.GRID_WD[k][3][0] = {}
				RT.UI.GRID_WD[k][3][0]["JW_Icon"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_3_icon",RT.UI.GRID_WD[k].panel,CT_TEXTURE)
				RT.UI.GRID_WD[k][3][0]["JW_Icon"]:SetHidden(false)
				RT.UI.GRID_WD[k][3][0]["JW_Icon"]:SetDimensions(20,20)
				RT.UI.GRID_WD[k][3][0]["JW_Icon"]:SetAnchor(TOPLEFT,prevcontrol,BOTTOMLEFT,(width*3/4),5)
				RT.UI.GRID_WD[k][3][0]["JW_Icon"]:SetTexture("/esoui/art/icons/passive_jewelerengraver.dds")

				RT.UI.GRID_WD[k][3][0]["JW_Text"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_3_text",RT.UI.GRID_WD[k].panel,CT_LABEL)
				RT.UI.GRID_WD[k][3][0]["JW_Text"]:SetHidden(false)
				RT.UI.GRID_WD[k][3][0]["JW_Text"]:SetFont(RT.font)
				RT.UI.GRID_WD[k][3][0]["JW_Text"]:SetDimensions(width/4,20)
				RT.UI.GRID_WD[k][3][0]["JW_Text"]:SetAnchor(TOPLEFT,RT.UI.GRID_WD[k][3][0]["JW_Icon"],TOPRIGHT,0,0)
				RT.UI.GRID_WD[k][3][0]["JW_Text"]:SetText(RT.L["Loading"])
				ctl_headers[3] = RT.UI.GRID_WD[k][3][0]["JW_Icon"]

				for craft_id = 0, 3,1 do    -- column
					prevcontrol=ctl_headers[craft_id]   -- line up under this column

					for simcraft = 1, 3,1 do

						RT.UI.GRID_WD[k][craft_id][simcraft] = {}
						-- item icon
						RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_"..craft_id.."_"..simcraft.."_icon",RT.UI.GRID_WD[k].panel,CT_TEXTURE)
						RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]:SetHidden(true)
						RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]:SetDimensions(20,20)
						RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]:SetAnchor(TOPLEFT,prevcontrol,BOTTOMLEFT,0,0)  --below
						RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]:SetMouseEnabled(true)
						prevcontrol= RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]


						-- trait icon
						RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_"..craft_id.."_"..simcraft.."_trait",RT.UI.GRID_WD[k].panel,CT_TEXTURE)
						RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetHidden(true)
						RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetDimensions(20,20)
						RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetAnchor(TOPLEFT,prevcontrol,TOPRIGHT,0,0)  --to right
						RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetMouseEnabled(true)


						RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetHandler("OnMouseExit", function (self)
																					ZO_Tooltips_HideTextTooltip()
																		end)
						prevcontrol=RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]

						-- text
						RT.UI.GRID_WD[k][craft_id][simcraft]["text"] = WINDOW_MANAGER:CreateControl("RT_GRID_"..k.."_"..craft_id.."_"..simcraft.."_text",RT.UI.GRID_WD[k].panel,CT_LABEL)
						RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetHidden(true)
						RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetFont(RT.font)
						RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetDimensions(480,20)
						RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetAnchor(TOPLEFT,prevcontrol,TOPRIGHT,0,0)   --to right

						prevcontrol=RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]		-- set back to beginning of line
					end
				end
				num_char = num_char+1
				RT.UI.GRID_TLW:SetDimensions(width,RT.UI.GRID_WD[k].panel:GetHeight()*num_char)
end

function RT.GRID_Update(timestamp)
        local  emp_start, em_finish
		for k, _ in pairs(RT.SV.data.Craft) do
		--	if ( (RT.SV.data.Craft[k][0].Simu_craft ~= 0 or RT.SV.data.Craft[k][1].Simu_craft ~= 0 or RT.SV.data.Craft[k][2].Simu_craft ~= 0)) then
				for craft_id = 0, 3,1 do
					if (RT.SV.data.Craft[k][craft_id].MaxResearch ~= nil ) then
						local MaxResearch = RT.SV.data.Craft[k][craft_id].MaxResearch
						local Simu_craft = RT.SV.data.Craft[k][craft_id].Simu_craft
						if Simu_craft == MaxResearch then
							emp_start = ""		--no highlighting
							em_finish = ""
						else
							emp_start = "|cFF0000"
							em_finish = "|r"
						end
						if (craft_id == 0) then
						RT.UI.GRID_WD[k][craft_id][0]["BS_Text"]:SetText(" "..emp_start .. Simu_craft.." / "..MaxResearch .. em_finish)

						elseif(craft_id == 1) then

						RT.UI.GRID_WD[k][craft_id][0]["CL_Text"]:SetText(" "..emp_start .. Simu_craft.." / "..MaxResearch .. em_finish)
						elseif(craft_id == 2) then
						RT.UI.GRID_WD[k][craft_id][0]["WO_Text"]:SetText(" "..emp_start .. Simu_craft.." / "..MaxResearch .. em_finish)
						elseif(craft_id == 3) then
						RT.UI.GRID_WD[k][craft_id][0]["JW_Text"]:SetText(" "..emp_start .. Simu_craft.." / "..MaxResearch .. em_finish)
						end

					end


					for simcraft = 1, 3,1 do
					    --erase the display, need when a research is completed.
						RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetHidden(true)
						RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]:SetHidden(true)
						RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetHidden(true)

						if (RT.SV.data.Craft[k][craft_id].doing[simcraft] ~= nil)then


							RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]:SetHidden(false)
							RT.UI.GRID_WD[k][craft_id][simcraft]["item_icon"]:SetTexture(RT.SV.data.Craft[k][craft_id].doing[simcraft]["Item_icon"])

							RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetHidden(false)
							RT.UI.GRID_WD[k][craft_id][simcraft]["trait_icon"]:SetTexture(RT.SV.data.Craft[k][craft_id].doing[simcraft]["Trait_icon"])

							local currenttimer = RT.SV.data.Craft[k][craft_id].doing[simcraft]["EndTimeStamp"] - timestamp - 1
							RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetHidden(false)
							if (currenttimer > 0) then
							local tFormatted = FormatTimeSeconds(currenttimer, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
							-- chop seconds
								RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetText(string.sub(tFormatted, 1,string.len(tFormatted)-3))
							else  -- only triggers on display of not logged in chars. Current Char causes a data reload
								RT.UI.GRID_WD[k][craft_id][simcraft]["text"]:SetText(RT.L["Finished"])
								RT.UI.GRID_WD[k].label:SetText("|cFF0000" .. string.upper(k) .."|r" )
							end
						end
					end
				end
			-- end
		end
		RT.Set_Shortest()
end
function RT.Char_sort()    -- Produce a sorted list for display
  RT.CharsInOrder = {}
  for k, _ in pairs(RT.SV.data.Craft) do
			table.insert(RT.CharsInOrder,k)
  end

  table.sort(RT.CharsInOrder, function (a,b) return RT.SV.data.Craft[a].shortest < RT.SV.data.Craft[b].shortest end)
end

-- move characters in grid
function RT.GRID_Sort()
    local panelheight
	RT.Char_sort()
    panelheight = RT.UI.GRID_WD[RT.CharsInOrder[1]].panel:GetHeight()  -- after scaling
	for k, v  in ipairs(RT.CharsInOrder) do
		RT.UI.GRID_WD[v].panel:SetAnchor(TOPLEFT,RT.UI.GRID_TLW,TOPLEFT,0,panelheight*(k-1))
	end

	RT.UI.GRID_TLW:SetHeight(table.getn(RT.CharsInOrder) * panelheight)
 end
EVENT_MANAGER:RegisterForEvent(RT.name, EVENT_ADD_ON_LOADED, RT.Init)
