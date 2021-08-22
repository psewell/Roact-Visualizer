--[[
	Viewing window for Roact-Visualizer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Cryo = require(main.Packages.Cryo)
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local DynamicRequire = require(main.Src.Util.DynamicRequire)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local Reload = require(main.Src.Reducers.PluginState.Actions.Reload)
local ComponentErrorReporter = require(main.Src.Util.ComponentErrorReporter)
local PluginContext = require(main.Src.Contexts.PluginContext)
local SelectWindow = require(main.Src.Components.SelectWindow)
local Connection = require(main.Src.Components.Signal.Connection)
local HeartbeatConnection = require(main.Src.Components.Signal.HeartbeatConnection)
local getColor = require(main.Src.Util.getColor)
local t = require(main.Packages.t)

local ViewWindow = Roact.PureComponent:extend("ViewWindow")

function ViewWindow:init()
	self.targetRef = Roact.createRef()
	self.handle = nil
	self.ThirdPartyRoact = nil
	self.nextUpdate = nil

	self.state = {
		connections = nil,
		target = nil,
	}

	self.closeModule = function()
		if self.props.RootModule then
			self.props.CloseModule()
			self.props.SetMessage({
				Type = "Closed",
				Text = "Component closed.",
				Time = 2,
			})
		end
	end

	self.onScriptUpdate = function()
		self.nextUpdate = tick() + self.props.AutoRefreshDelay
	end

	self.update = function()
		if self.nextUpdate and tick() > self.nextUpdate then
			self.nextUpdate = nil
			self.props.Reload()
		end
	end
end

function ViewWindow:didMount()
	self:setState({
		target = self.targetRef:getValue(),
	})
end

function ViewWindow:showErrorMessage(message, scriptInfo)
	local props = self.props
	props.SetMessage({
		Type = "ErrorMessage",
		Text = string.format("❗ %s Check the Output window for details.", message),
		Time = -1,
		Buttons = scriptInfo and {
			{
				Text = "Go to Error",
				OnActivated = function()
					local plugin = PluginContext:get(self)
					plugin:OpenScript(scriptInfo.Script, scriptInfo.LineNumber)
				end,
			},
			{
				Text = "Close",
				OnActivated = self.closeModule,
			},
		} or nil,
	})
end

function ViewWindow:updateTree(target)
	local props = self.props
	local rootScript = props.Root
	local propsScript = props.Props
	local plugin = PluginContext:get(self)

	local didLoadProps, propsResult, propsCached
	xpcall(function()
		propsResult, propsCached = DynamicRequire.RequireWithCacheResult(propsScript, {
			plugin = plugin,
			module = props.RootModule,
		})
		if propsResult and t.table(propsResult) then
			didLoadProps = true
		else
			ComponentErrorReporter(string.format("Roact-Visualizer: Props script did not return a valid table."))
			self:showErrorMessage("Props encountered an error during load.")
			didLoadProps = false
		end
	end, function(err)
		local traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
		ComponentErrorReporter(string.format("Roact-Visualizer: Props Error during Load:\n\t%s", traceback))
		self:showErrorMessage("Props encountered an error during load.", scriptInfo)
		didLoadProps = false
	end)

	if not didLoadProps then
		return false
	end

	local didLoadRoot, rootResult, rootCached
	xpcall(function()
		if not (propsCached) then
			-- Force the root to update, there is an update ahead of us
			rootCached = false
			rootResult = DynamicRequire.ForceRequire(rootScript, {
				Roact = self.ThirdPartyRoact,
				plugin = plugin,
				module = props.RootModule,
			})
		else
			rootResult, rootCached = DynamicRequire.RequireWithCacheResult(rootScript, {
				Roact = self.ThirdPartyRoact,
				plugin = plugin,
				module = props.RootModule,
			})
		end
		if rootResult and t.callback(rootResult) or t.table(rootResult) then
			didLoadRoot = true
		else
			ComponentErrorReporter(string.format("Roact-Visualizer: Tree script did not return a valid Roact component."))
			self:showErrorMessage("Tree encountered an error during load.")
			didLoadRoot = false
		end
	end, function(err)
		local traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
		ComponentErrorReporter(string.format("Roact-Visualizer: Tree Error during Load:\n\t%s", traceback))
		self:showErrorMessage("Tree encountered an error during load.", scriptInfo)
		didLoadRoot = false
	end)

	if not didLoadRoot then
		return false
	end

	if propsCached and rootCached then
		props.SetMessage({
			Type = "NoChanges",
			Text = "Tree not updated: No changes detected.",
			Time = 2,
		})
		return true
	end

	local tree = self.ThirdPartyRoact.createElement(self.ThirdPartyRoact.Portal, {
		target = target,
	}, {
		Root = self.ThirdPartyRoact.createElement(rootResult, Cryo.Dictionary.join(propsResult)),
	})

	local success, traceback, scriptInfo
	xpcall(function()
		if self.handle then
			self.handle = self.ThirdPartyRoact.update(self.handle, tree)
		else
			self.handle = self.ThirdPartyRoact.mount(tree)
		end
		success = true
	end, function(err)
		traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
		ComponentErrorReporter(string.format("Roact-Visualizer: Tree Error during Render:\n\t%s", traceback))
		success = false
	end)

	if success then
		if propsCached and not rootCached then
			props.SetMessage({
				Type = "TreeUpdated",
				Text = "Tree successfully updated.",
				Time = 2,
			})
		elseif rootCached and not propsCached then
			props.SetMessage({
				Type = "PropsUpdated",
				Text = "Props successfully updated.",
				Time = 2,
			})
		else
			props.SetMessage({
				Type = "TreeUpdated",
				Text = "Tree successfully updated.",
				Time = 2,
			})
		end
		return true
	else
		self:showErrorMessage("Tree encountered an error during render.", scriptInfo)
		return false
	end
end

function ViewWindow:unmountTree()
	local success, traceback, scriptInfo
	xpcall(function()
		if self.handle then
			self.ThirdPartyRoact.unmount(self.handle)
			self.handle = nil
		end
		success = true
	end, function(err)
		traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
		ComponentErrorReporter(string.format("Roact-Visualizer: Tree Error during unmount:\n\t%s", traceback))
		if self.state.target then
			self.state.target:ClearAllChildren()
		end
		self.handle = nil
		success = false
	end)
	if not success then
		self:showErrorMessage("Tree encountered an error during unmount.", scriptInfo)
	end
end

function ViewWindow:didUpdate(lastProps, lastState)
	local state = self.state
	local target = state.target
	local props = self.props

	if target ~= lastState.target or props.RootModule ~= lastProps.RootModule
		or props.ReloadCode ~= lastProps.ReloadCode then

		if self.ThirdPartyRoact == nil or props.RoactInstall ~= lastProps.RoactInstall then
			self.ThirdPartyRoact = DynamicRequire.RequireStaticModule(props.RoactInstall)

			if self.handle then
				self.ThirdPartyRoact.unmount(self.handle)
				self.handle = nil
			end
		end

		if target then
			local success = self:updateTree(target)
			if not success then
				self:unmountTree()
			end
		elseif self.handle then
			self:unmountTree()
		end

		self:makeConnections()
	end
end

function ViewWindow:makeConnections()
	local connections = {}
	local active = DynamicRequire.GetActiveModules()
	for id, item in pairs(active) do
		connections[id] = Roact.createElement(Connection, {
			Signal = item.Module:GetPropertyChangedSignal("Source"),
			Callback = self.onScriptUpdate,
		})
	end
	self:setState({
		connections = Roact.createFragment(connections),
	})
end

function ViewWindow:render()
	local props = self.props
	local theme = props.Theme
	local center = props.AlignCenter
	local state = self.state
	local connections = state.connections

	return Roact.createElement("Frame", {
		ZIndex = 2,
		BackgroundColor3 = getColor(function(c)
			return theme:GetColor(c.Midlight)
		end),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, -8, 1, -68),
		Position = UDim2.new(0, 4, 1, -34),
		AnchorPoint = Vector2.new(0, 1),
	}, {
		SelectWindow = props.RootModule == nil
			and Roact.createElement(SelectWindow) or nil,

		Center = props.RootModule and center and Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}) or nil,

		Target = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = center and UDim2.fromScale(0, 0) or UDim2.fromScale(1, 1),
			AutomaticSize = center and Enum.AutomaticSize.XY or Enum.AutomaticSize.None,
			[Roact.Ref] = self.targetRef,
		}),

		Connections = props.AutoRefresh and connections or nil,

		Update = props.AutoRefresh and Roact.createElement(HeartbeatConnection, {
			Update = self.update,
		}),

		CheckAncestry = props.RootModule and Roact.createElement(Connection, {
			Signal = props.RootModule.AncestryChanged,
			Callback = self.closeModule,
		}),
	})
end

function ViewWindow:willUnmount()
	self:unmountTree()
end

ViewWindow = RoactRodux.connect(function(state)
	return {
		Props = state.ScriptTemplates.Props,
		Root = state.ScriptTemplates.Root,
		AlignCenter = state.Settings.AlignCenter,
		AutoRefresh = state.Settings.AutoRefresh,
		AutoRefreshDelay = state.Settings.AutoRefreshDelay,
		RootModule = state.PluginState.RootModule,
		RoactInstall = state.PluginState.RoactInstall,
		ReloadCode = state.PluginState.ReloadCode,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		Reload = function()
			dispatch(Reload({}))
		end,

		CloseModule = function()
			dispatch(SetRootModule({
				RootModule = nil,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(ViewWindow)

return ViewWindow
