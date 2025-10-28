-- =============================================================
-- HYPER FAST FISH - MULTI THREAD APPROACH
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.3

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
-- HYPER FAST FISHING - PRELOAD SYSTEM
-- =============================================================

local function HyperFastFishing()
    print("=== HYPER FAST FISHING STARTED ===")
    
    EquipToolEvent:FireServer(ToolSlot)
    task.wait(0.2)
    
    local consecutiveSuccess = 0
    local lastCastTime = 0
    
    while true do
        local cycleStart = tick()
        
        -- PRELOAD: Charge sebelum delay selesai
        if tick() - lastCastTime > BiteDelay - 0.5 then
            pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
        end
        
        -- Cast dengan timing yang aggressive
        local castSuccess = pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
        
        if castSuccess then
            -- Optimized wait dengan micro-adjustments
            local optimizedWait = BiteDelay - 0.08  -- More aggressive
            local waitStart = tick()
            
            while tick() - waitStart < optimizedWait do
                -- PRELOAD charge untuk next cycle
                if tick() - waitStart > optimizedWait - 0.3 then
                    pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
                end
                task.wait(0.001)
            end
            
            -- Instant completion
            FishingCompletedEvent:FireServer()
            
            -- Super fast reset
            task.wait(0.0005)  -- Ultra minimal
            pcall(CancelInputsFunc.InvokeServer, CancelInputsFunc)
            EquipToolEvent:FireServer(0)
            
            consecutiveSuccess = consecutiveSuccess + 1
            lastCastTime = tick()
            
            -- No delay between successful cycles
        else
            consecutiveSuccess = 0
            task.wait(0.005)
        end
        
        -- Auto-recalibrate every 15 success
        if consecutiveSuccess >= 15 then
            EquipToolEvent:FireServer(0)
            task.wait(0.03)
            EquipToolEvent:FireServer(ToolSlot)
            task.wait(0.1)
            consecutiveSuccess = 0
        end
    end
end

-- Start
task.spawn(HyperFastFishing)
