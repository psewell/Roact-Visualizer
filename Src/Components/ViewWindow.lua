--[[
	Viewing window for Roact-Visualizer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local DynamicRequire = require(main.Src.Util.DynamicRequire)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local getColor = require(main.Src.Util.getColor)

local ViewWindow = Roact.PureComponent:extend("ViewWindow")

function ViewWindow:init()
	self.targetRef = Roact.createRef()
	self.handle = nil
	self.ThirdPartyRoact = nil

	self.state = {
		target = nil,
	}
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
				local success, err = pcall(function()
					component, didCache = DynamicRequire.RequireWithCacheResult(rootModule)
				end)
				if component == nil or not success then
					component = nil
					warn(string.format("Roact-Visualizer:%s: %s", rootModule:GetFullName(), err))
					props.SetMessage({
						Text = "⚠️ Component encountered an error.\nCheck the Output window for details.",
						Time = 10,
					})
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
				local success, err = pcall(function()
					if self.handle then
						self.handle = self.ThirdPartyRoact.update(self.handle, tree)
					else
						self.handle = self.ThirdPartyRoact.mount(tree)
					end
				end)
				if not success then
					warn(string.format("Roact-Visualizer:%s: %s", props.RootModule:GetFullName(), err))
					props.SetMessage({
						Text = "❗ Component encountered an error.\nCheck the Output window for details.",
						Time = 10,
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

	return Roact.createElement("Frame", {
		ZIndex = 2,
		BackgroundColor3 = getColor(function(c)
			return theme:GetColor(c.Midlight)
		end),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, -8, 1, -38),
		Position = UDim2.new(0, 4, 1, -4),
		AnchorPoint = Vector2.new(0, 1),
		[Roact.Ref] = self.targetRef,
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
		RootModule = state.PluginState.RootModule,
		RoactInstall = state.PluginState.RoactInstall,
		ReloadCode = state.PluginState.ReloadCode,
		Theme = state.PluginState.Theme,
	}
end, function(dispatch)
	return {
		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(ViewWindow)

return ViewWindow
