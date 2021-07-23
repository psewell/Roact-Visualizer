--[[
	A simple text button.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local GetTextSize = require(main.Packages.GetTextSize)
local getColor = require(main.Src.Util.getColor)

local TextButton = Roact.PureComponent:extend("TextButton")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Text = t.optional(t.string),
	OnActivated = t.callback,
	Icon = t.optional(t.string),
	Default = t.optional(t.boolean),
	LayoutOrder = t.optional(t.integer),
	ImageOffset = t.optional(t.Vector2),
})

TextButton.defaultProps = {
	Text = "",
	Default = false,
	LayoutOrder = 1,
	ImageOffset = Vector2.new(),
}

function TextButton:init(props)
	assert(typecheck(props))
end

function TextButton:render()
	local props = self.props
	local theme = props.Theme
	local default = props.Default

	local textSize = GetTextSize({
		Font = Enum.Font.SourceSans,
		TextSize = 18,
		Text = props.Text,
	})

	local icon = props.Icon
	local width = textSize.X + 12
	if icon then
		width = width + 20
	end

	return Roact.createElement("TextButton", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(width, 26),
		Font = Enum.Font.SourceSans,
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
			Image = icon,
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 3 + props.ImageOffset.X, 0.5, props.ImageOffset.Y),
			AnchorPoint = Vector2.new(1, 0.5),
		}),
	})
end

TextButton = RoactRodux.connect(function(state)
	return {
		Theme = state.PluginState.Theme,
	}
end)(TextButton)

return TextButton
