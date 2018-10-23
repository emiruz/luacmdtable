# luacmdtable

A command table is a useful abstraction for running a function when the system is in some
pre-specified state. The command table makes clear in which state the function can run.

|     | s_1 | s_2 | s_3 | s_4 |
| --- | --- + --- + --- + --- |
| f_1 |  F  |  F  |  F  |  F  |
| f_2 |  T  |  F  |  T  |  T  |
| f_3 |  T  |  T  |  T  |  T  |


When a function runs it can itself modify state so that on the next run the state may be
different.

Command tables can be used to easily specify state machines or workflow diagrams, to make
the logic of critical code clearer and easier to change confidentally. It also makes testing
critical code much easier.

luacmdtable is a tiny library which can be used to easily build command tables in Lua.
It is written in Lua 5.1.

# Installation

    luarocks install --server=http://luarocks.org/dev luacmdtable

# Documentation

## Example

Let's start with **require**:

    local D = require 'cmdtable'

We'll add a shortcut for creating negations:

    local NOT = D.neg

Here is a command table for us to translate.

|   | a | b | c |
|---+---+---+---+
| A | F | F | F |
| B | T | F | F |
| C | T | T | F |
| X | T | F | T |

Here are the functions which will serve as the conditions for our state.
Note that they must always return a boolean.

    local function a(s) return s.a or false end
    local function b(s) return s.b or false end
    local function c(s) return s.c or false end

Here are the state functions.

    local function A(s) s.a = true end
    local function B(s) s.b = true end
    local function C(s) s.c = true; s.b = false end
    local function X(s) s.success = true end

Let's encode our command table.

    local t = D.init()

       :cmd(A,       NOT(a),    NOT(b),       NOT(c))
       :cmd(B,       a,         NOT(b),       NOT(c))
       :cmd(C,       a,         b,            NOT(c))
       :cmd(X,       a,         NOT(b),       c)

Finally, let's print out the results.

    repeat
       print(t:exec(), t.state.a,t.state.b,t.state.c,t.state.success)
    until t.state.success

Output:

    1       true    nil     nil     nil
    1       true    true    nil     nil
    1       true    false   true    nil
    1       true    false   true    true   

##  init(state) -> self

Initialises the command table object with an optional state parameter. The state
can be any reference type you want: table, function, etc. The function returns itself.

##  cmd(f, ...) -> self

Adds a new line to the command table. The **ff** parameter must be a state function
with a proforma like **f(state) -> void**, the return value is ignored.

The rest of the parameters should be zero or more condition functions. A condition
function tests the state for a particular condition are returns a boolean value. It
must have the proforma **f(state) -> {true,false}**.

##  exec() -> N

Executes all functions in your command table which meet their criteria. Note that if a 
Returns the number of functions executed.

# Test suite

There are basic smoke tests and examples in test.impl.lua. To run them:

    lua test.impl.lua

# License

MIT Licensed, please see LICENSE file for more information.
