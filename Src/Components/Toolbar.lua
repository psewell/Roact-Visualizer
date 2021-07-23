--[[
	Toolbar controls at the top of the visualizer.
]]

local Selection = game:GetService("Selection")

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)
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
			return theme:GetColor(c.MainBackground)
		end),
		BorderColor3 = getColor(function(c)
			return theme:GetColor(c.Border)
		end),
		BorderSizePixel = 2,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),

		SelectButton = Roact.createElement("TextButton", {
			Size = UDim2.fromOffset(50, 26),
			Font = Enum.Font.SourceSansSemibold,
			TextSize = 18,
			Text = "Select",
			BackgroundColor3 = getColor(function(c)
				return theme:GetColor(c.Button)
			end),
			TextColor3 = getColor(function(c)
				return theme:GetColor(c.ButtonText)
			end),
			[Roact.Event.Activated] = props.StartSelecting,
		}, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})
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
			Selection:Set({})
			dispatch(SetSelectingModule({
				SelectingModule = true,
			}))
		end,
	}
end)(Toolbar)

return Toolbar
