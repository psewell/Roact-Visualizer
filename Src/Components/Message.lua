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
local TextBox = require(main.Src.Components.TextBox)
local Connection = require(main.Src.Components.Signal.Connection)
local getColor = require(main.Src.Util.getColor)

local Message = Roact.PureComponent:extend("Message")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Icon = t.optional(t.string),
	Text = t.string,
	Visible = t.boolean,
	Buttons = t.optional(t.table),
	TextBox = t.optional(t.strictInterface({
		InitialText = t.optional(t.string),
		PlaceholderText = t.optional(t.string),
		Validate = t.optional(t.callback),
		OnTextSubmitted = t.callback,
	})),
	VerticalAlignment = t.optional(t.enum(Enum.VerticalAlignment)),
	TextXAlignment = t.optional(t.enum(Enum.TextXAlignment)),
	ZIndex = t.optional(t.integer),
})

Message.defaultProps = {
	VerticalAlignment = Enum.VerticalAlignment.Center,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 5,
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
		currentText = nil,
		pluginGui = nil,
		absoluteSize = Vector2.new(),
	}

	self.sizeChanged = function(size)
		self:setState({
			absoluteSize = size or self.state.pluginGui.AbsoluteSize
		})
	end

	self.submitText = function()
		local currentText = self.state.currentText
		if currentText then
			self.props.TextBox.OnTextSubmitted(currentText)
		end
	end

	self.cancelText = function()
		self.props.TextBox.OnTextSubmitted(nil)
	end

	self.onTextChanged = function(newText, isValid)
		if isValid then
			self:setState({
				currentText = newText,
			})
		else
			self:setState({
				currentText = Roact.None,
			})
		end
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
	local textBox = props.TextBox
	local buttons = props.Buttons
	local state = self.state
	local absoluteSize = state.absoluteSize
	local pluginGui = state.pluginGui

	if textBox then
		buttons = {
			{
				Text = "Submit",
				Default = true,
				Enabled = state.currentText ~= nil,
				OnActivated = self.submitText,
			},
			{
				Text = "Cancel",
				OnActivated = self.cancelText,
			},
		}
	end

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
	if textBox then
		height = height + 26 + 8
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

			TextBox = textBox and Roact.createElement(TextBox, {
				CaptureFocus = true,
				InitialText = textBox.InitialText,
				PlaceholderText = textBox.PlaceholderText,
				Validate = textBox.Validate,
				OnTextChanged = self.onTextChanged,
				OnTextSubmitted = textBox.OnTextSubmitted,
				Position = UDim2.new(0.5, 0, 1, -34),
				AnchorPoint = Vector2.new(0.5, 1),
			}) or nil,

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
