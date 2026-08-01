local startLoadTime = GetGameTimeMilliseconds()
AOEHelper = AOEHelper or {}


local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)