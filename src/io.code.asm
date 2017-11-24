io.load_file:
    pop ebp
    pop edx
    push ebp
    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push OPEN_EXISTING
    push NULL
    push FILE_SHARE_READ
    push GENERIC_READ
    push edx
    call [CreateFile]
    cmp eax, INVALID_HANDLE_VALUE
    jne .open_ok
    push .open_fail_msg
    call ui.message_box
    ret
.open_ok:
    mov [io.file_handle], eax
    push NULL
    push [io.file_handle]
    call [GetFileSize]
    cmp eax, -1  ; INVALID_FILE_SIZE
    jne .size_ok
    push .size_fail_msg
    call ui.message_box
    ret
.size_ok:
    mov [io.file_size], eax
    call [GetProcessHeap]
    mov [io.heap_handle], eax
    push [io.file_size]
    push HEAP_ZERO_MEMORY
    push eax
    call [HeapAlloc]
    test eax, eax
    jnz .heap_ok
    push .heap_fail_msg
    call ui.message_box
.heap_ok:
    mov [io.file_data_ptr], eax
    push NULL
    push io.num_bytes_read
    push [io.file_size]
    push [io.file_data_ptr]
    push [io.file_handle]
    call [ReadFile]
    test eax, eax
    jnz .read_ok
    push .read_fail_msg
    call ui.message_box
.read_ok:
    push [io.file_data_ptr]
    call ui.set_textbox_text
    push [io.file_handle]
    call [CloseHandle]
    push [io.file_data_ptr]
    push 0
    push [io.heap_handle]
    call [HeapFree]
    ret
.open_fail_msg db "Could not open file.", 0
.size_fail_msg db "Could not get file size.", 0
.heap_fail_msg db "Could not allocate memory.", 0
.read_fail_msg db "Could not read file.", 0

io.save_file:
    call [GetProcessHeap]
    mov [io.heap_handle], eax
    push [ui.hwnd_textbox]
    call [GetWindowTextLength]
    inc eax                     ; make room for nullchar
    mov [io.file_size], eax
    push [io.file_size]
    push HEAP_ZERO_MEMORY
    push [io.heap_handle]
    call [HeapAlloc]
    mov [io.file_data_ptr], eax
    push [io.file_size]
    push [io.file_data_ptr]
    push [ui.hwnd_textbox]
    call [GetWindowText]

    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push CREATE_ALWAYS
    push NULL
    push 0
    push GENERIC_WRITE
    push ui.filename
    call [CreateFile]
    mov [io.file_handle], eax

    push NULL
    push io.num_bytes_read
    mov eax, [io.file_size]
    dec eax                     ; dont write nullchar
    push eax
    push [io.file_data_ptr]
    push [io.file_handle]
    call [WriteFile]

    push [io.file_handle]
    call [CloseHandle]

    push [io.file_data_ptr]
    push 0
    push [io.heap_handle]
    call [HeapFree]
    ret
