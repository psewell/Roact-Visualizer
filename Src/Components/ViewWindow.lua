--[[
	Viewing window for Roact-Visualizer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local DynamicRequire = require(main.Src.Util.DynamicRequire)
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
			print("Reloading Roact")
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
				name = rootModule:GetDebugId()
				component = DynamicRequire.Require(rootModule)
			end

			if name and component then
				local tree = self.ThirdPartyRoact.createElement(self.ThirdPartyRoact.Portal, {
					target = target,
				}, {
					[name] = component and self.ThirdPartyRoact.createElement(component) or nil,
				})
				if self.handle then
					self.handle = self.ThirdPartyRoact.update(self.handle, tree)
				else
					self.handle = self.ThirdPartyRoact.mount(tree)
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
end)(ViewWindow)

return ViewWindow
