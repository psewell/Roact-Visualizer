--[[
	A helper function to create a Tween,
	because the TweenService API is legit unusable
]]

local TweenService = game:GetService("TweenService")

local t = require(script.Parent.t)
local typecheck = t.strictInterface({
	Instance = t.Instance,
	Props = t.table,
	EasingStyle = t.optional(t.EnumItem),
	EasingDirection = t.optional(t.EnumItem),
	Time = t.optional(t.number),
	RepeatCount = t.optional(t.integer),
	DelayTime = t.optional(t.number),
	Reverses = t.optional(t.boolean),
})

return function(props)
	assert(typecheck(props))
	local tweenInfo = TweenInfo.new(
		props.Time or 1,
		props.EasingStyle or Enum.EasingStyle.Quad,
		props.EasingDirection or Enum.EasingDirection.Out,
		props.RepeatCount or 0,
		props.Reverses or false,
		props.DelayTime or 0
	)
	return TweenService:Create(props.Instance, tweenInfo, props.Props)
end
