--[[
	A menu for settings items.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginMenu = require(main.Src.Components.Base.PluginMenu)
local TextButton = require(main.Src.Components.TextButton)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local generateId = require(main.Packages.generateId)

local SetShowHelp = require(main.Src.Reducers.Settings.Thunks.SetShowHelp)
local SetSetting = require(main.Src.Reducers.Settings.Actions.SetSetting)
local SetInputAutoRefreshDelay = require(main.Src.Reducers.PluginState.Actions.SetInputAutoRefreshDelay)

local SettingsButton = Roact.PureComponent:extend("SettingsButton")
local t = require(main.Packages.t)
local typecheck = t.interface({
	LayoutOrder = t.integer,
	Tooltip = t.string,
})

SettingsButton.defaultProps = {
	LayoutOrder = 1,
}

local selectModesOrdered = {
	"FromExplorer", "FromList", "FromFile",
}

local selectModes = {
	FromExplorer = "Active Selection",
	FromList = "ModuleScript List",
	FromFile = "File Browser (Rojo)",
}

function SettingsButton:getCheckMark(condition)
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

function SettingsButton:init(initialProps)
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

	self.createSelectModeMenu = function(plugin)
		local props = self.props
		local selectMode = props.SelectMode
		local subMenu = plugin:CreatePluginMenu(generateId() .. "SelectMode", "Select Mode")
		subMenu.Name = "Default Select Mode"
		subMenu.Title = "Default Select Mode: " .. selectModes[selectMode]
		for _, key in ipairs(selectModesOrdered) do
			local displayText = selectModes[key]
			subMenu:AddNewAction(generateId() .. "SelectMode" .. key, displayText,
				self:getCheckMark(selectMode == key))
		end
		return subMenu
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

	self.createMenu = function(pluginMenu, plugin)
		local props = self.props
		pluginMenu:AddNewAction(generateId() .. "AutoRefresh", "Auto Update",
			self:getCheckMark(props.AutoRefresh))
		local refreshDelay
		if props.AutoRefreshDelay == 0 then
			refreshDelay = "Off"
		else
			refreshDelay = props.AutoRefreshDelay .. " sec"
		end
		pluginMenu:AddMenu(self.createDelayMenu(plugin, refreshDelay))
		pluginMenu:AddSeparator()
		pluginMenu:AddMenu(self.createSelectModeMenu(plugin))
		pluginMenu:AddSeparator()
		pluginMenu:AddNewAction(generateId() .. "ShowHelp", "Show Help",
			self:getCheckMark(props.ShowHelp))
		pluginMenu:AddNewAction(generateId() .. "MinimalAnimations", "Use Animations",
			self:getCheckMark(not props.MinimalAnimations))
		return pluginMenu
	end

	self.onItemSelected = function(item)
		if item then
			local props = self.props
			if (string.find(item.ActionId, "ShowHelp")) then
				props.SetShowHelp(not props.ShowHelp)
			elseif (string.find(item.ActionId, "MinimalAnimations")) then
				props.SetSetting({MinimalAnimations = not props.MinimalAnimations})
			elseif (string.find(item.ActionId, "SelectMode")) then
				local key = item.ActionId:gsub(".*SelectMode", "")
				props.SetSetting({SelectMode = key})
				self.props.SetMessage({
					Type = "SetSelectMode",
					Text = string.format("Set Select Mode to %s.", selectModes[key]),
					Time = 2,
				})
			elseif (string.find(item.ActionId, "AutoRefresh")) then
				props.SetSetting({
					AutoRefresh = not props.AutoRefresh,
				})
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
		self.hideMenu()
	end
end

function SettingsButton:render()
	local state = self.state
	local props = self.props
	local showMenu = state.showMenu

	return Roact.createFragment({
		Button = Roact.createElement(TextButton, {
			LayoutOrder = props.LayoutOrder,
			Text = "",
			Icon = "rbxassetid://7157376255",
			ImageSize = UDim2.fromOffset(20, 20),
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

SettingsButton = RoactRodux.connect(function(state)
	return {
		AutoRefresh = state.Settings.AutoRefresh,
		AutoRefreshDelay = state.Settings.AutoRefreshDelay,
		ShowHelp = state.Settings.ShowHelp,
		MinimalAnimations = state.Settings.MinimalAnimations,
		SelectMode = state.Settings.SelectMode,
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
end)(SettingsButton)

return SettingsButton
