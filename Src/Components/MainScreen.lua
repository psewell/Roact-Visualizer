--[[
	Main screen for Roact-Visualizer.
	Consists of the toolbar, the view, and any modals.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local MainBackground = require(main.Src.Components.MainBackground)
local ViewWindow = require(main.Src.Components.ViewWindow)
local ModuleSelector = require(main.Src.Components.ModuleSelector)

local MainScreen = Roact.PureComponent:extend("MainScreen")

function MainScreen:render()
	return Roact.createFragment({
		Background = Roact.createElement(MainBackground),
		ViewWindow = Roact.createElement(ViewWindow),
		ModuleSelector = Roact.createElement(ModuleSelector),
	})
end

return MainScreen
