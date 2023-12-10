-- bytes_system.lua
if SERVER then
    -- File to store the Bytes balances
    local DATA_FILE = "bytes_balances.txt"
    local CATEGORY_NAME = "Utility"

    -- Function to load balances from file
    local function loadBalances()
        if not file.Exists(DATA_FILE, "DATA") then
            file.Write(DATA_FILE, util.TableToJSON({}))
        end

        local data = file.Read(DATA_FILE, "DATA")
        return util.JSONToTable(data) or {}
    end

    -- Function to save balances to file
    local function saveBalances(balances)
        file.Write(DATA_FILE, util.TableToJSON(balances))
    end

    -- Load the balances when the script runs
    local playerBalances = loadBalances()

    -- Helper function to modify balance
    local function modifyBalance(ply, amount)
        local steamID = ply:SteamID()
        playerBalances[steamID] = (playerBalances[steamID] or 0) + amount
        saveBalances(playerBalances)
    end

    -- ULX Command to add Bytes
    local function ulxAddBytes(calling_ply, target_ply, amount)
        modifyBalance(target_ply, amount)
        ulx.fancyLogAdmin(calling_ply, "#A added #i Bytes to #T", amount, target_ply)
    end
    local addBytes = ulx.command(CATEGORY_NAME, "ulx addbytes", ulxAddBytes, "!addbytes")
    addBytes:addParam{ type=ULib.cmds.PlayerArg }
    addBytes:addParam{ type=ULib.cmds.NumArg, min=0 }
    addBytes:defaultAccess(ULib.ACCESS_ADMIN)
    addBytes:help("Add Bytes to a player's balance.")

    -- ULX Command to deduct Bytes
    local function ulxDeductBytes(calling_ply, target_ply, amount)
        modifyBalance(target_ply, -amount)
        ulx.fancyLogAdmin(calling_ply, "#A deducted #i Bytes from #T", amount, target_ply)
    end
    local deductBytes = ulx.command(CATEGORY_NAME, "ulx deductbytes", ulxDeductBytes, "!deductbytes")
    deductBytes:addParam{ type=ULib.cmds.PlayerArg }
    deductBytes:addParam{ type=ULib.cmds.NumArg, min=0 }
    deductBytes:defaultAccess(ULib.ACCESS_ADMIN)
    deductBytes:help("Deduct Bytes from a player's balance.")

    -- ULX Command to check Bytes
    local function ulxCheckBytes(calling_ply, target_ply)
        local balance = playerBalances[target_ply:SteamID()] or 0
        ulx.fancyLogAdmin(calling_ply, "#T has #i Bytes", target_ply, balance)
    end
    local checkBytes = ulx.command(CATEGORY_NAME, "ulx checkbytes", ulxCheckBytes, "!checkbytes")
    checkBytes:addParam{ type=ULib.cmds.PlayerArg }
    checkBytes:defaultAccess(ULib.ACCESS_ADMIN)
    checkBytes:help("Check a player's Bytes balance.")
end
