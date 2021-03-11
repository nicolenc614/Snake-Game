INCLUDE Irvine32.inc
.DATA
mainnMenu BYTE "1. Start Game", 0Dh, 0Ah,"2. Select Speed Level", 0Dh, 0Ah,
"3. Select Obstacle Level", 0Dh, 0Ah, "4. Exit",0Dh, 0Ah, 0
speedLevel BYTE "1. Normal Speed", 0Dh, 0Ah, "2. 2x Speed", 0Dh, 0Ah, "3. 3x Speed",
0Dh, 0Ah, "4. 4x Speed", 0Dh, 0Ah, 0
ObstacleLevel BYTE "1. No Obstacle", 0Dh, 0Ah, "2. Box Obstacle", 0Dh, 0Ah, "3. Rooms Obstacle", 0Dh, 0Ah, 0
collision BYTE "Game Over!", 0
currentScore BYTE "Score: 0", 0
delayTime DWORD 150 ; Delay time between frames (game speed)

.CODE
main PROC
; The procedure prints menus to the screen, configures and starts the game
mainMenu:
CALL Randomize ; Set seed for food generation
CALL Clrscr ; Clear terminal screen
MOV EDX, OFFSET mainnMenu ; Copy pointer to main menu string into EDX
CALL WriteString ; Write menu string to terminal
wait1: ; Loop for reading menu choices
CALL ReadChar
CMP AL, '1' ; Check if start game was selected
JE start
CMP AL, '2' 
JE speed
CMP AL, '3' 
JE obstacle
CMP AL, '4' ; If any other character was read,
JNE wait1 ; continue loop until a valid character has been given, else exit program
EXIT
speed: ; selection of game speed
CALL Clrscr 
MOV EDX, OFFSET speedLevel ; Copy pointer to speed menu into EDX
CALL WriteString ; Write speed menu string to screen
wait3: ; Wait for valid input for speed choice
CALL ReadChar
CMP AL, '1' ; Normal speed
JE normalSpeed
CMP AL, '2' ; 2x speed
JE twoSpeed
CMP AL, '3' ; 3x speed
JE threeSpeed
CMP AL, '4' ; 4x speed
JE fourSpeed
JMP wait3
normalSpeed: ; Set refresh rate of game to 150ms
MOV delayTime, 150
JMP mainMenu
twoSpeed: ; Set refresh rate of game to 100ms
MOV delayTime, 100
JMP mainMenu
threeSpeed:
MOV delayTime, 50 ; Set refresh rate of game to 50ms
JMP mainMenu
fourSpeed:
MOV delayTime, 15 ; Set refresh rate of game to 35ms
JMP mainMenu ; Go back to main menu

obstacle: ; Obstacle Level chooser section
CALL Clrscr 
MOV EDX, OFFSET ObstacleLevel ; Copy pointer to obstacle menu into EDX
CALL WriteString ; Write obstacle level string to screen
wait2: ; Wait for valid input for level choice
CALL ReadChar
CMP AL, '1' ; No obstacles level
JE noObstacle
CMP AL, '2' ; Box level
JE box
CMP AL, '3' ; Rooms level
JE rooms
JMP wait2 ; Invalid choice, continue loop
noObstacle: ; No obstacles level

JMP mainMenu
box: ; Box obstacle level

JMP mainMenu

rooms: ; Rooms obstacle level

JMP mainMenu
start: ; sets the necessary flags and calls the main infinite loop
MOV EAX, 0 ; Clear registers
MOV EDX, 0
CALL Clrscr 
CALL initializeSnake ; Initialize snake position
CALL Paint ; Paint level to terminal screen
CALL createFood ; Create snake food location, print to screen
CALL startGame ; Call main infinite loop
main ENDP

initializeSnake PROC
; This procedure initializes the snake to the default position
; in the center of the screen
MOV DH, 13 ; Set row number to 13
MOV DL, 47 ; Set column number to 47
MOV BX, 1 ; First segment of snake
CALL saveIndex ; Write to framebuffer
MOV DH, 14 ; Set row number to 14
MOV DL, 47 ; Set column number to 47
MOV BX, 2 ; Second segment of snake
CALL saveIndex ; Write to framebuffer
MOV DH, 15 ; Set row number to 15
MOV DL, 47 ; Set column number to 47
MOV BX, 3 ; Third segment of snake
CALL saveIndex ; Write to framebuffer
MOV DH, 16 ; Set row number to 16
MOV DL, 47 ; Set column number to 47
MOV BX, 4 ; Fourth segment of snake
CALL saveIndex ; Write to framebuffer
RET
initializeSnake ENDP

clearMemory PROC
; This procedure clears the framebuffer, resets the snake position and length,
; and sets all the game related flags back to their default value.
MOV DH, 0 ; Set the row register to zero
MOV BX, 0 ; Set the data register to zero
oLoop: ; Outer loop for matrix indexing (for rows)
CMP DH, 24 ; Count for 24 rows and break if row number is 24
; (since indexing starts form 0)
JE endOLoop
MOV DL, 0 ; Set the column number to zero
iLoop: ; Inner loop for matrix indexing (for columns)
CMP DL, 80 ; Count for 80 columns and
JE endILoop ; break if column number is 80
CALL saveIndex ; Call procedure for writing to the framebuffer
; based on the DH and DL registers
INC DL ; Increment column number
JMP iLoop ; Continue inner loop
endILoop: ; End of innter loop
INC DH ; Increment row number
JMP oLoop ; Continue outer loop
endOLoop: ; End of outer loop
MOV tailRow, 16 ; Reset coordinates of
MOV tailColumn, 47 ; snake tail (row and column)
MOV headRow, 13 ; Reset coordinates of
MOV headColumn, 47 ; snake head (row and column)
MOV endGame, 0 ; Clear the end game flag
MOV deleteTail, 1 ; Set the erase tail flag (no food eaten)
MOV direction, 'w' ; Set current direction to up
MOV newDirection, 'w' ; Set new direction to up
MOV totalScore, 0 ; Reset total score
RET
clearMemory ENDP


Paint PROC

Paint ENDP

createFood PROC

createFood ENDP

startGame PROC

startGame ENDP
END main
