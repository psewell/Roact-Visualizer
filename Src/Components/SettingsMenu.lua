--[[
	A menu for settings items.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginMenu = require(main.Src.Components.Base.PluginMenu)
local generateId = require(main.Packages.generateId)

local SetShowHelp = require(main.Src.Reducers.Settings.Thunks.SetShowHelp)

local SettingsMenu = Roact.PureComponent:extend("SettingsMenu")
local t = require(main.Packages.t)
local typecheck = t.interface({
	OnClose = t.callback,
})

function SettingsMenu:getCheckMark(condition)
	if not condition then
		return nil
	end

	local props = self.props
	local theme = props.Theme
	local isDark = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground).G < 0.5
	if isDark then
		return "rbxassetid://7149083535"
	else
		return "rbxassetid://7149083668"
	end
end

function SettingsMenu:init(initialProps)
	assert(typecheck(initialProps))

	self.createMenu = function(pluginMenu)
		local props = self.props
		pluginMenu:AddNewAction(generateId(), "Show Help", self:getCheckMark(props.ShowHelp))
		return pluginMenu
	end

	self.onItemSelected = function(item)
		local props = self.props
		if item.Text == "Show Help" then
			props.SetShowHelp(not props.ShowHelp)
		end
		self.props.OnClose()
	end
end

function SettingsMenu:render()
	return Roact.createElement(PluginMenu, {
		CreateMenu = self.createMenu,
		OnItemSelected = self.onItemSelected,
	})
end

SettingsMenu = RoactRodux.connect(function(state)
	return {
		ShowHelp = state.Settings.ShowHelp,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		SetShowHelp = function(showHelp)
			dispatch(SetShowHelp(showHelp))
		end,
	}
end)(SettingsMenu)

return SettingsMenu
