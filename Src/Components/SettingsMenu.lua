--[[
	A menu for settings items.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginMenu = require(main.Src.Components.Base.PluginMenu)
local generateId = require(main.Packages.generateId)

local SetShowHelp = require(main.Src.Reducers.Settings.Thunks.SetShowHelp)
local SetSetting = require(main.Src.Reducers.Settings.Actions.SetSetting)

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

	self.createMenu = function(pluginMenu, plugin)
		pluginMenu:AddMenu(self.createSettingsMenu(plugin))
		return pluginMenu
	end

	self.createSettingsMenu = function(plugin)
		local props = self.props
		local subMenu = plugin:CreatePluginMenu(generateId() .. "Settings", "Settings",
			"rbxassetid://413362914")
		subMenu.Name = "Settings"
		subMenu:AddNewAction(generateId() .. "AutoRefresh", "Auto Refresh",
			self:getCheckMark(props.AutoRefresh))
		subMenu:AddNewAction(generateId() .. "ShowHelp", "Show Help",
			self:getCheckMark(props.ShowHelp))
		subMenu:AddNewAction(generateId() .. "MinimalAnimations", "Use Animations",
			self:getCheckMark(not props.MinimalAnimations))
		return subMenu
	end

	self.onItemSelected = function(item)
		if item then
			local props = self.props
			if (string.find(item.ActionId, "ShowHelp")) then
				props.SetShowHelp(not props.ShowHelp)
			elseif (string.find(item.ActionId, "MinimalAnimations")) then
				props.SetSetting({
					MinimalAnimations = not props.MinimalAnimations
				})
			elseif (string.find(item.ActionId, "AutoRefresh")) then
				props.SetSetting({
					AutoRefresh = not props.AutoRefresh
				})
			end
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
		AutoRefresh = state.Settings.AutoRefresh,
		ShowHelp = state.Settings.ShowHelp,
		MinimalAnimations = state.Settings.MinimalAnimations,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		SetShowHelp = function(showHelp)
			dispatch(SetShowHelp(showHelp))
		end,

		SetSetting = function(settings)
			dispatch(SetSetting(settings))
		end,
	}
end)(SettingsMenu)

return SettingsMenu
