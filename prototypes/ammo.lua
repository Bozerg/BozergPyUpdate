-- Handcrafting is disabled, so the player needs a bullet an assembling-machine-1 can
-- make from starting-area iron and raw coal, long before the sulfur/coke/lead chain
-- behind pY's real firearm-magazine is reachable. This is a distinct item, so nothing
-- else can be built from it -- it is only ever ammunition.
local crudeMagazine = table.deepcopy(data.raw["ammo"]["firearm-magazine"])
crudeMagazine.name = "crude-firearm-magazine"
crudeMagazine.icon = nil
crudeMagazine.icons = {
	{
		icon = "__base__/graphics/icons/firearm-magazine.png",
		icon_size = 64,
		tint = {r = 0.85, g = 0.68, b = 0.45, a = 1}
	}
}
crudeMagazine.order = "a[basic-clips]-a0[crude-firearm-magazine]"

-- Ingredients and time follow the `ammo-initial` recipe pyrawores sketched out and left
-- commented in prototypes/recipes/recipes.lua, minus the stone.
local crudeMagazineRecipe = {
	type = "recipe",
	name = "crude-firearm-magazine",
	category = "crafting",
	enabled = true,
	energy_required = 12,
	ingredients = {
		{type = "item", name = "iron-plate", amount = 1},
		{type = "item", name = "raw-coal", amount = 2}
	},
	results = {{type = "item", name = "crude-firearm-magazine", amount = 1}}
}

data:extend{crudeMagazine, crudeMagazineRecipe}
