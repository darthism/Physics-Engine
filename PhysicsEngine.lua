local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local PHYSICS_ENGINE_TAG = "ZerthPhysics"
local function MetersToStuds(Meters)
	return Meters * 3.571428
end
local GravityConstant = MetersToStuds(workspace.Gravity)
local function TrueDictionary(Array)
	local Copy = {}
	for _, Value in Array do
		Copy[Value] = true
	end
	return Copy
end
local function FindInArray(Array, Needle, Skip)
	local SkipShadow = 0
	local Index
	for I, Value in Array do
		if Value == Needle then 
			SkipShadow += 1
			if SkipShadow == Skip then
				Index = I
				break
			end
		end
	end
	return Index
end
local function RemoveNilStrings(Array)
	local ArrayClone = table.clone(Array)
	for Index, Character in ArrayClone do
		if Character == " " then
			table.remove(ArrayClone, Index)
		end
	end
	return ArrayClone
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
local PEMDAS = {
	"(",
	")",
	"^",
	"*",
	"/",
	"+",
	"-",
}
local PostTermSymbols = TrueDictionary({
	"*",
	"/",
	"+",
	"-",
})
local DerivativeMethods = {
	PowerRule = function(Segment)

	end,
	SumRule = function(Segment)

	end,
	DifferenceRule = function(Segment)

	end,
	ProductRule = function(Segment)

	end,
	QuotientRule = function(Segment)

	end,
}
local DerivativeSolver = {}
function DerivativeSolver.SolveDerivative(Equation)
	local function Solve()
		
	end
	local ReducedBuffer = ""
	local Stream = string.split(Equation, "")
	local ReverseStream = string.split(string.reverse(Equation), "")
	Stream = RemoveNilStrings(Stream)
	ReverseStream = RemoveNilStrings(ReverseStream)
	local IndicesType = {}
	for I, Token in Stream do
		if type(tonumber(Token)) == "number" or string.match(Token, "%a") then 
			continue
		end
		table.insert(IndicesType, table.find(PEMDAS, Token))
	end
	local ReverseStreamClone = {}
	for I = #ReverseStream, 1, -1 do
		local Token = ReverseStream[I]
		if not (tonumber(Token) ~= nil or string.match(Token, "%a")) then
			table.insert(ReverseStreamClone, 1, Token)
		end
	end
	local ParenthesisNest = 1
	local RightParenthesisLocations = {}
	for I, Type in IndicesType do
		if Type == 1 then
			local Index
			local FoundRightParenthesis = false
			local Flag = true
			for J = I + 1, #IndicesType do
				if IndicesType[J] == 1 then
					break
				elseif IndicesType[J] == 2 then
					if not FoundRightParenthesis then
						Index = J
						Flag = false	
					end
					break
				end
			end
			if Flag then
				local ReverseIndex = FindInArray(ReverseStreamClone, ")", ParenthesisNest)
				Index = #Stream - ReverseIndex
				ParenthesisNest += 1
			end
			RightParenthesisLocations[I] = Index
		end
	end
	print(IndicesType, RightParenthesisLocations)
	local IndicesTypeClone = table.clone(IndicesType)
	local Offset = 0
	local CurrentLeftIndex = 1
	for I = 1, #IndicesType do
		local Value = IndicesType[I]
		local IsPostTerm = PostTermSymbols[PEMDAS[Value]]
		local IsPostTermNext = PostTermSymbols[PEMDAS[IndicesType[I + 1]]]
		if Value == 1 or IsPostTerm then
			continue
		end
		if I == RightParenthesisLocations[CurrentLeftIndex] then
			table.insert(IndicesTypeClone, I + Offset, ")")
			CurrentLeftIndex += 1
			continue
		end
		if IndicesType[I + 1] ~= 1 and IsPostTermNext then
			table.insert(IndicesTypeClone, I + Offset, "(")
			Offset += 2
			table.insert(IndicesTypeClone, I + Offset, ")")
			Offset += 1
		end
	end
 	print(IndicesTypeClone)
	return Solve(ReducedBuffer)
end
function DerivativeSolver.PlugValue(Equation)
	local Stream = string.split(Equation, "")
	for I, Token in Stream do

	end
end
local Objects = {}
local Engine = {}
function Engine.AddTag(Object)
	CollectionService:AddTag(Object, PHYSICS_ENGINE_TAG)
end
local Movable = {}
Movable.__index = Movable 
function Movable.new(AccelerationEquation)
	print(DerivativeSolver.SolveDerivative("8x^3 + (5x^2 + 7x) + 3"))
	return setmetatable({
		Acceleration = Vector3.zero,
		Velocity = Vector3.zero,
		Position = Vector3.zero
	}, Movable)
end
function Movable:Start()
	
end
local Movables = TrueDictionary({
	"BasePart",
	"Model",
})
for _, Object in workspace:GetDescendants() do
	if Object:GetAttribute("CollectPhysics") and MultiIsA(Movables, Object) then
		CollectionService:AddTag(Object, PHYSICS_ENGINE_TAG)
	end
end
RunService.Heartbeat:Connect(function()
	for _, Object in Objects do
		
	end
end)
print(Movable.new())
return Engine
