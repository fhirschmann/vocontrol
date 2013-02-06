---------------
-- ## Utilities for LUA
--
-- [Github Page](https://github.com/fhirschmann/vomote)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

local voutil = {}
voutil.table = {}

--- Checks wheter a table contains a value
-- @param tbl the table to check
-- @param value the value to check for
-- @return true if `tbl` contains `value`
function voutil.table.contains_value(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end

    return false
end

--- Copies a table.
-- @param orig the original table to copy
-- @return a copy of the original table
function voutil.table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[voutil.table.deepcopy(orig_key)] = voutil.table.deepcopy(orig_value)
        end
    else
        copy = orig
    end

    return copy
end

--- Maps a function to the values of a table; preserves keys
-- @param func the function to apply
-- @param tbl the table to apply func to
function voutil.table.map(func, tbl)
    local new_tbl = {}
    for i,v in pairs(tbl) do
        new_tbl[i] = func(v)
    end
    return new_tbl
end

--- Inverts a a table. The input table should be bijective.
-- @param tbl the table to invert
-- @return an inverted table
function voutil.table.invert(tbl)
    tbl2 = {}

    for k, v in pairs(tbl) do
        tbl2[v] = k
    end
end

--- Returns a filtered table.
-- @param tbl a table
-- @param func a filter function
function voutil.table.filter(tbl, func)
    local tbl2 = {}
    for k, v in pairs(tbl) do
        if func(k, v) then
            tbl2[k] = v
        end
    end

    return tbl2
end

return voutil
