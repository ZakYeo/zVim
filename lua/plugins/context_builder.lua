return {
  "ZakYeo/context-builder",
  config = function()
    require("context-builder").setup({
      register = "+",
      use_relative_paths = true,
      max_file_size_kb = 200,
      max_project_tree_files = 200,
      default_render_mode = "markdown",
      context_budget = {
        enabled = true,
        max_tokens = 30000,
        warn_at_percent = 80,
      },
      editable_buffer = {
        listed = true,
      },
      templates = {
        debug = "I need help debugging this code. Explain the likely issue and suggest a minimal fix.",
        review = "Please review this code for correctness, maintainability, and edge cases.",
        refactor = "Please suggest a cleaner refactor while preserving behaviour.",
        tests = "Please write useful tests for this code.",
      },
      keymaps = {
        enabled = true,
        prefix = "<leader>cb",
      },
    })
  end,
}
