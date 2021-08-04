--[[
	Gets all ModuleScripts in the game.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Cryo = require(main.Packages.Cryo)

local SEARCH_LOCATIONS = {
	game.ReplicatedStorage,
	game.Workspace,
	game.StarterPlayer,
	game.StarterGui,
	game.StarterPack,
	game.ServerScriptService,
	game.ServerStorage,
	game.PluginGuiService,
	game.PluginDebugService,
}

local function search(location)
	return Cryo.List.filter(location:GetDescendants(), function(item)
		return item:IsA("ModuleScript")
	end)
end

local function getAllModules(colorFunc)
	local results = {}
	for _, location in ipairs(SEARCH_LOCATIONS) do
		results = Cryo.List.join(results, search(location))
	end
	return results
end

return getAllModules
