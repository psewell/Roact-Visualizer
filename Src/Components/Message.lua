--[[
	A message which pops up.
	Optionally can have buttons and an icon.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local GetTextSize = require(main.Packages.GetTextSize)
local GroupTweenJob = require(main.Src.Components.Base.GroupTweenJob)
local TextButton = require(main.Src.Components.TextButton)
local Connection = require(main.Src.Components.Signal.Connection)
local getColor = require(main.Src.Util.getColor)

local Message = Roact.PureComponent:extend("Message")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Icon = t.optional(t.string),
	Text = t.string,
	Visible = t.boolean,
	Buttons = t.optional(t.table),
	VerticalAlignment = t.optional(t.enum(Enum.VerticalAlignment)),
	TextXAlignment = t.optional(t.enum(Enum.TextXAlignment)),
	ZIndex = t.optional(t.integer),
})

Message.defaultProps = {
	VerticalAlignment = Enum.VerticalAlignment.Center,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 3,
}

local positions = {
	[Enum.VerticalAlignment.Center] = UDim2.fromScale(0.5, 0.5),
	[Enum.VerticalAlignment.Bottom] = UDim2.new(0.5, 0, 1, -20),
}

local anchorPoints = {
	[Enum.VerticalAlignment.Center] = Vector2.new(0.5, 0.5),
	[Enum.VerticalAlignment.Bottom] = Vector2.new(0.5, 1),
}

function Message:init(props)
	assert(typecheck(props))
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
end

function Message:didMount()
	local target = self.targetRef:getValue()
	local pluginGui = target:FindFirstAncestorWhichIsA("PluginGui")
	self:setState({
		pluginGui = pluginGui,
	})
	self.sizeChanged(pluginGui.AbsoluteSize)
end

function Message:render()
	local props = self.props
	local theme = props.Theme
	local icon = props.Icon
	local buttons = props.Buttons
	local state = self.state
	local absoluteSize = state.absoluteSize
	local pluginGui = state.pluginGui

	local textSize = GetTextSize({
		Font = Enum.Font.SourceSansSemibold,
		Text = props.Text,
		TextSize = 18,
		MaxWidth = math.min(320, absoluteSize.X - 16),
	})

	local height = textSize.Y + 16
	local width = textSize.X + 16
	local buttonComponents = {}
	if buttons then
		height = height + 26 + 8
		for i, button in ipairs(buttons) do
			buttonComponents[i] = Roact.createElement(TextButton, button)
		end
	end

	local itemType = buttons and "ImageButton" or "Frame"
	local autoButtonColor
	if buttons then
		autoButtonColor = false
	else
		autoButtonColor = nil
	end

	return Roact.createElement(GroupTweenJob, {
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		TweenIn = true,
		Time = 0.3,
		Offset = UDim2.fromOffset(0, 20),
		MinimalAnimations = props.MinimalAnimations,
	}, {
		SizeChanged = pluginGui and Roact.createElement(Connection, {
			Signal = pluginGui:GetPropertyChangedSignal("AbsoluteSize"),
			Callback = self.sizeChanged,
		}),

		[itemType] = Roact.createElement(itemType, {
			AutoButtonColor = autoButtonColor,
			ImageTransparency = itemType == "ImageButton" and 1 or nil,
			Size = UDim2.fromOffset(width, height),
			Position = positions[props.VerticalAlignment],
			AnchorPoint = anchorPoints[props.VerticalAlignment],
			BackgroundColor3 = getColor(function(c)
				return theme:GetColor(c.MainBackground)
			end),
			BorderSizePixel = 0,
			[Roact.Ref] = self.targetRef,
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
				TextXAlignment = props.TextXAlignment,
				Size = UDim2.fromOffset(textSize.X, textSize.Y),
				Position = UDim2.fromScale(0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0),
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

			ButtonBar = buttons and Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 26),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 8),
				}),

				Buttons = Roact.createFragment(buttonComponents),
			}),
		}),
	})
end

Message = RoactRodux.connect(function(state)
	return {
		MinimalAnimations = state.Settings.MinimalAnimations,
		Theme = state.PluginState.Theme,
	}
end)(Message)

return Message
