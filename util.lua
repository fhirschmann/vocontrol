---------------
-- ## Utilities for Vendetta Online's LUA subset.
--
-- [Github Page](https://github.com/fhirschmann/vomote)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

local voutil = {table={}, string={}, func={}}

--- Checks wheter a table contains a value.
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

--- Copies a table deeply.
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

--- Maps a function to the values of a table; preserves keys.
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
-- @return a new table contains all elements of tbl
--         for which func is true
function voutil.table.filter(tbl, func)
    local tbl2 = {}
    for k, v in pairs(tbl) do
        if func(k, v) then
            tbl2[k] = v
        end
    end

    return tbl2
end

--- Returns the first element in a table.
-- @param tbl the table
-- @return first element in table
function voutil.table.head(tbl)
    for k, v in pairs(tbl) do
        return v
    end
end

--- Returns true if all elements of the table are true.
-- @param tbl the table
-- @return true if any of the table's value is true
function voutil.table.all(tbl)
    for _, v in pairs(tbl) do
        if not v then
            return false
        end

        return true
    end
end

--- Returns true if any of the table's values is true
-- @param tbl the table
-- @return true if any of the table's value is true
function voutil.table.any(tbl)
    for _, v in pairs(tbl) do
        if v then
            return true
        end

        return false
    end
end

--- Returns a new new table containing the union of both tables' values.
-- @param tbl1 the first table
-- @param tbl2 the second table
-- @return a table with all values of tbl1 and tbl2
function voutil.table.union(tbl1, tbl2)
    local tbl = {}

    for _, v in ipairs(tbl1) do
        table.insert(tbl, v)
    end

    for _, v in ipairs(tbl2) do
        table.insert(tbl, v)
    end

    return tbl
end

--- Returns a table containing all key/value pairs.
-- @param tbl1 the first table
-- @param tbl2 the second table
-- @return a new table containing all key/value pairs
function voutil.table.merge(tbl1, tbl2)
    local tbl = {}

    for k, v in pairs(tbl1) do
        tbl[k] = v
    end

    for k, v in pairs(tbl2) do
        tbl[k] = v
    end

    return tbl
end

--- Splits a string into an array.
-- @param string the string to split
-- @param sep the separator
function voutil.string.split(str, sep)
        local sep = sep or ","
        local fields = {}

        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c)
            table.insert(fields, c)
        end)
        return fields
end

--- Returns a new partial object which when called will behave like.
--- func called with the positional arguments ....
function voutil.func.partial(func, ...)
    local a = {...}
    return function(...)
        local args = {}
        for _, arg in pairs(a) do
            table.insert(args, arg)
        end
        for _, arg in pairs({...}) do
            table.insert(args, arg)
        end
        return func(unpack(args))
    end
end


return voutil
