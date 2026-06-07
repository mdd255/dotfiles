---@diagnostic disable: undefined-global
local map = require("config.utils").map
local git = require("config.git-functions")
local gh_actions = require("config.gh-actions-functions")

map({
  -- Github
  { "gpr", git.gh_pr_picker, { desc = "Github PRs (toggle filter with C-o)" } },
  { "gpo", git.gh_switch_account, { desc = "Switch Github account" } },
  { "gpc", git.create_pr, { desc = "Create PR" } },
  { "gpa", gh_actions.gh_actions_picker, { desc = "GH Actions picker" } },
  { "gpw", gh_actions.gh_workflow_dispatch, { desc = "GH workflow dispatch" } },
  {
    "gpb",
    function()
      Snacks.gitbrowse()
    end,
    { modes = { "n", "x" }, desc = "Git browse on remote" },
  },

  -- Git diff
  { "gdf", git.get_current_file_history, { desc = "Diffview current file history" } },
  { "gdb", git.git_diff_branch, { desc = "Diff branch" } },

  -- Git push/pull
  { "gpl", git.git_pull, { desc = "Git pull" } },
  { "gpu", git.git_push, { desc = "Git push" } },

  -- Git stash
  { "gss", git.git_stash_push, { desc = "Git stash push" } },
  { "gsd", git.git_stash_drop, { desc = "Git stash drop" } },
  { "gsp", git.git_stash_apply, { desc = "Git stash apply" } },

  -- Git restore/reset
  { "gaq", git.git_restore_staged, { desc = "Git restore --staged" } },
  { "grh", git.git_reset_hard, { desc = "Git reset --hard" } },
  { "grs", git.git_reset_soft, { desc = "Git reset --soft" } },
  { "grv", git.git_revert, { desc = "Git revert" } },

  -- Git commit
  { "gcm", git.git_commit, { desc = "Git commit" } },
  { "gca", git.git_commit_amend, { desc = "Git commit amend" } },

  -- Git misc
  {
    "gst",
    function()
      Snacks.picker.git_status()
    end,
    { desc = "Git status" },
  },
  { "gaa", git.git_add_all, { desc = "Git add all" } },
  { "gap", git.git_restore_all, { desc = "Git restore all" } },

  --- Git branch
  { "gbc", git.git_checkout_branch, { desc = "Git checkout branch" } },
  { "gbn", git.git_checkout_new_branch, { desc = "Git checkout new branch" } },
  { "gbd", git.git_delete_branch, { desc = "Git delete branch" } },
  { "gbm", git.git_merge_branch, { desc = "Git merge branch into current" } },

  -- Git log / blame
  { "gl", git.git_log, { desc = "Git commit log browser" } },
  { "gB", git.git_blame, { desc = "Git blame current line" } },

  -- Git cherry-pick
  { "gcp", git.git_cherry_pick, { desc = "Git cherry-pick" } },
  { "gcd", git.git_cherry_pick_abort, { desc = "Git cherry-pick abort" } },
})
