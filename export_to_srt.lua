--[[
README:

Export to srt for fastsub

Exports all the lines to subrip format from aegisub

]]

--Script properties
script_name="Export srt"
script_description="Export to srt"
script_author="Oli"
script_version="2.0"

include("utils.lua")

-- srt toolbox
include("submerger.lua")

-- Saves the srt in the same directory of the aegisub script, using its filename 
function savef(subs, sel)

	scriptpath=aegisub.decode_path("?script")
	scriptname=aegisub.file_name()
	filename=scriptname:gsub("%.%w+$",".srt")

	write_srt(scriptpath.."/"..filename, subs )

	aegisub.debug.out("\n==== EXPORT TO SRT FINISHED "..#subs.." lines found=====")
	aegisub.debug.out("\nSaved, file " .. scriptpath.."/"..filename)
        aegisub.debug.out("\n==== EXPORT TO SRT ENDS ===========\n")

end


-- select all lines	useful when you want the "selected lines/all lines" option
-- use it something like this:	if res.selection=="all" then sel=selectall(subs, sel) mainfunction(subs, sel) end
function selectall(subs, sel)
sel={}
    for i = 1, #subs do
	if subs[i].class=="dialogue" then table.insert(sel,i) end
    end
    return sel
end

--Main processing function
function exportlines2srt(sub, sel)

	--Override selection from https://unanimated.github.io/ts/luapaste.htm
	sel=selectall(sub, sel)

	--Go through all the lines in the selection
	

	aegisub.debug.out("==== EXPORT TO SRT STARTS ===========\n")

	lines={}

	for si,li in ipairs(sel) do

		--Read in the line
		local line=sub[li]
		

		--Clears the styles, we just want the text for translations
		line.text = line.text:gsub("({[^}]+})(.*)", "%2")
		
		line.text=line.text:gsub("{%\\i1}", "<i>")
		line.text=line.text:gsub("{%\\i0}", "</i>")

		-- Fix CR for multiple lines
		line.text = line.text:gsub("%\\N", "\n")

		--Put the line back into the subtitles
		--sub[li]=line
		table.insert(lines,line)

	end
	
	--Save to File   
	savef(lines,sel)
	
	--Set undo point and maintain selection
	aegisub.set_undo_point(script_name)
	return sel
end

--Register macro (no validation function required)
aegisub.register_macro(script_name,script_description,exportlines2srt)
