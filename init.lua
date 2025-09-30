local pack_list = {} ---@type Package[]

Fk:loadTranslationTable{
  ["aaa_steam"] = "Steam",
  ["steam"] = "蒸",
}

local extensionName = "aaa_steam"

--- 从扩展包里读取技能skel
---@param package Package
local function loadSkillSkelsFromPackage (package)
  local path = "./packages/" .. extensionName .. "/pkg/"..package.name.."/skills"
  local skels = {}
  local normalized_dir = path
      :gsub("^%.+/", "")
      :gsub("/+$", "")
      :gsub("/", ".")
  for _, filename in ipairs(FileIO.ls(path)) do
    -- 下划线开头的文件不会被加载
    if filename:sub(-4) == ".lua" and filename ~= "init.lua" and not filename:startsWith("_") then
      local skel = Pcall(require, normalized_dir .. "." .. filename:sub(1, -5))
      if skel then
        -- 如果返回了一个skel表
        if type(skel) == "table" and skel[1] ~= nil then
          for _, v in ipairs(skel) do
            table.insert(skels, v)
          end
        else
          table.insert(skels, skel)
        end
      end
    end
  end
  package:loadSkillSkels(skels)
end

-- 加载所有拓展包，并为包加载技能
local package_path = "packages/" .. extensionName .. "/pkg"
local normalized_dir = package_path:gsub("/", ".")
for _, dirname in ipairs(FileIO.ls(package_path)) do
  if FileIO.isDir(package_path .. "/" .. dirname) then
    local pkg = Pcall(require, normalized_dir .. "." .. dirname)---@type Package
    if pkg then
      loadSkillSkelsFromPackage(pkg)
      table.insert(pack_list, pkg)
    end
  end
end

return pack_list
