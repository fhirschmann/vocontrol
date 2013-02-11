---------------
-- ## Log - a log-like object that has a history.
--
-- [Github Page](https://github.com/fhirschmann/vomote)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

local Log = {}

--- Creates a new empty queue.
-- @param max_history the maximum number of queries to keep track of
-- @return a new queue
function Log:new(max_history)
    local new = {}
    for k, v in pairs(Log) do
        new[k] = v
    end
    new:reset()
    new._past = {}
    new._time2past = {}
    new._max_history = max_history or gkini.ReadInt("vomote", "evqueuesize", 100)

    return new
end

--- Resets this queue.
function Log:reset()
    self._change = {}
end

--- Sets the attribute identified by name to value.
function Log:set(name, value)
    self._change[name] = value
end

--- Appends a value of an attribute identified by name.
-- @param name the name of the attribute
-- @param value the value
function Log:append(name, value)
    local tbl = self._change[name] or {}
    table.insert(tbl, value)
    self._change[name] = tbl
end

--- Constructs a subset of this queue containing all events since
--- the last query.
-- @param last_query the timestamp of the last query
function Log:construct(last_query)
    if self._past[last_query] then
        return self._past[last_query]
    end

    local copy = vomote.util.table.deepcopy(self._change)
    copy["timestamp"] = os.time()

    if table.getn(self._past) >= self._max_history then
        -- remove the entry and its mapping
        local q = table.remove(self._past, 1)
        self._time2past[q["timestamp"]] = nil

        -- shift the table indices down by 1
        self._time2past = vomote.util.table.map(function(x) return x - 1 end, self._time2past)
    end

    table.insert(self._past, copy)
    self._time2past[copy["timestamp"]] = table.getn(self._past)

    if not last_query then
        return self._past
    end

    local index = self._time2past[last_query]
    if not index then
        -- this should not happen, except when vomote is reloaded
        return self._past
    end

    -- we don't want the last query again
    index = index + 1

    local ret = {}
    local n = table.getn(self._past)
    while index <= n do
        table.insert(ret, self._past[index])
        index = index + 1
    end

    return ret
end

return Log