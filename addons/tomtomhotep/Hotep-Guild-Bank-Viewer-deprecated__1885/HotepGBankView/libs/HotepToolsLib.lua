
local lib = LibStub:NewLibrary("HotepToolsLib", 19)

if not lib then
  return    -- already loaded and no upgrade necessary
end



lib.name = "HotepToolsLib"
lib.ver = 1
lib.ns = "HotepToolsLibSVns"

lib.def = {
  MailToDelete = {},
}


Hotep_Tools_Lib = lib


local COLOR_HOTEP = "|c3366ff"
local COLOR_MSG = "|cff6633"
local COLOR_RED = "|cff0000"


local function msgWithName(msg, color, name)
  if (type(color) == "nil") then color = COLOR_MSG end
  if (type(name) == "nil") then name = "Hotep" end
  local barr = "|r"
  if (not color) then
    barr = ""
    color = ""
  end
  
  d(zo_strformat("[<<1>><<2>>|r] <<3>><<4>><<5>>", COLOR_HOTEP, name, color, msg, barr))
end





local function clone(t, c)
  if (type(t) ~= "table") then return t end
  if (type(c) == "nil") then c = {} end
  if (type(c) ~= "table") then return nil end
  
  for k,v in pairs(t) do
    if (type(v) == "table") then
      c[k] = clone(v)
    else
      c[k] = v
    end
  end
  
  return c
end


local function explode(div, str) -- credit: http://richard.warburton.it
  if (div == '') then return false end

  local pos, arr = 0, {}

  -- for each divider found
  for st, sp in function() return string.find(str, div, pos, true) end do
    table.insert(arr, string.sub(str, pos, st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end

  table.insert(arr, string.sub(str, pos)) -- Attach chars right of last divider

  return arr
end


local function in_array(ele, t, fun)
  local foo

  if (type(fun) == "function") then
    foo = fun
  else
    foo = function (elem) return elem end
  end

  for k,v in pairs(t) do
    if (foo(v) == ele) then return true end
  end

  return false
end


local function array_find(ele, t, fun)
  local foo
  
  if (type(fun) == "function") then
    foo = fun
  else
    foo = function (elem) return elem end
  end
  
  for k,v in pairs(t) do
    if (foo(v) == ele) then return k,v end
  end
  
  return nil, nil
end


local function array_key_exists(key, arr)
  return (arr[key] ~= nil)
end


local function array_without(arr, v, fun)

  local foo

  if (type(fun) == "function") then
    foo = fun
  else
    foo = function (ele) return ele end
  end

  local i = 1

  while (i <= #arr) do
    if (foo(arr[i]) == v) then
      table.remove(arr, i)
    else
      i = i + 1
    end
  end

  return arr
end

local function array_indexof(v, arr, fun)

  local foo

  if (type(fun) == "function") then
    foo = fun
  else
    foo = function (ele) return ele end
  end

  for i = 1, #arr do
    if (foo(arr[i]) == v) then
      return i
    end
  end

  return 0
end


local function array_glob(arr, n)   -- output array of tables of n elements of arr each
  
  local glob = {}
  local i = 1
  
  while (i <= #arr) do
    local k = 1
    local t = {}
    
    while ((k <= n) and (i <= #arr)) do
      table.insert(t, arr[i])
      i = i + 1
      k = k + 1
    end
    
    table.insert(glob, t)
  end
  
  return glob
end




local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end


local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k,_ in pairs(t) do table.insert(keys, k) end
    
    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if (type(order) == "function") then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    
    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


local function eyesort(t, a, b)
  return (t[a].__i < t[b].__i)
end


---
-- @param t @class table
-- @return @class table
local function array_keys(t)
  local keys = {}
  for k,_ in spairs(t) do
    table.insert(keys, k)
  end
  return keys
end

---
-- @param t1 @class table
-- @param t2 @class table
-- @return @class table
local function array_append(t1, t2)
  local t = clone(t1)
  
  for _,v in ipairs(t2) do
    table.insert(t, v)
  end
  
  return t
end

---
-- @param t @class table
-- @return @class boolean
local function empty(t)
  for _,_ in pairs(t) do
    return false
  end
  
  return true
end






local function badscene()
  local t = {"bank","guildBank","tradinghouse","interact","mailInbox","gameMenuInGame",
                "mailSend","loot","store","smithing","enchanting","alchemy","provisioner","inventory"}
  return (in_array(SCENE_MANAGER.currentScene.name, t) or IsUnitInCombat("player"))
end


local function InTheMailBox()
  return (GetInteractionType() == INTERACTION_MAIL)
end



lib.HotepCommonFuncs = {
  clone = clone,
  explode = explode,
  in_array = in_array,
  array_key_exists = array_key_exists,
  array_indexof = array_indexof,
  array_without = array_without,
  array_glob = array_glob,
  array_keys = array_keys,
  array_find = array_find,
  array_append = array_append,
  empty = empty,
  uuid = uuid,
  msgWithName = msgWithName,
  spairs = spairs,
  eyesort = eyesort,
  badscene = badscene,
}


lib.initialized = false


function lib:Init()
  
  if (lib.initialized) then return end
  
  lib.initialized = true
  
--  lib.savedVars = ZO_SavedVars:NewAccountWide("ZO_Ingame_SavedVariables", lib.ver, lib.ns, lib.def)
--  
--  lib.HotepMailReader.MailToDelete = lib.savedVars.MailToDelete
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_SUCCESS, self.OnMailEventSendSuccess)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_FAILED, self.OnMailEventSendFailed)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAT_MESSAGE_CHANNEL, self.OnChatEvent)
  
  EVENT_MANAGER:RegisterForUpdate(self.name, 250, self.OnUpdateEvent)
  
  SLASH_COMMANDS["/hotep"] = function(extra) self.shutup(); self.SlashHotep:Exec(extra) end
  
  if (not SLASH_COMMANDS["/shutup"]) then
    SLASH_COMMANDS["/shutup"] = self.shutup
  end
  
end


function lib.MailRcompat()
  if (not MailR) then return end
  
  EVENT_MANAGER:UnregisterForEvent("MailR_SetMailboxActive", EVENT_MAIL_OPEN_MAILBOX)
end

function lib.MailR()
  if (not MailR) then return end
  
  EVENT_MANAGER:RegisterForEvent("MailR_SetMailboxActive", EVENT_MAIL_OPEN_MAILBOX, MailR.SetMailboxActive)
end






lib.SlashHotep = {
  commands = {},            -- list of functions indexed by command word
  helps = {},               -- list of help functions indexed by addon name
}

local Slash = lib.SlashHotep

function Slash:Register(word, fun)
  
  if (type(word) ~= "string") then return false end
  if (word == "") then return false end
  if (array_key_exists(word, self.commands)) then return false end
  
  if (type(fun) ~= "function") then return false end
  
  self.commands[word] = fun
  
  return true
end

function Slash:RegisterHelp(addon, fun)
  
  if (type(addon) ~= "string") then return false end
  if (type(fun) ~= "function") then return false end
  
  self.helps[addon] = fun
  
  return true
end

function Slash:Exec(extra)
  
  if (next(self.commands) == nil) then return end
  
  local pieces = explode(" ", extra)
  local cmd = table.remove(pieces, 1)
  local rest = table.concat(pieces, " ")
  
  for word,fun in pairs(self.commands) do
    if (word == cmd) then
      if (fun(rest)) then return end
    end
  end
  
  for _,help in pairs(self.helps) do
    help()
  end
end





lib.HotepUtilities = {
  Timer = {},
  MailQueue = {
    q = {},
    current = {},
    cts = true,      -- clear to send
    sending = false,
    t = nil,
  },
  Iterator = {},
  ChatQueue = {
    channel = nil,
    handle = "",
    active = false,
    msgQ = {},
    callback = nil,
    failback = nil,
    timeout = 10,
  }
}


---------------------------------------------------------- Timer
--  calls a function after x minutes
---------------------------------------

local Timers = {}
local Timer = lib.HotepUtilities.Timer


function Timer:New(minutes, callback, params, deferred, once)
  local timer = {
    time = minutes * 60000,
    start = 0,
    current = 0,
    triggered = false,
    stopped = true,
    callback = callback,
    params = params,
    once = once
  }
  setmetatable(timer, { __index = Timer })
  table.insert(Timers, timer)
  
  if (not callback) then
    error(zo_strformat("Invalid callback (type <<1>>) in Timer:New()", type(callback)))
  end

  if (not deferred) then
    timer:Start()
  end

  return timer
end

setmetatable(Timer, { __call = Timer.New })


function Timer:Once(minutes, callback, params, deferred)
  return Timer(minutes, callback, params, deferred, true)
end


function Timer:Stop()
  self.stopped = true
end


function Timer:Continue()
  if ((self.triggered == false) and (self.stopped == true)) then
    local paused = (GetGameTimeMilliseconds() - self.current)
    self.start = self.start + paused
    self.stopped = false
    return paused
  end
  
  return false
end


function Timer:Start(newMinutes)
  
  if (type(newMinutes) == "number") then self.time = newMinutes * 60000 end
  
  if (not lib.initialized) then
    error("HotepToolsLib must be initialized before use by calling :Init()")
  end
  
  self.start = GetGameTimeMilliseconds()
  self.triggered = false
  self.stopped = false
end


function Timer:Update(i)
  if (self.stopped or self.triggered) then
    return false
  end
  
  if (type(i) ~= "number") then i = 0 end
  
  self.current = GetGameTimeMilliseconds()
  
  if ((self.current - self.start) > self.time) then
    self.stopped = true
    self.triggered = true
    local k = 250 + (50 * i)
    zo_callLater(function () self.callback(self.params) end, k)
    if (self.once == true) then self:Destroy() end
    return true
  end
  
  return false
end


function Timer:Destroy()
  self.stopped = true

  local i = 0

  for j,timer in pairs(Timers) do
    if ((timer.start == self.start) and (timer.time == self.time)) then
      i = j
      break
    end
  end

  if (i > 0) then
    table.remove(Timers, i)
  end
end



function lib.OnUpdateEvent()
  for i, timer in pairs(Timers) do
    timer:Update(i)
  end
end


---------------------------------------------------------- end Timer


lib.EVENT_MAILSEND_DEFERRED = 'HOTEP_MAILSEND_DEFERRED'
lib.EVENT_MAILSEND_ATTEMPTED = 'HOTEP_MAILSEND_ATTEMPTED'



---------------------------------------------------------- MailSender
-- sends one mail
-------------------

local MailSender = {}
local MailOut = {
  active = false
}

function MailSender:New(to, subject, body, callback, failback)
  local mailout = {
    active = true,
    sent = false,
    callback = callback,
    failback = failback,
    to = to,
    subject = subject,
    body = body,
  }
  setmetatable(mailout, { __index = MailSender })

  return mailout
end

setmetatable(MailSender, { __call = MailSender.New })


function MailSender:foo()
  SCENE_MANAGER:Show("mailSend")
  SendMail(self.to, self.subject, self.body)
  self.sent = true
  CALLBACK_MANAGER:FireCallbacks(lib.EVENT_MAILSEND_ATTEMPTED, self.to, self.subject, self.body)
  Timer:Once(0.03, function () EndInteraction(GetInteractionType()) end)
  zo_callLater(function () SCENE_MANAGER:ShowBaseScene() end, 500)
  zo_callLater(lib.MailR, 600)
end

function MailSender:Send()
  if (badscene()) then
    CALLBACK_MANAGER:FireCallbacks(lib.EVENT_MAILSEND_DEFERRED, self.to, self.subject, self.body)
    Timer:Once(0.25, function () self:Send() end)
  else
    lib.MailRcompat()
    SCENE_MANAGER:ShowBaseScene()
    zo_callLater(function () SCENE_MANAGER:Show("mailInbox") end, 500)
    zo_callLater(function () self:foo() end, 1000)
  end
end


function MailSender:Success()
  self.active = false

  if (self.callback) then
    self.callback()
  end
end


function MailSender:Failure(reason)
  self.active = false

  if (self.failback) then
    self.failback(reason)
  end
end

---------------------------------------------------------- end MailSender


---------------------------------------------------------- MailQueue
-- queues up all mail to be sent
--------------------------------

local MailQueue = lib.HotepUtilities.MailQueue



function MailQueue:Enqueue(to, subject, body, callback, failback)

  local cb = function () MailQueue:OneSuccess() end
  local fb = function (reason) MailQueue:OneFailed(reason) end

  local m = {
    callback = callback,
    failback = failback,
    mailout = MailSender(to, subject, body, cb, fb)
  }

  table.insert(self.q, m)

  if (not self.sending) then
    MailQueue:AttemptNext()
  end
end

setmetatable(MailQueue, { __call = MailQueue.Enqueue })


function MailQueue:Requeue(mailer)

  table.insert(self.q, mailer)

  if (not self.sending) then
    MailQueue:AttemptNext()
  end
end


function MailQueue:AttemptNext()

  if (#self.q == 0) then
    self.sending = false
    return
  end

  if (self.cts and not MailOut.active) then
    self.cts = false
    self.sending = true

    self.current = table.remove(self.q, 1)

    self.t = Timer(0.04, function () MailQueue:CTS() end, nil, true)

    MailOut = self.current.mailout

    MailOut:Send()
  else
    zo_callLater(function () MailQueue:AttemptNext() end, 6000)
  end
end


function MailQueue:OneSuccess()
  if (self.current.callback) then
    self.current.callback()
  end

  self.t:Start()
end


function MailQueue:OneFailed(reason)
  if (self.current.failback) then
    self.current.failback(reason, clone(self.current))
  end

  self.t:Start()
end


function MailQueue:CTS()
  if (MailOut.active) then
    self.t:Start()
  else
    self.cts = true
    MailQueue:AttemptNext()
  end
end




function lib.OnMailEventSendSuccess(eventCode)
  if (MailOut.active and MailOut.sent) then
    MailOut:Success()
  end
end


function lib.OnMailEventSendFailed(eventCode, reason)
  if (MailOut.active and MailOut.sent) then
    MailOut:Failure(reason)
  end
end


---------------------------------------------------------- end MailQueue


---------------------------------------------------------- Iterator
-- Iterates elements of a given table, and calls
-- a callback for each element.  The callback should
-- expect the iterator as it's only parameter.
----------------------------------------------------

local Iterator = lib.HotepUtilities.Iterator

function Iterator:New(t, callback, params, doneback)
  local iterator = {
    t = t,
    callback = callback,
    params = params,
    doneback = doneback,
    index = nil,
    current = nil,
    n = 0,
  }
  setmetatable(iterator, { __index = Iterator })
  
  return iterator
end

setmetatable(Iterator, { __call = Iterator.New })


function Iterator:Next()
  self.index, self.current = next(self.t, self.index)
  
  if (self.index == nil) then
    self:Break()
    return
  end
  
  self.n = self.n + 1
  zo_callLater(function () self.callback(self) end, 250)
end


function Iterator:Break()
  
  local fun = function ()
    self.doneback(self.t, self.n, self.params)
  end
  
  zo_callLater(fun, 250)
end

---------------------------------------------------------- end Iterator


---------------------------------------------------------- SendChat
-- holds one message the user needs to send out to chat
-- begs the user to press enter until user sends message
-- or timeout expires
--------------------------------------------------------



local chatslashes = {
  [CHAT_CHANNEL_EMOTE] = "/emote",
  [CHAT_CHANNEL_GUILD_1] = "/g1",
  [CHAT_CHANNEL_GUILD_2] = "/g2",
  [CHAT_CHANNEL_GUILD_3] = "/g3",
  [CHAT_CHANNEL_GUILD_4] = "/g4",
  [CHAT_CHANNEL_GUILD_5] = "/g5",
  [CHAT_CHANNEL_PARTY] = "/group",
  [CHAT_CHANNEL_SAY] = "/say",
  [CHAT_CHANNEL_YELL] = "/yell",
  [CHAT_CHANNEL_ZONE] = "/zone",
}


local SendChat = {}
local ChatOut = {
  active = false
}


function SendChat:New(timeout, channel, text, handle, callback, failback)
  
  if (ChatOut.active) then return false end
  
  local chatout = {
    timeout = timeout * 60000,
    oldchannel = CHAT_SYSTEM.currentChannel,
    channel = channel,
    text = text,
    handle = handle,
    active = false,
    sent = false,
    callback = callback,
    failback = failback,
    time = 0,
    cmd = false,
    t = nil,
    beg = nil,
    paused = false,
    wait = Timer:New(0.5, function() ChatOut:Continue() end, nil, true)
  }
  setmetatable(chatout, { __index = SendChat })
  
  
  if (type(channel) == "number") then
    chatout.cmd = chatslashes[channel]
    if (not chatout.cmd) then chatout.cmd = false end
  else
    if (channel) then chatout.cmd = channel end
  end
  
  
  ChatOut = chatout
  return ChatOut:Attempt()
end

setmetatable(SendChat, { __call = SendChat.New })


function SendChat:Pause()
  HotepToolsLib_ChatPrompt:SetHidden(true)
  if (self.t) then
    self.t:Stop()
  end
  self.wait:Start()
end


function SendChat:Continue()
  if (self.t) then
    local paused = self.t:Continue()
    if (paused) then
      self.time = self.time + paused
    end
  end
end


function SendChat:Attempt()
  HotepToolsLib_ChatPrompt:SetHidden(true)
  
  if (self.sent) then return false end
  
  if (IsUnitInCombat("player")) then
    zo_callLater(function () ChatOut:Attempt() end, 2000)
    return true
  end
  
  if (self.channel == "wisp") then
    CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_WHISPER, self.handle)
  elseif (self.cmd) then
    CHAT_SYSTEM:StartTextEntry(self.cmd)
    CHAT_SYSTEM:SubmitTextEntry()
    self.channel = CHAT_SYSTEM.currentChannel
  else
    self.channel = CHAT_SYSTEM.currentChannel
  end
  
  
  if (not self.active) then
    self.time = GetGameTimeMilliseconds()
    self.active = true
    self.t = Timer(0.2, function () ChatOut:Attempt() end, nil, true)
--    self.beg = Timer(0.01, function () ChatOut:BegIt() end, nil, true)
  end
  
  zo_callLater(function ()
      ChatOut:SayIt()
    end, 150)
  
  return true
end


function SendChat:SayIt()
  if (self.sent or not self.active) then return end
  
  
  if ((GetGameTimeMilliseconds() - self.time) > self.timeout) then
    self:Failed()
    return
  end
  
  self.t:Start()
  CHAT_SYSTEM:StartTextEntry(self.text)
  HotepToolsLib_ChatPrompt:SetHidden(false)
  PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
--  self.beg:Start()
end


function SendChat:SetBackToOld()
  local cmd = chatslashes[self.oldchannel]
  if (cmd) then
    CHAT_SYSTEM:StartTextEntry(cmd)
    CHAT_SYSTEM:SubmitTextEntry()
  end
end


function SendChat:Failed(stopped)
  self.t:Destroy()
--  self.beg:Destroy()
  HotepToolsLib_ChatPrompt:SetHidden(true)
  
  self.active = false
  
  self:SetBackToOld()
  
  if (self.failback and not stopped) then
    zo_callLater(self.failback, 750)
  end
end


--function SendChat:BegIt()
--  CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT,
--    SOUNDS.QUEST_COMPLETED, "** PLEASE PRESS ENTER **", "[Hotep]",
--    nil, nil, nil, nil, 4440)
--end


function SendChat:SentSomething(channel, text, handle)
  
  HotepToolsLib_ChatPrompt:SetHidden(true)
  
  if (self.sent or not self.active) then return end
  
  if (channel ~= self.channel) then return end
  
  if (text ~= self.text) then return end
  
  if (channel == "wisp") then
    if (string.sub(handle, 1, 1) ~= "@") then
      handle = zo_strformat(SI_UNIT_NAME, handle)
    end
    if (handle ~= self.handle) then return end
  end
  
  -- user sent the chat message we wanted them to send
  
  self.t:Destroy()
--  self.beg:Destroy()
  
  self.sent = true
  self.active = false
  
  self:SetBackToOld()
  
  if (self.callback) then
    zo_callLater(self.callback, 750)
  end
end



function lib.OnChatEvent(eventCode, messageType, fromName, text, isCustomerService)

  if (isCustomerService) then
    return
  end

  if (messageType == CHAT_CHANNEL_WHISPER_SENT) then
    if (ChatOut.active) then ChatOut:SentSomething("wisp", text, fromName) end
  else
    if ((fromName ~= GetUnitDisplayName("player")) 
                and (zo_strformat(SI_UNIT_NAME, fromName) ~= GetUnitName("player"))) then
      return
    end
    
    if (ChatOut.active) then ChatOut:SentSomething(messageType, text, fromName) end
  end
end


function lib.shutup()
  if (ChatOut.Failed and ChatOut.active) then
    ChatOut.sent = true
    ChatOut:Failed(true)
  end
end





---------------------------------------------------------- end SendChat


---------------------------------------------------------- ChatQueue
-- queues up several chat messages that need to be sent
-- out (on same channel), and sends them one at a time
-------------------------------------------------------

local ChatQueue = lib.HotepUtilities.ChatQueue


function ChatQueue.Foo(t)
  ChatQueue:New(t.timeout, t.channel, t.handle, t.callback, t.failback, t.msgs)
end


function ChatQueue:New(timeout, channel, handle, callback, failback, msgs)
  if (self.active) then
    Timer:Once(0.05, ChatQueue.Foo, {timeout = timeout, channel = channel, handle = handle, callback = callback, failback = failback, msgs = msgs})
    return
  end
  
  if (not lib.initialized) then
    error("HotepToolsLib must be initialized before use by calling :Init()")
  end
  
  self.active = true
  if (timeout) then self.timeout = timeout else self.timeout = 10 end
  self.channel = channel
  self.handle = handle
  self.callback = callback
  self.failback = failback
  self.msgQ = {}
  
  if (msgs) then
    self.msgQ = msgs
    ChatQueue:Start()
  end
  
  return true
end

setmetatable(ChatQueue, { __call = ChatQueue.New })


function ChatQueue:Add(msg, last)
  table.insert(self.msgQ, msg)
  
  if (last) then
    ChatQueue:Start()
  end
end


function ChatQueue:Start()
  ChatQueue:SendNext()
end


function ChatQueue:Stop()
  lib.shutup()
  self:Done()
end


function ChatQueue:Pause()
  if (ChatOut.active) then
    ChatOut:Pause()
  end
end


function ChatQueue:SendNext()
  
  if (#self.msgQ == 0) then
    ChatQueue:Done()
    return
  end
  
  if (not ChatOut.active) then
    local text = table.remove(self.msgQ, 1)
    
    text = string.gsub(text, "%s$", "")   -- right-trim
    
    if (string.len(text) == 0) then
      zo_callLater(function () ChatQueue:SendNext() end, 60)
      return
    end
    
    local cb = function () ChatQueue:SendNext() end
    local fb = function () ChatQueue:Failed() end
    
    if (not SendChat(self.timeout, self.channel, text, self.handle, cb, fb)) then fb() end
  else
    zo_callLater(function () ChatQueue:SendNext() end, 6000)
  end
end


function ChatQueue:Failed()
  self.active = false
  
  if (self.failback) then
    zo_callLater(self.failback, 750)
  end
end


function ChatQueue:Done()
  self.active = false
  
  if (self.callback) then
    zo_callLater(self.callback, 750)
  end
end

---------------------------------------------------------- end ChatQueue














lib.MATCH_EXACT = 0
lib.MATCH_SUBSTRING = 1

lib.MATCHTYPES = {lib.MATCH_EXACT, lib.MATCH_SUBSTRING}


lib.HotepMailReader = {
  name = "HotepMailReader",
  numUnread = 0,
  GetMyMailNow = nil,
  registered = {},
  processingMail = false,
  started = false,
  abort = false,
  preabort = false,
  notify = {},
  check = 3,
  defer = 0.3,             -- if mailbox busy, try again in 18 seconds
  MailInfo = {},
  callback = nil,
  donereading = true,
}


local HotepMail = lib.HotepMailReader


function HotepMail:ChatNotify(addonName)
  if (not array_key_exists(addonName, self.registered)) then return end
  
  self.notify[addonName] = true
end


local onmailregister


function HotepMail:Register(addonName, MagicSubject, match_type, MailReadCallback)
  
  if (array_key_exists(addonName, self.registered)) then return false end
  
  if (type(MagicSubject) ~= "string") then return false end
  if (not in_array(match_type, lib.MATCHTYPES)) then return false end
  if (type(MailReadCallback) ~= "function") then return false end
  
  if (not lib.initialized) then
    error("HotepToolsLib must be initialized before use by calling :Init()")
  end
  
  local x = {
    MagicSubject = MagicSubject,
    match_type = match_type,
    MailReadCallback = MailReadCallback,
  }
  
  self.registered[addonName] = x
  
  if (not self.started) then self:Start() end
  
  if (not onmailregister) then
    onmailregister = Timer(0.25, HotepMail.OnMailEventUnread, nil, true)
  end
  
  onmailregister:Start()
  
  return true
end


function HotepMail:Unregister(addonName)
  
  self.registered[addonName] = nil
  
  self.notify[addonName] = nil
  
  if (next(self.registered) == nil) then self:Stop() end
end


function HotepMail.ErrorReset()
  HotepMail.abort = false
  HotepMail.preabort = false
  HotepMail.processingMail = false
  HotepMail.donereading = true
  msgWithName("Mail Reading Reset.", COLOR_RED)
end


local timer_mailerror = Timer:New(5, HotepMail.ErrorReset, nil, true)


function HotepMail:Start()
  self.started = true
--  EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_MAIL_OPEN_MAILBOX, self.OnMailSceneOpened)
  
  EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_START_FAST_TRAVEL_INTERACTION, HotepMail.PreAbort)
  EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_END_FAST_TRAVEL_INTERACTION, HotepMail.PostAbort)
  EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_PLAYER_DEACTIVATED, HotepMail.Abort)
  EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_PLAYER_ACTIVATED, HotepMail.UnAbort)
  
  
--  ZO_PreHook("ReloadUI", HotepMail.WaitDontLogout)
--  ZO_PreHook("Logout", HotepMail.WaitDontLogout)
--  ZO_PreHook("SetCVar", HotepMail.WaitDontLogout)
--  ZO_PreHook("Quit", HotepMail.WaitDontLogout)
  
  
  local foo = function ()
    EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_MAIL_NUM_UNREAD_CHANGED, HotepMail.OnMailEventUnread)
  end
  
  self.GetMyMailNow = Timer(0.25, foo, nil, true)
  
  foo()
end

function HotepMail:Stop()
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_MAIL_NUM_UNREAD_CHANGED)
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_PLAYER_DEACTIVATED)
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_PLAYER_ACTIVATED)
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_START_FAST_TRAVEL_INTERACTION)
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_END_FAST_TRAVEL_INTERACTION)
  
  self.GetMyMailNow:Destroy()
  self.GetMyMailNow = nil
  self.started = false
end


function HotepMail.PreAbort()
  HotepMail.abort = true
  HotepMail.preabort = true
end


function HotepMail.PostAbort()
  if (HotepMail.preabort) then
    HotepMail.abort = false
    HotepMail.preabort = false
  end
end


function HotepMail.Abort()
  HotepMail.abort = true
  HotepMail.preabort = false
end


function HotepMail.UnAbort()
  HotepMail.abort = false
  HotepMail.preabort = false
  
--    
--  d("fixing?")
  zo_callLater(function () SCENE_MANAGER:ShowBaseScene() end, 2000)
end


function HotepMail:checkSubject(subject, addonName)
  local x = self.registered[addonName]
  
  if (x.match_type == lib.MATCH_EXACT) then
    return (subject == x.MagicSubject)
  else
    return (string.find(subject, x.MagicSubject, 1, true) ~= nil)
  end
end


--local FAKE_MAIL = {
--  mailId = zo_getSafeId64Key(math.random(GetTimeStamp())),
--  subject = "Hotep Placeholder",
--  formattedSubject = "|cff0000Hotep Placeholder|r",
--  senderDisplayName = HotepMail.name,
--  senderCharacterName = "",
--  expiresInDays = 0,
--  expiresText = "HOTEP",
--  state = 0,
--  unread = false,
--  numAttachments = 0,
--  codAmount = 0,
--  attachedMoney = 0,
--  secsSinceReceived = 1,
--  receivedText = ZO_FormatDurationAgo(1),
--  fromSystem = false,
--  fromCS = false,
--  priority = 2,
--  GetFormattedSubject = function(self) return self.formattedSubject end,
--  GetExpiresText = function(self) return self.expiresText end,
--  GetReceivedText = function(self) return self.receivedText end,
--}



local mnreset

local function NotifyMail(num)
  if (num > 0) then
    d(zo_strformat("** You have <<1>> unread mail **", num))
  end
  
  mnreset()
end


local mailNotify = Timer(0.1, NotifyMail, 0, true)

mnreset = function ()
  mailNotify.params = 0
  HotepMail.numUnread = 0
end


local function cleanup()
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_MAIL_CLOSE_MAILBOX)
  
  lib.MailR()
  
  if (HotepMail.numUnread > mailNotify.params) then
    mailNotify.params = HotepMail.numUnread
  end
  
  HotepMail.processingMail = false
  HotepMail.donereading = true
  timer_mailerror:Stop()
  
  if (in_array(true, HotepMail.notify)) then msgWithName("Done Reading Mail", COLOR_RED) end
  
  if (in_array(true, HotepMail.notify)) then mailNotify:Start() end
  
  HotepMail.GetMyMailNow:Start()
end


function HotepMail.OnMailEventUnread(ee, nn)
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_MAIL_NUM_UNREAD_CHANGED)
  
  if (not IsPlayerActivated()) then
    Timer:Once(0.03, HotepMail.OnMailEventUnread)
    return
  end
  
  timer_mailerror:Start(5)
  
  if (HotepMail.processingMail or badscene() or InTheMailBox() or HotepMail.abort) then
    Timer:Once(HotepMail.defer, HotepMail.OnMailEventUnread)
    return
  end
  
  HotepMail.numUnread = GetNumUnreadMail()
  
  HotepMail.processingMail = true
  
  if (in_array(true, HotepMail.notify) and HotepMail.donereading) then
    msgWithName("Reading Mail", COLOR_RED)
    PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
  end
  
  lib.MailRcompat()
  
  EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_MAIL_OPEN_MAILBOX, HotepMail.OnMailEventMailboxOpened)
  SCENE_MANAGER:Show("mailInbox")
end


function HotepMail.OnMailEventMailboxOpened(eventCode)
  EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_MAIL_OPEN_MAILBOX)
  
  zo_callLater(HotepMail.OnMailEventFoobar, 50)
end


function HotepMail.OnMailEventFoobar()
  
--  MAIL_INBOX:BuildMasterList()
--  FAKE_MAIL.mailId = zo_getSafeId64Key(math.random(GetTimeStamp()))
--  table.insert(MAIL_INBOX.masterList, 1, FAKE_MAIL)
  
  local mailid = nil
  
  if (not HotepMail.abort) then
    mailid = GetNextMailId(nil)
  end
  
  while ((mailid ~= nil) and not HotepMail.abort) do
    if ((type(mailid) == "number")) then
      local sender, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService,
          returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailid)
      
      if (not fromSystem and not fromCustomerService and not returned) then
        
        HotepMail.MailInfo = {
          sender = sender,
          senderCharacterName = senderCharacterName,
          subject = subject,
          icon = icon,
          unread = unread,
          numAttachments = numAttachments,
          attachedMoney = attachedMoney,
          codAmount = codAmount,
          expiresInDays = expiresInDays,
          secsSinceReceived = secsSinceReceived,
          mailid = mailid,
        }
        
        for addonName, x in pairs(HotepMail.registered) do
          HotepMail.callback = x.MailReadCallback
          if (HotepMail:InspectMail(addonName)) then return end
        end
      end
    end
    
    if (not HotepMail.abort) then
      mailid = GetNextMailId(mailid)
    end
  end
  
  EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_MAIL_CLOSE_MAILBOX, cleanup)
  SCENE_MANAGER:ShowBaseScene()
end


function HotepMail:InspectMail(addonName)
  
  local z = HotepMail.MailInfo
  
  HotepMail.inspectAddon = addonName
  
  if (HotepMail.abort) then return false end
  
  if (HotepMail:checkSubject(z.subject, addonName)) then
    
--    local foo = function(eventCode)
--      EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_MAIL_CLOSE_MAILBOX)
--      HotepMail.processingMail = false
--      HotepMail.donereading = false
      
--      Timer:Once(0.02, HotepMail.OnMailEventUnread)
--    end
    
    local foo = function (ee, id)
      EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_MAIL_REMOVED)
      Timer:Once(0.003, HotepMail.OnMailEventFoobar)
    end
    
    local fun = function (eventCode, Mailid)
      EVENT_MANAGER:UnregisterForEvent(HotepMail.name, EVENT_MAIL_READABLE)
      
      
      if (HotepMail.MailInfo.mailid == Mailid) then
        local param = HotepMail.MailInfo
        local body = ReadMail(Mailid)
        HotepMail.callback(param, body)
        
  --      table.insert(HotepMail.MailToDelete, Mailid)
        
        EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_MAIL_REMOVED, foo)
        DeleteMail(Mailid, true)
        HotepMail.numUnread = HotepMail.numUnread - 1
      else
        Timer:Once(0.003, HotepMail.OnMailEventFoobar)
      end
    
--      EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_MAIL_CLOSE_MAILBOX, foo)
--      SCENE_MANAGER:ShowBaseScene()
      
    end
    
    EVENT_MANAGER:RegisterForEvent(HotepMail.name, EVENT_MAIL_READABLE, fun)
    RequestReadMail(z.mailid)
    
    return true
  end
  
  return false
end




--function HotepMail.OnMailSceneOpened(eventCode)

--  if (SCENE_MANAGER.currentScene.name ~= "mailInbox") then return end
--  if (HotepMail.processingMail) then return end

--  if (#HotepMail.MailToDelete < 1) then
----    if (HotepMail.peppercorn) then
----      HotepMail.peppercorn = false
----      SCENE_MANAGER:ShowBaseScene()
----      CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT,
----        SOUNDS.QUEST_COMPLETED, "I'm done now, thanks!", "[Hotep]",
----        nil, nil, nil, nil, 2220)
----    end
    
--    return 
--  end
  

--  local mailid = table.remove(HotepMail.MailToDelete, 1)

--  DeleteMail(mailid, true)

--  Timer:Once(0.003, HotepMail.OnMailSceneOpened, eventCode)
--end



--function HotepMail.WaitDontLogout()
  
--  if (#HotepMail.MailToDelete < 1) then return false end
  
--  local foo = function()
--    SCENE_MANAGER:Show("mailInbox")
--  end
  
--  HotepMail.processingMail = false
--  HotepMail.peppercorn = true
  
--  SCENE_MANAGER:ShowBaseScene()
--  zo_callLater(foo, 500)
  
--  CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT,
--    SOUNDS.QUEST_COMPLETED, "Sorry, I need to clean up your mailbox first!", "[Hotep]",
--    nil, nil, nil, nil, 2220)
  
--  return true
--end


















