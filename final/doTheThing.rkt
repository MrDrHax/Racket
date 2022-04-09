#lang racket

(define (floatLoop toRead fileS out callback)
    (define (endLoop fileS out)
        (display "</span>" out)
        (callback fileS out)
    )
    (define (iloop fileS out)
        (cond
            [(char-numeric? (car fileS))
                (begin
                    (display (car fileS) out)
                    (iloop (cdr fileS) out)
                )
            ]
            [else fileS]
        )
    )

    (display toRead out)
    (if (char-numeric? (car fileS))
        (endLoop (iloop fileS out) out)
        (begin
            (display "<span class=\"error\">NEEDS NUMBER</span>" out)
            fileS
        )
    )
    
)

(define (intLoop toRead fileS out callback)
    (define (endLoop fileS out)
        (display "</span>" out)
        (callback fileS out)
    )
    (define (iloop fileS out)
        (cond
            [(char=? (car fileS) #\.) (floatLoop (car fileS) (cdr fileS) out callback)]
            [(char-numeric? (car fileS))
                (begin
                    (display (car fileS) out)
                    (iloop (cdr fileS) out)
                )
            ]
            [else fileS]
            
        )
    )

    (display "<span class=\"int\">" out)
    (display toRead out)
    (endLoop (iloop fileS out) out)
)

(define (stringLoop toRead fileS out initType callback)
    (define (endLoop fileS out)
        (display "</span>" out)
        (callback fileS out)
    )
    (define (iloop fileS out)
        (display (car fileS) out)
        (if (char=? (car fileS) #\") 
            (cdr fileS)
            (iloop (cdr fileS) out)
        )
    )

    (display initType out)
    (display toRead out)
    (endLoop (iloop fileS out) out)
)

(define (enterErrorState fileS out)
    (define (loop fileS out)
        (if (empty? fileS)
            (display "</span>" out)
            (begin
                (display (car fileS) out)
                (loop (cdr fileS) out)
            )
        )
    )

    (display "<span class=\"error\">" out)
    (loop fileS out)
    '()
)

(define (startArray toRead fileS out)
    (display "<span class=\"parentesis1\">" out)
    (display toRead out)
    (display "<br>" out)
    (display "</span>" out)

    (display "<div class=\"indent\">" out)

    ; make a newline
    (define (newLine fileS out returnTo)
        (display (car fileS) out)
        (display '<br> out)
        (returnTo (cdr fileS) out)
    )

    ; end the indent
    (define (endTag fileS out)
        (display '</div> out)
        (display "<span class=\"parentesis1\">" out)
        (display (car fileS) out)
        (display "<br>" out)
        (display "</span>" out)
        ; need to get out of loop while returning previous array
        (cdr fileS)
    )

    (define (validEndScout fileS out)
        (cond 
            ; if array is empry
            [(empty? fileS) (begin (display "<span class=\"error\"><br>/\\/\\ ERROR HERE /\\/\\<br></span></span>" out) '())]
            ; empty space
            [(char-whitespace? (car fileS)) (validEndScout (cdr fileS) out)]
            ; end array
            [(char=? (car fileS) '#\]) fileS]
            ; new element
            [(char=? (car fileS) '#\,) (newLine fileS out scout)]
            [else (enterErrorState fileS out)]
        )
    )

    ; go to next state
    (define (scout fileS out)
        (cond 
            ; if array is empry
            [(empty? fileS) (display "<span class=\"error\">NEEDS END ]</span></span>" out)]
            ; empty space
            [(char-whitespace? (car fileS)) (scout (cdr fileS) out)]
            ; new array
            [(char=? (car fileS) '#\[) (startArray (car fileS) (cdr fileS) out)]
            [(char=? (car fileS) '#\{) (startDict (car fileS) (cdr fileS) out)]
            ; end array
            [(char=? (car fileS) '#\]) (endTag fileS out)]
            ; new element
            [(char=? (car fileS) '#\,) (newLine fileS out scout)]
            ; string
            [(char=? (car fileS) '#\") (stringLoop (car fileS) (cdr fileS) out "<span class=\"string\">" validEndScout)]
            ; number
            [(char-numeric? (car fileS)) (intLoop (car fileS) (cdr fileS) out validEndScout)]
            [else (print 'error)]
        )
    )

    (define (internalLoop fileS out)
        (if (empty? fileS)
            '()
            (if (char=? (car fileS) '#\])
                (endTag fileS out)
                (internalLoop (validEndScout fileS out) out)
            )
        )
    )

    (internalLoop (scout fileS out) out)
)

(define (startDict toRead fileS out)
    (display "<span class=\"parentesis1\">" out)
    (display toRead out)
    (display "<br>" out)
    (display "</span>" out)

    (display "<div class=\"indent\">" out)

    ; make a newline
    (define (newLine fileS out returnTo)
        (display (car fileS) out)
        (display '<br> out)
        (returnTo (cdr fileS) out)
    )

    ; end the indent
    (define (endTag fileS out)
        (display '</div> out)
        (display "<span class=\"parentesis1\">" out)
        (display (car fileS) out)
        (display "<br>" out)
        (display "</span>" out)
        ; need to get out of loop while returning previous array
        (cdr fileS)
    )

    (define (validEndScout fileS out)
        (print (list 'end fileS))
        (cond 
            ; if array is empry
            [(empty? fileS) (begin (display "<span class=\"error\"><br>/\\/\\ ERROR HERE /\\/\\<br></span></span>" out) '())]
            ; empty space
            [(char-whitespace? (car fileS)) (validEndScout (cdr fileS) out)]
            ; end array
            [(char=? (car fileS) '#\}) fileS]
            ; new element
            [(char=? (car fileS) '#\,) (newLine fileS out getKey)]
            [else (enterErrorState fileS out)]
        )
    )

    ; go to next state
    (define (scout fileS out)
        (print (list 'scout fileS))
        (cond 
            ; if array is empry
            [(empty? fileS) (display "<span class=\"error\">NEEDS END }</span></span>" out)]
            ; empty space
            [(char-whitespace? (car fileS)) (scout (cdr fileS) out)]
            ; new array
            [(char=? (car fileS) '#\[) (startArray (car fileS) (cdr fileS) out)]
            [(char=? (car fileS) '#\{) (startDict (car fileS) (cdr fileS) out)]
            ; end dict
            [(char=? (car fileS) '#\}) (endTag fileS out)]
            ; new element
            [(char=? (car fileS) '#\,) (newLine fileS out getKey)]
            ; string
            [(char=? (car fileS) '#\") (stringLoop (car fileS) (cdr fileS) out "<span class=\"string\">" validEndScout)]
            ; number
            [(char-numeric? (car fileS)) (intLoop (car fileS) (cdr fileS) out validEndScout)]
            [else (print 'error)]
        )
    )

    (define (keyEnder fileS out)
        (cond 
            ; if array is empry
            [(empty? fileS) (display "<span class=\"error\">NEEDS END }</span></span>" out)]
            ; empty space
            [(char-whitespace? (car fileS)) (getKey (cdr fileS) out)]
            ; string
            [(char=? (car fileS) '#\:) (begin 
                (display " : " out)
                (scout (cdr fileS) out)
            )]
            ; no valid key here!
            [else (enterErrorState fileS out)]
        )
    )

    (define (getKey fileS out)
        (print (list 'key fileS))
        (cond 
            ; if array is empry
            [(empty? fileS) (display "<span class=\"error\">NEEDS END ]</span></span>" out)]
            ; empty space
            [(char-whitespace? (car fileS)) (getKey (cdr fileS) out)]
            ; string
            [(char=? (car fileS) '#\") (stringLoop (car fileS) (cdr fileS) out "<span class=\"key\">" keyEnder)]
            ; end dict should be valid
            [(char=? (car fileS) '#\}) (endTag fileS out)]
            ; no valid key here!
            [else (enterErrorState fileS out)]
        )
    )

    (define (internalLoop fileS out)
        (if (empty? fileS)
            '()
            (if (char=? (car fileS) '#\})
                (endTag fileS out)
                (internalLoop (validEndScout fileS out) out)
            )
        )
    )

    (internalLoop (getKey fileS out) out)
)

(define (start)
    (define out (open-output-file "output.html" #:exists 'update))

    (define (searchStart toRead fileS out)
        (cond 
            [(char=? toRead #\[) (startArray toRead fileS out)]
            [(char=? toRead #\{) (startDict toRead fileS out)]
            [else (searchStart (car fileS) (cdr fileS) out)]
        )
    )

    (define (startEntry fileS out)
        (searchStart (car fileS) (cdr fileS) out)
    )

    (display (file->string "./elements/base.html") out)
    (display "<p>" out)
    ; run the actual procedure here
    (startEntry (string->list (file->string "./input.json")) out)
    (display "</p></body></html>" out)
    (close-output-port out)
)

(start)
