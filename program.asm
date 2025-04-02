global start

section .text

start:
  fninit

  ; output string
  mov rax, 0x02000004
  mov rdi, 1
  mov rsi, hello_world
  mov rdx, length
  syscall

  mov rcx, resolution
  mov rbx, rcx

loop_y:
loop_x:
  push rcx
  push rbx
  call calculate
  pop rbx
  pop rcx

  dec rcx
  cmp rcx, 0
  jg loop_x

  call new_line
  dec rbx
  cmp rbx, 0
  mov rcx, resolution
  jg loop_y

  ; exit with value
  mov rax, 0x02000001
  mov rdi, 0x0
  syscall

calculate:
  ; x, y coords in [-2..2] space st0, st1
  fild qword [rsp+16]
  call transform_coord
  fld st0
  mov rax, two
  fmul qword [rax]
  fsubp
  mov rax, x0
  fstp qword [rax]
  fild qword [rsp+8]
  call transform_coord
  mov rax, y0
  fstp qword [rax]

  mov rax, 32

  ; load newX
  mov rbx, x0
  fld qword [rbx]
  mov rbx, newX
  fstp qword [rbx]

  ; load newY
  mov rbx, y0
  fld qword [rbx]
  mov rbx, newY
  fstp qword [rbx]
start_loop:

  ; x * x + y * y
  mov rbx, newY
  fld qword [rbx]
  fmul st0
  mov rbx, newX
  fld qword [rbx]
  fmul st0
  faddp
  mov rbx, four
  fld qword [rbx]

  ; while (4.0 >= x * x + y * y)
  fcomi
  fstp
  fstp
  jbe exit_loop

  ; while (iterations != 0)
  cmp rax, 0
  je exit_loop


  ; calculate new x
  mov rbx, newX
  fld qword [rbx]
  fmul st0
  mov rbx, newY
  fld qword [rbx]
  fmul st0
  fsubp
  mov rbx, x0
  fadd qword [rbx]
  mov rbx, tempX
  fstp qword [rbx]

  ; calculate new y
  mov rbx, newY
  fld qword [rbx]
  mov rbx, newX
  fmul qword [rbx]
  mov rbx, two
  fmul qword [rbx]
  mov rbx, y0
  fadd qword [rbx]
  mov rbx, newY
  fstp qword [rbx]

  mov rbx, tempX
  fld qword [rbx]
  mov rbx, newX
  fstp qword [rbx]

  dec rax
  jmp start_loop


exit_loop:
  cmp rax, 10

  mov rax, '#'
  jg inside_set
  mov rax, ' '
inside_set:

  push rax
  call print_symbol
  call print_symbol
  pop rax
  ret

transform_coord:
  push resolution
  fidiv dword [rsp]
  pop rax

  mov rax, four
  fmul qword [rax]

  mov rax, two
  fsub qword [rax]

  ret

new_line:
  push 0xA
  call print_symbol
  pop rax
  ret

print_symbol:
  mov rbp, rsp
  add rbp, 8

  mov rax, 0x02000004
  mov rdi, 1
  mov rsi, rbp
  mov rdx, 1
  syscall

  ret

section .data

  resolution equ 100
  hello_world db "Hello, world!", 0xA
  length equ $ - hello_world
  four dq 4.0
  two dq 2.0

section .bss
  x0: resq 1
  y0: resq 1
  tempX: resq 1
  newX: resq 1
  newY: resq 1
