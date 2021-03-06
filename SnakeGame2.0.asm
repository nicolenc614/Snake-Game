INCLUDE Irvine32.inc

.DATA
mainnMenu BYTE "1. Start Game", 0Dh, 0Ah,"2. Select Speed Level", 0Dh, 0Ah,
"3. Select Obstacle Level", 0Dh, 0Ah, "4. Exit",0Dh, 0Ah, 0
speedLevel BYTE "1. Normal Speed", 0Dh, 0Ah, "2. 2x Speed", 0Dh, 0Ah, "3. 3x Speed",
0Dh, 0Ah, "4. 4x Speed", 0Dh, 0Ah, 0
ObstacleLevel BYTE "1. No Obstacle", 0Dh, 0Ah, "2. Box Obstacle", 0Dh, 0Ah, "3. Rooms Obstacle", 0Dh, 0Ah, "4. Maze Obstacle", 0Dh, 0Ah,0

collision BYTE "Game Over, thanks for playing!", 0
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


main PROC ; The procedure prints menus to the screen, configures and starts the game
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

    wait3: 
    CALL ReadChar
    CMP AL, '1' ; Normal speed
    JE normalSpeed
    CMP AL, '2' 
    JE twoSpeed
    CMP AL, '3' 
    JE threeSpeed
    CMP AL, '4' 
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
    JMP mainMenu 

    obstacle: ; Obstacle Level chooser section
    CALL Clrscr 
    MOV EDX, OFFSET ObstacleLevel 
    CALL WriteString 
   
    wait2: ; Wait for valid input for level choice
    CALL ReadChar
    CMP AL, '1' ; No obstacles level
    JE noObstacle
    CMP AL, '2' ; Box level
    JE box
    CMP AL, '3' ; Rooms level
    JE rooms
    CMP AL, '4' ; Rooms level
    JE maze
    JMP wait2 

    noObstacle: ; No obstacles level
    CALL clearMemory ; Clear framebuffer and reset all game flags
    MOV AL, 1 ; Set flag for level generation in AL and jump
    CALL GenerateObstacle ; to level generation section of program
    JMP mainMenu

    box: ; Box obstacle level
    CALL clearMemory 
    MOV AL, 2 ; Set flag for level generation in AL and jump
    CALL GenerateObstacle 
    JMP mainMenu

    rooms: ; Rooms obstacle level
    CALL clearMemory 
    MOV AL, 3 ; Set flag for level generation in AL and jump
    CALL GenerateObstacle 
    JMP mainMenu

    maze: ; Rooms obstacle level
    CALL clearMemory 
    MOV AL, 4 ; Set flag for level generation in AL and jump
    CALL GenerateObstacle 
    JMP mainMenu


    start: ; sets the necessary flags and calls the main infinite loop
    MOV EAX, 0 ; Clear registers
    MOV EDX, 0
    CALL Clrscr 
    CALL initializeSnake ; Initialize snake position
    CALL DrawSnakeAndWalls; Draw snake and wall to terminal screen
    CALL FoodCreation ; Create snake food location, print to screen
    CALL StartMainGame ; Call main infinite loop
    MOV EAX, white + (black * 16)
    CALL SetTextColor ; Game was exited, reset screen color
    JMP mainMenu ; and jump back to main menu
main ENDP


initializeSnake PROC ; This procedure places the snake to starting position aka center of screen
    MOV DH, 13 ; Set row number to 13
    MOV DL, 47 ; Set column number to 47
    MOV BX, 1 ; First segment of snake
    CALL writeIndexToFrame; Write to framebuffer

    MOV DH, 14 
    MOV DL, 47 
    MOV BX, 2 ; Second segment of snake
    CALL writeIndexToFrame

    MOV DH, 15 
    MOV DL, 47 
    MOV BX, 3 ; Third segment of snake
    CALL writeIndexToFrame

    MOV DH, 16 
    MOV DL, 47 
    MOV BX, 4 ; Fourth segment of snake
    CALL writeIndexToFrame
    RET
initializeSnake ENDP


writeIndexToFrame PROC USES EAX ESI EDX ; This procedure accesses the framebuffer and writes a value to the pixel
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
    SHL SI, 1 ; Multiply address by two, because elements are of type WORD
    MOV frame[SI], BX ; Save BX into array
    RET
writeIndexToFrame ENDP

DrawSnakeAndWalls PROC USES EAX EDX EBX ESI
; This procedure reads the contents of the framebuffer, pixel by pixel, and
; puts them onto the terminal screen. This includes the snake and the walls.

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
    SHL SI, 1 ; Multiply indexing address by 2, since we're using elements of type WORD in the framebuffer
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
    MOV EAX, yellow + (yellow * 16); Set text color to yellow on yellow
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

    outerLoop: ; Outer loop for matrix indexing (for rows)
    CMP DH, 24 ; Count for 24 rows and break if row number is 24 since indexing starts form 0
    JE endOuterLoop
    MOV DL, 0 ; Set the column number to zero

        innerLoop: ; Inner loop for matrix indexing (for columns)
        CMP DL, 80 ; Count for 80 columns and
        JE endILoop ; break if column number is 80
        CALL writeIndexToFrame
        INC DL 
        JMP innerLoop 
        endILoop: ; End of innter loop
        INC DH 
        JMP outerLoop ; Continue outer loop
    endOuterLoop: ; End of outer loop
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

StartMainGame PROC USES EAX EBX ECX EDX
; This procedure is the main process, and has an infinite loop which exits
; when the user presses ESC or when it comes to a collision with a wall or the
; snake itself. Upon exit, the procedure resets the game flags to default and
; clears the framebuffer. 

    MOV EAX, white + (black * 16) ; Set text color to white on black
    CALL SetTextColor
    MOV DH, 24 ; Move cursor to bottom left side
    MOV DL, 0 ; of screen, to write the score
    CALL GotoXY ; string
    MOV EDX, OFFSET currentScore
    CALL WriteString

    ; Get console input handle and store it in memory
    INVOKE getStdHandle, STD_INPUT_HANDLE
    MOV termInpHandle, EAX
    MOV ECX, 10

    ; Read two events from buffer
    INVOKE ReadConsoleInput, termInpHandle, ADDR temp, 1, ADDR inputRead
    INVOKE ReadConsoleInput, termInpHandle, ADDR temp, 1, ADDR inputRead

    ; Main infinite loop
    more: ; Get number of events in input buffer
    INVOKE GetNumberOfConsoleInputEvents, termInpHandle, ADDR numberInput
    MOV ECX, numberInput
    CMP ECX, 0 ; Check if input buffer is empty
    JE done ; Continue loop if buffer is empty

    ; Read one event from input buffer and save it at temp
    INVOKE ReadConsoleInput, termInpHandle, ADDR temp, 1, ADDR inputRead
    MOV DX, WORD PTR temp ; Check if EventType is KEY_EVENT,
    CMP DX, 1 ; which is determined by 1st WORD
    JNE SkipEvent ; of INPUT_RECORD message

    MOV DL, BYTE PTR [temp+4] ; Skip key released event
    CMP DL, 0
    JE SkipEvent

    MOV DL, BYTE PTR [temp+10] ; Copy pressed key into DL
    CMP DL, 1Bh ; Check if ESC key was pressed and
    JE quit ; quit the game if it was

    CMP direction, 'w' ; Check if current snake direction
    JE horizontalArrow ; is vertical, and jump to horizontalArrow to

    CMP direction, 's' ; handle direction change if the
    JE horizontalArrow ; change is horizontal
    JMP verticalArrow ; Jump to verticalArrow if the current

    ; direction is vertical
    horizontalArrow:
    CMP DL, 25h ; Check if left arrow was in input
    JE leftArrow
    CMP DL, 27h ; Check if right arrow was in input
    JE rightArrow
    JMP SkipEvent ; If up or down arrows were in input, no direction change

        leftArrow:
        MOV newDirection, 'a' ; Set new direction to left
        JMP SkipEvent

        rightArrow:
        MOV newDirection, 'd' ; Set new direction to right
        JMP SkipEvent

    verticalArrow:
    CMP DL, 26h ; Check if up arrow was in input
    JE upArrow
    CMP DL, 28h ; Check if down arrow was in input
    JE downArrow
    JMP SkipEvent 
        upArrow:
        MOV newDirection, 'w' ; Set new direction to up
        JMP SkipEvent

        downArrow:
        MOV newDirection, 's' ; Set new direction to down
        JMP SkipEvent

    SkipEvent:
    JMP more ; Continue main loop

    done:
    MOV BL, newDirection ; Set new direction as snake
    ; direction
    MOV direction, BL
    CALL MovingTheSnake ; Update direction and position
    MOV EAX, DelayTime ; Delay before next iteration 
    CALL Delay 
    CMP endGame, 1 ; Check if end game flag is set
    JE quit ; (from a collision)
    JMP more ; Continue main loop

    quit:
    CALL clearMemory ; Set all game related things to
    MOV delayTime, 150 ; default, and go back to main menu
    RET
StartMainGame ENDP



MovingTheSnake PROC USES EBX EDX  
; This procedure updates the framebuffer, thus moving the snake. The procedure
; starts from the snake tail, and searches for the next segment in the
; region of the current segment. 

    CMP deleteTail, 1 ; Check if delete tail flag is set....if (deleteTail == 1)
    JNE noDelTail ; Don't erase the tail if flag is not set

        MOV DH, tailRow  ;search = a[tailRow][tailColumn]
        MOV DL, tailColumn 
        CALL accessFrameIndex; Access framebuffer at given index
        DEC BX ; Decrement value returned from framebuffer,this gives us the value of the next segment, search--
        MOV search, BX ; Copy value of next segment to search

        MOV BX, 0 ; Erase the value at current index from the
        CALL writeIndexToFrame; framebuffer (the snake tail)

        CALL GotoXY ; Erase snake tail pixel from screen, erase console[tailRow][tailColum]
        MOV EAX, white + (black * 16)
        CALL SetTextColor
        MOV AL, ' '
        CALL WriteChar
        PUSH EDX ; Move cursor to bottom right side of the screen
        MOV DL, 79
        MOV DH, 23
        CALL GotoXY
        POP EDX

        MOV AL, DH ; Copy tail row index into AL
        DEC AL ; Get index of row above current row
        MOV rowMinus, AL ; Save index of row above current row....rowMinus = tailRow-1
        ADD AL, 2 ; Get index of row below current row
        MOV rowPlus, AL ; rowPlus = tailRow+1

        MOV AL, DL ; Copy tail column index into AL
        DEC AL ; Get index of column left of current column
        MOV columnMinus, AL ; Save index of column left of current column....columnMinus = tailcolumn-1
        ADD AL, 2 ; Get index of column right of current column
        MOV columnPlus, AL ; columnPlus = tailColumn+1

        CMP rowPlus, 24 ; Check if new index is getting off screen.... if (rowPlus == 24)
        JNE next1
        MOV rowPlus, 0 ; Wrap the index around the screen

        next1:
        CMP columnPlus, 80 ; Check if new index is getting off screen.... if (columnPlus == 80)
        JNE next2
        MOV columnPlus, 0 ; Wrap the index around the screen
       
        next2:
        CMP rowMinus, 0 ; Check if new index is getting off screen
        JGE next3
        MOV rowMinus, 23 ; Wrap the index around the screen

        next3:
        CMP columnMinus, 0 ; Check if new index is getting off screen
        JGE next4
        MOV columnMinus, 79 ; Wrap the index around the screen

        next4:
        MOV DH, rowMinus ; Copy row index of pixel above tail into DH
        MOV DL, tailColumn ; Copy column index of pixel above tail into DL
        CALL accessFrameIndex; Access pixel value in framebuffer
        CMP BX, search ; Check if pixel is the next segment of the snake....if (a[rowMinus][tailColumn] == search)
        JNE move1
        MOV tailRow, DH ; Move tail to new location, if it is
        JMP moveEnd

        move1:
        MOV DH, rowPlus ; Copy row index of pixel below tail into DH
        CALL accessFrameIndex; Acces pixel value in framebuffer
        CMP BX, search ; Check if pixel is the next segment of the snake....else if (a[rowPlus][tailColumn] == search)
        JNE move2
        MOV tailRow, DH ; Move tail to new location, if it is
        JMP moveEnd

        move2:
        MOV DH, tailRow ; Copy row index of pixel left of tail into DH
        MOV DL, columnMinus ; Copy column index of pixel left of tail into DH
        CALL accessFrameIndex; Access pixel value in framebuffer
        CMP BX, search ; Check if pixel is the next segment of the snake....else if (a[tailRow][columnMinus] == search)
		CMP bx, search
        JNE moveElse
        MOV tailColumn, DL ; Move tail to new location, if it is
        JMP moveEnd

        moveElse:
        MOV DL, columnPlus ; Move tail to pixel right of tail
        MOV tailColumn, DL
        moveEnd:

    noDelTail:
    MOV deleteTail, 1 ; Set erase tail flag
    MOV DH, tailRow ; Copy row index of tail into DH
    MOV DL, tailColumn ; Copy column index of tail into DL
    MOV tempRow, DH ; Copy row index into memory
    MOV tempColumn, DL ; Copy column index into memory

    whileTrue: ; Infinite loop for going over all the snake segments and adjusting each value
    MOV DH, tempRow ; Copy current row index into DH
    MOV DL, tempColumn ; Copy current column index into DL
    CALL accessFrameIndex; Get pixel value form framebuffer

    DEC BX ; Decrement pixel value to get the value of the next snake segment
    MOV search, BX ; Copy value of next segment into search
    PUSH EBX ; Replace current segment value in framebuffer with
    ADD BX, 2 ; previous segment value (snake is moving, segments
    CALL writeIndexToFrame ; are moving)

    POP EBX
    CMP BX, 0 ; Check if the current segment is the head of the
    JE break ; snake

    MOV AL, DH ; Copy row index of current segment into AL
    DEC AL ; Get index of row above current row
    MOV rowMinus, AL ; Save index of row above current row
    ADD AL, 2 ; Get index of row below current row
    MOV rowPlus, AL ; Save index of row below current row
    MOV AL, DL ; Copy column index of current segment into AL

    DEC AL ; Get index of column left of current column
    MOV columnMinus, AL ; Save index of column left of current column
    ADD AL, 2 ; Get index of column right of current column
    MOV columnPlus, AL ; Save index of column right of current column
    CMP rowPlus, 24 ; Check if new index is getting off screen
    JNE next2of1
    MOV rowPlus, 0 ; Wrap index around screen

    next2of1:
    CMP columnPlus, 80 ; Check if new index is getting off screen
    JNE next2of2
    MOV columnPlus, 0 ; Wrap index around screen

    next2of2:
    CMP rowMinus, 0 ; Check if index is getting off screen
    JGE next2of3
    MOV rowMinus, 23 ; Wrap index around screen

    next2of3:
    CMP columnMinus, 0 ; Check if index is getting off screen
    JGE next2of4
    MOV columnMinus, 79 ; Wrap index around screen

    next2of4:
    MOV DH, rowMinus ; Copy row index of pixel above segment into DH
    MOV DL, tempColumn ; Copy column index of pixel above segment into DH
    CALL accessFrameIndex; Access pixel value in framebuffer
    CMP BX, search ; Check if pixel is the next segment of the snake
    JNE elseif2of1
    MOV tempRow, DH ; Move index to new location, if it is
    JMP endif2

    elseif2of1:
    MOV DH, rowPlus ; Copy row index of pixel below segment into DH
    CALL accessFrameIndex; Access pixel value in framebuffer
    CMP BX, search ; Check if pixel is the next segment of the snake
    JNE elseif2of2
    MOV tempRow, DH ; Move index to new location, if it is
    JMP endif2
    elseif2of2:
    MOV DH, tempRow ; Copy row index of pixel left of segment into DH
    MOV DL, columnMinus ; Copy column index of pxl left of segment into DL
    CALL accessFrameIndex; Access pixel value in framebuffer
    CMP BX, search ; Check if pixel is the next segment of the snake
    JNE else2
    MOV tempColumn, DL ; Move index to new location if it is
    JMP endif2

    else2:
    MOV DL, columnPlus ; Move index to pixel right of segment
    MOV tempColumn, DL

    endif2:
    JMP whileTrue ; Continue loop until the snake head is reached
    break:
    MOV AL, headRow ; Copy head row index into AL
    DEC AL ; Get index of row above head row
    MOV rowMinus, AL ; Save index of row above head row
    ADD AL, 2 ; Get index of row below head row
    MOV rowPlus, AL ; Save index of row below head row
    MOV AL, headColumn ; Copy head column index into AL
    DEC AL ; Get index of column left of head column
    MOV columnMinus, AL ; Save index of column left of head column
    ADD AL, 2 ; Get index of column right of head column
    MOV columnPlus, AL ; Save index of column right of head column
    CMP rowPlus, 24 ; Check if new index is getting off screen
    JNE next3of1
    MOV rowPlus, 0 ; Wrap index around screen

    next3of1:
    CMP columnPlus, 80 ; Chekc if new index is getting off screen
    JNE next3of2
    MOV columnPlus, 0 ; Wrap index around screen

    next3of2:
    CMP rowMinus, 0 ; Check if new index is getting off sreen
    JGE next3of3
    MOV rowMinus, 23 ; Wrap index around screen

    next3of3:
    CMP columnMinus, 0 ; Check if new index is getting off screen
    JGE next3of4
    MOV columnMinus, 79 ; Wrap index around screen
    
    next3of4:
    CMP direction, 'w' ; Check if input direction is up
    JNE elseif3
    MOV AL, rowMinus ; Move head row index to new location,
    MOV headRow, AL ; above current location
    JMP endif3

    elseif3:
    CMP direction, 's' ; Check if input direction is down
    JNE elseif3to2
    MOV AL, rowPlus ; Move head row index to new location,
    MOV headRow, AL ; below current location
    JMP endif3

    elseif3to2:
    CMP direction, 'a' ; Check if input direction is left
    JNE else3
    MOV AL, columnMinus ; Move head column index to new location,
    MOV headColumn, AL ; left of current location
    JMP endif3

    else3:
    MOV AL, columnPlus ; Move head column index to new location,
    MOV headColumn, AL ; right of current location

    endif3:
    MOV DH, headRow ; Copy new head row index into DH
    MOV DL, headColumn ; Copy new head column index into DL
    CALL accessFrameIndex; Get pixel value of new head location

    CMP BX, 0 ; Check if new head location is empty space
    JE NoHit ; If the new head location is empty space, there has been no collision
    MOV EAX, 4000 ; Set delay time to 4000ms
    MOV DH, 24 ; Move cursor to new location, to write game over
    MOV DL, 11 ; message

    CALL GotoXY
    MOV EDX, OFFSET collision
    CALL WriteString
    CALL Delay ; Call delay to pause game for 4 seconds
    MOV endGame, 1 ; Set end game flag
    RET ; Exit procedure

    NoHit: ; Part of procedure that handles the case where
    MOV BX, 1 ; there's been no collision
    CALL writeIndexToFrame; Write head value to new head location

    MOV cl, foodColumn ; Copy food column to memory
    MOV ch, foodRow ; Copy food row to memory

    CMP cl, DL ; Compare new head column and food column
    JNE foodNotEaten ; Food has not been eaten
    CMP ch, DH ; Compare new head row and food row
    JNE foodNotEaten ; Food has not been eaten
    CALL FoodCreation ; Food has been eaten, create new food location
    MOV deleteTail, 0 ; Clear erase tail flag, so that snake grows in next framebuffer update
    MOV EAX, white + (black * 16)
    CALL SetTextColor ; Change background color to white on black
    PUSH EDX ; Push EDX onto stack
    MOV DH, 24 ; Move cursor to new location, to update score
    MOV DL, 7
    CALL GotoXY

    MOV EAX, totalScore ; Move score to EAX and increment it
    INC EAX
    CALL WriteDec
    MOV totalScore, EAX ; Copy updated score value back into memory
    POP EDX ; Pop EDX off of stack

    foodNotEaten: ; Part of procedure that handles the case where
    CALL GotoXY ; food has not been eaten (just adds head)
    MOV EAX, blue + (white * 16)
    CALL setTextColor ; Change text color to blue on white
    MOV AL, ' ' ; Write whitesoace to new head location
    CALL WriteChar
    MOV DH, 24 ; Move cursor to bottom right side of screen
    MOV DL, 79
    CALL GotoXY
    RET ; Exit procedure
MovingTheSnake ENDP



GenerateObstacle PROC
; This procedure takes care of generating the level obstacles. There are three
; levels; a no obstacle level, a box level, and a level with four rooms. The
; level choice gets passed through the AL register (can be 1 to 3). Default
; level choice is without obstacles.
; Obstacles get written into the framebuffer, as 0FFFFh values.
    
    CMP AL, 1 ; Check if level choice is without obstacles
    JNE boxObstacle ; If not, jump to next level selection
    RET ; Exit procedure, don't generate any obstacles. 
    boxObstacle: ; generating box obstacle
    CMP AL, 2
    JNE roomObstacle ; If not, jump to next level selection
    MOV DH, 0 ; Set row index to 0
    MOV BX, 0FFFFh ; Set data to be written to framebuffer
    rLoop: ; Loop for generating vertical lines
    CMP DH, 24 ; Check if loop has reached bottom of screen
    JE endRLoop ; Break loop if bottom of screen is reched
    MOV DL, 0 ; Set column index to 0 (left side of screen)
    CALL writeIndexToFrame; Write value stored in BX to framebuffer
    MOV DL, 79 ; Set column index to 79 (right side of screen)
    CALL writeIndexToFrame; Write value stored in BX to framebuffer
    INC DH ; Increment row value
    JMP rLoop ; Continue loop
    endRLoop:
    MOV DL, 0 ; Set column index to 0
    cLoop: ; Loop for generating horizontal lines
    CMP DL, 80 ; Check if loop has reached right side of screen
    JE endCLoop ; Break loop if right side of screen is reached
    MOV DH, 0 ; Set row index to 0 (top of screen)
    CALL writeIndexToFrame; Write value stored in BX to framebuffer
    MOV DH, 23 ; Set row index to 23 (bottom of screen)
    CALL writeIndexToFrame; Write value stored in BX to framebuffer
    INC DL ; Increment column value
    JMP cLoop ; Continue loop
    endCLoop:
    RET   
    roomObstacle: ; Section for generating rooms obstacle
    CMP AL, 3
    JNE mazeObstacle
    MOV newDirection, 'w' ; Set the default direction to up
    MOV DH, 8 ; start at row 8
    MOV DL, 0 ; Set row and column numbers to 8 and 0
    MOV BX, 0FFFFh ; Set value for writing into framebuffer
    cLoop2: ; Loop for painting a horizontal line of the screen (row 8)
    CMP DL, 35 ; Check if right side of screen was reached at 35
    JE endCLoop2
    CALL writeIndexToFrame; Write obstacle value to framebuffer
    INC DL ; Increment column number
    JMP cLoop2 ; Continue until right side of screen is reached at 35

    endCloop2: ; Prepare for next horizontal line painting
    MOV DH, 8 ; Start from row 8
    MOV DL, 50 ; horizontal line starts at column 50
    cLoop21: 
    CMP DL, 80 
    JE endCLoop21
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop21 
    endCloop21: 
    MOV DH, 16 
    MOV DL, 0 

    cLoop22: 
    CMP DL, 35 
    JE endCLoop22
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop22 
    endCloop22: 
    MOV DH, 16 
    MOV DL, 50 

    cLoop23: 
    
    CMP DL, 80 
    JE endCLoop23
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop23 
    endCloop23: 
    MOV DH, 0 
    MOV DL, 35 

    rLoop2: ; Loop for patining a vertical line 
    CMP DH, 6 ; of the screen (column 6)
    JE endRLoop2
    CALL writeIndexToFrame
    INC DH ; Increment row number
    JMP rLoop2 ; Continue until bottom of screen is reached at 6
    endRLoop2: ; Return from procedure after painting the line
    MOV DH, 19 
    MOV DL, 35 

    rLoop21: 
    CMP DH, 24 
    JE endRLoop21
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop21 
    endRLoop21: 
    MOV DH, 0 
    MOV DL, 50 

    rLoop22: 
    CMP DH, 6 
    JE endRLoop22
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop22 
    endRLoop22: 
    MOV DH, 19 
    MOV DL, 50 

    rLoop23: 
    CMP DH, 24 
    JE endRLoop23
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop23 
    endRLoop23: 
    
    RET
    mazeObstacle: ; maze obstacle loop
    MOV newDirection, 'w' ; Set the default direction to up, as not to run
    MOV DH, 0
    MOV DL, 0 
    MOV BX, 0FFFFh ; Set value for writing into framebuffe
    cLoop3: 
    CMP DL, 25 
    JE endCLoop3
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop3 
    endCloop3: 
    MOV DH, 0 
    MOV DL, 30 

    cloop4:
    CMP DL, 50 
    JE endCLoop4
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop4 

    endCloop4:
    MOV DH, 0 
    MOV DL, 55 

    cloop5:
    CMP DL, 80 
    JE endCLoop5
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop5 

    endCloop5:
    MOV DH, 8 
    MOV DL, 0 

    cloop6:
    CMP DL, 40 
    JE endCLoop6
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop6 

    endCloop6:
    MOV DH, 8 
    MOV DL, 50 

    cloop7:
    CMP DL, 80 
    JE endCLoop7
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop7 

    endCloop7:
    MOV DH, 16 
    MOV DL, 20 
    MOV BX, 0FFFFh 

    cloop8:
    CMP DL, 45 
    JE endCLoop8
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop8 

    endCloop8:
    MOV DH, 16 
    MOV DL, 50 

    cloop9:
    CMP DL, 80 
    JE endCLoop9
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop9 

    endCloop9:
    MOV DH, 23 
    MOV DL, 0 

    cloop10:
    CMP DL, 25 
    JE endCLoop10
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop10 

    endCloop10:
    MOV DH, 23 
    MOV DL, 30 

    cloop11:
    CMP DL, 50 
    JE endCLoop11
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop11 

    endCloop11:
    MOV DH, 23 
    MOV DL, 55 

    cloop12:
    CMP DL, 80 
    JE endCLoop12
    CALL writeIndexToFrame
    INC DL 
    JMP cLoop12 

    endCloop12:
    MOV DH, 4 
    MOV DL, 5 

    rLoop3: 
    CMP DH, 8 
    JE endRLoop3
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop3 
    endRLoop3: 
    MOV DH, 10 
    MOV DL, 5 


    rLoop4: 
    CMP DH, 17 
    JE endRLoop4
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop4 
    endRLoop4: 
    MOV DH, 19 
    MOV DL, 5 

    rLoop5: 
    CMP DH, 24 
    JE endRLoop5
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop5 
    endRLoop5: 
    MOV DH, 0 
    MOV DL, 20 

    rLoop6: 
    CMP DH, 6 
    JE endRLoop6
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop6 
    endRLoop6: 
    MOV DH, 12 
    MOV DL, 20 

    rLoop7: 
    CMP DH, 18 
    JE endRLoop7
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop7 
    endRLoop7: 
    MOV DH, 21 
    MOV DL, 20 

    rLoop8: 
    CMP DH, 24 
    JE endRLoop8
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop8 
    endRLoop8: 
    MOV DH, 9 
    MOV DL, 50 

    rLoop9: 
    CMP DH, 18 
    JE endRLoop9
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop9 
    endRLoop9: 
    MOV DH, 20 
    MOV DL, 50 

    rLoop10: 
    CMP DH, 24 
    JE endRLoop10
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop10 
    endRLoop10: 
    MOV DH, 4 
    MOV DL, 75 

    rLoop11: 
    CMP DH, 8 
    JE endRLoop11
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop11 
    endRLoop11: 
    MOV DH, 11 
    MOV DL, 75 

    rLoop12: 
    CMP DH, 17 
    JE endRLoop12
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop12 
    endRLoop12: 
    MOV DH, 20 
    MOV DL, 75 

    rLoop13: 
    CMP DH, 24 
    JE endRLoop13
    CALL writeIndexToFrame
    INC DH 
    JMP rLoop13 
    endRLoop13: 

    RET   
GenerateObstacle ENDP
END main