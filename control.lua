local util = require("util")
local crash_site = require("crash-site")

itemsToAdd = {["transport-belt"] = 100, 
				["burner-inserter"] = 20, 
				["small-electric-pole"] = 150, 
				["firearm-magazine"] = 200, 
				["iron-plate"] = 100, 
				["copper-plate"] = 50}

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]

    local character = player.character or player.cutscene_character

    if not character then
    	return
    end

    local inventory = character.get_main_inventory()
    if not inventory then
        return
    end

    for item_name, item_count in pairs(itemsToAdd) do
        if item_count > 0 then
            inventory.insert({name = item_name, count = item_count})
        end
    end

    inventory.sort_and_merge()

    if not global.init_ran then
        global.init_ran = true

        if remote.interfaces.freeplay then
            local player = game.players[event.player_index]
            local surface = player.surface
            local sps = surface.find_entities_filtered{position = player.force.get_spawn_position(surface), radius = 250, name = "crash-site-spaceship"} 
            local position = sps[1].insert({name="automated-factory-mk01",count=1})
            local position = sps[1].insert({name="assembling-machine-1",count=12})
        end
    end
end)

script.on_event(defines.events.on_player_respawned, function(event)
	local player = game.get_player(event.player_index)
	util.insert_safe(player, {["firearm-magazine"] = 40})
end)


script.on_init(function()
    if remote.interfaces.freeplay then
        remote.call("freeplay", "set_disable_crashsite", false)     -- That's the point of this mod... to have a crashsite, so we're force enabling it
    end
end)
