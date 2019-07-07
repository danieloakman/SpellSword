local class = require 'lib/middleclass'

local Weapon = require 'weapon'
local MeleeWeapon = class('MeleeWeapon', Weapon)

function MeleeWeapon:initialize(name, owner)
  local weapons = {
    dagger = {
      damage = 1, attackSpeed = 1.2,
      sprite = {
        x = 288, y = 16, frameWidth = 16, frameHeight = 16,
        idle = {
          offsetX = 4, offsetY = 14, scaleX = 1, scaleY = 1,
          rot = toRadians(90)
        },
        attack = {
        
        }
      },
      tier = 1
    },
    rustyShortSword = {
      damage = 2, attackSpeed = 1.2,
      sprite = {x = 304, y = 16, frameWidth = 16, frameHeight = 32},
      tier = 2
    },
    shortSword = {
      damage = 3, attackSpeed = 1.2,
      sprite = {x = 320, y = 16, frameWidth = 16, frameHeight = 32},
      tier = 3
    },
    veteranShortSword = {
      damage = 4, attackSpeed = 1.2,
      sprite = {x = 336, y = 16, frameWidth = 16, frameHeight = 32},
      tier = 4
    },
    longHammer = {
      damage = 2, attackSpeed = 0.5,
      sprite = {x = 388, y = 32, frameWidth = 16, frameHeight = 48},
      tier = 1
    }
  }
  Weapon.initialize(self, weapons[name], owner)
end

function MeleeWeapon:update(dt, owner)
  Weapon.update(self, dt, owner)
end

function MeleeWeapon:draw()
  Weapon.draw(self)
end

return MeleeWeapon
