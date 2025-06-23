local kube = require("util.kube")

-- k9s
vim.keymap.set("n", "<leader>ks", kube.open_k9s_in_zellij, { desc = "[P]K9S (zellij)" })
vim.keymap.set("n", "<leader>kS", kube.open_k9s_in_term, { desc = "[P]K9S (term)" })

-- kubectl
vim.keymap.set("n", "<leader>kf", kube.kubectl_apply, { desc = "[P]Kubectl Apply -f (Background)" })
vim.keymap.set("n", "<leader>kaf", kube.kubectl_apply, { desc = "[P]Kubectl Apply -f (Background)" })
vim.keymap.set("n", "<leader>kaF", kube.kubectl_apply_term, { desc = "[P]Kubectl Apply -f (Terminal)" })
vim.keymap.set("n", "<leader>kdf", kube.kubectl_delete, { desc = "[P]Kubectl Delete -f (Background)" })
vim.keymap.set("n", "<leader>kF", kube.kubectl_delete, { desc = "[P]Kubectl Delete -f (Background)" })
vim.keymap.set("n", "<leader>kdF", kube.kubectl_delete_term, { desc = "[P]Kubectl Delete -f (Terminal)" })

-- kustomize
vim.keymap.set("n", "<leader>kk", kube.kustomize_apply, { desc = "[P]Kubectl Apply -k (Background)" })
vim.keymap.set("n", "<leader>kak", kube.kustomize_apply, { desc = "[P]Kubectl Apply -k (Background)" })
vim.keymap.set("n", "<leader>kaK", kube.kustomize_apply_term, { desc = "[P]Kubectl Apply -k (Terminal)" })
vim.keymap.set("n", "<leader>kdk", kube.kustomize_delete, { desc = "[P]Kubectl Delete -k (Background)" })
vim.keymap.set("n", "<leader>kK", kube.kustomize_delete, { desc = "[P]Kubectl Delete -k (Background)" })
vim.keymap.set("n", "<leader>kdK", kube.kustomize_delete_term, { desc = "[P]Kubectl Delete -k (Terminal)" })
