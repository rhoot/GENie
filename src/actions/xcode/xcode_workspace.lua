local premake = premake
local xcode = premake.xcode

function xcode.workspace_head()
	_p('<?xml version="1.0" encoding="UTF-8"?>')
	_p('<Workspace')
	_p(1,'version = "1.0">')
end

function xcode.workspace_tail()
	_p('</Workspace>')
end

function xcode.workspace_file_ref(prj, indent)
	local projpath = path.getrelative(prj.solution.location, prj.location)
	if projpath == '.' then projpath = ''
	else projpath = projpath ..'/'
	end
	_p(indent, '<FileRef')
	_p(indent + 1, 'location = "group:%s">', projpath .. prj.name .. '.xcodeproj')
	_p(indent, '</FileRef>')
end

function xcode.workspace_group(grp, indent)
	_p(indent, '<Group')
	_p(indent + 1, 'location = "container:"')
	_p(indent + 1, 'name = "%s">', grp.name)

	for _, child in ipairs(grp.groups) do
		xcode.workspace_group(child, indent + 1)
	end

	for _, prj in ipairs(grp.projects) do
		xcode.workspace_file_ref(prj, indent + 1)
	end

	_p(indent, '</Group>')
end

function xcode.workspace_generate(sln)
	xcode.preparesolution(sln)
	xcode.workspace_head()
	xcode.sortSolution(sln)

	for grp in premake.solution.eachgroup(sln) do
		if grp.parent == nil then
			xcode.workspace_group(grp, 1)
		end
	end

	for prj in premake.solution.eachproject(sln) do
		if prj.group == nil then
			xcode.workspace_file_ref(prj, 1)
		end
	end

	xcode.workspace_tail()
end

--
-- Sort the solution's groups and projects to be listed in alphabetical order.
--

function xcode.sortSolution(sln)
	local function nameCompare(a, b)
		return a.name < b.name
	end

	local function sortChildren(grp)
		table.sort(grp.groups, nameCompare)
		table.sort(grp.projects, nameCompare)

		for _, child in ipairs(grp.groups) do
			sortChildren(child)
		end
	end

	sortChildren(sln)
end

