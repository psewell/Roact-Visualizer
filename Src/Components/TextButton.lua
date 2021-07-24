--[[
	A simple text button.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local GetTextSize = require(main.Packages.GetTextSize)
local getColor = require(main.Src.Util.getColor)
local Tooltip = require(main.Src.Components.Tooltip)

local TextButton = Roact.PureComponent:extend("TextButton")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Text = t.optional(t.string),
	OnActivated = t.callback,
	Icon = t.optional(t.string),
	Default = t.optional(t.boolean),
	LayoutOrder = t.optional(t.integer),
	ImageSize = t.optional(t.UDim2),
	ImageOffset = t.optional(t.Vector2),
	Tooltip = t.optional(t.string),
	Position = t.optional(t.UDim2),
	AnchorPoint = t.optional(t.Vector2),
	ColorImage = t.optional(t.boolean),
})

TextButton.defaultProps = {
	Text = "",
	Default = false,
	LayoutOrder = 1,
	ImageOffset = Vector2.new(),
	ImageSize = UDim2.fromOffset(18, 18),
	ColorImage = false,
}

function TextButton:init(props)
	assert(typecheck(props))
end

function TextButton:render()
	local props = self.props
	local theme = props.Theme
	local default = props.Default
	local tooltip = props.Tooltip

	local textSize = GetTextSize({
		Font = Enum.Font.SourceSans,
		TextSize = 18,
		Text = props.Text,
	})

	local icon = props.Icon
	local width = props.Text ~= "" and textSize.X + 12 or 6
	if icon then
		width = width + 20
	end

	return Roact.createElement("TextButton", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(width, 26),
		Font = Enum.Font.SourceSans,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		TextSize = 18,
		Text = props.Text,
		BackgroundColor3 = getColor(function(c)
			return default and theme:GetColor(c.DialogMainButton)
				or theme:GetColor(c.Button)
		end),
		TextColor3 = getColor(function(c)
			return default and theme:GetColor(c.DialogMainButtonText)
				or theme:GetColor(c.ButtonText)
		end),
		[Roact.Event.Activated] = props.OnActivated,
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		Padding = icon and props.Text ~= "" and Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
		}),

		Icon = icon and Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			ImageColor3 = props.ColorImage and getColor(function(c)
				return theme:GetColor(c.BrightText)
			end) or Color3.new(1, 1, 1),
			Image = icon,
			Size = props.ImageSize,
			Position = props.Text ~= "" and UDim2.new(0, 3 + props.ImageOffset.X, 0.5, props.ImageOffset.Y)
				or UDim2.new(0.5, props.ImageOffset.X, 0.5, props.ImageOffset.Y),
			AnchorPoint = props.Text ~= "" and Vector2.new(1, 0.5)
				or Vector2.new(0.5, 0.5),
		}),

		Tooltip = tooltip and Roact.createElement(Tooltip, {
			Text = tooltip,
			Icon = icon,
		}),
	})
end

TextButton = RoactRodux.connect(function(state)
	return {
		Theme = state.PluginState.Theme,
	}
end)(TextButton)

return TextButton
