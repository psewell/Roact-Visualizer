--[[
	A Symbol to indicate a syntax error.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Symbol = require(main.Packages.Symbol)

return Symbol.named("SyntaxError")
