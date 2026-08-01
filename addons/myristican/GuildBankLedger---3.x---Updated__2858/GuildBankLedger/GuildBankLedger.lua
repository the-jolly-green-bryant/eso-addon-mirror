local LAM2	= LibAddonMenu2
local LGH	= LibHistoire

local GuildBankLedger = {}
GuildBankLedger.name            = "GuildBankLedger"
GuildBankLedger.version         = "3.55"
GuildBankLedger.savedVarVersion = 3
GuildBankLedger.default = {
      enable_guild  = { false, false, false, false, false }
    , history = {}
    , timeframe_days = 10
	, lastReceivedEventID = {}
	, enable_alldata = true
}
GuildBankLedger.max_guild_ct = 5
GuildBankLedger.fetching = { false, false, false, false, false }


                        -- fetched_str_list[guild_index] = { list of event strings }
                        -- loaded from the current "Save Now" run.
--GuildBankLedger.fetched_str_list = {}
GuildBankLedger.guild_name = {} -- guild_name[guild_index] = "My Aweseome Guild"

                        -- retry_ct[guild_index] = how many retries after
                        -- distrusting "nah, no more history"
-- GuildBankLedger.retry_ct   = { 0, 0, 0, 0, 0 }
-- GuildBankLedger.max_retry_ct = 3
-- GuildBankLedger.MIN_DELAY_MS = 500

GuildBankLedger.ET_DEPOSIT_GOLD  = "dep_gold"
GuildBankLedger.ET_DEPOSIT_ITEM  = "dep_item"
GuildBankLedger.ET_WITHDRAW_GOLD = "wd_gold"
GuildBankLedger.ET_WITHDRAW_ITEM = "wd_item"

-- Init ----------------------------------------------------------------------

function GuildBankLedger.OnAddOnLoaded(event, addonName)
    if addonName ~= GuildBankLedger.name then return end
	if not GuildBankLedger.version then return end
    if not GuildBankLedger.default then return end
    GuildBankLedger:Initialize()
end

function GuildBankLedger:Initialize()

	for i = 1, GetNumGuilds() do
		local guildID                                 = GetGuildId(i)
		local guildName                               = GetGuildName(guildID)
		GuildBankLedger.default["lastReceivedEventID"][guildID] = "0"
		GuildBankLedger.default["history"][guildName] = {}
	end
    self.savedVariables = ZO_SavedVars:NewAccountWide(
                              "GuildBankLedgerVars"
                            , self.savedVarVersion
                            , nil
                            , self.default
                            )
    self:CreateSettingsWindow()
	self.LibHistoireListener = {}
	GuildBankLedger:libhistoire()
	--[[LGH:RegisterCallback(LibHistoire.callback.INITIALIZED, function()
	GuildBankLedger:libhistoire()
	d("Listeners Started")
	end)
	]]--
	
	--[[
	SLASH_COMMANDS["/gbl"] = function(keyWord, argument)
		if(string.lower(keyWord) == "help") then
			GuildBankLedger:HelpSlash()
		elseif(keyWord == "") then
			GuildBankLedger:SaveNow()
		else return end
    --EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
	end
	]]--
	GuildBankLedger.OnPanelControlsCreated(panel)
end

function GuildBankLedger:libhistoire()
	for i = 1, GetNumGuilds() do
		local guildID 		= GetGuildId(i)
		local guild_index 	= i
			if self.savedVariables.enable_guild[guild_index] then
				GuildBankLedger:SetupListener(guildID)
			else
				local guildName   	= GetGuildName(guildID)
				GuildBankLedger:SkipGuildIndex(guildName)
			end
	end
end


-- UI ------------------------------------------------------------------------

function GuildBankLedger.ref_cb(guild_index)
    return "GuildBankLedger_cbg" .. guild_index
end

function GuildBankLedger.ref_desc(guild_index)
    return "GuildBankLedger_desc" .. guild_index
end

function GuildBankLedger:CreateSettingsWindow()
    local panelData = {
        type                = "panel",
        name                = "Guild Bank Ledger",
        displayName         = "Guild Bank Ledger",
        author              = "Myristican, Original by ziggr",
        version             = self.version,
        registerForRefresh  = true,
        registerForDefaults = false,
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel( self.name
                                                     , panelData
                                                     )
    local optionsData = {
        { type 		= "button"
		, name		= "Export Data"
		, tooltip   = "Export Data to csv friendly format"
        , func      = function() self:Export() end
        },
		{ type      = "button"
        , name      = "Refresh Data Now"
        , tooltip   = "Refresh all Data and Collect any newly enabled data."
        , func      = function() self:ForceSaveNow() end
        },
        { type      = "header"
        , name      = "Guilds"
        },
    }
	
    for guild_index = 1, self.max_guild_ct do
        table.insert(optionsData,
            { type      = "checkbox"
            , name      = "(guild " .. guild_index .. ")"
            , tooltip   = "Save data for guild " .. guild_index .. " ?"
            , getFunc   = function()
                            return self.savedVariables.enable_guild[guild_index]
                          end
            , setFunc   = function(e)
                            self.savedVariables.enable_guild[guild_index] = e
                          end
            , reference = self.ref_cb(guild_index)
            })
                        -- HACK: for some reason, I cannot get "description"
                        -- items to dynamically update their text. Color and
                        -- hidden, yes, but text? Nope, it never changes. So
                        -- instead of a desc for static text, I'm going to use
                        -- a "checkbox" with the on/off field hidden. Total
                        -- hack. Sorry.
        table.insert(optionsData,
            { type      = "checkbox"
            , name      = "(desc " .. guild_index .. ")"
            , reference = self.ref_desc(guild_index)
            , getFunc   = function() return false end
            , setFunc   = function() end
            })
    end

                        -- Gold only/All bank history Options
    table.insert(optionsData,
        { type    = "header"
        , name    = "Turn All History ON or OFF for Gold Only"
        })
    table.insert(optionsData,
        { type    = "checkbox"
        , name    = "All History"

        , tooltip = "ON for all Bank History to be saved"
        , getFunc = function()
                      return self.savedVariables.enable_alldata
                    end
        , setFunc = function(e)
                      self.savedVariables.enable_alldata = e
                    end
        })
	
-- To set timeframe for export	
    table.insert(optionsData,
        { type    = "header"
        , name    = "Export Timeframe"
        })
    table.insert(optionsData,
        { type    = "slider"
        , name    = "Data Export Timeframe in days"

        , tooltip = "Set Amount of days of history you want to export."
        , min     =  1
        , max     = 90
        , step    =  1
        , getFunc = function()
                      return self.savedVariables.timeframe_days
                    end
        , setFunc = function(e)
                      self.savedVariables.timeframe_days = e
                    end
        })

    LAM2:RegisterOptionControls("GuildBankLedger", optionsData)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated"
            , self.OnPanelControlsCreated)
end

-- Delay initialization of options panel: don't waste time fetching
-- guild names until a human actually opens our panel.
function GuildBankLedger.OnPanelControlsCreated(panel)
    self = GuildBankLedger
    local guild_ct = GetNumGuilds()
    for guild_index = 1,self.max_guild_ct do
        exists = guild_index <= guild_ct
        self:InitGuildSettings(guild_index, exists)
        self:InitGuildControls(guild_index, exists)
    end
end

-- Data portion of init UI
function GuildBankLedger:InitGuildSettings(guild_index, exists)
    if exists then
        local guildId   = GetGuildId(guild_index)
        local guildName = GetGuildName(guildId)
        self.guild_name[guild_index] = guildName
    else
        self.savedVariables.enable_guild[guild_index] = false
    end
end

-- UI portion of init UI
function GuildBankLedger:InitGuildControls(guild_index, exists)
    local cb = _G[self.ref_cb(guild_index)]
    if exists and cb and cb.label then
        cb.label:SetText(self.guild_name[guild_index])
    end
    if cb then
        cb:SetHidden(not exists)
    end

    local desc = _G[self.ref_desc(guild_index)]
    self.ConvertCheckboxToText(desc)
    -- self:SetStatusNewestSaved(guild_index)
end

-- Coerce a checkbox to act like a text label.
--
-- I cannot get LibAddonMenu-2.0 "description" items to dynamically update
-- their text. SetText() has no effect. But SetText() works on "checkbox"
-- items, so beat those into a text-like UI element.
function GuildBankLedger.ConvertCheckboxToText(desc)
    if not desc then return end
    desc:SetHandler("OnMouseEnter", nil)
    desc:SetHandler("OnMouseExit",  nil)
    desc:SetHandler("OnMouseUp",    nil)
    desc.label:SetFont("ZoFontGame")
    desc.label:SetText("-")
    desc.checkbox:SetHidden(true)
end

function GuildBankLedger:Export()
	d("GuildBankLedger: Exporting Data...")
	for i = 1, GetNumGuilds() do
			local guildID 		= GetGuildId(i)
			local guild_index 	= i
			local guildName = GetGuildName(guildID)
			local now_ts   = GetTimeStamp()
			local days_in_secs = self.savedVariables.timeframe_days * 86400
			local savedevents = self.savedVariables["history"][guildName]
			local enable_alldata = self.savedVariables.enable_alldata
	--GuildBankLedger:RunExport(i)
		if self.savedVariables.enable_guild[guild_index] then
			for k, v in pairs(savedevents) do
				local ago_secs = GetDiffBetweenTimeStamps(now_ts, v.timestamp)
				--	d(ago_secs)
				if ago_secs <= days_in_secs then
					GBLData:ExportEvent(guildID, v, guildName, enable_alldata)  
				end			
			end
		GBLData:WriteEvent(guildName)
		else
			GuildBankLedger:SkipGuildIndex(guildName)
		end
	end
	d("GuildBankLedger: Export Complete")
	d("GuildBankLedger: /reloadui, Log out or Quit to write file.")
end

function GuildBankLedger:RunExport(i)
		local guildID 		= GetGuildId(i)
		local guild_index 	= i
		local guildName = GetGuildName(guildID)
		local now_ts   = GetTimeStamp()
		local days_in_secs = self.savedVariables.timeframe_days * 86400
		local savedevents = self.savedVariables["history"][guildName]
		local enable_alldata = self.savedVariables.enable_alldata
	if self.savedVariables.enable_guild[guild_index] then
		for k, v in pairs(savedevents) do
				--	local ago_secs = GetDiffBetweenTimeStamps(now_ts, v.timestamp)
				--	d(ago_secs)
				--	if ago_secs <= days_in_secs then
			GBLData:ExportEvent(guildID, v, guildName, enable_alldata)  
				--	end
		break 
		end	
	else
		GuildBankLedger:SkipGuildIndex(guildName)
	end
end

-- Display Status ------------------------------------------------------------

-- Update the per-guild text label with what's going on with that guild data.
function GuildBankLedger:SetStatus(guild_index, msg)
    --d("status " .. tostring(guild_index) .. ":" .. tostring(msg))
    local x = _G[self.ref_desc(guild_index)]
    if not x then return end
    desc = x.label
    desc:SetText("  " .. msg)
end

-- Set status to "Newest: @user 100,000g  11 hours ago"
function GuildBankLedger:SetStatusNewestSaved(guild_index)
    local event = self:SavedHistoryNewest(guild_index)
    self:SetStatusNewest(guild_index, event)
end

function GuildBankLedger:SetStatusNewestFetched(guild_index)
    local event = self:FetchedNewest(guild_index)
    self:SetStatusNewest(guild_index, event)
end

function GuildBankLedger:SetStatusNewest(guild_index, event)
    if not event then return end

    local now_ts   = GetTimeStamp()
    local ago_secs = GetDiffBetweenTimeStamps(now_ts, event.time)
    local ago_str  = FormatTimeSeconds(ago_secs
                    , TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE -- "22 hours"
                    , TIME_FORMAT_PRECISION_SECONDS
                    , TIME_FORMAT_DIRECTION_DESCENDING
                    )

    self:SetStatus(guild_index, "Newest: " .. event.user
                     .. " " .. ago_str .. " ago")
end

-- Return the one newest event, if any, from our previous save.
-- Return nil if not.
function GuildBankLedger:SavedHistoryNewest(guild_index)
    local guildName = GetGuildName(guildId)
    if not self.savedVariables then return nil end
    if not self.savedVariables.history then return nil end
    return self:Newest(self.savedVariables.history[guildName])
end

-- Return the Event of the most recent event string from
-- a list of event strings.
function GuildBankLedger:Newest(str_list)
    if not str_list then return nil end
    if not (1 <= #str_list) then return nil end
    local newest_event = GuildBankLedger:FromString(str_list[1])
    for _,line in ipairs(str_list) do
        local e = GuildBankLedger:FromString(line)
        if e then
            if (not newest_event) or newest_event.time < e.time then
                newest_event = e
            end
        end
    end
    return newest_event
end

--  GuildHistory Listener and Events  -------------------------------------------------------------------------------------
function GuildBankLedger:SetupListener(guildID)
--LGH:RegisterCallback(LibHistoire.callback.INITIALIZED, function()
  -- listener
  d("Starting SetupListenerFunction " .. guildID)
  GuildBankLedger.LibHistoireListener[guildID] = LGH:CreateGuildHistoryListener(guildID, GUILD_HISTORY_BANK)
  local lastReceivedEventID
  if GuildBankLedger.savedVariables["lastReceivedEventID"][guildID] then
    lastReceivedEventID = StringToId64(GuildBankLedger.savedVariables["lastReceivedEventID"][guildID])
    --MasterMerchant.dm("Info", string.format("lastReceivedEventID set to: %s", lastReceivedEventID))
    GuildBankLedger.LibHistoireListener[guildID]:SetAfterEventId(lastReceivedEventID)
  end
  
	GuildBankLedger.LibHistoireListener[guildID]:SetEventCallback(function(eventType, eventId, eventTime, p1, p2, p3, p4, p5, p6)

		if eventType == GUILD_EVENT_BANKGOLD_ADDED then
		  if not lastReceivedEventID or CompareId64s(eventId, lastReceivedEventID) > 0 then
			GuildBankLedger.savedVariables["lastReceivedEventID"][guildID] = Id64ToString(eventId)
			lastReceivedEventID                                                 = eventId
		  end
		  local guildName   	= GetGuildName(guildID)
		  local theEvent    	= {
				user     		= p1,
				trans_type		= GuildBankLedger.ET_DEPOSIT_GOLD,
				gold_ct  		= p2,
				timestamp 		= eventTime,
				id        		= Id64ToString(eventId)
			}
		
		local isNotDuplicate = GuildBankLedger:isNotDuplicate(theEvent.id, guildID)
		if isNotDuplicate then
			GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end
			
		--GuildBankLedger:SaveNow(theEvent) 
		--	GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end
		
		if eventType == GUILD_EVENT_BANKGOLD_REMOVED then
		  if not lastReceivedEventID or CompareId64s(eventId, lastReceivedEventID) > 0 then
			GuildBankLedger.savedVariables["lastReceivedEventID"][guildID] = Id64ToString(eventId)
			lastReceivedEventID                                                 = eventId
		  end
		  local guildName   	= GetGuildName(guildID)
		  local theEvent    	= {
				user     		= p1,
				trans_type		= GuildBankLedger.ET_WITHDRAW_GOLD,
				gold_ct  		= p2,
				timestamp 		= eventTime,
				id        		= Id64ToString(eventId)
			}

		local isNotDuplicate = GuildBankLedger:isNotDuplicate(theEvent.id, guildID)
		if isNotDuplicate then
			GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end

		--GuildBankLedger:SaveNow(theEvent)
		--	GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end
	
		if eventType == GUILD_EVENT_BANKITEM_ADDED then
		  if not lastReceivedEventID or CompareId64s(eventId, lastReceivedEventID) > 0 then
			GuildBankLedger.savedVariables["lastReceivedEventID"][guildID] = Id64ToString(eventId)
			lastReceivedEventID                                                 = eventId
		  end
		  local guildName   	= GetGuildName(guildID)
		  local theEvent    	= {
				user     		= p1,
				trans_type		= GuildBankLedger.ET_DEPOSIT_ITEM,
				item_ct  		= p2,
				item_link     	= p3,
				timestamp 		= eventTime,
			--	item_mm     	= GuildBankLedger:MMPrice(p3),
				item_name    	= GetItemLinkName(p3),
				id        		= Id64ToString(eventId)
			}

		local isNotDuplicate = GuildBankLedger:isNotDuplicate(theEvent.id, guildID)
		if isNotDuplicate then
			GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end

		--GuildBankLedger:SaveNow(theEvent)
		--	GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end
			
		if eventType == GUILD_EVENT_BANKITEM_REMOVED then
		  if not lastReceivedEventID or CompareId64s(eventId, lastReceivedEventID) > 0 then
			GuildBankLedger.savedVariables["lastReceivedEventID"][guildID] = Id64ToString(eventId)
			lastReceivedEventID                                                 = eventId
		  end
		  local guildName   	= GetGuildName(guildID)
		  local theEvent    	= {
				user     		= p1,
				trans_type		= GuildBankLedger.ET_WITHDRAW_ITEM,
				item_ct  		= p2,
				item_link     	= p3,
				timestamp 		= eventTime,
			--	item_mm     	= GuildBankLedger:MMPrice(p3),
				item_name    	= GetItemLinkName(p3),
				id        		= Id64ToString(eventId)
			}

		local isNotDuplicate = GuildBankLedger:isNotDuplicate(theEvent.id, guildID)
		if isNotDuplicate then
			GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end

		--GuildBankLedger:SaveNow(theEvent)
		--	GuildBankLedger:SaveGuildIndex(guildID, theEvent)
		end
	end)
	GuildBankLedger.LibHistoireListener[guildID]:Start()
	local guildName = GetGuildName(guildID)
	GuildBankLedger.ListenerDebugText(guildName)
end 

function GuildBankLedger:isNotDuplicate(eventId, guildID)
local dupe   = true
	local guildName = GetGuildName(guildID)
	local savedevents = self.savedVariables["history"][guildName]
	for k, v in pairs(savedevents) do
		if v.id == eventId then
		dupe = false
		break
		end
	end
	return dupe
end


function GuildBankLedger.ListenerDebugText(guildName)
	d(guildName .. " GBL: Listener Started")
end


--end

function GuildBankLedger:MMPrice(item_link)
    if not MasterMerchant then return nil end
    if not item_link then return nil end
    mm = MasterMerchant:itemStats(item_link, false)
    if not mm then return nil end
    return mm.avgPrice
end

function GuildBankLedger:ForceSaveNow()
	d("Starting Refresh for Enabled Guilds")
  numGuilds = GetNumGuilds()
  for i = 1, numGuilds do
	local guildID = GetGuildId(i)
	local guild_index = i
		if GuildBankLedger.savedVariables.enable_guild[guild_index] and GuildBankLedger.savedVariables["lastReceivedEventID"][guildID] ~= "0" then
				GuildBankLedger.LibHistoireListener[guildID]:Stop()
				GuildBankLedger.LibHistoireListener[guildID]  = nil
		end
  end
  for i = 1, numGuilds do
    local guildID	= GetGuildId(i)
	local guild_index = i
		if GuildBankLedger.savedVariables.enable_guild[guild_index] then
			GuildBankLedger.savedVariables["lastReceivedEventID"][guildID] = "0"
			GuildBankLedger:SetupListener(guildID)
		end
  end
	d("Refresh Completed")
 end


function GuildBankLedger:SaveNow(theEvent)
        if self.savedVariables.enable_guild[guild_index] then
            self:SaveGuildIndex(guildID, theEvent)
        else
            self:SkipGuildIndex(guildID)
        end
    end

-- User doesn't want this guild. Respond with "okay, skipping"
function GuildBankLedger:SkipGuildIndex(guildName)
  --  self:SetStatus(guildID, "skipped")
--	local guildName = GetGuildName(guildID)
	d(guildName .. " Skipped")
end

-- Write to file for included guilds
function GuildBankLedger:SaveGuildIndex(guildID, theEvent)
	--	d("Saving History...")
	local guild_name = GetGuildName(guildID)		
--		self.savedVariables.history[guild_name] = self.fetched_str_list[guildID]
		self:RecordEvent(guildID, theEvent, guild_name)
	--	d(self.name .. ": /reloadui, Log out or Quit to write file.")
    end  

function GuildBankLedger:RecordEvent(guildID, theEvent, guild_name)
    if not GuildBankLedger.savedVariables["history"][guild_name] then
        GuildBankLedger.savedVariables["history"][guild_Name] = {}
		end
    local t = GuildBankLedger.savedVariables["history"][guild_Name]
	-- if self.savedVariables.enable_alldata then
		table.insert(GuildBankLedger.savedVariables["history"][guild_name], theEvent)
	-- else
	--	table.insert(t, theEvent)
	-- end
	end
	
-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( GuildBankLedger.name 
								, EVENT_ADD_ON_LOADED
								, GuildBankLedger.OnAddOnLoaded
								)
								