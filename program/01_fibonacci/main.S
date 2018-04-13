

            .text

start:      move    $t0, $0
            li      $t1, 1
            move    $v0, $t1

fibonacci:  addu    $t0, $t0, $t1
            move    $v0, $t0
            addu    $t1, $t0, $t1
            move    $v0, $t1
            beqz    $0,  fibonacci
