-- =============================================================
-- CONTINUOUS FISHING SCRIPT
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.3

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
-- CONTINUOUS FISHING LOOP
-- =============================================================

local function OneFishingCycle()
    -- 1. Charge rod
    pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    
    -- 2. Cast
    pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
    
    -- 3. Wait for bite
    task.wait(BiteDelay)
    
    -- 4. Complete fishing
    FishingCompletedEvent:FireServer()
    
    -- 5. Reset
    pcall(CancelInputsFunc.InvokeServer, CancelInputsFunc)
    EquipToolEvent:FireServer(0)
    
    return true
end

-- MAIN LOOP
print("=== CONTINUOUS FISHING STARTED ===")

EquipToolEvent:FireServer(ToolSlot)
task.wait(0.5)

-- INI LOOP NYA - biar terus menerus
while true do
    local success = OneFishingCycle()
    
    if success then
        print("Fishing cycle completed, starting next...")
        task.wait(0.1)  -- Small delay before next cycle
    else
        print("Fishing failed, retrying...")
        task.wait(0.5)
    end
end
