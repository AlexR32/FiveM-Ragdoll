local Ragdoll = false
local Debug = Config.Debug
local Speed = Config.Speed
local Mode = Config.Mode
--[[
local Control = {
    Toggle = 74,
    Forward = 32,
    Backward = 33,
    Left = 34,
    Right = 35,
    Up = 44,
    Down = 48,
    Increase = 45,
    Decrease = 23,
    Mode = 38
}
]]
local HelpControl = {
    {Button = Config.Control.Forward, Name = "Forward"},
	{Button = Config.Control.Backward, Name = "Backward"},
	{Button = Config.Control.Left, Name = "Left"},
	{Button = Config.Control.Right, Name = "Right"},
    {Button = Config.Control.Up, Name = "Upward"},
    {Button = Config.Control.Down, Name = "Downward"},
    {Button = Config.Control.Increase, Name = "Decrease Speed"},
    {Button = Config.Control.Decrease, Name = "Increase Speed"},
    {Button = Config.Control.Mode, Name = "Change Mode"},
}

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        local Player = PlayerPedId()

        if IsEntityDead(Player) or IsPedInAnyVehicle(Player, false) then
            Ragdoll = false
        end

        if IsControlJustReleased(0, Config.Control.Toggle) then
            if Ragdoll == true or IsEntityDead(Player) or IsPedInAnyVehicle(Player, false) then
                Ragdoll = false
            else
                Ragdoll = true
            end
        end

        if Ragdoll == true then
            SetPedToRagdoll(Player, 1000, 1000, Mode, false, false, false)
            --Alert("Press ~INPUT_VEH_HEADLIGHT~ to stand up\nSpeed: " .. Speed)
            Alert("Press ~" .. IndexToName(Config.Control.Toggle) .. "~ to stand up\nSpeed: " .. Speed .. "\nMode: " .. Mode)
            InstructionalButtons(HelpControl)
            Rotation = GetGameplayCamRot()
            X,Y,Z = RotationToDirection(Rotation)
            sX,sY,sZ = RotationToSideDirection(Rotation)
            if Debug then
                Citizen.Trace("Direction: " .. X .. ", " .. Y .. "\nSide Direction: " .. sX .. ", " .. sY .. "\n")
            end
            if IsControlPressed(0, Config.Control.Forward) then
                ApplyForceToEntity(Player, 0, X * Speed, Y * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Config.Control.Left) then
                ApplyForceToEntity(Player, 0, -sX * Speed, -sY * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Config.Control.Backward) then
                ApplyForceToEntity(Player, 0, -X * Speed, -Y * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Config.Control.Right) then
                ApplyForceToEntity(Player, 0, sX * Speed, sY * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Config.Control.Up) then
                ApplyForceToEntity(Player, 0, 0.0, 0.0, Speed, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Config.Control.Down) then
                ApplyForceToEntity(Player, 0, 0.0, 0.0, -Speed, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Ragdoll then
            if IsControlPressed(0, Config.Control.Increase) then
                if Speed ~= 200.0 then
                    Speed = Speed + 5.0
                    Wait(100)
                else
                    Speed = 200.0
                end
            end
            if IsControlPressed(0, Config.Control.Decrease) then
                if Speed ~= 0.0 then
                    Speed = Speed - 5.0
                    Wait(100)
                else
                    Speed = 0.0
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Ragdoll then
            if IsControlJustPressed(0, Config.Control.Mode) then
                if Mode ~= 3 then
                    Mode = Mode + 1
                else
                    Mode = 0
                end
            end
        end
    end
end)

function Alert(Text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(Text)
    EndTextCommandDisplayHelp(0, false, false, 0)
end

function InstructionalButtons(Button)
    local Scaleform = RequestScaleformMovie("instructional_buttons")

    while not HasScaleformMovieLoaded(Scaleform) do
        Wait(0)
    end

    BeginScaleformMovieMethod(Scaleform, "CLEAR_ALL")
    BeginScaleformMovieMethod(Scaleform, "TOGGLE_MOUSE_BUTTONS")
    ScaleformMovieMethodAddParamBool(0)
    EndScaleformMovieMethod()

    for ButtonIndex, ButtonValue in ipairs(Button) do
        BeginScaleformMovieMethod(Scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(ButtonIndex - 1)
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, ButtonValue.Button, 0))
        ScaleformMovieMethodAddParamPlayerNameString(ButtonValue.Name)
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(Scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    ScaleformMovieMethodAddParamInt(-1)
    EndScaleformMovieMethod()
    DrawScaleformMovieFullscreen(Scaleform, 255, 255, 255, 255)
end

function DegToRad(Degree)
    return Degree * 3.1415927 / 180.0
end

function RotationToDirection(Rotation)
    Z = DegToRad(Rotation.z)
    X = DegToRad(Rotation.x)
    Number = math.abs(math.cos(X))
    X,Y,Z = -math.sin(Z) * Number, math.cos(Z) * Number, math.sin(X)
    return X,Y,Z
end

function RotationToSideDirection(Rotation)
    sZ = DegToRad(Rotation.z)
    sX = -DegToRad(Rotation.x)
    sNumber = math.abs(math.cos(sX))
    sX,sY,sZ = math.cos(sZ) * sNumber, math.sin(sZ) * Number, math.sin(sX)
    return sX,sY,sZ
end
