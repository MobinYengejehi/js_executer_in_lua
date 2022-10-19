GLOBALINDEX = 1
UNDEFINED = enum{}
NULL = enum{}

LuaTypes = enum{
    "Nothing",
    Nil = "nil",
    Boolean = "boolean",
    String = "string",
    Number = "number",
    Table = "table",
    Userdata = "userdata",
    Function = "function"
}

VariableTypes = enum{
    "Undefined",
    "Null",
    "Boolean",
    "Number",
    "String",
    "Object",
    "Function",
    "Symbol"
}

function CreateStack()
    local global = {}
    local stack = {}
    local refs = {}
    local dead = false
    local function v_type(index)
        if not dead then
            index = tonumber(index)
            if index then
                if type(stack[index]) == LuaTypes.Table then
                    return stack[index].type
                end
            end
        end
    end
    return {
        type = v_type,
        pushundefined = function()
            if not dead then
                table.insert(stack,{
                    type = VariableTypes.Undefined,
                    value = UNDEFINED
                })
            end
        end,
        pushnull = function()
            if not dead then
                table.insert(stack,{
                    type = VariableTypes.Null,
                    value = NULL
                })
            end
        end,
        pushboolean = function(value)
            if not dead then
                if type(value) == LuaTypes.Boolean then 
                    table.insert(stack,{
                        type = VariableTypes.Boolean,
                        value = value
                    })
                end
            end
        end,
        pushnumber = function(value)
            if not dead then
                if type(value) == LuaTypes.Number then
                    table.insert(stack,{
                        type = VariableTypes.Number,
                        value = value
                    })
                end
            end
        end,
        pushstring = function(value)
            if not dead then
                if type(value) == LuaTypes.String then
                    table.insert(stack,{
                        type = VariableTypes.String,
                        value = value
                    })
                end
            end
        end,
        pushfunction = function(value)

        end,
        tonil = function(index)
            if not dead then
                if (
                    v_type(index) == VariableTypes.Null or
                    v_type(index) == VariableTypes.Undefined
                ) then
                    return nil
                end
            end
            return LuaTypes.Nothing
        end,
        toboolean = function(index)
            if not dead then
                if v_type(index) == VariableTypes.Boolean then 
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        tonumber = function(index)
            if not dead then 
                if v_type(index) == VariableTypes.Number then
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        tostring = function(index)
            if not dead then
                if v_type(index) == VariableTypes.String then
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        pop = function(amount)
            if not dead then
                amount = tonumber(amount)
                if amount and amount > 0 then
                    for i = 1,amount do
                        if #stack > 0 then
                            table.remove(stack,#stack)
                        else
                            break
                        end
                    end
                end
            end
        end,
        alive = function()
            return dead
        end,
        free = function()
            global = nil
            stack = nil
            refs = nil
            v_type = nil
            dead = true
            collectgarbage("collect")
        end
    }
end

local stack = CreateStack()

stack.pushnull()
stack.pushundefined()
stack.pushboolean(true)
stack.pushstring("salam chetori?")

--stack.pop(1)

local value = stack.tostring(4)


print(value,value == LuaTypes.Nothing)
