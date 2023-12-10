-- Import ULX and ULib
local CATEGORY_NAME = "Fun"

-- Function to update player color to rainbow
local function updateRainbowColor( ply )
    if not ply:IsValid() or not ply.rainbowColor then return end

    local color = HSVToColor( ( CurTime() * 50 ) % 360, 1, 1 ) -- Creates a rainbow effect
    ply:SetPlayerColor( Vector( color.r / 255, color.g / 255, color.b / 255 ) )

    timer.Simple( 0.1, function() updateRainbowColor( ply ) end ) -- Update color every 0.1 seconds
end

-- Define the function to change player color
function ulx.rgbcolor( calling_ply, target_ply, red, green, blue, rainbow )
    if not target_ply:IsValid() then
        ULib.tsayError( calling_ply, "Invalid player!", true )
        return
    end

    if rainbow then
        -- Enable rainbow mode
        target_ply.rainbowColor = true
        updateRainbowColor( target_ply )
        ulx.fancyLogAdmin( calling_ply, "#A enabled rainbow color mode for #T", target_ply )
    else
        -- Disable rainbow mode and set specified color
        target_ply.rainbowColor = false
        local color = Color( red, green, blue )
        target_ply:SetPlayerColor( Vector( color.r / 255, color.g / 255, color.b / 255 ) )
        ulx.fancyLogAdmin( calling_ply, "#A changed the color of #T to RGB( #i, #i, #i )", target_ply, red, green, blue )
    end
end

-- Declare the command
local rgbcolor = ulx.command( CATEGORY_NAME, "ulx rgbcolor", ulx.rgbcolor, "!rgbcolor" )
rgbcolor:addParam{ type=ULib.cmds.PlayerArg }
rgbcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, hint="red", ULib.cmds.round, optional=true }
rgbcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, hint="green", ULib.cmds.round, optional=true }
rgbcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, hint="blue", ULib.cmds.round, optional=true }
rgbcolor:addParam{ type=ULib.cmds.BoolArg, hint="rainbow mode" }
rgbcolor:defaultAccess( ULib.ACCESS_ADMIN )
rgbcolor:help( "Change a player's color based on RGB values or enable rainbow mode." )
