-- =============================================================
-- FAST FISH (BACK TO ORIGINAL BUT OPTIMIZED)
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.2      
local ChargeTime = 0.0     

local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE FUNCTIONS/EVENTS
-- =============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true):FindFirstChild("_Index", true):FindFirstChild("sleitnick_net@0.2.0", true):FindFirstChild("net", true)

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted") 
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs") 

-- =============================================================
-- OPTIMIZED ORIGINAL VERSION
-- =============================================================

local function EquipFishingRod(slot)
    EquipToolEvent:FireServer(slot)
end

local function CombinedChargeAndCast()
    local currentTime = tick()
    
    local args = {
        [1] = CastingX,
        [2] = CastingY,
        [3] = currentTime
    }
    
    local cast_success = false
    
    -- 1. Charge Pancing
    local charge_success, charge_result = pcall(function()
        return ChargeRodFunc:InvokeServer()
    end)
    
    if charge_success and charge_result == true then
        -- 2. Cast
        local request_success, request_result = pcall(function()
            return RequestMinigameFunc:InvokeServer(unpack(args))
        end)
        
        if request_success and (request_result == true or type(request_result) == "table") then
            cast_success = true
        end
    end
    
    return cast_success
end

local function CastAndReelFast()
    local cast_success = CombinedChargeAndCast()
    
    if cast_success then
        -- Tunggu BiteDelay
        wait(BiteDelay) 
        
        -- Tarik Pancing
        FishingCompletedEvent:FireServer()
        
        -- Reset Cooldown/Status
        pcall(function()
            CancelInputsFunc:InvokeServer() 
        end)
        EquipToolEvent:FireServer(0) 
        
        return true
    else
        return false
    end
end

-- =============================================================
-- EKSEKUSI UTAMA DENGAN OPTIMISASI LOOP
-- =============================================================

local function AutoFishFast()
    print("--- FAST FISHING SCRIPT DIMULAI ---")

    EquipFishingRod(ToolSlot)
    wait(0.3)  -- Reduced dari 1.0

    while true do 
        local isCastSuccessful = CastAndReelFast()
        
        if not isCastSuccessful then
            wait(0.005)  -- Very short delay on failure
        end
        -- No additional delay on success
    end
end

AutoFishFast()
