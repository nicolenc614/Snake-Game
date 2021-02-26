INCLUDE Irvine32.inc
.DATA
a WORD 1920 DUP(0) ; Framebuffer (24x80)
tailRow BYTE 16d ; Snake tail row number
tailColumn BYTE 47d ; Snake tail column number
headRow BYTE 13d ; Snake head row number
headColumn BYTE 47d ; Snake head column number
foodRow BYTE 0 ; Food row
foodColumn BYTE 0 ; Food column
endGame BYTE 0d ; Flag for indicating that game should be ended (collision)
countScore DWORD 0d ; Total score
delTime DWORD 150 ; Delay time between frames (game speed)
; Strings for menu display
mainMenu BYTE "1. Start Game", 0Dh, 0Ah,"2. Select Speed", 0Dh, 0Ah,
"3. Select Level", 0Dh, 0Ah, "4. Exit",0Dh, 0Ah, 0
obstacleLevel BYTE "1. None", 0Dh, 0Ah, "2. Box", 0Dh, 0Ah, "3. Rooms", 0Dh, 0Ah, 0
speedLevel BYTE "1. normal", 0Dh, 0Ah, "2. 2x", 0Dh, 0Ah, "3. 3x",
0Dh, 0Ah, "4. 4x", 0Dh, 0Ah, 0
hit BYTE "Game Over!", 0
score BYTE "Score: 0", 0

.CODE
main PROC
; The main procedure handles printing menus to the user, configuring the game
; and then starting the game.
menu:
CALL Clrscr ; Clear terminal screen
CALL WriteString ; Write menu string to terminal
CALL ReadChar
CMP AL, '1' ; Check if start game was selected
JE startGame
CMP AL, '2' ; Check if speed level choice was selected
JE speed
CMP AL, '3' ; Check if obstacle level choice was selected
JE level
CMP AL, '4' ; Check if exit choice was selected,
level: ; Level chooser section
CALL Clrscr ; Clear terminal screen
CALL WriteString ; Write level menu string to screen
wait2: ; Wait for valid input for level choice
CALL ReadChar
CMP AL, '1' ; No obsacles level
JE level1
CMP AL, '2' ; Box level
JE level2
CMP AL, '3' ; Rooms level
level1: ; No obstacles level
level2: ; Box obstacle level
JMP menu
level3: ; Rooms obstacle level
speed: ; This section of code selects the game speed
CALL Clrscr ; Clear terminal screen

CALL WriteString ; Write speed menu string to screen
CALL ReadChar
CMP AL, '1' ; normal speed
JE speed1
CMP AL, '2' ; 2 times the normal speed
JE speed2
CMP AL, '3' ; 3 times the normal speed
JE speed3
CMP AL, '4' ; 4 times the normal speed
JE speed4
speed1: ; Set refresh rate of game to 150ms
MOV delTime, 150
JMP menu
speed2: ; Set refresh rate of game to 100ms
MOV delTime, 100
JMP menu
speed3:
MOV delTime, 50 ; Set refresh rate of game to 50ms
JMP menu
speed4:
MOV delTime, 35 ; Set refresh rate of game to 35ms
JMP menu ; Go back to main menu
main ENDP