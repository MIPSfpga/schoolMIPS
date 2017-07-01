

            .text

start:      move    $v0, $0
counter:    addiu   $v0, 1
            b       counter
