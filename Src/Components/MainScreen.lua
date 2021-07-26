--[[
	Main screen for Roact-Visualizer.
	Consists of the toolbar, the view, and any modals.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local MainBackground = require(main.Src.Components.MainBackground)
local TopToolbar = require(main.Src.Components.TopToolbar)
local BottomToolbar = require(main.Src.Components.BottomToolbar)
local ViewWindow = require(main.Src.Components.ViewWindow)
local ModuleSelector = require(main.Src.Components.ModuleSelector)
local ToastMessage = require(main.Src.Components.ToastMessage)
local InputAutoRefreshDelay = require(main.Src.Components.InputAutoRefreshDelay)

local MainScreen = Roact.PureComponent:extend("MainScreen")

function MainScreen:render()
	return Roact.createFragment({
		Background = Roact.createElement(MainBackground),
		TopToolbar = Roact.createElement(TopToolbar),
		BottomToolbar = Roact.createElement(BottomToolbar),
		ViewWindow = Roact.createElement(ViewWindow),
		ModuleSelector = Roact.createElement(ModuleSelector),
		ToastMessage = Roact.createElement(ToastMessage),
		InputAutoRefreshDelay = Roact.createElement(InputAutoRefreshDelay),
	})
end

return MainScreen
