--[[
	A menu for settings items.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginMenu = require(main.Src.Components.Base.PluginMenu)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local generateId = require(main.Packages.generateId)

local SetShowHelp = require(main.Src.Reducers.Settings.Thunks.SetShowHelp)
local SetSetting = require(main.Src.Reducers.Settings.Actions.SetSetting)
local SetInputAutoRefreshDelay = require(main.Src.Reducers.PluginState.Actions.SetInputAutoRefreshDelay)

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
		--pluginMenu:AddMenu(self.createSettingsMenu(plugin))
		return self.createSettingsMenu(plugin)
	end

	self.createDelayMenu = function(plugin, title)
		local props = self.props
		local subMenu = plugin:CreatePluginMenu(generateId() .. "Delay", "Delay")
		subMenu.Name = "Delay"
		subMenu.Title = "Auto Update Delay: " .. title
		subMenu:AddNewAction(generateId() .. "DelayOff", "Off",
			self:getCheckMark(props.AutoRefreshDelay == 0))
		subMenu:AddNewAction(generateId() .. "Delay05", "0.5 sec",
			self:getCheckMark(props.AutoRefreshDelay == 0.5))
		subMenu:AddNewAction(generateId() .. "Delay1", "1 sec",
			self:getCheckMark(props.AutoRefreshDelay == 1))
		subMenu:AddNewAction(generateId() .. "DelayCustom", "Custom...")
		return subMenu
	end

	self.createSettingsMenu = function(plugin)
		local props = self.props
		local subMenu = plugin:CreatePluginMenu(generateId() .. "Settings", "Settings",
			"rbxassetid://413362914")
		subMenu.Name = "Settings"
		subMenu:AddNewAction(generateId() .. "AutoRefresh", "Auto Update",
			self:getCheckMark(props.AutoRefresh))

		local refreshDelay
		if props.AutoRefreshDelay == 0 then
			refreshDelay = "Off"
		else
			refreshDelay = props.AutoRefreshDelay .. " sec"
		end
		subMenu:AddMenu(self.createDelayMenu(plugin, refreshDelay))
		subMenu:AddSeparator()
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
				props.SetSetting({MinimalAnimations = not props.MinimalAnimations})
			elseif (string.find(item.ActionId, "AutoRefresh")) then
				props.SetSetting({AutoRefresh = not props.AutoRefresh})
				self.props.SetMessage({
					Type = "SetAutoUpdateEnabled",
					Text = props.AutoRefresh and "Auto Update disabled."
						or "Auto Update enabled.",
					Time = 2,
				})
			elseif (string.find(item.ActionId, "DelayOff")) then
				props.SetSetting({AutoRefreshDelay = 0})
				self.props.SetMessage({
					Type = "SetAutoUpdateDelay",
					Text = "Auto Update delay set to 0 seconds.",
					Time = 2,
				})
			elseif (string.find(item.ActionId, "Delay05")) then
				props.SetSetting({AutoRefreshDelay = 0.5})
				self.props.SetMessage({
					Type = "SetAutoUpdateDelay",
					Text = "Auto Update delay set to 0.5 seconds.",
					Time = 2,
				})
			elseif (string.find(item.ActionId, "Delay1")) then
				props.SetSetting({AutoRefreshDelay = 1})
				self.props.SetMessage({
					Type = "SetAutoUpdateDelay",
					Text = "Auto Update delay set to 1 second.",
					Time = 2,
				})
			elseif (string.find(item.ActionId, "DelayCustom")) then
				props.InputAutoRefreshDelay()
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
		AutoRefreshDelay = state.Settings.AutoRefreshDelay,
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

		InputAutoRefreshDelay = function()
			dispatch(SetInputAutoRefreshDelay({
				InputAutoRefreshDelay = true,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(SettingsMenu)

return SettingsMenu
