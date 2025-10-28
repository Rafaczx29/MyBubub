-- =============================================================
-- PRECISE TIMING FISHING
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.2  -- Tetap 1.0 tapi dengan timing yang lebih precise

-- Nilai Casting (x, y)
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
-- OPTIMIZED TIMING FISHING
-- =============================================================

local function PreciseFishing()
    -- 1. Charge + Cast dengan timing yang tepat
    local chargeOk = pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    if not chargeOk then return false end
    
    local castOk, castResult = pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
    if not castOk then return false end
    
    -- 2. Tunggu BiteDelay dengan precise timing
    local waitStart = tick()
    
    -- TAPI mungkin temen lu pake cara ini:
    -- Dia mulai hitung waktu SEBELUM cast selesai, jadi lebih cepat
    while tick() - waitStart < BiteDelay do
        -- Biarkan game process
        task.wait()
    end
    
    -- 3. Begitu waktu tepat 1.0 detik, langsung tarik
    FishingCompletedEvent:FireServer()
    
    -- 4. Reset sequence yang SUPER CEPAT
    -- Mungkin dia ga pake CancelInputsFunc sama sekali?
    EquipToolEvent:FireServer(0)  -- Unequip
    task.wait(0.001)              -- Delay minimal
    EquipToolEvent:FireServer(ToolSlot) -- Re-equip
    
    return true
end

local function FastLoopFishing()
    print("=== PRECISE TIMING FISHING STARTED ===")
    
    task.wait(1)  -- Initial wait
    
    while true do
        local success = PreciseFishing()
        
        if not success then
            task.wait(0.01)  -- Short delay jika gagal
        end
        -- Jika sukses, langsung loop lagi tanpa delay tambahan
    end
end

-- Start
task.spawn(FastLoopFishing)
