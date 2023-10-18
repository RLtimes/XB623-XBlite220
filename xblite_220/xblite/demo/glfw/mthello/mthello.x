 ' ========================================================================
 '  This is a small test application for GLFW.
 '  The program prints "Hello world!", using two threads.
 '
 '  Ported to XBLite by Michael McElligott 10/11/2002
 '  Mapei_@hotmail.com
 ' ========================================================================
 
CONSOLE

IMPORT "xst"
IMPORT "glfw"
IMPORT "kernel32"

DECLARE FUNCTION main ()
DECLARE FUNCTION HelloFun()


 ' ========================================================================
 '  main() - Main function (main thread)
 ' ========================================================================

FUNCTION main ()

     '  Initialise GLFW
    IFZ glfwInit() THEN RETURN 0
    
     '  Create thread
    thread = glfwCreateThread( &HelloFun(), NULL ) 

    PRINT "" ' commenting out this will reverse the order of the threads

     '  Print the rest of the message
    PRINT "..world!\n"
    
    FOR i=0 TO 10
    	PRINT STRING$(i)+" Thread 2 "
    NEXT i

     '  Wait for thread to die
    glfwWaitThread( thread, $$GLFW_WAIT ) 

     '  Terminate GLFW
    glfwTerminate() 
    
    Sleep (10000)
   
END FUNCTION 

 ' ========================================================================
 '  HelloFun() - Thread function
 ' ========================================================================

FUNCTION HelloFun()

     '  Print the first part of the message
    PRINT "Hello" 
    FOR i=0 TO 10
    	PRINT  STRING$(i)+" Thread 1"
    NEXT i
    
END FUNCTION

END PROGRAM