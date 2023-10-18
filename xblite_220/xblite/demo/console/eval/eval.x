'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' An expression evaluator by Steven Gunhouse
'
PROGRAM "eval"
CONSOLE
'IMPORT "xst"
'IMPORT "xma"
IMPORT "xma_s.lib"
'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION DOUBLE Eval (expr$)

FUNCTION Entry ()
	PRINT "Type an expression to evaluate"
	expr$ = INLINE$("> ")
	DO
		PRINT Eval (expr$)
		PRINT "Another? (Just press Enter to quit.)"
		expr$ = INLINE$("> ")
	LOOP WHILE expr$
	PRINT "Thanks for playing"
END FUNCTION
'
FUNCTION DOUBLE Eval (expr$)

	temp$ = UCASE$(expr$)
	len = LEN(expr$)
	char = 0
	nextVal = 0
	upperVal = 10
	DIM value#[upperVal]
	nextOp = 0
	upperOp = 20
	DIM op[upperOp]

FindObject:
	IF char >= len THEN GOTO ObjErr
	nextChar = temp${char}
	INC char
	SELECT CASE nextChar
	CASE ' ', '\t', '+'
		' Ignore whitespace and "+" as sign
		GOTO FindObject
	CASE '('
		op = 1
		GOSUB AddOp
		GOTO FindObject
	CASE '-'
		op = 4
		GOSUB AddOp
		GOTO FindObject
	CASE 'A'
		IF MID$(temp$, char, 3) = "ABS" THEN
			op = 8
			char = char + 2
			GOSUB AddOp
			GOTO Func
		END IF
		IF MID$(temp$, char, 4) = "ACOS" THEN
			op = 9
			char = char + 3
			GOSUB AddOp
			GOTO Func
		END IF
		IF MID$(temp$, char, 4) = "ASIN" THEN
			op = 10
			char = char + 3
			GOSUB AddOp
			GOTO Func
		END IF
		IF MID$(temp$, char, 4) = "ATAN" THEN
			op = 11
			char = char + 3
			GOSUB AddOp
			GOTO Func
		END IF
	CASE 'C'
		IF MID$(temp$, char, 3) = "COS" THEN
			op = 12
			char = char + 2
			GOSUB AddOp
			GOTO Func
		END IF
	CASE 'E'
		IF MID$(temp$, char, 3) = "EXP" THEN
			op = 13
			char = char + 2
			GOSUB AddOp
			GOTO Func
		END IF
		' Not EXP, presume E
		value# = $$E
		GOTO AddValue
	CASE 'L'
		IF MID$(temp$, char, 5) = "LOG10" THEN
			op = 15
			char = char + 4
			GOSUB AddOp
			GOTO Func
		END IF
		IF MID$(temp$, char, 3) = "LOG" THEN
			op = 14
			char = char + 2
			GOSUB AddOp
			GOTO Func
		END IF
	CASE 'P'
		IF MID$(temp$, char, 2) = "PI" THEN
			value# = $$PI
			INC char
			GOTO AddValue
		END IF
	CASE 'S'
		IF MID$(temp$, char, 4) = "SIGN" THEN
			op = 16
			char = char + 3
			GOSUB AddOp
			GOTO Func
		END IF
		IF MID$(temp$, char, 3) = "SIN" THEN
			op = 17
			char = char + 2
			GOSUB AddOp
			GOTO Func
		END IF
		IF MID$(temp$, char, 3) = "SQRT" THEN
			op = 18
			char = char + 3
			GOSUB AddOp
			GOTO Func
		END IF
	CASE 'T'
		IF MID$(temp$, char, 3) = "TAN" THEN
			op = 19
			char = char + 2
			GOSUB AddOp
			GOTO Func
		END IF
	CASE ELSE
		IF (nextChar >= '0') AND (nextChar <= '9') THEN GOTO ParseNumber
	END SELECT

ObjErr:
	RETURN ($$PNAN)

Func:
	' Look for parenthesis
	IF char >= len THEN GOTO ObjErr
	nextChar = temp${char}
	INC char
	SELECT CASE nextChar
	CASE ' ', '\t'
		' Ignore whitespace
		GOTO Func
	CASE '('
		op = 1
		GOSUB AddOp
		GOTO FindObject
	END SELECT
	GOTO ObjErr

ParseNumber:
	end = char
	dot = $$FALSE
	exp = 0
	done = $$FALSE
	DO UNTIL done
		IF end >= len THEN
			done = $$TRUE
			INC end
		ELSE
			nextChar = temp${end}
			INC end
			SELECT CASE nextChar
			CASE '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
				' Digit - fine
			CASE '.'
				' Decimal point
				IF dot THEN GOTO ObjErr
				dot = $$TRUE
			CASE 'D', 'E'
				' Exponent marker - check for sign
				IF exp THEN GOTO ObjErr
				IF (temp${end} = '+') OR (temp${end} = '-') THEN INC end
				exp = end - 1
			CASE ELSE
				done = $$TRUE
			END SELECT
		END IF
	LOOP
	IF exp THEN
		IF (end - exp > 3) OR (end == exp) THEN GOTO ObjErr
	END IF
	value# = DOUBLE(MID$(temp$, char, end - char))
	char = end - 1

AddValue:
	IF nextVal > upperVal THEN
		upperVal = upperVal + 2
		REDIM value#[upperVal]
	END IF
	value#[nextVal] = value#
	INC nextVal

FindOp:
	IF char >= len THEN
		' End of input string, evaluate all
		op = 0
		GOTO Pending
	END IF
	nextChar = temp${char}
	INC char
	SELECT CASE nextChar
	CASE ' ', '\t'
		' Ignore whitespace
		GOTO FindOp
	CASE ')'
		op = 1
		GOTO Pending
	CASE '+'
		op = 2
		GOTO Pending
	CASE '-'
		op = 3
		GOTO Pending
	CASE '*'
		IF MID$(temp$, char, 2) = "**" THEN
			op = 7
			INC char
			GOTO Pending
		END IF
		op = 5
		GOTO Pending
	CASE '/'
		op = 6
		GOTO Pending
	END SELECT

OpErr:
	RETURN ($$NNAN)

Pending:
	IF nextOp THEN
		SELECT CASE op[nextOp - 1]
		CASE 0
			' Shouldn't get here
			GOTO OpErr
		CASE 1
			IF op = 0 THEN GOTO OpErr ' No closing parenthesis
			IF op = 1 THEN
				DEC nextOp
				GOTO FindOp
			END IF
		CASE 2
			IF op <= 3 THEN
				IF nextVal >= 2 THEN
					DEC nextVal
					DEC nextOp
					value#[nextVal-1] = value#[nextVal-1] + value#[nextVal]
					GOTO Pending
				ELSE
					GOTO OpErr
				END IF
			END IF
		CASE 3
			IF op <= 3 THEN
				IF nextVal >= 2 THEN
					DEC nextVal
					DEC nextOp
					value#[nextVal-1] = value#[nextVal-1] - value#[nextVal]
					GOTO Pending
				ELSE
					GOTO OpErr
				END IF
			END IF
		CASE 4
			IF op <= 3 THEN
				IF nextVal THEN
					DEC nextOp
					value#[nextVal-1] = -value#[nextVal-1]
					GOTO Pending
				ELSE
					GOTO OpErr
				END IF
			END IF
		CASE 5
			IF op <= 6 THEN
				IF nextVal >= 2 THEN
					DEC nextVal
					DEC nextOp
					value#[nextVal-1] = value#[nextVal-1] * value#[nextVal]
					GOTO Pending
				ELSE
					GOTO OpErr
				END IF
			END IF
		CASE 6
			IF op <= 6 THEN
				IF nextVal >= 2 THEN
					DEC nextVal
					DEC nextOp
					value#[nextVal-1] = value#[nextVal-1] / value#[nextVal]
					GOTO Pending
				ELSE
					GOTO OpErr
				END IF
			END IF
		CASE 7
			IF op <= 6 THEN
				IF nextVal >= 2 THEN
					DEC nextVal
					DEC nextOp
					value#[nextVal-1] = value#[nextVal-1] ** value#[nextVal]
					GOTO Pending
				ELSE
					GOTO OpErr
				END IF
			END IF
		CASE 8
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = ABS(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 9
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Acos(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 10
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Asin(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 11
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Atan(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 12
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Cos(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 13
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Exp(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 14
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Log(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 15
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Log10(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 16
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = SIGN(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 17
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Sin(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 18
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Sqrt(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		CASE 19
			IF nextVal THEN
				DEC nextOp
				value#[nextVal-1] = Tan(value#[nextVal-1])
				GOTO Pending
			ELSE
				GOTO OpErr
			END IF
		END SELECT
	ELSE
		IF op = 1 THEN GOTO OpErr  ' Missing left parenthesis
	END IF
	' Done with pending ops
	IFZ op THEN RETURN (value#[0])
	IF op = 1 THEN GOTO FindOp
	GOSUB AddOp
	GOTO FindObject

SUB AddOp
	IF nextOp > upperOp THEN
		upperOp = upperOp + 5
		REDIM op[upperOp]
	END IF
	op[nextOp] = op
	INC nextOp
END SUB
END FUNCTION
END PROGRAM
