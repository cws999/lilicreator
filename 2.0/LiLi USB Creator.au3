#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=icon.ico
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Easily create a Linux Live USB
#AutoIt3Wrapper_Res_Fileversion=1.5.1.87
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=Copyright Thibaut Lauziere a.k.a Sl�m
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Site|http://www.linuxliveusb.com
#AutoIt3Wrapper_AU3Check_Parameters=-w 4
#AutoIt3Wrapper_Run_After=upx.exe --best --compress-resources=0 "%out%"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $lang_ini = @ScriptDir & "\tools\settings\langs.ini"
Global $settings_ini = @ScriptDir & "\tools\settings\settings.ini"
Global $compatibility_ini = @ScriptDir & "\tools\settings\compatibility_list.ini"
Global $log_dir =  @ScriptDir & "\logs\"
Global $help_file_name = "Help.chm"
Global $help_available_langs = "en,fr,sp"
Global $lang, $anonymous_id
Global $downloaded_virtualbox_filename
; Global variables used for the onEvent Functions
; Globals images and GDI+ elements
Global $GUI,$CONTROL_GUI,$EXIT_BUTTON,$MIN_BUTTON,$DRAW_REFRESH,$DRAW_ISO,$DRAW_CD,$DRAW_DOWNLOAD,$DRAW_LAUNCH,$HELP_STEP1,$HELP_STEP2,$HELP_STEP3,$HELP_STEP4,$HELP_STEP5
Global 	$ZEROGraphic,$EXIT_NORM,$EXIT_OVER,$MIN_NORM,$MIN_OVER,$PNG_GUI,$CD_PNG,$CD_HOVER_PNG,$ISO_PNG,$ISO_HOVER_PNG,$DOWNLOAD_PNG,$DOWNLOAD_HOVER_PNG,$LAUNCH_PNG,$LAUNCH_HOVER_PNG,$HELP,$BAD,$GOOD,$WARNING

; Global variables for releases attributes
Global Const $R_CODE = 0,$R_NAME=1,$R_DISTRIBUTION=2, $R_DISTRIBUTION_VERSION=3,$R_FILENAME=4,$R_FILE_MD5=5,$R_RELEASE_DATE=6,$R_WEB=7,$R_DOWNLOAD_PAGE=8,$R_DOWNLOAD_SIZE=9,$R_INSTALL_SIZE=10,$R_DESCRIPTION=11
Global Const $R_MIRROR1=12,$R_MIRROR2=13,$R_MIRROR3=14,$R_MIRROR4=15,$R_MIRROR5=16,$R_MIRROR6=17,$R_MIRROR7=18,$R_MIRROR8=19,$R_MIRROR9=20,$R_MIRROR10=21,$R_VARIANT=22,$R_VARIANT_VERSION=23,$R_VISIBLE=24
Global $MD5_ISO, $compatible_md5, $compatible_filename,$release_number=-1


Opt("GUIOnEventMode", 1)

; Checking if Tools folder exists (contains tools and settings)
if DirGetSize(@ScriptDir & "\tools\",2 ) <> -1 Then
	If Not FileExists($lang_ini) Then
		MsgBox(48, "ERROR", "Language file not found !!!")
		Exit
	EndIf

	If Not FileExists($settings_ini) Then
		MsgBox(48, "ERROR", "Settings file not found !!!")
		Exit
	Else
		; Generate an unique ID for anonymous crash reports and stats
		If IniRead($settings_ini, "General", "unique_ID", "none") = "none" OR  IniRead($settings_ini, "General", "unique_ID", "none") = ""  Then
			$anonymous_id = Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1))
			IniWrite($settings_ini, "General", "unique_ID", $anonymous_id)
		Else
			$anonymous_id = IniRead($settings_ini, "General", "unique_ID", "none")
		EndIf
	EndIf
Else
		MsgBox(48, "ERROR", "Please put the 'tools' directory back")
		Exit
EndIf

; Unlock help file on Vista (because Vista will prevent opening it ... stupid)
UnlockHelp()


#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <Constants.au3>
#include <ProgressConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>
#include <About.au3>
#include <File.au3>
#include <md5.au3>
#include <INet.au3>
#include <ErrorHandler.au3>
#include <Ressources.au3>
#include <LiLis_heart.au3>

;                                   Version
Global $software_version = "2.0"

SendReport("Starting LiLi USB Creator" & $software_version)

_GDIPlus_Startup()



; If compiled, load the included resources else it will load files
#cs
If @Compiled == 1 Then
	; Chargement des ressources
	$EXIT_NORM = _ResourceGetAsImage("EXIT_NORM")
	$EXIT_OVER = _ResourceGetAsImage("EXIT_OVER")
	$MIN_NORM = _ResourceGetAsImage("MIN_NORM")
	$MIN_OVER = _ResourceGetAsImage("MIN_OVER")
	$BAD = _ResourceGetAsImage("BAD")
	$WARNING = _ResourceGetAsImage("WARNING")
	$GOOD = _ResourceGetAsImage("GOOD")
	$HELP = _ResourceGetAsImage("HELP")
	$CD_PNG = _ResourceGetAsImage("CD_PNG")
	$CD_HOVER_PNG = _ResourceGetAsImage("CD_HOVER_PNG")
	$ISO_PNG = _ResourceGetAsImage("ISO_PNG")
	$ISO_HOVER_PNG = _ResourceGetAsImage("ISO_HOVER_PNG")
	$DOWNLOAD_PNG = _ResourceGetAsImage("DOWNLOAD_PNG")
	$DOWNLOAD_HOVER_PNG = _ResourceGetAsImage("DOWNLOAD_HOVER_PNG")
	$LAUNCH_PNG = _ResourceGetAsImage("LAUNCH_PNG")
	$LAUNCH_HOVER_PNG = _ResourceGetAsImage("LAUNCH_HOVER_PNG")
	$REFRESH_PNG = _ResourceGetAsImage("REFRESH_PNG")
	$PNG_GUI = _ResourceGetAsImage("PNG_GUI_" & $lang)
Else 
#ce
	; Loading PNG Files
	$EXIT_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close.PNG")
	$EXIT_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close_hover.PNG")
	$MIN_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min.PNG")
	$MIN_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min_hover.PNG")
	$BAD = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\bad.png")
	$WARNING = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\warning.png")
	$GOOD = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\good.png")
	$HELP = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\help.png")
	$CD_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\cd.png")
	$CD_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\cd_hover.png")
	$ISO_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\iso.png")
	$ISO_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\iso_hover.png")
	$DOWNLOAD_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\download.png")
	$DOWNLOAD_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\download_hover.png")
	$LAUNCH_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\launch.png")
	$LAUNCH_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\launch_hover.png")
	$REFRESH_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\refresh.png")
	if FileExists(@ScriptDir & "\tools\img\GUI_" & $lang & ".png") Then
		$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_" & $lang & ".png")
	Else
		$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_English.png")
	EndIf



SendReport("Creating GUI")

$GUI = GUICreate("LiLi USB Creator", 450, 750, -1, -1, $WS_POPUP, $WS_EX_LAYERED)

SetBitmap($GUI, $PNG_GUI, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
GUISetState(@SW_SHOW, $GUI)

; Old offset was 18
$LAYERED_GUI_CORRECTION = GetVertOffset($GUI)
$CONTROL_GUI = GUICreate("CONTROL_GUI", 450, 750, 0, $LAYERED_GUI_CORRECTION, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)

; Offset for applied on every items
$offsetx0=27
$offsety0=23

; Clickable parts of images
$EXIT_AREA = GUICtrlCreateLabel("", 335+$offsetx0, -20+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Exit")
$MIN_AREA = GUICtrlCreateLabel("", 135+$offsetx0, -3+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Minimize")
$REFRESH_AREA = GUICtrlCreateLabel("", 300+$offsetx0, 145+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Refresh_Drives")
$ISO_AREA = GUICtrlCreateLabel("", 38+$offsetx0, 231+$offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Choose_ISO")
$CD_AREA = GUICtrlCreateLabel("", 146+$offsetx0, 231+$offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Choose_CD")
$DOWNLOAD_AREA = GUICtrlCreateLabel("", 260+$offsetx0, 230+$offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Download")
$LAUNCH_AREA = GUICtrlCreateLabel("", 35+$offsetx0, 600+$offsety0, 22, 43)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Launch_Creation")
$HELP_STEP1_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 105+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step1")
$HELP_STEP2_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 201+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step2")
$HELP_STEP3_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 339+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step3")
$HELP_STEP4_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 449+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step4")
$HELP_STEP5_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 562+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step5")

GUISetBkColor(0x121314)
_WinAPI_SetLayeredWindowAttributes($CONTROL_GUI, 0x121314)
GUISetState(@SW_SHOW, $CONTROL_GUI)



$ZEROGraphic = _GDIPlus_GraphicsCreateFromHWND($CONTROL_GUI)

; Firt display (initialization) of images 
$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)
$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
$DRAW_REFRESH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $REFRESH_PNG, 0, 0, 20, 20, 300+$offsetx0, 145+$offsety0, 20, 20)
$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)
$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)
$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)
$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)
$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 105+$offsety0, 20, 20)
$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 201+$offsety0, 20, 20)
$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 339+$offsety0, 20, 20)
$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 449+$offsety0, 20, 20)
$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 562+$offsety0, 20, 20)

; Put the state for the first 3 steps
Step1_Check("bad")
Step2_Check("bad")
Step3_Check("bad")

SendReport("Creating GUI (buttons)")

; Text for step 2
GUICtrlCreateLabel("ISO", 65+$offsetx0, 304+$offsety0, 20, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


GUICtrlCreateLabel("CD", 175+$offsetx0, 304+$offsety0, 20, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

GUICtrlCreateLabel(Translate("T�l�charger"), 262+$offsetx0, 304+$offsety0, 70, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Text and controls for step 3
$offsetx3 = 60
$offsety3 = 150
$label_min = GUICtrlCreateLabel("0 " & Translate("Mo"), 30 + $offsetx3+$offsetx0, 228 + $offsety3+$offsety0, 30, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$label_max = GUICtrlCreateLabel("?? " & Translate("Mo"), 250 + $offsetx3+$offsetx0, 228 + $offsety3+$offsety0, 50, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider = GUICtrlCreateSlider(60 + $offsetx3+$offsetx0, 225 + $offsety3+$offsety0, 180, 20)
GUICtrlSetLimit($slider, 0, 0)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Slider")
$slider_visual = GUICtrlCreateInput("0", 90 + $offsetx3+$offsetx0, 255 + $offsety3+$offsety0, 40, 20)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Input")
$slider_visual_Mo = GUICtrlCreateLabel(Translate("Mo"), 135 + $offsetx3+$offsetx0, 258 + $offsety3+$offsety0, 20, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider_visual_mode = GUICtrlCreateLabel(Translate("(Mode Live)"), 160 + $offsetx3+$offsetx0, 258 + $offsety3+$offsety0, 100, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Text and controls for step 4
$offsetx4 = 10
$offsety4 = 195
$hide_files = GUICtrlCreateCheckbox("", 30 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$hide_files_label = GUICtrlCreateLabel(Translate("Cacher les fichiers sur la cl�"), 50 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; No more reason to keep that option because menu is integrated on right click of the key
$except_wubi = GUICtrlCreateDummy()
;$except_wubi = GUICtrlCreateCheckbox("", 200 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 13, 13)
;$except_wubi_label = GUICtrlCreateLabel(Translate("(Sauf Umenu.exe)"), 220 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 200, 20)
;GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;GUICtrlSetColor(-1, 0xFFFFFF)

$formater = GUICtrlCreateCheckbox("", 30 + $offsetx4+$offsetx0, 305 + $offsety4+$offsety0, 13, 13)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Format_Key")
$formater_label = GUICtrlCreateLabel(Translate("Formater la cl� en FAT32 (Vos donn�es seront supprim�es!)"), 50 + $offsetx4+$offsetx0, 305 + $offsety4+$offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$virtualbox = GUICtrlCreateCheckbox("", 30 + $offsetx4+$offsetx0, 325 + $offsety4+$offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_NoVirtualization")
$virtualbox_label = GUICtrlCreateLabel(Translate("Permettre de lancer LinuxLive directement sous Windows (n�cessite internet)"), 50 + $offsetx4+$offsetx0, 325 + $offsety4+$offsety0, 300, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Text and controls for step 5
$label_step6_statut = GUICtrlCreateLabel("<- " & Translate("Cliquer l'�clair pour lancer l'installation"), 50 + $offsetx4+$offsetx0, 410 + $offsety4+$offsety0, 300, 60)
GUICtrlSetFont($label_step6_statut, 9, 800, 0, "Arial")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Filling the combo box with drive list
Global $combo
$combo = GUICtrlCreateCombo("-> " & Translate("Choisir une cl� USB"), 90+$offsetx0, 145+$offsety0, 200,-1,3)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Choose_Drive")
Refresh_DriveList()

; Setting up all global vars and local vars
Global $selected_drive, $logfile, $virtualbox_check, $virtualbox_size
Global $STEP1_OK, $STEP2_OK, $STEP3_OK
Global $DRAW_CHECK_STEP1, $DRAW_CHECK_STEP2, $DRAW_CHECK_STEP3
Global $MD5_FOLDER, $MD5_ISO, $version_in_file
Global $variante, $jackalope

$selected_drive = "->"
$file_set = 0;
$file_set_mode = "none"
$annuler = 0
$sysarg = " "
$combo_updated = 0

$STEP1_OK = 0
$STEP2_OK = 0
$STEP3_OK = 0

$MD5_FOLDER = "none"
$MD5_ISO = "none"
$version_in_file = "none"

; Sending anonymous statistics
SendStats()
SendReport(LogSystemConfig())

; initialize list of compatible releases
Get_Compatibility_List()
	
; Hovering Buttons
AdlibEnable ( "Control_Hover", 150 ) 

; Main part
While 1
	; Force retracing the combo box (bugfix)
	If $combo_updated <> 1 Then
		GUICtrlSetData($combo, GUICtrlRead($combo))
		$combo_updated = 1
	EndIf
	
	sleep(60000)
WEnd

Func DrawAll()
		$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)
		$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
		$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)
		$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)
		$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)
		$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)

		$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 105+$offsety0, 20, 20)
		$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 201+$offsety0, 20, 20)
		$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 339+$offsety0, 20, 20)
		$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 449+$offsety0, 20, 20)
		$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 562+$offsety0, 20, 20)
		Redraw_Traffic_Lights()
EndFunc

Func Redraw_Traffic_Lights()
		; Re-checking step (to retrace traffic lights)
		Select
			Case $STEP1_OK = 0
				Step1_Check("bad")
			Case $STEP1_OK = 1
				Step1_Check("good")
			Case $STEP1_OK = 2
				Step1_Check("warning")
			EndSelect
			Select
				Case $STEP2_OK = 0
					Step2_Check("bad")
				Case $STEP2_OK = 1
					Step2_Check("good")
				Case $STEP2_OK = 2
					Step2_Check("warning")
			EndSelect
			Select
				Case $STEP3_OK = 0
					Step3_Check("bad")
				Case $STEP3_OK = 1
					Step3_Check("good")
				Case $STEP3_OK = 2
					Step3_Check("warning")
			EndSelect
EndFunc
			

Func Control_Hover()
	Global $previous_hovered_control
    Local $CursorCtrl = GUIGetCursorInfo($CONTROL_GUI)
	if WinActive("CONTROL_GUI") OR WinActive("LiLi USB Creator")  Then
		Switch $previous_hovered_control
			case $EXIT_AREA
				$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)
			case $MIN_AREA
				$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
			case $ISO_AREA
				$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)
			case $CD_AREA
				$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)
			case $DOWNLOAD_AREA
				$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)
			case $LAUNCH_AREA
				$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)
		EndSwitch
		
		Switch $CursorCtrl[4]
			case $EXIT_AREA
				$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_OVER, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)
			case $MIN_AREA
				$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_OVER, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
			case $ISO_AREA
				$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_HOVER_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)
			case $CD_AREA
				$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_HOVER_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)
			case $DOWNLOAD_AREA
				$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_HOVER_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)
			case $LAUNCH_AREA
				$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_HOVER_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)
		EndSwitch
	EndIf
	$previous_hovered_control = $CursorCtrl[4]
EndFunc

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Files management                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func DirRemove2($arg1, $arg2)
	SendReport("Start-DirRemove2 ( " & $arg1 & " )")
	UpdateLog("Deleting folder : " & $arg1)
	If DirRemove($arg1, $arg2) Then
		UpdateLog("                   " & "Folder deleted")
	Else
		If DirGetSize($arg1) >= 0 Then
			UpdateLog("                   " & "Error while deleting")
		Else
			UpdateLog("                   " & "Folder not found")
		EndIf
	EndIf
	SendReport("End-DirRemove2")
EndFunc   

Func FileDelete2($arg1)
	SendReport("Start-FileDelete2 ( " & $arg1 & " )")
	UpdateLog("Deleting file : " & $arg1)
	If FileDelete($arg1) == 1 Then
		UpdateLog("                   " & "File deleted")
	Else
		If FileExists($arg1) Then
			UpdateLog("                   " & "Error while deleting")
		Else
			UpdateLog("                   " & "File not found")
		EndIf
	EndIf
	SendReport("End-FileDelete2")
EndFunc 

Func HideFile($file_or_folder) 
	SendReport("Start-HideFile ( " & $file_or_folder & " )")
	UpdateLog("Hiding file : " & $file_or_folder)
	If FileSetAttrib($file_or_folder,"+SH") == 1 Then
		UpdateLog("                   " & "File hided")
	Else
		If FileExists($file_or_folder) Then
			UpdateLog("                   " & "File not found")
		Else
			UpdateLog("                   " & "Error while hiding")
		EndIf
	EndIf
	SendReport("End-HideFile")
EndFunc

Func _FileCopy($fromFile, $tofile)
	SendReport("Start-_FileCopy")
	Local $FOF_RESPOND_YES = 16
	Local $FOF_SIMPLEPROGRESS = 256
	$winShell = ObjCreate("shell.application")
	$winShell.namespace($tofile).CopyHere($fromFile, $FOF_RESPOND_YES)
	SendReport("End-_FileCopy")
EndFunc  

Func _FileCopy2($arg1, $arg2)
	SendReport("Start-_FileCopy2 ( " & $arg1 & " -> " & $arg2 & " )")
	_FileCopy($arg1, $arg2)
	UpdateLog("Copying folder " & $arg1 & " to " & $arg2)
	SendReport("End-_FileCopy2")
EndFunc   

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Launching third party tools                       ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Run7zip($cmd, $taille)
	Local $foo, $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip ( " & $cmd & " )")
	
	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	$line = @CRLF
	
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("D�compression de l'ISO sur la cl�") & " ( � " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		$line &= StdoutRead($foo)
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip")
EndFunc   

Func Run7zip2($cmd, $taille)
	Local $foo, $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip2 ( " & $cmd & " )")
	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	$line = @CRLF
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("D�compression de VirtualBox sur la cl�") & " ( � " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		$line &= StdoutRead($foo)
		;UpdateStatus2($line)
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip2")
EndFunc  

Func RunDD($cmd, $taille)
	SendReport("Start-RunDD ( " & $cmd & " )")
	Local $foo, $line
	UpdateLog($cmd)
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
	$line = @CRLF
	While 1

		UpdateStatusNoLog(Translate("Cr�ation du fichier de persistance") & " ( " & Round(FileGetSize($selected_drive & "\casper-rw") / 1048576, 0) & "/" & Round($taille, 0) & " Mo )")
		$line &= StderrRead($foo)
		;UpdateStatus2($line)
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-RunDD")
EndFunc   

Func RunMke2fs()
	Local $foo, $line
	If ProcessExists("mke2fs.exe") > 0 Then ProcessClose("mke2fs.exe")
	$cmd = @ScriptDir & '\tools\mke2fs.exe -b 1024 ' & $selected_drive & '\casper-rw'
	SendReport("Start-RunMke2fs ( " & $cmd & " )")
	UpdateLog($cmd)
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	$line = @CRLF
	While 1
		$line &= StdoutRead($foo)
		StdinWrite($foo, "{ENTER}")
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-RunMke2fs")
EndFunc   

Func RunWait3($soft, $arg1, $arg2)
	SendReport("Start-RunWait3 ( " & $soft & " )")
	Local $line, $foo
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = @CRLF
	While True
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-RunWait3")
EndFunc   


Func Run2($soft, $arg1, $arg2)
	SendReport("Start-Run2 ( " & $soft & " )")
	Local $line, $foo
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = @CRLF
	While True
		$line = StdoutRead($foo)
		StdinWrite($foo, @CR & @LF & @CRLF)
		If @error Then ExitLoop
		Sleep(300)
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-Run2")
EndFunc  

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Disks Management                              ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Refresh_DriveList()
	SendReport("Start-Refresh_DriveList")
	; r�cup�re la liste des disques
	$drive_list = DriveGetDrive("REMOVABLE")
	$all_drives = "|-> " & Translate("Choisir une cl� USB") & "|"
	If Not @error Then
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If ((Not $fs = "") Or (Not $space = 0)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("Go") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-1")
	$drive_list = DriveGetDrive("FIXED")
	If Not @error Then
		$all_drives &= "-> " & Translate("Suite (disques durs)") & " -------------|"
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If ((Not $fs = "") Or (Not $space = 0)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("Go") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-2")
	If $all_drives <> "|-> " & Translate("Choisir une cl� USB") & "|" Then
		GUICtrlSetData($combo, $all_drives, "-> " & Translate("Choisir une cl� USB"))
		GUICtrlSetState($combo, $GUI_ENABLE)
	Else
		GUICtrlSetData($combo, "|-> " & Translate("Aucune cl� trouv�e"), "-> " & Translate("Aucune cl� trouv�e"))
		GUICtrlSetState($combo, $GUI_DISABLE)
	EndIf
	SendReport("End-Refresh_DriveList")
EndFunc   ;==>Refresh_DriveList

Func SpaceAfterLinuxLiveMB($disk)
	SendReport("Start-SpaceAfterLinuxLiveMB")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - 720
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			Return (4000)
		Else
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - 720
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			Return (4000)
		Else
			Return 0
		EndIf
	EndIf
	SendReport("End-SpaceAfterLinuxLiveMB")
EndFunc   ;==>SpaceAfterLinuxLiveMB

Func SpaceAfterLinuxLiveGB($disk)
	SendReport("Start-SpaceAfterLinuxLiveGB")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - 720
		If $spacefree >= 0 Then
			Return Round($spacefree / 1024, 1)
		Else
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - 720
		If $spacefree >= 0 Then
			Return Round($spacefree / 1024, 1)
		Else
			Return 0
		EndIf
	EndIf
	SendReport("End-SpaceAfterLinuxLiveGB")
EndFunc   ;==>SpaceAfterLinuxLiveGB

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Logs and status                               ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Func InitLog()
	Global $log_dir, $logfile
	DirCreate($log_dir)
	$logfile = @ScriptDir & "\logs\" & @MDAY & "-" & @MON & "-" & @YEAR & " (" & @HOUR & "h" & @MIN & "s" & @SEC & ").log"
	UpdateLog(LogSystemConfig())
	SendReport("logfile-" & $logfile )
EndFunc

Func LogSystemConfig()
	$mem = MemGetStats()
	$line = @CRLF & "--------------------------------  System Config  --------------------------------"
	$line &= @CRLF & "LiLi USB Creator : " & $software_version
	$line &= @CRLF & "OS Type : " & @OSTYPE
	$line &= @CRLF & "OS Version : " & @OSVersion
	$line &= @CRLF & "OS Build : " & @OSBuild
	$line &= @CRLF & "OS Service Pack : " & @OSServicePack
	$line &= @CRLF & "Architecture : " & @ProcessorArch
	$line &= @CRLF & "Memory : " & Round($mem[1] / 1024) & "MB  ( with " & (100 - $mem[0]) & "% free = " & Round($mem[2] / 1024) & "MB )"
	$line &= @CRLF & "Language : " & @OSLang
	$line &= @CRLF & "Keyboard : " & @KBLayout
	$line &= @CRLF & "Resolution : " & @DesktopWidth & "x" & @DesktopHeight
	;$line &= @CRLF & "Home drive : " &@HomeDrive
	If Ping("www.google.com") > 0 Then
		$line &= @CRLF & "Internet connected : YES"
	Else
		$line &= @CRLF & "Internet connected : NO"
	EndIf
	$line &= @CRLF & "Chosen Key : " & GUICtrlRead($combo)
	$line &= @CRLF & "Free space on key : " & Round(DriveSpaceFree($selected_drive)) & "MB"
	If $file_set_mode == "iso" Then
		$line &= @CRLF & "Selected ISO : " & path_to_name($file_set)
		$line &= @CRLF & "ISO Hash : " & $MD5_ISO
	Else
		$line &= @CRLF & "Selected source : " & $file_set
		$line &= @CRLF & "Folder Hash : " & $MD5_FOLDER
		$line &= @CRLF & "Linux Version : " & $version_in_file
	EndIf
	$line &= @CRLF & "Step Status : (STEP1=" & $STEP1_OK & ") (STEP2=" & $STEP2_OK & ") (STEP3=" & $STEP3_OK & ") "
	$line &= @CRLF & "------------------------------  End of system config  ------------------------------" & @CRLF
	Return $line
EndFunc   ;==>LogSystemConfig

Func UpdateStatus($status)
	SendReport(IniRead($lang_ini, "English", $status, $status))
	_FileWriteLog($logfile, "Status : " & Translate($status))
	GUICtrlSetData($label_step6_statut, Translate($status))
EndFunc   ;==>UpdateStatus

Func UpdateLog($status)
	_FileWriteLog($logfile, $status) ; No translation in logs
EndFunc   ;==>UpdateLog

Func UpdateStatusNoLog($status)
	GUICtrlSetData($label_step6_statut, Translate($status))
EndFunc   ;==>UpdateStatusNoLog

Func SendReport($report)
	_SendData($report, "lili-Reporter")
EndFunc   ;==>SendReport


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking steps states                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Func Step1_Check($etat)
	Global $STEP1_OK
	If $etat = "good" Then
		$STEP1_OK = 1
		$DRAW_CHECK_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338+$offsetx0, 150+$offsety0, 25, 40)
	Else
		$STEP1_OK = 0
		$DRAW_CHECK_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338+$offsetx0, 150+$offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step1_Check

Func Step2_Check($etat)
	Global $STEP2_OK
	If $etat = "good" Then
		$STEP2_OK = 1
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338+$offsetx0, 287+$offsety0, 25, 40)
	ElseIf $etat = "bad" Then
		$STEP2_OK = 0
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338+$offsetx0, 287+$offsety0, 25, 40)
	Else
		$STEP2_OK = 2
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $WARNING, 0, 0, 25, 40, 338+$offsetx0, 287+$offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step2_Check

Func Step3_Check($etat)
	Global $STEP3_OK
	If $etat = "good" Then
		$STEP3_OK = 1
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338+$offsetx0, 398+$offsety0, 25, 40)
	ElseIf $etat = "bad" Then
		$STEP3_OK = 0
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338+$offsetx0, 398+$offsety0, 25, 40)
	Else
		$STEP3_OK = 2
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $WARNING, 0, 0, 25, 40, 338+$offsetx0, 398+$offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step3_Check

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Creating boot menu                             ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func GetKbdCode()
	SendReport("Start-GetKbdCode")
	Select
		Case StringInStr("040c,080c,140c,180c", @OSLang)
			; FR
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (France)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_FR bootkbd=fr-latin1 console-setup/layoutcode=fr console-setup/variantcode=nodeadkeys "

		Case StringInStr("0c0c", @OSLang)
			; CA
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (Canada)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CA bootkbd=fr-latin1 console-setup/layoutcode=ca console-setup/variantcode=nodeadkeys "

		Case StringInStr("100c", @OSLang)
			; Suisse FR
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (Suisse)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CH bootkbd=fr-latin1 console-setup/layoutcode=ch console-setup/variantcode=fr "

		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			; German & dutch
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Allemand"))
			SendReport("End-GetKbdCode")
			Return "locale=de_DE bootkbd=de console-setup/layoutcode=de console-setup/variantcode=nodeadkeys "

		Case StringInStr("0816", @OSLang)
			; Portugais
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Portugais"))
			SendReport("End-GetKbdCode")
			Return "locale=pt_BR bootkbd=qwerty/br-abnt2 console-setup/layoutcode=br console-setup/variantcode=nodeadkeys "
			
		Case StringInStr("0410,0810", @OSLang)
			; Italien
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Italian"))
			SendReport("End-GetKbdCode")
			Return "locale=it_IT bootkbd=it console-setup/layoutcode=it console-setup/variantcode=nodeadkeys "
		Case Else
			; US
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("US ou autres (qwerty)"))
			SendReport("End-GetKbdCode")
			Return "locale=us_us bootkbd=us console-setup/layoutcode=en_US console-setup/variantcode=nodeadkeys "
	EndSelect

EndFunc   ;==>GetKbdCode


Func Get_Disk_UUID($drive_letter)
	Dim $oWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	$o_ColListOfProcesses = $oWMIService.ExecQuery ("SELECT * FROM Win32_LogicalDisk WHERE Name = '" & $drive_letter & "'")
	For $o_ObjProcess in $o_ColListOfProcesses
		$uuid = $o_ObjProcess.VolumeSerialNumber
	Next
	if StringLen($uuid) < 5 Then $uuid = "802B84D8"
	Return $uuid
EndFunc


Func WriteTextCFG($selected_drive,$variant)
	SendReport("Start-WriteTextCFG")
	Local $boot_text, $kbd_code
	$boot_text = ""
	$kbd_code = GetKbdCode()

	if $variant = "mint" then 
		$boot_text = "default vesamenu.c32" _
		& @LF &  "timeout 100" _
		& @LF &  "menu background splash.jpg" _
		& @LF &  "menu title Welcome to Linux Mint" _
		& @LF &  "menu color border 0 #00eeeeee #00000000" _
		& @LF &  "menu color sel 7 #ffffffff #33eeeeee" _
		& @LF &  "menu color title 0 #ffeeeeee #00000000" _
		& @LF &  "menu color tabmsg 0 #ffeeeeee #00000000" _
		& @LF &  "menu color unsel 0 #ffeeeeee #00000000" _
		& @LF &  "menu color hotsel 0 #ff000000 #ffffffff" _
		& @LF &  "menu color hotkey 7 #ffffffff #ff000000" _
		& @LF &  "menu color timeout_msg 0 #ffffffff #00000000" _
		& @LF &  "menu color timeout 0 #ffffffff #00000000" _
		& @LF &  "menu color cmdline 0 #ffffffff #00000000" _
		& @LF &  "menu hidden" _
		& @LF &  "menu hiddenrow 5"
	Elseif $variant = "custom" Then
		$boot_text &=  "DISPLAY isolinux.txt" _
					 & @LF & "TIMEOUT 300" _
					 & @LF & "PROMPT 1" _
					 & @LF & "default persist" 
	Else
		$boot_text &=  @LF & "default persist" 
	EndIf
	
	$boot_text &=  @LF & "label persist" & @LF & "menu label ^" & Translate("Mode Persistant") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append  " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $variant & ".seed boot=casper initrd=/casper/initrd.gz splash--" _
			 & @LF & "label live" _
			 & @LF & "  menu label ^" & Translate("Mode Live") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true file=/cdrom/preseed/" & $variant & ".seed boot=casper initrd=/casper/initrd.gz splash--" _
			 & @LF & "label live-install" _
			 & @LF & "  menu label ^" & Translate("Installer") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $variant & ".seed boot=casper only-ubiquity initrd=/casper/initrd.gz splash --" _
			 & @LF & "label check" _
			 & @LF & "  menu label ^" & Translate("Verification des fichiers") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt boot=casper integrity-check initrd=/casper/initrd.gz splash --" _
			 & @LF & "label memtest" _
			 & @LF & "  menu label ^" & Translate("Test de la RAM") _
			 & @LF & "  kernel /install/mt86plus"
	UpdateLog("Creating syslinux config file :" & @CRLF & $boot_text) 
		$file = FileOpen($selected_drive & "\syslinux\text.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	if $variant = "mint" OR $variant = "custom" then 
		$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	EndIf
	
	if $variant = "custom" then 
		FileDelete2($selected_drive & "\syslinux\isolinux.txt")
		FileCopy(@ScriptDir & "\tools\crunchbang-isolinux.txt", $selected_drive & "\syslinux\isolinux.txt", 1)
	EndIf
	
		$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	SendReport("End-WriteTextCFG")
EndFunc   ;==>WriteTextCFG

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Graphical Part                                ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func GetVertOffset($hgui)
;Const $SM_CYCAPTION = 4
    Const $SM_CXFIXEDFRAME = 7
    Local $wtitle, $wclient, $wsize,$wside,$ans
    $wclient = WinGetClientSize($hgui)
    $wsize = WinGetPos($hgui)
    $wtitle = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CYCAPTION)
    $wside = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CXFIXEDFRAME)
    $ans = $wsize[3] - $wclient[1] - $wtitle[0] - 2 * $wside[0] +25
    Return $ans
EndFunc  ;==>GetVertOffset

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If ($hWnd = $GUI) And ($iMsg = $WM_NCHITTEST) Then Return $HTCAPTION
EndFunc   ;==>WM_NCHITTEST

Func SetBitmap($hGUI, $hImage, $iOpacity)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend

	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
	DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", $iOpacity)
	DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
	_WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetBitmap



Global Const $LWA_ALPHA = 0x2
Global Const $LWA_COLORKEY = 0x1

;############# EndExample #########

;===============================================================================
;
; Function Name: _WinAPI_SetLayeredWindowAttributes
; Description:: Sets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Transparent color
; $Transparency - Set Transparancy of GUI
; $isColorRef - If True, $i_transcolor is a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: 1
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed - use
; _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ SetLayeredWindowAttributes
; Example : Yes
;===============================================================================
;
Func _WinAPI_SetLayeredWindowAttributes($hWnd, $i_transcolor, $Transparency = 255, $dwFlages = 0x03, $isColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	If $dwFlages = Default Or $dwFlages = "" Or $dwFlages < 0 Then $dwFlages = 0x03

	If Not $isColorRef Then
		$i_transcolor = Hex(String($i_transcolor), 6)
		$i_transcolor = Execute('0x00' & StringMid($i_transcolor, 5, 2) & StringMid($i_transcolor, 3, 2) & StringMid($i_transcolor, 1, 2))
	EndIf
	Local $Ret = DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hWnd, "long", $i_transcolor, "byte", $Transparency, "long", $dwFlages)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			Return 1
	EndSelect
EndFunc   ;==>_WinAPI_SetLayeredWindowAttributes

;===============================================================================
;
; Function Name: _WinAPI_GetLayeredWindowAttributes
; Description:: Gets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Returns Transparent color ( dword as 0x00bbggrr or string "0xRRGGBB")
; $Transparency - Returns Transparancy of GUI
; $isColorRef - If True, $i_transcolor will be a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: Usage of LWA_ALPHA and LWA_COLORKEY (use BitAnd)
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed
; - use _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; - @extended contains _WinAPI_GetLastError
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ GetLayeredWindowAttributes
; Example : Yes
;===============================================================================
;
Func _WinAPI_GetLayeredWindowAttributes($hWnd, ByRef $i_transcolor, ByRef $Transparency, $asColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	$i_transcolor = -1
	$Transparency = -1
	Local $Ret = DllCall("user32.dll", "int", "GetLayeredWindowAttributes", "hwnd", $hWnd, "long*", $i_transcolor, "byte*", $Transparency, "long*", 0)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			If Not $asColorRef Then
				$Ret[2] = Hex(String($Ret[2]), 6)
				$Ret[2] = '0x' & StringMid($Ret[2], 5, 2) & StringMid($Ret[2], 3, 2) & StringMid($Ret[2], 1, 2)
			EndIf
			$i_transcolor = $Ret[2]
			$Transparency = $Ret[3]
			Return $Ret[4]
	EndSelect
EndFunc   ;==>_WinAPI_GetLayeredWindowAttributes

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking ISO/File MD5 Hashes                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Check_iso_integrity($linux_live_file)
	SendReport("Start-Check_iso_integrity")

	Global $MD5_ISO, $compatible_md5, $compatible_filename,$release_number=-1
	If IniRead($settings_ini, "General", "skip_checking", "no") == "yes" Then
		Step2_Check("good")
		Return ""
	EndIf

	$shortname = path_to_name($linux_live_file)

	If Check_if_version_non_grata($shortname) Then Return ""
	SendReport("Start-MD5_ISO")
	$MD5_ISO = MD5_ISO($linux_live_file)
	SendReport("End-MD5_ISO")
	$temp_index = _ArraySearch($compatible_md5,$MD5_ISO) 
	
	if  $temp_index > 0 Then 
		; Good version -> COMPATIBLE
		MsgBox(4096, Translate("V�rification") & " OK", Translate("La version est compatible et le fichier est valide"))
		Step2_Check("good")
		$release_number=$temp_index
	Else 
		$temp_index = _ArraySearch($compatible_filename,$shortname)
		if $temp_index > 0 Then
			; Filename is known but MD5 not OK -> COMPATIBLE BUT ERROR
			MsgBox(48, Translate("Attention"), Translate("Vous avez la bonne version de Linux mais elle est corrompue ou a �t� modifi�e.") & @CRLF & Translate("Merci de la t�l�charger � nouveau"))
			Step2_Check("warning")
			$release_number=$temp_index
		Else
			; Filename is not known and MD5 is not OK -> NOT COMPATIBLE
			MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("Merci de v�rifier la liste de compatibilit� dans le guide d'utilisation.") & @CRLF & Translate("Si votre version est bien dans la liste c'est que le fichier est corrompu et qu'il faut le t�l�charger � nouveau"))
			Step2_Check("warning")
			$release_number=-1
		EndIf
	EndIf
	DisplayRelease($release_number)
	SendReport("End-Check_iso_integrity")
EndFunc   ;==>Check_iso_integrity

Func Check_if_version_non_grata($ubuntu_version)
	SendReport("Start-Check_if_version_non_grata")
	If StringInStr($ubuntu_version, "8.04") Or StringInStr($ubuntu_version, "7.10") Or StringInStr($ubuntu_version, "6.06") Or StringInStr($ubuntu_version, "amd64") Or StringInStr($ubuntu_version, "sparc") Then
		MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("Merci de v�rifier la liste de compatibilit� dans le guide d'utilisation."))
		Step2_Check("warning")
		SendReport("End-Check_if_version_non_grata (is Non grata)")
		Return 1
	ElseIf StringInStr($ubuntu_version, "9.04") Then
		$jackalope = 1
	EndIf
	SendReport("End-Check_if_version_non_grata (is not Non grata)")
EndFunc   ;==>Check_if_version_non_grata

Func MD5_ISO($FileName)
	ProgressOn(Translate("V�rification"), Translate("V�rification de l'int�grit� + compatibilit�"), "0 %", -1, -1, 16)
	Global $BufferSize = 0x20000
	If $FileName = "" Then
		SendReport("End-MD5_ISO (no iso)")
		Return "no iso"
	EndIf

	Global $FileHandle = FileOpen($FileName, 16)

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileName) / $BufferSize)
	For $i = 1 To $iterations
		_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
		$percent_md5 = Round(100 * $i / $iterations)
		ProgressSet($percent_md5, $percent_md5 & " %")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)

	ProgressSet(100, "100%", Translate("V�rification termin�e"))
	Sleep(500)
	ProgressOff()
	Return StringTrimLeft($hash, 2)
EndFunc   ;==>MD5_ISO


Func Check_folder_integrity($folder)
	SendReport("Start-Check_folder_integrity")
	Global $version_in_file, $MD5_FOLDER
	If IniRead($settings_ini, "General", "skip_checking", "no") == "yes" Then
		Step2_Check("good")
		SendReport("End-Check_folder_integrity (skip)")
		Return ""
	EndIf

	$info_file = FileOpen($folder & "\.disk\info", 0)
	If $info_file <> -1 Then
		$version_in_file = FileReadLine($info_file)
		FileClose($info_file)
		If Check_if_version_non_grata($version_in_file) Then Return ""
	EndIf
	
	Global $progression_foldermd5
	$file = FileOpen($folder & "\md5sum.txt", 0)
	If $file = -1 Then
		MsgBox(0, Translate("Erreur"), Translate("Impossible d'ouvrir le fichier md5sum.txt"))
		FileClose($file)
		Step2_Check("warning")
		Return ""
	EndIf
	$progression_foldermd5 = ProgressOn(Translate("V�rification"), Translate("V�rification de l'int�grit�"), "0 %", -1, -1, 16)
	$corrupt = 0
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		$array_hash = StringSplit($line, '  .', 1)
		$file_to_hash = $folder & StringReplace($array_hash[2], "/", "\")
		$file_md5 = MD5_FOLDER($file_to_hash)
		If ($file_md5 <> $array_hash[1]) Then
			ProgressOff()
			FileClose($file)
			MsgBox(48, Translate("Erreur"), Translate("Le fichier suivant est corrumpu") & " : " & $file_to_hash)
			Step2_Check("warning")
			$corrupt = 1
			$MD5_FOLDER = "bad file :" & $file_to_hash
			ExitLoop
		EndIf
	WEnd
	ProgressSet(100, "100%", Translate("V�rification termin�e"))
	Sleep(500)
	ProgressOff()
	If $corrupt = 0 Then
		MsgBox(4096, Translate("V�rification termin�e"), Translate("Toutes les fichiers sont bons."))
		Step2_Check("good")
		$MD5_FOLDER = "Good"
	EndIf
	FileClose($file)
	SendReport("End-Check_folder_integrity")
EndFunc   ;==>Check_folder_integrity


Func MD5_FOLDER($FileName)
	Global $progression_foldermd5
	Global $BufferSize = 0x20000

	If $FileName = "" Then
		SendReport("End-MD5_FOLDER (no folder)")
		Return "no iso"
	EndIf

	Global $FileHandle = FileOpen($FileName, 16)

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileName) / $BufferSize)
	For $i = 1 To $iterations
		_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
		$percent_md5 = Round(100 * $i / $iterations)
		ProgressSet($percent_md5, Translate("V�rification du fichier") & " " & path_to_name($FileName) & " (" & $percent_md5 & " %)")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)

	Return StringTrimLeft($hash, 2)
EndFunc   ;==>MD5_FOLDER

Func path_to_name($filepath)
	$short_name = StringSplit($filepath, '\')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>path_to_name

Func unix_path_to_name($filepath)
	$short_name = StringSplit($filepath, '/')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>unix_path_to_name

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Locales management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func _Language()
	SendReport("Start-_Language")
	#cs
		Case StringInStr("0413,0813", @OSLang)
		Return "Dutch"
		
		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009, 2409,2809,2c09,3009,3409", @OSLang)
		Return "English"
		
		Case StringInStr("0410,0810", @OSLang)
		Return "Italian"
		
		Case StringInStr("0414,0814", @OSLang)
		Return "Norwegian"
		
		Case StringInStr("0415", @OSLang)
		Return "Polish"
		
		Case StringInStr("0416,0816", @OSLang)
		Return "Portuguese";
		
		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a, 440a,480a,4c0a,500a", @OSLang)
		Return "Spanish"
		
		Case StringInStr("041d,081d", @OSLang)
		Return "Swedish"
	#ce

	$force_lang = IniRead($settings_ini, "General", "force_lang", "no")
	$temp = IniReadSectionNames($lang_ini)
	$available_langs = _ArrayToString($temp)
	If $force_lang <> "no" And (StringInStr( $available_langs, $force_lang) > 0) Then
		SendReport("End-_Language (Force Lang)")
		Return $force_lang
	EndIf
	Select
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			SendReport("End-_Language (FR)")
			Return "French"
		Case StringInStr("0403,040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", @OSLang)
			SendReport("End-_Language (SP)")
			Return "Spanish"
		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			SendReport("End-_Language (GE)")
			Return "German"	
		Case StringInStr("0410,0810", @OSLang)
			Return "Italian"			
		Case Else
			SendReport("End-_Language (EN)")
			Return "English"
	EndSelect
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Statistics                                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func SendStats()
	Global $anonymous_id
	SendReport("stats-id=" & $anonymous_id & "&version=" & $software_version & "&os=" & @OSVersion & "-" & @ProcessorArch & "-" & @OSServicePack & "&lang=" & _Language_for_stats())
EndFunc   ;==>SendStats

Func _Language_for_stats()
	Select
		Case StringInStr("0413,0813", @OSLang)
			Return "Dutch"

		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009, 2409,2809,2c09,3009,3409", @OSLang)
			Return "English"

		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			Return "German"

		Case StringInStr("0410,0810", @OSLang)
			Return "Italian"

		Case StringInStr("0414,0814", @OSLang)
			Return "Norwegian"

		Case StringInStr("0415", @OSLang)
			Return "Polish"

		Case StringInStr("0416,0816", @OSLang)
			Return "Portuguese";

		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a, 240a,280a,2c0a,300a,340a,380a,3c0a,400a, 440a,480a,4c0a,500a", @OSLang)
			Return "Spanish"

		Case StringInStr("041d,081d", @OSLang)
			Return "Swedish"

		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			Return "French";remove and return function specifally to oslang
		Case Else
			Return @OSLang
	EndSelect
EndFunc   ;==>_Language_for_stats



; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Help file management                          ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Unlock help file with vista
Func UnlockHelp()
	Global $help_file_name
	If FileExists($help_file_name) Then
		IniWrite($help_file_name&":Zone.Identifier", "ZoneTransfer", "ZoneId", 5)
	EndIf
EndFunc
	
; Open help file with right page and locale
Func OpenHelpPage($page)
	Global $help_file_name, $lang
	$short_lang = StringLower(StringLeft($lang,2))
	if StringInStr($help_available_langs,$short_lang)==0 then $short_lang = "en" 
		
	If FileExists($help_file_name) Then
		Run(@ComSpec & " /c " & 'hh.exe mk:@MSITStore:' & $help_file_name & '::/' & $page & '_' & $short_lang & '.html', "", @SW_HIDE)
	Else
		MsgBox(48, Translate("Erreur"), Translate("Le fichier d'aide n'est pas pr�sent dans le dossier."))
	EndIf
EndFunc

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Buttons handling                        ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Clickable parts of images
Func GUI_Exit()

	GUIDelete($CONTROL_GUI)
	GUIDelete($GUI)
	_GDIPlus_GraphicsDispose($ZEROGraphic)
	_GDIPlus_ImageDispose($EXIT_NORM)
	_GDIPlus_ImageDispose($EXIT_OVER)
	_GDIPlus_ImageDispose($MIN_NORM)
	_GDIPlus_ImageDispose($MIN_OVER)
	_GDIPlus_ImageDispose($PNG_GUI)
	_GDIPlus_ImageDispose($CD_PNG)
	_GDIPlus_ImageDispose($CD_HOVER_PNG)
	_GDIPlus_ImageDispose($ISO_PNG)
	_GDIPlus_ImageDispose($ISO_HOVER_PNG)
	_GDIPlus_ImageDispose($DOWNLOAD_PNG)
	_GDIPlus_ImageDispose($DOWNLOAD_HOVER_PNG)
	_GDIPlus_ImageDispose($LAUNCH_PNG)
	_GDIPlus_ImageDispose($LAUNCH_HOVER_PNG)
	_GDIPlus_ImageDispose($HELP)
	_GDIPlus_ImageDispose($BAD)
	_GDIPlus_ImageDispose($GOOD)
	_GDIPlus_ImageDispose($WARNING)
	_GDIPlus_Shutdown()
	 Exit
EndFunc

Func GUI_Minimize()
	GUISetState(@SW_MINIMIZE,$GUI) 
EndFunc

Func GUI_Choose_Drive()
		$selected_drive = StringLeft(GUICtrlRead($combo), 2)
		If ( StringInStr(DriveGetFileSystem($selected_drive),"FAT") >=1 And SpaceAfterLinuxLiveMB($selected_drive) > 0 ) Then
			; State is OK ( FAT32 or FAT format and 700MB+ free)
			Step1_Check("good")

			If GUICtrlRead($slider) > 0 Then
				GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
				GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
				; State is OK ( FAT32 or FAT format and 700MB+ free) and warning for live mode only on step 3
				Step3_Check("good")
				SendReport(LogSystemConfig())
			Else
				GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
				GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
				; State is OK but warning for live mode only on step 3
				Step3_Check("warning")
				SendReport(LogSystemConfig())
			EndIf

		ElseIf ( StringInStr(DriveGetFileSystem($selected_drive),"FAT") <=0 And GUICtrlRead($formater) <> $GUI_CHECKED ) Then

			MsgBox(4096, "", Translate("Veuillez choisir un disque format� en FAT32 ou FAT ou cocher l'option de formatage"))

			; State is NOT OK (no selected key)
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			Step1_Check("bad")

			; State for step 3 is NOT OK according to step 1
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			GUICtrlSetLimit($slider, 0, 0)
			Step3_Check("bad")
		Else
			If (DriveGetFileSystem($selected_drive) = "") Then
				MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun disque"))
			EndIf
			; State is NOT OK (no selected key)
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			Step1_Check("bad")

			; State for step 3 is NOT OK according to step 1
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			GUICtrlSetLimit($slider, 0, 0)
			Step3_Check("bad")
		EndIf
EndFunc

Func GUI_Refresh_Drives()
	Refresh_DriveList()
	Finish_Help("G:")
EndFunc

Func GUI_Choose_ISO()
	SendReport("Start-ISO_AREA")
	$iso_file = FileOpenDialog(Translate("Choisir l'image ISO d'un CD live de Linux"), @ScriptDir & "\", "ISO (*.iso)", 1)
	If @error Then
		SendReport("IN-ISO_AREA (no iso)")
		MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun fichier"))
		$file_set = 0;
		Step2_Check("bad")
	Else
		SendReport("IN-ISO_AREA (iso selected :" & $iso_file & ")")
		$file_set = $iso_file
		$file_set_mode = "iso"
		Check_iso_integrity($file_set)
		SendReport(LogSystemConfig())
	EndIf
	SendReport("End-ISO_AREA")	
EndFunc

Func GUI_Choose_CD()
		SendReport("Start-CD_AREA")
		$folder_file = FileSelectFolder(Translate("S�lectionner le CD live de Linux ou son r�pertoire"), "")
		If @error Then
			SendReport("IN-CD_AREA (no CD)")
			MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun CD ou dossier"))
			Step2_Check("bad")
			$file_set = 0;
		Else
			SendReport("IN-CD_AREA (CD selected :" & $folder_file & ")")
			$file_set = $folder_file;
			$file_set_mode = "folder"
			Check_folder_integrity($folder_file)
			SendReport(LogSystemConfig())
		EndIf
		SendReport("End-CD_AREA")
EndFunc

Func GUI_Download()
	ShellExecute(Translate("http://www.ubuntu-fr.org/telechargement"))
EndFunc

Func GUI_Persistence_Slider()
	If GUICtrlRead($slider) > 0 Then
		GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
		GUICtrlSetData($slider_visual_mode, Translate("(Mode Persistant)"))
		; State is OK (value > 0)
		Step3_Check("good")
	Else
		GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
		GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
		; State is OK but warning (value = 0)
		Step3_Check("warning")
	EndIf
EndFunc

Func GUI_Persistence_Input()
		$selected_drive = StringLeft(GUICtrlRead($combo), 2)
		If StringIsInt(GUICtrlRead($slider_visual)) And GUICtrlRead($slider_visual) <= SpaceAfterLinuxLiveMB($selected_drive) And GUICtrlRead($slider_visual) > 0 Then
			GUICtrlSetData($slider, Round(GUICtrlRead($slider_visual) / 10))
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Persistant)"))
			; State is  OK (persistent mode)
			Step3_Check("good")
		ElseIf GUICtrlRead($slider_visual) = 0 Then
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
			; State is WARNING (live mode only)
			Step3_Check("warning")
		Else
			GUICtrlSetData($slider, 0)
			GUICtrlSetData($slider_visual, 0)
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
			; State is WARNING (live mode only)
			Step3_Check("warning")
		EndIf
EndFunc

Func GUI_Format_Key()
		If GUICtrlRead($formater) == $GUI_CHECKED Then
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
		Else
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
		EndIf

		; update the combo box (listing drives)
		If ( ( StringInStr(DriveGetFileSystem($selected_drive),"FAT") >=1 Or GUICtrlRead($formater) == $GUI_CHECKED ) And SpaceAfterLinuxLiveMB($selected_drive) > 0 ) Then
			; State is OK ( FAT32 or FAT format and 700MB+ free)
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
			Step1_Check("good")

		ElseIf (StringInStr(DriveGetFileSystem($selected_drive),"FAT") <=0 And GUICtrlRead($formater) <> $GUI_CHECKED ) Then
			MsgBox(4096, "", Translate("Veuillez choisir un disque format� en FAT32 ou FAT ou cocher l'option de formatage"))
			GUICtrlSetData($label_max, "?? Mo")
			Step1_Check("bad")

		Else
			If (DriveGetFileSystem($selected_drive) = "") Then
				MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun disque"))
			EndIf
			;State is NOT OK (no selected key)
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			Step1_Check("bad")

		EndIf
EndFunc

Func GUI_NoVirtualization()
EndFunc

Func GUI_Launch_Creation()
			SendReport("Start-LAUNCH_AREA")
		SendReport(LogSystemConfig())

		$selected_drive = StringLeft(GUICtrlRead($combo), 2)

		UpdateStatus("D�but de la cr�ation du LinuxLive USB")
		
		If $STEP1_OK >= 1 And $STEP2_OK >= 1 And $STEP3_OK >= 1 Then
			$annuler = 0
		Else
			$annuler = 2
			UpdateStatus("Veuillez valider les �tapes 1 � 3")
		EndIf
		
		; Initializing log file
		InitLog()

		; Format option has been selected
		If (GUICtrlRead($formater) == $GUI_CHECKED) And $annuler <> 2 Then
			$annuler = 0
			$annuler = MsgBox(49, Translate("Attention") & "!!!", Translate("Voulez-vous vraiment continuer et formater le disque suivant ?") & @CRLF & @CRLF & "       " & Translate("Nom") & " : ( " & $selected_drive & " ) " & DriveGetLabel($selected_drive) & @CRLF & "       " & Translate("Taille") & " : " & Round(DriveSpaceTotal($selected_drive) / 1024, 1) & " " & Translate("Go") & @CRLF & "       " & Translate("Formatage") & " : " & DriveGetFileSystem($selected_drive) & @CRLF)
			If $annuler = 1 Then
				Format_FAT32($selected_drive)
			EndIf
		EndIf

		; Starting creation if not cancelled
		If $annuler <> 2 Then

			UpdateStatus("Etape 1 � 3 valides")

			If GUICtrlRead($formater) <> $GUI_CHECKED  Then Clean_old_installs($selected_drive,$release_number)

			If GUICtrlRead($virtualbox) == $GUI_CHECKED Then $virtualbox_check = Download_virtualBox()

			; Uncompressing ou copying files on the key
			If $file_set_mode = "iso" Then
				Uncompress_ISO_on_key($selected_drive,$file_set,$release_number)
			Else
				Copy_live_files_on_key($selected_drive,$file_set)
			EndIf
			
			Rename_and_move_files($selected_drive, $release_number)
		
			Create_boot_menu($selected_drive,$release_number)

			Create_persistence_file($selected_drive,$release_number,GUICtrlRead($slider_visual),GUICtrlRead($hide_files)) 

			Install_boot_sectors($selected_drive)
			
			If (GUICtrlRead($hide_files) == $GUI_CHECKED) Then Hide_live_files($selected_drive)


			If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then
				
				If $virtualbox_check <> 2 Then Check_virtualbox_download()
				
				; maybe check downloaded file ?
				
				; Next step : uncompressing vbox on the key
				Uncompress_virtualbox_on_key($selected_drive)
				
				;UpdateStatus("Configuration de VirtualBox Portable")
				;SetupVirtualBox($selected_drive & "\Portable-VirtualBox", $selected_drive)
				
				;Run($selected_drive & "\Portable-VirtualBox\Launch_usb.exe", @ScriptDir, @SW_HIDE)

			EndIf
			
			; Create Autorun menu
			Create_autorun($selected_drive,"test")
			
			; Creation is now done
			UpdateStatus("Votre cl� LinuxLive est maintenant pr�te !")

			If $virtualbox_check >= 1 Then Final_check()
			
			sleep(1000)
			$gui_finish = GUICreate (Translate("Votre cl� LinuxLive est maintenant pr�te !"), 604, 378 , -1, -1)

			GUICtrlCreatePic(@ScriptDir & "\tools\img\tuto.jpg", 350, 0, 254, 378)
			$printme = @CRLF & @CRLF& @CRLF & @CRLF& "  " & Translate("Votre cl� LinuxLive est maintenant pr�te !") _
			& @CRLF & @CRLF & "    "  &Translate("Pour lancer LinuxLive :") _
			& @CRLF & "    " &Translate("Retirez votre cl� et r�ins�rez-la.") _
			& @CRLF & "    " &Translate("Allez ensuite dans 'Poste de travail'.") _
			& @CRLF & "    " &Translate("Faites un clic droit sur votre cl� et s�lectionnez :") & @CRLF 
			
			if FileExists($selected_drive & "\VirtualBox\Virtualize_This_Key.exe") AND FileExists($selected_drive & "VirtualBox\VirtualBox.exe") then
				$printme &= @CRLF & "    " &"-> "& Translate("'LinuxLive!' pour lancer la cl� directement dans windows") 
				$printme &= @CRLF  & "    " & "-> " &Translate("'VirtualBox Interface' pour lancer l'interface compl�te de VirtalBox") 
			EndIf
			$printme &= @CRLF  & "    " & "-> " &Translate("'CD Menu' pour lancer le menu original du CD")
			GUICtrlCreateLabel($printme, 0, 0, 370, 378)
			GUICtrlSetBkColor(-1, 0x0ffffff) 
			GUICtrlSetFont (-1, 10, 600)
			$Button_2 = GUICtrlCreateButton("Button Test",10, 30, 100)
			GUICtrlSetOnEvent($Button_2,"biou")
			
			GUISetState(@SW_SHOW)
			While 1
				sleep(1000)
			WEnd
		Else
			UpdateStatus("Veuillez valider les �tapes 1 � 3")
		EndIf
		SendReport("End-LAUNCH_AREA")
EndFunc


Func GUI_Help_Step1()
	OpenHelpPage("etape1")
EndFunc

Func GUI_Help_Step2()
	OpenHelpPage("etape2")
EndFunc

Func GUI_Help_Step3()
	OpenHelpPage("etape3")
EndFunc

Func GUI_Help_Step4()
	OpenHelpPage("etape4")
EndFunc

Func GUI_Help_Step5()
	_About(Translate("A propos"), "LiLi USB Creator", "Copyright � " & @YEAR & " Thibaut Lauzi�re. All rights reserved.", $software_version, Translate("Guide d'utilisation"), "User_Guide", Translate("Homepage"), "http://www.linuxliveusb.com", Translate("Faire un don"), "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=1195284", @AutoItExe, 0x0000FF, 0xFFFFFF, -1, -1, -1, -1, $CONTROL_GUI)	
EndFunc

Func Get_Compatibility_List()
	$sections = IniReadSectionNames($compatibility_ini)
	If (Not IsArray($sections)) Or (Not FileExists($compatibility_ini)) Then
		MsgBox(32,"","Le fichier de releases "&$compatibility_ini&" est introuvable ou vide.")
		GUI_Exit()
	EndIf
	
	Global $releases[$sections[0]+1][30],$compatible_md5[$sections[0]+1],$compatible_filename[$sections[0]+1]
	
	For $i=1 to $sections[0]
		$releases[$i][$R_CODE]=$sections[$i]
		$releases[$i][$R_NAME]=IniRead($compatibility_ini, $sections[$i], "Name","NotFound")
		$releases[$i][$R_DISTRIBUTION]=IniRead($compatibility_ini, $sections[$i], "Distribution","NotFound")
		$releases[$i][$R_DISTRIBUTION_VERSION]=IniRead($compatibility_ini, $sections[$i], "Distribution_Version","NotFound")
		$releases[$i][$R_VARIANT]=IniRead($compatibility_ini, $sections[$i], "Variant","NotFound")
		$releases[$i][$R_VARIANT_VERSION]=IniRead($compatibility_ini, $sections[$i], "Variant_Version","NotFound")
		$releases[$i][$R_FILENAME]=IniRead($compatibility_ini, $sections[$i], "Filename","NotFound")
		$compatible_filename[$i]=IniRead($compatibility_ini, $sections[$i], "Filename","NotFound")
		$releases[$i][$R_FILE_MD5]=IniRead($compatibility_ini, $sections[$i], "File_MD5","NotFound")
		$compatible_md5[$i]=IniRead($compatibility_ini, $sections[$i], "File_MD5","NotFound")
		$releases[$i][$R_RELEASE_DATE]=IniRead($compatibility_ini, $sections[$i], "Release_Date","NotFound")
		$releases[$i][$R_WEB]=IniRead($compatibility_ini, $sections[$i], "Web","NotFound")
		$releases[$i][$R_DOWNLOAD_PAGE]=IniRead($compatibility_ini, $sections[$i], "Download_page","NotFound")
		$releases[$i][$R_DOWNLOAD_SIZE]=IniRead($compatibility_ini, $sections[$i], "Donwload_Size","NotFound")
		$releases[$i][$R_INSTALL_SIZE]=IniRead($compatibility_ini, $sections[$i], "Install_Size","NotFound")
		$releases[$i][$R_DESCRIPTION]=IniRead($compatibility_ini, $sections[$i], "Description","NotFound")
		$releases[$i][$R_MIRROR1]=IniRead($compatibility_ini, $sections[$i], "Mirror1","NotFound")
		$releases[$i][$R_MIRROR2]=IniRead($compatibility_ini, $sections[$i], "Mirror2","NotFound")
		$releases[$i][$R_MIRROR3]=IniRead($compatibility_ini, $sections[$i], "Mirror3","NotFound")
		$releases[$i][$R_MIRROR4]=IniRead($compatibility_ini, $sections[$i], "Mirror4","NotFound")
		$releases[$i][$R_MIRROR5]=IniRead($compatibility_ini, $sections[$i], "Mirror5","NotFound")
		$releases[$i][$R_MIRROR6]=IniRead($compatibility_ini, $sections[$i], "Mirror6","NotFound")
		$releases[$i][$R_MIRROR7]=IniRead($compatibility_ini, $sections[$i], "Mirror7","NotFound")
		$releases[$i][$R_MIRROR8]=IniRead($compatibility_ini, $sections[$i], "Mirror8","NotFound")
		$releases[$i][$R_MIRROR9]=IniRead($compatibility_ini, $sections[$i], "Mirror9","NotFound")
		$releases[$i][$R_MIRROR10]=IniRead($compatibility_ini, $sections[$i], "Mirror10","NotFound")
		$releases[$i][$R_VISIBLE]=IniRead($compatibility_ini, $sections[$i], "Visible","NotFound")
	Next
	Return $releases
EndFunc

Func DisplayRelease($release_in_list)
	Global $releases
	if $release_in_list>0 Then
		Msgbox(4096,"Release Details" ,  "Name : " & $releases[$release_in_list][$R_NAME]  & @CRLF  _
		& "Distribution : " & ReleaseGetDistribution($release_in_list) & @CRLF  _
		& "Distribution Version : " & ReleaseGetDistributionVersion($release_in_list) & @CRLF  _
		& "Variant : " & ReleaseGetVariant($release_in_list) & @CRLF  _
		& "Variant Version : " & ReleaseGetVariantVersion($release_in_list) & @CRLF  _
		& "Filename : " & $releases[$release_in_list][$R_FILENAME] & @CRLF  _
		& "MD5 : " & $releases[$release_in_list][$R_FILE_MD5] & @CRLF  _
		& "Release Date : " & $releases[$release_in_list][$R_RELEASE_DATE] & @CRLF  _
		& "WebSite : " & $releases[$release_in_list][$R_WEB] & @CRLF  _
		& "Download Page : " & $releases[$release_in_list][$R_DOWNLOAD_PAGE] & @CRLF _
		& "Download Size : " & $releases[$release_in_list][$R_DOWNLOAD_SIZE] & @CRLF _
		& "Installed Size : " & $releases[$release_in_list][$R_INSTALL_SIZE] & @CRLF  _
		& "Description : " & $releases[$release_in_list][$R_DESCRIPTION] & @CRLF  _
		& "Mirror 1 :"  & $releases[$release_in_list][$R_MIRROR1] & @CRLF  _
		& "Mirror 2 : " & $releases[$release_in_list][$R_MIRROR2] & @CRLF  _
		& "Mirror 3 : " & $releases[$release_in_list][$R_MIRROR3] & @CRLF  _
		& "Mirror 4 : " & $releases[$release_in_list][$R_MIRROR4] & @CRLF  _
		& "Mirror 5 : " & $releases[$release_in_list][$R_MIRROR5] & @CRLF  _
		& "Mirror 6 : " & $releases[$release_in_list][$R_MIRROR6] & @CRLF  _
		& "Mirror 7 : " & $releases[$release_in_list][$R_MIRROR7] & @CRLF  _
		& "Mirror 8 : " & $releases[$release_in_list][$R_MIRROR8] & @CRLF  _
		& "Mirror 9 : " & $releases[$release_in_list][$R_MIRROR9] & @CRLF  _
		& "Mirror 10 : " & $releases[$release_in_list][$R_MIRROR10])
	EndIf
EndFunc
	
Func DisplayAllReleases()
	$sections = IniReadSectionNames($compatibility_ini)
	For $i=1 to $sections[0]
		DisplayRelease($i)
	Next
EndFunc

Func ReleaseGetCodename($release_in_list)
	if $release_in_list <=0 Then Return "NotFound" 
	Return $releases[$release_in_list][$R_CODE] 
EndFunc

Func ReleaseGetDistribution($release_in_list)
	if $release_in_list <=0 Then Return "NotFound" 
	Return $releases[$release_in_list][$R_DISTRIBUTION] 
EndFunc

Func ReleaseGetDistributionVersion($release_in_list)
	if $release_in_list <=0 Then Return "NotFound" 
	Return $releases[$release_in_list][$R_DISTRIBUTION_VERSION] 
EndFunc

Func ReleaseGetVariant($release_in_list)
	if $release_in_list <=0 Then Return "NotFound" 
	Return $releases[$release_in_list][$R_VARIANT] 
EndFunc

Func ReleaseGetVariantVersion($release_in_list)
	if $release_in_list <=0 Then Return "NotFound" 
	Return $releases[$release_in_list][$R_VARIANT_VERSION] 
EndFunc

Func ReleaseGetInstallSize($release_in_list)
	if $release_in_list <=0 Then Return -1 
	Return $releases[$release_in_list][$R_INSTALL_SIZE] 
EndFunc