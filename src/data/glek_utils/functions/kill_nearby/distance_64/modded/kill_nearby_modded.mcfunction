execute as @s run tag @s add glek_utils_damage_nearby_source
execute as @e[type=#glek_utils:modded/modded,distance=..64] run damage @s 999999 minecraft:player_attack by @p[tag=glek_utils_damage_nearby_source,distance=..64]
execute as @s run tag @s remove glek_utils_damage_nearby_source
