option casemap:none

EXTERN fopen:PROC
EXTERN fgets:PROC
EXTERN sscanf:PROC
EXTERN fclose:PROC

includelib msvcrt.lib
includelib legacy_stdio_definitions.lib

.data
rangeFmt        db "%llu-%llu",0
idFmt           db "%llu",0
modeRead        db "r",0

filenameBuf     db 256 dup(0)
lineBuf         db 128 dup(0)

rangeL          dq 4096 dup(0)
rangeR          dq 4096 dup(0)
rangeCount      dq 0

freshCount      dq 0             ; Part 1 result 
totalFreshIds   dq 0             ; Part 2 result 

tempA           dq 0
tempB           dq 0
tempID          dq 0

.code

; --------------------------------------
; helper: copy filename from RCX ? filenameBuf
; --------------------------------------
CopyFilename PROC
    ; RCX = const char* inputFilename
    push rsi
    push rdi

    mov  rsi, rcx
    lea  rdi, filenameBuf

copyLoop:
    mov  al, [rsi]
    mov  [rdi], al
    inc  rsi
    inc  rdi
    test al, al
    jne  copyLoop

    pop  rdi
    pop  rsi
    ret
CopyFilename ENDP

; ============================================================
; Part 1: counts how many AVAILABLE IDs are fresh
;      long long SolveDay5Part1(const char* filename)
; ============================================================
SolveDay5Part1 PROC

    sub  rsp, 40               

    ; copy filename into filenameBuf
    mov  rcx, rcx              ; filename already in RCX
    call CopyFilename

    ; fopen(filenameBuf, "r")
    mov  rcx, OFFSET filenameBuf
    mov  rdx, OFFSET modeRead
    call fopen
    mov  rbx, rax              ; FILE*
    test rbx, rbx
    je   P1_openFail

    mov  qword ptr [freshCount], 0
    mov  qword ptr [rangeCount], 0

; ======================
; READ RANGE LINES
; ======================
P1_readRanges:
    ; fgets(lineBuf, 128, file)
    mov  rcx, OFFSET lineBuf
    mov  rdx, 128
    mov  r8,  rbx
    call fgets
    test rax, rax
    je   P1_readIdsStart       ; EOF -> skip to IDs section 

    ; check for blank line (separator)
    mov  al, [lineBuf]
    cmp  al, 0
    je   P1_readIdsStart
    cmp  al, 10                ; '\n'
    je   P1_readIdsStart
    cmp  al, 13                ; '\r'
    je   P1_readIdsStart

    ; sscanf(lineBuf, "%llu-%llu", &tempA, &tempB)
    mov  rcx, OFFSET lineBuf
    mov  rdx, OFFSET rangeFmt
    mov  r8,  OFFSET tempA
    mov  r9,  OFFSET tempB
    sub  rsp, 32
    call sscanf
    add  rsp, 32

    ; index = rangeCount
    lea  r8, rangeCount
    mov  rax, [r8]             ; rax = index

    ; load tempA/tempB
    lea  r9, tempA
    mov  rcx, [r9]             ; rcx = tempA

    lea  r9, tempB
    mov  rdx, [r9]             ; rdx = tempB

    ; store to rangeL[index], rangeR[index]
    lea  r9, rangeL
    mov  [r9 + rax*8], rcx

    lea  r9, rangeR
    mov  [r9 + rax*8], rdx

    ; rangeCount++
    inc  qword ptr [rangeCount]

    jmp  P1_readRanges

; ======================
; READ AVAILABLE ID LINES
; ======================
P1_readIdsStart:

P1_readIdLoop:
    mov  rcx, OFFSET lineBuf
    mov  rdx, 128
    mov  r8,  rbx
    call fgets
    test rax, rax
    je   P1_doneFile           ; EOF

    mov  al, [lineBuf]
    cmp  al, 0
    je   P1_readIdLoop
    cmp  al, 10
    je   P1_readIdLoop
    cmp  al, 13
    je   P1_readIdLoop

    ; sscanf(lineBuf, "%llu", &tempID)
    mov  rcx, OFFSET lineBuf
    mov  rdx, OFFSET idFmt
    mov  r8,  OFFSET tempID
    sub  rsp, 32
    call sscanf
    add  rsp, 32

    ; r11 = candidate ID
    lea  r8, tempID
    mov  r11, [r8]

    ; r10 = rangeCount
    lea  r8, rangeCount
    mov  r10, [r8]

    xor  r9, r9                ; index = 0

P1_checkRangeLoop:
    cmp  r9, r10
    jge  P1_notFresh           ; no matching range

    ; load rangeL[r9]
    lea  r8, rangeL
    mov  rax, [r8 + r9*8]
    cmp  r11, rax
    jl   P1_nextRange          ; ID < left

    ; load rangeR[r9]
    lea  r8, rangeR
    mov  rax, [r8 + r9*8]
    cmp  r11, rax
    jg   P1_nextRange          ; ID > right

    ; ID is inside [L,R] -> fresh
    lea  r8, freshCount
    inc  qword ptr [r8]
    jmp  P1_readIdLoop

P1_nextRange:
    inc  r9
    jmp  P1_checkRangeLoop

P1_notFresh:
    jmp  P1_readIdLoop

P1_doneFile:
    mov  rcx, rbx
    call fclose

P1_openFail:
    lea  r8, freshCount
    mov  rax, [r8]             ; return freshCount
    add  rsp, 40
    ret

SolveDay5Part1 ENDP


; ============================================================
; Part 2:
; ============================================================
SolveDay5Part2 PROC

    sub  rsp, 40               ; shadow + align

    ; copy filename into filenameBuf
    mov  rcx, rcx              ; RCX already has pointer
    call CopyFilename

    ; fopen(filenameBuf, "r")
    mov  rcx, OFFSET filenameBuf
    mov  rdx, OFFSET modeRead
    call fopen
    mov  rbx, rax              ; FILE*
    test rbx, rbx
    je   P2_openFail

    mov  qword ptr [rangeCount],    0
    mov  qword ptr [totalFreshIds], 0

; ======================
; READ RANGE LINES ONLY
; (Stop at blank line, ignore IDs section)
; ======================
P2_readRanges:
    mov  rcx, OFFSET lineBuf
    mov  rdx, 128
    mov  r8,  rbx
    call fgets
    test rax, rax
    je   P2_afterRanges        ; EOF

    mov  al, [lineBuf]
    cmp  al, 0
    je   P2_afterRanges
    cmp  al, 10
    je   P2_afterRanges
    cmp  al, 13
    je   P2_afterRanges

    ; sscanf(lineBuf, "%llu-%llu", &tempA, &tempB)
    mov  rcx, OFFSET lineBuf
    mov  rdx, OFFSET rangeFmt
    mov  r8,  OFFSET tempA
    mov  r9,  OFFSET tempB
    sub  rsp, 32
    call sscanf
    add  rsp, 32

    ; index = rangeCount
    lea  r8, rangeCount
    mov  rax, [r8]

    ; load tempA/tempB
    lea  r9, tempA
    mov  rcx, [r9]             ; tempA

    lea  r9, tempB
    mov  rdx, [r9]             ; tempB

    ; store to arrays
    lea  r9, rangeL
    mov  [r9 + rax*8], rcx

    lea  r9, rangeR
    mov  [r9 + rax*8], rdx

    inc  qword ptr [rangeCount]
    jmp  P2_readRanges

P2_afterRanges:

    ; close file now, we don't need IDs section
    mov  rcx, rbx
    call fclose

    ; if no ranges, result = 0
    lea  r8, rangeCount
    mov  rsi, [r8]
    test rsi, rsi
    je   P2_openFail           ; just return 0

; ======================
; SORT RANGES BY rangeL 
; ======================
    xor  rcx, rcx              ; i = 0

P2_outerLoop:
    cmp  rcx, rsi
    jge  P2_sortDone

    mov  rdx, rcx
    inc  rdx                   ; j = i + 1

P2_innerLoop:
    cmp  rdx, rsi
    jge  P2_nextI

    ; load L[j] / L[i]
    lea  r8, rangeL
    mov  rax, [r8 + rdx*8]     ; Lj
    mov  r10, [r8 + rcx*8]     ; Li

    cmp  rax, r10
    jge  P2_noSwap

    ; swap L[i], L[j]
    mov  [r8 + rdx*8], r10
    mov  [r8 + rcx*8], rax

    ; swap R[i], R[j]
    lea  r8, rangeR
    mov  rax, [r8 + rdx*8]
    mov  r10, [r8 + rcx*8]
    mov  [r8 + rdx*8], r10
    mov  [r8 + rcx*8], rax

P2_noSwap:
    inc  rdx
    jmp  P2_innerLoop

P2_nextI:
    inc  rcx
    jmp  P2_outerLoop

P2_sortDone:

; ======================
; MERGE RANGES & SUM LENGTHS
; ======================
    ; current segment [curL, curR] = first range
    lea  r8, rangeL
    lea  r9, rangeR
    mov  rax, [r8]             ; curL
    mov  rdx, [r9]             ; curR

    mov  qword ptr [totalFreshIds], 0

    mov  rcx, 1                ; index = 1

P2_mergeLoop:
    cmp  rcx, rsi
    jge  P2_afterMerge

    mov  r10, [r8 + rcx*8]     ; s = L[i]
    mov  r11, [r9 + rcx*8]     ; e = R[i]

    ; if (s <= curR + 1) -> overlap/adjacent
    mov  r12, rdx
    add  r12, 1
    cmp  r10, r12
    jg   P2_disjoint

    ; overlapping / touching
    cmp  r11, rdx
    jle  P2_continue           ; fully inside

    mov  rdx, r11              ; extend curR to e
    jmp  P2_continue

P2_disjoint:
    ; add length of [curL, curR]: len = curR - curL + 1
    mov  r13, rdx
    sub  r13, rax
    inc  r13

    lea  r14, totalFreshIds
    mov  r15, [r14]
    add  r15, r13
    mov  [r14], r15

    ; new current segment = [s,e]
    mov  rax, r10
    mov  rdx, r11

P2_continue:
    inc  rcx
    jmp  P2_mergeLoop

P2_afterMerge:
    ; add last [curL,curR]
    mov  r13, rdx
    sub  r13, rax
    inc  r13

    lea  r14, totalFreshIds
    mov  r15, [r14]
    add  r15, r13
    mov  [r14], r15

P2_openFail:
    lea  r8, totalFreshIds
    mov  rax, [r8]             ; return totalFreshIds
    add  rsp, 40
    ret

SolveDay5Part2 ENDP

END

