local itemstack = import "org.bukkit.inventory.ItemStack"
local material = import "org.bukkit.Material"
local location = import "org.bukkit.Location"
local gamerule = import "org.bukkit.GameRule"
local diff = import "org.bukkit.Difficulty"
local bukkit = import "org.bukkit.Bukkit"

-- holds the causer of the last damage
-- key: the damaged (Player)
-- value: damager (Player)
local lastDmg = {}

local function setRandSpawn(entity)
  local world = entity:getWorld()
  local spawns = {
    location.new(world, -496, 31, 149),
    location.new(world, -496, 31, 165),
    location.new(world, -487, 31, 151),
    location.new(world, -487, 31, 162),
    location.new(world, -461, 33, 166),
    location.new(world, -464, 33, 147),
    location.new(world, -434, 35, 140),
    location.new(world, -394, 36, 153),
    location.new(world, -394, 35, 160),
    location.new(world, -404, 35, 152),
    location.new(world, -404, 35, 159),
    location.new(world, -414, 35, 155),
    location.new(world, -442, 35, 156),
    location.new(world, -442, 37, 171),
    location.new(world, -469, 32, 160),
  }
  entity:setRespawnLocation(spawns[math.random(#spawns)], true)
end

local function printf(str,...)
  return print(str:format(...))
end

script.onLoad(function(event)
  local world = bukkit:getWorld("world")
  world:setGameRule(gamerule.DO_DAYLIGHT_CYCLE, false)
  world:setGameRule(gamerule.DO_MOB_SPAWNING, false)
  world:setGameRule(gamerule.DO_IMMEDIATE_RESPAWN, true)
  world:setGameRule(gamerule.DO_WEATHER_CYCLE, false)
  world:setDifficulty(diff.EASY)
  world:setTime(1000)
end)

script.hook("org.bukkit.event.entity.EntityDamageEvent", function(event)
  local causer = event:getDamageSource():getDirectEntity()
  local damaged = event:getEntity()

  if not causer then 
    return
  end
  
  if not utils.instanceOf(causer, "org.bukkit.entity.Player") then
    return
  end

  printf("damager=%s, damaged=%s", causer:getUniqueId():toString(), damaged:getUniqueId():toString())
  lastDmg[damaged] = causer
end)

script.hook("org.bukkit.event.entity.PlayerDeathEvent", function(event)
  event:setDeathMessage("")
  event:setKeepInventory(true)
  -- so we can call clear() it requires us to set 
  -- --add-opens=java.base/java.util=ALL-UNNAMED
  -- for whatever fucking reason
  event:getDrops():clear()
  
  local killed = event:getEntity()
  local killer = lastDmg[killed:getUniqueId()]
  
  printf("killer=%s killed=%s", killer:getUniqueId():toString(), killed:getUniqueId():toString())
  
  -- TODO: notfiy killer 
  setRandSpawn(killed)
end)

script.hook("org.bukkit.event.entity.ProjectileHitEvent", function(event)
  local proj = event:getEntity()
  proj:getWorld():createExplosion(proj:getLocation(), 3, false, false, proj:getShooter());
  proj:remove()
  -- nil if non entity is hit
  local hit = event:getHitEntity()
  if hit and utils.instanceOf(hit, "org.bukkit.entity.Player") then
    hit:setHealth(0)
  end
end)

script.hook("org.bukkit.event.block.BlockExplodeEvent", function(event)
  event:blockList():clear()
end)

script.hook("org.bukkit.event.entity.EntityShootBowEvent", function(event)
  event:setConsumeItem(false)
end)

script.hook("org.bukkit.event.player.PlayerDropItemEvent", function(event)
  event:setCancelled(true)
end)

script.hook("org.bukkit.event.player.PlayerJoinEvent", function(event)
  local player = event:getPlayer()
  
  local bow = itemstack.new(material.BOW)
  local meta = bow:getItemMeta()
  
  meta:setUnbreakable(true)
  bow:setItemMeta(meta)
  
  player:getInventory():setItem(9, itemstack.new(material.ARROW))
  player:getInventory():setItemInMainHand(bow)
  
  setRandSpawn(player)
  player:teleport(player:getRespawnLocation())
end)
