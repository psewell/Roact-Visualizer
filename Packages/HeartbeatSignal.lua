local RunService = game:GetService("RunService")
local Signal = require(script.Parent.Signal)

local HeartbeatSignal = Signal.new()

RunService.Heartbeat:Connect(function(dt)
	local t = math.min(0.1, dt)
	HeartbeatSignal:Fire(t)
end)

return HeartbeatSignal
