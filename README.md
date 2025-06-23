
<h1 align="center">
🔄 NeoSwap.nvim
</h1>

<p align="center">
  <a href="http://www.lua.org">
    <img
      alt="Lua"
      src="https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua"
    />
  </a>
  <a href="https://neovim.io/">
    <img
      alt="Neovim"
      src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white"
    />
  </a>
</p>

![demo](https://raw.githubusercontent.com/ecthelionvi/Images/main/NeoSwap.gif)

## 📢 Introduction

NeoSwap simplifies word swapping in Neovim, making it easy to quickly rearrange words within your code.

## ✨ Features

- Swap words with ease in Neovim using NeoSwap's built-in pattern matching.
- Visual mode support: Select any text and swap it with adjacent words.
- Streamline your coding workflow with efficient word and text swapping.

## 🛠️ Usage

To swap the position of adjacent words to the right of the cursor, use the `NeoSwapNext` command:

```vim
:NeoSwapNext
```
To swap the position of adjacent words to the left of the cursor, use the `NeoSwapNext` command:

```vim
:NeoSwapPrev
```

### Visual Mode Support

In visual mode, you can select any text and swap it with adjacent words:

```vim
:NeoSwapVisualNext
:NeoSwapVisualPrev
```

You can also create keybindings to swap words more conveniently:

```lua
-- Normal mode
vim.keymap.set("n", "<leader>s", "<cmd>NeoSwapNext<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>S", "<cmd>NeoSwapPrev<cr>", { noremap = true, silent = true })

-- Visual mode
vim.keymap.set("v", "<leader>s", "<cmd>NeoSwapVisualNext<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>S", "<cmd>NeoSwapVisualPrev<cr>", { noremap = true, silent = true })
```
## 📦 Installation

1. Install via your favorite package manager.

- [lazy.nvim](https://github.com/folke/lazy.nvim)
```Lua
{
  "ecthelionvi/NeoSwap.nvim",
  opts = {}
},
```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```Lua
use "ecthelionvi/NeoSwap.nvim"
```

2. Setup the plugin in your `init.lua`. This step is not needed with lazy.nvim if `opts` is set as above.
```Lua
require("NeoSwap").setup()
```
## 🙏 Acknowledgments

Special thanks to [LostNeophyte](https://gitlab.com/lostneophyte) for their contributions to the development of NeoSwap. Your help is greatly appreciated!
