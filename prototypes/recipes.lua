local woodenChestRecipe = table.deepcopy(data.raw["recipe"]["wooden-chest"])
woodenChestRecipe.name = "wooden-chest-log"
woodenChestRecipe.ingredients = {
	{type = "item", name = "log", amount = 2}
}
woodenChestRecipe.results = {{type = "item", name = "wooden-chest", amount = 1}}

data:extend{woodenChestRecipe}