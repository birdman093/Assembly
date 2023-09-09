TITLE Project 1 Arithmetic Calculator     (Proj1_featheru.asm)

; Author: Russell Feathers
; Last Modified: 01/22/21
; OSU email address: featheru@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 1            Due Date: 1/24/21
; Description: Program takes in three user inputs, where A > B > C and displays the possible sums and differences.  
;	There are extra credit add ons such as allowing the user to play until they decide to quit
;	Checking that numbers are in descending order, and returning an error if they are not
;	Computing some additional subtractions and computing some division as well

INCLUDE Irvine32.inc

.data

	;Program introductions, program exits, prompts, and error messages
	prog_name		BYTE	"              Project 1 - The Basics      by Russell Feathers", 13,10,0
	EC_q1			BYTE	"**EC1: Repeat until the user chooses to quit",13,10,0
	EC_q2			BYTE	"**EC2: Check if numbers are in non-descending order",13,10,0
	EC_q3			BYTE	"**EC3: Handle Negative results and compute B-A, C-A, C-B, C-B-A",13,10,0
	EC_q4			BYTE	"**EC4: Calculate and display quotients A/B, A/C, B/C printing quotient and remainder",13,10,0
	start			BYTE	"Enter 3 numbers A > B > C, and I'll show you the sums and differences.", 13,10,0
	prompt_1		BYTE	"First number: ", 0
	prompt_2		BYTE	"Second number: ", 0
	prompt_3		BYTE	"Third number: ", 0
	goodbye			BYTE	"Thanks for using Elementary Arithmetic! Goodbye!", 0
	user_play		BYTE	"Does the user want to play again? Write 1 and press enter to Stop",0
	error_descend	BYTE	"ERROR: The numbers are not in desceding order!", 0
	error_descend_2 BYTE	"Impressed? Bye!",0

	;Store user input values
	play_input		QWORD	?
	input_counter	DWORD	?
	number_1		SDWORD	?
	number_2		SDWORD	?
	number_3		SDWORD	?

	;Text reporting of summations, subtractions, and division in memory
	word_sum		BYTE	" + ",0
	word_sub		BYTE	" - ",0
	word_equal		BYTE	" = ",0
	word_stop		BYTE	"NO",0
	word_div		BYTE	" / ",0
	word_rem		BYTE	" r: ",0

	;Store summations and subtractions in memory
	sum_1_2			SDWORD	?
	sub_1_2			SDWORD	?
	sum_1_3			SDWORD	?
	sub_1_3			SDWORD	?
	sum_2_3			SDWORD	?
	sub_2_3			SDWORD	?
	sum_1_2_3		SDWORD	?

	;Store EC3 subtractions in memory as signed integers
	sub_2_1			SDWORD	?
	sub_3_1			SDWORD	?
	sub_3_2			SDWORD	?
	sub_3_2_1		SDWORD	?

	;Store EC4 divisions in memory
	quot_1_2		SDWORD	?
	rem_1_2			SDWORD	?
	quot_1_3		SDWORD	?
	rem_1_3			SDWORD	?
	quot_2_3		SDWORD	?
	rem_2_3			SDWORD	?

.code
main PROC


_StartUserLoop:
	;EC1: Create a while loop where user has option to quit after loop has run once

;------------------------------------
;Introduction:  Program starts on excecution and displays the program name, the program author, the extra
;	credit solutions being used, and informs the user of what to input, and what the output will be
;------------------------------------

	;Introduction: Display Program Intro statements
	MOV		EDX, OFFSET prog_name
	CALL	WriteString

	;Introduction: Display Extra Credit Intro statements
	CALL	crLF
	MOV		EDX, OFFSET EC_q1
	CALL	WriteString
	MOV		EDX, OFFSET EC_q2
	CALL	WriteString
	MOV		EDX, OFFSET EC_q3
	CALL	WriteString
	MOV		EDX, OFFSET EC_q4
	CALL	WriteString
	CALL	crLF

	;Introduction: Display Start requirements intro statements
	MOV		EDX, OFFSET start
	CALL	WriteString
	CALL	crLF

;------------------------------------
;User Data Collection:  Program gets three input values from the user.  As part of Extra Credit 2, those
;	numbers are checked to verify that they are in descending order.  If they are not in descending order
;	then the program is halted, and error message is given to the user
;------------------------------------

	;User Data Collection: Get three user integers inputs and store them in memory, starting with number 1
	MOV		EDX, OFFSET prompt_1
	CALL	WriteString
	CALL	ReadInt
	MOV		number_1, EAX

	;User Data Collection: Get number 2 from user
	MOV		EDX, OFFSET prompt_2
	CALL	WriteString
	CALL	ReadInt
	MOV		number_2, EAX

	;User Data Collection/ EC2: Check that numbers 1 and 2 are in descending order, if not send to end
	CMP		number_1, EAX
	JLE		_NonDescending
	
	;User Data Collection: Get number 3 from user
	MOV		EDX, OFFSET prompt_3
	CALL	WriteString
	CALL	ReadInt
	MOV		number_3, EAX

	;User Data Collection/ EC2: Check that numbers 2 and 3 are in descending order, if not send to end
	CMP		number_2, EAX
	JLE		_NonDescending

;------------------------------------
;Calculate Results:  Program performs the addition and subtraction of each of the three input values
;	including:  num 1 + num2, num1 - num2, num1 + num3, num1 - num3, num2 + num 3, num2 - num3, 
;	num1 + num2 + num3.  The results of each calculation is stored in the memory.
;------------------------------------

	;Calculate Results: Addition of numbers 1 and 2 and store value in memory
	CALL	CrLF
	MOV		EAX, number_1
	ADD		EAX, number_2
	MOV		sum_1_2, EAX

	;Calculate Results: Subtraction of numbers 1 and 2 and store value in memory
	MOV		EAX, number_1
	SUB		EAX, number_2
	MOV		sub_1_2, EAX

	;Calculate Results: Addition of numbers 1 and 3 and store value in memory
	MOV		EAX, number_1
	ADD		EAX, number_3
	MOV		sum_1_3, EAX

	;Calculate Results: Subtraction of numbers 1 and 3 and store value in memory
	MOV		EAX, number_1
	SUB		EAX, number_3
	MOV		sub_1_3, EAX

	;Calculate Results: Addition of numbers 2 and 3 and store value in memory
	MOV		EAX, number_2
	ADD		EAX, number_3
	MOV		sum_2_3, EAX

	;Calculate Results: Subtraction on numbers 2 and 3 and store value in memory
	MOV		EAX, number_2
	SUB		EAX, number_3
	MOV		sub_2_3, EAX

	;Calculate Results: Addition of numbers 1, 2 and 3 and store value in memory
	MOV		EAX, number_2
	ADD		EAX, number_3
	ADD		EAX, number_1
	MOV		sum_1_2_3, EAX

;------------------------------------
;Display Results:  Program displays the results of the arithmetic calculated above.
;	To display the results the number is printed, followed by a string of the type 
;	of arithmetic, followed by the next number, followed by the equal string 
;	and finally the result is displayed.
;------------------------------------

	;Display Results: Addition of numbers 1 and 2 

	MOV		EAX, number_1			
	CALL	WriteDec
	MOV		EDX, OFFSET word_sum
	CALL	WriteString
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX,sum_1_2
	CALL	WriteDec				;Write decimal is used as the input is only positive
	CALL	crLF

	;Display Results: Subtraction of numbers 1 and 2
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, sub_1_2
	CALL	WriteDec
	CALL	crLF

	;Display Results: Addition of numbers 1 and 3
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_sum
	CALL	WriteString
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, sum_1_3
	CALL	WriteDec
	CALL	crLF

	;Display Results: Subtraction of numbers 1 and 3
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, sub_1_3
	CALL	WriteDec
	CALL	crLF

	;Display Results: Addition of numbers 2 and 3
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_sum
	CALL	WriteString
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, sum_2_3
	CALL	WriteDec
	CALL	crLF

	;Display Results: Subtraction of numbers 2 and 3
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, sub_2_3
	CALL	WriteDec
	CALL	crLF

	;Display Results: Addition of numbers 1, 2, and 3
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_sum
	CALL	WriteString
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_sum
	CALL	WriteString
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, sum_1_2_3
	CALL	WriteDec
	CALL	crLF

;------------------------------------
;Extra Credit No. 3 Calculation & Results:  Program calculates and displays the results 
;	of the ;	subtraction of the larger numbers from the smaller numbers:  num2 - num1,
;	num3 - num1, num3 - num2, num3 - num2 - num1.  The first part of the displaying of 
;	of arithmetic is done the same, but the display of the result must be done as an integer
;	since the result is negative in each of these cases
;------------------------------------

	;Extra Credit No. 3 Calculation: Subtraction of number 2 minus number 1
	MOV		EAX, number_2
	SUB		EAX, number_1
	MOV		sub_2_1, EAX

	;Extra Credit No. 3 Calculation: Subtraction on number 3 minus number 1
	MOV		EAX, number_3
	SUB		EAX, number_1
	MOV		sub_3_1, EAX

	;Extra Credit No. 3 Calculation: Subtraction on number 3 minus number 2
	MOV		EAX, number_3
	SUB		EAX, number_2
	MOV		sub_3_2, EAX

	;Extra Credit No. 3 Calculation: Subtraction on number 3 minus number 2 minus number 1
	MOV		EAX, number_3
	SUB		EAX, number_2
	SUB		EAX, number_1
	MOV		sub_3_2_1, EAX

	;Extra Credit No. 3 Display: Subtraction of number 2 minus number 1
	Call	CrLF
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX,sub_2_1
	CALL	WriteInt
	Call	CrLF

	;Extra Credit No. 3 Display: Subtraction on number 3 minus number 1
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX,sub_3_1
	CALL	WriteInt
	Call	CrLF

	;Extra Credit No. 3 Display: Subtraction on number 3 minus number 2
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX,sub_3_2
	CALL	WriteInt
	Call	CrLF

	;Extra Credit No. 3 Display: Subtraction on number 3 minus number 2 minus number 1
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_sub
	CALL	WriteString
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX,sub_3_2_1
	CALL	WriteInt
	CALL	crLF

;------------------------------------
;Extra Credit No. 4 Calculation & Results:  Program calculates and displays the results 
;	of the division of: num1/ num2, num1/ num3, num2/ num3. The results are calculated
;	using signed division (IDIV), and displayed in a similar manner as described previously
;------------------------------------

	;Extra Credit No. 4 Calculation: Division of number 1 divided by number 2
	MOV		EAX, number_1
	CDQ								;Sign extend EAX to EDX for division 
	IDIV	number_2
	MOV		quot_1_2, EAX
	MOV		rem_1_2, EDX

	;Extra Credit No. 4 Calculation: Division of number 1 divided by number 3
	MOV		EAX, number_1
	CDQ								;Sign extend EAX to EDX for division
	IDIV	number_3
	MOV		quot_1_3, EAX
	MOV		rem_1_3, EDX

	;Extra Credit No. 4 Calculation: Division of number 2 divided by number 3
	MOV		EAX, number_2
	CDQ								;Sign extend EAX to EDX for division
	IDIV	number_3
	MOV		quot_2_3, EAX
	MOV		rem_2_3, EDX

	;Extra Credit No. 4 Display: Division of number 1 divided by number 2
	Call	CrLF
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_div
	CALL	WriteString
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, quot_1_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_rem
	CALL	WriteString
	MOV		EAX, rem_1_2
	Call	WriteDec
	Call	CrLF

	;Extra Credit No. 4 Display: Division of number 1 divided by number 3
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_div
	CALL	WriteString
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, quot_1_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_rem
	CALL	WriteString
	MOV		EAX, rem_1_3
	Call	WriteDec
	Call	CrLF

	;Extra Credit No. 4 Display: Division of number 2 divided by number 3
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_div
	CALL	WriteString
	MOV		EAX, number_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX, quot_2_3
	CALL	WriteDec
	MOV		EDX, OFFSET word_rem
	CALL	WriteString
	MOV		EAX, rem_2_3
	Call	WriteDec
	CALL	CrLF

;------------------------------------
;Extra Credit No. 1 Calculation & Results:  Ask user if they want to play again, if so restart game, 
;	if the user types 1 game is sent to finish statements
;------------------------------------

	;Extra Credit No. 1: 
	CALL	crLF
	MOV		EDX, OFFSET user_play
	CALL	WriteString
	CALL	crLF
	CALL	ReadDec
	CMP		EAX, 1
	JNE		_StartUserLoop
	JMP		_Finished

;------------------------------------
;Extra Credit No. 2 Calculation & Results:  If user determined to have input non-desceding values, an error is given
;	and sends user to exit
;------------------------------------
	
_NonDescending:

	CALL	crLF
	MOV		EDX, OFFSET error_descend
	CALL	WriteString
	MOV		EDX, OFFSET error_descend_2
	CALL	crLF
	CALL	crLF
	CALL	WriteString
	CALL	crLF
	JMP		_EarlyExit

;------------------------------------
;Say Goodbye:  Exit Statements to screen when completed and exit program
;------------------------------------

_Finished:
	;Send to Exit program with goodbye message

	CALL	crLF
	MOV		EDX, OFFSET goodbye
	CALL	WriteString
	CALL	crLF


_EarlyExit:
	;Extra Credit No. 2: End of program destination for NonDescending numbers, exit program


	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
