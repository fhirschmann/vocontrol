---------------
-- ## A datatype featuring multiple Buffers.
--
-- [Github Page](https://github.com/fhirschmann/vomote)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

local Buffer = {}
local MultiBuffer = {}

--- Creates a new buffer.
-- @param size maximum size of the append buffer
function Buffer:new(size)
    local new = {}
    for k, v in pairs(Buffer) do
        new[k] = v
    end

    new._size = size or 50
    new:reset()

    return new
end

--- Sets the attribute identified by `name` to `value`.
-- @param name the name of the attribute
-- @param value the value
function Buffer:set(name, value)
    self._buffer[name] = value
end

--- Appends a value of an attribute identified by name.
-- @param name the name of the attribute
-- @param value the value
function Buffer:append(name, value)
    local tbl = self._buffer[name] or {}

    if table.getn(tbl) >= self._size then
        -- remove the oldest entry
        table.remove(tbl, 1)

        -- shift the table indices down by 1
        tbl = vomote.util.table.map(function(x)
            return x - 1
        end, tbl)
    end

    table.insert(tbl, value)
    self._buffer[name] = tbl
end

--- Gets the buffer.
function Buffer:get()
    return self._buffer
end

--- Resets the buffer.
function Buffer:reset()
    self._buffer = {}
end

--- Creates a new MultiBuffer.
function MultiBuffer:new()
    local new = {}
    for k, v in pairs(MultiBuffer) do
        new[k] = v
    end

    new._buffers = {}

    return new
end

--- Sets the attribute identified by `name` to `value`.
-- @param name the name of the attribute
-- @param value the value
function MultiBuffer:set(name, value)
    for _, buffer in pairs(self._buffers) do
        buffer:set(name, value)
    end
end

--- Appends a value of an attribute identified by name.
-- @param name the name of the attribute
-- @param value the value
function MultiBuffer:append(name, value)
    for _, buffer in pairs(self._buffers) do
        buffer:append(name, value)
    end
end

--- Adds a buffer to this MultiBuffer.
-- @param size maximum size of the buffer
-- @return id of the new buffer
function MultiBuffer:add_buffer(size)
    local id = table.getn(self._buffers) + 1
    self._buffers[id] = Buffer:new(size)

    return id
end

--- Gets a buffer.
-- @param id the id of the buffer to get
function MultiBuffer:get_buffer(id)
    return self._buffers[id]
end

return MultiBuffer
