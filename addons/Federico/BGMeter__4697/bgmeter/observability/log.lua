BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Log = {}
Log.DEBUG = false

local PREFIX = "|cE34234[bgmeter]|r "

local ring = {}
local RING_CAP = 600
local ring_n = 0
local ring_head = 0

local function remember(tag, msg)
    ring_n = ring_n + 1
    ring_head = (ring_head % RING_CAP) + 1
    ring[ring_head] = string.format("%04d %s %s", ring_n, tag, msg)
end

local function format_msg(fmt, ...)
    local ok, msg = pcall(string.format, fmt, ...)
    if not ok then msg = tostring(fmt) end
    return msg
end

local function chat(color, msg)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(PREFIX .. "|c" .. color .. msg .. "|r")
    end
end

function Log.say(fmt, ...)
    local msg = format_msg(fmt, ...)
    remember("[s]", msg)
    chat("FFFFFF", msg)
end

function Log.debug(fmt, ...)
    local msg = format_msg(fmt, ...)
    remember("[d]", msg)
    if Log.DEBUG then chat("AAAAAA", msg) end
end

function Log.error(fmt, ...)
    local msg = format_msg(fmt, ...)
    remember("[e]", msg)
    chat("FF4040", msg)
end

function Log.lines()
    local out = {}
    local total = math.min(ring_n, RING_CAP)
    for i = 1, total do
        out[i] = ring[((ring_head - total + i - 1) % RING_CAP) + 1]
    end
    return out
end

function Log.seal()
    local K = BGMeter.Constants
    if K and K.dev_tools and K.dev_tools() then return end
    local noop = function() end
    Log.say, Log.debug, Log.error = noop, noop, noop
    Log.lines = function() return {} end
end
Log.seal()

BGMeter.Log = Log
