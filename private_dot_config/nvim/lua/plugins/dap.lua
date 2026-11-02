vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/rcarriga/nvim-dap-ui",
})

local dap, dapui = require("dap"), require("dapui")
dapui.setup()

-- Open/close the UI automatically with a debug session
dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

-- gdb >= 14 speaks DAP natively, no extra adapter needed
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

-- Debug the binary that <leader>r builds (same path, no extension).
-- If input.txt exists next to it, it is fed as stdin (gdb runs the program through a shell).
local function cp_config()
  local cfg = {
    name = "Debug current file",
    type = "gdb",
    request = "launch",
    program = vim.fn.expand("%:p:r"),
    cwd = vim.fn.expand("%:p:h"),
    stopAtBeginningOfMainSubprogram = false,
  }
  if vim.fn.filereadable(cfg.cwd .. "/input.txt") == 1 then
    cfg.args = { "<", "input.txt" }
  end
  return cfg
end

-- F5: build a debug binary (-g -O0) for C/C++ and start debugging; continue if already running
local function debug_current()
  if dap.session() then
    return dap.continue()
  end
  local ft = vim.bo.filetype
  if ft ~= "c" and ft ~= "cpp" then
    return dap.continue()
  end
  vim.cmd("write")
  local cc = ft == "c" and { "gcc", "-g", "-O0", "-Wall" } or { "g++", "-std=c++20", "-g", "-O0", "-Wall" }
  vim.list_extend(cc, { "-o", vim.fn.expand("%:p:r"), vim.fn.expand("%:p") })
  local res = vim.system(cc, { text = true }):wait()
  if res.code ~= 0 then
    return vim.notify(res.stderr, vim.log.levels.ERROR, { title = "Build failed" })
  end
  dap.run(cp_config())
end

local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end
map("<F5>", debug_current, "Debug: build & start / continue")
map("<F10>", dap.step_over, "Debug: step over")
map("<F11>", dap.step_into, "Debug: step into")
map("<F12>", dap.step_out, "Debug: step out")
map("<leader>b", dap.toggle_breakpoint, "Debug: toggle breakpoint")
map("<leader>B", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "Debug: conditional breakpoint")
map("<leader>du", dapui.toggle, "Debug: toggle UI")
map("<leader>dq", dap.terminate, "Debug: stop")
