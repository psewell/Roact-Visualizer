--[[
	Toolbar controls at the bottom of the visualizer.
]]

local tooltips = {
	Select = [[Select a Component's ModuleScript for previewing]],
	Close = [[Close the current Component]],
	About = [[About this Plugin]],
}

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)
local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local TextButton = require(main.Src.Components.TextButton)
local Connection = require(main.Src.Components.Signal.Connection)
local GetTextSize = require(main.Packages.GetTextSize)
local getColor = require(main.Src.Util.getColor)

local BottomToolbar = Roact.PureComponent:extend("BottomToolbar")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Minified = t.optional(t.boolean),
})

BottomToolbar.defaultProps = {
	Minified = false,
}

function BottomToolbar:init(props)
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

	self.closeModule = function()
		if self.props.RootModule then
			self.props.CloseModule()
			self.props.SetMessage({
				Text = "Component unloaded.",
				Time = 2,
			})
		end
	end
end

function BottomToolbar:didMount()
	local target = self.targetRef:getValue()
	local pluginGui = target:FindFirstAncestorWhichIsA("PluginGui")
	self:setState({
		pluginGui = pluginGui,
	})
	self.sizeChanged(pluginGui.AbsoluteSize)
end

function BottomToolbar:render()
	local props = self.props
	local theme = props.Theme
	local minified = props.Minified
	local selecting = props.SelectingModule
	local rootModule = props.RootModule

	local state = self.state
	local pluginGui = self.state.pluginGui
	local absoluteSize = state.absoluteSize

	local text, textSize
	if rootModule then
		local largeSize = GetTextSize({
			Font = Enum.Font.SourceSans,
			TextSize = 18,
			Text = rootModule:GetFullName(),
		})
		local smallSize = GetTextSize({
			Font = Enum.Font.SourceSans,
			TextSize = 18,
			Text = rootModule.Name,
		})
		local textWidth
		if smallSize.X > (absoluteSize.X - 142) then
			textWidth = absoluteSize.X - 142
			text = rootModule.Name
		elseif largeSize.X > (absoluteSize.X - 142) then
			textWidth = smallSize.X
			text = rootModule.Name
		else
			textWidth = largeSize.X
			text = rootModule:GetFullName()
		end
		textSize = UDim2.new(0, textWidth, 1, 0)
	end

	return Roact.createElement("Frame", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 0, 30),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
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

		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
		}),

		SelectButton = Roact.createElement(TextButton, {
			LayoutOrder = 1,
			Text = minified and "" or "Select",
			Icon = "rbxassetid://2254538897",
			ImageOffset = Vector2.new(0, 2),
			Tooltip = not selecting and tooltips.Select or nil,
			OnActivated = props.StartSelecting,
		}),

		CloseButton = rootModule and Roact.createElement(TextButton, {
			Text = "",
			LayoutOrder = 2,
			Icon = "rbxasset://textures/StudioSharedUI/close.png",
			ImageSize = UDim2.fromOffset(16, 16),
			ColorImage = true,
			Tooltip = not selecting and tooltips.Close or nil,
			OnActivated = self.closeModule,
		}),

		CurrentModule = rootModule and Roact.createElement("TextLabel", {
			Text = text,
			Size = textSize,
			Font = Enum.Font.SourceSans,
			TextSize = 18,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 3,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			BackgroundTransparency = 1,
			TextColor3 = getColor(function(c)
				return theme:GetColor(c.MainText)
			end),
		}),

		IgnoreLayout = Roact.createElement("Folder", {}, {
			AboutButton = Roact.createElement(TextButton, {
				Text = "",
				Position = UDim2.fromScale(1, 0),
				AnchorPoint = Vector2.new(1, 0),
				Icon = "rbxassetid://7138347364",
				ImageSize = UDim2.fromOffset(24, 24),
				Tooltip = not selecting and tooltips.About or nil,
				OnActivated = function() end,
			}),
		}),
	})
end

BottomToolbar = RoactRodux.connect(function(state)
	return {
		RootModule = state.PluginState.RootModule,
		SelectingModule = state.PluginState.SelectingModule,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		CloseModule = function()
			dispatch(SetRootModule({
				RootModule = nil,
			}))
		end,

		StartSelecting = function()
			dispatch(SetSelectingModule({
				SelectingModule = true,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(BottomToolbar)

return BottomToolbar
