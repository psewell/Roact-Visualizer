--[[
	A component which can tween its children's transparencies.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local Cryo = require(main.Packages.Cryo)
local CreateTween = require(main.Packages.CreateTween)

local Props = {}
Props.Frame = {"BackgroundTransparency",}
Props.ScrollingFrame = Cryo.List.join(Props.Frame, {"ScrollBarImageTransparency"})
Props.ImageLabel = Cryo.List.join(Props.Frame, {"ImageTransparency",})
Props.ImageButton = Cryo.List.join(Props.ImageLabel, {})
Props.ViewportFrame = Cryo.List.join(Props.ImageLabel, {})
Props.TextLabel = Cryo.List.join(Props.Frame, {
	"TextTransparency",
	"TextStrokeTransparency",
})
Props.TextButton = Cryo.List.join(Props.TextLabel, {})

local GroupTweenJob = Roact.PureComponent:extend("GroupTweenJob")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Time = t.number,
	Offset = t.optional(t.UDim2),
	Visible = t.boolean,
	TweenIn = t.optional(t.boolean),
	ZIndex = t.optional(t.integer),
	OnCompleted = t.optional(t.callback),
	MinimalAnimations = t.optional(t.boolean),
})

GroupTweenJob.defaultProps = {
	ZIndex = 1,
	Offset = UDim2.new(),
	MinimalAnimations = false,
}

function GroupTweenJob:init(props)
	assert(typecheck(props))
	self.catchRef = Roact.createRef()
	self.jobs = {}
	self.tweens = {}

	self.onCompleted = function(visible)
		if self.props.OnCompleted then
			self.props.OnCompleted(visible)
		end
	end
end

function GroupTweenJob:makeVisibleNow()
	if next(self.jobs) == nil then return end

	for instance, initialState in pairs(self.jobs) do
		for k, value in pairs(initialState) do
			instance[k] = value
		end
	end
	local catch = self.catchRef:getValue()
	if catch then
		catch.Position = UDim2.fromOffset(0, 0)
	end
end

function GroupTweenJob:forward()
	if next(self.jobs) == nil then return end

	if self.props.MinimalAnimations then
		self:makeInvisibleNow()
		self.onCompleted(false)
	end

	local tweens = {}
	for instance, initialState in pairs(self.jobs) do
		local propTable = {}
		for k, _ in pairs(initialState) do
			propTable[k] = 1
		end
		table.insert(tweens, CreateTween({
			Time = self.props.Time,
			EasingStyle = Enum.EasingStyle.Quad,
			EasingDirection = Enum.EasingDirection.Out,
			Instance = instance,
			Props = propTable,
		}))
	end
	if self.props.Offset then
		local catch = self.catchRef:getValue()
		table.insert(tweens, CreateTween({
			Time = self.props.Time,
			EasingStyle = Enum.EasingStyle.Quad,
			EasingDirection = Enum.EasingDirection.Out,
			Instance = catch,
			Props = {
				Position = self.props.Offset,
			},
		}))
	end
	for _, tween in ipairs(self.tweens) do
		tween:Cancel()
	end
	self.tweens = tweens
	self.tweens[1].Completed:Connect(function()
		self.onCompleted(false)
	end)
	for _, tween in ipairs(self.tweens) do
		tween:Play()
	end
end

function GroupTweenJob:makeInvisibleNow()
	if next(self.jobs) == nil then return end

	for instance, initialState in pairs(self.jobs) do
		for k, _ in pairs(initialState) do
			instance[k] = 1
		end
	end
	local catch = self.catchRef:getValue()
	if catch then
		catch.Position = self.props.Offset
	end
end

function GroupTweenJob:backward()
	if next(self.jobs) == nil then return end

	if self.props.MinimalAnimations then
		self:makeVisibleNow()
		self.onCompleted(true)
	end

	local tweens = {}
	for instance, initialState in pairs(self.jobs) do
		table.insert(tweens, CreateTween({
			Time = self.props.Time,
			EasingStyle = Enum.EasingStyle.Quad,
			EasingDirection = Enum.EasingDirection.Out,
			Instance = instance,
			Props = initialState,
		}))
	end
	if self.props.Offset then
		local catch = self.catchRef:getValue()
		table.insert(tweens, CreateTween({
			Time = self.props.Time,
			EasingStyle = Enum.EasingStyle.Back,
			EasingDirection = Enum.EasingDirection.Out,
			Instance = catch,
			Props = {
				Position = UDim2.new(),
			},
		}))
	end
	for _, tween in ipairs(self.tweens) do
		tween:Cancel()
	end
	self.tweens = tweens
	self.tweens[1].Completed:Connect(function()
		self.onCompleted(true)
	end)
	for _, tween in ipairs(self.tweens) do
		tween:Play()
	end
end

function GroupTweenJob:getInitialState(instance)
	for className, propTypes in pairs(Props) do
		if instance:IsA(className) then
			local values = {}
			for _, propType in ipairs(propTypes) do
				values[propType] = instance[propType]
			end
			if next(values) ~= nil then
				return values
			end
		end
	end
	return nil
end

function GroupTweenJob:didMount()
	if self and self.catchRef and not self.unmounted then
		local catch = self.catchRef:getValue()
		local jobs = {}
		for _, child in ipairs(catch:GetDescendants()) do
			local initialState = self:getInitialState(child)
			if initialState then
				jobs[child] = initialState
			end
		end
		self.jobs = jobs
		if not self.props.Visible then
			self:makeInvisibleNow()
		elseif self.props.TweenIn then
			self:makeInvisibleNow()
			self:backward()
		end
	end
end

function GroupTweenJob:didUpdate(lastProps)
	if lastProps.Visible ~= self.props.Visible then
		if self.props.Visible then
			self:backward()
		else
			self:forward()
		end
	end
end

function GroupTweenJob:render()
	return Roact.createElement("Frame", {
		ZIndex = self.props.ZIndex,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Roact.Ref] = self.catchRef,
	}, self.props[Roact.Children])
end

function GroupTweenJob:willUnmount()
	self.unmounted = true
end

return GroupTweenJob
