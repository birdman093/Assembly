TITLE Project 3 Data Validation, Looping and Constants     (Proj3_featheru.asm)

; Author: Russell Feathers
; Last Modified: 02/07/21
; OSU email address: featheru@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 3            Due Date: 02/07/21
; Description: Program prompts user to enter numbers that are within the range of [-200, -100] and [-50, -1].  
;	Program notifies the user of invalid negative numbers, and stops asking for numbers when a positive 
;	number is entered. After the user has finished entering numbers a rounded average of the valid numbers is
;	is calculated and then a count of valid numbers, the sum, the maximum, minimum, and average to nearest integer
;	are displayed. Extra Credit 1 and 2 are also included in this program.  Extra credit 1 counts the line of input
;	for the user, and extra credit 2 displays the decimal point number without using the FPU.

INCLUDE Irvine32.inc

; Constants to control the two ranges of values
UPPER_2 = -200
LOWER_2 = -100
UPPER_1 = -50
LOWER_1 = -1

EVEN_CHECK = 2

.data

	;Program introductions, program exits, prompts, and error messages
	prog_name		BYTE	"Welcome to the Integer Accumulator by Russell Feathers", 13,10,0
	EC_q1			BYTE	"**EC1: Number lines during user input. line numbering incremented only for valid number entries.",13,10,0
	EC_q2			BYTE	"**EC2: Display average as decimal point number to nearest .01 without using FPU",13,10,0
	greet_q			BYTE	"What is your name?  ", 0
	hello			BYTE	"Hello there, ",0
	start			BYTE	"Please enter numbers in [-200, -100] or [-50, -1].", 13,10,0
	start_2			BYTE	"Enter a non-negative number when you are finished to see results.", 13,10,0
	enter_num		BYTE	". Enter: ", 0
	invalid_mess	BYTE	"Number Invalid!",13,10,0
	input_error		BYTE	"ERROR: No numbers entered", 13,10,0

	;Display messages as part of summary, extra credit 2, and goodbyes 
	summary_num_1	BYTE	"You entered ", 0
	summary_num_2	BYTE	" valid numbers.", 13,10,0
	summary_max		BYTE	"The maximum valid number is ", 0
	summary_min		BYTE	"The minimum valid number is ", 0
	summary_sum		BYTE	"The sum of your valid numbers is ", 0
	summary_round	BYTE	"The rounded average is ", 0
	summary_rnd_ec2	BYTE	"The EC2 rounded two decimal point average is ", 0
	radix_point		BYTE	".",0
	radix_point_0	BYTE	".00",0
	goodbye			BYTE	"We have to stop meeting like this. Farewell, ", 0

	;User input values of name and numbers
	name_input		BYTE	30 DUP(?)
	curr_num		SDWORD	?

	;Calculated values including sum, min, max, quotients, remainders
	input_counter	SDWORD	0
	num_sum			SDWORD	0
	num_min			SDWORD	?
	num_max			SDWORD	?
	num_rem			SDWORD	?
	num_quot		SDWORD	?
	num_quot_rnd	SDWORD	?
	num_quot_ec2	SDWORD	?
	num_rem_ec2		SDWORD	?
	ec2_dec			SDWORD	?
	
.code
main PROC

;------------------------------------------------------
;Introduction:  Provides introduction to the game, then ask user for name, greets the user using their name, and provides input 
;	instructions for the game
;------------------------------------------------------

	;Introduction: Display Program Intro statements
	MOV		EDX, OFFSET prog_name
	CALL	WriteString

	;Introduction: Ask user for name and greet user using that name
	MOV		EDX, OFFSET greet_q
	CALL	WriteString
	MOV		EDX, OFFSET name_input
	MOV		ECX, SIZEOF name_input
	CALL	Readstring
	MOV		EDX, OFFSET hello
	CALL	WriteString
	MOV		EDX, OFFSET name_input
	CALL	WriteString
	CALL	crLF
	CALL	crLF

	;Introduction: Display Extra Credit Intro statements
	MOV		EDX, OFFSET EC_q1
	CALL	WriteString
	MOV		EDX, OFFSET EC_q2
	CALL	WriteString
	CALL	crLF

	;Introduction: Display game requirement intro statements
	MOV		EDX, OFFSET start
	CALL	WriteString
	MOV		EDX, OFFSET start_2
	CALL	WriteString

;--------------------------------------------------------------
;Data Collection and Calculation:  Collect numbers from user and check whether the values are within the 
;	specified constant bounds of the program.  If the number is 0 or greater then stop data entry, and begin
;	the display portion.  Data entry also determines if a number is the max or min through comparisons as the
;	the numbers are input and calculates the sum of the entries, as well as calculating the number of entries. 
;	Contains EC #1, where lines of input by user are numbered
;---------------------------------------------------------------

	;Data Collection: Determenies if the user entry is valid and within specified bounds, and whether
	;the user has selected 0 or greater to cancel out
_NumberEntry:

	;Data Collection EC #1: lines numbered by adding 1 to input counter, so that line numbering starts at 1, and does not increment invalid entries
	MOV		EAX, input_counter
	ADD		EAX, 1
	CALL	WriteDec

	;Data Collection: Collect user input, and check whether user has opted to stop by selecting a non-negative number
	MOV		EDX, OFFSET enter_num
	CALL	WriteString
	CALL	ReadInt
	MOV		curr_num, EAX
	CMP		EAX, 0
	JNS		_Display			; compare using SF flag, i.e. check if value is non-negative to quit
	
	;Data Collection: User has not opted to stop; Compare upper and lower bounds to determine valid or invalid entry within range; EAX is current value
	CMP		EAX, UPPER_2
	JL		_InvalidEntry
	CMP		EAX, LOWER_2
	JLE		_ValidEntry
	CMP		EAX, UPPER_1
	JL		_InvalidEntry
	CMP		EAX, LOWER_1
	JLE		_ValidEntry

	;Data Collection: Print message for data entry out of range and return to data entry
_InvalidEntry:
	MOV		EDX, OFFSET invalid_mess
	CALL	Writestring
	JMP		_NumberEntry

	;Data Collection: Entry is within range, determine if new number supercedes the current maximum or minimum value, update counter, and return to data entry
	;If the number is a first entry then update min and max to be the first entry
_ValidEntry:
	INC		input_counter
	MOV		EAX, curr_num
	ADD		num_sum, EAX
	; Determine if this is max or min number
	CMP		input_counter, 1
	JE		_ValidEntry_First
	CMP		EAX, num_min
	JL		_ValidEntry_Min
	CMP		EAX, num_max
	JG		_ValidEntry_Max
	JMP		_NumberEntry

	;Data Collection: first number entry so update min and max to be equal to entry, and return to data entry
_ValidEntry_First:
	MOV		num_min, EAX
	MOV		num_max, EAX
	JMP		_NumberEntry

	;Data Collection: number is minimum, update minimum number in memory and return to data entry
_ValidEntry_Min:
	MOV		num_min, EAX
	JMP		_NumberEntry

	;Data Collection: number is maximum, update maximum number in memory and return to data entry
_ValidEntry_Max:
	MOV		num_max, EAX
	JMP		_NumberEntry
	
;------------------------------------
;Display Results:  Displays results with number of valid numbers entered, max number, min number, sum of numbers.
;------------------------------------

_Display:
	;checks more than one number input has been provided, if not exit to error
	MOV		EAX, input_counter
	CMP		EAX, 0
	JZ		_Error_Exit

	;display number of valid numbers entered (valid numbers is a positive value)
	MOV		EDX, OFFSET summary_num_1
	CALL	WriteString
	MOV		EAX, input_counter
	CALL	WriteDec
	MOV		EDX, OFFSET summary_num_2
	CALL	WriteString

	; Display: maximum number (negative value, so WriteInt used)
	MOV		EDX, OFFSET summary_max
	CALL	WriteString
	MOV		EAX, num_max
	CALL	WriteInt
	CALL	CRLF

	; Display: minimum number (negative value, so WriteInt used)
	MOV		EDX, OFFSET summary_min
	CALL	WriteString
	MOV		EAX, num_min
	CALL	WriteInt
	CALL	CRLF

	; Display: sum of numbers using WriteInt  (negative value, so WriteInt used)
	MOV		EDX, OFFSET summary_sum
	CALL	WriteString
	MOV		EAX, num_sum
	CALL	WriteInt
	CALL	CRLF

;----------------------------------------------------------
;Display and Calculate Rounded Average Results: Returns the rounded average of the numbers.  
;	Rounded average of numbers is calculated by determining whether
;	the absolute value of the remainder is greater than 1/2 and if so then the numbers are "rounded up" 
;	or in the case of negative numbers, becomes smaller.  
;----------------------------------------------------------

	;Calculate: Divide sum by counter to calculate unrounded result of quotient and remainder 
	MOV		EAX, num_sum
	MOV		EDX, 0
	CDQ
	IDIV	input_counter
	MOV		num_quot, EAX
	MOV		num_quot_rnd, EAX
	MOV		num_rem, EDX

	;Calculate: Divide counter by -2, to convert to negative value to determine middle point for rounding down, EAX contains middle point
	MOV		EAX, input_counter
	MOV		EBX, -2
	MOV		EDX, 0
	CDQ
	IDIV	EBX

	;Calculate: Compares remainder against middle point(EAX), if absolute of remainder is greater than 1/2, then quotient is rounded down,
	;and stored in num_quot_rnd
	CMP		num_rem, EAX
	JGE		_display_round
	MOV		EAX, num_quot
	SUB		EAX, 1
	MOV		num_quot_rnd, EAX

	;Display:  Display the results of the rounded number.
_display_round:
	MOV		EDX, OFFSET summary_round
	CALL	WriteString
	MOV		EAX, num_quot_rnd
	CALL	WriteInt
	CALL	crLF

;---------------------------------------------------------
;EC #2 Display and Calculate Rounded Average Results: Returns the rounded average of the numbers to the nearest .01  
;	without using the FPU. The decimal component is calculated by multiplying the remainder:
;	by 1000 if remainder is 0, 
;	by 100 if remainder is between 1 and 99 
;	by 10 if the remainder is between 100 and 200.  
;	This modified remainder is divided by the number of user inputs to get the "decimal" value.  
;	Result is then displayed by taking the quotient, displaying a radix point, and then printing the modified decimal value.
;--------------------------------------------------------

	;Check whether remainder is 0
	CMP		num_rem, 0
	JZ		_Display_e2_0
	
	;Check whether remainder is between 0 and -99, or if remainder is less than -100
	CMP		num_rem, -100
	JLE		_rem_over_100

	;remainder is between 0 and -99, multiply remainder (sign is negative) by -100 to make value positive
	MOV		EAX, num_rem
	MOV		EBX, -100
	IMUL	EBX	

	;divide remainder mutlipled by -100 by the counter to get the "decimal" value to 2 places
	;note result of multiply is in EDX:EAX;  no need to check Eflags for carry or overflow for set of values used in program
	MOV		EDX, 0
	CDQ
	DIV		input_counter
	MOV		ec2_dec, EAX
	JMP		_Display_e2

_rem_over_100:
	;remainder is between 100 and 200, multiply remainder (sign is negative) by -100 to make value positive
	MOV		EAX, num_rem
	MOV		EBX, -10
	IMUL	EBX	

	;divide remainder mutlipled by 100 by the counter to get the "decimal" value to 2 places
	;note result of multiply is in EDX:EAX;  no need to check Eflags for carry or overflow for set of values used in program
	MOV		EDX, 0
	CDQ
	DIV		input_counter
	MOV		ec2_dec, EAX
	
	;Display results
_Display_e2:
	MOV		EDX, OFFSET summary_rnd_ec2
	CALL	WriteString
	MOV		EAX, num_quot
	CALL	WriteInt
	MOV		EDX, OFFSET radix_point
	CALL	WriteString
	MOV		EAX, ec2_dec
	CALL	WriteDec
	CALL	crLF
	JMP		_Finished

_Display_e2_0:
	MOV		EDX, OFFSET summary_rnd_ec2
	CALL	WriteString
	MOV		EAX, num_quot
	CALL	WriteInt
	MOV		EDX, OFFSET radix_point_0
	CALL	WriteString
	CALL	crLF
	JMP		_Finished

;------------------------------------
;Say Goodbye:  Program exits with a goodbye statement addressing the user inputed name from the
;	top of the program
;------------------------------------

_Error_Exit:
	CALL crLF
	MOV	EDX, OFFSET input_error
	CALL WriteString
	
_Finished:
	;Send to Exit program with goodbye message

	CALL	crLF
	MOV		EDX, OFFSET goodbye
	CALL	WriteString
	MOV		EDX, OFFSET name_input
	CALL	WriteString
	CALL	crLF

	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
