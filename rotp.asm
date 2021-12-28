section .text
    global rotp

;; void rotp(char *ciphertext, char *plaintext, char *key, int len);
rotp:
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; ciphertext
    mov     esi, [ebp + 12] ; plaintext
    mov     edi, [ebp + 16] ; key
    mov     ecx, [ebp + 20] ; len
    
    ;Se initializeaza capatul din stanga si din dreapta de plecare
    ;pentru cele doua siruri
    mov ebx, 0 
    sub ecx, 1
    
encrypt_cypher:
    mov al, [esi + ebx] ;Se muta caracterul din sirul plaintext in subregsitrul
    xor al, [edi + ecx] ;lui eax se aplica xor intre acesta si caracterul din 
    mov [edx + ebx], al ;sirul key dupa care se muta in pozitia dorita
    add ebx, 1
    sub ecx, 1  ;Au loc schimbarile nexesare ale registrilor si se face comparatia
    cmp ecx, -1 ;pentru eventuala iesire din loop
    je finish ;Sare la finish 
    jmp encrypt_cypher ;Se reintoarce in bucla

finish:
    popa
    leave
    ret
