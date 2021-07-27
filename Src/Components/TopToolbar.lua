--[[
	Toolbar controls at the top of the visualizer.
]]

local noop = function() end

local tooltips = {
	Update = [[Update the current component to reflect the latest changes]],
	Tree = [[Edit the Roact tree around the current component
Right click for more options.]],
	Props = [[Edit the props passed to the current component
Right click for more options.]],
	Center = [[Alignment: Centered]],
	Actual = [[Alignment: Actual]],
	Menu = [[Settings]],
	Recording = [[Auto Update is actively polling script changes]],
	NotRecording = [[Auto Update is paused - no active component]],
}

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Reload = require(main.Src.Reducers.PluginState.Actions.Reload)
local SetSetting = require(main.Src.Reducers.Settings.Actions.SetSetting)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local TextButton = require(main.Src.Components.TextButton)
local SettingsButton = require(main.Src.Components.SettingsButton)
local ScriptLoadButton = require(main.Src.Components.ScriptLoadButton)
local Connection = require(main.Src.Components.Signal.Connection)
local PluginContext = require(main.Src.Contexts.PluginContext)
local getColor = require(main.Src.Util.getColor)

local TopToolbar = Roact.PureComponent:extend("TopToolbar")

function TopToolbar:init()
	self.targetRef = Roact.createRef()
	self.state = {
		pluginGui = nil,
		absoluteSize = Vector2.new(),
	}

	self.sizeChanged = function(size)
		self:setState({
			absoluteSize = size or self.state.pluginGui.AbsoluteSize
		})
	end

	self.toggleAlignment = function()
		self.props.SetAlignCenter(not self.props.AlignCenter)
	end

	self.openTree = function()
		local plugin = PluginContext:get(self)
		plugin:OpenScript(self.props.Root)
		self.props.SetMessage({
			Type = "OpenedRootModule",
			Text = "Opened Root module",
			Time = 2,
		})
	end

	self.openProps = function()
		local plugin = PluginContext:get(self)
		plugin:OpenScript(self.props.Props)
		self.props.SetMessage({
			Type = "OpenedPropsModule",
			Text = "Opened Props module",
			Time = 2,
		})
	end
end

function TopToolbar:didMount()
	local target = self.targetRef:getValue()
	local pluginGui = target:FindFirstAncestorWhichIsA("PluginGui")
	self:setState({
		pluginGui = pluginGui,
	})
	self.sizeChanged(pluginGui.AbsoluteSize)
end

function TopToolbar:render()
	local props = self.props
	local theme = props.Theme
	local selecting = props.SelectingModule
	local center = props.AlignCenter
	local rootModule = props.RootModule

	local state = self.state
	local pluginGui = state.pluginGui
	local absoluteSize = state.absoluteSize
	local minified = absoluteSize.X < 288
	local minifyUpdate = absoluteSize.X < 215

	return Roact.createElement("Frame", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = getColor(function(c)
			return theme:GetColor(c.Titlebar)
		end),
		BorderColor3 = getColor(function(c)
			return theme:GetColor(c.Border)
		end),
		BorderSizePixel = 2,
		[Roact.Ref] = self.targetRef,
	}, {
		SizeChanged = pluginGui and Roact.createElement(Connection, {
			Signal = pluginGui:GetPropertyChangedSignal("AbsoluteSize"),
			Callback = self.sizeChanged,
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),

		AlignLeft = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 4),
			}),

			RefreshButton = not props.AutoRefresh and Roact.createElement(TextButton, {
				LayoutOrder = 1,
				Text = minifyUpdate and "" or "Update",
				Icon = "rbxassetid://7148367326",
				ImageSize = UDim2.fromOffset(20, 20),
				ImageOffset = Vector2.new(0, 1),
				ColorImage = true,
				Tooltip = not selecting and tooltips.Update or nil,
				OnActivated = props.Reload,
				Enabled = rootModule ~= nil,
			}) or nil,

			AutoRefresh = props.AutoRefresh and Roact.createElement(TextButton, {
				LayoutOrder = 1,
				Text = minifyUpdate and "" or "Auto",
				AutoButtonColor = false,
				Icon = rootModule ~= nil and "rbxassetid://7152317618" or "rbxassetid://7152324797",
				ImageSize = UDim2.fromOffset(20, 20),
				ColorImage = rootModule == nil,
				Tooltip = rootModule ~= nil and tooltips.Recording or tooltips.NotRecording,
				OnActivated = noop,
				Enabled = rootModule ~= nil,
			}) or nil,

			Separator = Roact.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.new(0, 1, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = getColor(function(c)
					return theme:GetColor(c.Border)
				end),
			}),

			Tree = Roact.createElement(ScriptLoadButton, {
				LayoutOrder = 3,
				Text = minified and "" or "Tree",
				Icon = "rbxassetid://7148430029",
				Tooltip = tooltips.Tree,
				Type = "RootScripts",
				OnActivated = self.openTree,
			}),

			Props = Roact.createElement(ScriptLoadButton, {
				LayoutOrder = 4,
				Text = minified and "" or "Props",
				Icon = "rbxassetid://7148440849",
				Tooltip = tooltips.Props,
				Type = "PropsScripts",
				OnActivated = self.openProps,
			}),
		}),

		AlignRight = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 4),
			}),

			Alignment = Roact.createElement(TextButton, {
				LayoutOrder = 1,
				Text = "",--center and "Centered" or "Actual",
				Icon = center and "rbxassetid://7157728506" or "rbxassetid://7143578075",
				ImageSize = UDim2.fromOffset(20, 20),
				ColorImage = true,
				Tooltip = not selecting and (center and tooltips.Center or tooltips.Actual) or nil,
				OnActivated = self.toggleAlignment,
			}),

			Separator = Roact.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.new(0, 1, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = getColor(function(c)
					return theme:GetColor(c.Border)
				end),
			}),

			Menu = Roact.createElement(SettingsButton, {
				LayoutOrder = 3,
				Tooltip = tooltips.Menu,
			}),
		}),
	})
end

TopToolbar = RoactRodux.connect(function(state)
	return {
		Root = state.ScriptTemplates.Root,
		Props = state.ScriptTemplates.Props,
		AlignCenter = state.Settings.AlignCenter,
		SelectingModule = state.PluginState.SelectingModule,
		RootModule = state.PluginState.RootModule,
		AutoRefresh = state.Settings.AutoRefresh,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		Reload = function()
			dispatch(Reload({}))
		end,

		SetAlignCenter = function(alignCenter)
			dispatch(SetSetting({
				AlignCenter = alignCenter,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,

		SetSetting = function(settings)
			dispatch(SetSetting(settings))
		end,
	}
end)(TopToolbar)

return TopToolbar
