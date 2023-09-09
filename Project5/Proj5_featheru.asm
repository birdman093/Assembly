TITLE Project 5 Arrays, Addressing, and Stack Passed Parameters     (Proj5_featheru.asm)

; Author: Russell Feathers
; Last Modified: 02/27/21
; OSU email address: featheru@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 5            Due Date: 02/28/21
; Description: Program creates an array of random numbers, then sorts the array, provides the median value,
; and then puts the number of occurences of each number into an array.  All results are displayed for user. 
; Extra Credit options 1 and 2 provided to sort by column, and to read/ write to a text file

INCLUDE Irvine32.inc

ARRAYSIZE	= 200
LO			= 7
HI			= 32

; Constant controls when to shift display to next line
LINE_SWITCH	= 20

.data

	;Introduction strings
	prog_name		BYTE	"Prime Numbers Programmed by Russell Feathers", 13,10,0
	intro_instr_l1	BYTE	"This program generates 200 random numbers in the range [10 ... 29], displays the original list,",13, 10,0 
	intro_instr_l2	BYTE	"sorts the list, displays the median value of the list, displays the list sorted in ascending order,",13,10,0 
	intro_instr_l3	BYTE	"then displays the number of instances of each generated value, starting with the number of 10s.", 13,10,0 

	;Extra Credit strings
	extra_credit_1	BYTE	"EC #1: Display sorted numbers by column instead of by row",13,10,0
	extra_credit_2	BYTE	"EC #2: Write random numbers directly to txt file, then read file into stored array in fillArray procedure.",13,10,0
	sort_str_EC1	BYTE	"EC #1: Your sorted random numbers by column:",0

	;Sorting string headers
	unsorted_string	BYTE	"Your unsorted random numbers:", 0
	median_string	BYTE	"The median value of the array: ", 0
	sorted_string	BYTE	"Your sorted random numbers:",0
	list_string		BYTE	"Your list of instances of each generated number, starting with the number of 10s:", 0

	;Goodbye messages
	goodbye_string	BYTE	"Goodbye, and thanks for using this program!", 0

	;Array data
	someArray		BYTE	ARRAYSIZE DUP(?)
	median			BYTE	?
	countArray		BYTE	HI DUP(?)
	countSize		DWORD	?

	;EC2 file name, buffer, and file handle save
	file_name		BYTE	"extraCredit_2.txt",0
	buffer_byte		BYTE	1 DUP(?)


.code
;------------------------------------------------------
;Name: main
;
;main is the primary procedure in this .asm file that calls the different procedures that display the program introduction
;	create a random array of numbers, provides the median of those numbers, then displays a sorted array of the random 
;	numbers, then provides a list that contains the number of each number, before bidding farewell
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
	;Introduction and parameters
	PUSH	OFFSET extra_credit_1
	PUSH	OFFSET extra_credit_2
	PUSH	OFFSET intro_instr_l3
	PUSH	OFFSET intro_instr_l2
	PUSH	OFFSET intro_instr_l1
	PUSH	OFFSET prog_name
	CALL	Introduction

	;fillArray_EC2 and parameters
	PUSH	OFFSET file_name
	PUSH	OFFSET buffer_byte
	PUSH	OFFSET someArray
	PUSH	LO
	PUSH	HI
	PUSH	ARRAYSIZE
	CALL	fillArray_EC2

	;displayList and parameters
	PUSH	LINE_SWITCH
	PUSH	OFFSET unsorted_string
	PUSH	OFFSET someArray
	PUSH	ARRAYSIZE
	CALL	displayList

	;mergeSort and parameters
	PUSH	OFFSET someArray
	PUSH	ARRAYSIZE
	CALL	mergeSort

	;displayMedian and parameters
	PUSH	OFFSET median_string
	PUSH	OFFSET someArray
	PUSH	ARRAYSIZE
	CALL	displayMedian

	;displayList and parameters
	PUSH	LINE_SWITCH
	PUSH	OFFSET sorted_string
	PUSH	OFFSET someArray
	PUSH	ARRAYSIZE
	CALL	displayList

	;displayList_EC1 and parameters
	PUSH	LINE_SWITCH
	PUSH	OFFSET sort_str_EC1
	PUSH	OFFSET someArray
	PUSH	ARRAYSIZE
	CALL	displayList_EC1

	;countList and parameters
	PUSH	OFFSET countSize
	PUSH	OFFSET someArray
	PUSH	ARRAYSIZE
	PUSH	OFFSET countArray
	PUSH	LO
	PUSH	HI
	CALL	countList

	;displayList and parameters
	PUSH	LINE_SWITCH
	PUSH	OFFSET list_string
	PUSH	OFFSET countArray
	PUSH	countSize
	CALL	displayList

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
;Preconditions: None, no register requirements
;
;Postconditions: None, all registers used are restored
;
;Receives:	1) Address of string that contains program name and author
;			2) Address of (2) Extra Credit Strings
;			3) Address of (3) Program instruction strings	
;
;Returns: None
;----------------------------------------------------------------------------------------

introduction	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EDX
	PUSH	ECX
	MOV		EBP, ESP
	ADD		EBP, 16				;moves base pointer to first parameter

	;Display Program name
	MOV		EDX, [EBP]
	CALL	WriteString
	CALL	crLF

	;Display extra credit 1 and 2
	MOV		EDX, [EBP+20]
	CALL	WriteString
	MOV		EDX, [EBP+16]
	CALL	WriteString
	CALL	CrLF

	;Display Program instructions through loop
	MOV		ECX, 3
_IntroLoop:
	ADD		EBP, 4
	MOV		EDX, [EBP]
	CALL	WriteString
	LOOP	_IntroLoop
	CALL	crLF

	;Restore registers and base pointer
	POP		ECX
	POP		EDX
	POP		EBP
	RET		24
introduction ENDP

;----------------------------------------------------------------------------------------------------------------------
;name: fillArray_EC2
;
;Procedure fills a text file one by one with random numbers between Lo and Hi per constants, and then writes the values from the text
;	file the array specified in the input
;
;Preconditions:		None, no register requirements
;
;Postconditions:	None, all registers restored
;
;Receives:			1)	Starting address of array, where each element is one BYTE
;					2)	array size constant value -- positive value, varies between 180 and 220
;					3)  Lo constant value -- positive value, varies between 7 and 12
;					4)	Hi constant value -- positive value, varies between 27 and 32.
;					5)	starting address of string that contains file name to write and read from
;					6)	byte identifier to store byte sized buffer data into
;
;Returns:			1) Array is populated with random numbers between Lo and Hi
;					2) File created called by name received by function, file is unreadable by humans
;------------------------------------------------------------------------------------------------------------------------

fillArray_EC2	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		EBP, ESP
	ADD		EBP, 32				;moves base pointer to first parameter

	CALL	RANDOMIZE
	
	;Set parameters for random:  Hi must be modified by subtracting the lo number and adding 1
	MOV		EAX, [EBP+4]		;Hi 
	MOV		EBX, [EBP+8]		;Lo 
	SUB		EAX, EBX
	ADD		EAX, 1
	MOV		EDI, EAX			;store modified high bound for random

	;Open txt file for use, store file handle in ESI
	MOV		EDX, [EBP+20]
	CALL	createOutputFile
	MOV		ESI, EAX

	;Set counter equal to arraySize
	MOV		ECX, [EBP]			;ArraySize

	;Generate random numbers and then write each values into txt file one by one
_ArrayLoop:
	MOV		EAX, EDI			;Adjust hi random number every iteration
	CALL	RandomRange			;Stores value in EAX
	ADD		EAX, [EBP+8]		;Add Lo to random variable	
	MOV		EBX, EAX
	MOV		EAX, [EBP+16]
	MOV		[EAX], BL			;Store value in buffer_byte

	;File Writing, store local variables on stack as needed
	PUSH	ECX					;Store counter on stack
	PUSH	EDX					;Store Lo value on stack
	MOV		EAX, ESI
	MOV		ECX, 1
	MOV		EDX, [EBP+16]
	CALL	WritetoFile
	POP		EDX
	POP		ECX

	LOOP	_ArrayLoop

	;Close File and then Open file again
	MOV		EAX, ESI
	CALL	CloseFile
	MOV		EDX, [EBP+20]
	CALL	OpenInputFile
	MOV		ESI, EAX

	;ReadFile into SomeArray
	MOV		EAX, ESI
	MOV		ECX, [EBP]
	MOV		EDX, [EBP+12]
	CALL	ReadFromFile

	;Close File
	MOV		EAX, ESI
	CALL	CloseFile

	;Restore registers and base pointer
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		24
fillArray_EC2	ENDP
 
;---------------------------------------------------------------------------------------------------------
;NOT USED/ OVERRIDDEN by fillArray_EC2; for reference only
;
;name: fillArray
;
;Fills an input array of input size with random numbers that are between a Lo and Hi input value. 
;
;Preconditions:		1) Some array is a BYTE array
;
;Postconditions:	None, all registers restored
;
;Receives:			1)	Starting address of array, where each element is one BYTE
;					2)	array size constant value -- positive value, varies between 
;					3)  Lo constant value -- positive value, varies between 7 and 12
;					4)	Hi constant value -- positive value, varies between 180 and 220.
;
;Returns:			1) Array is populated with random numbers between Lo and Hi
;--------------------------------------------------------------------------------------------------------------

fillArray	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	MOV		EBP, ESP
	ADD		EBP, 28				;moves base pointer to first parameter

	CALL	RANDOMIZE
	
	;Set parameters for random:  Hi must be modified by subtracting the lo number and adding 1
	MOV		EAX, [EBP+4]		;Hi 
	MOV		EBX, [EBP+8]		;Lo 
	SUB		EAX, EBX
	ADD		EAX, 1
	MOV		EBX, EAX			;store modified bounds in EBX
	
	;Adjust EDI to point at array, set counter equal to arraySize
	MOV		EDI, [EBP+12]		;someArray		
	MOV		ECX, [EBP]			;ArraySize
	MOV		EDX, [EBP+8]		;Lo

_ArrayLoop:
	MOV		EAX, EBX			;Adjust hi every iteration
	CALL	RandomRange
	MOV		[EDI], AL
	ADD		[EDI], EDX			;Add Lo to every random
	ADD		EDI, 1
	LOOP	_ArrayLoop

	;Restore registers and base pointer
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		16
fillArray	ENDP

;------------------------------------------------------------------------------------------------------------------------------
;name: displayList
;
;Displays a string header regarding an array and displays the values of an array row by row.  Row length is specified by user 
;
;Preconditions:		1) Some array is a BYTE array
;
;Postconditions: None, all registers restored
;
;Receives:		1) Constant value -- determines length of row to display
;				2) Starting address of string that contains a heading for the array
;				3) Starting address of an array where each element is one BYTE
;				4) Value of length of an array, DWORD
;
;Returns: None
;-----------------------------------------------------------------------------------------------------------------------------------

displayList	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	MOV		EBP, ESP
	ADD		EBP, 28				;moves base pointer to first parameter

	;Display heading string input
	MOV		EDX, [EBP+8]		;string
	CALL	WriteString
	CALL	CRLF

	;Adjust EDI to point at array, set counter equal to arraySize
	MOV		ECX, [EBP]			;ArraySize
	MOV		EDI, [EBP+4]		;Array address start	
	MOV		EBX, 0				;line switch counter

_ArrayLoop:
	; Display value stored at array address
	MOV		EAX, 0
	MOV		AL, [EDI]
	CALL	WriteDec

	;This is a weird bit in the code where some spaces (32) before tabbing (09) was needed to prevent errors in display
	MOV		AL, 32
	CALL	WriteChar
	CALL	WriteChar
	CALL	WriteChar
	MOV		AL, 9
	CALL	WriteChar

	ADD		EDI, 1			;increment to next number in array
	ADD		EBX, 1			;update line switch counter
	CMP		EBX, [EBP+12]	;compare against lineswitch
	JNE		_Next_Num

	;Feed new line, reset counter
	CALL	CRLF
	MOV		EBX, 0

_Next_Num:
	LOOP	_ArrayLoop

	CALL	CRLF
	CALL	CRLF

	;Restore registers and base pointer
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		16
displayList	ENDP

;------------------------------------------------------
;name: displayList_EC1
;
;Extra Credit #1 Procedure: Displays a string header regarding array, then displays the values of an array column by column.  
;	Row length is specified by user. 
;
;Preconditions:		1) Some array is a BYTE array
;
;Postconditions: None, all registers restored
;
;Receives:		1) Constant value -- determines max length of row to display
;				2) Starting address of string that contains a heading for the array
;				3) Starting address of an array where each element is one BYTE
;				4) Value of length of an array, DWORD
;
;Returns: None
;------------------------------------------------------

displayList_EC1	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		EBP, ESP
	ADD		EBP, 32				;moves base pointer to first parameter

	;Display heading string input
	MOV		EDX, [EBP+8]
	CALL	WriteString
	CALL	CRLF

	;Calculate row_switch by dividing array size by line switch constant
	MOV		EDX, 0
	MOV		EAX, [EBP]
	MOV		EBX, [EBP+12]
	CDQ
	DIV		EBX
	CMP		EDX, 0
	JZ		_Continue
	ADD		EAX, 1

_Continue:
	MOV		ECX, EAX			;Set loop counter based on number of rows
	MOV		ESI, ECX			;Store # of rows needed, does not change
	MOV		EDX, [EBP+4]		
	ADD		EDX, [EBP]			
	SUB		EDX, 1				;Store last item address, does not change
	
_RowCounterLoop:
	MOV		EDI, [EBP+4]		;reset to Array starting address
	MOV		EAX, ESI
	SUB		EAX, ECX
	ADD		EDI, EAX
	MOV		EBX, 0				;loop counter for number of numbers per line
_LineSwitchLoop:
	
	CMP		EDI, EDX			;Check if reaching beyond array
	JA		_NextNum

	;Dispaly current value of array at EDI
	MOV		EAX, 0
	MOV		AL, [EDI]
	CALL	WriteDec

	;This is a weird bit in the code where some spaces (32) before tabbing (09) was needed to prevent errors in display
	MOV		AL, 32	
	CALL	WriteChar
	CALL	WriteChar
	CALL	WriteChar
	MOV		AL, 9
	CALL	WriteChar

	;determine next value index, update line switch counter, compare to line switch and determine if continue or switch to next line
	MOV		EAX, ESI
	ADD		EDI, ESI
	ADD		EBX, 1		
	CMP		EBX, [EBP+12]
	JE		_NextNum	
	JMP		_LineSwitchLoop

_NextNum:
	CALL	CRLF
	LOOP	_RowCounterLoop

	CALL	CRLF
	;Restore registers and base pointer
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		16
displayList_EC1	ENDP

;-----------------------------------------------------------------------------------------------------------------------------
;name: mergeSort
;
;Sorts an unordered list to be from lowest to highest using mergeSort.  mergeSort modifies the list rather than creating a 
;	new list.  MergeSort functions using recursion.
;
;Preconditions:		1) Some array is a BYTE array
;
;Postconditions:	None, all registers restored
;
;Receives:			1)	Starting address of array, each element of BYTE size
;					2)	Constant value -- Size of array specified in 1)
;
;Returns:			1)	Input array is modified to have sorted elements
;---------------------------------------------------------------------------------------------------------------------------------

mergeSort		PROC
	;Store changed registers and base pointer
	;For reference:  EBP --> ArraySize, EBP+4 --> Start Address of SomeArray
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		EBP, ESP
	ADD		EBP, 32				;moves base pointer to first parameter

	MOV		EAX, [EBP]			; Base Case: Compare Array size to 1
	CMP		EAX, 1			
	JNA		_Fin

	;Divide ArraySize by 2 to get middle, result stored in EBX
	MOV		EDX, 0
	MOV		EBX, 2
	CDQ
	DIV		EBX
	MOV		EBX, EAX

	;mergeSort on left side of array
	PUSH	[EBP+4]			;address of left side start
	PUSH	EBX				;mid point calculated above
	CALL	mergeSort

	;mergeSort on right side of array
	MOV		EDX, [EBP]		;length of array
	SUB		EDX, EBX		;subtract mid point from length of array
	MOV		ECX, [EBP+4]		
	ADD		ECX, EBX		;increment right side by mid-point
	PUSH	ECX				;starting address plus mid-point
	PUSH	EDX				;array size minus mid-point
	CALL	mergeSort

	;set endpoints of left and right array for comparisons
	ADD		EBX, [EBP+4]
	ADD		EDX, ECX
	MOV		EAX, [EBP+4]
	
_ExchangeLoop:
	;EBX is end point of left array, Iterate EAX index
	;EDX is end point of right array, Iterate ECX index
	;Check if end of either array is reached, if so exhanging complete
	CMP		EBX, EAX
	JE		_Fin
	CMP		EDX, ECX
	JE		_Fin

	;Check left element value against right element value at current index
	MOVZX	EDI, BYTE PTR [EAX]			;EDI is left value
	MOVZX	ESI, BYTE PTR [ECX]			;ESI is right value
	CMP		EDI, ESI
	JBE		_noexchange

	;There is a change needed, use callExchanges subprocedure with left array index, and right array index
	PUSH	EAX
	PUSH	ECX
	CALL	exchangeElements
	ADD		EBX, 1
	ADD		EAX, 1
	ADD		ECX, 1

	JMP		_nextloop

_noexchange:
	ADD		EAX, 1							;increment left array

_nextloop:
	JMP		_ExchangeLoop

_Fin:
	;Restore registers and base pointer
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8	
mergeSort		ENDP


;------------------------------------------------------
;name: exchangeElements
;
;MergeSort procedure uses exchangeElements as its suprocedure to swap elements when the number on the left is greater 
;	than the number on the left.  ExchangeElements then moves the element in the right index to the left index, and shifts
;	all the items in between over one to the right.
;
;Preconditions:	1) Addresses provided are part of an Array	
;
;Postconditions: Modifies all the elements in some array between left index address and right index address, such that value of right index is at the left 
;	index, and all other numbers shift over by 1
;
;Receives:		1) left index address to be merged
;				2) right index address to be merged
;
;Returns:		1) Modifies all the elements from the left index and right index, such that value of right index is at the left index, and shifts values in 
;					between by 1
;------------------------------------------------------

exchangeElements	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		EBP, ESP
	ADD		EBP, 32				;moves base pointer to first parameter

	;Calculate number of shifts and store in loop counter
	;[ebp+4] is address of left, [ebp] is address of right 
	MOV		ECX, [EBP]
	SUB		ECX, [EBP+4]

	;Start EBX as index, and save initial right value for end
	MOV		EBX, [EBP]				;address of right most index, to be iterated
	MOV		EAX, 0
	MOV		AL, [EBX]				;value of right most index, saved for end of loop
	MOV		EDX, 0
_exchangeLoop:
	MOV		EDI, EBX
	SUB		EDI, 1
	MOV		DL, [EDI]
	MOV		[EBX], DL

	;Shift right index
	SUB		EBX, 1
	LOOP	_exchangeLoop

	;move right most element saved in AL into left array index 
	MOV		EDX, [EBP+4]
	MOV		[EDX], AL

	;Restore registers and base pointer
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8	
exchangeElements	ENDP

;------------------------------------------------------
;name: displayMedian
;
;Displays a text input message and then determines the median of a list an array and its size.
;
;Preconditions:		1) Some array is a BYTE array
;
;Postconditions:	None, all registers restored
;
;Receives:		1) starting address of string 
;				2) starting address of sorted array, 
;				3) Array size constant value -- postive value
;
;Returns:		None, median value is not stored, just displayed
;------------------------------------------------------

displayMedian	PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	MOV		EBP, ESP
	ADD		EBP, 24				;moves base pointer to first parameter

	;Display median intro statement
	MOV		EDX, [EBP+8]
	CALL	WriteString

	;Divide arraysize by 2, to find mid point of array
	MOV		EAX, [EBP]
	MOV		EBX, 2
	MOV		EDX, 0
	CDQ
	DIV		EBX

	;Determine if caluclating median for even or odd number
	CMP		EDX,0
	JZ		_EvenMedian

	;Odd median, and grab array value at this index
	MOV		EDX, [EBP+4]
	ADD		EDX, EAX
	MOV		EAX, 0
	MOV		AL, [EDX]
	
	JMP		_Fin

	;Even median, need to sum middle numbers and round up
_EvenMedian:
	MOV		EDX, [EBP+4]
	ADD		EDX, EAX
	MOV		EAX, 0
	MOV		ECX, 0
	MOV		AL, [EDX]
	SUB		EDX, 1
	MOV		CL, [EDX]
	ADD		AL, CL
	MOV		EBX, 2
	MOV		EDX, 0
	CDQ
	DIV		EBX
	;Check if remainder if there is a remainder of 1, if so add 1
	CMP		EDX, 1
	JNE		_FIN
	ADD		EAX, 1

_Fin:
	CALL	WriteDec
	CALL	CRLF
	CALL	CRLF

	;Restore registers and base pointer
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		12	
displayMedian	ENDP

;------------------------------------------------------
;name: countList
;
;Determines the number of occurences of each number and puts into an array the length of the range
;
;Preconditions:		1) Counting array must be empty, and have elements of size BYTE
;					2) SomeArray must have elements of size BYTE
;					3) Empty count array length variable is type DWORD
;
;Postconditions: None, all registers restored
;
;Receives:			1) starting address of start of an Array, each element of size BYTE  
;					2) constant value of size of array from 1)
;					3) an empty array, each element of size BYTE with length of at least range between Hi and Lo
;					4) constant value of Lo
;					5) constant value of Hi
;					6) empty count array length variable, DWORD
;
;Returns:			1) countarray is filled with values
;					2) updates value of length of countarray
;------------------------------------------------------

countList		PROC
	;Store changed registers and base pointer
	PUSH	EBP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
	MOV		EBP, ESP
	ADD		EBP, 32				;moves base pointer to first parameter

	MOV		ECX, [EBP+12]		;Counter of array size
	MOV		EDX, 0
	MOV		DL, [EBP+4]			;Set current value to LO value
	MOV		EDI, [EBP+16]		;Current index of someArray
	MOV		EAX, [EBP+8]		;Current index of countArray

	;Iterate through each number in someArray
_countLoop:
	
	;Check if current number in some array counts number in countArray
_MatchLoop:
	CMP		DL, BYTE PTR [EDI]
	JE		_matchAdd
	; No match, increment countarray
	INC		EAX
	ADD		DL, 1
	JMP		_MatchLoop

	;There is a match, increment countArray
_MatchAdd:
	INC		BYTE PTR [EAX]
	
_Fin:
	ADD		EDI, 1
	LOOP	_countLoop

	;calculate countSize to provide as input when displaying list
	MOV		EAX, [EBP]
	MOV		EBX, [EBP+4]
	SUB		EAX, EBX
	ADD		EAX, 1
	MOV		EBX, [EBP+20]
	MOV		[EBX], EAX

	;Restore registers and base pointer
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		24	
countList		ENDP

;------------------------------------------------------
;name: Farwell
;
;Farewell bids adieu to the user with a goodbye message
;
;Preconditions:		None, no register requirements
;
;Postconditions:	None, all registers restored
;
;Receives:			1) Starting address of goodbye string, BYTE size
;
;Returns:			None
;------------------------------------------------------

farewell		PROC
	;Send to Exit program with goodbye message
	PUSH	EDX
	PUSH	EBP
	MOV		EBP, ESP
	ADD		EBP, 12

	MOV		EDX, [EBP]
	CALL	WriteString
	CALL	crLF

	POP		EBP
	POP		EDX
	RET		4
farewell		ENDP

END	main
