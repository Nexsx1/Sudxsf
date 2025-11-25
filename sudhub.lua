-- SUD HUB v2.5 NEON - VERSÃO FINAL 100% FUNCIONANDO
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local State = {
    Speed = {Enabled = false, Value = 100, Original = 16},
    InfiniteJump = {Enabled = false},
    Noclip = {Enabled = false},
    AntiAFK = {Enabled = false, Conn = nil},
    Invisibility = {Enabled = false, Loop = nil},
    Character = nil,
    Humanoid = nil
}
local JumpConnection

local function Notify(t, m, d)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = t or "Sud Hub", Text = m, Duration = d or 4}) end)
end

local function GetChar()
    State.Character = Player.Character or Player.CharacterAdded:Wait()
    State.Humanoid = State.Character:FindFirstChildOfClass("Humanoid")
end
GetChar()

-- INVISIBILIDADE 100% FIXA
local function ApplyInvisibility()
    if not State.Character then return end
    for _, v in pairs(State.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.LocalTransparencyModifier = 1
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
    for _, acc in pairs(State.Character:GetChildren()) do
        if acc:IsA("Accessory") and acc:FindFirstChild("Handle") then
            acc.Handle.LocalTransparencyModifier = 1
        end
    end
    local head = State.Character:FindFirstChild("Head")
    if head then
        for _, gui in pairs(head:GetChildren()) do
            if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                gui.Enabled = false
            end
        end
    end
end

local function ToggleInvisibility(v)
    State.Invisibility.Enabled = v
    if v then
        ApplyInvisibility()
        if State.Invisibility.Loop then State.Invisibility.Loop:Disconnect() end
        State.Invisibility.Loop = RunService.Heartbeat:Connect(ApplyInvisibility)
        Notify("Invisibilidade", "100% INVISÍVEL")
    else
        if State.Invisibility.Loop then State.Invisibility.Loop:Disconnect() State.Invisibility.Loop = nil end
        if State.Character then
            for _, v in pairs(State.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
                if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
            end
            local head = State.Character:FindFirstChild("Head")
            if head then
                for _, gui in pairs(head:GetChildren()) do
                    if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then gui.Enabled = true end
                end
            end
        end
        Notify("Invisibilidade", "VISÍVEL NOVAMENTE")
    end
end

-- SPEED
local function ToggleSpeed(v)
    State.Speed.Enabled = v
    if v and State.Humanoid then
        State.Speed.Original = State.Humanoid.WalkSpeed
        State.Humanoid.WalkSpeed = State.Speed.Value
    elseif State.Humanoid then
        State.Humanoid.WalkSpeed = State.Speed.Original
    end
end

local function SetSpeed(v)
    State.Speed.Value = math.clamp(v, 16, 500)
    if State.Speed.Enabled and State.Humanoid then State.Humanoid.WalkSpeed = State.Speed.Value end
end

-- FLYJUMP
local function ToggleInfiniteJump(v)
    State.InfiniteJump.Enabled = v
    if v then
        JumpConnection = UserInputService.JumpRequest:Connect(function()
            if State.Character and State.Character:FindFirstChild("HumanoidRootPart") then
                State.Character.HumanoidRootPart.Velocity = Vector3.new(0, 60, 0)
            end
        end)
    else
        if JumpConnection then JumpConnection:Disconnect() end
    end
end

-- NOCLIP
RunService.Stepped:Connect(function()
    if State.Noclip.Enabled and State.Character then
        for _, v in pairs(State.Character:GetDescendants()) do
            if v:IsA("BasePart") then pcall(function() v.CanCollide = false end) end
        end
    end
end)

-- ANTI-AFK
local function ToggleAntiAFK(v)
    State.AntiAFK.Enabled = v
    if v then
        State.AntiAFK.Conn = Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    elseif State.AntiAFK.Conn then
        State.AntiAFK.Conn:Disconnect()
    end
end

-- RESPAWN SAFE
Player.CharacterAdded:Connect(function()
    task.wait(1.5)
    GetChar()
    if State.Speed.Enabled then ToggleSpeed(true) end
    if State.Invisibility.Enabled then task.wait(0.5) ApplyInvisibility() end
end)

-- INFINITY YIELD
local function LoadIY()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    Notify("Infinity Yield", "CARREGADO!")
end

-- LOOP SPEED
RunService.Heartbeat:Connect(function()
    GetChar()
    if State.Speed.Enabled and State.Humanoid then State.Humanoid.WalkSpeed = State.Speed.Value end
end)

-- RAYFIELD UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Sud Hub v2.5 Neon",
    LoadingTitle = "Sud Hub v2.5",
    LoadingSubtitle = "Invis + FlyJump + Iy",
    ConfigurationSaving = {Enabled = true, FolderName = "SudHub", FileName = "Config"}
})

local Tab = Window:CreateTab("Hacks", 4483362458)
Tab:CreateToggle({Name = "Invisibilidade Total", Callback = ToggleInvisibility, Flag = "InvisT"})
Tab:CreateToggle({Name = "Speed Hack", Callback = ToggleSpeed, Flag = "SpeedT"})
Tab:CreateSlider({Name = "Velocidade", Range = {16,500}, Increment = 10, CurrentValue = 100, Callback = SetSpeed, Flag = "SpeedS"})
Tab:CreateToggle({Name = "FlyJump (Pula Infinito)", Callback = ToggleInfiniteJump, Flag = "FlyJumpT"})
Tab:CreateToggle({Name = "Noclip", Callback = function(v) State.Noclip.Enabled = v end, Flag = "NoclipT"})
Tab:CreateToggle({Name = "Anti-AFK", Callback = ToggleAntiAFK, Flag = "AntiAFKT"})
Tab:CreateButton({Name = "Respawn", Callback = function() Player.Character:BreakJoints() end})

local IyTab = Window:CreateTab("Infinity Yield", 4483362458)
IyTab:CreateButton({Name = "EXECUTAR INFINITY YIELD", Callback = LoadIY})

Notify("Sud Hub v2.5", "CARREGADO 100% - DOMINA GERAL!")
