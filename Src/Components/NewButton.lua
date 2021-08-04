--[[
	A menu for selecting a new script.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginMenu = require(main.Src.Components.Base.PluginMenu)
local TextButton = require(main.Src.Components.TextButton)
local generateId = require(main.Packages.generateId)

local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)

local NewButton = Roact.PureComponent:extend("NewButton")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Text = t.string,
	Tooltip = t.string,
	LayoutOrder = t.optional(t.integer),
})

NewButton.defaultProps = {
	LayoutOrder = 1,
}

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

function NewButton:init(initialProps)
	assert(typecheck(initialProps))
	self.state = {
		showMenu = false,
	}

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

function NewButton:render()
	local state = self.state
	local props = self.props
	local showMenu = state.showMenu

	return Roact.createFragment({
		Button = Roact.createElement(TextButton, {
			LayoutOrder = props.LayoutOrder,
			Text = props.Text,
			Icon = "rbxassetid://7148404429",
			ImageSize = UDim2.fromOffset(20, 20),
			ImageOffset = Vector2.new(0, 1),
			ColorImage = true,
			Tooltip = props.Tooltip,
			OnActivated = self.showMenu,
		}),

		Menu = showMenu and Roact.createElement(PluginMenu, {
			CreateMenu = self.createMenu,
			OnItemSelected = self.onItemSelected,
		}),
	})
end

NewButton = RoactRodux.connect(function(state)
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
end)(NewButton)

return NewButton
