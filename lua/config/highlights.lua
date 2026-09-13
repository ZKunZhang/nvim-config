-- Keep the built-in theme, with distinct syntax colors in 256-color terminals.
local function apply()
  if vim.g.colors_name ~= "default" then return end
  local light = vim.o.background == "light"
  local groups = {
    Function = { 25, "#005faf", 75, "#5fafff", bold = true },
    Statement = { 90, "#870087", 176, "#d787d7", bold = true },
    Type = { 30, "#008787", 80, "#5fd7d7" },
    Constant = { 130, "#af5f00", 215, "#ffaf5f" },
    String = { 28, "#008700", 114, "#87d787" },
  }
  for name, color in pairs(groups) do
    vim.api.nvim_set_hl(0, name, {
      ctermfg = color[light and 1 or 3],
      fg = color[light and 2 or 4],
      bold = color.bold or false,
    })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("config_default_highlights", { clear = true }),
  pattern = "default",
  callback = apply,
})
apply()
