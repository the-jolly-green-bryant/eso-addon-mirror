AzuraGuildMessages = {}

local AGM = AzuraGuildMessages
local em = GetEventManager()
AzuraGuildMessagesKeybind = {}

AGM.name = "AzuraGuildMessages"
AGM.defaults = {
  infocooldown = 30,
  cooldown = 0,
  messagenum = 1,
  infocolour = "c82fa58",
  debugcolour = "cfa7057",
  othercolour = "c57a9fa",
  InfoMessages = {
    {"Дети Азуры! Помните, Discord - обязательное условие нахождения в гильдии! И чтобы события Азуры не пролетали мимо вас, подобно неуловимым ветрам, переходите по ссылке discord.gg/KPkKhJTEkH и присоединяйтесь! Именно здесь к вашим услугам мероприятия, творчество, рейды, крафт, помощь и, конечно, общение!", nil},
    {"Ты уже в Discord, но выглядит он чересчур скромно? Оставь сообщение в канале #хочу-к-вам и получи роль c полным доступом на сервер. Мероприятия, творчество, рейды, крафт, помощь и, конечно же, общение ждут тебя!", nil},
    {"У нас есть уютный гильд-холл со всеми крафтовыми станками, камнями Мундуса и манекенами. Чтобы попасть в гильд-холл --> клавиша G --> список игроков --> отобразить игроков оффлайн --> сортировать по званиям --> ПКМ по ID @Azura’s.Kingdom --> Посетить дом.", nil},
    --{"Дети Азуры! Гильдейский Банк открыт для каждого из вас. Вы можете брать из него всё, что необходимо вам для развития персонажа - ремесленные мотивы, рецепты, чертежи, схемы, вещи и руны для разбора для прокачки ремесел, мастерские крафтовые заказы, наживку для рыбалки и другие полезные вещи.", nil},
    {"Азура ищет Рейд- и Пати-лидеров, способных взять под своё крыло отряды смельчаков для покорения триалов и данжей! Если ты знаешь механики и хочешь  поделиться своими знаниями, мы ждём тебя! Если же ты не до конца уверен в своих умениях, но хотел бы попробовать себя в этой роли, то мы всё равно ждём тебя! За подробностями на канал #о-гильдии.", nil},
    {"Дети Азуры, у нас в гильдии можно заказать бесплатный крафт белых вещей и сетов от 4 до 140 ЧП, Заказ будет создан за счет гильдии. Ваши материалы или их эквивалент в золоте понадобится для улучшения вещей (от зеленого до золотого качества). Не стесняйтесь обращаться к крафтерам за помощью, мы всегда рады помочь! Подробности - #заказ-крафта.", nil},
    {"Тебе нравится в колыбели Азуры? Тебя согревает её свет и обволакивает уют? Тебе в радость разделять с её Детьми комфорт, удобство и приятную атмосферу нашего сообщества? Узнай, как не попасть под чистку и сохранить всё это без труда и особых временных затрат! Посети канал #о-гильдии нашего дискорд-сервера, и пусть истина откроется тебе!", nil},
    {"Дитя Азуры! Ремесленные чертоги Садов Лунной тени ждут мастеров! Если ты изучил все или многие особенности и стили, если материалы горят в твоих руках и ты готов поделиться с Азурчатами плодами твоих умений, то мы приглашаем тебя присоединиться к команде крафтеров Азуры! Подробности - в дискорд-канале #о-гильдии.", nil}
    --,{"Временное сообщение.", os.time{year=2022, month=6, day=5, hour=1}}
  }

}

AGM.settings = {}

function AzuraGuildMessages:Initialize()
  AGM.settings = ZO_SavedVars:NewAccountWide("AzuraGuildMessagesSavedVariables", 1, nil, AGM.defaults)
  d("[AGM]Initialize happened...")

  --AGM.settings.InfoMessages[2] = {"Ты уже в Discord, но выглядит он чересчур скромно? Оставь сообщение в канале #хочу-к-вам и получи роль c полным доступом на сервер. Мероприятия, творчество, рейды, крафт, помощь и, конечно же, общение ждут тебя!", nil}
  --AGM.settings.InfoMessages[5] = {"Азура ищет Рейд- и Пати-лидеров, способных взять под своё крыло отряды смельчаков для покорения триалов и данжей! Если ты знаешь механики и хочешь  поделиться своими знаниями, мы ждём тебя! Если же ты не до конца уверен в своих умениях, но хотел бы попробовать себя в этой роли, то мы всё равно ждём тебя! За подробностями на канал #отдел_кадров", nil}
  --AGM.settings.InfoMessages[9] = nil
  --AGM.settings.InfoMessages[10] = nil
  --AGM.settings.InfoMessages[11] = nil

--full cleanup
---[[   
  local i
  for i=1, #AGM.settings.InfoMessages do
    AGM.settings.InfoMessages[i] = nil
  end
--]]
--defaults

  for i=1, #AGM.defaults.InfoMessages do
    AGM.settings.InfoMessages[i] = AGM.defaults.InfoMessages[i]
  end

  d("[AGM] Test initialize")
  EVENT_MANAGER:UnregisterForEvent(AzuraGuildMessages.name, EVENT_ADD_ON_LOADED)

end

function AzuraGuildMessages.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == AzuraGuildMessages.name then
    AzuraGuildMessages:Initialize()
  end
  d("[AGM] Test on addon loaded")
end

ZO_CreateStringId("SI_BINDING_NAME_AZURA_GUILD_MESSAGES_PASTE", "Paste Info")

function AGMKeybind_pasteText()
  if AGM.settings.messagenum ~= nil and AGM.settings.InfoMessages[AGM.settings.messagenum] ~= nil and AGM.settings.InfoMessages[AGM.settings.messagenum][1] ~= nil then
    if AGM.settings.cooldown < GetTimeStamp() then 
      if AzuraGuildMessages.InfoMessageCheck(AGM.settings.messagenum) then
        d("|" .. AGM.settings.infocolour .. "[AGM] Info message " .. AGM.settings.messagenum .. " pasted to the chat.")
        ZO_ChatWindowTextEntryEditBox:SetText("/o1 " .. AGM.settings.InfoMessages[AGM.settings.messagenum][1])
        AGM.settings.cooldown = GetTimeStamp() + (AGM.settings.infocooldown*60)
--      AGM.settings.cooldown = GetTimeStamp() + (30*60)
        AGM.settings.messagenum = AGM.settings.messagenum + 1
      end 
    else 
      d("|" .. AGM.settings.infocolour .. "[AGM] You can't until " .. os.date("%H:%M:%S", AGM.settings.cooldown) .. " (next message number " .. AGM.settings.messagenum .. ").")
    end
    if AGM.settings.messagenum > #AGM.settings.InfoMessages then AGM.settings.messagenum = 1 end
  else
    if AGM.settings.messagenum > #AGM.settings.InfoMessages then AGM.settings.messagenum = 1 
    else 
      d("[AGM] Settings error.") 
    end
  end
end

function AzuraGuildMessages.InfoMessageCheck(num)
  local i
  local result = false
  if AGM.settings.InfoMessages[num] ~= nil then
    if AGM.settings.InfoMessages[num][2] ~= nil then
      if AGM.settings.InfoMessages[num][2] < GetTimeStamp() then
        d("[AGM] Message " .. num .. " was valid till " .. os.date("%d.%m.%y %H:%M", AGM.settings.InfoMessages[num][2]))
        d("[AGM] Message " .. num .. " removed.")
        for i=num, #AGM.settings.InfoMessages do
          AGM.settings.InfoMessages[i] = AGM.settings.InfoMessages[i+1]
        end
        if num == AGM.settings.messagenum then
          d("|" .. AGM.settings.infocolour .. "[AGM] Next message number " .. num .. " (former " .. num+1 ..").")
        end
      else
        d("|" .. AGM.settings.debugcolour .. "[AGM] Message " .. num .. " ok.")
        result = true
      end
    else
      d("|" .. AGM.settings.debugcolour .. "[AGM] Message " .. num .. " ok.")
      result = true
    end
  else 
    d("[AGM] Invalid message number (" .. num .. ").")
  end
  return result
end


function AzuraGuildMessages.wtfcheck() 
  d("|" .. AGM.settings.debugcolour .. "#AGM.settings.InfoMessages == " .. tostring(#AGM.settings.InfoMessages)) 
  --AzuraGuildMessages.InfoMessageCheck(12)
  local i
  for i=1, #AGM.settings.InfoMessages do
    d("|" .. AGM.settings.othercolour .. "[AGM] Message " .. i .. ": " .. AGM.settings.InfoMessages[i][1])
  end
  d("|" .. AGM.settings.infocolour .. "[AGM] Cooldown until " .. os.date("%H:%M:%S", AGM.settings.cooldown) .. " (next message number " .. AGM.settings.messagenum .. ").")

end

function AzuraGuildMessages.droptimer()
  AGM.settings.cooldown = GetTimeStamp()
  d("|" .. AGM.settings.infocolour .. "[AGM] Timer dropped.")
end

function AzuraGuildMessages.back()
  AGM.settings.messagenum = AGM.settings.messagenum - 1
  if AGM.settings.messagenum == 0 then AGM.settings.messagenum = #AGM.settings.InfoMessages end
  d("|" .. AGM.settings.infocolour .. "[AGM] Next message number " .. AGM.settings.messagenum .. ".")
end

SLASH_COMMANDS["/agmwtf"] = AzuraGuildMessages.wtfcheck
SLASH_COMMANDS["/agmdt"] = AzuraGuildMessages.droptimer
SLASH_COMMANDS["/agmdroptimer"] = AzuraGuildMessages.droptimer
SLASH_COMMANDS["/agmback"] = AzuraGuildMessages.back


-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(AzuraGuildMessages.name, EVENT_ADD_ON_LOADED, AzuraGuildMessages.OnAddOnLoaded)
