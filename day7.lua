local grid = {}
for line in io.lines("input7.txt") do
    if line ~= "" then
        table.insert(grid, line)
    end
end

local H = #grid
if H == 0 then
    print(0)
    print(0)
    os.exit()
end

local W = #grid[1]

local start_r, start_c = nil, nil
for r = 1, H do
    local pos = grid[r]:find("S", 1, true)
    if pos then
        start_r = r
        start_c = pos
        break
    end
end

if not start_r then
    print(0)
    print(0)
    os.exit()
end

local start_row = start_r + 1
if start_row > H then
    print(0)
    print(0)
    os.exit()
end

local function new_zero_array()
    local t = {}
    for i = 1, W do
        t[i] = 0
    end
    return t
end

local beams1 = new_zero_array()
beams1[start_c] = 1
local splits1 = 0

for r = start_row, H do
    local next_beams = new_zero_array()
    for c = 1, W do
        if beams1[c] ~= 0 then
            local cell = grid[r]:sub(c, c)
            if cell == "." or cell == "S" then
                if r < H then
                    next_beams[c] = 1
                end
            elseif cell == "^" then
                splits1 = splits1 + 1
                if r < H then
                    if c > 1 then
                        next_beams[c - 1] = 1
                    end
                    if c < W then
                        next_beams[c + 1] = 1
                    end
                end
            end
        end
    end
    beams1 = next_beams
end

local beams2 = new_zero_array()
beams2[start_c] = 1
local timelines = 0

for r = start_row, H do
    local next_beams = new_zero_array()
    for c = 1, W do
        local count = beams2[c]
        if count ~= 0 then
            local cell = grid[r]:sub(c, c)
            if cell == "." or cell == "S" then
                if r == H then
                    timelines = timelines + count
                else
                    next_beams[c] = next_beams[c] + count
                end
            elseif cell == "^" then
                if r == H then
                    timelines = timelines + count * 2
                else
                    if c > 1 then
                        next_beams[c - 1] = next_beams[c - 1] + count
                    end
                    if c < W then
                        next_beams[c + 1] = next_beams[c + 1] + count
                    end
                end
            end
        end
    end
    beams2 = next_beams
end

print(splits1)
print(timelines)
