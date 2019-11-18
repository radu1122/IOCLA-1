%include "includes/io.inc"

extern getAST
extern freeAST
extern printf
section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1
   

section .text
global main

string_to_number:  
    push ebp
    lea ebp, [esp]

    xor edx, edx  
    xor ebx, ebx  
    xor esi, esi
    xor edi, edi
    
    mov dl, [ecx]
    cmp dl, '-' 
    jne parse   ; daca primul caracter e nu '-', treci la parcurgere
    inc esi     ; altfel, sari peste el
    mov edi, 1  ; si retine ca numarul e negativ
parse:
    mov dl, [ecx + esi] ; ia fiecare caracter

    cmp dl, ' ' ; daca s-a parcurs tot
    jbe return  ; iesi din functie
                                ; calculeaza in ebx numarl:
    imul ebx, 10                ; ebx = eax * 10
    lea ebx, [ebx + edx - '0']  ; ebx+= [ecx] - '0'

    inc esi ; mergi pe urmatoarea pozitie
    jmp parse   

return:
    cmp edi, 1 
    jne final   ; daca numarul nu e negativ, treci la final
    imul ebx, -1     ; altfel se inmulteste rezultatul cu -1
final:     
    leave
    ret

traverse:
    push ebp
    mov ebp, esp

    xor edx, edx
    mov ecx, [eax]
    mov dl, [ecx] 
    ; daca in eax e numar atuci fiul sau stang (implicit si cel drept) e null
    cmp dword[eax + 4], 0
    je is_number 

    is_sign: 
        push edx    ; retine pe stiva valoare
        push dword [eax + 8] ; retine fiul DREAPTA (right)
        push dword [eax + 4] ; retine fiul STANGA (left)
        
        pop eax         ;left
        call traverse   ; apel recursiv pe stanga 
        pop ebx         ; scoate eax-ul fara a-i pierde valoarea
        push eax
        mov eax, ebx    ; adica right
        call traverse   ; apel recursiv pe dreapta
        pop ebx
        pop edx   
         
        cmp dl, '+'
        je adunare 
        cmp dl, '*'
        je inmultire 
        cmp dl, '/'
        je impartire 
        cmp dl, '-'
        je scadere
    adunare:
        add eax, ebx
        jmp end
    scadere:
        sub ebx, eax
        mov eax, ebx
        jmp end
    inmultire:
        imul eax, ebx
        jmp end
    impartire:
        xchg eax, ebx
        cdq
        idiv ebx
        jmp end
            
    is_number: 
        push edx    ; adauga pe stiva valoarea care trebuie convertita
        call string_to_number
        mov edx, ebx
        mov eax, edx
end:
    leave
    ret

main:
    mov ebp, esp; for correct debugging
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    
    ; apelare si afisare:
    call traverse
    PRINT_DEC 4, eax
    
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret