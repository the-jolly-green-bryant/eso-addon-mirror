-- Last manifest entry: samples after every Battle Scrolls Lua and XML file has
-- executed, and before this addon's SavedVariables are loaded. The difference
-- from storage/memtrace.lua's "first" sample is the code/XML loading cost.
BattleScrolls.memTrace.sample("code")

-- Eager collection at the end of code loading. Loading leaves a few MiB of
-- dead objects (executed main chunks and compile leftovers) in the Lua heap.
-- The console's Add-On Memory gauge keeps the pages the Lua allocator took,
-- so freeing them lowers nothing by itself; collecting here lets the
-- SavedVariables graph, built right after this file, fill those pages instead
-- of taking new ones. /bsmemlab load shows the result as the "code" row's
-- third column (after collection) and the "init" row.
collectgarbage("collect")
BattleScrolls.memTrace.sample("code+")
