----- Guild Store Search extended 

----- Declare Core Data/Objects
gsse={
    State="NONE",
    ResultControls = {},
    ResultsSlider = nil,
    StoreItems = {},
    SearchMatches = {},
    Terms = nil,
    CurrentGuildIndex = 1,
    Guilds = {},
    dropDownInit=false,
    last_search_count=0,		
    language_options={"Auto","English","Deutsch","Français", "Russian"},
    Version = "0.13.2h",
    Author = "lintydruid/Sephiroth08/tridman",	
}
gsse.data={
    window={x=0,y=0},
    undercutPerc=5,  -- Undercut Percentage
    itemData={},
    tooltips={session=true, history=true, recommend=true},
    search_results={},
    last_search="",			
    language="Auto",
    lastSearchRequest = {},
}

gsse.utils={}

-- Declare Locale Control
gsse.lang={}
gsse.lang.sets={}
gsse.lang.core={}
gsse.lang.gui={}
gsse.lang.config={}		

gsse.defaults = {
    window = {
        x=0,
        y=0,
    },
    undercutPerc = 5,
    showdebug = false,
    language = "Auto",
    tooltips = {
        session = true,
        history = true,
        recommend = true
    },
    lastSearchRequest = {},
}

-------------------------------Output --------------------
function gsse.message (text)
    d (text)
end

function gsse.debug (text)
    if gsse.data.showdebug~=nil  then
        if gsse.data.showdebug==true then
            gsse.message("|c2080D0GSSE debug :: |r"..text)
        end
    end
end
------------------------------ Initialize------------------------------------
function gsse.upgradeData()
    if  gsse.data.showdebug == nil then  gsse.data.showdebug=false end

    if  gsse.data.itemData == nil then  gsse.data.itemData={} end
    if  gsse.data.tooltips == nil then gsse.data.tooltips={session=true, history=true, recommend=true} end

    if  gsse.data.search_results == nil then gsse.data.search_results={} end
    if  gsse.data.last_search == nil then gsse.data.last_search="" end

    if  gsse.data.language==nil then gsse.data.language="Auto" end

end

function gsse.Initialize(eventCode, addOnName)
    if(addOnName == "GuildStoreSearchEx") then
        EVENT_MANAGER:UnregisterForEvent("GuildStoreSearchEx", EVENT_ADD_ON_LOADED)

        --	Load saved vars
        gsse.data = ZO_SavedVars:NewAccountWide( "gsse_data" , 1 , nil , gsse.defaults  , nil )

        -- Data Clean-up/Upgrade
        gsse.upgradeData();

        gsse.lang.Set(gsse.data.language) --- Initialise Locale

        gsse.config.create() -- config window

        --Window Co-ord Managment
        GuildStoreSearchEx:SetHandler("OnMoveStop", gsse.SetFrameCoords)
        GuildStoreSearchEx:SetAnchor(CENTER, GuiRoot, CENTER, gsse.data.window.x,gsse.data.window.y)
        GuildStoreSearchEx:SetMovable(true)

        --Main Init
        if #gsse.ResultControls == 0 then

            local resultLineOffsetX = 0
            local resultLineOffsetY = 0

            for i = 1,10 do
                local control = CreateControlFromVirtual(
                    "GuildStoreSearchExResult", GuildStoreSearchExResultsBG, "GuildStoreSearchExResult", i)
                control:SetSimpleAnchorParent(resultLineOffsetX, resultLineOffsetY+((control:GetHeight()+2)*(i-1)))
                control:SetText(i .. ":")

                gsse.ResultControls[i] = control
            end

            local bg = CreateControlFromVirtual("GuildStoreSearchExEditBg", GuildStoreSearchEx, "ZO_EditBackdrop")
            bg:SetParent(GuildStoreSearchEx)
            bg:SetDimensions(300,28)
            bg:SetSimpleAnchorParent(GuildStoreSearchEx:GetNamedChild("ForLabel"):GetWidth(), 5)

            GuildStoreSearchExTerms = CreateControlFromVirtual("GuildStoreSearchExTerms", bg, "ZO_DefaultEditForBackdrop")
            GuildStoreSearchExTerms:SetParent(bg)
            GuildStoreSearchExTerms:SetDimensions(300,28)
            GuildStoreSearchExTerms:SetResizeToFitDescendents(false)
            GuildStoreSearchExTerms:SetMouseEnabled(true)
            GuildStoreSearchExTerms:SetText("")  
            GuildStoreSearchExTerms:SetHandler("OnMouseDoubleClick",gsse.GetCurrentSellName) -----  Added by LintyDruid

            local gdd = CreateControlFromVirtual("GuildStoreSearchExGuildCombo", GuildStoreSearchEx, "GuildStoreSearchExDropdown")
            gdd:SetDimensions(300,28)
            gdd:SetSimpleAnchorParent(GuildStoreSearchEx:GetNamedChild("GuildLabel"):GetWidth(), bg:GetHeight() + 10 )

            GuildStoreSearchExResultsBG:SetMouseEnabled(true)
            GuildStoreSearchExResultsBG:SetHandler("OnMouseWheel", gsse.OnSliderMouseWheel)

            gsse.ResultsSlider = gsse.CreateSlider("GuildStoreSearchExSlider", GuildStoreSearchEx)
            gsse.ResultsSlider:SetAnchor(LEFT,GuildStoreSearchExResultsBG,RIGHT,0,0)
            gsse.ResultsSlider:SetHandler("OnValueChanged", gsse.OnSliderMoved)

            local pane = ZO_TradingHouseMenuBar

            --local toggleButton = CreateControl("GuildStoreSearchExToggleButton", pane, CT_BUTTON)
            local toggleButton = CreateControlFromVirtual("GuildStoreSearchExToggleButton", pane, "ZO_DefaultButton")

            toggleButton:SetDimensions(195,31)
            toggleButton:SetHidden(false)
            toggleButton:SetFont("ZoFontGameBold")
            toggleButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            toggleButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

            --toggleButton:SetNormalTexture("/esoui/art/contacts/social_status_online.dds")
            --toggleButton:SetMouseOverTexture("/esoui/art/contacts/social_status_highlight.dds")
            toggleButton:SetText(gsse.lang.gui.main_cmd)
            --toggleButton:SetNormalTexture("esoui/art/tradinghouse/tradinghouse_browse_tabicon_up.dds")
            toggleButton:SetAnchor(TOPLEFT, pane, TOPLEFT, 200, 5)
            toggleButton:SetHandler("OnMouseDown", function() gsse.PopulateGuildList() gsse.GuildStoreSearchToggle() end)

            --bg = CreateControlFromVirtual("GuildStoreSearchExToggleButtonBG", toggleButton, "GuildStoreSearchExVirtualBG")
            --bg:SetAnchorFill()
        end

        gsse.Reset()

        gsse.ClearSessionData()

        gsse.SetCanContinueSearch()

        GuildStoreSearchExFindMatchesButton:SetHidden(false)

        EVENT_MANAGER:RegisterForEvent("GuildStoreSearchEx", EVENT_GUILD_SELF_JOINED_GUILD, gsse.PopulateGuildList)
        EVENT_MANAGER:RegisterForEvent("GuildStoreSearchEx", EVENT_GUILD_SELF_LEFT_GUILD, gsse.PopulateGuildList)
    end
end

function gsse.ClearSessionData()
    ---Reset Session data
    for id, data in pairs(gsse.data.itemData) do
        for gname, value in pairs(gsse.data.itemData[id].session) do
            if gsse.data.itemData[id].session[gname].lastUpdatedTimestamp == nil or (gsse.data.itemData[id].session[gname].lastUpdatedTimestamp < (GetTimeStamp() - 3600)) then
                gsse.data.itemData[id].session[gname] = nil
            end
        end
    end

    -- clean up  save search data
    for n=1,#gsse.data.search_results,1 do
        if gsse.data.search_results[n][12] == nil or gsse.data.search_results[n][12] < (GetTimeStamp() - 3600) then
            gsse.data.search_results[n][10]=-1 --- set page ref to -1
        end
    end
end

------------------------------ Functions------------------------------------
local function shortguild(guildName)
    spos=string.find(guildName," ")
    if (spos~=nil and spos<18) then
        guildName=string.sub(guildName,1,spos+1)
    end

    if string.len(guildName)>18 then
        guildName=string.sub(guildName,1,15).."..."
    end

    return guildName
end

local function truncGuildName(guildName)
    guildName=guildName.." "

    local ga,gb = guildName:match("([a-z,A-Z].*) ([a-z,A-Z].*) ")

    if ga==nil then ga=guildName end

    local gName=""

    if ga~=nil then gName=gName..ga:sub(1,4) end
    if gb~=nil then gName=gName.."'"..gb:sub(1,4) end


    return gName
end

function gsse.ClearResultLine(index)
    if index < 1 or index > 10 then
        return 
    end

    local resultControl = gsse.ResultControls[index]
    resultControl:SetText("")
    resultControl:GetNamedChild("Price"):SetText("")
    resultControl:GetNamedChild("UnitPrice"):SetText("")
    resultControl:GetNamedChild("BuyButton"):SetText("")
end

function gsse.SetState(newState)
    gsse.State = newState
end

function  gsse.ClearResultLines()
    for i = 1,10 do
        gsse.ClearResultLine(i)
    end
end

function  gsse.ClearResults()
    --  gsse.data.search_results = {}
    gsse.SearchMatches = {}
    --  GuildStoreSearchExFindMatchesButton:SetHidden(true)
    GuildStoreSearchExMatchCounter:SetText("")
    gsse.ClearResultLines()
end

function gsse.Reset()
    if  gsse.Terms ~= nil then GuildStoreSearchExTerms:SetText("") end
    GuildStoreSearchExCounter:SetText("")
    gsse.ResultsSlider:SetMinMax(1,1)
    gsse.ResultsSlider:SetValue(1)
    gsse.ResultsSlider:SetHidden(true)
    gsse.ClearResults()
    gsse.SetState("NONE")

    --- Rebuild list
    gsse.dropDownInit=false
    gsse.PopulateGuildList()
    gsse.SetCanContinueSearch()
end

function gsse.SetResultLine(index, name, count, price, unitPrice, guildId, pageNumber, icon, quality, gName)
    if index < 1 or index > 10 then
        return
    end

    local resultControl = gsse.ResultControls[index]

    name = string.gsub(name,"(^.*)","") -- Clean up link

    resultControl:SetText(string.format(gsse.lang.gui.res_label,icon,gName, gsse.utils.GetQualityColor(quality), name, count))
    resultControl:GetNamedChild("Price"):SetText(string.format(gsse.lang.gui.res_price,price))
    resultControl:GetNamedChild("UnitPrice"):SetText(string.format(gsse.lang.gui.res_unitprice,string.format("%.2f", unitPrice)))

    if (pageNumber>-1) then
        resultControl:GetNamedChild("BuyButton"):SetText(gsse.lang.gui.res_buy)
    else
        resultControl:GetNamedChild("BuyButton"):SetText(gsse.lang.gui.res_buy_off)
    end
end

function gsse.DisplayMatches()
    local startIndex = gsse.ResultsSlider:GetValue()

    -- Don't scroll down lower than the last result
    if startIndex + #gsse.ResultControls - 1 > #gsse.SearchMatches then 
        startIndex = #gsse.SearchMatches - #gsse.ResultControls + 1 
    end

    -- Don't scroll up higher than the first result
    if startIndex < 1 then startIndex = 1 end

    for i = 1, #gsse.ResultControls do
        local resultIndex = i+startIndex-1
        if resultIndex > #gsse.SearchMatches then 
            gsse.ClearResultLine(i)
        else
            local r = gsse.SearchMatches[resultIndex]
            gsse.SetResultLine(i, r[2], r[4], r[7], r[8], r[9], r[10],r[1], r[3], r[11])
        end
    end
end

function gsse.OnSliderMouseWheel(self, delta)
    if #gsse.SearchMatches <= #gsse.ResultControls then return end

    local oldSliderLevel = gsse.ResultsSlider:GetValue()
    local newSliderLevel = oldSliderLevel - delta

    -- local scrollUp = delta > 0
    -- local scrollDown = delta < 0

    gsse.ResultsSlider:SetValue(newSliderLevel)
end

function gsse.OnSliderMoved(self,sliderLevel,eventReason)
    gsse.DisplayMatches()
end

function gsse.CreateSlider(name, parent)
    local slider = CreateControl(name, parent, CT_SLIDER)

    slider.texture =  "/esoui/art/miscellaneous/scrollbox_elevator.dds"
    slider.offset = 0

    local tex = slider.texture

    slider:SetDimensions(30,300)
    slider:SetMouseEnabled(true)
    slider:SetThumbTexture(tex,tex,tex,30,50,0,0,1,1)
    slider:SetMinMax(0,100)
    slider:SetValue(0)
    slider:SetValueStep(1)
    slider:SetAnchor(TOPRIGHT,parent,TOPRIGHT,0,0)

    return slider
end

function gsse.Command(options)
    if options == nil or options=="" then
        ---- command instr
        for i=1, #gsse.lang.core.cmdHelp, 1 do
            gsse.message(gsse.lang.core.cmdHelp[i])
        end
        return
    end

    cmd=string.lower(options)

    gsse.debug("Command line -> ["..cmd.."]")

    if cmd == "show" or cmd == "on" then
        gsse.showWindow()
    elseif omd == "hide" or cmd == "off"  then
        gsse.hideWindow()
    end
end


function gsse.showWindow()
    --- Rebuild list
    gsse.PopulateGuildList()

    GuildStoreSearchEx:SetHidden(false)
end

function gsse.hideWindow()
    GuildStoreSearchEx:SetHidden(true)
end

function gsse.GuildStoreSearchToggle()
    if GuildStoreSearchEx:IsHidden() then
        gsse.showWindow()
    else
        gsse.hideWindow()
    end
end

----- Function Added by LintyDruid
function gsse.GetCurrentSellName()
    GuildStoreSearchExTerms:SetText('"'..ZO_TradingHouseLeftPanePostItemFormInfoName:GetText()..'"')
end
----- End Function Added by LintyDruid

function gsse.CollateResults(guildId, numItemsOnPage, currentPage, hasMorePages)
    for i = 1, numItemsOnPage do
        gsse.last_search_count=gsse.last_search_count+1

        local icon, name, quality, stackCount, seller, timeRemaining, price = 
        GetTradingHouseSearchResultItemInfo(i)

        if (not(tonumber(stackCount) == nil)
            and not(tonumber(timeRemaining) == nil)
            and not (tonumber(price) == nil))
        then

          local currentResult = {icon, name, quality, tonumber(stackCount), seller, 
              tonumber(timeRemaining), tonumber(price), 
              tonumber(price)/tonumber(stackCount),
              guildId, currentPage,truncGuildName(GetGuildName(guildId)),GetTimeStamp()}
  
          table.insert(gsse.data.search_results, currentResult)
  
          --Build Item History
  
          local itmIndex= gsse.utils:NameCleanupLower(name).."::"..quality
          local gname=GetGuildName(guildId)
          local itmCost=tonumber(price)/tonumber(stackCount)
          local currentTimestamp = GetTimeStamp()
  
          if gsse.data.itemData[itmIndex]==nil then
              gsse.data.itemData[itmIndex]={session={},history={}}
          end
  
          ---- Session
          if gsse.data.itemData[itmIndex].session[gname]==nil then
              gsse.data.itemData[itmIndex].session[gname] = {min=-1, max=-1, seen=0, sum=0, avg=0}
          end
  
          if gsse.data.itemData[itmIndex].session[gname].min==-1 or gsse.data.itemData[itmIndex].session[gname].min>itmCost then
              gsse.data.itemData[itmIndex].session[gname].min=itmCost
          end
  
          if gsse.data.itemData[itmIndex].session[gname].max==-1 or gsse.data.itemData[itmIndex].session[gname].max<itmCost then
              gsse.data.itemData[itmIndex].session[gname].max=itmCost
          end
  
          gsse.data.itemData[itmIndex].session[gname].lastUpdatedTimestamp = currentTimestamp
  
          gsse.data.itemData[itmIndex].session[gname].seen=gsse.data.itemData[itmIndex].session[gname].seen+1
  
          gsse.data.itemData[itmIndex].session[gname].sum=gsse.data.itemData[itmIndex].session[gname].sum+itmCost
  
          gsse.data.itemData[itmIndex].session[gname].avg=gsse.data.itemData[itmIndex].session[gname].sum/gsse.data.itemData[itmIndex].session[gname].seen
  
          -- history
          if gsse.data.itemData[itmIndex].history[gname]==nil then
              gsse.data.itemData[itmIndex].history[gname] = {min=-1, max=-1, seen=0, sum=0, avg=0}
          end
  
          if gsse.data.itemData[itmIndex].history[gname].min==-1 or gsse.data.itemData[itmIndex].history[gname].min>itmCost then
              gsse.data.itemData[itmIndex].history[gname].min=itmCost
          end
  
          if gsse.data.itemData[itmIndex].history[gname].max==-1 or gsse.data.itemData[itmIndex].history[gname].max<itmCost then
              gsse.data.itemData[itmIndex].history[gname].max=itmCost
          end
  
          gsse.data.itemData[itmIndex].history[gname].lastUpdatedTimestamp = currentTimestamp
  
          gsse.data.itemData[itmIndex].history[gname].seen=gsse.data.itemData[itmIndex].history[gname].seen+1
  
          gsse.data.itemData[itmIndex].history[gname].sum=gsse.data.itemData[itmIndex].history[gname].sum+itmCost
  
          gsse.data.itemData[itmIndex].history[gname].avg=gsse.data.itemData[itmIndex].history[gname].sum/gsse.data.itemData[itmIndex].history[gname].seen
        else
          gsse.debug("--------------------------------------")
          gsse.debug("ERROR: Tonumber conversion failed.")
          gsse.debug("stackCount: "..stackCount)
          gsse.debug("timeRemaining: "..timeRemaining)
          gsse.debug("price: "..price)
          gsse.debug("--------------------------------------")
          
        end
    end
end

function gsse.StrictCompareByUnitPrice(a,b)
    return a[8] < b[8]
end

function gsse.ResultsReceived (eventId, guildId, numItemsOnPage, currentPage, hasMorePages)
    gsse.debug("Results ("..gsse.State..")")
    GuildStoreSearchExStatus:SetText("")

    gsse.data.lastSearchRequest.guildId = guildId
    gsse.data.lastSearchRequest.currentPage = currentPage

    if gsse.State == "AWAITING_RESULTS" then
        gsse.CollateResults(guildId, numItemsOnPage, currentPage, hasMorePages)

        if (hasMorePages) then
            gsse.queueTradingHouseSearch(currentPage+1,TRADING_HOUSE_SORT_SALE_PRICE, true)
            GuildStoreSearchExCounter:SetText(string.format(gsse.lang.gui.search, guildId, currentPage+1))
        else
            local resultCount = table.getn(gsse.data.search_results)
            GuildStoreSearchExMatchCounter:SetText(gsse.lang.gui.searchready)
            GuildStoreSearchExCounter:SetText(string.format(gsse.lang.gui.found, gsse.last_search_count, guildId))
            --GuildStoreSearchExFindMatchesButton:SetHidden(false)
            gsse.SetState("NONE")
            gsse.data.lastSearchRequest = {}
            gsse.SetCanContinueSearch()
        end
    elseif  gsse.State == "AWAITING_RESULTS_ALL" then
        gsse.debug("Results for all ["..guildId.."]")

        gsse.CollateResults(guildId, numItemsOnPage, currentPage, hasMorePages)

        if (hasMorePages) then
            gsse.debug("Next Page...")
            gsse.queueTradingHouseSearch(currentPage+1,TRADING_HOUSE_SORT_SALE_PRICE, true)
            GuildStoreSearchExCounter:SetText(string.format(gsse.lang.gui.retrv, guildId, currentPage+1))
        elseif guildId ~= gsse.Guilds[#gsse.Guilds].Id then
            local canBuyFrom = true

            local  nextTradingGuild = gsse.nextTradingHouse(guildId)

            gsse.debug("Next Guild is "..nextTradingGuild.."...")	

            if nextTradingGuild==-1 or guildId==0 then 
                local resultCount = table.getn(gsse.data.search_results)
                GuildStoreSearchExMatchCounter:SetText(gsse.lang.gui.searchready)
                GuildStoreSearchExCounter:SetText(string.format(gsse.lang.gui.foundall, gsse.last_search_count))
                --  GuildStoreSearchExFindMatchesButton:SetHidden(false)
                gsse.SetState("NONE")
            else
                gsse.SaveSwitchTradingHouseGuild("", guildId + 1)
            end
        else 
            local resultCount = table.getn(gsse.data.search_results)
            GuildStoreSearchExCounter:SetText(string.format(gsse.lang.gui.foundall, gsse.last_search_count))
            -- GuildStoreSearchExFindMatchesButton:SetHidden(false)
            gsse.SetState("NONE")
            gsse.data.lastSearchRequest = {}
            gsse.SetCanContinueSearch()
        end
    end
end

function gsse.SaveSwitchTradingHouseGuild(name, guildId)
    local delay = GetTradingHouseCooldownRemaining()

    if delay > 0 then
        delay = delay + 1000
        local delayInSeconds = math.ceil(delay / 1000)
        gsse.debug("waiting "..delay.."ms before switching to "..guildId)
        GuildStoreSearchExStatus:SetText(string.format(gsse.lang.gui.searchpause, delayInSeconds));
        ld_timer.addWithData("GSSE_Search", delay, gsse.SaveSwitchTradingHouseGuild, 1, guildId)  
    else
        gsse.debug("executing switching to "..guildId)
        SelectTradingHouseGuildId(guildId)
        gsse.queueTradingHouseSearch(0,TRADING_HOUSE_SORT_SALE_PRICE, true)
    end	
end

function gsse.GuildStoreClosed()
    if  GuildStoreSearchEx:IsHidden() == false then
        GuildStoreSearchEx:ToggleHidden()
    end
end

function gsse.PopulateGuildList()
    if gsse.dropDownInit then return end

    gsse.dropDownInit=true

    local dropdown = ZO_ComboBox_ObjectFromContainer(GuildStoreSearchEx:GetNamedChild("GuildCombo"))
    gsse.CurrentGuildIndex = 1
    gsse.Guilds = {}

    dropdown:ClearItems()

    local entry = dropdown:CreateItemEntry(gsse.lang.gui.guild_all, function() end)
    dropdown:AddItem(entry)

    local numGuilds = GetNumGuilds()
    local currentIndex = 0

    while #gsse.Guilds < numGuilds do
        local resultId = GetGuildId(currentIndex)

        if resultId ~= 0 then
            local name = GetGuildName(resultId)

            local color="|cFFFFFF"

            if gsse.canUseTradingHouse(resultId) == false then
                color="|cff0000" 
            else
                color="|cFFFF00"
            end

            gsse.debug("Dropdown add ::".. string.format(gsse.lang.gui.guild_templ, resultId, color, name))

            local formattedName = string.format(gsse.lang.gui.guild_templ, resultId, color, name)

            local entry = dropdown:CreateItemEntry(string.format(gsse.lang.gui.guild_templ, resultId, color, name), function() end)
            dropdown:AddItem(entry)

            table.insert(gsse.Guilds, { Id = resultId, Name = name, FormattedName = formattedName })
        end

        currentIndex = currentIndex + 1
    end

    dropdown:SetSelectedItem(gsse.lang.gui.guild_all) 

    gsse.dropDownInit = false
end

function gsse.StatusReceived()
    -- gsse.PopulateGuildList()
end

function gsse.GetGuildIdFromDropdown()
    local dropdown = ZO_ComboBox_ObjectFromContainer(GuildStoreSearchEx:GetNamedChild("GuildCombo"))
    local guildId = dropdown:GetSelectedItem()

    if guildId ~= gsse.lang.gui.guild_all then 
        guildId = string.sub(guildId, 2, 2)
    end

    return guildId
end

function gsse.SetGuildTextForDropdown(guildId)
    local dropdown = ZO_ComboBox_ObjectFromContainer(GuildStoreSearchEx:GetNamedChild("GuildCombo"))
    local items = dropdown:GetItems()

    if guildId ~= gsse.lang.gui.guild_all then
        for key, value in pairs(items) do
            if guildId == string.sub(value.name, 2, 2) then
                guildId = value.name
                break
            end
        end
    end

    dropdown:SetSelectedItem(guildId)
end

function gsse.canUseTradingHouse(guildId)
    return ((DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_STORE_BUY) or DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_STORE_SELL)) and DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE))
end

function gsse.nextTradingHouse(guildInd)
    guildInd=guildInd+1

    for i = 1, #gsse.Guilds, 1 do
        local guildId = gsse.Guilds[i].Id
        if gsse.canUseTradingHouse(guildId) then 
            return guildId
        end
    end

    return -1 -- no more
end

function gsse.SetCanContinueSearch()
    local button = GuildStoreSearchEx:GetNamedChild("ContinueSearchButton")

    if gsse.data.lastSearchRequest.guildId == nil then
        button:SetEnabled(false)
    else
        button:SetEnabled(true)
    end
end

function gsse.ContinueSearch()
    if ZO_TradingHouse:IsHidden() then
        gsse.message(gsse.lang.gui.searchNoGS);
        return
    end

    if gsse.State ~= "NONE" then 
        gsse.message(gsse.lang.gui.searchBusy);
        return

    end
    gsse.debug("Retrv...")

    -- GuildStoreSearchExFindMatchesButton:SetHidden(true)

    gsse.ClearResults()

    gsse.SetGuildTextForDropdown(gsse.data.lastSearchRequest.SelectedGuild)

    GuildStoreSearchExCounter:SetText(gsse.lang.gui.searchStarte);

    SelectTradingHouseGuildId(tonumber(gsse.data.lastSearchRequest.guildId))

    gsse.debug("Searching...")
    gsse.queueTradingHouseSearch(gsse.data.lastSearchRequest.currentPage ,TRADING_HOUSE_SORT_SALE_PRICE, true)

    if selectedText == gsse.lang.gui.guild_all then 
        gsse.SetState("AWAITING_RESULTS_ALL")
    else
        gsse.SetState("AWAITING_RESULTS")
    end
end

function gsse.Retrieve()   
    if ZO_TradingHouse:IsHidden() then
        gsse.message(gsse.lang.gui.searchNoGS);
        return
    end

    if gsse.State ~= "NONE" then 
        gsse.message(gsse.lang.gui.searchBusy);
        return

    end
    gsse.debug("Retrv...")

    -- GuildStoreSearchExFindMatchesButton:SetHidden(true)

    gsse.ClearResults()

    selectedText =  gsse.GetGuildIdFromDropdown()
    gsse.data.lastSearchRequest.SelectedGuild = selectedText

    GuildStoreSearchExCounter:SetText(gsse.lang.gui.searchStarte);
    gsse.last_search_count = 0

    if selectedText == gsse.lang.gui.guild_all then 
        gsse.debug("Finding all...")
        gsse.data.search_results = {} -- clear all results for a full refresh
        local firstTradingGuild = gsse.nextTradingHouse(0)

        if firstTradingGuild == -1 then 
            GuildStoreSearchExCounter:SetText(gsse.lang.gui.noTradingGuilds);
            return
        end

        gsse.debug("Selected guild"..firstTradingGuild.."...")
        SelectTradingHouseGuildId(firstTradingGuild)
    else
        if gsse.canUseTradingHouse(tonumber(selectedText)) then
            SelectTradingHouseGuildId(tonumber(selectedText))

            --   clear results for the selected guild.
            for n = #gsse.data.search_results,1,-1 do
                if gsse.data.search_results[n][9]==tonumber(selectedText) then
                    table.remove(gsse.data.search_results,n)
                end
            end
        else
            GuildStoreSearchExCounter:SetText(string.format(gsse.lang.gui.notATradingGuild,(tonumber(selectedText))))
            return
        end
    end

    gsse.debug("Searching...")
    gsse.queueTradingHouseSearch(0,TRADING_HOUSE_SORT_SALE_PRICE, true)

    if selectedText == gsse.lang.gui.guild_all then 
        gsse.SetState("AWAITING_RESULTS_ALL")
    else
        gsse.SetState("AWAITING_RESULTS")
    end
end

function  gsse.queueTradingHouseSearch(a,b,c)
    --need a message mere
    gsse.debug("Queuing request for "..a..", "..b)

    gsse.SaveQueueTradingHouseSearch("", {a, b, c})
end 

function gsse.SaveQueueTradingHouseSearch(name, params)
    local delay = GetTradingHouseCooldownRemaining()

    if delay > 0 then
        delay = delay + 1000
        local delayInSeconds = math.ceil(delay / 1000)
        gsse.debug("waiting "..delay.."ms before executing search")
        GuildStoreSearchExStatus:SetText(string.format(gsse.lang.gui.searchpause, delayInSeconds));
        ld_timer.addWithData("GSSE_Search", delay, gsse.SaveQueueTradingHouseSearch, 1, params)  
    else
        gsse.debug("executing search")
        gsse.doTradingHouseSearch("", params)
    end	
end

function gsse.doTradingHouseSearch(name,params)
    --d(params)
    GuildStoreSearchExStatus:SetText(gsse.lang.gui.searchproc)
    gsse.debug("Asking for for "..params[1]..", "..params[2].." ...")
    ExecuteTradingHouseSearch(params[1],params[2],params[3])
end

function gsse.FindMatches()
    if gsse.data.search_results == nil or table.getn(gsse.data.search_results) < 1 then return end

    local searchTerms = gsse.utils.Trim(string.lower(GuildStoreSearchExTerms:GetText()))
    if searchTerms == "" then 
        return 
    end

    gsse.ClearResultLines()

    local matches = {}
    local numberOfItems = table.getn(gsse.data.search_results)
    local exact = searchTerms:sub(1,1) == "\"" and searchTerms:sub(-1,-1) == "\""

    -----  Added by LintyDruid
    local unitcost={max=0, min=0, total=0, avg=0, undercut=0}
    -----  End Added by LintyDruid

    for i = 1, numberOfItems do
        local currentResult = gsse.data.search_results[i]
        -- icon, name, quality, stackCount, seller, timeRemaining, 
        -- price, unitPrice, guildId, resultPage 

        local currentGuild = gsse.GetGuildIdFromDropdown()

        local name = currentResult[2]
        local guildId = tostring(currentResult[9])

        if currentGuild == gsse.lang.gui.guild_all then currentGuild = guildId end

        if exact then
            -- Some item names have ^n or ^p at the end.
            -- Remove them if doing an exact search
            if name:sub(-2,-2) == "^" then
                name = name:sub(1,-3)
            end

            -- Remove quotes from search terms
            local unquotedSearchTerms = searchTerms:sub(2,-2)

            if string.lower(name) == unquotedSearchTerms and currentGuild == guildId then
                table.insert(matches, currentResult)
            end
        else
            findResult = string.lower(name):find(searchTerms)

            if findResult ~= nil and currentGuild == guildId then
                table.insert(matches, currentResult)

                -----  Added by LintyDruid
                --- Unit price is 8
                if unitcost.max<currentResult[8] then
                    unitcost.max=currentResult[8]
                end

                if unitcost.min>currentResult[8] or unitcost.min==0 then
                    unitcost.min=currentResult[8]
                end

                unitcost.total=unitcost.total+currentResult[8]

                unitcost.avg=unitcost.total/#matches

                local undercut=((100-gsse.data.undercutPerc)/100)
                unitcost.undercut=unitcost.min*undercut
                -----  End Added by LintyDruid
            end
        end
    end

    table.sort(matches, gsse.StrictCompareByUnitPrice)

    matchCount = table.getn(matches)

    gsse.SearchMatches = matches
    -----  Added by LintyDruid

    local currPostItemBag= ZO_TradingHouseLeftPanePostItemFormInfoItem["bagId"]
    local currPostItemBIndex= ZO_TradingHouseLeftPanePostItemFormInfoItem["itemIndex"]

    local sellFor=""

    if (currPostItemBag~=nil and currPostItemBIndex ~= nil) then
        local numItems=GetItemTotalCount(currPostItemBag,currPostItemBIndex)

        sellFor=string.format(gsse.lang.gui.search_summsell,numItems,math.floor(numItems*unitcost.undercut))
    end

    GuildStoreSearchExMatchCounter:SetText(string.format(gsse.lang.gui.search_summ,matchCount,math.floor(unitcost.max),math.floor(unitcost.min),math.floor(unitcost.avg),math.floor(unitcost.undercut),sellFor))
    -----  End Added by LintyDruid

    if #gsse.SearchMatches <= #gsse.ResultControls then
        gsse.ResultsSlider:SetMinMax(1, 1)
        gsse.ResultsSlider:SetHidden(true)
    else
        gsse.ResultsSlider:SetMinMax(1, #gsse.SearchMatches - #gsse.ResultControls + 1)
        gsse.ResultsSlider:SetHidden(false)
    end

    gsse.ResultsSlider:SetValue(1)

    gsse.DisplayMatches()
end

function gsse.ShowItem(itemButton)
    local start = 23 -- length of "GuildStoreSearchResult" + 1
    local scrollOffset = gsse.ResultsSlider:GetValue() - 1
    local displayRow = tonumber(string.sub(itemButton:GetParent():GetName(), 25, -1)) 
    local resultIndex = displayRow + scrollOffset

    local result = gsse.SearchMatches[ resultIndex ]

    if result == nil then return end

    local guildId = result[9]
    local resultPage = result[10]

    if resultPage<0 then 
        return 
    end

    SelectTradingHouseGuildId(guildId)
    gsse.queueTradingHouseSearch(resultPage,TRADING_HOUSE_SORT_SALE_PRICE, true)
end    

function gsse.Info(itemButton)
    local start = 23 -- length of "GuildStoreSearchResult" + 1
    local scrollOffset = gsse.ResultsSlider:GetValue() - 1
    local displayRow = tonumber(string.sub(itemButton:GetName(), 25, -1)) 
    local resultIndex = displayRow + scrollOffset

    local result = gsse.SearchMatches[ resultIndex ]

    if result == nil then 
        return 
    end

    gsse.ShowToolTip(result )
end    


function gsse.SetFrameCoords()
    local x, y = 0, 0
    local addOnX, addOnY =  GuildStoreSearchEx:GetCenter()
    local guiRootX, guiRootY = GuiRoot:GetCenter()
    x = addOnX - guiRootX
    y = addOnY - guiRootY

    gsse.data.window.x = x
    gsse.data.window.y = y

    --self:SetAnchor(CENTER, GuiRoot,CENTER, x, y)
end

-----------------------------------------Utils-------------------------------------------------------
gsse.utils={}

function gsse.utils:NameCleanupLower(StringVar)
    return string.lower(gsse.utils:NameCleanup(StringVar))
end 

function gsse.utils:NameCleanup(StringVar)
    local apos=string.find( StringVar, "^", 1, true)
    if apos == nil or apos<2 then
        return StringVar
    end

    return string.sub(StringVar,1,apos-1);
end 

local function numfmt(num)
    return math.floor(num)
end

function gsse.ShowToolTip(result)
    local name= result[2]
    local seller=result[5]
    local remains=result[6]
    local quality=result[3]
    local icon = result[1]
    local guild = GetGuildName(result[9])
    local qty= result[4]
    local price=result[7]
    local color=gsse.utils.GetQualityColor(quality)

    PopupTooltip:ClearLines();
    PopupTooltipIcon:SetHidden(false)

    --PopupTooltipFadeRight:SetText("|cFFF000x"..qty)

    PopupTooltipIcon:SetHidden(false)

    PopupTooltipIcon:SetTexture(icon)

    PopupTooltip:AddVerticalPadding(15)
    PopupTooltip:AddLine("|cFFF000x "..qty,"ZoFontAlert",1,1,1,TOPRIGHT,MODIFY_TEXT_TYPE_NONE,RIGHT,false)
    PopupTooltip:AddLine("|c"..color..gsse.utils:NameCleanup(name).."|r","ZoFontAlert")
    ZO_Tooltip_AddDivider(PopupTooltip); 
    PopupTooltip:AddLine("|c008000"..guild.."|r")
    PopupTooltip:AddLine("|c00FFFF"..seller.."|r")
    PopupTooltip:AddLine(gsse.lang.core.icon_gold.."|cFFFFFF"..price.."|r")

    --ZO_Tooltip_AddDivider(PopupTooltip); 

    PopupTooltip.lastLink=gsse.CreateLink(color,name,0,quality,0,0)

    PopupTooltip:SetHidden(false);

    ld_tooltip.forceupdate(PopupTooltip);
end

function gsse.CreateLink(itemColor, itemText, itemID, itemQuality,itemLevel, price )
    local linkTemplate="|H%s:%s|h%s|h"
    local dataTemplate="item:%s:%s:%s:0:0:0:0:0:0:0:0:0:0:0:%s:0:0:0:0:0"

    return linkTemplate:format(itemColor, dataTemplate:format(itemID, itemQuality,itemLevel, price),"["..itemText.."]")
end

-----------------------------------------Tooltip------------------------------------------------------
function gsse.SetTooltip(itemData)
    local itmIndex= gsse.utils:NameCleanupLower(itemData.name).."::"..itemData.quality
    --d(itmIndex)
    local mkr=""
    if gsse.data.itemData[itmIndex]==nil then --- no initial match
        for item, data in pairs(gsse.data.itemData) do
            if (string.find(item,gsse.utils:NameCleanupLower(itemData.name).."::")==1) then
                itmIndex=item
                mkr="?"
                break
            end
        end
        if gsse.data.itemData[itmIndex]==nil then 
            return {} 
        end
    end

    local tt_text={}

    local sess_bp=-1
    local sess_bb=-1
    local sess_gb=""
    local sess_g=""

    local hist_bp=-1
    local hist_bb=-1
    local hist_g=""
    local hist_gb=""

    if next(gsse.data.itemData[itmIndex].session)~=nil  then
        if gsse.data.tooltips.session then -- show session
            table.insert(tt_text,gsse.lang.gui.tt_sesstlt)
        end

        for id,data in pairs(gsse.data.itemData[itmIndex].session) do
            if gsse.data.tooltips.session then -- show session
                table.insert(tt_text,string.format(gsse.lang.gui.tt_line,shortguild(id),numfmt(data.min),numfmt(data.max),numfmt(data.avg),numfmt(data.min*((100-gsse.data.undercutPerc)/100))))
            end

            if sess_bp==-1 or sess_bp<data.min then
                sess_bp=data.min
                sess_g=shortguild(id)
            end

            if sess_bb==-1 or sess_bb>data.min then
                sess_bb=data.min
                sess_gb=shortguild(id)
            end
        end
    end

    if  next(gsse.data.itemData[itmIndex].history)~=nil then
        if gsse.data.tooltips.history then -- show history
            table.insert(tt_text,gsse.lang.gui.tt_histtlt)
        end

        for id,data in pairs(gsse.data.itemData[itmIndex].history) do
            if gsse.data.tooltips.history then -- show history
                table.insert(tt_text,string.format(gsse.lang.gui.tt_line,shortguild(id),numfmt(data.min),numfmt(data.max),numfmt(data.avg),numfmt(data.min*((100-gsse.data.undercutPerc)/100))))
            end

            if hist_bp==-1 or hist_bp<data.min then
                hist_bp=data.min
                hist_g=shortguild(id)
            end

            if hist_bb==-1 or hist_bb>data.min then
                hist_bb=data.min
                hist_gb=shortguild(id)
            end
        end
    end

    if gsse.data.tooltips.recommend then -- show recommendations
        if (gsse.data.tooltips.history and hist_bp>-1) or (gsse.data.tooltips.session and sess_bp>-1) then
            table.insert(tt_text,"-")
        end

        local qty=1
        local qty_lbl=gsse.lang.gui.tt_eachshort

        if (itemData.stackCount~=nil and itemData.stackCount>1) then
            qty=itemData.stackCount
            qty_lbl=""..itemData.stackCount
        end

        if sess_bp>-1 then
            table.insert(tt_text,string.format(gsse.lang.gui.tt_Sell,sess_g,numfmt(sess_bp*((100-gsse.data.undercutPerc)/100)*qty),qty_lbl,gsse.lang.gui.tt_sessshort))
        else
            table.insert(tt_text,string.format(gsse.lang.gui.tt_Sell,hist_g,numfmt(hist_bp*((100-gsse.data.undercutPerc)/100)*qty),qty_lbl,gsse.lang.gui.tt_histshort))
        end

        if sess_bb>-1 then
            table.insert(tt_text,string.format(gsse.lang.gui.tt_Buy,sess_gb,numfmt(sess_bb*qty),qty_lbl,gsse.lang.gui.tt_sessshort))
        else
            table.insert(tt_text,string.format(gsse.lang.gui.tt_Buy,hist_gb,numfmt(hist_bb*qty),qty_lbl,gsse.lang.gui.tt_histshort))
        end
    end

    if (gsse.data.tooltips.history and hist_bp>-1) or (gsse.data.tooltips.session and sess_bp>-1) then
        --- key needed
        table.insert(tt_text,"-")
        table.insert(tt_text,gsse.lang.gui.tt_key)
    end

    return tt_text
end

---------------------------------------- Event Handling ----------------------------------------------

SLASH_COMMANDS["/gsse"] = gsse.Command

EVENT_MANAGER:RegisterForEvent("GuildStoreSearchEx", EVENT_ADD_ON_LOADED, gsse.Initialize)
EVENT_MANAGER:RegisterForEvent("GuildStoreSearchEx", EVENT_SCREEN_RESIZED, function(...) 
  PopupTooltip:SetHidden(true);
  PopupTooltip:ClearLines();
    PopupTooltipIcon:SetHidden(true)
  end)
EVENT_MANAGER:RegisterForEvent("GuildStoreSearchEx", EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, gsse.ResultsReceived)
EVENT_MANAGER:RegisterForEvent("GuildStoreSearchEx", EVENT_TRADING_HOUSE_STATUS_RECEIVED, gsse.StatusReceived)
EVENT_MANAGER:RegisterForEvent("GuildStoreSearchEx", EVENT_CLOSE_TRADING_HOUSE, gsse.GuildStoreClosed)

ld_tooltip.additemtooltip("gsse_main","|cFFF000Guild Store Search Extended", gsse.SetTooltip)
