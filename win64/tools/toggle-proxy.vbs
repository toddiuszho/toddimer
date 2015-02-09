Option Explicit 
Dim WSHShell, numSetting, sSetting
Set WSHShell = WScript.CreateObject("WScript.Shell")
Const HIDDEN_WINDOW = 0
Const sComputer = "."
Const sIeLong = "C:\Program Files\Internet Explorer\iexplore.exe -embedding"
Const sIeShort = "iexplore.exe"
Const REG_DWORD = "REG_DWORD"
Const REG_SZ = "REG_SZ"
Const sProxyEnable   = "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
Const sProxyOverride = "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyOverride"
Const sProxyServer   = "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyServer"
Const sLocal = "<local>"
Const sSocks="socks=127.0.0.1:12345"
Dim aOverrides, sOverrides 
'aOverrides = array("corp.viverae.com", "helpdesk", "172.20.119.210", "dev.viverae.com", "viveraeconnect.com", "184.73.235.12", "107.22.210.163", "184.73.255.87", "204.236.224.158", "23.21.122.20", "23.23.126.165", "54.243.248.138", "23.21.62.199", sLocal)
aOverrides = array("*.corp.viverae.com", "corp.viverae.com", "helpdesk", "172.20.119.210", "viveraeconnect.com", sLocal)
sOverrides = Join(aOverrides, ";")

'Display current setting
numSetting = wshshell.regread(sProxyEnable)
If numSetting = 1 Then
  sSetting = "ON"
Else
  sSetting = "OFF"
End If
WScript.Echo "Previous ProxyEnable setting: " & sSetting

'Exec
If WScript.Arguments.Count > 0 Then
  If WScript.Arguments(0) = "on" Then
    WScript.Echo "Explicitly turning ON"
    Proxy
  ElseIf WScript.Arguments.Count > 0 And WScript.Arguments(0) = "off" Then
    WScript.Echo "Explicitly turning OFF"
    NoProxy
  Else
    WScript.Echo "Cannot understand client. Implicitly toggling."
    'Determine current proxy setting and toggle to opposite setting
    If numSetting = 1 Then 
      WScript.Echo "Implicitly turning OFF since it's currently ON."
      NoProxy
    Else 
      WScript.Echo "Implicitly turning ON since it's currently OFF."
      Proxy
    End If
  End If
Else
  'Determine current proxy setting and toggle to opposite setting
  WScript.Echo "Client did not make explicit request. Implicitly toggling."
  If numSetting = 1 Then 
    WScript.Echo "Implicitly turning OFF since it's currently ON."
    NoProxy
  Else 
    WScript.Echo "Implicitly turning ON since it's currently OFF."
    Proxy
  End If
End If

'Subroutine to Toggle Proxy Setting to ON
Sub Proxy 
  WSHShell.regwrite sProxyEnable, 1, REG_DWORD
  WSHShell.regwrite sProxyOverride, sOverrides, REG_SZ
  WSHShell.regwrite sProxyServer, sSocks, REG_SZ
  Flash sIeLong, sIeShort
  WScript.Echo "Proxy now ON"
End Sub

'Subroutine to Toggle Proxy Setting to OFF
Sub NoProxy 
  WSHShell.regwrite sProxyEnable, 0, REG_DWORD
  Flash sIeLong, sIeShort
  WScript.Echo "Proxy now OFF"
End Sub

Sub Flash(cmdLong, cmdShort)
  Dim objWMIService, objStartup, objConfig, objProcess, pid
  Set objWMIService = GetObject("winmgmts:\\" & sComputer & "\root\cimv2")
  Set objStartup = objWMIService.Get("Win32_ProcessStartup")
  Set objConfig = objStartup.SpawnInstance_
  objConfig.ShowWindow = HIDDEN_WINDOW
  Set objProcess = GetObject("winmgmts:\\" & sComputer & "\root\cimv2:Win32_Process")
  objProcess.Create cmdLong, null, objConfig, pid
  'WScript.Sleep 3000
  KillByShortName objWMIService, cmdShort
End Sub

Sub KillByShortName(objWMIService, cmdShort)
  Dim colProcess, objProcess, intrc, pid
  Set colProcess = objWMIService.ExecQuery("Select * from Win32_Process where Name = '" & cmdShort & "'")
  If colProcess.Count > 0 Then
    On Error Resume next
      For Each objProcess in colProcess
        WScript.Sleep 1500
        If IsObject(objProcess) Then
          pid = objProcess.processid
          intrc = objProcess.Terminate()
          If intrc = 0 Then
            WScript.Echo "... Killed " & pid
          Else
            WScript.Echo "... Could not kill " & intrc & " Reason code: " & intrc
          End If
        End If
      Next
    On Error goTo 0
  End If
End Sub

