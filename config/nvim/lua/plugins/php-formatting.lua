-- Formatierung/Linting so ausrichten, dass es mit PhpStorm übereinstimmt.
--
-- PhpStorm nutzt pro Projekt `.php-cs-fixer.dist.php` + `phpcs.xml` aus dem Projekt-Root
-- und die Tools aus `vendor/bin`. Neovim hat bisher das nächste `composer.json` als
-- Arbeitsverzeichnis genommen – in Monorepos (packages/*/composer.json) ist das das
-- Paket, dort findet php-cs-fixer keine Config und formatiert mit seinen Defaults.

local FIXER_CONFIGS = { ".php-cs-fixer.dist.php", ".php-cs-fixer.php" }
local PHPCS_CONFIGS = { ".phpcs.xml", "phpcs.xml", ".phpcs.xml.dist", "phpcs.xml.dist" }

-- Wie PhpStorm ($PROJECT_DIR$/...): die äußerste Config gewinnt, nicht die eines
-- einzelnen Pakets unter packages/*.
---@param buf integer
---@param markers string[]
---@return string? root, string? config
local function find_config(buf, markers)
  local name = vim.api.nvim_buf_get_name(buf == 0 and vim.api.nvim_get_current_buf() or buf)
  if name == "" then
    return nil
  end
  local found = vim.fs.find(markers, {
    path = vim.fs.dirname(name),
    upward = true,
    limit = math.huge,
    stop = vim.uv.os_homedir(),
  })
  if #found == 0 then
    return nil
  end
  local root = vim.fs.dirname(found[#found])
  -- Innerhalb des Root-Verzeichnisses gilt die Reihenfolge in `markers`.
  for _, marker in ipairs(markers) do
    local path = root .. "/" .. marker
    if vim.uv.fs_stat(path) then
      return root, path
    end
  end
end

---@param root string
---@param bin string
local function vendor_bin(root, bin)
  local path = root .. "/vendor/bin/" .. bin
  return vim.uv.fs_stat(path) and path or nil
end

-- Beim Speichern nur diese Filetypes formatieren. PhpStorm formatiert beim Speichern gar
-- nicht; alles andere (YAML, JSON, HTML/Fluid, JS, CSS …) fasst Neovim daher nicht
-- automatisch an. Manuell geht es weiter mit <leader>cf.
local FORMAT_ON_SAVE = { php = true, lua = true }

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_format_on_save_filter", { clear = true }),
  callback = function(ev)
    -- Für erlaubte Filetypes nil lassen, damit der globale Toggle (<leader>uF) greift.
    if vim.b[ev.buf].autoformat == nil and not FORMAT_ON_SAVE[vim.bo[ev.buf].filetype] then
      vim.b[ev.buf].autoformat = false
    end
  end,
})

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        php_cs_fixer = {
          -- Nur formatieren, wenn das Projekt eine php-cs-fixer-Config hat. Ohne Config
          -- würde der Fixer seine eigenen Defaults anwenden, die PhpStorm nicht kennt.
          condition = function(_, ctx)
            local root, config = find_config(ctx.buf, FIXER_CONFIGS)
            return root ~= nil and config ~= nil and vendor_bin(root, "php-cs-fixer") ~= nil
          end,
          command = function(_, ctx)
            local root = find_config(ctx.buf, FIXER_CONFIGS)
            return vendor_bin(root, "php-cs-fixer")
          end,
          cwd = function(_, ctx)
            return (find_config(ctx.buf, FIXER_CONFIGS))
          end,
          args = function(_, ctx)
            local _, config = find_config(ctx.buf, FIXER_CONFIGS)
            return { "fix", "--config=" .. config, "--using-cache=no", "--quiet", "$FILENAME" }
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        phpcs = {
          -- Wie in PhpStorm: Projekt-Ruleset + vendor/bin/phpcs. Ohne phpcs.xml kein Lint
          -- (sonst nutzt phpcs den PEAR-Standard und meldet massenhaft Fehlalarme).
          condition = function()
            return find_config(0, PHPCS_CONFIGS) ~= nil
          end,
          cmd = function()
            local root = find_config(0, PHPCS_CONFIGS)
            return root and vendor_bin(root, "phpcs") or "phpcs"
          end,
          args = {
            "-q",
            "--report=json",
            function()
              local _, config = find_config(0, PHPCS_CONFIGS)
              return "--standard=" .. config
            end,
            function()
              return "--stdin-path=" .. vim.api.nvim_buf_get_name(0)
            end,
            "-",
          },
        },
      },
    },
  },
}
