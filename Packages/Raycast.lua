--[[
	A helper function to Raycast,
	because the Raycast API is legit unusable
]]

local t = require(script.Parent.t)
local typecheck = t.strictInterface({
	Origin = t.Vector3,
	Direction = t.Vector3,
	Range = t.number,
	Whitelist = t.table,
})

return function(props)
	assert(typecheck(props))
	local ray = Ray.new(props.Origin, props.Direction.unit * props.Range)
	local part, position, normal, material
		= workspace:FindPartOnRayWithWhitelist(ray, props.Whitelist)

	return {
		Hit = (part ~= nil),
		Part = part,
		Position = position,
		Normal = normal,
		Material = material,
	}
end
