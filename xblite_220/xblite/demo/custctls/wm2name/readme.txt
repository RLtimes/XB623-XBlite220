
' WM2Name is a program which monitors all
' windows messages within a program.

'{----------------------------------------------------------------------------------------}
'{- To use WM2Name on a project:                                                         -}
'{- (1) IMPORT "wm2name"                                                                 -}
'{- (2) Add "ShowWM2Name ()" in CreateWindows                                            -}
'{- (3) Add "Msg2Name (hwnd, msg, wParam, lParam)" to window procedure to exam           -}
'{- (4) Add "DestroyWM2Name ()" to CleanUp                                               -}
'{-                                                                                      -}
'{- Note: Make sure the parameters for "Msg2Name" are identical to the window procedure. -}
'{- Also requires cmcs21.dll - CodeMax                                                   -}
'{----------------------------------------------------------------------------------------}

' Run the program testwm.x to see an example of how this
' program can be used. 