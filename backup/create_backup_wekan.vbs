' backup_wekan_log.vbs
' Script per backup Wekan con log giornaliero
' Esegue i comandi Docker e scrive output nel file backup_log.txt

Option Explicit

Dim shell, fso, projectDir, logFile, cmd, timeStamp, dumpFolderName, dumpFolderPath, dateSuffix

' === CONFIGURAZIONE ===
' Folder dove verrà aperto il prompt dei comandi.
projectDir = "C:\Users\matte\Desktop\WeKan"   ' <-- TODO: Modifica con il percorso della cartella di progetto Wekan
' Percorso file di log
logFile = projectDir & "\backup\logs\create_backup_log.txt"

' === INIZIALIZZAZIONE ===
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Data e ora in formato leggibile
timeStamp = "[" & Year(Now) & "-" & Right("0" & Month(Now),2) & "-" & Right("0" & Day(Now),2) & _
            " " & Right("0" & Hour(Now),2) & ":" & Right("0" & Minute(Now),2) & ":" & Right("0" & Second(Now),2) & "]"

' Suffisso data per il nome del dump
dateSuffix = Right("0" & Day(Now),2) & "_" & Right("0" & Month(Now),2) & "_" & Year(Now)
' Nome e percorso del dump finale
dumpFolderName = "dump_" & dateSuffix
dumpFolderPath = projectDir & "\backup\backups\" & dumpFolderName
' Crea la cartella di destinazione se non esiste
If Not fso.FolderExists(dumpFolderPath) Then
    fso.CreateFolder dumpFolderPath
End If

' === COMANDO COMPLETO ===
cmd = "cmd /c cd /d """ & projectDir & """ && " & _
      "echo """ & timeStamp & """ Avvio backup Wekan >> """ & logFile & """ && " & _
      "docker stop wekan-app >> """ & logFile & """ 2>&1 && " & _
      "docker exec wekan-db rm -rf /data/dump >> """ & logFile & """ 2>&1 && " & _
      "docker exec wekan-db mongodump -o /data/dump >> """ & logFile & """ 2>&1 && " & _
      "docker cp wekan-db:/data/dump """ & dumpFolderPath & """ >> """ & logFile & """ 2>&1 && " & _
      "docker start wekan-app >> """ & logFile & """ 2>&1 && " & _
      "echo """ & timeStamp & """ Backup completato: """ & dumpFolderPath & """ >> """ & logFile & """ && echo. >> """ & logFile & """"

' === ESECUZIONE ===
shell.Run cmd, 1, True   ' 0 = finestra nascosta, True = attendi fine

Set shell = Nothing
