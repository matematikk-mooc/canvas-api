require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
gid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta gid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut gruppetilhørighet for gruppesettet 'gid'.")
	exit
end

canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/group_categories/%d/groups?per_page=999", gid)
list = canvas.get(uri)
printf("Id\tNavn\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 




