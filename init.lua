-- PasteStack spoon
-- Spoon names should use TitleCase
-- https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md#how-do-i-create-a-spoon
local s = {}

-- Metadata
s.name="PasteStack"
s.version="0.1"
s.author="Von Welch"
s.license="Creative Commons Zero v1.0 Universal"
s.homepage="https://github.com/von/PasteStack.spoon"
s.path = hs.spoons.scriptPath()

-- Set up logger for spoon
local log = hs.logger.new("PasteStack")
s.log = log

s.stack = {}

-- debug() {{{ --
-- Enable or disable debugging
--
--- Parameters:
---  * enable - Boolean indicating whether debugging should be on
---
--- Returns:
---  * Nothing
s.debug = function(enable)
  if enable then
    log.setLogLevel('debug')
    log.d("Debugging enabled")
  else
    log.d("Disabling debugging")
    log.setLogLevel('info')
  end
end
-- }}}  debug() --

--- PasteStack:push() {{{ --
--- PasteStack:push()
--- Method
--- Pop last item pushed onto stack into pastebuffer.
--- Does nothing if stack is empty.
---
--- Parameters:
--- * Nothin
---
--- Returns:
--- * Nothing
s.push = function()
  log.d("Push()")
  table.insert(s.stack, hs.pasteboard.getContents())
end
--- }}} PasteStack:push() --

--- PasteStack:pop() {{{ --
--- PasteStack:pop()
--- Method
--- Push a copy of the current pastebuffer onto the stack.
--- Leaves paste buffer intact.
---
--- Parameters:
--- * Nothin
---
--- Returns:
--- * Nothing
s.pop = function()
  if #s.stack == 0 then
    log.i("Empty stack")
  else
    log.d("Pop()")
    hs.pasteboard.setContents(table.remove(s.stack))
  end
end
--- }}} PasteStack:push() --

--- PasteStack:bindHotKey() {{{ --
--- PasteStack:bindHotKey(self, table)
--- Method
--- The method should accept a single parameter, which is a table.
--- The keys of the table should be strings that describe the
--- action performed by the hotkeys, and the values of the table should be tables
--- containing modifiers and keynames/keycodes. E.g.
---   {
---     push = {{"cmd", "alt"}, "p"},
---     pop = {{"cmd", "alt"}, "P"}
--    }
---
---
--- Parameters:
---  * table - Table of action to key mappings
---
--- Returns:
---  * PasteStack object

s.bindHotKeys = function(table)
  for feature,mapping in pairs(table) do
    if feature == "push" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2], s.push)
    elseif feature == "pop" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2], s.pop)
     else
       log.wf("Unrecognized key binding feature '%s'", feature)
     end
   end
  return self
end
--- }}} PasteStack:bindHotKey() --

return s
-- vim: foldmethod=marker:
