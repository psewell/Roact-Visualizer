--[[
	Main screen for Roact-Visualizer.
	Consists of the toolbar, the view, and any modals.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local MainBackground = require(main.Src.Components.MainBackground)
local TopToolbar = require(main.Src.Components.TopToolbar)
local BottomToolbar = require(main.Src.Components.BottomToolbar)
local ViewWindow = require(main.Src.Components.ViewWindow)
local ModuleSelector = require(main.Src.Components.ModuleSelector)
local ToastMessage = require(main.Src.Components.ToastMessage)
local InputAutoRefreshDelay = require(main.Src.Components.InputAutoRefreshDelay)
local InputScriptName = require(main.Src.Components.InputScriptName)
local ConfirmDeleteScript = require(main.Src.Components.ConfirmDeleteScript)
local RoactSelectHelper = require(main.Src.Components.RoactSelectHelper)
local ConfirmStartupState = require(main.Src.Components.ConfirmStartupState)

local MainScreen = Roact.PureComponent:extend("MainScreen")

function MainScreen:render()
	local props = self.props
	return Roact.createFragment({
		Background = Roact.createElement(MainBackground),
		TopToolbar = Roact.createElement(TopToolbar),
		BottomToolbar = Roact.createElement(BottomToolbar),
		RoactSelectHelper = Roact.createElement(RoactSelectHelper),
		ToastMessage = Roact.createElement(ToastMessage),

		HasRoact = props.RoactInstall and Roact.createFragment({
			ViewWindow = Roact.createElement(ViewWindow),
			ModuleSelector = Roact.createElement(ModuleSelector),
			InputAutoRefreshDelay = Roact.createElement(InputAutoRefreshDelay),
			InputScriptName = Roact.createElement(InputScriptName),
			ConfirmDeleteScript = Roact.createElement(ConfirmDeleteScript),
			ConfirmStartupState = Roact.createElement(ConfirmStartupState),
		}),
	})
end

MainScreen = RoactRodux.connect(function(state)
	return {
		RoactInstall = state.PluginState.RoactInstall,
	}
end)(MainScreen)

return MainScreen
