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
frame WORD 1920 DUP(0) ; Framebuffer (24x80), size of the game frame
tailRow BYTE 16d ; Snake tail row number
tailColumn BYTE 47d ; Snake tail column number
headRow BYTE 13d ; Snake head row number
headColumn BYTE 47d ; Snake head column number
foodRow BYTE 0 ; Food row
foodColumn BYTE 0 ; Food column
tempRow BYTE 0 ; Temporary variable for storing row indexes
tempColumn BYTE 0 ; Temporary variable for storing column indexes
rowMinus BYTE 0d ; Index of row above current row (row minus)
columnMinus BYTE 0d ; Index of column left of current column (column minus)
rowPlus BYTE 0d ; Index of row below current row (row plus)
columnPlus BYTE 0d ; Index of column right of current column (column plus)
deleteTail BYTE 1d ; Flag for indicating if tail should be deleted or not
search WORD 0d ; Variable for storing value of next snake segment
endGame BYTE 0d ; Flag for indicating that game should be ended (collision)
totalScore DWORD 0d ; Total score
direction BYTE 'w' ; Variable for holding the current direction of the snake
newDirection BYTE 'w' ; Variable for holding the new direction specified by input
termInpHandle DWORD ? ; Variable for holding the terminal input handle
numberInput DWORD ? ; Variable for holding number of bytes in input buffer
temp BYTE 16 DUP(?) ; Variable for holding data of type INPUT_RECORD
inputRead DWORD ? ; Variable for holding number of read input bytes

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
CALL clearMemory ; Clear framebuffer and reset all game flags
MOV AL, 1 ; Set flag for level generation in AL and jump
CALL GenerateLevel ; to level generation section of program
JMP mainMenu
box: ; Box obstacle level
CALL clearMemory 
MOV AL, 2 ; Set flag for level generation in AL and jump
CALL GenerateLevel 
JMP mainMenu
rooms: ; Rooms obstacle level
CALL clearMemory 
MOV AL, 3 ; Set flag for level generation in AL and jump
CALL GenerateLevel 
JMP mainMenu
start: ; sets the necessary flags and calls the main infinite loop
MOV EAX, 0 ; Clear registers
MOV EDX, 0
CALL Clrscr 
CALL initializeSnake ; Initialize snake position
CALL Paint ; Paint level to terminal screen
CALL createFood ; Create snake food location, print to screen
CALL startGame ; Call main infinite loop
MOV EAX, white + (black * 16)
CALL SetTextColor ; Game was exited, reset screen color
JMP mainMenu ; and jump back to main menu
main ENDP
initializeSnake PROC
; This procedure places the snake to starting position aka center of screen
MOV DH, 13 ; Set row number to 13
MOV DL, 47 ; Set column number to 47
MOV BX, 1 ; First segment of snake
CALL writeIndexToFrame; Write to framebuffer
MOV DH, 14 ; Set row number to 14
MOV DL, 47 ; Set column number to 47
MOV BX, 2 ; Second segment of snake
CALL writeIndexToFrame; Write to framebuffer
MOV DH, 15 ; Set row number to 15
MOV DL, 47 ; Set column number to 47
MOV BX, 3 ; Third segment of snake
CALL writeIndexToFrame; Write to framebuffer
MOV DH, 16 ; Set row number to 16
MOV DL, 47 ; Set column number to 47
MOV BX, 4 ; Fourth segment of snake
CALL writeIndexToFrame; Write to framebuffer
RET
initializeSnake ENDP

writeIndexToFrame PROC USES EAX ESI EDX
; This procedure accesses the framebuffer and writes a value to the pixel
; specified by DH (row index) and DL (column index). The pixel value has to be
; passed through the register BX.
PUSH EBX ; Save EBX on stack
MOV BL, DH ; Copy row number to BL
MOV AL, 80 ; Copy multiplication constant for row number
MUL BL ; Multiply row index by 80 to get framebuffer segment
PUSH DX ; Push DX onto stack
MOV DH, 0 ; Clear DH register, to access the column number
ADD AX, DX ; Add column offset to get the array index
POP DX ; Pop old address off of stack
MOV ESI, 0 ; Clear indexing register
MOV SI, AX ; Move generated address into ESI register
POP EBX ; Pop EBX off of stack
SHL SI, 1 ; Multiply address by two, because elements
; are of type WORD
MOV frame[SI], BX ; Save BX into array
RET
writeIndexToFrame ENDP

DrawSnakeAndWalls PROC USES EAX EDX EBX ESI
; This procedure reads the contents of the framebuffer, pixel by pixel, and
; puts them onto the terminal screen. This includes the snake and the walls.
; The color of the walls can be changed in this procedure. The color of the
; snake has to be changed here, as well as in the moveSnake procedure.
MOV EAX, blue + (white * 16) ; Set text color to blue on white
CALL SetTextColor
MOV DH, 0 ; Set row number to 0
rowIndex: ; Loop for indexing of the rows
CMP DH, 24 ; Check if the indexing has arrived
JGE endRowIndex ; at the bottom of the screen
MOV DL, 0 ; Set column number to 0
columnIndex: ; Loop for indexing of the columns
CMP DL, 80 ; Check if the indexing has arrived
JGE endColumnIndex ; at the right side of the screen
CALL GOTOXY ; Set cursor to current pixel position
MOV BL, DH ; Generate the framebuffer address from
MOV AL, 80 ; the row value stored in DH
MUL BL
PUSH DX ; Save DX on stack
MOV DH, 0 ; Clear upper bite of DX
ADD AX, DX ; Add offset to row address (column adress)
POP DX ; Restore old value of DX
MOV ESI, 0 ; Clear indexing register
MOV SI, AX ; Move pixel address into indexing register
SHL SI, 1 ; Multiply indexing address by 2, since
; we're using elements of type WORD in the
; framebuffer
MOV BX, frame[SI] ; Get the pixel
CMP BX, 0 ; Check if pixel is empty space,
JE NoWalls ; and don't print it if is
CMP BX, 0FFFFh ; Check if pixel is part of a wall
JE printHurdle ; Jump to segment for printing walls
MOV AL, ' ' ; Pixel is part of the snake, so print
CALL WriteChar ; whitespace
JMP noWalls ; Jump to end of loop
PrintHurdle: ; Segment for printing the walls
MOV EAX, red + (red * 16) ; Change the text color to red (wall color)
CALL SetTextColor
MOV AL, ' ' ; Print whitespace
CALL WriteChar
MOV EAX, blue + (white * 16) ; Change the text color back to
CALL SetTextColor ; blue on white
NoWalls:
INC DL ; Increment the column number
JMP columnIndex ; Continue column indexing
endColumnIndex: ; End of column loop
INC DH ; Increment the row number
JMP rowIndex ; Continue row indexing
endRowIndex: ; End of row loop
RET
DrawSnakeAndWalls ENDP

FoodCreation PROC USES EAX EBX EDX
; This procedure generates food for the snake. It uses a random number to
; generate the row and column values for the location of the food. It also
; takes into account the position of the snake and obstacles, so that the food
; doesn't overlap with the snake or the obstacles.
foodPosition: ; Loop for food position generation
MOV EAX, 24 ; Generate a random integer in the
CALL RandomRange ; range 0 to numRows - 1
MOV DH, AL
MOV EAX, 80 ; Generate a random integer in the
CALL RandomRange ; range 0 to numCol - 1
MOV DL, AL
CALL accessFrameIndex; Get content of generated location
CMP BX, 0 ; Check if content is empty space
JNE foodPosition ; Loop until location is empty space
MOV foodRow, DH ; Set food row value
MOV foodColumn, DL ; Set food column value
MOV EAX, yellow + (yellow * 16); Set text color to white on cyan
CALL setTextColor
CALL GotoXY ; Move cursor to generated position
MOV AL, ' ' ; Write whitespace to terminal
CALL WriteChar
RET
FoodCreation ENDP

accessFrameIndex PROC USES EAX ESI EDX
; This procedure accesses the framebuffer and returns the value of the pixel
; specified by DH (row index) and DL (column index). The pixel value gets
; returned through the register BX.
MOV BL, DH ; Copy row index into BL
MOV AL, 80 ; Copy multiplication constant for row number
MUL BL ; Mulitply row index by 80 to get framebuffer segment
PUSH DX ; Push DX onto stack
MOV DH, 0 ; Clear upper byte of DX to get only column index
ADD AX, DX ; Add column offset to row segment to get pixel address
POP DX ; Pop DX off of stack
MOV ESI, 0 ; Clear indexing register
MOV SI, AX ; Copy generated address into indexing register
SHL SI, 1 ; Multiply address by 2 since the elements are of type WORD
MOV BX, frame[SI] ; Copy framebuffer content into BX register
RET
accessFrameIndex ENDP

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
CALL writeIndexToFrame; Call procedure for writing to the framebuffer
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


startGame PROC

startGame ENDP
END main
