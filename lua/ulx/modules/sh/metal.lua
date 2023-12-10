-- Required ULX modules
local CATEGORY_NAME = "Fun"
local ulx_command = "ulx metal"


-- Function to check if the player is moving
local function isPlayerMoving(ply)
    return ply:GetVelocity():Length() > 0
end

-- Function to apply screen shake effect to nearby players
local function applyShakeEffect(metalPly)
    local radius = 500  -- Define the radius of effect
    local intensity = 5  -- Intensity of the screen shake
    local duration = 0.5  -- Duration of the screen shake

    for _, ply in ipairs(player.GetAll()) do
        if ply != metalPly and ply:GetPos():Distance(metalPly:GetPos()) <= radius then
            util.ScreenShake(ply:GetPos(), intensity, 3, duration, radius)
        end
    end
end

local function playMetalFootstepSound(metalPly)
    local soundPath = "ulx_custom/clang_short.wav"  -- Replace with your sound file path
    local pitch = math.random(90, 110)  -- Random pitch between 90% and 110%

    metalPly:EmitSound(soundPath, 85, pitch)
end


-- Define the command
function ulx.metal(calling_ply, target_plys, duration, should_revoke)
    for _, ply in ipairs(target_plys) do
        if ply:GetNWBool("IsMetal") and not should_revoke then
            ULib.tsayError(calling_ply, ply:Nick() .. " is already metallic!", true)
            return
        end
        
        if duration <= 0 then
            ULib.tsayError(calling_ply, "please set a valid duration!",true)
            return
        end

        if not should_revoke and duration > 0 then
            -- Apply the metal effect
            ply:SetMaterial("debug/env_cubemap_model")  -- Change texture
            ply:SetWalkSpeed(100)  -- Reduce walking speed
            ply:SetRunSpeed(140)  -- Reduce running speed
            ply:SetJumpPower(0)   -- Disable jumping
            ply:SetNWBool("IsMetal", true)  -- Flag for other hooks

            -- Play music for the player
            ply:EmitSound("ulx_custom/metaltheme.wav", 75, 100, 1, CHAN_AUTO)

            -- Timer to revert effects after specified duration
            timer.Simple(duration, function()
                if IsValid(ply) then
                    ply:SetMaterial("")  -- Revert texture
                    ply:SetWalkSpeed(200)  -- Revert walk speed
                    ply:SetRunSpeed(400)  -- Revert running speed
                    ply:SetJumpPower(200)  -- Revert jump power
                    ply:SetNWBool("IsMetal", false)  -- Remove flag
                    ply:StopSound("ulx_custom/metaltheme.wav")
                end
            end)

            -- Hook to mute standard footsteps for metal players
            hook.Add("PlayerFootstep", "MuteMetalPlayerFootsteps_" .. ply:SteamID(), function(ply, pos, foot, sound, volume, rf)
                if ply:GetNWBool("IsMetal") then
                    playMetalFootstepSound(ply)  -- Play custom metal footstep sound
                    applyShakeEffect(ply)  -- Apply screen shake
                    return true  -- Returning true will mute the default footstep sound
                end
            end)
        else
            -- Revoke the metal effect
            ply:SetMaterial("")  
            ply:SetWalkSpeed(200)
            ply:SetRunSpeed(400)
            ply:SetJumpPower(200)
            ply:SetNWBool("IsMetal", false)
            ply:StopSound("ulx_custom/metaltheme.wav")

            -- Remove the footstep hook
            hook.Remove("PlayerFootstep", "MuteMetalPlayerFootsteps_" .. ply:SteamID())
        end
    end

    if not should_revoke then
        ulx.fancyLogAdmin(calling_ply, "#A made #T metallic for #i seconds!", target_plys, duration)
    else
        ulx.fancyLogAdmin(calling_ply, "#A revoked metallic effect from #T", target_plys)
    end
end

local metal = ulx.command(CATEGORY_NAME, ulx_command, ulx.metal, "!metal")
metal:addParam{type = ULib.cmds.PlayersArg}
metal:addParam{type = ULib.cmds.NumArg, default = 30, hint = "Duration", ULib.cmds.round}
metal:addParam{type = ULib.cmds.BoolArg, invisible = true}
metal:defaultAccess(ULib.ACCESS_ADMIN)
metal:help("Makes a player metallic and invincible for a specified duration.")
metal:setOpposite("ulx unmetal", {_, _, _, true}, "!unmetal")

-- Hook for invincibility
hook.Add("EntityTakeDamage", "MetalPlayerInvincibility", function(target, dmginfo)
    if target:IsPlayer() and target:GetNWBool("IsMetal") then
        return true  -- Cancel any damage
    end
end)
