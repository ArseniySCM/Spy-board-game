local composer = require( "composer" )
local globals = require 'globals'
-- Робота з файлами
local dataPath = system.pathForFile( "categories.txt", system.DocumentsDirectory )
local templatePath = system.pathForFile( "categoriesTemplate.txt", system.ResourceDirectory )
local contents

-- Перевіряємо, чи є файл у документах
local file = io.open( dataPath, "r" )

if file then
    
    contents = file:read( "*a" )
    io.close( file )
else
    
    local tFile = io.open( templatePath, "r" )
    if tFile then
	
        contents = tFile:read( "*a" )
        io.close( tFile )
        local wFile = io.open( dataPath, "w" )
		
        if wFile then
            wFile:write( contents )
            io.close( wFile )
        end
    end
end

-- Запускаємо обробку, якщо дані отримані
if contents then
    globals.saveCategories( contents )
end

math.randomseed( os.time() )

composer.gotoScene( "menu" )