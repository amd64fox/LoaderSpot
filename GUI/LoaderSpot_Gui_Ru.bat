@echo off
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}"; "& {(Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/amd64fox/LoaderSpot/main/GUI/LoaderSpot_Gui_Ru.ps1').Content | Invoke-Expression}"
pause
exit