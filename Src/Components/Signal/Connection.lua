--[[
	Connects a function to a callback.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)

local Connection = Roact.PureComponent:extend("Connection")

local t = require(main.Packages.t)
local typecheck = t.interface({
	Signal = t.any,
	Callback = t.callback,
})

function Connection:init(props)
	assert(typecheck(props))
	self.connection = props.Signal:Connect(props.Callback)
end

function Connection:render()
	return nil
end

function Connection:willUnmount()
	if self.connection then
		self.connection:Disconnect()
	end
end

return Connection
