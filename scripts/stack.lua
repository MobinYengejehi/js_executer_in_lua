VERSION = 0x01

GLOBALINDEX = 1
UNDEFINED = enum{}
NULL = enum{}

Line = 0
Character = 0
ValidChars = "abcdefghijklmnopqrstuvwxyz$1234567890_"
Numbers = "1234567890"
Strict = "use strict"

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

VariableSafety = enum{
    "Nothing",
    Const = "const",
    Let = "let",
    Var = "var"
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

Syntax = enum{
    Var = VariableSafety.Var,
    Let = VariableSafety.Let,
    Const = VariableSafety.Const,
    Import = "import",
    Export = "export",
    From = "from",
    As = "as",
    Function = "function",
    FunctionOpen = "(",
    FunctionClose = ")",
    ScopeOpen = "{",
    ScopeClose = "}",
    If = "if",
    Else = "else",
    For = "for",
    While = "while",
    Do = "do",
    And = "&",
    Or = "|",
    String = "'",
    String_2 = '"',
    LongString = "`",
    StringBackSlash = "\\",
    Async = "async",
    Await = "await",
    Yield = "yield",
    Delete = "delete",
    Arrow = "=>",
    Static = "static",
    Class = "class",
    ArrayOpen = "[",
    ArrayClose = "]",
    ObjectOpen = "{",
    ObjectClose = "}",
    ObjectEquil = ":",
    Cama = ",",
    ParOpen = "(",
    ParClose = ")",
    Add = "+",
    Equil = "=",
    Minus = "-",
    Multiply = "*",
    Devide = "/",
    Remainder = "%",
    Add_2 = "++",
    Minus_2 = "--",
    Multiply_2 = "**",
    AddEquil = "+=",
    MinusEquil = "-=",
    MultiplyEquil = "*=",
    DevideEquil = "/=",
    LambdaAnd = "?",
    LambdaOr = ":",
    SemiColon = ";",
    Comment = "//",
    LongCommentOpen = "/*",
    LongCommentClose = "*/",
    ObjectKey = ".",
    ObjectIndexOpen = "[",
    ObjectIndexClose = "]",
    StringJoin = "+",
    In = "in",
    Of = "of",
    Break = "break",
    Switch = "switch",
    Case = "case",
    Default = "default",
    Typeof = "typeof",
    Instanceof = "instanceof",
    BitLeftShift = "<",
    BitLeftShift_2 = "<<",
    BitRightShift = ">",
    BitRightShift_2 = ">>",
    BitRightShiftZero = ">>>",
    BitAnd = "&",
    BitOr = "|",
    BitXOr = "^",
    BitNot = "~",
    New = "new",
    Return = "return",
    JoinObject = "...",
    Try = "try",
    Catch = "catch",
    Line = "\n"
}

ImportantSyntax = {
    "while",
    "for",
    "do",
    "function",
    "instanceof",
    "typeof",
    "try",
    "catch",
    "new",
    "return",
    "if",
    "else",
    "switch",
    "case",
    "default",
    "delete",
    "in",
    "break",
    "class",
    "import",
    "export"
}

EvalEvents = enum{
    "DefineVariable",
    "DefineFunction",
    "Strict"
}

function Error(message,r,g,b)
    message = type(message) == LuaTypes.String and message or "Unknown"
    outputDebugString("Javascript(" + Line + ":" + Character + ") => " + message,0,r,g,b)
end

function IsValidChar(char)
    for i = 1,#ValidChars do 
        if ValidChars[i] == char then
            return true
        end
    end
    return false
end

function IsNumber(number)
    for i = 1,#Numbers do
        if Numbers[i] == number then 
            return true
        end
    end
    return false
end

function IsEmpty(char)
    return not IsValidChar(char) and (
        char ~= "[" and
        char ~= "]" and
        char ~= "{" and
        char ~= "}"
    )
end

function IsStringBracket(char)
    return (
        char == Syntax.String or
        char == Syntax.String_2 or
        char == Syntax.LongString
    )
end

function IsImportantSyntax(chunk,i)
    for _,syntax in ipairs(ImportantSyntax) do
        if sub(chunk,i,#syntax) == syntax then
            return syntax
        end
    end
    return false
end

function CreateStack(machine)
    local global = {}
    local stack = {}
    local dead = false
    local self
    self = {
        global = global,
        type = function(index)
            if not dead then
                index = tonumber(index)
                if index then
                    index = getindex(index,#stack)
                    if type(stack[index]) == LuaTypes.Table then
                        return stack[index].type
                    end
                end
            end
        end,
        existslocal = function(name)
            return not dead and (
                type(name) == LuaTypes.String and
                type(global[name]) == LuaTypes.Table
            )
        end,
        getlocal = function(name)
            if self.existslocal(name) then
                local variable = global[name].stack
                if variable.type == VariableTypes.Undefined then
                    self.pushundefined()
                elseif variable.type == VariableTypes.Null then
                    self.pushnull()
                elseif variable.type == VariableTypes.Boolean then
                    self.pushboolean(variable.value)
                elseif variable.type == VariableTypes.Number then
                    self.pushnumber(variable.value)
                elseif variable.type == VariableTypes.String then
                    self.pushstring(variable.value)
                elseif variable.type == VariableTypes.Object then
                    self.pushobject(variable.value)
                elseif variable.type == VariableTypes.Function then
                    self.pushfunction(variable.value)
                end
            else
                self.pushundefined()
            end
        end,
        setlocal = function(name,safety)
            if not dead and #stack > 0 then
                if type(name) == LuaTypes.String then 
                    if self.existslocal(name) then
                        if global[name].safety ~= VariableSafety.Const then
                           global[name].stack = stack[#stack]
                        else
                            Error("variable `" + name + "` is protected")
                        end
                        self.pop(1)
                    else
                        global[name] = {
                            safety = type(safety) == LuaTypes.String and safety or VariableSafety.Var,
                            stack = stack[#stack]
                        }
                        self.pop(1)
                    end
                end
            end
        end,
        deletelocal = function(name)
            if self.existslocal(name) then
                global[name] = nil
                collectgarbage("collect")
            end
        end,
        existsglobal = function(name)
            return not dead and (
                type(name) == LuaTypes.String and
                type(machine.global[name]) == LuaTypes.Table
            )
        end,
        getglobal = function(name)
            if self.existsglobal(name) then
                local variable = machine.global[name].stack
                if variable.type == VariableTypes.Undefined then
                    self.pushundefined()
                elseif variable.type == VariableTypes.Null then
                    self.pushnull()
                elseif variable.type == VariableTypes.Boolean then
                    self.pushboolean(variable.value)
                elseif variable.type == VariableTypes.Number then
                    self.pushnumber(variable.value)
                elseif variable.type == VariableTypes.String then
                    self.pushstring(variable.value)
                elseif variable.type == VariableTypes.Object then
                    self.pushobject(variable.value)
                elseif variable.type == VariableTypes.Function then
                    self.pushfunction(variable.value)
                end
            else
                self.pushundefined()
            end
        end,
        changableglobal = function(name)
            return self.existsglobal(name) and machine.global[name].safety ~= VariableSafety.Const
        end,
        setglobal = function(name,safety)
            if not dead and #stack > 0 then
                if type(name) == LuaTypes.String then 
                    if self.existsglobal(name) then
                        if machine.global[name].safety ~= VariableSafety.Const then
                            machine.global[name].stack = stack[#stack]
                        else
                            Error("variable `" + name + "` is protected")
                        end
                        self.pop(1)
                    else
                        machine.global[name] = {
                            safety = type(safety) == LuaTypes.String and safety or VariableSafety.Var,
                            stack = stack[#stack]
                        }
                        self.pop(1)
                    end
                end
            end
        end,
        deleteglobal = function(name)
            if self.existsglobal(name) then
                machine.global[name] = nil
                collectgarbage("collect")
            end
        end,
        existsref = function(key)
            if not dead then
                if type(key) == LuaTypes.Table then
                    return type(machine.ref[key]) == LuaTypes.Table
                end
            end
            return false
        end,
        ref = function()
            if not dead and #stack > 0 then
                local key = {}
                machine.ref[key] = stack[#stack]
                self.pop(1)
                return key
            end
        end,
        getref = function(key)
            if self.existsref(key) then
                local variable = machine.ref[key]
                if variable.type == VariableTypes.Undefined then
                    self.pushundefined()
                elseif variable.type == VariableTypes.Null then
                    self.pushnull()
                elseif variable.type == VariableTypes.Boolean then
                    self.pushboolean(variable.value)
                elseif variable.type == VariableTypes.Number then
                    self.pushnumber(variable.value)
                elseif variable.type == VariableTypes.String then
                    self.pushstring(variable.value)
                elseif variable.type == VariableTypes.Object then
                    self.pushobject(variable.value)
                elseif variable.type == VariableTypes.Function then
                    self.pushfunction(variable.value)
                end
            end
        end,
        unref = function(key)
            if self.existsref(key) then
                machine.ref[key] = nil
                collectgarbage("collect")
            end
        end,
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
            if not dead then 
                if type(value) == LuaTypes.Function then 
                    table.insert(stack,{
                        type = VariableTypes.Function,
                        value = value
                    })
                end
            end
        end,
        pushobject = function(value)
            if not dead then 
                if type(value) == LuaTypes.Table then 
                    table.insert(stack,{
                        type = VariableTypes.Object,
                        value = value
                    })
                end
            end
        end,
        tonil = function(index)
            if not dead then
                if (
                    self.type(index) == VariableTypes.Null or
                    self.type(index) == VariableTypes.Undefined
                ) then
                    return nil
                end
            end
            return LuaTypes.Nothing
        end,
        toboolean = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Boolean then 
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        tonumber = function(index)
            if not dead then 
                if self.type(index) == VariableTypes.Number then
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        tostring = function(index)
            if not dead then
                if self.type(index) == VariableTypes.String then
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        toobject = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Object then
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        tofunction = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Function then 
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        call = function(argsCount,returnCount)
            if not dead then
                argsCount = math.min(tonumber(argsCount) or 0,#stack)
                local index = #stack - argsCount
                if self.type(index) == VariableTypes.Function then
                    returnCount = tonumber(returnCount) or 0
                    local funcStack = CreateStack(machine)
                    for name,value in pairs(global) do
                        funcStack.global[name] = value
                    end
                    if argsCount > 0 then
                        for i = #stack - argsCount + 1,#stack do
                            if not self.type(i) then
                                funcStack.pushundefined()
                            else
                                copyValue(self,funcStack,i)
                            end
                        end
                    end
                    local rtCount = stack[index].value(funcStack)
                    self.pop(1 + argsCount)
                    for name,value in pairs(funcStack.global) do 
                        if global[name] then
                            if global[name].safety ~= VariableSafety.Const then
                                if global[name].stack.type ~= value.stack.type then
                                    global[name].stack.type = value.stack.type
                                end
                                if global[name].stack.value ~= value.stack.value then
                                    global[name].stack.value = value.stack.value
                                end
                            end
                        end
                    end
                    rtCount = math.min(tonumber(rtCount) or 0,returnCount)
                    if rtCount > 0 and returnCount > 0 then
                        local size = funcStack.size()
                        for i = math.max(argsCount,1) + size - rtCount - 1,size do
                            if returnCount < 1 then
                                break
                            else
                                if not funcStack.type(i) then
                                    self.pushundefined()
                                else
                                    copyValue(funcStack,self,i)
                                end
                                returnCount = returnCount - 1
                            end
                        end
                    end
                    if returnCount > 0 then
                        for i = 1,returnCount do
                            self.pushundefined()
                        end
                    end
                    funcStack.free()
                end
            end
        end,
        eval = function(code)
            if not dead and type(code) == LuaTypes.String and #code > 0 then
                local ignore = 0
                local ignoreSame = false
                local lastChunk = nil
                local event = nil
                local events = {}
                local lines = {0}
                local insideString = false
                local insideComment = false
                local longComment = false
                local variableSafety = nil
                local openedStringBracket = nil
                local beginingOfScope = true
                local afterEquil = false
                local strPack = ""
                local varName = ""
                local scope = 0
                local stream = CreateStream(code)
                local function SyntaxError(error)
                    stream.Break()
                    Line = #lines
                    Character = lines[Line]
                    Error("Syntax Error: " + error,255,0,0)
                    Line,Character = 0,0
                end
                stream.Read(function(byte,i)
                    if ignore > 0 then
                        ignore = ignore - 1
                        return
                    end
                    if ignoreSame then
                        if lastChunk ~= byte then
                            ignoreSame = false
                            stream.Back()
                        end
                        return
                    end
                    lastChunk = byte
                    if byte == Syntax.Line then
                        if insideComment and not longComment then
                            insideComment = false
                        end
                        if insideString then
                            if (
                                openedStringBracket == Syntax.String or
                                openedStringBracket == Syntax.String_2
                            ) then
                                insideString = false
                                openedStringBracket = nil
                                SyntaxError("Unterminated string literal")
                                return
                            end
                        end
                        table.insert(lines,0)
                    end
                    lines[#lines] = lines[#lines] + 1
                    if insideComment then
                        if longComment then 
                            if sub(code,i,#Syntax.LongCommentClose) == Syntax.LongCommentClose then
                                ignore = #Syntax.LongCommentClose - 1
                                insideComment = false
                                longComment = false
                            end
                        end
                        return
                    end
                    if insideString then
                        if sub(code,i,#openedStringBracket) == openedStringBracket then
                            if beginingOfScope then
                                beginingOfScope = false
                                if strPack == Strict then
                                    table.insert(events,{
                                        event = EvalEvents.Strict,
                                        scope = scope
                                    })
                                end
                            end
                            ignore = #openedStringBracket - 1
                            insideString = false
                            openedStringBracket = nil
                            strPack = ""
                        else
                            strPack = strPack + byte
                        end
                        return
                    end
                    if byte == Syntax.Line or byte == Syntax.SemiColon then
                        -- event = nil
                        return
                    end
                    if sub(code,i,#Syntax.Comment) == Syntax.Comment then
                        ignore = #Syntax.Comment - 1
                        insideComment = true
                        return
                    end
                    if sub(code,i,#Syntax.LongCommentOpen) == Syntax.LongCommentOpen then
                        ignore = #Syntax.LongCommentOpen - 1
                        insideComment = true
                        longComment = true
                        return
                    end
                    if not event then 
                        if sub(code,i,#Syntax.Var) == Syntax.Var and IsEmpty(code[i + #Syntax.Var]) then
                            ignore = #Syntax.Var - 1
                            event = EvalEvents.DefineVariable
                            variableSafety = VariableSafety.Var
                            return
                        end
                        if sub(code,i,#Syntax.Let) == Syntax.Let and IsEmpty(code[i + #Syntax.Let]) then
                            ignore = #Syntax.Let - 1
                            event = EvalEvents.DefineVariable
                            variableSafety = VariableSafety.Let
                            return
                        end
                        if sub(code,i,#Syntax.Const) == Syntax.Const and IsEmpty(code[i + #Syntax.Const]) then
                            ignore = #Syntax.Const - 1
                            event = EvalEvents.DefineVariable
                            variableSafety = VariableSafety.Const
                            return
                        end
                    else
                        if event == EvalEvents.DefineVariable then
                            if not afterEquil and IsStringBracket(byte) then
                                SyntaxError("Variable declaration expected")
                                return
                            end
                            if #varName < 1 and IsNumber(byte) then
                                SyntaxError("Variable declaration expected")
                                return
                            end
                            local impSyntax = IsImportantSyntax(code,i)
                            if #varName < 1 and impSyntax then
                                SyntaxError("'" + impSyntax + "' is not allowed as a variable declaration name")
                                return
                            end
                            -- error is  when const didn't have equil
                            --[[if variableSafety == VariableSafety.Const then
                                if sub(code,i,#Syntax.As) == Syntax.As then 
                                    SyntaxError("'" + variableSafety + "' declarations must be initialized")
                                    return
                                end
                            end--]]
                            print("event defineVariable",varName,#varName)
                            local data = {}
                            if IsValidChar(byte) then
                                varName = varName + byte
                            else
                                if sub(code,i,#Syntax.Equil) == Syntax.Equil then
                                    ignore = #Syntax.Equil - 1
                                    afterEquil = true
                                    table.insert(data,varName)
                                    varName = ""
                                    return
                                end
                            end
                            if afterEquil then
                                if IsValidChar(byte) then 
                                    afterEquil = false
                                    return
                                end
                            end
                        end
                    end
                    if sub(code,i,#Syntax.String) == Syntax.String then
                        ignore = #Syntax.String - 1
                        insideString = true
                        openedStringBracket = Syntax.String
                        return
                    end
                    if sub(code,i,#Syntax.String_2) == Syntax.String_2 then
                        ignore = #Syntax.String_2 - 1
                        insideString = true
                        openedStringBracket = Syntax.String_2
                        return
                    end
                    if sub(code,i,#Syntax.LongString) == Syntax.LongString then
                        ignore = #Syntax.LongString - 1
                        insideString = true
                        openedStringBracket = Syntax.LongString
                        return
                    end
                    beginingOfScope = false
                end)
                stream.Free()
                print("here finished!")
            end
        end,
        evalAsync = function() end,
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
        clear = function()
            if not dead then
                for i = 1,#stack do
                    if #stack > 0 then 
                        table.remove(stack,#stack)
                    else
                        break
                    end
                end
            end
        end,
        size = function()
            return not dead and #stack or 0
        end,
        alive = function()
            return dead
        end,
        free = function()
            self.clear()
            machine = nil
            global = nil
            stack = nil
            self = nil
            dead = true
            collectgarbage("collect")
        end
    }
    return self
end

function sub(str,i,count)
    return str:sub(i,i + count - 1)
end

function getindex(index,size)
    index = tonumber(index)
    size = tonumber(size)
    if index and size then
        return math.max(index >= 0 and index or size + index + 1,0)
    end
end

function copyValue(s1,s2,i)
    if s1.type(i) == VariableTypes.Null then 
        s2.pushnull()
    elseif s1.type(i) == VariableTypes.Undefined then
        s2.pushundefined()
    elseif s1.type(i) == VariableTypes.Boolean then
        s2.pushboolean(s1.toboolean(i))
    elseif s1.type(i) == VariableTypes.Number then
        s2.pushnumber(s1.tonumber(i))
    elseif s1.type(i) == VariableTypes.String then
        s2.pushstring(s1.tostring(i))
    elseif s1.type(i) == VariableTypes.Object then
        s2.pushobject(s1.toobject(i))
    elseif s1.type(i) == VariableTypes.Function then
        s2.pushfunction(s1.tofunction(i))
    end
end
