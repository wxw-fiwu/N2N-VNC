#Region ;**** 参数创建于 ACNWrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\WINDOWS\System32\SHELL32.dll
#AutoIt3Wrapper_Outfile=N2N&VNC.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=VNC自动挂载FRP程序
#AutoIt3Wrapper_Res_Description=由WXW编辑制作
#AutoIt3Wrapper_Res_Fileversion=1.0.0.17
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=@WXW
#AutoIt3Wrapper_Res_Language=4100
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** 参数创建于 ACNWrapper_GUI ****
#include <GUIConstantsEx.au3>
Example()
Opt("GUIOnEventMode",1)
Func Example()
	Local $frp_SAddr, $frp_SPort, $frp_token, $frp_RPort, $VNC_Port
	Local $start, $stop, $apply, $exit, $msg
	
	;判断系统位数
	;Local $xitongwei = FileFindFirstFile("C:\Program Files (x86)");系统x64
	If @CPUArch = "X64" Then;如果搜索到文件夹则运行x64
		Local $HKLM = "HKLM64"
	Else
		Local $HKLM = "HKLM"
	EndIf
	
	;读取edge配置
	$n2n_SAddr = IniRead("edge.conf", "edge", "-l", "")
	$n2n_group = IniRead("edge.conf", "edge", "-c", "")
	$n2n_pwd = IniRead("edge.conf", "edge", "-k", "")
	$n2n_LAddr = IniRead("edge.conf", "edge", "-a", "")
	
	;GUI对话框
	GUICreate("N2N&VNC-" & @CPUArch & "   www.fiwu.net", 400, 200)
	GUICtrlCreateLabel("服务地址：", 10, 7)
	$n2n_SAddr = GUICtrlCreateInput($n2n_SAddr, 80, 5, 100, 20)
	GUICtrlCreateLabel("小组名称：", 10, 37)
	$n2n_group = GUICtrlCreateInput($n2n_group, 80, 35, 100, 20)
	GUICtrlCreateLabel("小组密码：", 10, 67)
	$n2n_pwd = GUICtrlCreateInput($n2n_pwd, 80, 65, 100, 20)
	GUICtrlCreateLabel("虚拟地址：", 10, 98)
	$n2n_LAddr = GUICtrlCreateInput($n2n_LAddr, 80, 95, 100, 20)
	GUICtrlCreateLabel("VNC 端口：", 10, 128)
	$VNC_Port = GUICtrlCreateInput("15900", 80, 125, 100, 20)
	GUICtrlCreateLabel("VNC 密码：", 200, 128)
	$VNC_PWD = GUICtrlCreateInput("12345678", 270, 125, 100, 20)
	
	;显示框
	GUICtrlCreateGroup("运行信息", 195, 5, 194, 100)
	
	;GUI按钮
	$start = GUICtrlCreateButton("启动服务", 40, 155, 60, 20)
	$stop = GUICtrlCreateButton("停止服务", 120, 155, 60, 20)
	$apply = GUICtrlCreateButton("应用配置", 200, 155, 60, 20)
	$exit = GUICtrlCreateButton("退出", 280, 155, 60, 20)
	$cat_netstat = GUICtrlCreateButton("刷新", 330, 104, 60, 20)
	
	;底部信息
	$website1_url = "https://www.fiwu.net"
	$website1 = GUICtrlCreateLabel($website1_url, 270, 180, -1, -1)
	GuiCtrlSetFont($website1, 8.5, -1, 4) ; underlined
	GuiCtrlSetColor($website1, 0x0000ff)
	GuiCtrlSetCursor($website1, 0)


	GUISetState()
	
	$msg = 0
	While $msg <> $GUI_EVENT_CLOSE
		$msg = GUIGetMsg()

		Select
			Case $msg = $cat_netstat
				;=======================================================================
				;用于显示连接终端信息
				Local $netstat = Run(@ComSpec & ' /c ' & 'wmic NICCONFIG where "IPEnabled="TRUE"" get IPAddress | find "{"', '', @SW_HIDE, 15)
				ProcessWaitClose($netstat)
				$cat_netstat = StdoutRead($netstat)
				;GUICtrlCreateLabel($cat_netstat, 210, 20, 175, 80)
				GUICtrlCreateEdit($cat_netstat, 199, 20, 185, 80)
				GUICtrlSetState(GUICtrlRead($cat_netstat), 0)
				;MsgBox(0, "提示-" & @CPUArch, $cat_netstat)
				;=======================================================================
			Case $msg = $start
				GUICtrlSetState($start, $GUI_DISABLE);按键变灰色
				;=======================================================================
				;运行VNCS和FRPS
				Run(@ComSpec & ' /c echo ' & GUICtrlRead($VNC_PWD) & ' | .\' & @CPUArch & '\vncpasswd.exe -service', '', @SW_HIDE, 15);修改VNC密码
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall add rule name="vncserver.exe" dir=in program=".\' & @CPUArch & '\vncserver.exe" action=allow', '', @SW_HIDE);防火墙放行端口
				Run(".\" & @CPUArch & "\vnclicense.exe -add VKUPN-MTHHC-UDHGS-UWD76-6N36A", '', @SW_HIDE);VNC激活码到2029年的key
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "Authentication", "REG_SZ", "VncAuth")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "RfbPort", "REG_SZ", GUICtrlRead($VNC_Port))
				;RegWrite($HKLM & "\Software\RealVNC\vncserver", "Password", "REG_SZ", "f0e43164f6c2e373")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "DisableTrayIcon", "REG_SZ", "1")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "ConnNotifyTimeout", "REG_SZ", "0")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "EnableAutoUpdateChecks", "REG_SZ", "0")
				Run(".\" & @CPUArch & "\vncserver.exe -service -start", '', @SW_HIDE);开启vncserver服务
				Run(".\" & @CPUArch & "\edge_v3.exe edge.conf", '', @SW_MINIMIZE);运行服务
				;=======================================================================
			Case $msg = $stop
				;=======================================================================
				ProcessClose("edge_v3.exe");停止服务
				ProcessClose("vncserver.exe");停止vncserver服务
				Run(".\" & @CPUArch & "\vncserver.exe -service -stop", '', @SW_HIDE);停止vncserver服务
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall delete rule name="vncserver.exe"', '', @SW_HIDE);防火墙关闭端口
				Run(@ComSpec & ' /c ' & 'sc stop vncserver', '', @SW_HIDE)
				Run(@ComSpec & ' /c ' & 'sc delete vncserver', '', @SW_HIDE)
				GUICtrlSetState($start, $GUI_ENABLE);按键变可用
				;MsgBox(0, "提示-" & @CPUArch, "服务已停止")
				;=======================================================================
			Case $msg = $apply
				;=======================================================================
				;写入FRPC配置
				IniWrite("edge.conf", "edge", "-l", GUICtrlRead($n2n_SAddr))
				IniWrite("edge.conf", "edge", "-c", GUICtrlRead($n2n_group))
				IniWrite("edge.conf", "edge", "-k", GUICtrlRead($n2n_pwd))
				IniWrite("edge.conf", "edge", "-a", GUICtrlRead($n2n_LAddr))
				Run(@ComSpec & ' /c echo ' & GUICtrlRead($VNC_PWD) & ' | .\' & @CPUArch & '\vncpasswd.exe -service', '', @SW_HIDE, 15);修改VNC密码
				MsgBox(0, "提示-" & @CPUArch, "已应用配置")
				;=======================================================================
			Case $msg = $exit Or $msg = $GUI_EVENT_CLOSE 
				;=======================================================================
				;停止后退出
				ProcessClose("edge_v3.exe");停止frpc服务
				ProcessClose("vncserver.exe");停止vncserver服务
				Run(".\" & @CPUArch & "\vncserver.exe -service -stop", '', @SW_HIDE);停止vncserver服务
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall delete rule name="vncserver.exe"', '', @SW_HIDE);防火墙关闭端口
				Run(@ComSpec & ' /c ' & 'sc stop vncserver', '', @SW_HIDE)
				Run(@ComSpec & ' /c ' & 'sc delete vncserver', '', @SW_HIDE)
				ExitLoop
				;=======================================================================
			Case $msg = $website1
				Run(@ComSpec & " /c " & 'start ' & $website1_url, "", @SW_HIDE)
		EndSelect
	WEnd
EndFunc   ;==>Example
