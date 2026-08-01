local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}
AOEHelper.loadTime = AOEHelper.loadTime or 0
AOEHelper.name = "AOEHelper"
AOEHelper.author = "|c76c3f4@m00nyONE|r"
AOEHelper.variableVersion = 1
AOEHelper.version = "1.2.2"
AOEHelper.globalDelay = 2000
--AOEHelper.URL_LINK_TYPE = "aoe"
AOEHelper.defaultVariables = {
    savedZones = {},
    savedBosses = {}
}

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)