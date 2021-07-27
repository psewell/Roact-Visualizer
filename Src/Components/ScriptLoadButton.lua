--[[
	Can be used to load and save scripts.
]]

local LOAD_GUID = "F3CA094D39E347D1BE40FD1279D2BA11"
local DELETE_GUID = "FECF29FF44CF42D9BA6F0037B6D17D98"
local SAVE_GUID = "DBC50B132F954D1BB7B27F91E9FBD5BE"

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginContext = require(main.Src.Contexts.PluginContext)
local PluginMenu = require(main.Src.Components.Base.PluginMenu)
local TextButton = require(main.Src.Components.TextButton)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local generateId = require(main.Packages.generateId)

local SetSavingScript = require(main.Src.Reducers.PluginState.Actions.SetSavingScript)
local SetDeletingScript = require(main.Src.Reducers.PluginState.Actions.SetDeletingScript)
local LoadScript = require(main.Src.Reducers.ScriptTemplates.Thunks.LoadScript)

local ScriptLoadButton = Roact.PureComponent:extend("ScriptLoadButton")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Text = t.string,
	Type = t.literal("RootScripts", "PropsScripts"),
	LayoutOrder = t.integer,
	Tooltip = t.string,
	OnActivated = t.callback,
})

local displayNames = {
	RootScripts = "Root",
	PropsScripts = "Props",
}

ScriptLoadButton.defaultProps = {
	LayoutOrder = 1,
}

function ScriptLoadButton:init(initialProps)
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

	self.createScriptMenu = function(name, plugin)
		local subMenu = plugin:CreatePluginMenu(generateId() .. name, name)
		subMenu.Name = name
		subMenu.Title = name
		subMenu:AddNewAction(generateId() .. LOAD_GUID .. name, "Load")
		subMenu:AddSeparator()
		subMenu:AddNewAction(generateId() .. DELETE_GUID .. name, "Delete")
		return subMenu
	end

	self.createMenu = function(pluginMenu, plugin)
		local props = self.props
		pluginMenu:AddNewAction(generateId() .. SAVE_GUID, "Save")
		if next(props.Scripts) ~= nil then
			pluginMenu:AddSeparator()
			for name, _ in pairs(props.Scripts) do
				pluginMenu:AddMenu(self.createScriptMenu(name, plugin))
			end
		end
		return pluginMenu
	end

	self.onItemSelected = function(item)
		if item then
			local props = self.props
			if (string.find(item.ActionId, SAVE_GUID)) then
				props.SetSavingScript(props.Type)
			elseif (string.find(item.ActionId, LOAD_GUID)) then
				local scriptName = string.gsub(item.ActionId, ".*" .. LOAD_GUID, "")
				props.LoadScript(scriptName, props.Type)
				local plugin = PluginContext:get(self)
				plugin:OpenScript(props.Module)
				props.SetMessage({
					Type = "LoadedScript",
					Text = string.format([[Loaded %s script "%s".]], displayNames[props.Type], scriptName),
					Time = 2,
				})
			elseif (string.find(item.ActionId, DELETE_GUID)) then
				local scriptName = string.gsub(item.ActionId, ".*" .. DELETE_GUID, "")
				props.SetDeletingScript({
					Name = scriptName,
					Type = props.Type,
				})
			end
		end
		self.hideMenu()
	end
end

function ScriptLoadButton:render()
	local state = self.state
	local props = self.props
	local showMenu = state.showMenu

	return Roact.createFragment({
		Button = Roact.createElement(TextButton, {
			LayoutOrder = props.LayoutOrder,
			Text = props.Text,
			Icon = props.Icon,
			ImageSize = UDim2.fromOffset(20, 20),
			ColorImage = true,
			Tooltip = props.Tooltip,
			OnActivated = props.OnActivated,
			OnRightClick = self.showMenu,
		}),

		Menu = showMenu and Roact.createElement(PluginMenu, {
			CreateMenu = self.createMenu,
			OnItemSelected = self.onItemSelected,
		}),
	})
end

ScriptLoadButton = RoactRodux.connect(function(state, props)
	return {
		Module = state.ScriptTemplates[displayNames[props.Type]],
		Scripts = state.SavedScripts[props.Type],
	}
end, function(dispatch)
	return {
		SetSavingScript = function(scriptType)
			dispatch(SetSavingScript({
				Type = scriptType,
			}))
		end,

		SetDeletingScript = function(props)
			dispatch(SetDeletingScript(props))
		end,

		LoadScript = function(name, scriptType)
			dispatch(LoadScript({
				Name = name,
				Container = scriptType,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(ScriptLoadButton)

return ScriptLoadButton
