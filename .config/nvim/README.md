## LSP 相关

`mason-lspconfig.nvim` 会自动读取 `neovim/nvim-lspconfig` 中的配置，并自动使用 `williamboman/mason.nvim` 安装对应的 server，映射关系: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md

增加新语言支持时，可检查对应的映射关系，会自动安装的 server 无需显式用 Mason 安装。
