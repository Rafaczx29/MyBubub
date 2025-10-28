-- =============================================================
-- DEBUG FISHING SCRIPT
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
-- DEBUG FUNCTION
-- =============================================================

local function DebugFishing()
    print("=== DEBUG START ===")
    
    -- 1. Equip tool
    print("1. Equipping tool...")
    EquipToolEvent:FireServer(ToolSlot)
    task.wait(0.5)
    
    -- 2. Charge rod
    print("2. Charging rod...")
    local chargeSuccess, chargeResult = pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    print("Charge result:", chargeSuccess, chargeResult)
    
    -- 3. Cast
    print("3. Casting...")
    local castSuccess, castResult = pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
    print("Cast result:", castSuccess, castResult)
    
    -- 4. Wait for bite
    print("4. Waiting for bite...")
    task.wait(BiteDelay)
    
    -- 5. Try to complete fishing
    print("5. Completing fishing...")
    local completeSuccess, completeError = pcall(FishingCompletedEvent.FireServer, FishingCompletedEvent)
    print("Complete result:", completeSuccess, completeError)
    
    -- 6. Check if we need parameters
    if not completeSuccess then
        print("Trying with parameters...")
        local success2, error2 = pcall(FishingCompletedEvent.FireServer, FishingCompletedEvent, true)
        print("With true:", success2, error2)
        
        local success3, error3 = pcall(FishingCompletedEvent.FireServer, FishingCompletedEvent, false)  
        print("With false:", success3, error3)
    end
    
    print("=== DEBUG END ===")
end

-- Run debug
DebugFishing()
