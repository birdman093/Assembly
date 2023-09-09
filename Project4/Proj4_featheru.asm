TITLE Project 4 Nested Loops and Procedures     (Proj4_featheru.asm)

; Author: Russell Feathers
; Last Modified: 02/10/21
; OSU email address: featheru@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 4            Due Date: 02/21/21
; Description: Program asks the user how many prime numbers (between 1 and 200) to display 
; and then plots out the numbers 10 to a line.  For extra credit part 1, the output has been
; set to align with the lines above.  For extra credit part 2, the user is allowed to plot 4000 numbers,
; and the numbers are still plotted 10 to a line, but in 20 number increments with the user pressing to 
; continue

INCLUDE Irvine32.inc

; Constants to control the min and max number of prime numbers that can be displayed
MIN_NUM = 1
MAX_NUM = 4000

; Constant controls when to shift display to next line
LINE_SWITCH	= 10
ROW_SHOW	= 200


.data

	;Program introductions, program exits, prompts, and error messages
	prog_name		BYTE	"Prime Numbers Programmed by Russell Feathers", 13,10,0
	EC_q1			BYTE	"**EC1: Align the output of columns to align",13,10,0
	EC_q2			BYTE	"**EC2: Extend range of primes to 4000, and display 20 at a time",13,10,0
	start			BYTE	"Enter the number of prime number you would like to see.", 13,10,0
	start_2			BYTE	"I'll accept orders of up to 4000 primes.", 13,10,0
	prompt_num		BYTE	"Enter the number of primes to display [1 ... 4000]: ", 0
	invalid_message	BYTE	"No primes for you! Number out of range. Try again.",13,10,0
	press_cont		BYTE	"Press Any key to continue", 13,10,0

	;String to control the spacing between different nubmers during display
	fiveSpaces		BYTE	"     ",0
	fourSpaces		BYTE	"    ",0
	threeSpaces		BYTE	"   ",0
	twoSpaces		BYTE	"  ",0
	oneSpaces		BYTE	" ",0

	;Goodbye messages
	goodbye			BYTE	"Results certified by Euclid. Goodbye.", 0

	;User input of number of prime values to display
	input_num		SDWORD	?

	;Values used to determine the next prime value
	quot_check		DWORD	?
	prime_value		DWORD	2
	divisor_value	DWORD	2
	counter_input	DWORD	?

.code
;------------------------------------------------------
;Name: main
;
;main is the primary procedure in this .asm file that calls the different procedures that introduce the user 
;	to the game, gets the user data, determines what numbers are primes and displays them, and then bids 
;	farewell to the user.  This procedure doesnt actually display or calculate anything but does call all the 
;	procedures that do display and calculate
;
;Preconditions: None 
;
;Postconditions: None
;
;Receives: None
;
;Returns: Exits the program upon completion
;------------------------------------------------------

main PROC

	CALL	Introduction
	CALL	getUserData
	CALL	showPrimesCounter
	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;------------------------------------------------------
;name: introduction
;
;Procedure to introduce the program by displaying introduction on how to play the game for the user as well as displaying
;	displaying the extra credit introduction statements
;
;Preconditions: prog_name, EC_q1, EC_q2, start, start_2 are strings that describe the program  
;
;Postconditions: None (EDX is changed but then returned to its original value)
;
;Receives: None
;
;Returns: None (displays intro statements during procedure call) 
;------------------------------------------------------

introduction	PROC
	;Store EDX variable on stack
	PUSH	EDX

	;Display Program Intro statements
	MOV		EDX, OFFSET prog_name
	CALL	WriteString
	CALL	crLF

	;Display Extra Credit Intro statements
	MOV		EDX, OFFSET EC_q1
	CALL	WriteString
	MOV		EDX, OFFSET EC_q2
	CALL	WriteString
	CALL	crLF

	;Display game requirement intro statements
	MOV		EDX, OFFSET start
	CALL	WriteString
	MOV		EDX, OFFSET start_2
	CALL	WriteString
	CALL	crLF

	;return to main function
	POP		EDX
	RET
introduction ENDP

;------------------------------------------------------
;name: getUserData
;
;Procedure to get user input data.  Procedure contains a subprocedure, validate, that determines if 
;	user input meets the min, max standards defined in constants
;
;Preconditions: Strings of prompt_num, and invalid_message 
;
;Postconditions:  None (EAX, EDX is changed but then returned to its original value) 
;
;Receives: None
;
;Returns: variable num_input, which contains number of prime numbers user entered
;------------------------------------------------------

getUserData		PROC

	;Store EAX, EDX variable on stack
	PUSH	EAX
	PUSH	EDX

	;Data Collection: Collect user input, and check whether user has opted to stop by selecting a non-negative number
_EntryLoop:
	MOV		EDX, OFFSET prompt_num
	CALL	WriteString
	CALL	ReadInt
	
	;Validation: Precondition to validate is that EAX stores value to check
	CALL	validate

	;Validation: Postcondition to validate is that value has been modified such that an invalid entry is 0 and is in EAX
	CMP		EAX, 0
	JZ		_InvalidEntry
	MOV		input_num, EAX
	CALL	CRLF
	JMP		_finishedEntry

	;Invalid Entry: Display inavalid entry message, and restart entry loop
_InvalidEntry:
	MOV		EDX, OFFSET invalid_message
	CALL	WriteString
	JMP		_EntryLoop

	;Valid entry has been determined, restore registers and return
_finishedEntry:
	POP		EDX	
	POP		EAX
	RET
getUserData		ENDP

;------------------------------------------------------
;name: validate
;
;Procedure checks whether the user input is between the specified MIN_NUM and MAX_NUM constant ranges.
;	If value is in range, then they remain unmodified, otherwise value is modified to 0. 
;
;Preconditions: EAX contains user input, MIN_NUM and MAX_NUM are global constants
;
;Postconditions: EAX modified
;
;Receives: user input stored in EAX
;
;Returns: EAX modified
;------------------------------------------------------

validate	PROC

	;Compare against global constants, MIN_NUM and MAX_NUM
	CMP		EAX, MIN_NUM
	JL		_False
	CMP		EAX, MAX_NUM
	JG		_False
	JMP		_Finished

	;Invalid Entry: adjust EAX to 0
_False:
	MOV		EAX, 0

_Finished:
	RET
validate	ENDP

;------------------------------------------------------
;name: showPrimes
;
;Procedure Displays prime numbers 10 per line using a loop and spaces the numbers so that they 
;	align from line to line.  Procedure also calls subprocedure, isPrimes, that determines if
;	a value is a prime number.  Dipslays values up to input_num, user input
;
;Preconditions: input_num stores user input, LINE_SWITCH, prime_value are global values, and
;	oneSpaces, twoSpaces, threeSpaces, and fourSpaces are global strings, ECX contains counter
;	value
;
;Postconditions: Prime_value is updated, ECX modified (EAX, EBX, EDX are modified but restored)
;
;Receives: Received ECX value from ShowPrimesCounter
;
;Returns: updated prime_value to last prime value calculated
;------------------------------------------------------

showPrimes		PROC
	;Store used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX

	;Store current counter input to determine correct 10th line item
	MOV		counter_input, ECX

_primePrint:
	
	;Find next prime number using is Prime (value stored at prime_value)
	CALL	isPrime

	; At 10th line item switch to next line by comparing counter against procedure input
	MOV		EBX, LINE_SWITCH
	MOV		EAX, counter_input
	SUB		EAX, ECX
	MOV		EDX, 0
	CDQ
	DIV		EBX
	CMP		EDX, 0
	JZ		_NewLineCall
	JMP		_Spacing

_NewLineCall:
	;New line Call
	CALL	CRLF

_Spacing:
	;End of IsPrime modified prime value, so subtract 1 and then display
	MOV		EAX, prime_value
	SUB		EAX, 1
	CALL	WriteDec

	; Write out so that each number has 7 total spaces including the number
	MOV		EDX, OFFSET twoSpaces	
	Call	WriteString
	CMP		EAX, 10000
	JGE		_loop
	CMP		EAX, 1000
	JGE		_oneSpaces
	CMP		EAX, 100
	JGE		_twoSpaces
	CMP		EAX, 10
	JGE		_threeSpaces	
	MOV		EDX, OFFSET fourSpaces	
	JMP		_fin

_oneSpaces:
	MOV		EDX, OFFSET oneSpaces	
	JMP		_fin

_twoSpaces:
	MOV		EDX, OFFSET twoSpaces	
	JMP		_fin

_threeSpaces:
	MOV		EDX, OFFSET threeSpaces	

_fin:
	Call	WriteString

_loop:
	LOOP 	_primePrint

	;Restore registers and return
	POP		EDX
	POP		EBX
	POP		EAX
	RET
showPrimes		ENDP

;------------------------------------------------------
;name: isPrimes
;
;Procedure determines whether a value is a prime number and then send that number back to ShowPrimes
;	to display the value.  Starts by dividing the current prime number (prime_value) by 2, and then 
;	dividing from 2 up to the quotient of prime_value divided by 2, and checking if there is zero 
;	remainder.  If there is zero remainder then the number is not prime and then prime value is updated 
;	and the next number is checked until the next prime value is found.  
;
;Preconditions: prime_value is a global value, divisor_check is a global value
;
;Postconditions: prime_value and divisor_value is modified (EAX, EBX, ECX, EDX are modified but restored)
;
;Receives: None
;
;Returns: prime_value is modified
;------------------------------------------------------

isPrime		PROC
	;Store used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX

_divisionCheck:

	; Divide current prime number by 2
	MOV		EAX, prime_value
	MOV		EDX, 0
	CDQ
	MOV		EBX, 2
	DIV		EBX
	MOV		quot_check, EAX

	; Check quotient value: if value less than 2 (i.e. 2 or 3) then it is prime
	CMP		EAX, 2
	JL		_isPrimeFin

	; Quotient value is 2 or greater, start divisor value at 2 and run while loop up to quotient value
	MOV		divisor_value, 2	

_divisorCheck:

	;divide prime_value by divisor value and compare remainder (EDX)
	MOV		EAX, prime_value
	MOV		EDX, 0 
	CDQ
	DIV		divisor_value

	;compare remainder value, if remainder is 0, then the divisor is a factor, and not prime
	CMP		EDX, 0
	JZ		_isnotPrime

	;remainder is not 0, still might be a prime value, but compare divisor value against quotient value
	INC		divisor_value
	MOV		EBX, quot_check
	CMP		EBX, divisor_value
	JL		_isPrimeFin
	JMP		_DivisorCheck

_isnotPrime:
	;Number is not prime, so increment prime value by 1, and start division checks again
	MOV		EAX, prime_value
	ADD		EAX, 1
	MOV		prime_value, EAX
	JMP		_divisionCheck

_isPrimeFin:
	; Found a prime value, but increment prime value for future loops
	MOV		EAX, prime_value
	ADD		EAX, 1
	MOV		prime_value, EAX

_finPrime:
	;Restore registers and return
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET
isPrime		ENDP

;------------------------------------------------------
;name: showPrimesCounter
;
;Procedure added as part of extra credit part 2 to control the showPrimes procedure to only show 200
;	prime values at a time.  Procedure has a while loop that prints up to 200 rows at a time
;
;Preconditions: input_num, ROW_SHOW as global constant, press_cont as string
;
;Postconditions: None (EAX, EBX, ECX, EDX modified but returned to before)
;
;Receives: None
;
;Returns: 
;------------------------------------------------------

showPrimesCounter	PROC
	;Store used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX

	; EBX to store counter values, ECX to be passed to showPrimes
	MOV		EBX, input_num
_rowsDisplay:
	CMP		EBX, ROW_SHOW
	JG		_Show200
	MOV		ECX, EBX	
	CALL	showPrimes
	JMP		_Fin

_Show200:
	SUB		EBX, ROW_SHOW
	MOV		ECX, ROW_SHOW
	CALL	showPrimes
	CALL	CRLF
	MOV		EDX, OFFSET press_cont
	CALL	WriteString
	CALL	ReadDec
	JMP	_rowsDisplay

_Fin:
	;Restore registers and return
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET

showPrimesCounter	ENDP


;------------------------------------------------------
;name: Farwell
;
;Farewell bids adieu to the user with a goodbye message
;
;Preconditions: goodbye as global string
;
;Postconditions: None
;
;Receives: None
;
;Returns: None
;------------------------------------------------------

farewell		PROC
	;Send to Exit program with goodbye message

	CALL	crLF
	CALL	CRLF
	MOV		EDX, OFFSET goodbye
	CALL	WriteString
	CALL	crLF
	RET
farewell		ENDP

END	main
