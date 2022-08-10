local Ragdoll = false

local function Alert(Text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(Text)
    EndTextCommandDisplayHelp(0, false, false, 0)
end

local function FormatAlert(Controls)
    if Config.ToggleControls then
        local RagdollType = Config.RagdollType == 0 and "Relax" or "Balance"
        return string.format("Press ~%s~ to stand up\nRagdoll Type: %s\nSpeed: %i",
        IndexToName(Config.Controls.Toggle),RagdollType,Config.Speed)
    else
        return string.format("Press ~%s~ to stand up\nRagdoll Type: %s",
        IndexToName(Config.Controls.Toggle),RagdollType)
    end
end

local function RotationToDirection(Rotation)
    local X = math.rad(Rotation.x)
    local Z = math.rad(Rotation.z)
    local AbsCosX = math.abs(math.cos(X))
    return vector3(-math.sin(Z) * AbsCosX, math.cos(Z) * AbsCosX, math.sin(X))
end

local function RotationToOffsetDirection(Rotation)
    local X = -math.rad(Rotation.x)
    local Z = math.rad(Rotation.z)
    local AbsCosX = math.abs(math.cos(X))
    return vector3(math.cos(Z) * AbsCosX, math.sin(Z) * AbsCosX, math.sin(X))
end

local function InstructionalButtons(Scaleform)
    BeginScaleformMovieMethod(Scaleform,"CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(Scaleform,"SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    if Config.ToggleControls then
        BeginScaleformMovieMethod(Scaleform,"SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Right,true))
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Left,true))
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Backward,true))
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Forward,true))
        ScaleformMovieMethodAddParamPlayerNameString("Move")
        EndScaleformMovieMethod()

        --[[BeginScaleformMovieMethod(Scaleform,"SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(1)
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Right,true))
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Left,true))
        ScaleformMovieMethodAddParamPlayerNameString("Left/Right")
        EndScaleformMovieMethod()]]

        BeginScaleformMovieMethod(Scaleform,"SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(2)
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Down,true))
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Up,true))
        ScaleformMovieMethodAddParamPlayerNameString("Up/Down")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scaleform,"SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(3)
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Decrease,true))
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.Increase,true))
        ScaleformMovieMethodAddParamPlayerNameString("Increase/Decrease Speed")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(Scaleform,"SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(4)
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.RagdollType,true))
        ScaleformMovieMethodAddParamPlayerNameString("Change Ragdoll Type")
        EndScaleformMovieMethod()
    else
        BeginScaleformMovieMethod(Scaleform,"SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0,Config.Controls.RagdollType,true))
        ScaleformMovieMethodAddParamPlayerNameString("Change Ragdoll Type")
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(Scaleform,"DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(Scaleform,"SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    DrawScaleformMovieFullscreen(Scaleform,255,255,255,255,0)
end

Citizen.CreateThread(function()
    local Scaleform = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
    while not HasScaleformMovieLoaded(Scaleform) do
        Citizen.Wait(0)
    end
    
    while true do Citizen.Wait(0)
        local PlayerPed = PlayerPedId()
        
        if not CanPedRagdoll(PlayerPed) or IsEntityDead(PlayerPed) or IsPedInAnyVehicle(PlayerPed, true) then
            Ragdoll = false
        end

        if IsControlJustPressed(0, Config.Controls.Toggle) then
            if Ragdoll or not CanPedRagdoll(PlayerPed) or IsEntityDead(PlayerPed) or IsPedInAnyVehicle(PlayerPed, false) then
                Ragdoll = false
            else
                Ragdoll = true
            end
        end

        if Ragdoll then
            SetPedToRagdoll(PlayerPed, 1000, 1000, Config.RagdollType, true, true, false)
            if not IsHudHidden() or Config.HudHidden then
                InstructionalButtons(Scaleform)
                Alert(FormatAlert())
            end

            if Config.ToggleControls then
                local Rotation = GetGameplayCamRot()
                local Direction = RotationToDirection(Rotation)
                local OffsetDirection = RotationToOffsetDirection(Rotation)

                if IsControlPressed(0, Config.Controls.Forward) then
                    ApplyForceToEntity(PlayerPed,0,
                    Direction.x * Config.Speed,
                    Direction.y * Config.Speed,0.0,
                    0.0,0.0,0.0,0,false,true,true,false,true)
                end
                if IsControlPressed(0, Config.Controls.Left) then
                    ApplyForceToEntity(PlayerPed,0,
                    -OffsetDirection.x * Config.Speed,
                    -OffsetDirection.y * Config.Speed,0.0,
                    0.0,0.0,0.0,0,false,true,true,false,true)
                end
                if IsControlPressed(0, Config.Controls.Backward) then
                    ApplyForceToEntity(PlayerPed,0,
                    -Direction.x * Config.Speed,
                    -Direction.y * Config.Speed,0.0,
                    0.0,0.0,0.0,0,false,true,true,false,true)
                end
                if IsControlPressed(0, Config.Controls.Right) then
                    ApplyForceToEntity(PlayerPed,0,
                    OffsetDirection.x * Config.Speed,
                    OffsetDirection.y * Config.Speed,0.0,
                    0.0,0.0,0.0,0,false,true,true,false,true)
                end
                if IsControlPressed(0, Config.Controls.Up) then
                    ApplyForceToEntity(PlayerPed,0,0.0,0.0,Config.Speed,
                    0.0,0.0,0.0,0,false,true,true,false,true)
                end
                if IsControlPressed(0, Config.Controls.Down) then
                    ApplyForceToEntity(PlayerPed,0,0.0,0.0,-Config.Speed,
                    0.0,0.0,0.0,0,false,true,true,false,true)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do Citizen.Wait(0)
        if Ragdoll then
            if Config.ToggleControls then
                if IsControlPressed(0, Config.Controls.Increase) then
                    Config.Speed = Config.Speed ~= Config.MaxSpeed and
                    Config.Speed + Config.IndentIncrease or Config.MaxSpeed
                    Citizen.Wait(150)
                end
                if IsControlPressed(0, Config.Controls.Decrease) then
                    Config.Speed = Config.Speed ~= 0 and
                    Config.Speed - Config.IndentIncrease or 0
                    Citizen.Wait(150)
                end
            end
            if IsControlJustPressed(0, Config.Controls.RagdollType) then
                Config.RagdollType = Config.RagdollType == 0 and 2 or 0
            end
        end
    end
end)
