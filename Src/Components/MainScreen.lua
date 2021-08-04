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
local ModuleFromFileSelector = require(main.Src.Components.ModuleFromFileSelector)
local ToastMessage = require(main.Src.Components.ToastMessage)
local InputAutoRefreshDelay = require(main.Src.Components.InputAutoRefreshDelay)
local InputScriptName = require(main.Src.Components.InputScriptName)
local ConfirmDeleteScript = require(main.Src.Components.ConfirmDeleteScript)
local RoactSelectHelper = require(main.Src.Components.RoactSelectHelper)
local ConfirmStartupState = require(main.Src.Components.ConfirmStartupState)
local AboutScreen = require(main.Src.Components.AboutScreen)
local NoPermissionsScreen = require(main.Src.Components.NoPermissionsScreen)

local MainScreen = Roact.PureComponent:extend("MainScreen")

function MainScreen:render()
	local props = self.props
	return Roact.createFragment({
		Background = Roact.createElement(MainBackground),
		TopToolbar = Roact.createElement(TopToolbar),
		BottomToolbar = Roact.createElement(BottomToolbar),
		ToastMessage = Roact.createElement(ToastMessage),
		ViewWindow = props.RoactInstall and Roact.createElement(ViewWindow),

		NoPermissionsScreen = not props.HasScriptPermission and Roact.createElement(NoPermissionsScreen),
		HasPermissions = props.HasScriptPermission and Roact.createFragment({
			AboutScreen = props.ShowAboutScreen and Roact.createElement(AboutScreen),
			MainView = not props.ShowAboutScreen and Roact.createFragment({
				RoactSelectHelper = Roact.createElement(RoactSelectHelper),
				HasRoact = props.RoactInstall and Roact.createFragment({
					ModuleSelector = Roact.createElement(ModuleSelector),
					ModuleFromFileSelector = Roact.createElement(ModuleFromFileSelector),
					InputAutoRefreshDelay = Roact.createElement(InputAutoRefreshDelay),
					InputScriptName = Roact.createElement(InputScriptName),
					ConfirmDeleteScript = Roact.createElement(ConfirmDeleteScript),
					ConfirmStartupState = Roact.createElement(ConfirmStartupState),
				}),
			}),
		}),
	})
end

MainScreen = RoactRodux.connect(function(state)
	return {
		RoactInstall = state.PluginState.RoactInstall,
		ShowAboutScreen = state.PluginState.ShowAboutScreen,
		HasScriptPermission = state.PluginState.HasScriptPermission,
	}
end)(MainScreen)

return MainScreen
