local Ragdoll = false

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        local Player = PlayerPedId()
        
        if IsEntityDead(Player) or IsPedInAnyVehicle(Player, true) then
            Ragdoll = false
        end

        if IsControlJustReleased(0, Control.Toggle) then
            if Ragdoll or IsEntityDead(Player) or IsPedInAnyVehicle(Player, false) then
                Ragdoll = false
            else
                Ragdoll = true
            end
        end

        if Ragdoll then
            SetPedToRagdoll(Player, 1000, 1000, RagdollType, false, false, false)
            Alert("Press ~" .. IndexToName(Control.Toggle) .. "~ to stand up\nSpeed: " .. Speed .. "\nMode: " .. Mode)
            InstructionalButtons()
            Rotation = GetGameplayCamRot()
            X,Y,Z = RotationToDirection(Rotation)
            sX,sY,sZ = RotationToSideDirection(Rotation)
            if Debug then
                Citizen.Trace("Direction: " .. X .. ", " .. Y .. "\nSide Direction: " .. sX .. ", " .. sY .. "\n")
            end
            if IsControlPressed(0, Control.Forward) then
                ApplyForceToEntity(Player, 0, X * Speed, Y * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Control.Left) then
                ApplyForceToEntity(Player, 0, -sX * Speed, -sY * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Control.Backward) then
                ApplyForceToEntity(Player, 0, -X * Speed, -Y * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Control.Right) then
                ApplyForceToEntity(Player, 0, sX * Speed, sY * Speed, 0.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Control.Up) then
                ApplyForceToEntity(Player, 0, 0.0, 0.0, Speed, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
            if IsControlPressed(0, Control.Down) then
                ApplyForceToEntity(Player, 0, 0.0, 0.0, -Speed, 0.0, 0.0, 0.0, false, false, true, true, false, true)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Ragdoll then
            if Mode == 1 then
                RagdollType = 0
            elseif Mode == 2 then
                RagdollType = 2
            end

            if IsControlPressed(0, Control.Increase) then
                if Speed ~= 200.0 then
                    Speed = Speed + 5.0
                    Wait(100)
                else
                    Speed = 200.0
                end
            end
            if IsControlPressed(0, Control.Decrease) then
                if Speed ~= 0.0 then
                    Speed = Speed - 5.0
                    Wait(100)
                else
                    Speed = 0.0
                end
            end
            if IsControlJustPressed(0, Control.Mode) then
                if Mode ~= 2 then
                    Mode = Mode + 1
                else
                    Mode = 1
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

function Notification(Message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(Message)
    EndTextCommandThefeedPostTicker(false, false)
end

function InstructionalButtons()
    local Scaleform = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")

    while not HasScaleformMovieLoaded(Scaleform) do
        Wait(0)
    end

    BeginScaleformMovieMethod(Scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    ScaleformMovieMethodAddParamInt(-1)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(Scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Backward, true))
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Forward, true))
    ScaleformMovieMethodAddParamPlayerNameString("Move")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(Scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Right, true))
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Left, true))
    ScaleformMovieMethodAddParamPlayerNameString("Left/Right")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(Scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(2)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Up, true))
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Down, true))
    ScaleformMovieMethodAddParamPlayerNameString("Up/Down")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(Scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(3)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Increase, true))
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Decrease, true))
    ScaleformMovieMethodAddParamPlayerNameString("Increase/Decrease Speed")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(Scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(4)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Control.Mode, true))
    ScaleformMovieMethodAddParamPlayerNameString("Change Mode")
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
