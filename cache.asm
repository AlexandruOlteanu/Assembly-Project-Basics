CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 32

section .data
    iterator dd 0
    iterator1 dd 0
    replace_line dd 0
    cache_line dd 0
    offset dd 7
    var dd 0
    var1 dd 0

section .text
    global load

;; void load(char* reg, char** tags, char cache[CACHE_LINES][CACHE_LINE_SIZE], char* address, int to_replace);
load:
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)

    ;Se calculeaza tag-ul prin punerea ultimilor biti egali cu 1 folosind
    ;operatia or, apoi cu ajutorul operatiei xor acestia se schimba din 
    ;1 in 0. Astfel se obine mereu tag-ul care reprezinta de fapt adresa
    ;doar ca are mereu ultimii 3 biti pe 0
    xor ebp, ebp;
    mov ebp, edx
    or ebp, byte 7
    xor ebp, byte 7

    ;Se face initializarea iteratorilor si a variabilei replace_line ce
    ;reprezinta numarul de biti pe care trebuie sa ii sar pentru a
    ;ajunge la memoria responsabila de linia to_replace(edi)
    mov &iterator, dword 0
    mov &iterator1, dword 0
    mov &replace_line, dword 0
    mov &cache_line, dword 0

    ;Se verifica daca tag-ul calculat anterior este deja prezent in 
    ;lista de tag-uri existente si de asemenea se calculeaza replace_line 
    ;si cache_line. Daca tag-ul este prezent, se merge in cazul cache_hit 
    ;unde se preia valoarea de la memoria adresei (cea ce va fi mereu returnata),
    ;daca nu,se merge in cazul cache_miss(explicat mai jos)
traverse_tags:
    cmp &iterator1, dword CACHE_LINES
    je cache_miss
    mov esi, &iterator
    cmp &iterator1, edi 
    je change_replace_line ;Se face jump la functia de modificare pentru replace_line
    continue_after_replace:
        add &iterator1, dword 1
        cmp [ebx + esi], byte 0x00 ;Se verifica daca tag-ul curent este null, daca da,
        je add_one                 ;se incrementeaza cu 1, daca nu, se va incrementa cu
        cmp [ebx + esi], ebp       ;32, valoarea bitilor de pe o linie ocupata
        je cache_hit
        add &iterator, dword TAG_BITS
        add &cache_line, dword CACHE_LINE_SIZE
        jmp traverse_tags

change_replace_line:
    mov &replace_line, esi 
    jmp continue_after_replace

add_one:
    add &iterator, dword 1
    add &cache_line, dword CACHE_LINE_SIZE
    jmp traverse_tags

    ;Se calculeaza offset-ul si apoi se acceseaza memoria corespunzatoare
    ;a acestuia in functie de memoria inceputului liniei din cache dorita
    ;si offset
cache_hit:
    or &offset, byte 7
    and &offset, edx
    mov ebp, &offset
    add ebp, &cache_line
    mov ebp, [ecx + ebp]
    mov [eax], ebp
    jmp finish

    ;In cazul cache_miss se parcurg toti octetii porning de la tag pana la 
    ;tag cu 111 ca ultimi 3 biti. Acest lucru se face printr-o bucla.
    ;Stiind deja memoria unde trebuie pus tag-ul calculat initial dar si memoria 
    ;unde vor fi pusi octetii in cache, se proceseaza pas cu pas calculand
    ;corespunzator octetul curent
cache_miss:
    mov esi, &replace_line
    mov [ebx + esi], ebp
    xor esi, esi
    mov si, 0
    fill_octets:
        cmp si, byte 8
        jge finish_fill_octets
        or ebp, esi
        mov &var1, edi
        mov edi, [ebp]
        mov &var, esi
        mov &iterator, dword 0
        ;Se calculeaza valoarea lui esi * CACHE_LINE_SIZE
        ;pentru a putea accesa corespunzator
        ;memoria cache
        loop_add:                                
            cmp &iterator, dword CACHE_LINE_SIZE   
            je finish_loop_add               
            add esi, &var1
            add &iterator, dword 1
            jmp loop_add
        finish_loop_add:
            ;Se updateaza valoarea lui cache_line cand ultimii 3 biti sunt 0
            cmp &var, byte 0
            je update_cache_line    
            continue_after_update:
                mov [ecx + esi], edi
                mov edi, &var1
                mov esi, &var       ;Se realizeaza schimbarile necesare in cache si apoi
                or ebp, byte 7      ;se revine la valoarea initiala a tag-ului pentru
                xor ebp, byte 7     ;prelucrarea urmatoarelor valori
                add si, word 1
                jmp fill_octets

    finish_fill_octets: 
            jmp cache_hit   ;Odata modificat cache-ul si adaugat tag-ul in lista de tag-uri
                            ;existente, se merge in cazul cache_hit, moment in care putem
                            ;schimba valoarea registrului
    ;Functia ce schimba valoarea lui cache_line
    update_cache_line:
        mov &cache_line, esi
        jmp continue_after_update
finish:                     
    popa
    leave
    ret
