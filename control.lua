local util = require("util")
local crash_site = require("crash-site")

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

script.on_init(function()
    if remote.interfaces.freeplay then
        remote.call("freeplay", "set_disable_crashsite", false)
    end

    game.difficulty_settings.spoil_time_modifier = 5
    game.difficulty_settings.technology_price_multiplier = 10
end)


