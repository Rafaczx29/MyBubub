-- =============================================================
-- ULTRA FAST FISH WITH TIMESTAMP OPTIMIZATION
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.3      
local ChargeTime = 0.0     

-- Nilai Casting (x, y)
local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE FUNCTIONS/EVENTS
-- =============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true):FindFirstChild("_Index", true):FindFirstChild("sleitnick_net@0.2.0", true):FindFirstChild("net", true)

if not NetService then 
    warn("Error: NetService tidak ditemukan. Script gagal berjalan.")
    return 
end

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted") 
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs") 

-- Cache untuk performa
local tick = tick
local pcall = pcall

-- =============================================================
-- TIMESTAMP MANIPULATION
-- =============================================================
local timestampOffset = 0
local lastServerTime = tick()

local function GetOptimizedTimestamp()
    -- Coba predict server time dengan offset
    return tick() + timestampOffset
end

local function CalibrateTimestamp()
    -- Simulasi kalibrasi timestamp (hati-hati dengan ini)
    local clientTime = tick()
    -- Di realitanya butuh sync dengan server, tapi kita simulate aja
    timestampOffset = -0.5 -- Sedikit lebih cepat dari client time
end

-- =============================================================
-- LOGIKA ULTRA FAST FISHING DENGAN TIMESTAMP OPTIMIZED
-- =============================================================

local function EquipFishingRod(slot)
    EquipToolEvent:FireServer(slot)
end

local function UltraCombinedChargeAndCast()
    local currentTime = GetOptimizedTimestamp()
    
    -- Charge dan Cast dalam satu sequence tanpa delay
    local charge_success = pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    
    if charge_success then
        -- Pakai optimized timestamp
        local cast_success, cast_result = pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, currentTime)
        
        -- Jika gagal, coba recalibrate timestamp
        if not cast_success then
            CalibrateTimestamp()
        end
        
        return cast_success and (cast_result == true or type(cast_result) == "table")
    end
    
    return false
end

local function UltraFastCastAndReel()
    if UltraCombinedChargeAndCast() then
        -- Tunggu BiteDelay yang tetap 1.3
        local waitStart = tick()
        
        -- OPTIMIZED WAIT: Kita bisa reduce BiteDelay sedikit
        local actualWait = BiteDelay - 0.1  -- Sedikit lebih cepat
        while tick() - waitStart < actualWait do
            task.wait(0.01)  -- Smaller intervals
        end
        
        -- Sequence cepat untuk completion
        FishingCompletedEvent:FireServer()
        
        -- Reset sequence dengan delay super minimal
        task.wait(0.001)
        
        -- Reset tools
        pcall(CancelInputsFunc.InvokeServer, CancelInputsFunc)
        EquipToolEvent:FireServer(0)
        
        return true
    end
    return false
end

-- =============================================================
-- EKSEKUSI UTAMA DENGAN TIMESTAMP OPTIMIZATION
-- =============================================================

local function UltraFastAutoFish()
    print("--- ULTRA FAST FISHING WITH TIMESTAMP OPTIMIZATION ---")
    print("BiteDelay:", BiteDelay)

    -- Kalibrasi timestamp awal
    CalibrateTimestamp()
    
    EquipFishingRod(ToolSlot)
    task.wait(0.3)

    local failCount = 0
    local successCount = 0
    local cycleCount = 0
    
    while true do
        cycleCount = cycleCount + 1
        
        -- Rekalibrasi setiap 20 cycle
        if cycleCount % 20 == 0 then
            CalibrateTimestamp()
        end
        
        local success = UltraFastCastAndReel()
        
        if success then
            successCount = successCount + 1
            failCount = 0
        else
            failCount = failCount + 1
            successCount = 0
            
            if failCount >= 2 then
                task.wait(0.01)
            else
                task.wait(0.002)
            end
        end
        
        -- Reset equipment setiap 10 success
        if successCount >= 10 then
            EquipToolEvent:FireServer(0)
            task.wait(0.05)
            EquipFishingRod(ToolSlot)
            successCount = 0
        end
    end
end

-- Start dengan spawn
task.spawn(UltraFastAutoFish)
