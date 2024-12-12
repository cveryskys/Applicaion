--!strict
--littlekitti


local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Shared.Packages
local Observer = require(Packages.Observer)
local Warp = require(Packages.Warp)

local Library = ReplicatedStorage.Shared.Lib

require(Library.Ragdoll)

local ServerLibrary = script.Parent.Parent.Parent.Library
local BuildRagdoll = require(ServerLibrary.BuildRagdoll)

local ragdollEvent = Warp.Server("RagdollEvent")

function RagdollPlayer(character: any, duration: number)
	if not character then
		return
	end
	if character:GetAttribute("Ragdolled") then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)

	local id = HttpService:GenerateGUID(false)
	character:SetAttribute("RagdollId", id)

	character:SetAttribute("Ragdolled", true)
	if player then
		ragdollEvent:Fire(true, player, true)
	end
	local humanoid = character:WaitForChild("Humanoid", 180)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	task.delay(duration, function()
		if character:GetAttribute("RagdollId") == id then
			UnragdollPlayer(character)
		end
	end)
end

function UnragdollPlayer(character: any): ()
	if not character then
		return
	end
	if not character:GetAttribute("Ragdolled") then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)

	character:SetAttribute("Ragdolled", false)
	if player then
		ragdollEvent:Fire(true, player, false)
	end
	local humanoid = character:WaitForChild("Humanoid", 180)
	if humanoid.Health > 1 then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function OnCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 180) :: Humanoid
	BuildRagdoll(humanoid)

	return function() end
end

Observer.observeCharacter(OnCharacterAdded)

return {
	RagdollPlayer = RagdollPlayer,
	UnragdollPlayer = UnragdollPlayer,
}
