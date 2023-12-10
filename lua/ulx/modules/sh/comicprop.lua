-- First, ensure ULX and ULib are loaded
if not ulx or not ULib then
    error("ULX and ULib must be installed to use this script.")
end

-- Define the list of comic props models
local comicProps = {
    "models/props_c17/oildrum001.mdl",
    "models/props_junk/wood_crate001a.mdl",
    "models/props_junk/wood_crate002a.mdl",
    "models/props_junk/watermelon01.mdl",
    "models/props_junk/TrafficCone001a.mdl",
    "models/maxofs2d/companion_doll.mdl",
    "models/props_c17/FurnitureChair001a.mdl",
    "models/food/burger.mdl",
    "models/props_junk/garbage_milkcarton002a.mdl",
    "models/props_lab/monitor02.mdl",
    "models/props_combine/breenbust.mdl",
    -- Add more models from the "comic props" tab as desired
}

-- Rest of your script ...

-- Function to turn a player into a prop
local function ulx_comicprop(calling_ply, target_plys)
    for _, ply in ipairs(target_plys) do
        if ply:Alive() then
            local propModel = comicProps[math.random(#comicProps)]
            local prop = ents.Create("prop_physics")
            prop:SetModel(propModel)

            local spawnPos = ply:GetPos() + Vector(0, 0, 20) -- Adjust if necessary
            prop:SetPos(spawnPos)
            prop:Spawn()

            ply:Kill()  -- Kill the player

            -- Remove the player's ragdoll
            local ragdoll = ply:GetRagdollEntity()
            if IsValid(ragdoll) then
                ragdoll:Remove()
            end

            -- Randomize the pitch
            local pitch = math.random(80, 120) -- Random pitch between 80% and 120% of the original sound's pitch

            -- Play the custom sound with random pitch
            ply:EmitSound("ulx_custom/pop1.wav", 75, pitch)  -- Adjust 'my_sounds/funny_sound.mp3' to your sound file's path

            -- Remove the prop when the player respawns
            local function onPlayerRespawn()
                if IsValid(prop) then
                    prop:Remove()
                end
                hook.Remove("PlayerSpawn", "RemoveProp_" .. ply:SteamID())
            end

            hook.Add("PlayerSpawn", "RemoveProp_" .. ply:SteamID(), onPlayerRespawn)
        else
            ULib.tsayError(calling_ply, ply:Nick() .. " is not alive, so they can't be turned into a prop.", true)
        end
    end
end

-- Declare the command
local comicprop = ulx.command("Fun", "ulx comicprop", ulx_comicprop, "!comicprop")
comicprop:addParam{ type = ULib.cmds.PlayersArg }
comicprop:defaultAccess(ULib.ACCESS_ADMIN)
comicprop:help("Turn players into a random prop.")
