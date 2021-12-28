struc  my_date
    .day: resw 1
    .month: resw 1
    .year: resd 1
endstruc

section .text
    global ages

; void ages(int len, struct my_date* present, struct my_date* dates, int* all_ages);
ages:
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; len
    mov     esi, [ebp + 12] ; present
    mov     edi, [ebp + 16] ; dates
    mov     ecx, [ebp + 20] ; all_ages

    ;Se fac initializarile pentru contorul de lungime si cel de parsare
    ;a memoriei vectorului all_ages
    mov eax, 0
    mov ebp, 0

calculate_ages:
    cmp ebp, edx 
    je finish ;Se face jump la finish cand numarul de persoane se termina
    mov ebx, [esi + my_date.year] ;Se salveaza anul datei curente in registrul ebx
    ;Se scade 1 din numarul de ani pentru a adauga numarul de ani completi 
    ;de la fiecare data de nastere in parte
    sub ebx, 1 
    sub ebx, [edi + my_date_size * ebp + my_date.year]
    ;Daca numarul de ani completi este negativ (data curenta este inaintea datei de nastere)
    ;merge in instructiunea 1, instructiune ce asigneaza valoarea 0 in vectorul final
    cmp ebx, 0
    jl instruction1
    mov [ecx + eax], ebx
    xor ebx, ebx
    ;Se verifica daca luna curenta si apoi ziua sunt >= decat luna, respectiv ziua datei de 
    ;nastere. In caz afirmativ se merge la instructiunea 3 unse se aduga inca un an la varsta,
    ;in caz contrat se merge in instructiunea 2 ce se reintoarce in bucla    
    mov bl, [esi + my_date.month]
    sub bl, [edi + my_date_size * ebp + my_date.month]
    cmp bl, 0
    jl instruction2
    cmp bl, 0
    jg instruction3
    xor bl, bl
    mov bl, [esi + my_date.day]
    sub bl, [edi + my_date_size * ebp + my_date.day]
    cmp bl, 0
    jl instruction2
    jmp instruction3

instruction1:
    mov [ecx + eax], dword 0
    add eax, 4
    add ebp, 1
    jmp calculate_ages

instruction2:
    add eax, 4
    add ebp, 1
    jmp calculate_ages

instruction3:
    add [ecx + eax], dword 1
    jmp instruction2
    
finish:    
    popa
    leave
    ret
