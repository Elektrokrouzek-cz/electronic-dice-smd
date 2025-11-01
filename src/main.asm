// Dice code
//
start:
	ldi r16,low(RAMEND)		// Init stack pointer
	out SPL,r16
	sbis PINB, 1			// Check whether button is pressed - do not power on if not
	rjmp start
	ldi r16, 0x01			// Power on (turn on transistor)
	out DDRB, r16
	out PORTB, r16
	ldi r16, 0x0f			// Init PORTA (outputs)
	out DDRA, r16
	out PORTA, r16

	ldi r17, 1				// Number to show (1 to 6)
	ldi r18, 1				// Delay to wait
loop:
	mov r16, r17			// Show number
	rcall show
	sbic PINB, 1			// Check if button is pressed
	ldi r18, 1				// Reset wait period if button is pressed
	mov r16, r18
	mov r19, r18			// Copy delay to r19
	cpi r16, 20				// Slowly increment delay if lower than 20
	brge shift
	ldi r19, 1				// Increment by 10ms
	rjmp skip
shift:
	lsr r19					// Divide delay by 2
	brne skip				// Check if zero - cannot add zero to delay
	inc r19					// Increase at least by 1
skip:
	add r18, r19			// Increase delay by r19
	cpi r18, 100			// Check for finish (1s delay)
	brsh end
	rcall sleep_10ms		// Delay
	inc r17					// Increase number to sho
	cpi r17, 7				// Back to 1?
	brne loop				
	ldi r17, 1				// Set 1 again
    rjmp loop

end:
	ldi r19, 10				// Blink 10 times
end_loop:
	mov r18, r17			// Save number to show to r18
	ldi r16, 0				// Show nothing
	rcall show
	ldi r16, 5				// Wait 50ms
	rcall sleep_10ms
	mov r16, r18			// Show number
	rcall show
	ldi r16, 5				// Wait 50ms
	rcall sleep_10ms
	dec r19					// Decrease counter
	brne end_loop
	ldi r18, 1				// Reset dealy for the case that button will be pressed
	ldi r19, 50				// We will wait 5s max
finish_wait:
	sbic PINB, 1			// Check whether button is pressed
	rjmp loop				// Repeat the whole code
	ldi r16, 10				// Wait 10ms
	rcall sleep_10ms	
	dec r19					// Decrease counter
	brne finish_wait		
finish:
	ldi r16, 0				// Turn off transistor
	out PORTB, r16
	rjmp finish				// Repeat (just in case...)

show:						// Show number 1 to 6 or nothing (r16 is input - 1 to 6, other number = nothing to show)
	push r16
	dec r16
	brne show2
	ldi r16, 0x01
	rjmp show_out
show2:
	dec r16
	brne show3
	ldi r16, 0x04
	rjmp show_out
show3:
	dec r16
	brne show4
	ldi r16, 0x05
	rjmp show_out
show4:
	dec r16
	brne show5
	ldi r16, 0x06
	rjmp show_out
show5:
	dec r16
	brne show6
	ldi r16, 0x07
	rjmp show_out
show6:
	dec r16
	brne show0
	ldi r16, 0x0e
	rjmp show_out
show0:
	ldi r16, 0x00
show_out:
	out PORTA, r16
	pop r16
	ret

sleep_10ms:					// Wait N x 10ms (r16 is input - N)
	push r16
	push r17
	push r18
	clr r17
	ldi r18, 12
sleep_loop:
	dec r17
	brne sleep_loop
	dec r18
	brne sleep_loop
	ldi r18, 12
	dec r16
	brne sleep_loop
	pop r18
	pop r17
	pop r16
	ret