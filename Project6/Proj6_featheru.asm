TITLE Project 6 String Primitives and Macros   (Proj6_featheru.asm)

; Author: Russell Feathers
; Last Modified: 03/14/21
; OSU email address: featheru@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 6            Due Date: 03/14/21 (Pi Day!)
; Description: Program asks users for 10 signed decimal integers that fit within a 32 bit register, if user does not provide valid input
; then the user is prompted for another valid number.  After 10 valid inputs, the numbers are displayed, along with the sum, 
; and rounded average.  The program uses only string primitives and does not use WriteDec or WriteInt.  Extra Credit #1 was used and the input
; is numbered based on the number of valid numbers

INCLUDE Irvine32.inc

;Array and user entry constants
USR_ARR_LEN			= 10
USR_ARR_TYPE		= 4
USR_ENTRY_STORAGE	= 32
USR_ENTRY_BYTE		= 1

;------------------------------------------------------
;Name: mGetString
;
;mGetString is a macro that uses a prompt reference, a string reference, array type, and bytes read reference as input.  The macro then prompts the user
;	for input, stores the string input into the string reference, and stores the number of bytes read from the input. 
;
;Preconditions:			None, no register requirements
;
;Postconditions:		None, all used registers restored (EAX, ECX, EDX)
;
;Receives:				1)	starting address in memory of a message to prompt user for input
;						2)  string reference to store user input, length of string must be long enough for input
;						3)	type of values being input  (typically BYTES)
;						4)	address in memory to store the number of bytes read 
;
;Returns:				1)	stores string input in memory
;						2)	stores number of bytes read in memory
;------------------------------------------------------

mGetString	MACRO	prompt_ref, out_array_ref, type_const, bytes_read_ref
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX

	mDisplayString	prompt_ref

	;Read user input, store string in memory, store bytes read in memory
	MOV		EDX, out_array_ref
	MOV		ECX, type_const
	CALL	ReadString
	MOV		[bytes_read_ref], EAX

	POP		EAX
	POP		ECX
	POP		EDX
ENDM

;------------------------------------------------------
;Name: mDisplayString
;
;mDisplayString is a macro that displays a passed string starting address value using WriteString
;
;Preconditions:			None, no register requirements
;
;Postconditions:		None, all used registers restored (EDX) 
;
;Receives:				1)	Starting address of a string
;
;Returns:				None (displays input only)
;------------------------------------------------------

mDisplayString MACRO val_str
	PUSH	EDX
	MOV		EDX, val_str
	CALL	WriteString
	POP		EDX
ENDM

;------------------------------------------------------
;Name: mConvert_Int
;
;mConvert_Int is a macro that takes a user string address, length of the string to be used, an array reference for output, and an overflow reference 
;		for output.  The macro then takes the string input, converts to a numerical value and stores in the array reference.  Macro will store in 
;		the overflow identifier	reference whether the value overflows.
;
;Preconditions:			None, no register requirements
;
;Postconditions:		None, all used registers restored.
;
;Receives:				1) Starting address of user string 
;						2) Length of user string input
;						3) Address to store user string value
;						4) overflow identifier address location
;
;Returns:				1) Modfies array input to contain numeric value of string input
;						2) modifies overflow value in memory (DL =1 for error, DL = 0 for no error)
;------------------------------------------------------

mConvert_Int	MACRO	usr_str, usr_len, arr_add_ref, overflow_ref
;Create local variable to store address of array reference
    LOCAL arrayAddress
.data
    arrayAddress	DWORD	?
	negCheck		DWORD	0

.code
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
	MOV		arrayAddress, arr_add_ref

;Sign Check: if negative store sign until end in EDX
	CLD
	MOV		ECX, [usr_len]
	MOV		EDI, 0
	MOV		EBX, 0
	MOV		ESI, usr_str
	MOV		DL, 45
	CMP		BYTE PTR [ESI], DL		;compare against negative sign
	JE		_NegCheck
	JMP		_PosCheck
_NegCheck:
	ADD		ESI, 1			;plus sign, move to next character
	SUB		ECX, 1
	MOV		negCheck, 1
	JMP		_CalcLoop

_PosCheck:
	MOV		DL, 43
	CMP		BYTE PTR [ESI], DL		;compare character against plus sign
	JNE		_Nothing
	ADD		ESI, 1			;plus sign, move to next character
	SUB		ECX, 1
	MOV		negCheck, 0
	JMP		_CalcLoop
_Nothing:
	MOV		negCheck, 0

;Calculation: Convert string to numeric value, check for overflow errors
_CalcLoop:
	MOV		EAX, 0
	LODSB					;AL contains current ASCII character
	SUB		AL, 48			;AL contains current integer value
	MOV		BL, AL
	MOV		EAX, 10
	IMUL	EDI				;Check if multiplication generated an overflow error
	JO		_OverFlowError
	ADD		EAX, EBX		;Check if addition generated an overflow error
	JO		_OverFlowError
	MOV		EDI, EAX

	LOOP	_CalcLoop

;Use Sign Check from above, if negative then negate value
	MOV		EDX, negCheck
	CMP		EDX, 1
	JE		_Negate
	JMP		_Positive
_Negate:
	MOV		EDX, overflow_ref
	MOV		BYTE PTR [EDX], 0
	NEG		EDI

;Valid, non-overflowed number, store in array
_Positive:
	MOV		EDX, overflow_ref
	MOV		BYTE PTR [EDX], 0
	MOV		EAX, SDWORD PTR [arrayAddress]
	MOV		SDWORD PTR [EAX], EDI

	JMP		_Exit

;Overflow Error, send info back to procedure, no storage
_OverFlowError:
	MOV		EDX, overflow_ref
	MOV		BYTE PTR [EDX], 1

_Exit:
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
ENDM


.data

	;Introduction strings
	prog_name_1		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13,10,0
	prog_name_2		BYTE	"Written by: Russell Feathers", 13, 10, 0
	intro_instr_l1	BYTE	"Please provide 10 signed decimal integers.Each number needs to be small enough to fit",13, 10,0 
	intro_instr_l2	BYTE	"inside a 32 bit register. After you have finished inputting the raw numbers,",13,10,0 
	intro_instr_l3	BYTE	"I will display a list of the integers, their sum, and their average value.", 13,10,0 

	;Extra Credit strings
	extra_credit_1	BYTE	"EC #1: Number each line of user input, displaying subtotal of valid input using WriteVal",13,10,0

	;User input prompt strings
	usr_prompt		BYTE	"Please enter a signed number: ", 0
	Error_mess		BYTE	"ERROR: You did not enter a signed number or your number was too big.", 13,10,0
	usr_prompt_mess BYTE	"Please try again: ",0


	;summary strings
	num_summary		BYTE	"You entered the following numbers: ", 13,10, 0
	sum_summary		BYTE	"The sum of these numbers is: ", 0
	round_summary	BYTE	"The rounded average is: ", 0
	comma			BYTE	",",0
	ec1_string		BYTE	".) ",0 

	;Goodbye string
	goodbye_string	BYTE	"Thanks for playing! ", 0

	;user input Array data
	usrString		BYTE	USR_ENTRY_STORAGE DUP(0)
	usrArray		SDWORD	USR_ARR_LEN DUP(?)
	tempString		BYTE	USR_ENTRY_STORAGE DUP(0)
	stor_address	DWORD	?
	byte_read		DWORD	?
	sum				SDWORD	?
	rnd_avg			SDWORD	?
	overflow		BYTE	0


.code
;------------------------------------------------------
;Name: main
;
;main is the primary procedure in this .asm file that calls the different procedures that display the program introduction;
;	calls ReadVal to get the user input, and CalcVal to calculate the user input, and display the summary
;
;Preconditions: Arrays, and strings are predefined in the .data section of the file as needed for each file input 
;
;Postconditions: None
;
;Receives: None
;
;Returns: Exits the program upon completion
;------------------------------------------------------

main PROC
	;Introduction and parameters (6 inputs, return 24)
	PUSH	OFFSET intro_instr_l3
	PUSH	OFFSET intro_instr_l2
	PUSH	OFFSET intro_instr_l1
	PUSH	OFFSET extra_credit_1
	PUSH	OFFSET prog_name_2
	PUSH	OFFSET prog_name_1
	CALL	Introduction

	;Read Val asks for 10 user input values, and stores value in user array (11 inputs, return 44)
	PUSH	OFFSET ec1_string
	PUSH	OFFSET overflow
	PUSH	OFFSET Error_mess
	PUSH	OFFSET usrArray	
	PUSH	USR_ARR_TYPE
	PUSH	OFFSET usr_prompt_mess
	PUSH	USR_ARR_LEN
	PUSH	OFFSET byte_read
	PUSH	USR_ENTRY_STORAGE		
	PUSH	OFFSET usrString			
	PUSH	OFFSET usr_prompt
	CALL	ReadVal

	;CalcVal takes user array and length and displays numbers, sum, and average (8 inputs, return 32)
	PUSH	OFFSET comma
	PUSH	OFFSET tempString
	PUSH	OFFSET sum
	PUSH	OFFSET rnd_avg
	PUSH	USR_ARR_LEN
	PUSH	OFFSET usrArray
	PUSH	OFFSET round_summary
	PUSH	OFFSET sum_summary			
	PUSH	OFFSET num_summary		
	CALL	CalcVal

	;farewell and parameters
	PUSH	OFFSET goodbye_string
	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;------------------------------------------------------------------------------------
;name: introduction
;
;Displays program name and author, extra credit strings, and program instructions
;
;Preconditions:		None, no register requirements
;
;Postconditions:	None, all registers used are restored
;
;Receives:			1) Address of (2) strings that contains program name and author
;					2) Address of (3) Program instruction strings	
;					3) Address of (1) extra credit string
;
;Returns:			None
;----------------------------------------------------------------------------------------

introduction	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EDX
	PUSH	ECX
	MOV		EBP, ESP
	ADD		EBP, 16				;moves base pointer to first parameter

	;Display Program name and author
	MOV		ECX, 2
_NameLoop:
	mDisplayString	[EBP]
	ADD		EBP, 4
	LOOP	_NameLoop
	CALL	crLF

	;Display Extra Credit
	mDisplayString [EBP]
	ADD		EBP, 4
	CALL	crLF

	;Display Program instructions
	MOV		ECX, 3
_IntroLoop:
	mDisplayString	[EBP]
	ADD		EBP, 4
	LOOP	_IntroLoop
	CALL	crLF

	;Restore registers and base pointer
	POP		ECX
	POP		EDX
	POP		EBP
	RET		24
introduction ENDP

;------------------------------------------------------------------------------------
;name: ReadVal
;
;ReadVal procedure takes user display messages, information on arrays, user string memory address, and then prompts the user for 10 signed values, 
;	and stores those values in the referenced array
;
;Preconditions:			None, no register requirements
;
;Postconditions:		None, all registers used are restored
;
;Receives:				1) user prompt message
;						2) (2) user error messages for when a number does not fit in a 32 bit register or is not a legal number
;						3) array starting address reference, type of data (BYTE, DWORD, etc.) and its length to store user input data as a numerica value
;						4) string starting address with sufficient space to store user input, max allowable length, and a bytes read reference to store data on how much info was read
;
;Returns:				1) Stores user input values in array
;						2) Modifies user string, and bytes read references in memory
;----------------------------------------------------------------------------------------
ReadVal			PROC
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		EBP, ESP
	ADD		EBP, 32				;moves base pointer to first parameter

;PUSHED: OFFSET usr_prompt [EBP], OFFSET usrString [EBP+4], USR_ENTRY_STORAGE [EBP+8], OFFSET byte_read [EBP+12], USR_ARR_LEN [EBP+16], OFFSET usr_prompt_mess [EBP+20]
;USR_ARR_TYPE [EBP+24], OFFSET usrArray [EBP+28], OFFSET Error_mess [EBP+32], OFFSET overflow [EBP+36] 	OFFSET ec1_string [EBP+40]


	;Set loop to run for number of user input constant value
	MOV		ECX, [EBP+16]					
_UsrLoop:
	MOV		EBX, [EBP]
	JMP		_Normal

_ReEntry:
	mDisplayString	[EBP+32]
	MOV		EBX, [EBP+20]

_Normal:
	;Clear User input string
	PUSH	ECX			
	CLD
	MOV		EDI, [EBP+4]
	MOV		AL, 0
	MOV		ECX, [EBP+8]
	REP		STOSB
	POP		ECX

	;EC#1, number each line of input, increments only after valid input
	MOV		EAX, [EBP+16]
	SUB		EAX, ECX
	ADD		EAX, 1
	PUSH	[EBP+4]
	PUSH	EAX
	CALL	WriteVal
	mDisplayString [EBP+40]

	;User Input: Call macro to get user string input: EBX contains prompt, [EBP+4] contains user string reference, [EBP+8] contains length of user string reference, [EBP+12] contains 
	;address to store the number of bytes read

	mGetString	EBX, [EBP+4], [EBP+8], [EBP+12]

	;Validation: User String Entry address in ESI
	PUSH	ECX								;Nested loop, store ECX
	CLD
	MOV		ECX, [EBP+12]
	MOV		ESI, [EBP+4]
	MOV		AL, 0

	;Validation: first value can be + or -, other characters must be Check for 0 through 9 characters (ASCII integer values between 48 and 57 inclusively)
	MOV		DL, 43
	CMP		BYTE PTR [ESI], DL
	JE		_IncOne
	MOV		DL, 45
	CMP		BYTE PTR [ESI], DL
	JE		_IncOne
	JMP		_LetterLoop
_IncOne:
	ADD		ESI, 1
	SUB		ECX, 1
_LetterLoop:
	LODSB	
	CMP		AL, 48
	JB		_ReEntryExit
	CMP		AL, 57
	JA		_ReEntryExit
	Loop	_LetterLoop
	JMP		_Fin

	;ERROR in Validation: send back to start
_ReEntryExit:
	POP		ECX
	JMP		_ReEntry

_Fin:
	POP		ECX

	;Storage of user input address calculation:  Update next usrArray address in EBX based on ECX counter
	;Convert to integer value from ASCII, store value at address generated above, macro changes value of DL based on overflow
	
	MOV		EBX, [EBP+28]		;starting address of usrArray
	MOV		EAX, [EBP+16]		;len of usrArray
	SUB		EAX, ECX			;adjust index based on counter, and size
	MUL		DWORD PTR [EBP+24]
	ADD		EBX, EAX
	mConvert_Int	[EBP+4], [EBP+12], EBX, [EBP+36]	

	;OverFlow Validation: Check for error in overflow, 1 indicates error
	MOV		EDX, [EBP+36]
	MOV		EBX, 1
	CMP		BYTE PTR [EDX], BL
	JE		_ReEntry
	SUB		ECX, 1
	CMP		ECX, 0
	JNE		_UsrLoop

	;Restore registers and base pointer
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		44

ReadVal			ENDP

;------------------------------------------------------------------------------------
;name: WriteVal
;
;WriteVal takes a signed numeric value and converts it to a string.  WriteVal then calls mDisplayString macro which 
;	displays the value. 
;
;Preconditions:			None, no register requirements
;
;Postconditions:		None, all registers used are restored 
;
;Receives:				1) starting memory address for user string 
;						2) numeric value (SDWORD)
;
;Returns:				1) modifies values at memory address for user string
;----------------------------------------------------------------------------------------
WriteVal		PROC
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		EBP, ESP
	ADD		EBP, 32				;moves base pointer to first parameter

	MOV		EDI, [EBP+4]		;temporary string address
	MOV		EBX, [EBP]			;value to convert

	CMP		EBX, 0
	JGE		_PreDivision
	NEG		EBX					;make value positive to simplify conversion
	MOV		AL,	45				;negative sign
	CLD
	STOSB


_PreDivision:
	;Divide by 10 until quotient is zero, store that value, and counter
	MOV		ECX, 0
	MOV		EAX, EBX
_Division:
	MOV		EDX, 0
	MOV		ESI, 10				
	CDQ
	DIV	ESI						;EAX/ESI  --> result in EAX:EDX
	CMP		EAX, 0				;If quotient is zero, reached end of divisions
	JE		_LoadValOne
	ADD		ECX, 1
	JMP		_Division

_LoadValOne:
	ADD		DL, 48				;48 is 0 character in ASCII
	MOV		AL, DL
	STOSB

;ECX contains number of division steps until reach value to add
	CMP		ECX, 0
	JE		_Exit
_DivSteps:
	MOV		EAX, [EBP]			;start with fresh value from stack
	CMP		EAX, 0
	JGE		_Continue
	NEG		EAX					;Negative values need to be negated

_Continue:
	MOV		EBX, ECX

;decrements EBX, divides by 10 until set amount then stores in string
_DivLoop:
	MOV		ESI, 10
	MOV		EDX, 0
	CDQ
	DIV	ESI

	SUB		EBX, 1
	CMP		EBX, 0
	JNE		_DivLoop
	ADD		DL, 48				;48 is 0 character in ASCII
	MOV		AL, DL
	STOSB

	LOOP	_DivSteps

_Exit:
;Store 0 at end of string
	MOV		AL, 0
	STOSB

;Display Info
	mDisplayString	[EBP+4]

	;Restore registers and base pointer
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8
WriteVal		ENDP


;------------------------------------------------------------------------------------
;name: CalcVal
;
;CalcVal procedure takes usr array address, summary string messages, and memory references to store sum and rounded average
;	values. CalcVal calls WriteVal to assist in writing these values out
;
;Preconditions:			None, no register requirements
;
;Postconditions:		None, all registers used are restored 
;
;Receives:				1) (3) summary string messages, and a comma string
;						2) User array length, and user array address
;						3) memory addreses to store sum and rounded average
;						4) temporary string to use for converting numeric values to strings 
;
;Returns:				1) Updates sum and rounded average references in memory
;						2) Modifies tempString reference in memory 
;----------------------------------------------------------------------------------------
CalcVal			PROC
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		EBP, ESP
	ADD		EBP, 32						;moves base pointer to first parameter

;-----Display 1:  Number Summary
	;Display summary of numbers prompt
	CALL	CRLF
	mDisplayString	[EBP]

	;Set counter to array length, clear EAX
	MOV		ECX, [EBP+16]
	MOV		EAX, 0
	MOV		ESI, [EBP+12]

_SummaryLoop:
	LODSD
	PUSH	[EBP+28]					;temp string location
	PUSH	EAX							;Current array value
	CALL	WriteVal
	CMP		ECX, 1
	JE		_NoComma
_Comma:
	mDisplayString	[EBP+32]
	
_NoComma:
	LOOP	_SummaryLoop
	CALL	CRLF

;-------Display 2:  Summation Summary
	;Display prompt for sum of input numbers
	mDisplayString	[EBP+4]

	;Calculate sum of input numbers
	MOV		ECX, [EBP+16]				;array length
	MOV		EBX, 0						;sum calc
	MOV		ESI, [EBP+12]				;first array value
_SumLoop:
	LODSD
	ADD		EBX, EAX
	LOOP	_SumLoop

	MOV		EDX, [EBP+24]
	MOV		[EDX], EBX					;save sum value

	PUSH	[EBP+28]					;temp string location
	PUSH	EBX							;Current sum value
	CALL	WriteVal
	CALL	CRLF

;--------Display 3:  Rounded Average Summary
	;Display prompt for avg of input numbers
	
	mDisplayString	[EBP+8]

	;Calculate average and store value (sum stored in EBX, divisor off stack)--> result in EAX
	MOV		EDX, 0
	MOV		EAX, EBX
	CDQ
	IDIV	SDWORD PTR [EBP+16]

	MOV		EDX, [EBP+20]
	MOV		[EDX], EAX

	PUSH	[EBP+28]					;temp string location
	PUSH	EAX							;Current sum value
	CALL	WriteVal

	;Restore registers and base pointer
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		36
CalcVal		ENDP

;------------------------------------------------------
;name: Farwell
;
;Farewell bids adieu to the user with a goodbye message
;
;Preconditions:		None, no register requirements
;
;Postconditions:	None, all registers restored
;
;Receives:			1) Starting address of goodbye string, BYTE type
;
;Returns:			None
;------------------------------------------------------

farewell		PROC
	;Send to Exit program with goodbye message
	PUSH	EDX
	PUSH	EBP
	MOV		EBP, ESP
	ADD		EBP, 12

	CALL	CrLF
	CALL	CRLF
	mDisplayString	[EBP]
	CALL	crLF

	POP		EBP
	POP		EDX
	RET		4
farewell		ENDP

END	main
