%include "/home/student/Desktop/iocla-tema2-resurse/include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
    use_str     db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0
    revient     dw 114, 101, 118, 105, 101, 110, 116
    my_message  db "C'est un proverbe francais.", 0, 0
section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1
    
section .text
global main
main:
        mov ebp, esp; for correct debugging
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax
    call get_image_height
    mov [img_height], eax
    
    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax
    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    xor edx, edx
    mov edx, [img_height]
    imul edx,[img_width]    ; number of elements in matrix 
    push edx
    xor edi, edi            ; used to choose the key
    choose_key:
        xor ecx, ecx        ; used as iterator through the matrix
        mov eax, [img]      ; keep in eax the address of the immage  
        matrix_parse:
        pop edx
        push edx
        xor esi, esi
        mov esi, [revient]
        mov ebx, [eax + ecx * 4]
        inc ecx
        xor ebx, edi        ; apply the key        
        cmp bx, si          ; see if letter r found
        je verify           ; check if the rest of the word 'revient' is found  
        pop edx
        push edx
        cmp ecx, edx
        jne matrix_parse
        inc edi
        cmp edi, 256
        jne choose_key

    verify:
        xor edx, edx
        xor esi, esi
        next_letter:
        mov ebx, [eax + 4 * ecx]
        inc ecx
        inc edx
        cmp edx, 7
        je end_task_1
        mov si, word[revient + 2 * edx]
        xor ebx, edi
        cmp bx, si
        je next_letter  
        jmp matrix_parse
    
    end_task_1:                                                
    sub ecx, 6              ; move ecx back on r ( it was previously on t
    mov eax, ecx
    mov ebx, [img_width]
    cdq
    idiv ebx 
      
    mov ecx, eax
    mov esi, [task]         ; verify if the task is 1 in order to print the 
    cmp esi, 1              ; data, otherwise keep the key and line for task 2    
    jne keep_line_key
    
    push eax                ; keep the value of the line on the stack
    imul ecx, [img_width]   ; place in ecx the value of the first letter 
                            ; on the line stored in [line]
    mov eax, [img]
    print_messge_task1:
    mov ebx, [eax + ecx * 4] 
    xor ebx, edi
    inc ecx 
    cmp ebx, 0
    je print_task1 
    PRINT_CHAR ebx
    cmp ecx, [img_width]
    jne print_messge_task1
    
    print_task1:
    NEWLINE
    PRINT_DEC 4, edi    ; print the key
    NEWLINE
    pop ecx             ; pop the value of the line from the stack
    PRINT_DEC 4, ecx    ; print the line
    NEWLINE
    
    keep_line_key:
    
    mov eax, ecx        ; keep in eax the line
    xor ecx, ecx
    mov ecx, edi        ; keep in ecx the key
    
    mov esi, [task]
    cmp esi, 2
    je task_2
    jmp done
solve_task2:
    ; TODO Task2
    jmp solve_task1
    task_2:
    inc eax         ; set eax to keep the next line
    push eax        ; store the line on which to write on the stack
    xor eax, eax
    mov eax, ecx
    imul eax, 2     ; calculate the new key
    add eax, 3
    mov ebx, 5
    cdq
    idiv ebx
    sub eax, 4
    push eax        ; put the new key on the stack
    mov edi, ecx    ; put the old key in edi in ordet to free ecx
    xor ecx, ecx
        
    mov esi, [img_width]
    imul esi, [img_height]  ; keep the size of the matrix
    mov eax, [img]
    mov edx, [img]
    parse_to_decript:
    mov ebx, [eax + ecx * 4] 
    xor ebx, edi
    mov [edx + ecx * 4], ebx
    inc ecx  
    cmp ecx, esi
    jne parse_to_decript
    
    xor ecx, ecx
    mov [img], edx
    mov eax, [img]          ; now the immage is decripted
   
    pop edi                 ; the new key
    pop ecx                 ; restore the line on which to write the message
    push edi                ; store again the new key to save it for later
    imul ecx, [img_width]   ; keep the first position on which to add
    mov esi, 28             ; length of the message
    add esi, ecx
    xor ebx, ebx
    xor edx, edx
    xor edi, edi
    mov edx, my_message
    put_message:
    mov bl, byte[edx + edi]
    mov [eax + ecx * 4], ebx
    inc ecx
    inc edi
    cmp ecx, esi
    jne put_message
    
    mov [img], eax
    xor ecx, ecx
    mov esi, [img_height]
    imul esi, [img_width]
    pop edi
    encript:                    ; add the encrepted message in the image
    mov ebx, [eax + ecx * 4] 
    xor ebx, edi
    mov [eax + ecx * 4], ebx
    inc ecx  
    cmp ecx, esi
    jne encript
    
    mov [img], eax
    push dword[img_height] 
    push dword[img_width]
    push dword[img]
    call print_image
    jmp done
solve_task3:
    ; TODO Task3
    mov eax, [ebp + 12]
    mov ebx, [eax + 12]
    xor esi, esi
    parse_msg:
    mov ecx, dword[ebx + esi]
    inc esi
    cmp cl, 'A'
    jge parse_msg
    cmp cl, ','
    je parse_msg
    push esi            ; find the length of the message
    xor edx, edx
    xor ecx, ecx
   
    find_index:         ; calculate the index
    mov cl, byte[ebx + esi]
    cmp cl, 0
    je index_found
    sub cl, '0'
    imul edx, 10
    add edx, ecx
    inc esi
    cmp cl, 9
    jle find_index
    
    index_found:    ; index is in edx
    pop edi         ; lenght of the message
    
    mov eax, [ebp + 12]
    mov ebx, [eax + 12]

    mov esi, edi
    dec esi
    parse_again_msg:
    mov ecx, dword[ebx + esi]
    dec esi
    push ecx
    cmp esi, 0
    jge parse_again_msg
    
    xor esi, esi
    inc esi
    mov ecx, edx
    mov eax, [img]
    put_morse:
    pop ebx
    cmp bl, 'A'
    jne try_B
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_B:
    cmp bl, 'B'
    jne try_C
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_C:
    cmp bl, 'C'
    jne try_D
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_D:
    cmp bl, 'D'
    jne try_E
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_E:
    cmp bl, 'E'
    jne try_F
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_F:
    cmp bl, 'F'
    jne try_G
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_G:
    cmp bl, 'G'
    jne try_H
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_H:
    cmp bl, 'H'
    jne try_I
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_I:
    cmp bl, 'I'
    jne try_J
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_J:
    cmp bl, 'J'
    jne try_K
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_K:
    cmp bl, 'K'
    jne try_L
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_L:
    cmp bl, 'L'
    jne try_M
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_M:
    cmp bl, 'M'
    jne try_N
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_N:
    cmp bl, 'N'
    jne try_O
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_O:
    cmp bl, 'O'
    jne try_P
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_P:
    cmp bl, 'P'
    jne try_Q
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_Q:
    cmp bl, 'Q'
    jne try_R
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_R:
    cmp bl, 'R'
    jne try_S
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_S:
    cmp bl, 'S'
    jne try_T
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_T:
    cmp bl, 'T'
    jne try_U
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_U:
    cmp bl, 'U'
    jne try_V
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_V:
    cmp bl, 'V'
    jne try_W
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_W:
    cmp bl, 'W'
    jne try_X
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_X:
    cmp bl, 'X'
    jne try_Y
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_Y:
    cmp bl, 'Y'
    jne try_Z
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    try_Z:
    cmp bl, 'Z'
    jne try_COMMA
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    try_COMMA:
    cmp bl, ','
    jne add_space
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '.'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    mov dword[eax + ecx * 4], '-'
    inc ecx
    
    add_space:
    inc esi
    cmp esi, edi
    je final
    mov dword[eax + ecx * 4], ' '
    inc ecx
    final:    
    cmp esi, edi
    jne put_morse
    
    mov dword[eax + ecx * 4], 0
    inc ecx
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    jmp done
solve_task4:
    ; TODO Task4
    mov eax, [ebp + 12]
    mov ebx, [eax + 12]
    xor esi, esi
    find_msg_to_encript:
    mov ecx, dword[ebx + esi]
    inc esi
    cmp cl, 'A'
    jge find_msg_to_encript
    cmp cl, ','
    je find_msg_to_encript
    push esi            ; find the length of the message
    xor edx, edx
    xor ecx, ecx
   
    find_byte:         ; calculate the index
    mov cl, byte[ebx + esi]
    cmp cl, 0
    je byte_found
    sub cl, '0'
    imul edx, 10
    add edx, ecx
    inc esi
    cmp cl, 9
    jle find_byte
    
    byte_found:     ; index is in edx
    pop edi         ; lenght of the message
    
    mov eax, [ebp + 12]
    mov ebx, [eax + 12]
    mov esi, edi
    dec esi
    put_msg_on_stack:
    mov ecx, dword[ebx + esi]
    dec esi
    push ecx        ; push each letter on the stack
    cmp esi, 0
    jge put_msg_on_stack
    
    dec edx   
    xor esi, esi
    encript_msg:
    pop ebx
    mov eax, 8      ; a byte has 8 bits
    each_bit:
    xor ecx, ecx
    mov cl, bl      ; keep the charater in cl
                    ; I will xor this character with pows of 2
                    ; in order to obtain each bit 
    cmp eax, 8          
    jne try_7 
    and cl, 128 
    shr cl, 7
    try_7:
    cmp eax, 7
    jne try_6
    and cl, 64 
    shr cl, 6
    try_6:
    cmp eax, 6
    jne try_5
    and cl, 32 
    shr cl, 5  
    try_5:
    cmp eax, 5
    jne try_4
    and cl, 16 
    shr cl, 4      
    try_4:
    cmp eax, 4
    jne try_3
    and cl, 8 
    shr cl, 3
    try_3:
    cmp eax, 3
    jne try_2
    and cl, 4 
    shr cl, 2         
    try_2:
    cmp eax, 2
    jne try_1
    and cl, 2 
    shr cl, 1
    try_1: 
    cmp eax, 1
    jne obtain_bit
    and cl, 1 
                       
    obtain_bit:     ; once I obtain the bit                                 
    dec eax         
    push eax
    mov eax, [img]
    cmp cl, 0       ; if cl = 00000000
    jne set_bit
    not cl              ; cl = 11111111
    dec cl              ; cl = 11111110
    
    and [eax + edx * 4], cl     ; reset the last bit of the number
    jmp continue
    set_bit:        ; else
    or [eax + edx * 4], cl      ; set the last bit of the number
    continue:
    inc edx
    pop eax
    cmp eax, 0
    jg each_bit 
    inc esi
    cmp esi, edi
    jne encript_msg
    
    push dword[img_height] 
    push dword[img_width]
    push dword[img]
    call print_image
    
    jmp done
solve_task5:
    ; TODO Task5
    mov eax, [ebp + 12]
    mov ebx, [eax + 12]
    xor esi, esi
    xor edx, edx
    xor ecx, ecx
    find_poz:         ; calculate the position
    mov cl, byte[ebx + esi]  
    cmp cl, 0
    je poz_found
    sub cl, '0'
    imul edx, 10      ; keep position in edx
    add edx, ecx
    inc esi
    cmp cl, 9
    jle find_poz
    
    poz_found:
    mov ecx, edx
    dec ecx
    xor esi, esi
    xor edi, edi
    xor edx, edx
    find_encoded_msg:       ; parse the matrix from the position fo the message
    mov eax, [img]
    mov ebx, [eax + ecx * 4]
    inc ecx
    
    cmp esi, 8
    jne not_next_character
                        ; the first letter was found
    xor esi, esi        ; reset counter esi
    inc edi             ; increment thr number of items
    shr edx, 1          ; shift right the result because it was extra shifted 
    cmp edx, 0          ; if end of the message
    je final_ch         ; ending
    PRINT_CHAR edx      ; print the value
    xor edx, edx        ; reset the value for the character
    inc esi
    jmp all_checked     ; jump to repeat the process
    
    not_next_character:
    inc esi
    and ebx, 1          ; ogtain the last bit in ebx
    
    add edx, ebx        ; add in the result the last bit
    shl edx, 1          ; shift left to make space for another bit
    
    all_checked:
    cmp edi, 20
    jne find_encoded_msg
    
    final_ch:   
    NEWLINE
    jmp done
solve_task6:
    ; TODO Task6  
    mov eax, [img]
    mov esi, [img_width]
    xor edx, edx
    xor ecx, ecx
    blur:
    mov eax, [img]              ; put the address of the image in eax
    mov ebx, [eax + ecx * 4]    ; access each element   
    
    cmp ecx, [img_width]        ; if my index is on the first line (up border)
    jle just_print              ; do not modify the value
    
    mov edx, [img_width]
    imul edx, [img_height]
    sub edx, [img_width]        ; index of the last element on the second last row
    
    cmp ecx, edx                ; if my index is edx (calculatef above) ( down border)
    jge just_print              ; do not modify the value
    
    mov eax, ecx
    cdq
    idiv dword[img_width]
    cmp edx, 0                  ; first element on the line (left border)
    je just_print               
    inc edx
    cmp edx, dword[img_width]   ; last element on the line  (right border)
    je just_print
    
    
    mov eax, [img]                  ; eax was modified so make it point again to img
    add ebx, [eax + ecx * 4 - 4]    ; add right
    add ebx, [eax + ecx * 4 + 4]    ; add left
    sub ecx, [img_width]
    add ebx, [eax + ecx * 4]        ; add upper
    add ecx, [img_width]
    add ecx, [img_width]
    add ebx, [eax + ecx * 4]        ; add down
    sub ecx, [img_width]
    
    mov eax, ebx
    mov ebx, 5
    cdq
    idiv ebx            ; make average
    mov ebx, eax        ; always keep the result in ebx, not eax
    
    just_print:
    push ebx            ; put all the values on the stack
    inc ecx
    cmp ecx, esi
    jne blur            
    
    add esi, [img_width]
    mov edi, [img_width]
    imul edi, [img_height]
    sub edi, [img_width]    ; size of the image
    cmp ecx, edi            ; if there are still elements
    jle blur                ; repeat for all
    
    
    mov edx, [img_width]
    imul edx, [img_height]
    xor ecx, ecx
    mov eax, [img]
    
    restore:
    mov edx, [img_width]
    imul edx, [img_height]
    xor ecx, ecx
    modify_with_average:        ; after this, the matrix is rotated 180 degrees
    cmp esp, ebp                ; because the values are stored from the last
    je get_out                  ; to the first
    pop ebx                     ; pop the value 
    mov [eax + ecx * 4], ebx    
    inc ecx
    cmp ecx, edx
    jne modify_with_average     ; repeat for all
    
    get_out:                    ; put all the values back on the stack
    xor ecx, ecx                ; to store them in the correct order    
    mov edx, [img_width]
    imul edx, [img_height]
    swap:                     
    mov ebx, [eax + ecx * 4]    
    inc ecx
    push ebx
    cmp ecx, edx
    jne swap
    
    xor ecx, ecx
    final_matrix:               ; now pop al the values in the correct order
    pop ebx                     
    mov [eax + ecx * 4], ebx
    inc ecx
    cmp ecx, edx
    jne final_matrix            ; the image is now in the correct 
                                                                                             
    push dword[img_height] 
    push dword[img_width]
    push dword[img]
    call print_image            ; print the image
    jmp done
    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
