--[[
	Viewing window for Roact-Visualizer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
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

function ViewWindow:loadComponent(lastProps)
	local props = self.props
	local name, component, didCache
	if props.RootModule then
		local rootModule = props.RootModule
		name = rootModule:GetDebugId()

		local success, traceback, scriptInfo
		xpcall(function()
			component, didCache = DynamicRequire.RequireWithCacheResult(rootModule)
			success = true
		end, function(err)
			traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
			ComponentErrorReporter(string.format("Roact-Visualizer: Component Error during Load:\n\t%s", traceback))
			success = false
		end)

		local isValid = component and (typeof(component) == "function" or component.render ~= nil) or false

		if not success or not isValid then
			if success and not isValid then
				ComponentErrorReporter(string.format("Roact-Visualizer: Current script did not return a valid Roact component."))
			end
			self:showErrorMessage("Component encountered an error during load.", scriptInfo)
			return
		elseif props.RootModule ~= lastProps.RootModule then
			props.SetMessage({
				Type = "LoadedComponent",
				Text = "Component successfully loaded.",
				Time = 2,
			})
		end
	end
	return name, component, didCache
end

function ViewWindow:updateTree(name, component, target, moduleCached)
	local props = self.props
	local rootScript = props.Root
	local propsScript = props.Props

	local didLoadProps, propsResult, propsCached
	xpcall(function()
		propsResult, propsCached = DynamicRequire.RequireWithCacheResult(propsScript, {})
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
		return
	end

	local element = self.ThirdPartyRoact.createElement(component, propsResult)

	local didLoadRoot, rootResult, rootCached
	xpcall(function()
		rootResult, rootCached = DynamicRequire.RequireWithCacheResult(rootScript, {
			Roact = self.ThirdPartyRoact,
			CurrentElement = element,
		})
		if not (moduleCached and propsCached) then
			-- Force the root to update, there is an update ahead of us
			rootResult = DynamicRequire.ForceRequire(rootScript, {
				Roact = self.ThirdPartyRoact,
				CurrentElement = element,
			})
		end
		if rootResult and rootResult.component ~= nil then
			didLoadRoot = true
		else
			ComponentErrorReporter(string.format("Roact-Visualizer: Root script did not return a valid Roact tree."))
			self:showErrorMessage("Root encountered an error during load.")
			didLoadRoot = false
		end
	end, function(err)
		local traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
		ComponentErrorReporter(string.format("Roact-Visualizer: Root Error during Load:\n\t%s", traceback))
		self:showErrorMessage("Root encountered an error during load.", scriptInfo)
		didLoadRoot = false
	end)

	if not didLoadRoot then
		return
	end

	local tree = self.ThirdPartyRoact.createElement(self.ThirdPartyRoact.Portal, {
		target = target,
	}, rootResult)

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
		ComponentErrorReporter(string.format("Roact-Visualizer: Component Error during Render:\n\t%s", traceback))
		success = false
	end)

	if success then
		if moduleCached and propsCached and rootCached then
			props.SetMessage({
				Type = "NoChanges",
				Text = "Component not updated: No changes detected.",
				Time = 2,
			})
		elseif moduleCached and propsCached and not rootCached then
			props.SetMessage({
				Type = "RootUpdated",
				Text = "Root successfully updated.",
				Time = 2,
			})
		elseif moduleCached and rootCached and not propsCached then
			props.SetMessage({
				Type = "PropsUpdated",
				Text = "Props successfully updated.",
				Time = 2,
			})
		else
			props.SetMessage({
				Type = "ComponentUpdated",
				Text = "Component successfully updated.",
				Time = 2,
			})
		end
	else
		self:showErrorMessage("Component encountered an error during render.", scriptInfo)
	end
end

function ViewWindow:didUpdate(lastProps, lastState)
	local state = self.state
	local target = state.target
	local props = self.props

	if target ~= lastState.target or props.RootModule ~= lastProps.RootModule
		or props.ReloadCode ~= lastProps.ReloadCode
		or (props.AutoRefresh and not lastProps.AutoRefresh) then

		if self.ThirdPartyRoact == nil or props.RoactInstall ~= lastProps.RoactInstall then
			self.ThirdPartyRoact = DynamicRequire.RequireStaticModule(props.RoactInstall)
			self.ThirdPartyRoact.setGlobalConfig({
				elementTracing = true,
			})

			if self.handle then
				self.ThirdPartyRoact.unmount(self.handle)
				self.handle = nil
			end
		end

		if target then
			local name, component, didCache = self:loadComponent(lastProps)
			if name and component then
				self:updateTree(name, component, target, didCache)
			elseif self.handle then
				self.ThirdPartyRoact.unmount(self.handle)
				self.handle = nil
			end
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

	return Roact.createElement("ScrollingFrame", {
		ZIndex = 2,
		BackgroundColor3 = getColor(function(c)
			return theme:GetColor(c.Midlight)
		end),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, -8, 1, -68),
		Position = UDim2.new(0, 4, 1, -34),
		AnchorPoint = Vector2.new(0, 1),
		CanvasSize = UDim2.new(1, -8, 1, -68),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = getColor(function(c)
			return theme:GetColor(c.ScrollBar)
		end),
	}, {
		SelectWindow = props.RootModule == nil
			and Roact.createElement(SelectWindow) or nil,

		Center = props.RootModule and center and Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}) or nil,

		Target = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
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
	if self.handle then
		local props = self.props
		local ThirdPartyRoact = DynamicRequire.RequireStaticModule(props.RoactInstall)
		ThirdPartyRoact.unmount(self.handle)
		self.handle = nil
	end
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
		Recording = state.PluginState.Recording,
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
