--[[ SUD HUB 2.0 NEON – 100% FUNCIONAL 2025 ]]
if _G.SudHubLoaded then return end _G.SudHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer

local State = {
    Speed = {Enabled = false, Value = 150, Original = 16},
    FlyJump = false,
    Noclip = false,
    AntiAFK = false,
    Invis = false,
    Char = nil,
    Hum = nil
}

local JumpConn, NoclipConn, AntiAFKConn, InvisLoop
local MobileBtn

-- CORES DO BOTÃO (salva com Rayfield)
local Colors = {
    Normal = Color3.fromRGB(45,45,45),
    Active = Color3.fromRGB(180,0,0),
    Border = Color3.fromRGB(0,255,255),
    Text = Color3.fromRGB(255,255,255)
}

local function Notify(t,m) pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=m,Duration=5}) end) end

local function GetChar()
    State.Char = Player.Character or Player.CharacterAdded:Wait()
    State.Hum = State.Char:FindFirstChildOfClass("Humanoid")
end
GetChar()

-- INVISIBILIDADE 100% FIXA
local function ApplyInvis()
    if not State.Char then return end
    for _, v in pairs(State.Char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.LocalTransparencyModifier = 1
        elseif v:IsA("Decal") then v.Transparency = 1 end
    end
    for _, acc in pairs(State.Char:GetChildren()) do
        if acc:IsA("Accessory") and acc:FindFirstChild("Handle") then acc.Handle.LocalTransparencyModifier = 1 end
    end
    local head = State.Char:FindFirstChild("Head")
    if head then for _, g in pairs(head:GetChildren()) do if g:IsA("BillboardGui") then g.Enabled = false end end end
end

local function ToggleInvis()
    State.Invis = not State.Invis
    if State.Invis then
        ApplyInvis()
        InvisLoop = RunService.Heartbeat:Connect(ApplyInvis)
        if MobileBtn then MobileBtn.Text = "VISIBLE"; MobileBtn.BackgroundColor3 = Colors.Active end
    else
        if InvisLoop then InvisLoop:Disconnect(); InvisLoop = nil end
        for _, v in pairs(State.Char:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            if v:IsA("Decal") then v.Transparency = 0 end
        end
        local head = State.Char:FindFirstChild("Head")
        if head then for _, g in pairs(head:GetChildren()) do if g:IsA("BillboardGui") then g.Enabled = true end end end
        if MobileBtn then MobileBtn.Text = "INVISIBLE"; MobileBtn.BackgroundColor3 = Colors.Normal end
    end
end

-- SPEED
local function ToggleSpeed(v)
    State.Speed.Enabled = v
    if v and State.Hum then
        State.Speed.Original = State.Hum.WalkSpeed
        State.Hum.WalkSpeed = State.Speed.Value
    elseif State.Hum then
        State.Hum.WalkSpeed = State.Speed.Original
    end
end

local function SetSpeed(v)
    State.Speed.Value = math.clamp(v,16,500)
    if State.Speed.Enabled and State.Hum then State.Hum.WalkSpeed = State.Speed.Value end
end

-- FLYJUMP + SPEED NO AR
local function ToggleFlyJump(v)
    State.FlyJump = v
    if v then
        JumpConn = UserInputService.JumpRequest:Connect(function()
            local hrp = State.Char and State.Char:FindFirstChild("HumanoidRootPart")
            if hrp and State.Hum then
                local speed = State.Speed.Enabled and State.Speed.Value or 16
                local dir = State.Hum.MoveDirection
                hrp.Velocity = Vector3.new(dir.X * speed * 1.8, 60, dir.Z * speed * 1.8)
            end
        end)
    else
        if JumpConn then JumpConn:Disconnect(); JumpConn = nil end
    end
end

-- NOCLIP INSTANTÂNEO
local function ToggleNoclip(v)
    State.Noclip = v
    if NoclipConn then NoclipConn:Disconnect() end
    if v and State.Char then
        NoclipConn = RunService.Stepped:Connect(function()
            for _, p in pairs(State.Char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end

-- ANTI-AFK
local function ToggleAntiAFK(v)
    State.AntiAFK = v
    if v then
        AntiAFKConn = Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    elseif AntiAFKConn then
        AntiAFKConn:Disconnect()
    end
end

-- RESPAWN SAFE
Player.CharacterAdded:Connect(function()
    task.wait(1.5)
    GetChar()
    if State.Speed.Enabled then ToggleSpeed(true) end
    if State.Invis then task.wait(0.5); ApplyInvis() end
end)

-- BOTÃO FORA + ARRASTÁVEL + CORES
if UserInputService.TouchEnabled then
    local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.ResetOnSpawn = false
    MobileBtn = Instance.new("TextButton", sg)
    MobileBtn.Size = UDim2.new(0,160,0,75)
    MobileBtn.Position = UDim2.new(0,20,0.65,0)
    MobileBtn.BackgroundColor3 = Colors.Normal
    MobileBtn.TextColor3 = Colors.Text
    MobileBtn.Text = "INVISIBLE"
    MobileBtn.Font = Enum.Font.GothamBold
    MobileBtn.TextSize = 20
    Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(0,18)
    local stroke = Instance.new("UIStroke", MobileBtn)
    stroke.Color = Colors.Border
    stroke.Thickness = 3.5

    local dragging = false
    local dragStart, startPos
    MobileBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = MobileBtn.Position end end)
    MobileBtn.InputChanged:Connect(function(i) if dragging then local delta = i.Position - dragStart; MobileBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    MobileBtn.InputEnded:Connect(function() dragging = false end)
    MobileBtn.MouseButton1Click:Connect(ToggleInvis)
end

-- RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name="SUD HUB 2.0 NEON", LoadingTitle="SUD HUB 2.0 NEON", LoadingSubtitle="100% Funcional 2025", ConfigurationSaving={Enabled=true, FolderName="SudHub", FileName="Neon2025"}})

local Main = Window:CreateTab("Hacks")
local Cores = Window:CreateTab("Cores Botão")

Main:CreateToggle({Name="Invisibilidade Total", Callback=ToggleInvis, Flag="Invis"})
Main:CreateToggle({Name="Speed Hack", Callback=ToggleSpeed, Flag="Speed"})
Main:CreateSlider({Name="Velocidade", Range={16,500}, Increment=5, CurrentValue=150, Callback=SetSpeed, Flag="SpeedVal"})
Main:CreateToggle({Name="FlyJump + Speed no Ar", Callback=ToggleFlyJump, Flag="FlyJump"})
Main:CreateToggle({Name="Noclip (Instantâneo)", Callback=ToggleNoclip, Flag="Noclip"})
Main:CreateToggle({Name="Anti-AFK", Callback=ToggleAntiAFK, Flag="AntiAFK"})
Main:CreateButton({Name="Infinity Yield", Callback=function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})

-- CORES
Cores:CreateColorPicker({Name="Cor Normal", Color=Colors.Normal, Callback=function(c) Colors.Normal=c if MobileBtn and not State.Invis then MobileBtn.BackgroundColor3=c end end})
Cores:CreateColorPicker({Name="Cor Ativa", Color=Colors.Active, Callback=function(c) Colors.Active=c if MobileBtn and State.Invis then MobileBtn.BackgroundColor3=c end end})
Cores:CreateColorPicker({Name="Cor da Borda", Color=Colors.Border, Callback=function(c) Colors.Border=c if MobileBtn then MobileBtn.UIStroke.Color=c end end})
Cores:CreateColorPicker({Name="Cor do Texto", Color=Colors.Text, Callback=function(c) Colors.Text=c if MobileBtn then MobileBtn.TextColor3=c end end})

Notify("SUD HUB 2.0 NEON","100% FUNCIONAL – tudo arrumado, rei!",8)
