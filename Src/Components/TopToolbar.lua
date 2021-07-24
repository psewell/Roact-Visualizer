--[[
	Toolbar controls at the top of the visualizer.
]]

local tooltips = {
	Reload = [[Reload the current Component to reflect the latest changes to its script]],
	Center = [[Alignment: Centered]],
	Actual = [[Alignment: Actual]],
}

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Reload = require(main.Src.Reducers.PluginState.Actions.Reload)
local SetAlignCenter = require(main.Src.Reducers.PluginState.Actions.SetAlignCenter)
local TextButton = require(main.Src.Components.TextButton)
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
end

function TopToolbar:render()
	local props = self.props
	local theme = props.Theme
	local minified = props.Minified
	local selecting = props.SelectingModule
	local center = props.AlignCenter

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

		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
		}),

		RefreshButton = Roact.createElement(TextButton, {
			LayoutOrder = 2,
			Text = minified and "" or "Reload",
			Icon = "rbxassetid://69395121",
			ImageOffset = Vector2.new(0, 1),
			ColorImage = true,
			Tooltip = not selecting and tooltips.Reload or nil,
			OnActivated = props.Reload,
		}),

		Alignment = Roact.createElement(TextButton, {
			LayoutOrder = 3,
			Text = "",
			Icon = center and "rbxassetid://7143578269" or "rbxassetid://7143578075",
			ImageSize = UDim2.fromOffset(20, 20),
			ColorImage = true,
			Tooltip = not selecting and (center and tooltips.Center or tooltips.Actual) or nil,
			OnActivated = self.toggleAlignment,
		}),
	})
end

TopToolbar = RoactRodux.connect(function(state)
	return {
		AlignCenter = state.PluginState.AlignCenter,
		SelectingModule = state.PluginState.SelectingModule,
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
	}
end)(TopToolbar)

return TopToolbar
