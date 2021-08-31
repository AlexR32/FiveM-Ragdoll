local Ragdoll = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local Player = PlayerPedId()
        
        if not CanPedRagdoll(Player) or IsEntityDead(Player) or IsPedInAnyVehicle(Player, true) then
            Ragdoll = false
        end

        if IsControlJustPressed(0, Config.Controls.Toggle) then
            if Ragdoll or not CanPedRagdoll(Player) or IsEntityDead(Player) or IsPedInAnyVehicle(Player, false) then
                Ragdoll = false
            else
                Ragdoll = true
            end
        end

        if Ragdoll then
            SetPedToRagdoll(Player, 1000, 1000, Config.RagdollType, false, false, false)
            
            if not IsHudHidden() or not Config.HudHidden then
                if Config.ToggleControls then
                    Alert("Press ~" .. IndexToName(Config.Controls.Toggle) .. "~ to stand up\nSpeed: " .. Config.Speed .. "\nRagdoll Type: " .. Config.RagdollType)
                else
                    Alert("Press ~" .. IndexToName(Config.Controls.Toggle) .. "~ to stand up\nRagdoll Type: " .. Config.RagdollType)
                end

                InstructionalButtons()
            end

            if Config.ToggleControls then
                Rotation = GetGameplayCamRot()
                X,Y,Z = RotationToDirection(Rotation)
                OffX,OffY,OffZ = RotationToOffsetDirection(Rotation)

                if IsControlPressed(0, Config.Controls.Forward) then
                    ApplyForceToEntity(Player, 0, X * Config.Speed, Y * Config.Speed, 0, 0, 0, 0, 0, false, true, true, false, true)
                end
                if IsControlPressed(0, Config.Controls.Left) then
                    ApplyForceToEntity(Player, 0, -OffX * Config.Speed, -OffY * Config.Speed, 0, 0, 0, 0, 0, false, true, true, false, true)
                end
                if IsControlPressed(0, Config.Controls.Backward) then
                    ApplyForceToEntity(Player, 0, -X * Config.Speed, -Y * Config.Speed, 0, 0, 0, 0, 0, false, true, true, false, true)
                end
                if IsControlPressed(0, Config.Controls.Right) then
                    ApplyForceToEntity(Player, 0, OffX * Config.Speed, OffY * Config.Speed, 0, 0, 0, 0, 0, false, true, true, false, true)
                end
                if IsControlPressed(0, Config.Controls.Up) then
                    ApplyForceToEntity(Player, 0, 0, 0, Config.Speed + .0, 0, 0, 0, 0, false, true, true, false, true)
                end
                if IsControlPressed(0, Config.Controls.Down) then
                    ApplyForceToEntity(Player, 0, 0, 0, -Config.Speed + .0, 0, 0, 0, 0, false, true, true, false, true)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Ragdoll then
            if Config.ToggleControls then
                if IsControlPressed(0, Config.Controls.Increase) then
                    if Config.Speed ~= Config.MaxSpeed then
                        Config.Speed = Config.Speed + 5
                        Wait(100)
                    else
                        Config.Speed = Config.MaxSpeed
                    end
                end
                if IsControlPressed(0, Config.Controls.Decrease) then
                    if Config.Speed ~= 0 then
                        Config.Speed = Config.Speed - 5
                        Wait(100)
                    else
                        Config.Speed = 0
                    end
                end
            end
            if IsControlJustPressed(0, Config.Controls.RagdollType) then
                if Config.RagdollType == 2 then
                    Config.RagdollType = 0
                elseif Config.RagdollType == 0 then
                    Config.RagdollType = 2
                else
                    Config.RagdollType = 1
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

function InstructionalButtons()
    local Scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")

    while not HasScaleformMovieLoaded(Scale) do
        Wait(0)
    end

    if Config.ToggleControls then
        BeginScaleformMovieMethod(Scale, "CLEAR_ALL")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Backward, true))
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Forward, true))
        ScaleformMovieMethodAddParamPlayerNameString("Move")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(1)
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Right, true))
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Left, true))
        ScaleformMovieMethodAddParamPlayerNameString("Left/Right")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(2)
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Up, true))
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Down, true))
        ScaleformMovieMethodAddParamPlayerNameString("Up/Down")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(3)
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Increase, true))
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.Decrease, true))
        ScaleformMovieMethodAddParamPlayerNameString("Increase/Decrease Speed")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(4)
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.RagdollType, true))
        ScaleformMovieMethodAddParamPlayerNameString("Change Ragdoll Type")
        EndScaleformMovieMethod()
    else
        BeginScaleformMovieMethod(Scale, "CLEAR_ALL")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, Config.Controls.RagdollType, true))
        ScaleformMovieMethodAddParamPlayerNameString("Change Ragdoll Type")
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(Scale, "DRAW_INSTRUCTIONAL_BUTTONS")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()

    DrawScaleformMovieFullscreen(Scale, 255, 255, 255, 255, 0)
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

function RotationToOffsetDirection(Rotation)
    sZ = DegToRad(Rotation.z)
    sX = -DegToRad(Rotation.x)
    sNumber = math.abs(math.cos(sX))
    sX,sY,sZ = math.cos(sZ) * sNumber, math.sin(sZ) * Number, math.sin(sX)
    return sX,sY,sZ
end
