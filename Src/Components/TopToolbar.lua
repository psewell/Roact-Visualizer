--[[
	Toolbar controls at the top of the visualizer.
]]

local tooltips = {
	Update = [[Update the current component to reflect the latest changes]],
	Root = [[Edit the Roact tree above the current component]],
	Props = [[Edit the props passed to the current component]],
	Center = [[Alignment: Centered]],
	Actual = [[Alignment: Actual]],
}

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Reload = require(main.Src.Reducers.PluginState.Actions.Reload)
local SetAlignCenter = require(main.Src.Reducers.PluginState.Actions.SetAlignCenter)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local TextButton = require(main.Src.Components.TextButton)
local PluginContext = require(main.Src.Contexts.PluginContext)
local getColor = require(main.Src.Util.getColor)

local TopToolbar = Roact.PureComponent:extend("TopToolbar")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Minified = t.optional(t.boolean),
})

TopToolbar.defaultProps = {
	Minified = false,
}

function TopToolbar:init(props)
	assert(typecheck(props))

	self.toggleAlignment = function()
		self.props.SetAlignCenter(not self.props.AlignCenter)
	end

	self.openRoot = function()
		local plugin = PluginContext:get(self)
		plugin:OpenScript(self.props.Root)
		self.props.SetMessage({
			Text = "Opened Root module",
			Time = 2,
		})
	end

	self.openProps = function()
		local plugin = PluginContext:get(self)
		plugin:OpenScript(self.props.Props)
		self.props.SetMessage({
			Text = "Opened Props module",
			Time = 2,
		})
	end
end

function TopToolbar:render()
	local props = self.props
	local theme = props.Theme
	local minified = props.Minified
	local selecting = props.SelectingModule
	local center = props.AlignCenter
	local rootModule = props.RootModule

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
	}, {
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

			RefreshButton = Roact.createElement(TextButton, {
				LayoutOrder = 1,
				Text = minified and "" or "Update",
				Icon = "rbxassetid://7148367326",
				ImageSize = UDim2.fromOffset(20, 20),
				ImageOffset = Vector2.new(0, 1),
				ColorImage = true,
				Tooltip = not selecting and tooltips.Update or nil,
				OnActivated = props.Reload,
				Enabled = rootModule ~= nil,
			}),

			Root = Roact.createElement(TextButton, {
				LayoutOrder = 2,
				Text = minified and "" or "Root",
				Icon = "rbxassetid://7148430029",
				ImageSize = UDim2.fromOffset(20, 20),
				ImageOffset = Vector2.new(0, 1),
				ColorImage = true,
				Tooltip = tooltips.Root,
				OnActivated = self.openRoot,
			}),

			Props = Roact.createElement(TextButton, {
				LayoutOrder = 3,
				Text = minified and "" or "Props",
				Icon = "rbxassetid://7148440849",
				ImageSize = UDim2.fromOffset(20, 20),
				ImageOffset = Vector2.new(0, 2),
				ColorImage = true,
				Tooltip = tooltips.Props,
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
				Text = "",
				Icon = center and "rbxassetid://7143578269" or "rbxassetid://7143578075",
				ImageSize = UDim2.fromOffset(20, 20),
				ColorImage = true,
				Tooltip = not selecting and (center and tooltips.Center or tooltips.Actual) or nil,
				OnActivated = self.toggleAlignment,
			}),
		}),
	})
end

TopToolbar = RoactRodux.connect(function(state)
	return {
		Root = state.ScriptTemplates.Root,
		Props = state.ScriptTemplates.Props,
		AlignCenter = state.PluginState.AlignCenter,
		SelectingModule = state.PluginState.SelectingModule,
		RootModule = state.PluginState.RootModule,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		Reload = function()
			dispatch(Reload({}))
		end,

		SetAlignCenter = function(alignCenter)
			dispatch(SetAlignCenter({
				AlignCenter = alignCenter,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(TopToolbar)

return TopToolbar
