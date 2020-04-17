#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions' 

dst = ARGV[0]
aid = ARGV[1]
sterm = ARGV[2]


if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta accountid searchterm")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut brukere i accountid som matcher searchterm.")
	exit
end

$canvas = getCanvasConnection(dst)
def processUsers(users)
    users.each { |c|
	    printf("%s\t%s\t%s\t%s\n", c['id'],c['login_id'], c['name'], c['sortable_name'])
    }
end

printf("Id\tLoginId\tNavn\tSortertbart navn\n")
uri = sprintf("/api/v1/accounts/%d/users?search_term=%s",aid,sterm)
users = $canvas.get(uri)
processUsers(users)
while users.more?  do
  users = users.next_page!
  processUsers(users)
end
