-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
local Promise = LibPromises
LibPromiseTest = {}

local function resolved(value)
    local p = Promise:New()
    p:Resolve(value)
    return p
end

LibPromiseTest.resolved = resolved

local function rejected(value)
    local p = Promise:New()
    p:Reject(value)
    return p
end

LibPromiseTest.rejected = rejected

local function deferred()
    local p = Promise:New()
    return {
        promise = p,
        resolve = function(value) return p:Resolve(value) end,
        reject = function(reason) return p:Reject(reason) end,
    }
end

LibPromiseTest.deferred = deferred
