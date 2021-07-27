--[[
	Main controller for Roact-Visualizer.
	Controls the plugin widget, toolbar, and buttons.
]]

local tooltip = [[Rapidly visualize and prototype Roact components and trees.]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local Rodux = require(main.Packages.Rodux)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginWidget = require(main.Src.Components.Base.PluginWidget)
local PluginToolbar = require(main.Src.Components.Base.PluginToolbar)
local PluginButton = require(main.Src.Components.Base.PluginButton)
local MainScreen = require(main.Src.Components.MainScreen)
local MainReducer = require(main.Src.Reducers.MainReducer)
local Initialize = require(main.Src.Reducers.Initialize)
local Teardown = require(main.Src.Reducers.Teardown)
local PluginContext = require(main.Src.Contexts.PluginContext)

local MainController = Roact.PureComponent:extend("MainController")

local function createMiddlewares()
	local middlewares = {
		Rodux.thunkMiddleware,
		--Rodux.loggerMiddleware,
	}
	return middlewares
end

function MainController:init()
	self.state = {
		enabled = false,
		store = nil,
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

function MainController:createStore()
	local middlewares = createMiddlewares()
	local store = Rodux.Store.new(MainReducer, nil, middlewares)
	local plugin = PluginContext:get(self)
	store:dispatch(Initialize(plugin))
	self:setState({
		store = store,
	})
end

function MainController:destroyStore()
	local store = self.state.store
	local plugin = PluginContext:get(self)
	store:dispatch(Teardown(plugin))
	store:flush()
	store:destruct()
	if not self.unmounted then
		self:setState({
			store = Roact.None,
		})
	end
end

function MainController:didUpdate()
	local state = self.state
	if state.enabled and state.store == nil then
		self:createStore()
	elseif state.store and not state.enabled then
		self:destroyStore()
	end
end

function MainController:render()
	local state = self.state
	local enabled = state.enabled
	local store = state.store

	return Roact.createFragment({
		Widget = Roact.createElement(PluginWidget, {
			Title = "Roact Visualizer",
			Enabled = enabled,
			Size = Vector2.new(640, 480),
			MinSize = Vector2.new(164, 64),
			InitialDockState = Enum.InitialDockState.Right,
			OnClose = self.close,
			ShouldRestore = true,
			OnWidgetRestored = self.setEnabled,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			MainStore = enabled and store and Roact.createElement(RoactRodux.StoreProvider, {
				store = store,
			}, {
				MainScreen = Roact.createElement(MainScreen),
			}),
		}),

		Toolbar = Roact.createElement(PluginToolbar, {
			Title = "Roact",
			RenderButtons = function(toolbar)
				return Roact.createElement(PluginButton, {
					Title = "Roact Visualizer",
					Tooltip = tooltip,
					Toolbar = toolbar,
					OnClick = self.toggle,
					Active = enabled,
					Icon = "rbxassetid://7138347364",
				})
			end,
		}),
	})
end

function MainController:willUnmount()
	local store = self.state.store
	if store then
		self.unmounted = true
		self:destroyStore()
	end
end

return MainController
