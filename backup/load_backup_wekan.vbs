' backup_wekan_log.vbs
' Script per backup Wekan con log giornaliero
' Esegue i comandi Docker e scrive output nel file backup_log.txt

Option Explicit

Dim shell, projectDir, logFile, cmd, timeStamp

' === CONFIGURAZIONE ===
projectDir = "C:\Users\matte\Desktop\WeKan"   ' <-- TODO: Modifica con il percorso della cartella di progetto Wekan
' Percorso file di log
logFile = projectDir & "\backup\logs\load_backup_log.txt"

' === INIZIALIZZAZIONE ===
Set shell = CreateObject("WScript.Shell")

' Data e ora in formato leggibile
timeStamp = "[" & Year(Now) & "-" & Right("0" & Month(Now),2) & "-" & Right("0" & Day(Now),2) & _
            " " & Right("0" & Hour(Now),2) & ":" & Right("0" & Minute(Now),2) & ":" & Right("0" & Second(Now),2) & "]"

' === COMANDO COMPLETO ===
cmd = "cmd /c cd /d """ & projectDir & """ && " & _
      "echo """ & timeStamp & """ Avvio backup Wekan >> """ & logFile & """ && " & _
      "docker stop wekan-app >> """ & logFile & """ 2>&1 && " & _
      "docker exec wekan-db rm -rf /data/dump >> """ & logFile & """ 2>&1 && " & _
      "docker cp backup/toRestore/dump wekan-db:/data/ >> """ & logFile & """ 2>&1 && " & _
      "docker exec wekan-db mongorestore --drop --dir=/data/dump >> """ & logFile & """ 2>&1 && " & _
      "docker start wekan-app >> """ & logFile & """ 2>&1 && " & _
      "echo """ & timeStamp & """ Backup completato. >> """ & logFile & """ && echo. >> """ & logFile & """"

' === ESECUZIONE ===
shell.Run cmd, 1, True   ' 0 = finestra nascosta, True = attendi fine

Set shell = Nothing
