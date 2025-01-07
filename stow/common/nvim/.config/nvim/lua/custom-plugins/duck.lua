return {
  {
    'tamton-aquib/duck.nvim',
    config = function()
      vim.keymap.set('n', '<leader>kk', function()
        require('duck').hatch()
      end, { desc = 'hatch a default duck' })
      vim.keymap.set('n', '<leader>ka', function()
        require('duck').cook()
      end, { desc = 'cook one' })
      vim.keymap.set('n', '<leader>kA', function()
        require('duck').cook_all()
      end, { desc = 'cook all' })

      local animals = {
        { name = '🦆', speed = 1 }, -- Duck (fast)
        { name = 'ඞ', speed = 0.5 }, -- Among Us (medium)
        { name = '🦀', speed = 0.2 }, -- Crab (medium-fast)
        { name = '🐈', speed = 1.2 }, -- Cat (medium)
        { name = '🐎', speed = 1.5 }, -- Horse (very fast)
        { name = '🦖', speed = 0.6 }, -- Dinosaur (medium-slow)
        { name = '🐤', speed = 0.8 }, -- Chick (fast)
      }

      vim.keymap.set('n', '<leader>kr', function()
        local random_animal = animals[math.random(#animals)]
        require('duck').hatch(random_animal.name, random_animal.speed)
      end, { desc = 'hatch a random animal' })

      vim.keymap.set('n', '<leader>kz', function()
        local duck = require 'duck'
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
        local random_animal = animals[math.random(#animals)]
        duck.hatch(random_animal.name, random_animal.speed)
      end, { desc = 'hatch a zoo' })
    end,
  },
}

-- 🦆 ඞ 🦀 🐈 🐎 🦖 🐤
-- vim.keymap.set('n', '<leader>dd', function() require("duck").hatch("🦆", 10) end, {}) -- A pretty fast duck
-- vim.keymap.set('n', '<leader>dc', function() require("duck").hatch("🐈", 0.75) end, {}) -- Quite a mellow cat
