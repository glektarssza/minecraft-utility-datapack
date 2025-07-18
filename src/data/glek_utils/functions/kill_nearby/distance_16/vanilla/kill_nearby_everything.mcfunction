execute as @s run tag @s add glek_utils_damage_nearby_source
execute as @e[type=#glek_utils:vanilla/everything,distance=..16] run damage @s 999999 minecraft:player_attack by @p[tag=glek_utils_damage_nearby_source,distance=..16]
execute as @s run tag @s remove glek_utils_damage_nearby_source
