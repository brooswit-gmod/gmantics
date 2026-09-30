-- Run from the repository root. Git discovers tracked and new test files.
package.path = "./lua/?.lua;" .. package.path
if arg[1] == "--suite" then
    dofile(assert(arg[2], "missing suite path"))
    return
end
local windows = package.config:sub(1, 1) == "\\"
local function quote(value)
    if windows then
        assert(not value:find('["%%!\r\n]'), "unsupported shell characters in path")
        return '"' .. value .. '"'
    end
    return "'" .. value:gsub("'", "'\\''") .. "'"
end
local pipe = assert(io.popen("git ls-files -z --cached --others --exclude-standard -- test/", "r"))
local listing = pipe:read("*a")
assert(pipe:close(), "test discovery failed")
local files, seen = {}, {}
for file in listing:gmatch("([^%z]+)%z") do
    if file:match("%.lua$") and file ~= "test/run.lua" and not seen[file] then
        files[#files + 1], seen[file] = file, true
    end
end
table.sort(files)
assert(#files > 0, "no test suites discovered")
local failed = 0
local executable_index = -1
while arg[executable_index - 1] do executable_index = executable_index - 1 end
local executable = arg[executable_index] or "luajit"
for _, file in ipairs(files) do
    print("Running " .. file)
    io.stdout:flush()
    local command = quote(executable) .. " test/run.lua --suite " .. quote(file)
    -- cmd.exe strips the outer quotes around a command starting with quotes.
    if windows then command = '"' .. command .. '"' end
    local status = os.execute(command)
    if status ~= 0 and status ~= true then
        failed = failed + 1
        io.stderr:write("FAILED: " .. file .. "\n")
    end
end
print(string.format("%d suites, %d failed", #files, failed))
os.exit(failed == 0 and 0 or 1)
