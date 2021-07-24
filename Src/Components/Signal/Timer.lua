--[[
	Fires a callback when a timer is reached.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local HeartbeatConnection = require(script.Parent.HeartbeatConnection)

local Timer = Roact.PureComponent:extend("Timer")

local t = require(main.Packages.t)
local typecheck = t.interface({
	Time = t.number,
	Callback = t.callback,
})

function Timer:init(props)
	assert(typecheck(props))
	self.active = true
	local now = tick()
	local endTime = now + props.Time

	self.update = function()
		if props.Time < 0 then
			return
		end
		if self.active and tick() >= endTime then
			self.active = false
			props.Callback()
		end
	end
end

function Timer:render()
	return Roact.createElement(HeartbeatConnection, {
		Update = self.update,
	})
end

function Timer:willUnmount()
	self.active = false
end

return Timer
