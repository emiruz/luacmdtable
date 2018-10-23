local D = require 'cmdtable'
local NOT = D.neg

--[[

|   | a | b | c |
|---+---+---+---+
| A | F | F | F |
| B | T | F | F |
| C | T | T | F |
| X | T | F | T |

--]]

-- functions

local function A(s) s.a = true end
local function B(s) s.b = true end
local function C(s) s.c = true; s.b = false end
local function X(s) s.success = true end

-- conditions

local function a(s) return s.a or false end
local function b(s) return s.b or false end
local function c(s) return s.c or false end

local t = D.init()

   :cmd(A,       NOT(a),    NOT(b),       NOT(c))
   :cmd(B,       a,         NOT(b),       NOT(c))
   :cmd(C,       a,         b,            NOT(c))
   :cmd(X,       a,         NOT(b),       c)

repeat
   print(t:exec(), t.state.a,t.state.b,t.state.c,t.state.success)
until t.state.success


-- neg, conj, disc tests.

assert(D.neg(function(s) return true end)() == false)

assert(D.neg(function(s) return false end)() == true)

assert(D.conj(
	  function(s) return true end,
	  function(s) return false end)() == false)

assert(D.conj(
	  function(s) return true end,
	  function(s) return true end)() == true)

assert(D.disc(
	  function(s) return false end,
	  function(s) return true end)() == true)

assert(D.disc(
	  function(s) return false end,
	  function(s) return false end)() == false)
