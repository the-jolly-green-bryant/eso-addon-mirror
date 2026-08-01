local AGS = AwesomeGuildStore

local SAFETY_MARGIN = 10 -- seconds

local logger = AGS.internal.logger
local Promise = LibPromises

local GuildHistoryHelper = ZO_InitializingObject:Subclass()
AGS.class.GuildHistoryHelper = GuildHistoryHelper

function GuildHistoryHelper:Initialize(saveData)
    self.playerName = UndecorateDisplayName(GetDisplayName())
    self.matchedEvents = {}

    for _, data in pairs(saveData.mailAugmentationData) do
        self.matchedEvents[data.eventId] = true
    end
end

function GuildHistoryHelper:FindEventData(mailId, mailTime, attachedMoney)
    return self:CollectEvents(mailTime):Then(function(events)
        return self:TryMatchPendingMails(events, mailId, mailTime, attachedMoney)
    end)
end

function GuildHistoryHelper:CollectEvents(mailTime)
    local promise = Promise:New()
    local events = {}

    local function CollectEvent(event)
        local info = event:GetEventInfo()
        local eventType = info.eventType
        local guildId = event:GetGuildId()
        if eventType == GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD and info.sellerDisplayName == self.playerName then
            events[#events + 1] = {
                guildId = guildId,
                eventId = info.eventId,
                eventTime = info.timestampS,
                buyerName = info.buyerDisplayName,
                itemLink = info.itemLink,
                quantity = info.quantity,
                price = info.price,
                tax = info.tax,
            }
        end
    end

    LibHistoire:OnReady(function(lib)
        local numRunning = 0
        for i = 1, GetNumGuilds() do
            local guildId = GetGuildId(i)
            if DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE) then
                local processor = lib:CreateGuildHistoryProcessor(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER,
                    "AwesomeGuildStore")
                local started = processor:StartIteratingTimeRange(mailTime - SAFETY_MARGIN, mailTime + SAFETY_MARGIN + 1,
                    CollectEvent, function()
                        numRunning = numRunning - 1
                        if numRunning == 0 then
                            promise:Resolve(events)
                        end
                    end)
                if started then
                    numRunning = numRunning + 1
                else
                    logger:Warn("Events are not being collected for guildId", guildId)
                end
            end
        end

        if numRunning == 0 then
            promise:Reject("No processors started")
        end
    end)

    return promise
end

local function byTimeDiffAsc(a, b)
    return a.timeDiff < b.timeDiff
end

function GuildHistoryHelper:TryMatchPendingMails(events, mailId, mailTime, attachedMoney)
    local promise = Promise:New()

    local sales = {}
    local matchedEvents = self.matchedEvents
    for i = 1, #events do
        local sale = events[i]
        if not matchedEvents[sale.eventId] then
            sale.timeDiff = math.abs(sale.eventTime - mailTime)
            sale.listingFee, sale.houseCut, sale.profit = GetTradingHousePostPriceInfo(sale.price)
            if attachedMoney == 0 or attachedMoney == sale.profit + sale.listingFee then
                sales[#sales + 1] = sale
            end
        end
    end

    if #sales > 0 then
        table.sort(sales, byTimeDiffAsc)
        local bestMatch = sales[1]
        bestMatch.guildName = GetGuildName(bestMatch.guildId)
        matchedEvents[bestMatch.eventId] = true
        promise:Resolve(bestMatch)
    else
        promise:Reject("No matching event found")
    end

    return promise
end
