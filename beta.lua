-- =============================================================
-- INSTANT RECAST FISHING
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.0

local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE
-- =============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true):FindFirstChild("_Index", true):FindFirstChild("sleitnick_net@0.2.0", true):FindFirstChild("net", true)

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted") 
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs") 

-- =============================================================
-- INSTANT RECAST SYSTEM
-- =============================================================

local function FishingCycle()
    -- Charge + Cast
    pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
    
    -- Tunggu tanda (!)
    task.wait(BiteDelay)
    
    -- Tarik ikan
    FishingCompletedEvent:FireServer()
    
    -- LANGSUNG lempar lagi tanpa delay
    -- Tidak ada unequip/equip yang makan waktu
    pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
end

-- Start
task.wait(1)
EquipToolEvent:FireServer(ToolSlot)
task.wait(0.5)

while true do
    FishingCycle()
    -- Tidak ada delay tambahan di sini
end
