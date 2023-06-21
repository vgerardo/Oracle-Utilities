
clear -host

echo "Inicio"

$WShell = New-Object -com "Wscript.shell"

$contador = 1

while ($true) 

{

$WShell.SendKeys("{SCROLLLOCK}")
Start-Sleep -seconds 300
echo "Probando configuración de SQL-Developer " + $contador

$contador = $contador + 1

}
