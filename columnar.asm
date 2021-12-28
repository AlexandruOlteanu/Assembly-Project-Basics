section .data
    extern len_cheie, len_haystack
    var dd 10
    my_string db "Alex", 0

section .text
    global columnar_transposition

;; void columnar_transposition(int key[], char *haystack, char *ciphertext);
columnar_transposition:
    push    ebp
    mov     ebp, esp
    pusha 

    mov edi, [ebp + 8]   ;key
    mov esi, [ebp + 12]  ;haystack
    mov ebx, [ebp + 16]  ;ciphertext

    ;Se initializeaza contorii pentru cele doua iteratii, respectiv 
    ;registrul ebp care contorizeaza caracterul curent din ciphertext
    mov eax, 0
    mov ecx, 0
    mov ebp, 0
encrypt_ciphertext:
    cmp eax, &len_cheie
    je finish;Se face jump la finish cand eax depaseste lungimea cheii
    mov edx, [edi + ecx]; edx primeste prima valoare de pe coloana curenta
    traverse_haystack:
        cmp edx, &len_haystack
        jge continue ;Incheie bucla cand se depaseste lungimea haystack-ului
        ;Pentru a parcurge intreaga coloana curenta data de valoarea din vectorul 
        ;cheii se merge din len_cheie in len_cheie pasi si se adauga
        ;la fiecare pas caracterul corespunzator chipertext-ului
        mov dword [var], edx
        mov dl, [esi + edx]
        mov [ebx + ebp], dl;
        xor edx, edx
        mov edx, &var
        add edx, &len_cheie
        add ebp, 1
        jmp traverse_haystack
    continue:
        add eax, 1
        add ecx, 4
        jmp encrypt_ciphertext

finish:
    popa
    leave
    ret
