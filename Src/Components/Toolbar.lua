--[[
	Toolbar controls at the top of the visualizer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)
local Reload = require(main.Src.Reducers.PluginState.Actions.Reload)
local TextButton = require(main.Src.Components.TextButton)
local getColor = require(main.Src.Util.getColor)

local Toolbar = Roact.PureComponent:extend("Toolbar")

function Toolbar:init()
	self.targetRef = Roact.createRef()
	self.handle = nil

	self.state = {
		target = nil,
	}
end

function Toolbar:didMount()
	self:setState({
		target = self.targetRef:getValue(),
	})
end

function Toolbar:render()
	local props = self.props
	local theme = props.Theme

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
			Padding = UDim.new(0, 4),
		}),

		SelectButton = Roact.createElement(TextButton, {
			LayoutOrder = 1,
			Text = "Select",
			Icon = "rbxassetid://2254538897",
			ImageOffset = Vector2.new(0, 2),
			OnActivated = props.StartSelecting,
		}),

		RefreshButton = Roact.createElement(TextButton, {
			LayoutOrder = 2,
			Text = "Reload",
			Icon = "rbxassetid://69395121",
			ImageOffset = Vector2.new(0, 1),
			OnActivated = props.Reload,
		}),
	})
end

Toolbar = RoactRodux.connect(function(state)
	return {
		SelectingModule = state.PluginState.SelectingModule,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		StartSelecting = function()
			dispatch(SetSelectingModule({
				SelectingModule = true,
			}))
		end,

		Reload = function()
			dispatch(Reload({}))
		end,
	}
end)(Toolbar)

return Toolbar
