local LIB_IDENTIFIER = "LibNeuralNetworks"
assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

_G[LIB_IDENTIFIER] = {
	name = LIB_IDENTIFIER,
	version = "1.0.0",
	author = "@Drako-Ei",
	math = {}
}