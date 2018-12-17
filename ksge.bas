' KSGE K.I.S.S. STRIP GAME ENGINE VERSION 1.1 20181129
' A STRIP GAME ENGINE BUILD WITH FREEBASIC AND BASED ON LIBVLC 
' COMPILE WITH FREEBASIC COMPILER (FBC) TESTET WITH VERSION 1.0.5 ON LINUX (UBUNTU 18.04) AND WINDOWS 10
' COMPILE WITH COMMAND FBC.EXE -s gui ksge.bas
' ON LINUX libvlc-dev IS NEEDED; INSTALL IT WITH sudo apt install libvlc-dev
' ON WINDOWS files libvlc.dll, libvlccore.dll and folder "plugins" from VLC media player folder should be placed in the source code folder
' AFTER COMPILED RUN THE BINARY WITH THE CORRECT PARAMETERS: KSGE name/foler of media content      debug flag (0=no 1=yes)       clip file extension
' example; ksge "marylin" 0 "mkv"
'
' CHANGELOG:
' VERSION 1.0 20181129 First working version
' VERSION 1.1 20181216 if a clip isn't found the game tries to go further
print "KSGE version 1.0 20181129"


#include once "vlc/vlc.bi"


'name of clips (wich must be then build by ksge adding only numbers)
'const ncliptype as string = ".mkv" 'type of clips.. avi, mkv, mpg, mp4 ecc..
const nclipstage as string = "./stage" 'part of clip name
const nclipenter as string = "./enter" 'part of clip name
const nclipend as string = "./end" 'part of clip name
const nclipcar as string = "car" 'part of clip name
const nclipact as string = "act" 'part of clip name
const nclipwin as string = "win" 'part of clip name
const ncliplos as string = "los" 'part of clip name
const nclipris as string = "ris" 'part of clip name
const nclipoff as string = "off" 'part of clip name

dim shared clipcount as integer = 0
dim shared currentstage as integer = 0
dim shared cliptoplay as string
dim shared lastclipplayed as string
dim shared action as string
dim shared totalstages as integer
dim shared ncliptype as string

'set correct clip file extension
ncliptype = "." & Command(3)

'set right working folder (where are clips and action file); strip game must use the same action file
if command(2) = "1" then print Command(1)
chdir Command(1)

Function rnd_range (first As Double, last As Double) As Double 'random number inrage for play random clip
    Function = Rnd * (last - first) + first
End Function

Function clipcounter (cliptosearch as string) as string
	dim filename as string
	clipcount = 0
	cliptosearch = cliptosearch + "*"
	filename = Dir(cliptosearch)
	Do While Len( filename ) > 0
		clipcount = clipcount + 1
		if command(2) = "1" then Print filename 'debug
		filename = Dir( )
	Loop
if command(2) = "1" then print "clipsearched: " , cliptosearch 'debug
if command(2) = "1" then print "counter: " , clipcount 'debug
Function = str (clipcount)
'Sleep
End Function

sub stagescounter
	dim flname as string
	dim stcount as integer
	totalstages = 1
	flname = Dir("stage" + str (totalstages) + "*")
	do while len (flname) > 0
	 totalstages = totalstages +1
	 flname = Dir("stage" + str (totalstages) + "*")
	loop
	totalstages = totalstages - 1
	if command(2) = "1" then print flname 'debug
	if command(2) = "1" then print "TOTAL STAGES: " , totalstages 'debug
	if command(2) = "1" then print totalstages 'debug
end sub

sub actiondone (acted as string)
   open "action" FOR OUTPUT AS #8 LEN = 3
   print #8, acted
   CLOSE #8
End sub


sub avoidduplicate
	do while clipcount > 1 and cliptoplay = lastclipplayed 
		if action <> "end" then
		cliptoplay = nclipstage + str (currentstage) + action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		else
		cliptoplay = action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		end if
		if command(2) = "1" then print "duplicate avoided" 'debug
	loop
end sub

function play(fileName as string, pInstance as libvlc_instance_t ptr, pPlayer as libvlc_media_player_t ptr) as integer
   var pMedia = libvlc_media_new_path (pInstance, fileName) 'libvlc_media_t ptr
   libvlc_media_player_set_media(pPlayer, pMedia)
   libvlc_media_player_play(pPlayer)
   dim as long w, h, l, timeout = 5000 'ms
   if command(2) = "1" then print "wait on start ..."
   while w = 0 andalso h = 0 andalso l = 0 andalso timeout >= 0
      w = libvlc_video_get_width(pPlayer)
      h = libvlc_video_get_height(pPlayer)
      l = libvlc_media_player_get_length(pPlayer)
      sleep 100 : timeout -= 100
   wend
   if timeout < 0 then
      print "Error: play back not started !"
      return -1
   end if
   'print "size: " & w & " x " & h & " length: " & l \ 1000 'debug
   while libvlc_media_get_state(pMedia) <> libvlc_ended
      sleep 100, 1
   wend
   'XXX libvlc_media_player_stop(pPlayer)
   'sleep
   return 0
end function

var pInstance = libvlc_new(0, NULL) 'libvlc_instance_t ptr
var pPlayer = libvlc_media_player_new(pInstance) 'libvlc_media_player_t ptr
var mediaFileName = "./enter1.mkv"

' MAIN
Randomize Timer

'first of all I reset the action file
actiondone ("car")
stagescounter

' deprecated launch of game thread
'#IFDEF __FB_WIN32__
'   CONST OS = "windows"
'   shell "start game.bat"
'#ELSE
'   CONST OS = "linux"
'   shell "./game.sh &"
'#ENDIF
'print OS


while action <> "qui"

if currentstage > 0 then
	select case action
	case "car"
		clipcounter (nclipstage + str (currentstage) + action)
		cliptoplay = nclipstage + str (currentstage) + action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		actiondone ("act") 'after car... model should act...
	case "los"
		clipcounter (nclipstage + str (currentstage) + action)
		cliptoplay = nclipstage + str (currentstage) + action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		actiondone ("car") 'after win or loss... model should take cards...	
	case "win"
		clipcounter (nclipstage + str (currentstage) + action)
		cliptoplay = nclipstage + str (currentstage) + action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		actiondone ("car") 'after win or loss... model should take cards...	
	case "ris","act"
		clipcounter (nclipstage + str (currentstage) + action)
		cliptoplay = nclipstage + str (currentstage) + action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		avoidduplicate
	case "off"
		clipcounter (nclipstage + str (currentstage) + action)
		cliptoplay = nclipstage + str (currentstage) + action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		if currentstage > totalstages then 
		clipcounter (nclipend)
		cliptoplay = nclipend + str(Int(rnd_range(1, clipcount+1))) + ncliptype 
		actiondone ("end") 'after off everything... go to end scenes...
		elseif currentstage < totalstages then
			actiondone ("car") 'after off... model should take cards...
		end if
		currentstage = currentstage + 1
	case "end"
		clipcounter (nclipend)
		cliptoplay = nclipend + str(Int(rnd_range(1, clipcount+1))) + ncliptype 
		avoidduplicate
		actiondone ("end")
	case else
		action = "act"
		clipcounter (nclipstage + str (currentstage) + action)
		cliptoplay = nclipstage + str (currentstage) + action + str(Int(rnd_range(1, clipcount+1))) + ncliptype
		avoidduplicate
		actiondone ("act") 'after car... model should act...
	end select
	
	
	
	
	if clipcount = 0 and currentstage <= totalstages then
		if command(2) = "1" then print "ERROR CLIP NOT FOUND!!!!"
		if command(2) = "1" then print cliptoplay
		'sleep
	end if
	
	mediaFileName = cliptoplay
	lastclipplayed =cliptoplay
	
	
	
	
end if

' entering scene 
if currentstage = 0 then
	clipcounter (nclipenter) 'let's check how many entering clips on filesystem
	cliptoplay = nclipenter + str(Int(rnd_range(1, clipcount+1))) + ncliptype 'let's play a random entering clip
	mediaFileName = cliptoplay
	currentstage = 1
	action = "car"
end if
	
   if command(2) = "1" then print mediaFileName 'debug
   'if play(mediaFileName, pInstance, pPlayer) < 0 then exit while ' <------- HERE STARTS PLAY CLIP
   if play(mediaFileName, pInstance, pPlayer) < 0 then print mediaFileName, "MAYBE NOT FOUND???" ' <------- HERE STARTS PLAY CLIP
   open "action" FOR INPUT AS #8 LEN = 3
   input #8, action
   CLOSE #8
   print
wend



libvlc_media_player_release(pPlayer)
libvlc_release(pInstance)
print "bye bye"
