--[[
	A message which appears in the center of the screen.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local GetTextSize = require(main.Packages.GetTextSize)
local GroupTweenJob = require(main.Src.Components.Base.GroupTweenJob)
local getColor = require(main.Src.Util.getColor)

local Message = Roact.PureComponent:extend("Message")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Header = t.optional(t.string),
	Icon = t.optional(t.string),
	Text = t.string,
	Visible = t.boolean,
})

function Message:init(props)
	assert(typecheck(props))
end

function Message:render()
	local props = self.props
	local theme = props.Theme
	local icon = props.Icon

	local textSize = GetTextSize({
		Font = Enum.Font.SourceSansSemibold,
		Text = props.Text,
		TextSize = 18,
		MaxWidth = 320,
	})

	return Roact.createElement(GroupTweenJob, {
		ZIndex = 10,
		Visible = props.Visible,
		TweenIn = true,
		Time = 0.3,
		Offset = UDim2.fromOffset(0, 20),
	}, {
		Background = Roact.createElement("Frame", {
			Size = UDim2.fromOffset(textSize.X + 16, textSize.Y + 16),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = getColor(function(c)
				return theme:GetColor(c.MainBackground)
			end),
			BorderSizePixel = 0,
		}, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),

			Text = Roact.createElement("TextLabel", {
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.fromOffset(textSize.X, textSize.Y),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				Text = props.Text,
				TextWrapped = true,
				BackgroundTransparency = 1,
				TextColor3 = getColor(function(c)
					return theme:GetColor(c.MainText)
				end),
			}),

			Icon = icon and Roact.createElement("ImageLabel", {
				Image = icon,
				Size = UDim2.fromOffset(18, 18),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(-8, -8),
				BackgroundTransparency = 1,
			}),
		}),
	})
end

Message = RoactRodux.connect(function(state)
	return {
		Theme = state.PluginState.Theme,
	}
end)(Message)

return Message
