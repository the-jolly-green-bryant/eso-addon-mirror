-- SPDX-FileCopyrightText: 2025 m00nyONE
-- SPDX-License-Identifier: Artistic-2.0

local lib_name = "LibCustomNames"
local lib = _G[lib_name]
local lib_author = lib.author
local lib_version = lib.version

--- menu building - this function gets overwritten depending on platform ESO runs on
function lib.BuildMenu() end