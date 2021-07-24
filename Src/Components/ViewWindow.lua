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
			local name, component
			if props.RootModule then
				local rootModule = props.RootModule
				local didCache
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

				local isValid = typeof(component) == "function" or component.render ~= nil

				if component == nil or not success then
					component = nil
					props.SetMessage({
						Text = "❗ Component encountered an error during load. Check the Output window for details.",
						Time = -1,
						Buttons = scriptInfo and {
							{
								Text = "Go To Error",
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
				elseif didCache then
					props.SetMessage({
						Text = "Component not reloaded: No changes detected.",
						Time = 3,
					})
				else
					props.SetMessage({
						Text = "Component successfully reloaded.",
						Time = 2,
					})
				end
			end

			if name and component then
				local tree = self.ThirdPartyRoact.createElement(self.ThirdPartyRoact.Portal, {
					target = target,
				}, {
					[name] = component and self.ThirdPartyRoact.createElement(component) or nil,
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
					ComponentErrorReporter(string.format("Roact-Visualizer: Component Error during Render:\n\t%s", traceback))
					success = false
				end)
				if not success then
					props.SetMessage({
						Text = "❗ Component encountered an error during render. Check the Output window for details.",
						Time = -1,
						Buttons = scriptInfo and {
							{
								Text = "Go To Error",
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
