#!/usr/bin/env lua

-- Test script for cursor-agent.lua plugin configuration

local function test_cursor_agent()
  print("Testing cursor-agent.lua...")
  
  -- Load the plugin file
  local ok, plugin = pcall(function()
    return dofile("lazyvim/lua/plugins/cursor-agent.lua")
  end)
  
  if not ok then
    print("✗ ERROR: Failed to load file")
    print("  " .. plugin) -- error message
    return false
  end
  
  print("✓ File loads successfully")
  
  -- Check return type
  if type(plugin) ~= "table" then
    print("✗ ERROR: Plugin must return a table, got: " .. type(plugin))
    return false
  end
  
  print("✓ Returns a table")
  
  -- Check plugin name (first element)
  local plugin_name = plugin[1]
  if not plugin_name or type(plugin_name) ~= "string" then
    print("✗ ERROR: Plugin name (first element) must be a string")
    return false
  end
  
  print("✓ Plugin name: " .. plugin_name)
  
  -- Check lazy setting
  if plugin.lazy ~= false then
    print("⚠ WARNING: lazy is set to: " .. tostring(plugin.lazy))
  else
    print("✓ lazy = false (plugin will load immediately)")
  end
  
  -- Validate plugin name format (should be "user/repo")
  if not plugin_name:match("^[%w%-_]+/[%w%-_%.]+$") then
    print("⚠ WARNING: Plugin name format may be incorrect (expected: user/repo)")
  else
    print("✓ Plugin name format is valid")
  end
  
  print("\n✓ All tests passed!")
  return true
end

-- Run tests
local success = test_cursor_agent()
os.exit(success and 0 or 1)
