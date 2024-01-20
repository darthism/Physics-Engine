local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage:WaitForChild("Signal"))
local PHYSICS_ENGINE_TAG = "ZerthPhysics"
local MARGIN = 1e-3
local Infinitesimal = 1e-6
local function MetersToStuds(Meters)
	return Meters * 3.571428
end
local function AngleBetween(A, B)
	return math.acos(A:Dot(B) / (A.Magnitude * B.Magnitude))
end
local function MakeVectorPositive(Vector)
	return Vector2.new(math.abs(Vector.X), math.abs(Vector.Y))
end
local function TrueDictionary(Array)
	local Copy = {}
	for _, Value in Array do
		Copy[Value] = true
	end
	return Copy
end
local function DeepCopy(Table)
	local Copy = {}
	for Key, Value in Table do
		if type(Value) == "table" then
			Value = DeepCopy(Value)
		end
		Copy[Key] = Value
	end
	return Copy
end
local function MultiIsA(Iterated, Object)
	local Flag = false
	for _, Type in Iterated do
		if Object:IsA(Type) then
			Flag = true
			break
		end
	end
	return Flag
end
local StructConstructor = {}
function StructConstructor.new(Default)
	return setmetatable({}, {
		__call = function(self, Attachment)
			return StructConstructor.Merge(DeepCopy(Default), Attachment)
		end,
	})
end
function StructConstructor.Merge(Attached, Attachment)
	local Merged = {}
	for Index, Value in Attached do
		Merged[Index] = Value
	end
	for Index, Value in Attachment do
		Merged[Index] = Value
	end
	return Merged
end
local Structs = {
	WorldConfigurations = StructConstructor.new({
		Gravity = MetersToStuds(9.81),
		Dimension = 3,
		WorldMass = 1E3,
	}),
	RigidBody = StructConstructor.new({
		Acceleration = Vector3.zero,
		Velocity = Vector3.zero,
		Position = Vector3.zero,
		Dimensions = Vector3.new(3, 3, 3),
		Model = Instance.new("Model"),
		Forces = {},
	}),
}
local function NewEngine(Configurations)
	local RigidBodies = {}
	local RigidBody = {}
	RigidBody.__index = RigidBody

	function RigidBody.new(Dictionary) -- Dictionary = {Model: Model, Dimensions: Vector3, Mass: number}
		local BodyMetaData = Structs.RigidBody(Dictionary)
		return setmetatable(StructConstructor.Merge(BodyMetaData, {
			Offset = Dictionary.Model:IsA("BasePart") and Dictionary.Model.Position or Dictionary.Model:GetPivot().Position,
			Signals = {
				ChangeVelocitySignX = Signal.NewEvent("ChangeVelocitySignX"),
				ChangeVelocitySignY = Signal.NewEvent("ChangeVelocitySignY"),
				ChangeVelocitySignZ = Signal.NewEvent("ChangeVelocitySignZ"),
			},
		}), RigidBody)
	end
	function RigidBody:SetPosition(NewPosition)
		self.Position = NewPosition
	end
	function RigidBody:InsertForce(Name, Force)
		self.Forces[Name] = Force
	end
	function RigidBody:AddGravity()
		self.Forces.Gravity = ((Vector3.yAxis * -Configurations.Gravity) * self.Mass * Configurations.WorldMass) / math.pow((self.Offset - Vector3.new(0, -1E2, 0)).Magnitude, 2)
	end
	function RigidBody:Run()
		table.insert(RigidBodies, self)
	end
	local MovableTypes = TrueDictionary({ 
		"BasePart",
		"Model",
	})
	for _, Object in workspace:GetDescendants() do
		if Object:GetAttribute("CollectPhysics"..tostring(Configurations.ID)) and MultiIsA(MovableTypes, Object) then
			CollectionService:AddTag(Object, PHYSICS_ENGINE_TAG)
		end
	end
	RunService.Heartbeat:Connect(function(DT)
		for _, Body in RigidBodies do
			local SumForce = Vector3.zero
			for _, Force in Body.Forces do
				SumForce += Force
			end
			Body.Acceleration = SumForce / Body.Mass
			Body.Velocity += Body.Acceleration * DT
			Body.Position += Body.Velocity * DT
			if Body.Velocity ~= Vector3.zero then
				for Index, Signal in Body.Signals do
					local Axis = Index:sub(-1)
					if math.abs(Body.Velocity[Axis]) < MARGIN then
						local NewVelocity = -math.sign(Body.Velocity[Axis]) * Infinitesimal
						Body.Velocity = Vector3.new(
							Axis == "X" and NewVelocity or Body.Velocity.X,
							Axis == "Y" and NewVelocity or Body.Velocity.Y,
							Axis == "Z" and NewVelocity or Body.Velocity.Z
						)
						Signal:Fire()
					end 
				end
			end
			if Body.Model:IsA("BasePart") then
				Body.Model.Position = Body.Position + Body.Offset
			elseif Body.Model:IsA("Model") then
				Body.Model:PivotTo(CFrame.new(Body.Position + Body.Offset))
			end
		end
	end)
	return {
		RigidBody = RigidBody, 
		ChangeGravity = function(NewGravity)
			Configurations.Gravity = NewGravity
		end,
	}
end
local Worlds = {}
Worlds.Tag = PHYSICS_ENGINE_TAG
function Worlds.CreateEngine(Name, Configurations)
	Configurations.ID = newproxy()
	Worlds[Name] = NewEngine(Structs.WorldConfigurations(Configurations))
	return Worlds[Name]
end
return Worlds
