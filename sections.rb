#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions' 

dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut seksjoner for kurs met kurs id 'cid'.")
	exit
end

canvas = getCanvasConnection(dst)

def dbg(s)
	STDERR.puts s
end

def OpenFile(filename)
	$file = File.open( filename,"w" )
end

def CloseFile()
	$file.close
end

def myputs(s)
	$file << s
end

#course_id,user_id,role,section_id,status

def printHeading(canvas, cid, mid)
    myputs("course_id,user_id,role,section_id,status")
end

def getUserProfile(canvas, sid)

    uri = sprintf("/api/v1/users/%d/profile",sid)
    profile = canvas.get(uri)
    return profile
end

def getCourseInfo(canvas, cid)
	uri = sprintf("/api/v1/courses/%d", cid)
    c = canvas.get(uri)
    return c["name"]
end

def getEnrollmentType(s)
#  //The enrollment type. One of 'StudentEnrollment', 'TeacherEnrollment',
#  //'TaEnrollment', 'DesignerEnrollment', 'ObserverEnrollment'.
#  "type": "StudentEnrollment",
	type = ""
	case s["type"]
	when "StudentEnrollment"
	  type = "student"
	when "TeacherEnrollment"
	  type = "teacher"
	end
	return type
end

#course_id,user_id,role,section_id,status
def processEnrollments(canvas, cid, sid, ssisid, list)
  list.each { |s| 
	    profile = getUserProfile(canvas, s["user_id"])
	    role = getEnrollmentType(s)
	    if((role != "") && (s["sis_section_id"] != "") && s["sis_section_id"] != nil)
		    str = sprintf("%s,%s,%s,%s,%s", cid, profile["sis_user_id"],role,ssisid, s["enrollment_state"])
		    myputs str
        	myputs "\n"
        end
  }
end

def processSection(canvas, cid, sid, ssisid)
	dbg(ssisid)
	
#	uri = sprintf("/api/v1/sections/%d/enrollments?type[]=StudentEnrollment", sid)
	uri = sprintf("/api/v1/sections/%d/enrollments", sid)

	list = canvas.get(uri)
	processEnrollments(canvas,cid, sid, ssisid, list)
	while list.more?  do
	  list = list.next_page!
	  processEnrollments(canvas,cid, sid, ssisid, list)
	end
end

def processSections(canvas,sections)
    i=0
	sections.each { |section| 
		i+=1
		dbg(section)
		processSection(canvas,section["sis_course_id"], section["id"], section["sis_section_id"])
		if(i==200)
			exit
		end
	}
end


courseName = getCourseInfo(canvas, cid)

cn = courseName.gsub(/[^0-9A-Za-z]/, '')
filename = sprintf("%s_seksjoner.csv", cn)

$file = OpenFile(filename)


uri = sprintf("/api/v1/courses/%d/sections",cid)
sections = canvas.get(uri)
processSections(canvas,sections)
while sections.more?  do
  sections = sections.next_page!
  processSections(canvas,sections)
end

CloseFile()


