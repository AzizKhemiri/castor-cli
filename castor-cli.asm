; ============================================
;       SECURE AUTHENTICATION CONSOLE
; ============================================
;    ____    _    ____  _____  ___  ____  
;   / ___|  / \  / ___||_   _|/ _ \|  _ \ 
;  | |     / _ \ \___ \  | | | | | | |_) |
;  | |___ / ___ \ ___) | | | | |_| |  _ < 
;   \____/_/   \_\____/  |_|  \___/|_| \_\
;                                          
; ============================================

ORG 100h                    

start:
    call afficher_logo
    mov byte ptr [tentatives_restantes], 3
boucle_tentatives:
    cmp byte ptr [tentatives_restantes], 0
    je blocage_systeme
    
    call afficher_tentatives
    call afficher_prompt
    call lire_mot_de_passe
    call comparer_mots_de_passe
    
    dec byte ptr [tentatives_restantes]
    
    call nettoyer_buffer
    
    jmp boucle_tentatives

blocage_systeme:
    mov dx, offset msg_blocage 
    mov ah, 09h
    int 21h
    
    call attendre_5_secondes
    
    mov dx, offset msg_fin_blocage
    mov ah, 09h
    int 21h

    mov ah, 4Ch
    int 21h

; Fct : afficher_logo
afficher_logo:
    mov dx, offset msg_logo
    mov ah, 09h
    int 21h
    ret

; Fct : afficher_tentatives
afficher_tentatives:
    mov dx, offset msg_tentatives_pre
    mov ah, 09h
    int 21h
    
    mov al, [tentatives_restantes]
    add al, '0'              ; 1-3 ==> '1'-'3'
    mov dl, al
    mov ah, 02h
    int 21h
    
    mov dx, offset msg_tentatives_post
    mov ah, 09h
    int 21h
    ret

; Fct : afficher_prompt
afficher_prompt:
    mov dx, offset msg_titre
    mov ah, 09h
    int 21h
    
    mov dx, offset msg_prompt
    mov ah, 09h
    int 21h
    ret

; Fct : lire_mot_de_passe
lire_mot_de_passe:
    mov si, offset buffer_input
    xor cx, cx

.boucle_lecture:
    mov ah, 08h
    int 21h
    
    cmp al, 0Dh
    je .fin_saisie
    
    cmp al, 08h
    je .gerer_backspace

    
    ; Condition & Alert > 30 
    cmp cx, 30
    jl .ajouter_caractere
    mov dx, offset msg_trop_long
    mov ah, 09h
    int 21h
    
    jmp .fin_saisie

.ajouter_caractere:
    mov [si], al
    inc si
    inc cx
    
    push ax
    mov dl, '*'
    mov ah, 02h
    int 21h
    pop ax
    
    cmp cx, 30
    jl .boucle_lecture
    jmp .fin_saisie

.gerer_backspace:
    cmp cx, 0
    je .boucle_lecture
    
    dec si
    dec cx
    
    mov dl, 08h
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 08h
    mov ah, 02h
    int 21h
    
    jmp .boucle_lecture

.fin_saisie:
    mov byte ptr [si], 0
    mov longueur_input, cx
    
    mov dx, offset msg_newline
    mov ah, 09h
    int 21h
    ret

; Fct : comparer_mots_de_passe
comparer_mots_de_passe:
    mov cx, longueur_input
    cmp cx, longueur_correct
    jne .acces_refuse
    
    mov si, offset buffer_input
    mov di, offset mot_de_passe_correct
    xor bx, bx ; indexe for CMP (MOV BX, 0)

.boucle_comparaison:
    mov al, [si + bx]
    mov dl, [di + bx]
    
    cmp al, dl
    jne .acces_refuse
    
    cmp al, 0
    je .acces_autorise
    
    inc bx
    jmp .boucle_comparaison

.acces_autorise:
    mov dx, offset msg_acces_ok
    mov ah, 09h
    int 21h
    
    mov ah, 4Ch
    int 21h

.acces_refuse:
    mov dx, offset msg_acces_no
    mov ah, 09h
    int 21h
    ret

; Fct : nettoyer_buffer
nettoyer_buffer:
    mov si, offset buffer_input
    mov cx, 32
.boucle_nettoyage:
    mov byte ptr [si], 0
    inc si
    loop .boucle_nettoyage
    ret

; Fct : attendre_5_secondes
attendre_5_secondes:
    mov ah, 00h
    int 1Ah            
    
    ; Input save hour
    mov word ptr [temps_debut], dx
    mov word ptr [temps_debut + 2], cx
    
    ; 1 sec = 18.2 tics
    ; 5 secs = 91 tics (18.2 * 5 = 91)
    mov word ptr [tics_a_attendre], 91
    
.boucle_attente:
    call afficher_point
    
    ; scanf current hour
    mov ah, 00h
    int 1Ah
    
    ; dx = dx - temps_debut
    sub dx, word ptr [temps_debut]

    cmp dx, word ptr [tics_a_attendre]
    jl .boucle_attente
    
    ret

; Fct : afficher_point
afficher_point:
    push dx
    mov dl, '.'
    mov ah, 02h
    int 21h
    pop dx
    
    ; Petite pause
    mov cx, 0FFFFh
.pause:
    loop .pause
    
    ret

;===========================================
; Vars & Messages
;===========================================
tentatives_restantes db 3
mot_de_passe_correct db "secret123", 0
longueur_correct dw 9
temps_debut dd 0     
tics_a_attendre dw 91
msg_logo db 0Dh, 0Ah
         db "   ____    _    ____  _____  ___  ____  ", 0Dh, 0Ah
         db "  / ___|  / \  / ___||_   _|/ _ \|  _ \ ", 0Dh, 0Ah
         db " | |     / _ \ \___ \  | | | | | | |_) |", 0Dh, 0Ah
         db " | |___ / ___ \ ___) | | | | |_| |  _ < ", 0Dh, 0Ah
         db "  \____/_/   \_\____/  |_|  \___/|_| \_\", 0Dh, 0Ah
         db 0Dh, 0Ah
         db "     SECURE AUTHENTICATION CONSOLE", 0Dh, 0Ah
         db 0Dh, 0Ah, '$'
msg_titre    db "===========================", 0Dh, 0Ah
             db "     CASTOR CLI", 0Dh, 0Ah
             db "===========================", 0Dh, 0Ah, '$'

msg_tentatives_pre db "==> Remaining attempts: $"
msg_tentatives_post db 0Dh, 0Ah, '$'

msg_prompt   db "==> Entre the password : $"

msg_newline  db 0Dh, 0Ah, '$'

msg_acces_ok db 0Dh, 0Ah                                       
             db "==> [OK] ACCESS AUTHORIZED ", 0Dh, 0Ah
             db "===========================", 0Dh, 0Ah, '$'

msg_acces_no db 0Dh, 0Ah                                  
             db "==> [Denied !] ACCESS DENIED ", 0Dh, 0Ah
             db "==> Please try again...", 0Dh, 0Ah
             db "===========================", 0Dh, 0Ah, '$'

msg_blocage  db 0Dh, 0Ah
             db "===========================", 0Dh, 0Ah
             db " /!\\ CASTOR CLI BLOCKED /!\\", 0Dh, 0Ah
             db "===========================", 0Dh, 0Ah
             db "==> 3 Failed attempts!", 0Dh, 0Ah
             db "==> Blockage in progress", '$'               

msg_fin_blocage db 0Dh, 0Ah, 0Dh, 0Ah
                db "===========================", 0Dh, 0Ah
                db " CASTOR CLI UNBLOCKED.", 0Dh, 0Ah
                db " Programme end.", 0Dh, 0Ah
                db "===========================", 0Dh, 0Ah, '$'
msg_trop_long db 0Dh,0Ah
              db "[!] Maximum 30 characters allowed!",0Dh,0Ah,'$'
buffer_input db 32 dup(0)
longueur_input dw 0

end start