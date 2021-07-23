--[[
	Main screen for Roact-Visualizer.
	Consists of the toolbar, the view, and any modals.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local MainBackground = require(main.Src.Components.MainBackground)
local Toolbar = require(main.Src.Components.Toolbar)
local ViewWindow = require(main.Src.Components.ViewWindow)
local ModuleSelector = require(main.Src.Components.ModuleSelector)

local MainScreen = Roact.PureComponent:extend("MainScreen")

function MainScreen:render()
	return Roact.createFragment({
		Background = Roact.createElement(MainBackground),
		Toolbar = Roact.createElement(Toolbar),
		ViewWindow = Roact.createElement(ViewWindow),
		ModuleSelector = Roact.createElement(ModuleSelector),
	})
end

return MainScreen
