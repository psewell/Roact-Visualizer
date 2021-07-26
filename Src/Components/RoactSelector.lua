--[[
	Used to manually select Roact.
]]

local selectMessage = [[Select or drag Roact
from the Explorer]]

local Selection = game:GetService("Selection")

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginContext = require(main.Src.Contexts.PluginContext)
local Connection = require(main.Src.Components.Signal.Connection)
local Message = require(main.Src.Components.Message)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)

local SetRoactInstall = require(main.Src.Reducers.PluginState.Actions.SetRoactInstall)
local SetSelectingRoact = require(main.Src.Reducers.PluginState.Actions.SetSelectingRoact)

local RoactSelector = Roact.PureComponent:extend("RoactSelector")

function RoactSelector:init()
	self.dragArea = Roact.createRef()
	self.state = {
		pluginGui = nil,
		dragObject = nil,
		selectedObject = nil,
	}

	self.setModule = function()
		local items = Selection:Get()
		local item = items[1]
		if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
			self.props.SetRoactInstall(item)
			self.props.SetMessage({
				Type = "SelectedRoact",
				Text = string.format("Found Roact at %s", items[1]:GetFullName()),
				Time = 3,
			})
			Selection:Set({})
			self.props.StopSelecting()
		end
	end

	self.onDragDropped = function(dragData)
		if dragData.Sender == "Explorer" then
			local items = Selection:Get()
			if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
				local item = items[1]
				if item.Name == dragData.Data then
					self.setModule()
				end
			end
		end
	end

	self.onDragEntered = function(dragData)
		if dragData.Sender == "Explorer" then
			local items = Selection:Get()
			if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
				local item = items[1]
				if item.Name == dragData.Data then
					self:setState({
						dragObject = item,
					})
				end
			end
		end
	end

	self.onDragLeft = function(dragData)
		if dragData.Sender == "Explorer" then
			self:setState({
				dragObject = Roact.None,
			})
		end
	end

	self.onSelectionChanged = function()
		local items = Selection:Get()
		if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
			self:setState({
				selectedObject = items[1],
			})
			local plugin = PluginContext:get(self)
			plugin:StartDrag({
				Sender = "Explorer",
				MimeType = "text/plain",
				Data = items[1].Name,
				MouseIcon = "",
				DragIcon = "rbxassetid://2254538897",
				HotSpot = Vector2.new(-20, -20),
			})
		else
			self:setState({
				selectedObject = Roact.None,
			})
		end
	end
end

function RoactSelector:didMount()
	local dragArea = self.dragArea:getValue()
	self:setState({
		pluginGui = dragArea:FindFirstAncestorWhichIsA("PluginGui"),
	})
	self.onSelectionChanged()
end

function RoactSelector:didUpdate(lastProps)
	if self.props.SelectingRoact and not lastProps.SelectingRoact then
		self:setState({
			dragObject = Roact.None,
			selectedObject = Roact.None,
		})
		self.onSelectionChanged()
	end
end

function RoactSelector:render()
	local state = self.state
	local pluginGui = state.pluginGui
	local dragObject = state.dragObject
	local selectedObject = state.selectedObject
	local props = self.props
	local selecting = props.SelectingRoact

	local validSelectText
	if selectedObject then
		validSelectText = string.format("Current Selection:\n%s", selectedObject:GetFullName())
	else
		validSelectText = ""
	end

	return Roact.createFragment({
		DragArea = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3,
			BackgroundTransparency = 1,
			[Roact.Ref] = self.dragArea,
		}),

		Selecting = selecting and Roact.createFragment({
			DragDropped = pluginGui and selecting and Roact.createElement(Connection, {
				Signal = pluginGui.PluginDragDropped,
				Callback = self.onDragDropped,
			}) or nil,

			DragEntered = pluginGui and selecting and Roact.createElement(Connection, {
				Signal = pluginGui.PluginDragEntered,
				Callback = self.onDragEntered,
			}) or nil,

			DragLeft = pluginGui and selecting and Roact.createElement(Connection, {
				Signal = pluginGui.PluginDragLeft,
				Callback = self.onDragLeft,
			}) or nil,

			SelectionConnection = selecting and Roact.createElement(Connection, {
				Signal = Selection.SelectionChanged,
				Callback = self.onSelectionChanged,
			}),
		}),

		SelectingMessage = not dragObject and not selectedObject and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = selectMessage,
			Icon = "rbxasset://textures/AssetManager/explorer.png",
		}),

		DragObjectMessage = dragObject and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = dragObject and string.format("%s\nDrop to select", dragObject:GetFullName()) or "",
			Icon = "rbxassetid://2254538897",
		}),

		ValidSelectToast = selectedObject and not dragObject and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = validSelectText,
			Icon = "rbxassetid://2254538897",
			Buttons = {
				{
					Text = "Select",
					Default = true,
					OnActivated = self.setModule,
				},
			},
		}),
	})
end

RoactSelector = RoactRodux.connect(function(state)
	return {
		SelectingRoact = state.PluginState.SelectingRoact,
	}
end, function(dispatch)
	return {
		SetRoactInstall = function(module)
			dispatch(SetRoactInstall({
				RoactInstall = module,
			}))
		end,

		StopSelecting = function()
			dispatch(SetSelectingRoact({
				SelectingRoact = false,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(RoactSelector)

return RoactSelector
