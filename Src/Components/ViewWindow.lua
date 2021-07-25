--[[
	Viewing window for Roact-Visualizer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local DynamicRequire = require(main.Src.Util.DynamicRequire)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local ComponentErrorReporter = require(main.Src.Util.ComponentErrorReporter)
local PluginContext = require(main.Src.Contexts.PluginContext)
local SelectWindow = require(main.Src.Components.SelectWindow)
local getColor = require(main.Src.Util.getColor)

local ViewWindow = Roact.PureComponent:extend("ViewWindow")

function ViewWindow:init()
	self.targetRef = Roact.createRef()
	self.handle = nil
	self.ThirdPartyRoact = nil

	self.state = {
		target = nil,
	}

	self.closeModule = function()
		if self.props.RootModule then
			self.props.CloseModule()
			self.props.SetMessage({
				Text = "Component unloaded.",
				Time = 2,
			})
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

		if component == nil or not success then
			component = nil
			self:showErrorMessage("Component encountered an error during load.", scriptInfo)
		elseif not isValid then
			props.SetMessage({
				Text = "❗ This module is not a Roact component.",
				Time = 10,
			})
			props.CloseModule()
			return
		elseif props.RootModule ~= lastProps.RootModule then
			props.SetMessage({
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
		propsResult, propsCached = DynamicRequire.RequireWithCacheResult(propsScript)
		didLoadProps = true
	end, function(err)
		local traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
		ComponentErrorReporter(string.format("Roact-Visualizer: Props Error during Load:\n\t%s", traceback))
		didLoadProps = false
		self:showErrorMessage("Props encountered an error during load.", scriptInfo)
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
		didLoadRoot = true
	end, function(err)
		local traceback, scriptInfo = DynamicRequire.GetErrorTraceback(err, debug.traceback())
		ComponentErrorReporter(string.format("Roact-Visualizer: Root Error during Load:\n\t%s", traceback))
		didLoadRoot = false
		self:showErrorMessage("Root encountered an error during load.", scriptInfo)
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
				Text = "Component not updated: No changes detected.",
				Time = 2,
			})
		elseif moduleCached and propsCached and not rootCached then
			props.SetMessage({
				Text = "Root successfully updated.",
				Time = 2,
			})
		elseif moduleCached and rootCached and not propsCached then
			props.SetMessage({
				Text = "Props successfully updated.",
				Time = 2,
			})
		else
			props.SetMessage({
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
		or props.ReloadCode ~= lastProps.ReloadCode then

		if self.ThirdPartyRoact == nil or props.RoactInstall ~= lastProps.RoactInstall then
			self.ThirdPartyRoact = DynamicRequire.Require(props.RoactInstall)
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
	end
end

function ViewWindow:render()
	local props = self.props
	local theme = props.Theme
	local center = props.AlignCenter

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
		[Roact.Ref] = self.targetRef,
	}, {
		SelectWindow = props.RootModule == nil
			and Roact.createElement(SelectWindow),

		Center = props.RootModule and center and Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}) or nil,
	})
end

function ViewWindow:willUnmount()
	if self.handle then
		local props = self.props
		local ThirdPartyRoact = DynamicRequire.Require(props.RoactInstall)
		ThirdPartyRoact.unmount(self.handle)
		self.handle = nil
	end
end

ViewWindow = RoactRodux.connect(function(state)
	return {
		Props = state.ScriptTemplates.Props,
		Root = state.ScriptTemplates.Root,
		AlignCenter = state.PluginState.AlignCenter,
		RootModule = state.PluginState.RootModule,
		RoactInstall = state.PluginState.RoactInstall,
		ReloadCode = state.PluginState.ReloadCode,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
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
