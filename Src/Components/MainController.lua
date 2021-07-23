--[[
	Main controller for Roact-Visualizer.
]]

local main = script.Parent.Parent.Parent
local Roact = require(main.Packages.Roact)
local PluginWidget = require(main.Src.Components.Base.PluginWidget)
local PluginToolbar = require(main.Src.Components.Base.PluginToolbar)
local PluginButton = require(main.Src.Components.Base.PluginButton)

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

	self.toggle = function()
		self:setState(function(oldState)
			return {
				enabled = not oldState.enabled,
			}
		end)
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

		Toolbar = Roact.createElement(PluginToolbar, {
			Title = "Roact Visualizer",
			RenderButtons = function(toolbar)
				return Roact.createElement(PluginButton, {
					Title = "Roact Visualizer",
					Toolbar = toolbar,
					OnClick = self.toggle,
					Active = enabled,
				})
			end,
		}),
	})
end

return MainController
