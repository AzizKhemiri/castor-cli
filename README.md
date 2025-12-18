# CASTOR CLI - Secure Authentication Console

x86 assembly authentication console that implements a password-protected login system with attempt limiting and lockout features.

## Features

- **Secure Password Input**: Masks password characters with asterisks (`*`)
- **Attempt Limiting**: Allows 3 password attempts before system lockout
- **Input Validation**: Enforces maximum 30-character password length
- **Backspace Support**: Users can correct their input during password entry
- **Lockout Mechanism**: 5-second countdown before system unlock after 3 failed attempts
- **User-Friendly Interface**: ASCII art logo and clear status messages

## Default Credentials

- **Password**: `secret123`

## Requirements

- x86 16-bit assembler EMU 8086 or ( DOSBox with NASM ).

## Usage

Assemble and run the program:

```bash
nasm castor-cli.asm -o castor-cli.com