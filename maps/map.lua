return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 9,
  height = 7,
  tilewidth = 128,
  tileheight = 128,
  properties = {},
  tilesets = {
    {
      name = "May",
      firstgid = 1,
      tilewidth = 128,
      tileheight = 128,
      spacing = 0,
      margin = 0,
      image = "hale_may_128.png",
      imagewidth = 128,
      imageheight = 128,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 9,
      height = 7,
      visible = true,
      opacity = 1,
      properties = {
        ["collidable"] = "true"
      },
      encoding = "lua",
      data = {
        1, 0, 3758096385, 0, 1073741825, 0, 536870913, 0, 2147483649,
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 536870913, 0, 2147483649, 0, 3758096385, 0, 1073741825,
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 1610612737, 0, 1, 0, 2684354561, 0, 3221225473,
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 2684354561, 0, 3221225473, 0, 1610612737, 0, 1
      }
    }
  }
}
