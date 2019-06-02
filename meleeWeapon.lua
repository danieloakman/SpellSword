require 'weapon'
MeleeWeapon = Weapon:extend()

function MeleeWeapon:new(name, owner)
  local weapons = {
    dagger = {
      damage = 1, attackSpeed = 1.2,
      sprite = {
        x = 288, y = 16, frameWidth = 16, frameHeight = 16,
        idle = {
          offsetX = 4, offsetY = 14, scaleX = 1, scaleY = 1,
          rot = degreesToRadians(90)
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
  self.super:new(weapons[name], owner)
end

function MeleeWeapon:update(dt, owner)
  self.super:update(dt, owner)
end

function MeleeWeapon:draw()
  self.super:draw()
end

