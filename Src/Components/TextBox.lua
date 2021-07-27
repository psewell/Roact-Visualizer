--[[
	A simple text box.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local getColor = require(main.Src.Util.getColor)

local TextBox = Roact.PureComponent:extend("TextBox")
local t = require(main.Packages.t)
local typecheck = t.interface({
	CaptureFocus = t.optional(t.boolean),
	ClearTextOnFocus = t.optional(t.boolean),
	InitialText = t.optional(t.string),
	PlaceholderText = t.optional(t.string),
	LayoutOrder = t.optional(t.integer),
	Position = t.optional(t.UDim2),
	AnchorPoint = t.optional(t.Vector2),
	Validate = t.optional(t.callback),
	OnTextChanged = t.callback,
	OnTextSubmitted = t.callback,
})

TextBox.defaultProps = {
	LayoutOrder = 1,
	Position = UDim2.fromScale(1, 1),
	AnchorPoint = Vector2.new(0, 0),
	ClearTextOnFocus = false,
}

function TextBox:init(props)
	assert(typecheck(props))
	self.textBox = Roact.createRef()
	self.state = {
		textIsValid = false,
		focused = false,
	}

	self.onTextChanged = function(rbx)
		if self.props.Validate then
			local isValid = self.props.Validate(rbx.Text)
			self.props.OnTextChanged(rbx.Text, isValid)
			if isValid ~= self.state.textIsValid then
				self:setState({
					textIsValid = isValid,
				})
			end
		end
	end

	self.onFocused = function()
		self:setState({
			focused = true,
		})
	end

	self.onFocusLost = function(rbx, enterPressed)
		self:setState({
			focused = false,
		})
		if enterPressed and self.state.textIsValid then
			self.props.OnTextSubmitted(rbx.Text)
		end
	end
end

function TextBox:didMount()
	local textBox = self.textBox:getValue()
	if self.props.InitialText then
		textBox.Text = self.props.InitialText
	end
	self.onTextChanged(textBox)
	if self.props.CaptureFocus then
		task.defer(function()
			textBox:CaptureFocus()
		end)
	end
end

function TextBox:render()
	local props = self.props
	local theme = props.Theme

	local state = self.state
	local textIsValid = state.textIsValid
	local focused = state.focused

	return Roact.createElement("TextBox", {
		LayoutOrder = props.LayoutOrder,
		Font = Enum.Font.SourceSans,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		TextSize = 18,
		Text = "",
		PlaceholderText = props.PlaceholderText,
		ClearTextOnFocus = props.ClearTextOnFocus,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 26),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = getColor(function(c, m)
			return theme:GetColor(c.InputFieldBackground)
		end),
		TextColor3 = getColor(function(c, m)
			return theme:GetColor(c.MainText)
		end),
		PlaceholderColor3 = getColor(function(c, m)
			return theme:GetColor(c.DimmedText)
		end),
		[Roact.Ref] = self.textBox,
		[Roact.Change.Text] = self.onTextChanged,
		[Roact.Event.Focused] = self.onFocused,
		[Roact.Event.FocusLost] = self.onFocusLost,
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 15),
			PaddingRight = UDim.new(0, 15),
		}),

		Stroke = Roact.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = getColor(function(c, m)
				if not textIsValid then
					return theme:GetColor(c.ErrorText)
				elseif focused then
					return theme:GetColor(c.InputFieldBorder, m.Selected)
				else
					return theme:GetColor(c.InputFieldBorder)
				end
			end),
		}),
	})
end

TextBox = RoactRodux.connect(function(state)
	return {
		Theme = state.PluginState.Theme,
	}
end)(TextBox)

return TextBox
