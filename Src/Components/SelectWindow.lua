--[[
	A window which appears when there is no selected component.
	Provides a larger area to click to select a component.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginMenu = require(main.Src.Components.Base.PluginMenu)
local getColor = require(main.Src.Util.getColor)
local generateId = require(main.Packages.generateId)

local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)

local SelectWindow = Roact.PureComponent:extend("SelectWindow")

local selectModesOrdered = {
	"FromExplorer", "FromList", "FromFile",
}

local selectModes = {
	FromExplorer = "...from Active Selection",
	FromList = "...from ModuleScript List",
	FromFile = "...from File Browser (Rojo)",
}

local icons = {
	FromExplorer = "rbxasset://textures/AssetManager/explorer.png",
	FromList = "rbxassetid://5428232036",
	FromFile = "rbxassetid://1153635961",
}

function SelectWindow:init()
	self.state = {
		showMenu = false,
		hovered = false,
	}

	self.mouseEnter = function()
		self:setState({
			hovered = true,
		})
	end

	self.mouseLeave = function()
		self:setState({
			hovered = false,
		})
	end

	self.startSelecting = function()
		local props = self.props
		props.StartSelecting(props.SelectMode)
	end

	self.showMenu = function()
		self:setState({
			showMenu = true,
		})
	end

	self.hideMenu = function()
		self:setState({
			showMenu = false,
		})
	end

	self.createMenu = function(pluginMenu, plugin)
		for _, key in ipairs(selectModesOrdered) do
			local displayText = selectModes[key]
			local icon = icons[key]
			pluginMenu:AddNewAction(generateId() .. "SelectMode" .. key, displayText, icon)
		end
		return pluginMenu
	end

	self.onItemSelected = function(item)
		if item then
			local props = self.props
			local key = item.ActionId:gsub(".*SelectMode", "")
			props.StartSelecting(key)
		end
		self.hideMenu()
	end
end

function SelectWindow:render()
	local props = self.props
	local theme = props.Theme
	local state = self.state
	local hovered = state.hovered
	local showMenu = state.showMenu

	return Roact.createElement("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		BackgroundColor3 = getColor(function(c)
			local color = theme:GetColor(c.Midlight)
			if hovered then
				return color:Lerp(Color3.new(), 0.05)
			else
				return color
			end
		end),
		Text = "Click here to start",
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 18,
		TextColor3 = getColor(function(c)
			return theme:GetColor(c.DimmedText)
		end),
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
		[Roact.Event.Activated] = self.startSelecting,
		[Roact.Event.MouseButton2Click] = self.showMenu,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),

		Corners = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://7143280824",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(21, 21, 21, 21),
			SliceScale = 2,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Rotation = 45,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0, 0.666667, 1)),
					ColorSequenceKeypoint.new(0.191348, Color3.new(0.458824, 1, 0.956863)),
					ColorSequenceKeypoint.new(0.69218, Color3.new(1, 0.333333, 1)),
					ColorSequenceKeypoint.new(0.948419, Color3.new(0.666667, 0.666667, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 1, 1)),
				}),
			}),
		}),

		Menu = showMenu and Roact.createElement(PluginMenu, {
			CreateMenu = self.createMenu,
			OnItemSelected = self.onItemSelected,
		}),
	})
end

SelectWindow = RoactRodux.connect(function(state)
	return {
		SelectMode = state.Settings.SelectMode,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		StartSelecting = function(selectMode)
			dispatch(SetSelectingModule({
				SelectingModule = selectMode,
			}))
		end,
	}
end)(SelectWindow)

return SelectWindow
