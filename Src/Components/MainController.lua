--[[
	Main controller for Roact-Visualizer.
]]

local main = script.Parent.Parent.Parent
local Roact = require(main.Packages.Roact)
local PluginWidget = require(main.Src.Components.Base.PluginWidget)

local MainController = Roact.PureComponent:extend("MainController")

function MainController:init()
	self.state = {
		enabled = false,
	}

	self.setEnabled = function(newEnabled)
		self:setState({
			enabled = newEnabled,
		})
	end

	self.close = function()
		self:setState({
			enabled = false,
		})
	end
end

function MainController:render()
	local state = self.state
	local enabled = state.enabled

	return Roact.createFragment({
		Widget = Roact.createElement(PluginWidget, {
			Title = "Roact Visualizer",
			Enabled = enabled,
			Size = Vector2.new(640, 480),
			MinSize = Vector2.new(200, 40),
			InitialDockState = Enum.InitialDockState.Right,
			OnClose = self.close,
			ShouldRestore = true,
			OnWidgetRestored = self.setEnabled,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}),
	})
end

return MainController
