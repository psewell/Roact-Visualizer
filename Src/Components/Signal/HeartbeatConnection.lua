--[[
	Calls the Update function every heartbeat.
	Uses a Lua signal to prevent lag that occurs from C++/Lua Boundary.
]]


local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local HeartbeatSignal = require(main.Packages.HeartbeatSignal)

local HeartbeatConnection = Roact.PureComponent:extend("HeartbeatConnection")

local t = require(main.Packages.t)
local typecheck = t.interface({
	Update = t.callback,
})

function HeartbeatConnection:init(props)
	assert(typecheck(props))
	self.connection = HeartbeatSignal:Connect(props.Update)
end

function HeartbeatConnection:render()
	return nil
end

function HeartbeatConnection:willUnmount()
	if self.connection then
		self.connection:Disconnect()
	end
end

return HeartbeatConnection
