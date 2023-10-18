CONSOLE:DECLARE FUNCTION Q()
FUNCTION Q():A$="consoleZdeclare@function@qHI-*function@qHIZaD]B!B-*do-*c]aDõiùZifz@c@then@exit@do-*if@c]SS@then-*_aD[-*else-*_chrDHcMSRI[-*endifZinc@iZloop-*end@function"
DO
C=A${I}:IFZ C THEN EXIT DO
IF C=33 THEN
?A$;
ELSE
?CHR$(C-32);
ENDIF:INC I:LOOP
END FUNCTION