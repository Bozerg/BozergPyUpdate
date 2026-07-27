local util = require("util")
local crash_site = require("crash-site")

-- Recipes this mod adds that only make sense when there is something to shoot at. On a
-- map generated without enemies they are kept out of the crafting menu, so the mod does
-- nothing biter-specific there.
local BITER_RECIPES = {"crude-firearm-magazine"}

local CRUDE_AMMO_ON_START = 100
local CRUDE_AMMO_ON_RESPAWN = 50

local function surfaceHasEnemies(surface)
    -- Only an explicit opt-out counts, because getting this wrong is not symmetric: a
    -- spare pistol on a peaceful map costs nothing, spawning unarmed into a Rampant run
    -- costs the run.
    if surface.no_enemies_mode then
        return false
    end

    -- Rampant and Biter Factions place and grow nests through their own logic, so vanilla
    -- enemy-base autoplace being zeroed says nothing about whether this map has biters.
    -- pY's own "py-recommended" map preset ships with enemy-base frequency = 0.
    if script.active_mods["RampantFixed"] or script.active_mods["biter-factions-ng"] then
        return true
    end

    local mapGenSettings = surface.map_gen_settings
    local controls = mapGenSettings and mapGenSettings.autoplace_controls
    local enemyBase = controls and controls["enemy-base"]
    -- An absent control means "fall back to the default", which does place enemies. The
    -- map generator GUI zeroes both frequency and size when enemy bases are set to None.
    if enemyBase and (enemyBase.frequency or 1) == 0 and (enemyBase.size or 1) == 0 then
        return false
    end
    return true
end

local function anySurfaceHasEnemies()
    for _, surface in pairs(game.surfaces) do
        if surfaceHasEnemies(surface) then
            return true
        end
    end
    return false
end

local function applyBiterContentState()
    local enabled = anySurfaceHasEnemies()

    for _, force in pairs(game.forces) do
        for _, recipeName in pairs(BITER_RECIPES) do
            local recipe = force.recipes[recipeName]
            if recipe then
                recipe.enabled = enabled
            end
        end
    end
end

script.on_event(defines.events.on_player_created, function(event)
    if not storage.init_ran then
        storage.init_ran = true

        if remote.interfaces.freeplay then
            local player = game.players[event.player_index]
            local surface = player.surface
            local sps = surface.find_entities_filtered{position = player.force.get_spawn_position(surface), radius = 250, name = "crash-site-spaceship"}

            local position = sps[1].insert({name="assembling-machine-1",count=20})
            local position = sps[1].insert({name="burner-inserter",count=40})
            local position = sps[1].insert({name="configurable-valve",count=14})
            local position = sps[1].insert({name="transport-belt",count=300})
            local position = sps[1].insert({name="burner-mining-drill",count=10})
            local position = sps[1].insert({name="stone-furnace",count=20})
            local position = sps[1].insert({name="pipe",count=50})
            local position = sps[1].insert({name="pipe-to-ground",count=20})
        end
    end

    local group = game.permissions.get_group("Default")
    if group then
        group.set_allows_action(defines.input_action.craft, false)
    end
end)

-- Freeplay stores these tables in the save, so a world keeps whatever they were when it
-- was created. This has to run on both on_init and on_configuration_changed, otherwise
-- adding or updating this mod in an existing world silently changes nothing.
local function configureFreeplaySpawnItems()
    if not remote.interfaces.freeplay then
        return
    end

    -- Handing the kit to freeplay rather than inserting it ourselves on on_player_created
    -- means it survives the crash-site cutscene, where the player is still a cutscene
    -- character and has no usable inventory yet.
    --
    -- This mod loads after pyalienlife, pycoalprocessing and pyhardmode, all of which
    -- rewrite these tables in their own on_init, so these edits are the surviving ones.
    local createdItems = remote.call("freeplay", "get_created_items")
    local respawnItems = remote.call("freeplay", "get_respawn_items")
    local shipItems = remote.call("freeplay", "get_ship_items")

    -- Real handgun ammo sits behind gunpowder and lead in pY. Nothing should hand it out
    -- for free; the crude magazine is what you get until you can build the real one.
    createdItems["firearm-magazine"] = nil
    respawnItems["firearm-magazine"] = nil
    shipItems["firearm-magazine"] = nil

    -- Both tables are applied per spawn: freeplay inserts created_items on
    -- on_player_created and respawn_items on on_player_respawned. Setting the pistol in
    -- both means it is reissued every death, not handed out once at the start. The respawn
    -- pistol is a base freeplay default already, but pyhardmode shows these tables get
    -- rewritten wholesale, so state it rather than inherit it.
    if anySurfaceHasEnemies() then
        createdItems["pistol"] = 1
        createdItems["crude-firearm-magazine"] = CRUDE_AMMO_ON_START
        respawnItems["pistol"] = 1
        respawnItems["crude-firearm-magazine"] = CRUDE_AMMO_ON_RESPAWN
    end

    remote.call("freeplay", "set_created_items", createdItems)
    remote.call("freeplay", "set_respawn_items", respawnItems)
    remote.call("freeplay", "set_ship_items", shipItems)
end

script.on_init(function()
    if remote.interfaces.freeplay then
        remote.call("freeplay", "set_disable_crashsite", false)
    end

    configureFreeplaySpawnItems()
    -- New worlds get the kit through freeplay's on_player_created, so the catch-up grant
    -- below must not fire for them.
    storage.spawnKitGranted = true

    game.difficulty_settings.spoil_time_modifier = 5
    game.difficulty_settings.technology_price_multiplier = 10

    applyBiterContentState()
end)

script.on_configuration_changed(function()
    applyBiterContentState()
    configureFreeplaySpawnItems()

    -- The tables above only take effect on the next spawn, so a character already standing
    -- in a world that predates the spawn kit would stay unarmed until it died. Hand the kit
    -- to everyone alive, exactly once, so updating the mod is enough.
    if not storage.spawnKitGranted then
        storage.spawnKitGranted = true
        if anySurfaceHasEnemies() then
            for _, player in pairs(game.players) do
                util.insert_safe(player, {
                    ["pistol"] = 1,
                    ["crude-firearm-magazine"] = CRUDE_AMMO_ON_RESPAWN
                })
            end
        end
    end
end)
script.on_event(defines.events.on_force_created, applyBiterContentState)
script.on_event(defines.events.on_surface_created, applyBiterContentState)


