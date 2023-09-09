TITLE Program Template     (template.asm)

; Author: Russell Feathers
; Last Modified: 01/12/21
; OSU email address: featheru@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 0            Due Date: 1/24/21
; Description: Program takes in three user inputs, where A > B > C and displays the possible sums and differences 

INCLUDE Irvine32.inc

.data

;Start and end of program introductions and exit
prog_name		BYTE	"              Project 1 - The Basics      by Russell Feathers", 0
start			BYTE	"Enter 3 numbers A > B > C, and I'll show you the sums and differences.", 0
prompt_1		BYTE	"First number: ", 0
prompt_2		BYTE	"Second number: ", 0
prompt_3		BYTE	"Third number: ", 0
goodbye			BYTE	"Thanks for using Elementary Arithmetic! Goodbye!", 0

;Store user input values
number_1		DWORD	?
number_2		DWORD	?
number_3		DWORD	?

;Text reporting of summations and subtractions in memory
word_sum		BYTE	" + ",0
word_sub		BYTE	" - ",0
word_equal		BYTE	" = ",0

;Store summations and subtractions in memory
sum_1_2			DWORD	?
sub_1_2			DWORD	?
sum_1_3			DWORD	?
sub_1_3			DWORD	?
sum_2_3			DWORD	?
sub_2_3			DWORD	?
sum_1_2_3		DWORD	?

.code
main PROC

;Program intro string statements to screen
	MOV		EDX, OFFSET prog_name
	CALL	WriteString
	CALL	crLF

	MOV		EDX, OFFSET start
	CALL	WriteString
	CALL	crLF
	CALL	crLF

; Get three user integers inputs and store them in memory
	MOV		EDX, OFFSET prompt_1
	CALL	WriteString
	CALL	ReadInt
	MOV		number_1, EAX

	MOV		EDX, OFFSET prompt_2
	CALL	WriteString
	CALL	ReadInt
	MOV		number_2, EAX

	MOV		EDX, OFFSET prompt_3
	CALL	WriteString
	CALL	ReadInt
	MOV		number_3, EAX


;Perform summation of numbers 1 and 2 and store value in memory
	CALL	CrLF
	MOV		EAX, number_1
	ADD		EAX, number_2
	MOV		sum_1_2, EAX

;Display of sum of numbers 1 and 2
	MOV		EAX, number_1
	CALL	WriteDec
	MOV		EDX, OFFSET word_sum
	CALL	WriteString
	MOV		EAX, number_2
	CALL	WriteDec
	MOV		EDX, OFFSET word_equal
	CALL	WriteString
	MOV		EAX,sum_1_2
	CALL	WriteDec
	CALL	crLF

;Perform subtraction of numbers 1 and 2 and store value in memory
	MOV		EAX, number_1
	SUB		EAX, number_2
	MOV		sub_1_2, EAX

;Display of subtraction of numbers 1 and 2
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


;Perform summation on numbers 1 and 3 and store value in memory
	MOV		EAX, number_1
	ADD		EAX, number_3
	MOV		sum_1_3, EAX

;Display summation of numbers 1 and 3
MOV EAX, number_1
CALL WriteDec
MOV EDX, OFFSET word_sum
CALL WriteString
MOV EAX, number_3
CALL WriteDec
MOV EDX, OFFSET word_equal
CALL WriteString
MOV EAX, sum_1_3
CALL WriteDec
CALL crLF

;Perform subtraction on numbers 1 and 3 and store value in memory
MOV EAX, number_1
SUB EAX, number_3
MOV sub_1_3, EAX

;Display subtraction of numbers 1 and 3
MOV EAX, number_1
CALL WriteDec
MOV EDX, OFFSET word_sub
CALL WriteString
MOV EAX, number_3
CALL WriteDec
MOV EDX, OFFSET word_equal
CALL WriteString
MOV EAX, sub_1_3
CALL WriteDec
CALL crLF


;Perform summation on numbers 2 and 3 and store value in memory
MOV EAX, number_2
ADD EAX, number_3
MOV sum_2_3, EAX

;Display summation of numbers 2 and 3
MOV EAX, number_2
CALL WriteDec
MOV EDX, OFFSET word_sum
CALL WriteString
MOV EAX, number_3
CALL WriteDec
MOV EDX, OFFSET word_equal
CALL WriteString
MOV EAX, sum_2_3
CALL WriteDec
CALL crLF

;Perform subtraction on numbers 2 and 3 and store value in memory
MOV EAX, number_2
SUB EAX, number_3
MOV sub_2_3, EAX

;Display subtraction of numbers 2 and 3
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


;Perform summation on numbers 1, 2 and 3 and store value in memory
MOV EAX, number_2
ADD EAX, number_3
ADD EAX, number_1
MOV sum_1_2_3, EAX

;Display summation of numbers 1, 2, and 3
MOV EAX, number_1
CALL WriteDec
MOV EDX, OFFSET word_sum
CALL WriteString
MOV EAX, number_2
CALL WriteDec
MOV EDX, OFFSET word_sum
CALL WriteString
MOV EAX, number_3
CALL WriteDec
MOV EDX, OFFSET word_equal
CALL WriteString
MOV EAX, sum_1_2_3
CALL WriteDec
CALL crLF

;Exit Statement to screen
CALL crLF
MOV	EDX, OFFSET goodbye
CALL WriteString
CALL crLF


; Exit the program

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
