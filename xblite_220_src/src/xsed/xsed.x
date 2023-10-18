'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' XSED is a programmers editor for XBLite. It uses the Scintilla
' editor control and is based upon the PowerBasic editor SED by Jose Roca.
' (c) GPL 2005-2006 David SZAFRANSKI
' Send comments/bug reports to david.szafranski@wanadoo.fr

'
' ***** Versions *****
' v1.01
' - fixed multiple instance error, xsed task not exiting properly
' - fixed syntax error with functions ending in $
' v1.02
' - set environment vars PATH, LIB, INCLUDE in BuildActiveFile()
' v1.03
' - set environment var XBLDIR in BuildActiveFile()
' v1.04
' - recently used files menu is now popup menu with more MRUs available (see $$MAX_MRU)
' - recently used files now save their last position and bookmarks on exit
' - fixed bug in mru dropdown menu from toolbar open button
' - added popup menu to tab control
' - fixed error in creating autocompletion list (not correctly finding
'   typed functions, eg; ULONG XstRandom().
' v1.05 - 7 July 2005
' - fixed bug with syntax of ASM lines starting with ? character
' - fixed folding bugs, lines starting with GOTO label not parsed correctly
'   and CFUNCTION not parsed.
' - fixed ConsoleProc error in opening a *.dec file
' - fixed printing error when using print menu button
' - repaired errors in formatting SINGLE type vars; a != b! vs a! = b (exchanged != with <>).
' - fixed more MRU errors.
' - Added character map dialog from context menu
' - Added Xio functions as keywords
' v1.06 - 20 July 2005
' - fixed error in Find/Replace Dialogs wrt TAB & Enter Key events (hFind not valid in message pump)
' - added keyboard shortcut for closing console window - Ctrl+Shift+C
' - fixed error in GetHelp()
' v1.07 - 8 August 2005
' - made console window height smaller
' - another attempt at fixing mru files errors
' - modified Find/Replace dialogs to use comboboxes which display MRU search strings
' - added show/hide console window commands to window menu, now use Ctrl+Shift+S to show console
'   and Ctrl+Shift+H to hide/close console window
' - fixed print selection error
' - added printer options dialog to enable color printing mode options and magnification of text
' - fixed paste context menu bug
' v1.08 13 August 2005
' - find/replace dialog bug fix
' - modified xsed.rc to change find/replace combobox styles
' v1.09 16 August 2005
' - corrected display of exit app dialog box on WM_CLOSE.
' v1.10 28 October 2005
' - added *.asm to open file dialogs
' - added GoAsm Help to Help menu
' - fixed margin 1 line selection
' - added tools menu option, all files placed in \xblite\bin\tools folder will be added to the tools menu
' v1.11 29 November 2005
' - changed console font to courier new 9 pt
' - fixed bug in Start in Last Folder option
' - File>Command Prompt menu selection now opens Command console window in directory of currently open file
' - Command Prompt now has hot key of F7
' - new menu item File>Explore Here opens explorer in directory of currently open file
' - after highlighting a word, pressing F3 (find next) will find next instance of highlighted word
' - added default option checkboxes to Colors & Fonts Options dialog,
'     this allows one to make all code properties the same font,
'     font size, and back color as default values.
' v1.12 13 December 2005
' - added color syntax to .asm files
' v1.13 16 December 2005
' - added editor option to auto-uppercase keywords as they are typed
'     (but does NOT work if next character is tab)
' - library functions in Xst, Xsx, and Xio are no longer keywords
' v1.14 18 December 2005
' - updated asm keywords for GoAsm
' - auto-uppercase keywords mode now does not uppercase keywords within string or comment
' -   (but does NOT work if next character is tab or CRLF)
' v1.15 05 Jan 2006
' - updated keywords and asm keywords
' - added dockable splitter control to provide split window view between MDI window and console window
' - added search origin choices (From cursor & From the top) to the Find/Replace dialogs
' v1.16 03 March 2006
' - added compiler switch options to Compiler Options Dialog
'   these switch options are not saved to the ini file so must be set for each instance of xsed
' v1.17 13 May 2006
' - added hotkey Shift+F9 for Compile as Library menu item
' - replaced $$SEDVERSION with VERSION$()
' - modified status bar
' - provided error when trying to save an empty file
' - added filter for *.gid files found in \tools folder so they won't appear in Tools menu
' v1.18 11 August 2006
' - added filter for *.ini files for \tools folder
' - added 'clean' makefile option to compiler options dialog
' - fixed duplicate entries in pop-up function listing (due to duplicate static lib .dec files)
' - added 'Find in Files' text search based on "Fast File Search" code by Kevin Diggins
' v1.19 27 August 2006
' - block comment/uncomment now use ; for comment char in .s and .asm files
' - added 'View Assembly File' to the pop-up context menu. This will open corresponding .asm file and set position to same line in program.
' v1.20 28 August 2006
' - added ability to build and execute an active .asm file
' - goasm line errors reported in console window can be selected and will move cursor to error line in asm file
' - removed '?' as assembly line
' - '?' added as a keyword (= PRINT)
' - ASM added as a keyword
' - revised character map dialog
' - added message box builder
' - modified template menu code to be able to handle comments (#), separators (|), and single submenus (<, >).
'    See templates.xxx file.
' - added simple macro recording/playing feature, see macro menubar selection.
' - modified long string lines to use _ line extension
' v1.21 10 September 2006
' - added function treeview browser, use Ctrl+Shift+B to display function browser, Ctrl+Alt+B to hide it.
' - fixed several dialog box background colors
' - improved handling of Code functions: NewFunction, CloneFunction, ImportFunction
'
PROGRAM "xsed"
VERSION "Version 1.21"
'
IMPORT "xst"		     ' Standard library : required by most programs
IMPORT "xio"
IMPORT "gdi32"		   ' gdi32.dll
IMPORT "user32"		   ' user32.dll
IMPORT "kernel32"		 ' kernel32.dll
IMPORT "comctl32"		 ' comctl32.dll
IMPORT "xsx"
IMPORT "shell32"
IMPORT "comdlg32"		 ' comdlg32.dll
IMPORT "scilexer"
IMPORT "msvcrt"
IMPORT "ole32"
IMPORT "combocolor"
IMPORT "docksplitter"

TYPE PROC
	XLONG .WhatIsUp
	XLONG .WhatIsDown
	XLONG .UpLnNo
	XLONG .DnLnNo
	STRING * 40 .ProcName
END TYPE

TYPE SED_SavePos
	XLONG .Position		        		' Last position
	STRING * 255 .FileName				' File name
END TYPE

TYPE EditorOptionsType
	XLONG .UseTabs								' Use tabs instead of spaces
	XLONG .TabSize								' Size of tabs in characters
	XLONG .AutoIndent							' Use autoindentation
	XLONG .IndentSize							' Size of autoindentation in characters
	XLONG .LineNumbers						' Show line numbers
	XLONG .LineNumbersWidth				' Width in pixels of the line numbers column
	XLONG .Margin									' Show margin for folding symbols
	XLONG .MarginWidth						' Width in pixels of the folding margin
	XLONG .EdgeColumn							' Show a line indicating the edge of the line
	XLONG .EdgeWidth							' Edge limit (PB limit is 255 characters)
	XLONG .IndentGuides						' Show indentation guides
	XLONG .WhiteSpace							' Show white spaces as dots
	XLONG .EndOfLine							' Show end of line markers
	XLONG .Magnification					' Zoom ratio (+20/-20 points)
	XLONG .SyntaxHighlighting			' Use syntax highlighting
'	XLONG .CodeTips								' Show codetips
	XLONG .MaximizeMainWindow			' Maximize main window on startup
	XLONG .MaximizeEditWindows		' Maximize edit windows
	XLONG .AskBeforeExit					' Ask before exiting the editor
	XLONG .AllowMultipleInstances	' Allow multiple instances of the editor
	XLONG .TrimTrailingBlanks			' Trim trailing blanks
	XLONG .ShowProcedureName			' Show the procedure name
	XLONG .ShowCaretLine					' Show caret line
	XLONG .StartInLastFolder			' Start in last folder
	STRING * 1024 .LastFolder
	XLONG .ReloadFilesAtStartup		' Reload files at startup
	XLONG .BackupEditorFiles			' Backup files on save
	XLONG .UpperCaseKeywords			' As keywords are typed, they are auto-uppercased (except if followed by tab)
END TYPE

TYPE FoldingOptionsType
	XLONG .FoldingLevel						' Folding level (Keyword, procedure or none)
	XLONG .FoldingSymbol					' Folding symbol (arrow, plus/minus, circle, box tree)
END TYPE

TYPE SciColorsAndFontsType
	' Default
	XLONG .DefaultForeColor							' Default foreground color
	XLONG .DefaultBackColor							' Default background color
	STRING * 255 .DefaultFontName				' Default font name
	STRING * 255 .DefaultFontCharset		' Default font charset
	XLONG .DefaultFontSize							' Default font size in points
	XLONG .DefaultFontBold							' Use bold style
	XLONG .DefaultFontItalic						' Use italic style
	XLONG .DefaultFontUnderline					' Use underline style
	' Comments
	XLONG .CommentForeColor							' Comment's foreground color
	XLONG .CommentBackColor							' Comment's background color
	STRING * 255 .CommentFontName				' Comment's font name
	STRING * 255 .CommentFontCharset		' Comment's charset
	XLONG .CommentFontSize							' Comment's font size in points
	XLONG .CommentFontBold							' Use bold style
	XLONG .CommentFontItalic						' Use italic style
	XLONG .CommentFontUnderline					' Use underline style
	' Constants
	XLONG .ConstantForeColor						' Foreground color
	XLONG .ConstantBackColor						' Background color
	STRING * 255 .ConstantFontName			' Font's name
	STRING * 255 .ConstantFontCharset		' Charset
	XLONG .ConstantFontSize							' Font's size in points
	XLONG .ConstantFontBold							' Bold style
	XLONG .ConstantFontItalic						' Italic style
	XLONG .ConstantFontUnderline				' Underline style
	' Identifier
	XLONG .IdentifierForeColor					' Foreground color
	XLONG .IdentifierBackColor					' Background color
	STRING * 255 .IdentifierFontName		' Font's name
	STRING * 255 .IdentifierFontCharset	' Charset
	XLONG .IdentifierFontSize						' Font's size in points
	XLONG .IdentifierFontBold						' Bold style
	XLONG .IdentifierFontItalic					' Italic style
	XLONG .IdentifierFontUnderline			' Underline style
	' Keywords
	XLONG .KeywordForeColor							' Foreground color
	XLONG .KeywordBackColor							' Background color
	STRING * 255 .KeywordFontName				' Font's name
	STRING * 255 .KeywordFontCharset		' Charset
	XLONG .KeywordFontSize							' Font's size
	XLONG .KeywordFontBold							' Bold style
	XLONG .KeywordFontItalic						' Italic style
	XLONG .KeywordFontUnderline					' Underline style
	' Numbers
	XLONG .NumberForeColor							' Foreground color
	XLONG .NumberBackColor							' Background color
	STRING * 255 .NumberFontName				' Font's name
	STRING * 255 .NumberFontCharset			' Charset
	XLONG .NumberFontSize								' Font's size
	XLONG .NumberFontBold								' Bold style
	XLONG .NumberFontItalic							' Italic style
	XLONG .NumberFontUnderline					' Underline style
	' Line numbers
	XLONG .LineNumberForeColor					' Foreground color
	XLONG .LineNumberBackColor					' Background color
	STRING * 255 .LineNumberFontName		' Font's name
	STRING * 255 .LineNumberFontCharset	' Charset
	XLONG .LineNumberFontSize						' Font's size
	XLONG .LineNumberFontBold						' Bold style
	XLONG .LineNumberFontItalic					' Italic style
	XLONG .LineNumberFontUnderline			' Underline style
	' Operators
	XLONG .OperatorForeColor						' Foreground color
	XLONG .OperatorBackColor						' Background color
	STRING * 255 .OperatorFontName			' Font's name
	STRING * 255 .OperatorFontCharset		' Charset
	XLONG .OperatorFontSize							' Font's size
	XLONG .OperatorFontBold							' Bold style
	XLONG .OperatorFontItalic						' Italic style
	XLONG .OperatorFontUnderline				' Underline style
	' Strings
	XLONG .StringForeColor							' Foreground color
	XLONG .StringBackColor							' Background color
	STRING * 255 .StringFontName				' Font's name
	STRING * 255 .StringFontCharset			' Charset
	XLONG .StringFontSize								' Font's size
	XLONG .StringFontBold								' Bold style
	XLONG .StringFontItalic							' Italic style
	XLONG .StringFontUnderline					' Underline style
	' ASM inline
	XLONG .ASMForeColor									' Foreground color
	XLONG .ASMBackColor									' Background color
	STRING * 255 .ASMFontName						' Font's name
	STRING * 255 .ASMFontCharset				' Charset
	XLONG .ASMFontSize									' Font's size in points
	XLONG .ASMFontBold									' Bold style
	XLONG .ASMFontItalic								' Italic style
	XLONG .ASMFontUnderline							' Underline style
	' ASM FPU instruction
	XLONG .AsmFpuInstructionForeColor							' Foreground color
	XLONG .AsmFpuInstructionBackColor							' Background color
	STRING * 255 .AsmFpuInstructionFontName				' Font's name
	STRING * 255 .AsmFpuInstructionFontCharset		' Charset
	XLONG .AsmFpuInstructionFontSize							' Font's size in points
	XLONG .AsmFpuInstructionFontBold							' Bold style
	XLONG .AsmFpuInstructionFontItalic						' Italic style
	XLONG .AsmFpuInstructionFontUnderline					' Underline style
	' ASM register
	XLONG .AsmRegisterForeColor							' Foreground color
	XLONG .AsmRegisterBackColor							' Background color
	STRING * 255 .AsmRegisterFontName				' Font's name
	STRING * 255 .AsmRegisterFontCharset		' Charset
	XLONG .AsmRegisterFontSize							' Font's size in points
	XLONG .AsmRegisterFontBold							' Bold style
	XLONG .AsmRegisterFontItalic						' Italic style
	XLONG .AsmRegisterFontUnderline					' Underline style
	' ASM directive
	XLONG .AsmDirectiveForeColor						' Foreground color
	XLONG .AsmDirectiveBackColor						' Background color
	STRING * 255 .AsmDirectiveFontName			' Font's name
	STRING * 255 .AsmDirectiveFontCharset		' Charset
	XLONG .AsmDirectiveFontSize							' Font's size in points
	XLONG .AsmDirectiveFontBold							' Bold style
	XLONG .AsmDirectiveFontItalic						' Italic style
	XLONG .AsmDirectiveFontUnderline				' Underline style
	' ASM directive operand
	XLONG .AsmDirectiveOperandForeColor						' Foreground color
	XLONG .AsmDirectiveOperandBackColor						' Background color
	STRING * 255 .AsmDirectiveOperandFontName			' Font's name
	STRING * 255 .AsmDirectiveOperandFontCharset	' Charset
	XLONG .AsmDirectiveOperandFontSize						' Font's size in points
	XLONG .AsmDirectiveOperandFontBold						' Bold style
	XLONG .AsmDirectiveOperandFontItalic					' Italic style
	XLONG .AsmDirectiveOperandFontUnderline				' Underline style
	' ASM extended instruction
	XLONG .AsmExtendedInstructionForeColor						' Foreground color
	XLONG .AsmExtendedInstructionBackColor						' Background color
	STRING * 255 .AsmExtendedInstructionFontName			' Font's name
	STRING * 255 .AsmExtendedInstructionFontCharset		' Charset
	XLONG .AsmExtendedInstructionFontSize							' Font's size in points
	XLONG .AsmExtendedInstructionFontBold							' Bold style
	XLONG .AsmExtendedInstructionFontItalic						' Italic style
	XLONG .AsmExtendedInstructionFontUnderline				' Underline style
	' Caret
	XLONG .CaretForeColor								' Color of the caret
	' Edge
	XLONG .EdgeForeColor								' Edge's foreground color
	XLONG .EdgeBackColor								' Edge's background color
	' Fold
	XLONG .FoldForeColor								' Folding margin highlight color
	XLONG .FoldBackColor								' Folding margin background color
	' Fold open
	XLONG .FoldOpenForeColor						' Foreground color of the folding symbols for expanded functions
	XLONG .FoldOpenBackColor						' Background color of the folding symbols for expanded functions
	' Fold margin
	XLONG .FoldMarginForeColor					' Foreground color of the folding symbols for folded functions
	XLONG .FoldMarginBackColor					' Background color of the folding symbols for folded functions
	' Indent guides
	XLONG .IndentGuideForeColor					' Indent guide's foreground color
	XLONG .IndentGuideBackColor					' Indent guide's background color
	' Selection
	XLONG .SelectionForeColor						' Selection's foreground color
	XLONG .SelectionBackColor						' Selection's background color
	' Whitespace
	XLONG .WhitespaceForeColor					' White space's foreground color
	XLONG .WhitespaceBackColor					' White space's background color
	' Menus
	XLONG .SubMenuTextForeColor					' Submenu text foreground color
	XLONG .SubMenuTextBackColor					' Submenu text background color
	XLONG .SubMenuHiTextForeColor				' Submenu hughlighted text foreground color
	XLONG .SubMenuHiTextBackColor				' Submenu hughlighted text background color
	' Caret line
	XLONG .CaretLineBackColor						' Caret line background color
	' default style
	XLONG .AlwaysUseDefaultBackColor
	XLONG .AlwaysUseDefaultFont
	XLONG .AlwaysUseDefaultFontSize
END TYPE

TYPE CompilerOptionsType
	STRING * 255 .XBLPath					' XBLite compiler path
	XLONG .DisplayResults					' Show the compiler results
	XLONG .EnableLogFile					' Create the log file by the compiler
	XLONG .BeepOnCompletion				' Beep on completion
	STRING * 255 .DebugToolPath		' Debug tool path
END TYPE

' terminate app struct
TYPE TERMINFO
	ULONG .dwID
	ULONG .dwThread
END TYPE

TYPE TDLGDATA
	DLGTEMPLATE	.dltt
	USHORT	.menu
	USHORT	.class
	USHORT	.title
END TYPE

TYPE CHARMAPINFO
	STRING * 64 .font
	XLONG .fontsize
	XLONG .zoomfontsize
END TYPE

DECLARE FUNCTION Entry ()
DECLARE FUNCTION WndProc (hWnd, wMsg, wParam, lParam)
DECLARE FUNCTION InitGui ()
DECLARE FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION CreateWindows ()
DECLARE FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION MessageLoop ()
DECLARE FUNCTION CleanUp ()
DECLARE FUNCTION GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION CWIDESTRING$ (addr)
DECLARE FUNCTION InitializeKeywords ()
DECLARE FUNCTION Scintilla_SetOptions (pSci, fileName$)
DECLARE FUNCTION SciMsg (pSciWndData, wMsg, wParam, lParam)
DECLARE FUNCTION SED_SetCharset (pSci, Style, CharsetName$)
DECLARE FUNCTION SED_AppAlreadyRunning (szClassName$)
DECLARE FUNCTION SED_ProcessCommandLine (hWnd)
DECLARE FUNCTION GetEdit ()
DECLARE FUNCTION MdiGetActive (hWnd)
DECLARE FUNCTION SED_ReadWindowPlacement (hWnd)

DECLARE FUNCTION CodeProc (hWnd, wMsg, wParam, lParam)
DECLARE FUNCTION ChangeButtonsState ()
DECLARE FUNCTION DisableToolbarButtons ()
DECLARE FUNCTION GetColorOptions (SciColorsAndFontsType ColOpt)
DECLARE FUNCTION SED_LoadPreviousFileSet ()
DECLARE FUNCTION FileExist (FileSpec$)
DECLARE FUNCTION OpenThisFile (fn$)
DECLARE FUNCTION EnumMdiTitleToTab (szMdiCaption$)
DECLARE FUNCTION SED_MsgBox (hWnd, strMessage$, dwStyle, strCaption$)
DECLARE FUNCTION SED_GetFileTime (FileSpec$)
DECLARE FUNCTION SED_CodeFinder (fClearTree)
DECLARE FUNCTION SED_ResetCodeFinder ()
DECLARE FUNCTION CreateMdiChild (WndClass$, hClient, Title$, Style)
DECLARE FUNCTION CheckMenuOptions (EditorOptionsType EdOpt)
DECLARE FUNCTION SED_SaveWindowPlacement (hWnd)
DECLARE FUNCTION ShowLinCol ()
DECLARE FUNCTION InitComCtl32 (iccClasses)
DECLARE FUNCTION AppLoadBitmaps ()
DECLARE FUNCTION CreateToolBar (hWnd, lBmpSize)
DECLARE FUNCTION GetMenuTextAndBitmap (ItemId, @BmpNum)
DECLARE FUNCTION SED_CreateMenu (hWnd)
DECLARE FUNCTION SED_CreateAcceleratorTable ()
DECLARE FUNCTION CreateTabMdiCtl (hWnd, RECT rc)
DECLARE FUNCTION CreateComboboxFinder (hWnd, hToolbar, hFont)
DECLARE FUNCTION STRING GetTabName (nTab)
DECLARE FUNCTION STRING GetMdiWindowTextFromTabCaption (sTabCaption$)
DECLARE FUNCTION EnumTabToMdiHandle (sTabCaption$)
DECLARE FUNCTION GetDroppedFiles (hfInfo, @DroppedFiles$[])
DECLARE FUNCTION DrawMenu (lParam)
DECLARE FUNCTION GetMenuBmpHandle (BmpNum, nState)
DECLARE FUNCTION MeasureMenu (hWnd, lParam)
DECLARE FUNCTION DrawTabItem (lParam)
DECLARE FUNCTION CreateSciControl (hWnd)
DECLARE FUNCTION Sci_OnNotify (hWnd, wParam, lParam)
DECLARE FUNCTION STRING SpacesToTabs (InString$)
DECLARE FUNCTION ToggleFolding (LineNumber)
DECLARE FUNCTION SED_WithinProc (PROC tmpPROC)
DECLARE FUNCTION IsENDFUNCTION (line$)
DECLARE FUNCTION IsFUNCTION (line$, @fn$)
DECLARE FUNCTION EnumMdiTitleToTabRemove (szMdiCaption$)
DECLARE FUNCTION SaveFileDialog (hWnd, Caption$, @Filespec$, InitialDir$, Filter$, DefExtension$, Flags)
DECLARE FUNCTION GetFileExtension (fileName$, @file$, @ext$)
DECLARE FUNCTION SaveFile (hWnd, Ask)
DECLARE FUNCTION SetTabName (hTabCtrl, nTab, strName$)
DECLARE FUNCTION TabCtrl_GetCurSel (hWnd)
DECLARE FUNCTION MdiNext (hWndClient, hwndChild, fNext)
DECLARE FUNCTION InsertTabMdiItem (hTab, item, szTabText$)
DECLARE FUNCTION IsBinary (text$)
DECLARE FUNCTION IsAWordChar (ch)
DECLARE FUNCTION IsTypeCharacter (ch)
DECLARE FUNCTION IsADigit (ch)
DECLARE FUNCTION IsAWordStart (ch)
DECLARE FUNCTION IsOperator (ch)
DECLARE FUNCTION IsSpaceChar (ch)
DECLARE FUNCTION Colourise (hEdit, start, finish)
DECLARE FUNCTION ColouriseXBLDoc (hEdit, @doc$, start, lengthDoc, initStyle, @keyWords$[], @keyWords2$[])
DECLARE FUNCTION ColourSegHwnd (hWnd, start, finish, chAttr)
DECLARE FUNCTION ClassifyWord (hEdit, @doc$, start, finish, @keyWords$[])
DECLARE FUNCTION WordInList (word$, @list$[])
DECLARE FUNCTION IsStartOfLine (hEdit)
DECLARE FUNCTION FileOpen ()
DECLARE FUNCTION OpenFileDialog (hWnd, Caption$, Filespec$, InitialDir$, Filter$, DefExtension$, Flags)
DECLARE FUNCTION SED_SaveLoadedFilesPaths ()
DECLARE FUNCTION BlockComment ()
DECLARE FUNCTION BlockUncomment ()
DECLARE FUNCTION ChangeSelectedTextCase (fCase)
DECLARE FUNCTION GetCurrentLine ()
DECLARE FUNCTION ToggleAllFoldersBelow (LineNumber)
DECLARE FUNCTION FoldAllProcedures ()
DECLARE FUNCTION ExpandAllProcedures ()
DECLARE FUNCTION FoldXBLDoc (hEdit, start, finish, lineNumber)
DECLARE FUNCTION SED_ReplaceTabsWithSpaces ()
DECLARE FUNCTION SED_ReplaceSpacesWithTabs ()
DECLARE FUNCTION EnsureRangeVisible (posStart, posEnd, fEnforcePolicy)
DECLARE FUNCTION FoldChanged (line, levelNow, levelPrev)
DECLARE FUNCTION Expand (line, doExpand, force, visLevels, level)
DECLARE FUNCTION MdiCascade (hClient)
DECLARE FUNCTION MdiTile (hClient, How)
DECLARE FUNCTION MdiIconArrange (hClient)
DECLARE FUNCTION RestoreMainWindowDefaultSize (hWnd)
DECLARE FUNCTION STRING SearchForExePath ()
DECLARE FUNCTION STRING BrowseForFolder (hWnd, strTitle$, StartFolder$)
DECLARE FUNCTION BrowseForFolderProc (hWnd, wMsg, wParam, lParam)
DECLARE FUNCTION SED_SaveUntitledFile (hWnd, @szPath$)
DECLARE FUNCTION ReplaceFileExtension (@file$, ext$)
DECLARE FUNCTION ShellEx (command$, workDir$, output$, outputMode)
DECLARE FUNCTION NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION UnFoldXBLDoc (hEdit)
DECLARE FUNCTION TerminateApp (dwPID, dwTimeout)
DECLARE FUNCTION TerminateAppEnum (hwnd, lParam)
DECLARE FUNCTION TEXTRANGE GetSelection ()
DECLARE FUNCTION GetFileInfo (file$, @created$, @modified$, @bytes)
DECLARE FUNCTION CommandLineInputBoxProc (hwndDlg, msg, wParam, lParam)
DECLARE FUNCTION InsertTemplateCode (hWnd, id)
DECLARE FUNCTION GetTemplates (@name$[], @fn$[])
DECLARE FUNCTION GetWindowText$ (hWnd)
DECLARE FUNCTION HtmlHelp (hwndCaller, file$, command, dwData)
DECLARE FUNCTION WriteHelpFilePaths ()
DECLARE FUNCTION SED_GetTextRange (hEdit, minimum, maximum, @text$)
DECLARE FUNCTION SED_GetTextLines (hEdit, start, end, @text$)
DECLARE FUNCTION TrimTrailingTabsAndSpaces (@text$)
DECLARE FUNCTION SaveFileAsHtml ()
DECLARE FUNCTION RGBToHTMLHEX$ (rgb)
DECLARE FUNCTION CloseAllWindows ()
DECLARE FUNCTION GetHelp (hWnd)

DECLARE FUNCTION InitializeAsmKeywords (pSci)
DECLARE FUNCTION XSED_AboutBox (hWnd)
DECLARE FUNCTION ShowHTMLDlg (hwndParent, url$, x, y, w, h, resize, status, center)
DECLARE FUNCTION GetWordAtPosition (position, @word$)
DECLARE FUNCTION DrawLineStatic (hWnd, x1, y1, x2, y2, color)
DECLARE FUNCTION EnableAMenuItem (IDItem, val)
DECLARE FUNCTION ResetTreeBrowser ()

' ini file related functions
DECLARE FUNCTION STRING IniRead (sIniFile$, sSection$, sKey$, sDefault$)
DECLARE FUNCTION IniWrite (sIniFile$, sSection$, sKey$, sValue$)

' folding options dialog related functions
DECLARE FUNCTION FoldingOptionsDlgProc (hWnd, wMsg, wParam, lParam)
DECLARE FUNCTION ShowFoldingOptionsDialog (hParent)
DECLARE FUNCTION GetFoldingOptions (FoldingOptionsType FoldOpt)
DECLARE FUNCTION WriteFoldingOptions (FoldingOptionsType FoldOpt)

' go to line dialog related functions
DECLARE FUNCTION GotoLinePopupDlgProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION ShowGotoLinePopupDialog (hParent)

' button related functions
DECLARE FUNCTION SetCheckBox (hButton)
DECLARE FUNCTION IsChecked (hButton)
DECLARE FUNCTION UnCheckBox (hButton)

' editor options dialog functions
DECLARE FUNCTION EditorOptionsDlgProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION ShowEditorOptions (hParent)
DECLARE FUNCTION WriteEditorOptions (EditorOptionsType EdOpt)
DECLARE FUNCTION GetEditorOptions (EditorOptionsType EdOpt)

' compiler options dialog functions
DECLARE FUNCTION ShowCompilerOptions (hParent)
DECLARE FUNCTION CompilerOptionsDlgProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION WriteCompilerOptions (CompilerOptionsType CpOpt)
DECLARE FUNCTION GetCompilerOptions (CompilerOptionsType CpOpt)

' compile, build, and execute program functions
DECLARE FUNCTION CompileActiveFile (hWnd, fAsLib)
DECLARE FUNCTION BuildActiveFile (hWnd)
DECLARE FUNCTION ExecuteActiveFile (hWnd)

' tooltip functions
DECLARE FUNCTION SetTooltip (hWnd, tip$)
DECLARE FUNCTION NewTooltipControl (hWnd)

' find and replace dialog functions
DECLARE FUNCTION FindReplaceDialog (hWnd, wParam)
DECLARE FUNCTION FindReplaceMsg (hWnd, hFind, lParam)
DECLARE FUNCTION FindUpOrDown ()
DECLARE FUNCTION FRHookProc (hDlg, msg, wParam, lParam)

' recently used files functions
DECLARE FUNCTION STRING GetRecentFileName (idx)
DECLARE FUNCTION GetRecentFiles ()
DECLARE FUNCTION STRING OpenRecentFile (wParam)
DECLARE FUNCTION WriteRecentFile (hEdit, szPath$)
DECLARE FUNCTION WriteRecentFiles (OpenFName$)

' WndProc message functions
DECLARE FUNCTION OnClose ()
DECLARE FUNCTION OnCreate (hWnd, wParam, lParam)
DECLARE FUNCTION OnDestroy (hWnd, wParam, lParam)
DECLARE FUNCTION OnNotify (hWnd, wParam, lParam)
DECLARE FUNCTION OnSize (hWnd, wMsg, wParam, lParam)
DECLARE FUNCTION OnSysColorChange (hWnd, wParam, lParam)

' status bar functions
DECLARE FUNCTION ClearStatusbar ()
DECLARE FUNCTION CreateStatusbar (hWnd)
DECLARE FUNCTION StatusBar_SetPartsBySize (hStatus, sSizes$)

' printing functions
DECLARE FUNCTION PrintSetup (hWnd)
DECLARE FUNCTION Print (hWnd, showDialog)

' Code menu functions for adding/deleting functions
DECLARE FUNCTION CloneFunction (hWnd)
DECLARE FUNCTION InsertNewFunction (hWnd)
DECLARE FUNCTION DeleteFunction (hWnd)
DECLARE FUNCTION ImportFunction (hWnd)
DECLARE FUNCTION CloneFunctionInputBoxProc (hwndDlg, msg, wParam, lParam)
DECLARE FUNCTION NewFunctionInputBoxProc (hwndDlg, msg, wParam, lParam)
DECLARE FUNCTION ImportFunctionInputBoxProc (hwndDlg, msg, wParam, lParam)

' supporting functions used with SED_FormatRegion() & FormatCode()
DECLARE FUNCTION SED_FormatRegion (hWnd)
DECLARE FUNCTION IndentTheLine (@sourceLine$, @newLine$, fIndentComment, @indentCount)
DECLARE FUNCTION SplitOffComment (@sourceString$, @code$, @comment$)
DECLARE FUNCTION IsCharLiteral (@s$, pos)
DECLARE FUNCTION CalculateTheIndentAndOutputTheLine (@code$, @comment$, @newLine$, fIndentComment, @indentCount)
DECLARE FUNCTION WhiteSpaceTheLine$ (@line$)
DECLARE FUNCTION IsStringQuote (@s$, position)
DECLARE FUNCTION AddWhiteSpace$ (@line$)
DECLARE FUNCTION FindNextQuote (src$, index, style)
DECLARE FUNCTION FormatCode (@code$, fIndentComment)

' functions used for autocompletion lists
DECLARE FUNCTION AutoComplete ()
DECLARE FUNCTION GetFunctionDeclarations (@funcList$[])
DECLARE FUNCTION GetKeywordDeclarations (@kwList$[])
DECLARE FUNCTION GetActiveFileDeclarations (@activeList$[])
DECLARE FUNCTION GetAutoCompletionList (@completionList$[])
DECLARE FUNCTION GetMatchingList (@autoList$[], @match$, @matchList$[])
DECLARE FUNCTION CreateAutoCompletionString (@match$, @auto$)

' functions used with color options dialog
DECLARE FUNCTION ShowColorOptionsDialog (hParent)
DECLARE FUNCTION ColorOptionsDlgProc (hWnd, wMsg, wParam, lParam)
DECLARE FUNCTION FillFontSizeCombo (hWnd, fontName$)
DECLARE FUNCTION FillFontCombo (hWnd)
DECLARE FUNCTION EnumFontName (lfAddr, tmAddr, fontType, hWnd)
DECLARE FUNCTION SED_ColorsAndFontsChangeSelection (hWnd, curSelStr$)
DECLARE FUNCTION DrawFontCombo (hWnd, wParam, lParam)
DECLARE FUNCTION SED_ColorsAndFontsStoreSelection (hWnd, curSelStr$)
DECLARE FUNCTION WriteColorOptions (SciColorsAndFontsType ColOpt)
DECLARE FUNCTION SED_ChooseColor (hParent, defaultColor)
DECLARE FUNCTION SetFontExample (hWnd)

' listbox supporting functions
DECLARE FUNCTION Listbox_AddString (hListBox, @text$)
DECLARE FUNCTION Listbox_SetCurSel (hListBox, index)
DECLARE FUNCTION Listbox_GetCurSel (hListBox)
DECLARE FUNCTION STRING Listbox_GetText (hListBox, index)

' combobox supporting functions
DECLARE FUNCTION Combo_ResetContent (hComboBox)
DECLARE FUNCTION Combo_AddString (hComboBox, text$)
DECLARE FUNCTION Combo_SetCurSel (hComboBox, index)
DECLARE FUNCTION Combo_GetCurSel (hComboBox)
DECLARE FUNCTION STRING Combo_GetLbText (hComboBox, index)

' output console functions
DECLARE FUNCTION ClearConsole ()
DECLARE FUNCTION ConsoleProc (hWnd, wMsg, wParam, lParam)
DECLARE FUNCTION CopyOutputConsoleToClipboard ()
DECLARE FUNCTION HideConsole ()
DECLARE FUNCTION ParseErrorMsg (err$, @path$, @line, @msg$, @col)

' character map functions
DECLARE FUNCTION NewDialogBox (hWndParent, x, y, width, height, dlgProcAddr, initParam)
DECLARE FUNCTION CharMapProc (hwndDlg, uMsg, wParam, lParam)
DECLARE FUNCTION KBHookProc (code, wParam, lParam)

' printing options dialog functions
DECLARE FUNCTION ShowPrintingOptionsDialog (hWnd)
DECLARE FUNCTION PrintingOptionsProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION GetPrintingOptions ()
DECLARE FUNCTION WritePrintingOptions ()

' Find in Files functions
DECLARE FUNCTION ShowFindFilesControls (hWnd, fShow)
DECLARE FUNCTION StringSearch (s$, find$, fFullWords, @position)
DECLARE FUNCTION FindFile (dir$, fileMask$, fRecurse, find$)
DECLARE FUNCTION GIANT CalcFileSize (ULONG high, ULONG low)
DECLARE FUNCTION DoFileSearch (fileName$, find$)
DECLARE FUNCTION OnSearchNow (hWnd)

' Like() related functions
DECLARE FUNCTION Like        (string$, mask$)
DECLARE FUNCTION DoMatch     (stringAddr, maskAddr)
DECLARE FUNCTION IsDigit     (char)
DECLARE FUNCTION IsAlpha     (char)
DECLARE FUNCTION ParseRange  (p, @not, @start, @end, @count, @error)
DECLARE FUNCTION CheckRange  (char, start, end)
DECLARE FUNCTION DoEvents ()

' message box builder functions
DECLARE FUNCTION MsgBoxProc (hDlg, uMsg, wParam, lParam)
DECLARE FUNCTION MsgBoxButtonType (hDlg, ID)
DECLARE FUNCTION MsgBoxBuildString$ (hDlg, msg$, caption$, style)
DECLARE FUNCTION MsgBoxIcon (hDlg, ID)
DECLARE FUNCTION MsgBoxButtonDefault (hDlg, ID)
DECLARE FUNCTION MsgBoxBehavior (hDlg, ID)
DECLARE FUNCTION MsgBoxType (hDlg, ID)
DECLARE FUNCTION MsgBoxToClipBoard (hDlg)
DECLARE FUNCTION MsgBoxTry (hDlg)

' macro related functions
DECLARE FUNCTION RecordMacroCommand (SCNotification scn)
DECLARE FUNCTION OnMacro (command$, params$)
DECLARE FUNCTION MacroAppend (params$)
DECLARE FUNCTION MacroIterate ()
DECLARE FUNCTION MacroGetParams (msg$, @message, @wParam, @lParam, @text$)
DECLARE FUNCTION MacroInit ()
DECLARE FUNCTION MacroCheckMenu ()

' treeview related functions
DECLARE FUNCTION AddTreeViewItem (hwndCtl, hParent, label$, idxImage, idxSelectedImage, hInsertAfter, data)
DECLARE FUNCTION GetTreeViewSelection (hwndCtl)
DECLARE FUNCTION GetTreeViewItemText (hwndCtl, hItem, @text$)
DECLARE FUNCTION SelectTreeViewItem (hTree, hItem)
DECLARE FUNCTION GetTreeViewNextItem (hTree, index)
DECLARE FUNCTION GetTreeViewItemData (hwndCtl, hItem, @data)
DECLARE FUNCTION DeleteAllTreeViewItems (hTree)
DECLARE FUNCTION FindTreeViewNode (hTree, hItem, @text$)
DECLARE FUNCTION SetTreeViewItemData (hTree, hItem, data)


$$PROGNAME 		= "XSED"
$$SEDCAPTION 	= "XSED"
$$MAIL 				= "david.szafranski@wanadoo.fr"
$$XBLITESITE 	= "http://perso.wanadoo.fr/xblite/"

$$MAX_MRU = 20  ' maximum number of recently used files
$$INITIAL_CONSOLE_HEIGHT = 120  ' height of console window on startup

' Like() function constants
$$LIKE_TRUE		=	1
$$LIKE_FALSE	=	0
$$LIKE_ABORT	=	-1

$$LIKE_BAD_RANGE_FORMAT = -2
$$LIKE_MISSING_BRACKET = -3
$$LIKE_INVALID_RANGE = -4

' terminate app constants
$$TA_FAILED = 0
$$TA_SUCCESS_CLEAN = 1
$$TA_SUCCESS_KILL = 2
$$TA_SUCCESS_16 = 3

 ' ShellEx() output modes
$$Default = 0
$$Console = -1
$$BUFSIZE = 0x1000

' Identifiers

$$ID_TOOLBAR = 3100		    	' Toolbar
$$IDC_EDIT = 3101		      	' Edit control
$$IDC_CODEFINDER = 3102			' Code finder combobox
$$IDC_TABMDI = 3103		    	' Tab control
$$IDC_LISTBOX = 3104		  	' Listbox control in Output Console
$$IDC_SPLITTER = 3105				' Splitter

$$IDC_SEARCH_STATIC1 = 3106	' Search window control
$$IDC_SEARCH_STATIC2 = 3107	' Search window control
$$IDC_SEARCH_STATIC3 = 3108	' Search window control
$$IDC_SEARCH_STATIC4 = 3109	' Search window control
$$IDC_SEARCH_EDIT1 = 3110		' Search window control
$$IDC_SEARCH_EDIT2 = 3111		' Search window control
$$IDC_SEARCH_EDIT3 = 3112		' Search window control
$$IDC_SEARCH_BUTTON1 = 3113	' Search window control
$$IDC_SEARCH_STATIC0 = 3114	' Search window control
$$IDC_SEARCH_STATIC5 = 3115	' Search window control
$$IDC_SEARCH_BUTTON2 = 3116	' Search window control
$$IDC_SEARCH_BUTTON3 = 3117	' Search window control
$$IDC_SEARCH_BUTTON4 = 3118	' Search window control
$$IDC_SEARCH_BUTTON5 = 3119	' Search window control


$$IDC_SEARCH_FIRST = $$IDC_SEARCH_STATIC1
$$IDC_SEARCH_LAST = 3130

$$IDC_TREEBROWSER = 3140

' FILE
$$IDM_FILEHEADER = 3200		  ' File

$$IDM_NEW = 3202		        ' New file
$$IDM_OPEN = 3203		        ' Open file
$$IDM_REOPEN = 3204		      ' Reopen file
$$IDM_SAVE = 3205		        ' Save
$$IDM_SAVEAS = 3206		      ' Save As
$$IDM_PRINTERSETUP = 3207		' Printer setup
$$IDM_PRINTPREVIEW = 3208		' Printer preview
$$IDM_PRINT = 3209		      ' Print file
$$IDM_CLOSEFILE = 3210		  ' Close file
$$IDM_CLOSEALL = 3211		    ' Close all files
$$IDM_REFRESH = 3214		    ' Refresh
$$IDT_PRINT = 3215		      ' Print without dialog
$$IDM_OPENASMFILE = 3216		' Open asm file

$$IDM_RECENTSEPARATOR = 3259		' Separator
$$IDM_EXPLOREHERE = 3260		' Open Explorer to currently opened file's folder
$$IDM_DOS = 3261		        ' Command prompt
$$IDM_EXIT = 3262		        ' Exit
$$IDM_RECENTSTART = 4000

' EDIT
$$IDM_EDITHEADER = 3300		      ' Edit
$$IDM_UNDO = 3301		            ' Undo
$$IDM_REDO = 3302		            ' Redo
$$IDM_CLEAR = 3303		          ' Clear
$$IDM_CLEARALL = 3304		        ' Clear all
$$IDM_CUT = 3305		            ' Cut
$$IDM_COPY = 3306		            ' Copy
$$IDM_PASTE = 3307		          ' Paste
$$IDM_SELECTALL = 3308		      ' Select all
$$IDM_COMMENT = 3309		        ' Block comment
$$IDM_UNCOMMENT = 3310		      ' Block uncomment

$$IDM_LINEDELETE = 3312		      ' Delete line
$$IDM_AUTOCOMPLETE = 3313		    ' Autocomplete
$$IDM_TEMPLATES = 3314		      ' Templates
$$IDM_HTMLCODE = 3315		        ' Save As Html
$$IDM_SELTOUPPERCASE = 3316		  ' Convert to selected text to upper case
$$IDM_SELTOLOWERCASE = 3317		  ' Convert to selected text to lower case

$$IDM_FORMATREGION = 3319		    ' Format selected text

$$IDM_BLOCKINDENT = 3321		    ' Block indent
$$IDM_BLOCKUNINDENT = 3322		  ' Block unindent
$$IDM_GOTOBEGINPROC = 3323		  ' Goto to the begining of the procedure or function
$$IDM_GOTOENDPROC = 3324		    ' Goto to the end of the procedure or function
$$IDM_GOTOBEGINTHISPROC = 3325	' Goto to the begining of the procedure or function
$$IDM_GOTOENDTHISPROC = 3326		' Goto to the end of the procedure or function
$$IDM_REPLSPCWITHTABS = 3327		' Replace spaces with tabs
$$IDM_REPLTABSWITHSPC = 3328		' Replace tabs with spaces

' SEARCH
$$IDM_SEARCHHEADER = 3350		    ' Search menu
$$IDM_FIND = 3351		            ' Find
$$IDM_FINDNEXT = 3352		        ' Find next
$$IDM_REPLACE = 3353		        ' Replace
$$IDM_GOTOLINE = 3354		        ' Go to line...
$$IDM_TOGGLEBOOKMARK = 3355		  ' Toggle bookmark
$$IDM_NEXTBOOKMARK = 3356		    ' Next bookmark
$$IDM_PREVIOUSBOOKMARK = 3357		' Previous bookmark
$$IDM_DELETEBOOKMARKS = 3358		' Delete bookmarks

$$IDM_EXPLORER = 3360		        ' Explorer
$$IDM_WINDOWSFIND = 3361		    ' Windows Find
$$IDM_FINDINFILES = 3362		    ' Find in files
$$IDM_FINDBACKWARDS = 3363		  ' Find backwards
$$IDM_FINDUPORDOWN = 3364		    ' Find up or down

' CODE
$$IDM_CODEHEADER = 3600         ' Code menu
$$IDM_NEWFUNCTION  = 3601       ' Insert new function
$$IDM_DELETEFUNCTION = 3602     ' Delete function
'$$IDM_RENAMEFUNCTION = 3603     ' Rename function
$$IDM_CLONEFUNCTION = 3604      ' Copy function
$$IDM_IMPORTFUNCTION = 3605     ' Import function from a *.x, *.xl, or *.xbl file
$$IDM_MSGBOXBUILDER = 3606		  ' Message box builder
$$IDM_TEMPLATESTART = 6000 		  ' starting template file from templates.xxx
$$IDM_TEMPLATESMAX = 6999

' MACRO
$$IDM_MACROHEADER = 3800
$$IDM_MACRORECORD = 3801
$$IDM_MACROSTOPRECORD = 3802
$$IDM_MACROPLAY = 3803

' RUN
$$IDM_RUNHEADER = 3430		  ' Run menu
$$IDM_COMPILE = 3431		    ' Compile program using xblite
$$IDM_BUILD = 3432		      ' Build executable by running nmake
' $$IDM_COMPILEANDDEBUG = 3433 ' Compile and debug
$$IDM_COMMANDLINE = 3435		' Command line
$$IDM_EXECUTE = 3436		    ' Execute file
$$IDM_COMPILE_LIB = 3437    ' Compile program as DLL library

' VIEW
$$IDM_VIEWHEADER = 3400		  ' View menu
$$IDM_TOGGLE = 3401		      ' Toggle function
$$IDM_TOGGLEALL = 3402		  ' Toggle function and all the functions below
$$IDM_FOLDALL = 3403		    ' Fold all functions
$$IDM_EXPANDALL = 3404		  ' Expand all functions
$$IDM_USETABS = 3405		    ' Use tabs
$$IDM_AUTOINDENT = 3406		  ' Auto indentation
$$IDM_SHOWLINENUM = 3407		' Show line numbers
$$IDM_SHOWMARGIN = 3408		  ' Show margin
$$IDM_SHOWINDENT = 3409		  ' Show indentation guides
$$IDM_SHOWEOL = 3410		    ' Show end of line
$$IDM_ZOOMIN = 3411		      ' Zoom in
$$IDM_ZOOMOUT = 3412		    ' Zoom out
$$IDM_SHOWSPACES = 3413		  ' Show spaces as dots
$$IDM_SHOWEDGE = 3414		    ' Show edge
$$IDM_CVEOLTOCRLF = 3415		' Convert end of line characters to $CRLF
$$IDM_CVEOLTOCR = 3416		  ' Convert end of line characters to $CR
$$IDM_CVEOLTOLF = 3417		  ' Convert end of line characters to $LF
$$IDM_SHOWPROCNAME = 3418		' Show sub/function name in the codefinder

' WINDOW
$$IDM_WINDOWHEADER = 3450		' Window menu
$$IDM_TILEH = 3451		      ' Tile windows horizontally
$$IDM_TILEV = 3452		      ' Tile windows vertically
$$IDM_CASCADE = 3453		    ' Cascade windows
$$IDM_ARRANGE = 3454		    ' Arrange icons
$$IDM_CLOSEWINDOWS = 3455		' Close all
$$IDM_SWITCHWINDOW = 3456		' Switch window
$$IDM_RESTOREWSIZE = 3457		' Restore main window size
$$IDM_SHOWCONSOLE = 3458		' Show console window
$$IDM_HIDECONSOLE = 3459		' Hide console window
$$IDM_SHOWTREEBROWSER = 3460		' Show treeview window
$$IDM_HIDETREEBROWSER = 3461		' Hide treeview window


' OPTIONS
$$IDM_OPTIONSHEADER = 3500			' Options menu
$$IDM_EDITOROPT = 3501		    	' Editor options
$$IDM_COMPILEROPT = 3502		  	' Compiler options
$$IDM_COLORSOPT = 3503		    	' Colors and fonts
$$IDM_TOOLSOPT = 3504		      	' Tools options
$$IDM_FOLDINGOPT = 3505		    	' Folding options
$$IDM_PRINTINGOPT = 3506				' Printing options

' TOOLS
$$IDM_TOOLSHEADER = 3520				' Tools menu
$$IDM_TOOLSTART   = 4100				' Tool folder index

$$IDM_PBCOMBR = 3522						' PB Com Browser
$$IDM_TYPELIBBR = 3523					' TypeLib Browser
$$IDM_DLGEDITOR = 3524					' Dialog Editor
$$IDM_IMGEDITOR = 3525					' Image Editor
$$IDM_RCEDITOR = 3526						' Resource Editor
$$IDM_VISDES = 3527							' Visual Designer
$$IDM_TBBDES = 3528							' Toolbar Designer
$$IDM_POFFS = 3529							' Poffs
$$IDM_PBWINSPY = 3530						' PBWinSpy

$$IDM_XBLHTMLHELP = 3531				' XBLite HTML Help
$$IDM_XSEDHTMLHELP = 3532   		' XSED HTML Help
$$IDM_WIN32HELP = 3533					' Win32 Help
$$IDM_RCHELP = 3534							' Resource Help
$$IDM_GOASMHELP = 3535					' GoAsm Help

$$IDM_CODEC = 3536							' Code analyzer
$$IDM_INCLEAN = 3537						' InClean
$$IDM_COPYCAT = 3538						' CopyCat
' $$IDM_DEBUGTOOL = 3539        ' Debug tool *** not used
' $$IDM_CODETIPSBUILDER = 3540	' Codetips builder *** not used
$$IDM_CODEKEEPER = 3541		      ' Code keeper
$$IDM_CALCULATOR = 3542		      ' Calculator
$$IDM_CHARMAP = 3543		        ' Character map
$$IDM_CODETYPEBUILDER = 3544		' Codetype builder

$$IDM_MORETOOLS = 3546		      ' More tools

' HELP
$$IDM_HELPHEADER = 3550	 				' Help menu
$$IDM_HELP = 3551		     				' XBLite HTML Help
$$IDM_ABOUT = 3552		   				' About box

$$IDM_XBLSITE = 3554		 				' XBLite site
$$IDM_MSDNSITE = 3555		 				' MSDN site
$$IDM_GOOGLE = 3556		   				' Google
$$IDM_MAIL = 3557      	 				' Email Us

$$IDM_GOTOSELPROC = 3702		    ' Goto to the function/procedure that has the same name that the word under the caret
$$IDM_GOTOLASTPOSITION = 3703		' Goto to the last saved position

' CONSOLE WINDOW CONTEXT
$$IDM_CONSOLE_JUMP = 3900
$$IDM_CONSOLE_COPY = 3901
$$IDM_CONSOLE_COPYLINE = 3902
$$IDM_CONSOLE_CLEAR = 3903
$$IDM_CONSOLE_HIDE = 3904

' TREEVIEW CONTEXT
$$IDM_TREE_UPDATE = 3920	' Update treeview control
$$IDM_TREE_HIDE = 3921		' Hide treeview control

$$ID_ProcNull = 0
$$ID_ProcStart = 1
$$ID_ProcEnd = 2

' ImageList Draw Style Constants.
$$IMG_DIS = 0		' Disabled
$$IMG_NOR = 1		' Normal
$$IMG_HOT = 2		' Selected

' Sometimes, the text ovewrites the accelerator key name
' or goes too close. In these cases, we need to add an
' extra width to the text to separe them.
$$OMENU_EXTRAWIDTH = 60			' Extra width in pixels
$$OMENU_CHECKEDICON = 106		' Identifier of the checked icon
'
$$IDBO_EDITOR_HELP = 5100
$$IDCO_USETABS = 5101
$$IDCO_CBTABSIZE = 5102
$$IDCO_AUTOINDENT = 5103
$$IDCO_CBINDENTSIZE = 5104
$$IDCO_LINENUMBERS = 5105
$$IDCO_LINENUMBERSWIDTH = 5106
$$IDCO_MARGIN = 5107
$$IDCO_MARGINWIDTH = 5108
$$IDCO_EDGECOLUMN = 5109
$$IDCO_EDGEWIDTH = 5110
$$IDCO_INDENTGUIDES = 5111
$$IDCO_WHITESPACE = 5112
$$IDCO_ENDOFLINE = 5113
$$IDCO_DEFAULT_UPPERCASE = 5114
$$IDCO_DEFAULT_MIXEDCASE = 5115
$$IDCO_DEFAULT_LOWERCASE = 5116
$$IDCO_KEYWORD_UPPERCASE = 5117
$$IDCO_KEYWORD_MIXEDCASE = 5118
$$IDCO_KEYWORD_LOWERCASE = 5119
$$IDCO_BUDDY = 5120
$$IDCO_MAGNIFICATION = 5121
$$IDCO_SYNTAXHIGH = 5122
$$IDCO_UPPERCASEKEYWORDS = 5123
$$IDCO_MAXMAINWINDOW = 5124
$$IDCO_MAXEDITWINDOWS = 5125
$$IDCO_ASKBEFOREEXIT = 5126
$$IDCO_ALLOWMULTINST = 5127
$$IDCO_AUTOCONSTRUCT = 5128
$$IDCO_AUTOCOMPLTYPES = 5129
$$IDCO_TRIMTRAILBLANKS = 5130
$$IDCO_SHOWPROCNAME = 5131
$$IDCO_SHOWCARETLINE = 5132
$$IDCO_STARTINLASTFOLDER = 5133
$$IDCO_RELOADFILESATSTARTUP = 5134
$$IDCO_BACKUPEDITORFILES = 5137

$$IDBO_COMPILER_HELP = 5200
$$IDCO_XBLPATH = 5203
$$IDBO_XBLPATH = 5204

$$IDCO_DISPRES = 5217
$$IDCO_ENABLELOG = 5218
$$IDCO_BEEPONEND = 5219
$$IDCO_DEBUGTOOLPATH = 5220
$$IDBO_DEBUGTOOLPATH = 5221
$$IDCO_LIB = 5222
$$IDCO_BC = 5223
$$IDCO_RC = 5224
$$IDCO_LOG = 5225
$$IDCO_MAK = 5226
$$IDCO_RCF = 5227
$$IDCO_BAT = 5228
$$IDCO_NOWINMAIN = 5229
$$IDCO_NODLLMAIN = 5230
$$IDCO_M4 = 5231
$$IDCO_CLEAN = 5232

$$IDC_FOLDINGLEVELNONE = 5400
$$IDC_FOLDINGLEVELKEYWORD = 5401
$$IDC_FOLDINGLEVELSUB = 5402
$$IDC_FOLDINGSYMBOLARROW = 5403
$$IDC_FOLDINGSYMBOLPLUSMINUS = 5404
$$IDC_FOLDINGSYMBOLCIRCLE = 5405
$$IDC_FOLDINGSYMBOLBOXTREE = 5406
$$IDL_FOLDINGHELP = 5407

$$IDC_LBCOLSEL = 5501
$$IDC_CBFORECOLOR = 5502
$$IDC_CBBACKCOLOR = 5503
$$IDC_CBFONTS = 5504
$$IDC_CBCHARSET = 5505
$$IDC_CBFONTSIZE = 5506
$$IDK_BOLD = 5507
$$IDK_ITALIC = 5508
$$IDK_UNDERLINE = 5509
$$IDB_USERFORECOLOR = 5510
$$IDB_USERBACKCOLOR = 5511
$$IDC_STATICEXAMPLE = 5512
$$IDK_USEDEFAULTCOLOR = 5513
$$IDK_USEDEFAULTFONT  = 5514
$$IDK_USEDEFAULTSIZE  = 5515

' printing options dialog control ids
$$IDR_PRINTINGNORMAL = 602
$$IDR_PRINTINGLIGHT  = 603
$$IDR_PRINTINGBW = 604
$$IDR_PRINTINGCOLORW = 605
$$IDCB_PRINTINGMAGNIFICATION = 606
$$IDCO_PRINTINGMAGVALUE = 607
'
' format code constants
$$CR_CR = "\r\r"
$$CRLF_CRLF = "\r\n\r\n"
$$DOUBLE_QUOTE = "\""
$$SINGLE_QUOTE = "\'"
$$SINGLE_SPACE = " "
$$DOUBLE_SPACE = "  "
$$SPACE_OR_QUOTE = " \""
$$TAB_OR_SPACE = "\t "
$$TAB_TAB = "\t\t"
$$TAB = "\t"
$$DQ = 1
$$SQ = 2
'
$$STATE_OPERATOR = 0
$$STATE_KEYWORD = 1
$$STATE_BRACKET = 2
$$STATE_NUMBER = 3
$$STATE_SEPARATOR = 4
'
' HTML Help Constants
$$HH_DISPLAY_TOPIC = 0x0            ' WinHelp equivalent
$$HH_DISPLAY_TOC = 0x1              ' WinHelp equivalent
$$HH_DISPLAY_INDEX = 0x2            ' WinHelp equivalent
$$HH_DISPLAY_SEARCH = 0x3           ' WinHelp equivalent
$$HH_SET_WIN_TYPE = 0x4
$$HH_GET_WIN_TYPE = 0x5
$$HH_GET_WIN_HANDLE = 0x6
$$HH_SYNC = 0x9
$$HH_ADD_NAV_UI = 0xA               ' not currently implemented
$$HH_ADD_BUTTON = 0xB               ' not currently implemented
$$HH_GETBROWSER_APP = 0xC           ' not currently implemented
$$HH_KEYWORD_LOOKUP = 0xD           ' WinHelp equivalent
$$HH_DISPLAY_TEXT_POPUP = 0xE       ' display string resource id
                                    ' or text in a popup window
                                    ' value in dwData
$$HH_HELP_CONTEXT = 0xF             ' display mapped numeric
$$HH_CLOSE_ALL = 0x12               ' WinHelp equivalent
$$HH_ALINK_LOOKUP = 0x13            ' ALink version of
                                    ' HH_KEYWORD_LOOKUP
$$HH_SET_GUID = 0x1A                ' For Microsoft Installer -- dwData is a pointer to the GUID string

$$FIND_FROM_CURSOR = 0x403
$$FIND_FROM_TOP    = 0x404

$$TWO32 = 4294967296

' message box dialog control IDs
$$MBB_CAPTION = "Message Box Builder v1.00"
$$TABGROUP = 196608  ' $$WS_GROUP OR $$WS_TABSTOP
$$ID_ICON = 2000

$$MBB_START = 1001
'-- edit boxes
$$editCAPTION      = 1001
$$editMESSAGE      = 1002

'-- checkbox button
$$cbtnCONSTANTS    = 1003
$$cbtnClassLong    = 1004

'-- radio (option) buttons
$$rbtnOK           = 1005
$$rbtnOKCANCEL     = 1006
$$rbtnA_R_I        = 1007
$$rbtnYESNO        = 1008
$$rbtnYESNOCANCEL  = 1009
$$rbtnRETRYCANCEL  = 1010

$$rbtnINFORMATION  = 1011
$$rbtnEXCLAMATION  = 1012
$$rbtnQUESTION     = 1013
$$rbtnERROR        = 1014
$$rbtnNO_ICON      = 1015
$$rbtnUSER_ICON    = 1016

$$rbtnDefButton1   = 1017
$$rbtnDefButton2   = 1018
$$rbtnDefButton3   = 1019

$$rbtnDefStyle1    = 1020
$$rbtnDefStyle2    = 1021
$$rbtnDefStyle3    = 1022

$$ViewMsgBoxText   = 1023
'-- label
$$lblRESULT        = 1024

'-- push buttons
$$pbtnTEST         = 1025
$$pbtnSAVE         = 1026
$$pbtnEXIT         = 1027

'-- type
'$$rbtnMB           = 1028
$$rbtnMSB          = 1029
'$$rbtnMSBEX        = 1030
$$rbtnMSBI         = 1031
$$lblEx            = 1032

$$grpCAPTION			= 1033
$$grpICON					= 1034
$$grpMESSAGE			= 1035
$$grpBUTTONS      = 1036
$$grpDEFAULT			= 1037
$$grpBEHAVIOR			= 1038
$$grpRESULT				= 1039
$$grpTYPE					= 1040
$$grpCODE					= 1041

$$MBB_END = 1041
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()
'	XioCreateConsole (title$, 250)		  ' create console, if console is not wanted, comment out this line
	InitGui ()		                      ' initialize program and libraries
	IF CreateWindows () THEN GOTO cleanup		' create main windows and other child controls
	MessageLoop ()		                  ' the message loop
cleanup:
	CleanUp ()		                      ' unregister all window classes
'	XioFreeConsole ()		                ' free CONSOLE
END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION WndProc (hWnd, wMsg, wParam, lParam)

	SHARED hInst				' instance handle
	SHARED IniFile$			' ini file name
	SHARED keywords$		' xblite keywords list
	SHARED hWndMain			' main window handle
	SHARED fMaximize		' maximize MDI windows
	SHARED hFont				' standard font
	SHARED hWndClient
	SHARED hAccel
	SHARED SciColorsAndFontsType scf
	SHARED fClosed
	SHARED hCodeFinder
	SHARED ShowProcedureName
	SHARED CommandLine$
	SHARED hMenu
	SHARED hWndConsole
	SHARED hSplitter
	SHARED fShowSearchControls
	SHARED fShowTreeBrowser
	CompilerOptionsType CpOpt
	CHARMAPINFO cmi
	RECT rc
	POINT pt

	STATIC hFocus						' Handle of the control that has the focus

	SHARED FINDREPLACE fr		' FINDREPLACE structure
	SHARED szFindText$			' Text to search
	SHARED szReplText$			' Replace text
	SHARED szLastFind$			' Last word found
	SHARED dwFindMsg				' Registered message handle
	SHARED startPos					' Starting position
	SHARED endPos						' Ending position
	SHARED curPos						' Current position
	SHARED findFlags				' Find flags
	SHARED updown						' Search direction
	SHARED hFind						' Find/Replace dialog box handle
	SHARED tools$[]					' List of files in \tools folder

	' Clipboard
	STATIC ClipFormat				' Registered clipboard format

	' macro recording flag
	SHARED fRecording

	TEXTRANGE txtrg					' Text range

	COPYDATASTRUCT cds
	MEASUREITEMSTRUCT mis

	$BIT0 = BITFIELD (1, 0)

	SELECT CASE wMsg

		CASE $$WM_DRAWITEM :
			' The ownerdrawn menu needs to redraw
			IFZ wParam THEN				' If identifier is 0, message was sent by a menu
				DrawMenu (lParam)		' Draw the menu
				RETURN ($$TRUE)
			END IF

		CASE $$WM_MEASUREITEM :						' Get menu item size
			IFZ wParam THEN									' A menu is calling
				MeasureMenu (hWnd, lParam)		' Do all work in separate Sub
				RETURN ($$TRUE)
			END IF

		CASE $$WM_NCACTIVATE :
			' Save the handle of the control that has the focus
			IFZ wParam THEN hFocus = GetFocus ()

		CASE $$WM_SETFOCUS :
			' Post a message to set the focus later, since some
			' Window's actions can steal it if we set it here
			IF hFocus THEN
				PostMessageA (hWnd, $$WM_USER + 999, hFocus, 0)
				hFocus = 0
			END IF

		CASE $$WM_USER + 999 :
			' Set the focus and show the line and column in the status bar
			IF wParam THEN SetFocus (wParam)
			ShowLinCol ()		' Show line and column
			RETURN

		CASE $$WM_USER + 1000 :
			' Process the command line
			' command line can contain a filename to load plus
			' an initial line number to go to.
			SED_ProcessCommandLine (hWnd)
			RETURN

		CASE $$WM_CREATE :
			' Process this message in the OnCreate function
			RETURN OnCreate (hWnd, wParam, lParam)

		CASE $$WM_SIZE :
			' Process this message in the OnSize function
			OnSize (hWnd, wMsg, wParam, lParam)
			RETURN

'		CASE $$WM_CTLCOLORSTATIC :
			' wParam is handle of control's display context (hDC)
			' lParam is handle of control
'			IF lParam = GetDlgItem(hWnd, $$IDC_SEARCH_STATIC5) THEN
'				RETURN SetColor (RGB(0, 0, 0), RGB(210, 210, 210), wParam, lParam) 
'			END IF

		CASE $$WM_NOTIFY :
			' Process this message in the OnNotify function
			OnNotify (hWnd, wParam, lParam)
			RETURN

		CASE $$WM_DESTROY :
			' Process this message in the OnDestroy function
			OnDestroy (hWnd, wParam, lParam)
			RETURN

		CASE $$WM_DROPFILES :
			' Retrieve the dropped file names
			' Open a new edit window for each of them
			IF GetDroppedFiles (wParam, @DroppedFiles$[]) THEN
				FOR i = 0 TO UBOUND (DroppedFiles$[])
					IF DroppedFiles$[i] THEN OpenThisFile (DroppedFiles$[i])
				NEXT
			END IF
			SED_CodeFinder ($$TRUE)
			RETURN

		CASE $$WM_SYSCOLORCHANGE :
			' Process this message in the OnSysColorChange function
			RETURN OnSysColorChange (hWnd, wParam, lParam)

		CASE $$WM_DRAWITEM :
			' The ownerdraw menu needs to redraw
			IFZ wParam THEN				' If identifier is 0, message was sent by a menu
				DrawMenu (lParam)		' Draw the menu
				RETURN ($$TRUE)
			END IF

			IF wParam = $$IDC_TABMDI THEN
				DrawTabItem (lParam)
				RETURN ($$TRUE)
			END IF

		CASE $$WM_MEASUREITEM :						' Get menu item size

			IFZ wParam THEN									' A menu is calling
				MeasureMenu (hWnd, lParam)		' Do all work in separate Sub
				RETURN ($$TRUE)
			END IF

		CASE $$WM_COPYDATA :
			' this processes command line data
			' and opens file to line position
			RtlMoveMemory (&cds, lParam, SIZE (cds))
			strTxt$ = NULL$ (cds.cbData)
			RtlMoveMemory (&strTxt$, cds.lpData, cds.cbData)
			strTxt$ = TRIM$ (CSIZE$ (strTxt$))
			IF strTxt$ THEN
				OpenThisFile (strTxt$)
				endPos = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
				SendMessageA (GetEdit (), $$SCI_GOTOLINE, endPos, 0)
				SendMessageA (GetEdit (), $$SCI_GOTOLINE, cds.dwData, 0)
				SED_CodeFinder ($$TRUE)		' Reset the code FUNCTION finder combobox content
			END IF

		CASE $$WM_CLOSE :
			' Quit the application
			IF XLONG (IniRead (IniFile$, "Editor options", "AskBeforeExit", "")) = $$BST_CHECKED THEN
				IF MessageBoxA (hWnd, &"Are you sure you want to quit the application?   ", &" Exit", $$MB_YESNO OR $$MB_ICONQUESTION OR $$MB_APPLMODAL) = $$IDYES THEN
					OnClose ()
					DestroyWindow (hWnd)
				END IF
			ELSE
				OnClose ()
				DestroyWindow (hWnd)
			END IF
			RETURN

'		CASE $$WM_ENDSESSION :
'			OnClose ()
'			SED_MsgBox (hWnd, "WM_ENDSESSION", 0, "WndProc msg")
'			RETURN

		CASE $$WM_COMMAND :
		  ctrlID = LOWORD (wParam)

			' most recently used files menu
		  SELECT CASE TRUE
		    CASE (ctrlID >= $$IDM_RECENTSTART + 1) && (ctrlID <= $$IDM_RECENTSTART + 1 + $$MAX_MRU) :
          OpenRecentFile (wParam)
          ClearConsole ()
          HideConsole ()
          RETURN

			' tools menu
				CASE (ctrlID >= $$IDM_TOOLSTART) && (ctrlID <= $$IDM_TOOLSTART + UBOUND(tools$[]) + 1) :
					szPath$ = tools$[ctrlID-$$IDM_TOOLSTART]
' 				Add command line options? Command line dialog?
					ShellExecuteA ($$HWND_DESKTOP, &"open", &szPath$, 0, 0, $$SW_SHOWNORMAL)
					RETURN

			' templates menu
				CASE (ctrlID >= $$IDM_TEMPLATESTART) && (ctrlID <= $$IDM_TEMPLATESMAX) :
					InsertTemplateCode (hWnd, LOWORD (wParam))
					SED_CodeFinder ($$TRUE)		' update codefinder and treebrowser controls
					RETURN
			END SELECT



			SELECT CASE ctrlID

				CASE $$IDCANCEL      : IF GetFocus () = hCodeFinder THEN SetFocus (GetEdit ()) ' Return the focus to the edit control

				' FILE menu (or toolbar button)
				CASE $$IDM_NEW       : IF fMaximize THEN ws = $$WS_MAXIMIZE
					                     hMdi = CreateMdiChild ("XSED32", hWndClient, "", ws)
															 SED_ResetCodeFinder ()		' Reset the code FUNCTION finder combobox content
															 ResetTreeBrowser ()			' Clear the treeview function browser
'					                     ClearConsole ()
					                     HideConsole ()
					                     ShowWindow (hMdi, $$SW_SHOW)
					                     RETURN

				CASE $$IDM_OPEN      : hMdi = FileOpen ()
'                              ClearConsole ()
                               HideConsole ()
				CASE $$IDM_SAVE      : SaveFile (hWnd, $$FALSE)
													     ChangeButtonsState ()
				CASE $$IDM_SAVEAS    : SaveFile (hWnd, $$TRUE)
														   ChangeButtonsState ()
				CASE $$IDM_HTMLCODE  : SaveFileAsHtml ()           ' Convert to HTML
				CASE $$IDM_CLOSEFILE : SendMessageA (MdiGetActive (hWndClient), $$WM_CLOSE, 0, 0)
					                     ChangeButtonsState ()
															 SED_CodeFinder($$TRUE)

				CASE $$IDM_CLOSEALL  :		' close all files
					DO WHILE MdiGetActive (hWndClient)
						ret = SendMessageA (MdiGetActive (hWndClient), $$WM_CLOSE, 0, 0)
						IFZ fClosed THEN RETURN
					LOOP
					SED_ResetCodeFinder ()
					ResetTreeBrowser ()

				CASE $$IDM_EXPLOREHERE: ' open explorer to current file's folder
					f$ = GetWindowText$ (MdiGetActive (hWndClient))
					IF f$ THEN
						path$ = ""
						XstDecomposePathname(f$, @path$, "", "", "", "")
						IF path$ THEN ShellExecuteA ($$HWND_DESKTOP, &"explore", &path$, 0, 0, $$SW_SHOWNORMAL)
					END IF

				CASE $$IDM_DOS       : ' open command window in current file's folder
					f$ = GetWindowText$ (MdiGetActive (hWndClient))
					XstGetEnvironmentVariable ("COMSPEC", @cmd$)
					IF f$ THEN
						path$ = ""
						XstDecomposePathname(f$, @path$, "", "", "", "")
						IF cmd$ THEN
							IF path$ THEN
								drive$ = LEFT$ (path$) + ": & cd "    ' cmd.exe /K d: & cd d:\\xblite
								param$ = " /K " + drive$ + path$
							END IF
						END IF
					END IF

					IF cmd$ THEN
						IF param$ THEN
							ShellExecuteA (0, &"open", &cmd$, &param$, NULL, $$SW_SHOWNORMAL)
						ELSE
							ShellExecuteA (0, &"open", &cmd$, NULL, NULL, $$SW_SHOWNORMAL)
						END IF
					END IF

				CASE $$IDM_REFRESH   : f$ = GetWindowText$ (MdiGetActive (hWndClient))
					                     IF f$ THEN OpenThisFile (f$)

        CASE $$IDM_RECENTSTART : GetRecentFiles ()

				CASE $$IDM_EXIT :
					' Quit the application
					SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
					RETURN

'					IF XLONG (IniRead (IniFile$, "Editor options", "AskBeforeExit", "")) = $$BST_CHECKED THEN
'						IF MessageBoxA (hWnd, &"Are you sure you want to quit the application?   ", &" Exit", $$MB_YESNO OR $$MB_ICONQUESTION OR $$MB_APPLMODAL) = $$IDYES THEN
'							SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
'						END IF
'					ELSE
'						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
'					END IF
'					RETURN

				CASE $$IDM_MAIL     : szText$ = "mailto:" + $$MAIL
					                    ShellExecuteA (NULL, &"open", &szText$, NULL, NULL, $$SW_SHOWNORMAL)

				' EDIT menu
				CASE $$IDM_UNDO     : SendMessageA (GetEdit (), $$SCI_UNDO, 0, 0)
                              ChangeButtonsState ()
				CASE $$IDM_REDO     : SendMessageA (GetEdit (), $$SCI_REDO, 0, 0)
                              ChangeButtonsState ()
				CASE $$IDM_CLEAR    : SendMessageA (GetEdit (), $$SCI_CLEAR, 0, 0)
				CASE $$IDM_CLEARALL : SendMessageA (GetEdit (), $$SCI_CLEARALL, 0, 0)
				CASE $$IDM_CUT      : SendMessageA (GetEdit (), $$SCI_CUT, 0, 0)
				CASE $$IDM_COPY     : SendMessageA (GetEdit (), $$SCI_COPY, 0, 0)
				CASE $$IDM_PASTE    : SendMessageA (GetEdit (), $$SCI_PASTE, 0, 0)
                              ChangeButtonsState ()

				CASE $$IDM_LINEDELETE     : SendMessageA (GetEdit (), $$SCI_LINEDELETE, 0, 0)
				CASE $$IDM_SELECTALL      : SendMessageA (GetEdit (), $$SCI_SELECTALL, 0, 0)
				CASE $$IDM_BLOCKINDENT    : SendMessageA (GetEdit (), $$SCI_TAB, 0, 0)
				CASE $$IDM_BLOCKUNINDENT  : SendMessageA (GetEdit (), $$SCI_BACKTAB, 0, 0)
				CASE $$IDM_COMMENT        : BlockComment ()
				CASE $$IDM_UNCOMMENT      : BlockUncomment ()

				CASE $$IDM_FORMATREGION   : SED_FormatRegion (hWnd)		' Format selected text

				CASE $$IDM_SELTOUPPERCASE : ChangeSelectedTextCase (1)		' Convert selected text to upper case
				CASE $$IDM_SELTOLOWERCASE : ChangeSelectedTextCase (2)		' Convert selected text to lower case

				' SEARCH menu
				CASE $$IDM_FIND, $$IDM_REPLACE : hFind = FindReplaceDialog (hWnd, wParam)

				CASE $$IDM_FINDBACKWARDS : updown = 0
					SendMessageA (hWnd, $$WM_COMMAND, $$IDM_FINDUPORDOWN, 0)
					RETURN

				CASE $$IDM_FINDNEXT : updown = $$FR_DOWN
					SendMessageA (hWnd, $$WM_COMMAND, $$IDM_FINDUPORDOWN, 0)
					RETURN

				CASE $$IDM_FINDUPORDOWN : FindUpOrDown ()

				CASE $$IDM_GOTOLINE : IF GetEdit () THEN ShowGotoLinePopupDialog (hWnd)

				CASE $$IDM_TOGGLEBOOKMARK :
					fMark = SendMessageA (GetEdit (), $$SCI_MARKERGET, GetCurrentLine (), 0)
					IF fMark{$BIT0} THEN
						SendMessageA (GetEdit (), $$SCI_MARKERDELETE, GetCurrentLine (), 0)
					ELSE
						SendMessageA (GetEdit (), $$SCI_MARKERADD, GetCurrentLine (), 0)
					END IF

				CASE $$IDM_NEXTBOOKMARK :
					fMark = 0
					fMark = SET (fMark, $BIT0)
					nLine = SendMessageA (GetEdit (), $$SCI_MARKERNEXT, GetCurrentLine () + 1, fMark)
					IF nLine > -1 THEN
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, nLine, 0)
					ELSE
						nLine = SendMessageA (GetEdit (), $$SCI_MARKERNEXT, 0, fMark)
						IF nLine > -1 THEN
							SendMessageA (GetEdit (), $$SCI_GOTOLINE, nLine, 0)
						END IF
					END IF

				CASE $$IDM_PREVIOUSBOOKMARK :
					fMark = 0
					' BIT SET fMark, 0
					fMark = SET (fMark, $BIT0)
					nLine = SendMessageA (GetEdit (), $$SCI_MARKERPREVIOUS, GetCurrentLine () - 1, fMark)
					IF nLine > -1 THEN
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, nLine, 0)
					ELSE
						nLine = SendMessageA (GetEdit (), $$SCI_GETLINECOUNT, 0, 0)
						nLine = SendMessageA (GetEdit (), $$SCI_MARKERPREVIOUS, nLine - 1, fMark)
						IF nLine > -1 THEN
							SendMessageA (GetEdit (), $$SCI_GOTOLINE, nLine, 0)
						END IF
					END IF

				CASE $$IDM_DELETEBOOKMARKS : SendMessageA (GetEdit (), $$SCI_MARKERDELETEALL, 0, 0)

				' CASE $$IDM_FILEFIND        : FileFindPopupDialog (hWnd)         ' Find files popup dialog
				CASE $$IDM_EXPLORER : XstGetCurrentDirectory (@curdir$)		' Explorer
					ShellExecuteA ($$HWND_DESKTOP, &"explore", &curdir$, 0, 0, $$SW_SHOWNORMAL)

				CASE $$IDM_WINDOWSFIND : XstGetCurrentDirectory (@curdir$)
					ShellExecuteA ($$HWND_DESKTOP, &"find", &curdir$, 0, 0, $$SW_SHOWNORMAL)

				' Show Find in Files controls
				CASE $$IDM_FINDINFILES :
					GetClientRect (hWnd, &rc)
					fShowSearchControls = $$TRUE
					ShowFindFilesControls (hWnd, fShowSearchControls)
					SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, MAKELONG (rc.right, rc.bottom))
'					SetFocus (GetDlgItem (hWnd, $$IDC_SEARCH_BUTTON2))
'					PostMessageA (hWnd, $$WM_NEXTDLGCTL, GetDlgItem (hWnd, $$IDC_SEARCH_BUTTON2), 1)

				' Hide Find in Files controls
				CASE $$IDC_SEARCH_BUTTON3 :
					GetClientRect (hWnd, &rc)
					fShowSearchControls = $$FALSE
					ShowFindFilesControls (hWnd, fShowSearchControls)
					SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, MAKELONG (rc.right, rc.bottom))

				' Search Now button for Find in Files
				CASE $$IDC_SEARCH_BUTTON1 : OnSearchNow (hWnd)

				' Search - Browse for Folder button
				CASE $$IDC_SEARCH_BUTTON2 : searchFolder$ = BrowseForFolder (hWnd, "Choose directory to search", "")
																		IF searchFolder$ THEN SetWindowTextA (GetDlgItem (hWnd, $$IDC_SEARCH_EDIT1), &searchFolder$)

				' CODE menu
				CASE $$IDM_NEWFUNCTION    :
					IF InsertNewFunction (hWnd) THEN SED_CodeFinder($$TRUE)

				CASE $$IDM_DELETEFUNCTION :
					IF DeleteFunction (hWnd) THEN SED_CodeFinder($$TRUE)

'				CASE $$IDM_RENAMEFUNCTION :

				CASE $$IDM_CLONEFUNCTION  :
					IF CloneFunction (hWnd) THEN SED_CodeFinder($$TRUE)

				CASE $$IDM_IMPORTFUNCTION :
					IF ImportFunction (hWnd) THEN SED_CodeFinder($$TRUE)

				' MACRO menu
				CASE $$IDM_MACRORECORD:
					IF GetEdit() THEN
						fRecording = $$TRUE
						MacroInit ()
						SendMessageA (GetEdit(), $$SCI_STARTRECORD, 0, 0)
						MacroCheckMenu()
					END IF

				CASE $$IDM_MACROSTOPRECORD :
					IF GetEdit() THEN
						SendMessageA (GetEdit(), $$SCI_STOPRECORD, 0, 0)
						fRecording = $$FALSE
						MacroCheckMenu()
					END IF

				CASE $$IDM_MACROPLAY :
					IFZ fRecording THEN
						MacroCheckMenu()
						OnMacro ("run", "")
					END IF


				' VIEW menu
				CASE $$IDM_TOGGLE     : ToggleFolding (GetCurrentLine ())
				CASE $$IDM_TOGGLEALL  : ToggleAllFoldersBelow (GetCurrentLine ())
				CASE $$IDM_FOLDALL    : FoldAllProcedures ()
				CASE $$IDM_EXPANDALL  : ExpandAllProcedures ()

				CASE $$IDM_ZOOMIN     : SendMessageA (GetEdit (), $$SCI_ZOOMIN, 0, 0)
				CASE $$IDM_ZOOMOUT    : SendMessageA (GetEdit (), $$SCI_ZOOMOUT, 0, 0)

				CASE $$IDM_USETABS :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_USETABS, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_USETABS, $$MF_UNCHECKED)
						SendMessageA (GetEdit (), $$SCI_SETUSETABS, $$FALSE, 0)
						IniWrite (IniFile$, "Editor options", "UseTabs", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_USETABS, $$MF_CHECKED)
						SendMessageA (GetEdit (), $$SCI_SETUSETABS, $$TRUE, 0)
						IniWrite (IniFile$, "Editor options", "UseTabs", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_AUTOINDENT :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_AUTOINDENT, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_AUTOINDENT, $$MF_UNCHECKED)
						IniWrite (IniFile$, "Editor options", "AutoIndent", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_AUTOINDENT, $$MF_CHECKED)
						IniWrite (IniFile$, "Editor options", "AutoIndent", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_SHOWLINENUM :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_SHOWLINENUM, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_SHOWLINENUM, $$MF_UNCHECKED)
						SendMessageA (GetEdit (), $$SCI_SETMARGINTYPEN, 0, $$SC_MARGIN_NUMBER)
						SendMessageA (GetEdit (), $$SCI_SETMARGINWIDTHN, 0, 0)
						IniWrite (IniFile$, "Editor options", "LineNumbers", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_SHOWLINENUM, $$MF_CHECKED)
						SendMessageA (GetEdit (), $$SCI_SETMARGINTYPEN, 0, $$SC_MARGIN_NUMBER)
						hr = XLONG (IniRead (IniFile$, "Editor options", "LineNumbersWidth", ""))
						IFZ hr THEN hr = 50
						SendMessageA (GetEdit (), $$SCI_SETMARGINWIDTHN, 0, hr)
						IniWrite (IniFile$, "Editor options", "LineNumbers", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_SHOWMARGIN :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_SHOWMARGIN, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_SHOWMARGIN, $$MF_UNCHECKED)
						SendMessageA (GetEdit (), $$SCI_SETMARGINTYPEN, 2, $$SC_MARGIN_SYMBOL)
						SendMessageA (GetEdit (), $$SCI_SETMARGINWIDTHN, 2, 0)
						IniWrite (IniFile$, "Editor options", "Margin", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_SHOWMARGIN, $$MF_CHECKED)
						SendMessageA (GetEdit (), $$SCI_SETMARGINTYPEN, 2, $$SC_MARGIN_SYMBOL)
						mw = XLONG (IniRead (IniFile$, "Editor options", "MarginWidth", ""))
						IFZ mw THEN mw = 20
						SendMessageA (GetEdit (), $$SCI_SETMARGINWIDTHN, 2, mw)
						IniWrite (IniFile$, "Editor options", "Margin", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_SHOWINDENT :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_SHOWINDENT, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_SHOWINDENT, $$MF_UNCHECKED)
						SendMessageA (GetEdit (), $$SCI_SETINDENTATIONGUIDES, $$FALSE, 0)
						IniWrite (IniFile$, "Editor options", "IndentGuides", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_SHOWINDENT, $$MF_CHECKED)
						SendMessageA (GetEdit (), $$SCI_SETINDENTATIONGUIDES, $$TRUE, 0)
						IniWrite (IniFile$, "Editor options", "IndentGuides", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_SHOWEOL :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_SHOWEOL, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_SHOWEOL, $$MF_UNCHECKED)
						SendMessageA (GetEdit (), $$SCI_SETVIEWEOL, $$FALSE, 0)
						IniWrite (IniFile$, "Editor options", "EndOfLine", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_SHOWEOL, $$MF_CHECKED)
						SendMessageA (GetEdit (), $$SCI_SETVIEWEOL, $$TRUE, 0)
						IniWrite (IniFile$, "Editor options", "EndOfLine", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_SHOWSPACES :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_SHOWSPACES, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_UNCHECKED)
						SendMessageA (GetEdit (), $$SCI_SETVIEWWS, $$SCWS_INVISIBLE, 0)
						IniWrite (IniFile$, "Editor options", "WhiteSpace", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_CHECKED)
						SendMessageA (GetEdit (), $$SCI_SETVIEWWS, $$SCWS_VISIBLEALWAYS, 0)
						IniWrite (IniFile$, "Editor options", "WhiteSpace", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_SHOWEDGE :
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_SHOWEDGE, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_SHOWEDGE, $$MF_UNCHECKED)
						SendMessageA (GetEdit (), $$SCI_SETEDGEMODE, $$EDGE_NONE, 0)
						IniWrite (IniFile$, "Editor options", "EdgeColumn", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_SHOWEDGE, $$MF_CHECKED)
						SendMessageA (GetEdit (), $$SCI_SETEDGEMODE, $$EDGE_LINE, 0)
						ew = XLONG (IniRead (IniFile$, "Editor options", "EdgeWidth", ""))
						IFZ ew THEN
							ew = 255
							IniWrite (IniFile$, "Editor options", "EdgeWidth", STRING$ (ew))
						END IF
						SendMessageA (GetEdit (), $$SCI_SETEDGECOLUMN, ew, 0)
						SendMessageA (GetEdit (), $$SCI_SETEDGECOLOUR, scf.EdgeForeColor, 0)
						IniWrite (IniFile$, "Editor options", "EdgeColumn", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_SHOWPROCNAME :		' display current FUNCTION in FUNCTION combobox
					' If checked, uncheck it, else check it
					IF (GetMenuState (hMenu, $$IDM_SHOWPROCNAME, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
						CheckMenuItem (hMenu, $$IDM_SHOWPROCNAME, $$MF_UNCHECKED)
						ShowProcedureName = $$FALSE
						IniWrite (IniFile$, "Editor options", "ShowProcedureName", STRING$ ($$BST_UNCHECKED))
					ELSE
						CheckMenuItem (hMenu, $$IDM_SHOWPROCNAME, $$MF_CHECKED)
						ShowProcedureName = $$TRUE
						IniWrite (IniFile$, "Editor options", "ShowProcedureName", STRING$ ($$BST_CHECKED))
					END IF

				CASE $$IDM_CVEOLTOCRLF : SendMessageA (GetEdit (), $$SCI_CONVERTEOLS, $$SC_EOL_CRLF, 0)
				CASE $$IDM_CVEOLTOCR : SendMessageA (GetEdit (), $$SCI_CONVERTEOLS, $$SC_EOL_CR, 0)
				CASE $$IDM_CVEOLTOLF : SendMessageA (GetEdit (), $$SCI_CONVERTEOLS, $$SC_EOL_LF, 0)

				CASE $$IDM_REPLSPCWITHTABS : SED_ReplaceSpacesWithTabs ()
				CASE $$IDM_REPLTABSWITHSPC : SED_ReplaceTabsWithSpaces ()

				' Window menu
				CASE $$IDM_CASCADE      : MdiCascade (hWndClient)
				CASE $$IDM_TILEH        : MdiTile (hWndClient, $$MDITILE_HORIZONTAL)
				CASE $$IDM_TILEV        : MdiTile (hWndClient, $$MDITILE_VERTICAL)
				CASE $$IDM_ARRANGE      : MdiIconArrange (hWndClient)
				CASE $$IDM_RESTOREWSIZE : RestoreMainWindowDefaultSize (hWnd)

				CASE $$IDM_SWITCHWINDOW :
          hWndActive = MdiGetActive (hWndClient)
					MdiNext (hWndClient, hWndActive, 0)
					szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
					IF szPath$ THEN
						XstGetPathComponents (szPath$, "", "", "", @fn$, 0)
						EnumMdiTitleToTab (fn$)		' Activates the associated tab
					END IF

				CASE $$IDM_HIDECONSOLE : SendMessageA (hSplitter, $$WM_DOCK_SPLITTER, 0, 0)  ' dock console window
				CASE $$IDM_SHOWCONSOLE : SendMessageA (hSplitter, $$WM_UNDOCK_SPLITTER, 0, 0)

				CASE $$IDM_HIDETREEBROWSER, $$IDM_TREE_HIDE:
					fShowTreeBrowser = $$FALSE
					GetClientRect (hWnd, &rc)
					SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, MAKELONG (rc.right, rc.bottom))
					IniWrite (IniFile$, "Tree Browser", "Show", STRING$ (fShowTreeBrowser))

				CASE $$IDM_SHOWTREEBROWSER :
					fShowTreeBrowser = $$TRUE
					GetClientRect (hWnd, &rc)
					SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, MAKELONG (rc.right, rc.bottom))
					IniWrite (IniFile$, "Tree Browser", "Show", STRING$ (fShowTreeBrowser))
					SED_CodeFinder ($$TRUE)

				CASE $$IDM_TREE_UPDATE : SED_CodeFinder ($$TRUE)

				' OPTIONS
				CASE $$IDM_EDITOROPT    : ShowEditorOptions (hWnd)
				CASE $$IDM_COMPILEROPT  : ShowCompilerOptions (hWnd)
				' CASE $$IDM_TOOLSOPT     : ShowToolsOptions (hWnd)
				CASE $$IDM_FOLDINGOPT   : ShowFoldingOptionsDialog (hWnd)
				CASE $$IDM_COLORSOPT    : ShowColorOptionsDialog (hWnd)
				CASE $$IDM_PRINTINGOPT  : ShowPrintingOptionsDialog (hWnd)

				' HELP
				CASE $$IDM_ABOUT        : XSED_AboutBox (hWnd)
				CASE $$IDM_XBLSITE      : ShellExecuteA ($$HWND_DESKTOP, &"open", &$$XBLITESITE, 0, 0, $$SW_SHOWNORMAL)
					' CASE $$IDM_MSDNSITE    : ShellExecuteA ($$HWND_DESKTOP, &"open", &"http://msdn.microsoft.com", 0, 0, $$SW_SHOWNORMAL)
				CASE $$IDM_GOOGLE       : ShellExecuteA ($$HWND_DESKTOP, &"open", &"http://www.google.com", 0, 0, $$SW_SHOWNORMAL)
				CASE $$IDM_XBLHTMLHELP  :
					p$ = IniRead (IniFile$, "Tools options", "XBLHelp", "")
					IF p$ THEN ShellExecuteA ($$HWND_DESKTOP, &"open", &p$, 0, 0, $$SW_SHOWNORMAL)

				CASE $$IDM_XSEDHTMLHELP :
					p$ = IniRead (IniFile$, "Tools options", "XSEDHelp", "")
					IF p$ THEN ShellExecuteA ($$HWND_DESKTOP, &"open", &p$, 0, 0, $$SW_SHOWNORMAL)

				CASE $$IDM_GOASMHELP :
					p$ = IniRead (IniFile$, "Tools options", "GoAsmHelp", "")
					IF p$ THEN ShellExecuteA ($$HWND_DESKTOP, &"open", &p$, 0, 0, $$SW_SHOWNORMAL)

				CASE $$IDM_WIN32HELP :
					' open win32.hlp file if it exists
					path$ = IniRead (IniFile$, "Tools options", "Win32Help", "")
					IF path$ THEN
						WinHelpA (hWnd, &path$, $$HELP_FINDER, 0)
					ELSE
						ret = SED_MsgBox (hWnd, "Win32 Programmers Reference Help not found.   \r\nDo you want to locate it?   ", $$MB_YESNO, " Win32Help")
						IF ret = $$IDYES THEN
							' find win32.hlp file
							XstGetCurrentDirectory (@CURDIR$)
							fOptions$ = fOptions$ + "Help files (*.hlp)|*.hlp|"
							fOptions$ = fOptions$ + "All Files (*.*)|*.*"
							path$ = "win32.hlp"
							style = $$OFN_EXPLORER OR $$OFN_FILEMUSTEXIST OR $$OFN_HIDEREADONLY
							IF OpenFileDialog (hWnd, "", @path$, CURDIR$, fOptions$, "hlp", style) THEN
								IF INSTRI (path$, "win32.hlp") THEN
									IniWrite (IniFile$, "Tools options", "Win32Help", path$)
									WinHelpA (hWnd, &path$, $$HELP_FINDER, 0)
								END IF
							END IF
						END IF
					END IF

				CASE $$IDM_RCHELP :
				  p$ = IniRead (IniFile$, "Tools options", "RCHelp", "")
          IF p$ THEN
            ' WinHelpA (hWnd, &p$, $$HELP_FINDER, 0)
						WinHelpA (hWnd, &p$, $$HELP_CONTENTS, 0)
					END IF

				CASE $$IDM_MSGBOXBUILDER :
					GetClientRect (hWnd, &rc)
					pt.x = rc.right/2 - 400/2
					IF pt.x < 0 THEN pt.x = 0
					pt.y = rc.bottom/2 - 540/2
					IF pt.y < 0 THEN pt.y = 0
					ClientToScreen (hWnd, &pt)
					ID = NewDialogBox (hWnd, pt.x, pt.y, 400, 540, &MsgBoxProc(), initParam)	' display message box builder

				CASE $$IDM_CLOSEWINDOWS : CloseAllWindows ()

				CASE $$IDM_HELP : GetHelp (hWnd)

					' CASE $$IDM_CODEC
					' ' Code analyzer, based on Borje Hagsten's PBCODEC.BAS
					' ' The routines are contained in the file SED_CODC.INC
					' szPath = SED_GetPrimarySourceFile
					' IF LEN(szPath) = 0 THEN GetWindowText MdiGetActive(hWndClient), szPath, SIZEOF(szPath)
					' DoInitProcess hWnd, szPath

				'CASE $$IDM_CHARMAP :
					' Display character map

				CASE $$IDM_CALCULATOR :
					hCalc = FindWindowA (&"Calculator", NULL)
					IF hCalc <> NULL THEN
						IF IsIconic (hCalc) <> 0 || IsZoomed (hCalc) <> 0 THEN
							ShowWindow (hCalc, $$SW_RESTORE)
						END IF
						SetForegroundWindow (hCalc)
					ELSE
						hr = SHELL ("CALC.EXE")
					END IF
					RETURN

				CASE $$IDM_COMMANDLINE :
					' Command line popup dialog
					addr = DialogBoxParamA (hInst, 200, hWnd, &CommandLineInputBoxProc (), 0)
					IF addr THEN
						CommandLine$ = CSTRING$ (addr)
					ELSE
						CommandLine$ = ""
					END IF

					' Autocompletion listbox
				CASE $$IDM_AUTOCOMPLETE : AutoComplete ()

					' Printer setup
				CASE $$IDM_PRINTERSETUP : PrintSetup (hWnd)

'				CASE $$IDM_PRINTPREVIEW :
					' Get the path from the window caption
					' szText$ = GetWindowText$ (MdiGetActive(hWndClient))
					' IF szText$ THEN SED_PrintDoc (szText$, $$TRUE)

				CASE $$IDM_PRINT : Print (hWnd, $$TRUE)		' display printer dialog

				CASE $$IDT_PRINT : Print (hWnd, $$FALSE)	' no printer dialog

					' Compile and debug
					' CASE $$IDM_COMPILEANDDEBUG  : SED_CompileAndDebug (hWnd)

				CASE $$IDM_EXECUTE      : ExecuteActiveFile (hWnd)

				CASE $$IDM_BUILD        : BuildActiveFile (hWnd)

				CASE $$IDM_COMPILE      :
          SaveFile (hWnd, $$FALSE)
					ChangeButtonsState ()
          CompileActiveFile (hWnd, $$FALSE)

				CASE $$IDM_COMPILE_LIB  :
          SaveFile (hWnd, $$FALSE)
					ChangeButtonsState ()
          CompileActiveFile (hWnd, $$TRUE)

				CASE $$IDM_GOTOSELPROC :
					SendMessageA (MdiGetActive (hWndClient), $$WM_COMMAND, $$IDM_GOTOSELPROC, 0)
					RETURN

				CASE $$IDM_GOTOLASTPOSITION :
					SendMessageA (MdiGetActive (hWndClient), $$WM_COMMAND, $$IDM_GOTOLASTPOSITION, 0)
					RETURN

				CASE $$IDC_CODEFINDER
					SELECT CASE HIWORD (wParam)
						CASE $$CBN_DROPDOWN :
							' Search the function and procedure names in a separate procedure.
							' This procedure fills the combobox and stores the lines in the
							' 32-bit values associated with each of them.
							SED_CodeFinder (0)
						CASE $$CBN_SELCHANGE :
							' Retrieve the line of the wanted function or procedure
							' stored in the 32-bit value associated with the specified item.
							curSel = SendMessageA (hCodeFinder, $$CB_GETCURSEL, 0, 0)
							IF curSel THEN
								' End position = length of the document
								endPos = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
								' Set to end position of document
								SendMessageA (GetEdit (), $$SCI_GOTOLINE, endPos, 0)
								' Set function or procedure to top of editor
								curSel = SendMessageA (hCodeFinder, $$CB_GETITEMDATA, curSel, 0)
								SendMessageA (GetEdit (), $$SCI_GOTOLINE, curSel, 0)
								' Return the focus to the edit control
								SetFocus (GetEdit ())
							END IF
					END SELECT

			END SELECT

			' Message sent by the Find/FindReplace dialog
		CASE dwFindMsg : FindReplaceMsg (hWnd, @hFind, lParam)
			RETURN

	END SELECT

	' Send the message to the MDI frame window procedure
	RETURN DefFrameProcA (hWnd, hWndClient, wMsg, wParam, lParam)

END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION InitGui ()

	SHARED hInst

	hInst = GetModuleHandleA (0)		' get current instance handle
	IFZ hInst THEN QUIT (0)
	' InitCommonControls ()

END FUNCTION
'
'
' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)

	SHARED hInst
	WNDCLASS wc

	wc.style = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc = addrWndProc
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = hInst
	wc.hIcon = LoadIconA (hInst, &icon$)
	wc.hCursor = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground = $$COLOR_BTNFACE + 1
	wc.lpszMenuName = &menu$
	wc.lpszClassName = &className$

	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION CreateWindows ()

	SHARED hInst				' instance handle
	SHARED IniFile$			' ini file name
	SHARED keywords$		' xblite keywords list
	SHARED hWndMain			' main window handle
	SHARED fMaximize		' maximize MDI windows
	SHARED hFont				' standard font
	RECT rc
	WNDCLASS wc
	EditorOptionsType EdOpt
	CompilerOptionsType CpOpt
	SHARED SciColorsAndFontsType scf
	SHARED hMenuTextBkBrush, hMenuHiBrush
	SHARED hSplitter

	' Get the path of the .INI file
	IniFile$ = NULL$ ($$MAX_PATH)
	GetModuleFileNameA (hInst, &IniFile$, $$MAX_PATH)
	IniFile$ = CSIZE$ (IniFile$)
	XstGetPathComponents (IniFile$, @Path$, @Drive$, @Dir$, @Fn$, @attributes)
	IniFile$ = Path$ + $$PROGNAME + ".INI"

	' End program if not multiple instances are allowed
	x = XLONG (IniRead (IniFile$, "Editor options", "AllowMultipleInstances", ""))
	IF x <> $$BST_CHECKED THEN
		ret = SED_AppAlreadyRunning ("XSED")
    IF ret THEN RETURN ret
	END IF

	' Initilize Keywords
	InitializeKeywords ()

	' Standard font
	hFont = GetStockObject ($$ANSI_VAR_FONT)

	' Register the Main Window class
	szClassName$ = "XSED"
	wc.style = $$CS_HREDRAW |$$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc = &WndProc ()
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = hInst
	wc.hIcon = LoadIconA (hInst, &"xsed")
	wc.hCursor = LoadCursorA (NULL, $$IDC_ARROW)
	wc.hbrBackground = $$COLOR_BTNFACE + 1	' GetStockObject ($$WHITE_BRUSH)
	wc.lpszMenuName = NULL
	wc.lpszClassName = &szClassName$
	IFZ (RegisterClassA (&wc)) THEN RETURN ($$TRUE)

	' Register the Code Window class
	szClassName$ = "XSED32"
	wc.style = 0 ' $$CS_HREDRAW OR $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc = &CodeProc ()
	wc.cbClsExtra = 0
	wc.cbWndExtra = 4
	wc.hInstance = hInst
	wc.hIcon = LoadIconA (hInst, 101)
	wc.hCursor = LoadCursorA (NULL, $$IDC_IBEAM)
	wc.hbrBackground = NULL  '$$COLOR_BTNFACE + 1	'$$COLOR_WINDOW + 1
	wc.lpszMenuName = NULL
	wc.lpszClassName = &szClassName$
	IFZ (RegisterClassA (&wc)) THEN RETURN ($$TRUE)

	' Register the Console Window class
	szClassName$ = "XSEDCONSOLE"
	' wc.cbSize        = SIZE(wc)
	wc.style = 0 '$$CS_HREDRAW OR $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc = &ConsoleProc ()
	wc.cbClsExtra = 0
	wc.cbWndExtra = 4
	wc.hInstance = hInst
	wc.hIcon = NULL		' LoadIconA (hInst, 101)
	wc.hCursor = LoadCursorA (NULL, $$IDC_IBEAM)
	wc.hbrBackground = NULL ' $$COLOR_BTNFACE + 1		'$$COLOR_WINDOW + 1
	wc.lpszMenuName = NULL
	wc.lpszClassName = &szClassName$
	IFZ (RegisterClassA (&wc)) THEN RETURN ($$TRUE)

	' Retrieve the size of the working area
	SystemParametersInfoA ($$SPI_GETWORKAREA, 0, &rc, 0)

	' Create a window using the registered class
	title$ = $$SEDCAPTION + ", " + VERSION$(0)  ' $$SEDVERSION
	hWndMain = CreateWindowExA (0, &"XSED", &title$, $$WS_OVERLAPPEDWINDOW | $$WS_CLIPCHILDREN, rc.left, rc.top, rc.right - rc.left + 2, rc.bottom - rc.top + 2, NULL, 0, hInst, NULL)

	' If the command line isn't empty post a message to process it later
	XstGetCommandLineArguments (@argCount, @argv$[])
	IF argCount > 1 THEN PostMessageA (hWndMain, $$WM_USER + 1000, 0, 0)

	' Read saved window's state and placement
	SED_ReadWindowPlacement (hWndMain)

	' Retrieve the editor options (must be done after the menu has been created)
	GetEditorOptions (@EdOpt)
	IF EdOpt.StartInLastFolder THEN
		lf$ = EdOpt.LastFolder
		IF LEN (lf$) THEN XstChangeDirectory (lf$)
	END IF

	' Retrieve the compiler options
	GetCompilerOptions (@CpOpt)
	WriteCompilerOptions (@CpOpt)
	' update help file paths since they depend on location of compiler
	WriteHelpFilePaths ()

	' Enables/disables some of the toolbar buttons
	ChangeButtonsState ()

	' Retrieves the color and fonts options
	GetColorOptions (@scf)
	' Creates the brushes for the submenu text background
	hMenuTextBkBrush = CreateSolidBrush (scf.SubMenuTextBackColor)
	' Creates the brushes for the submenu highlighted text background
	hMenuHiBrush = CreateSolidBrush (scf.SubMenuHiTextBackColor)

	' Enable drag and drop files
	DragAcceptFiles (hWndMain, $$TRUE)

	' Maximize MDI windows on startup if the user has selected this option
	IF EdOpt.MaximizeEditWindows = $$BST_CHECKED THEN fMaximize = $$TRUE
	IF EdOpt.MaximizeMainWindow = $$BST_CHECKED THEN
		' Maximize main window
		ShowWindow (hWndMain, $$SW_MAXIMIZE)
	ELSE
		' Sets the main window show state
		ShowWindow (hWndMain, $$SW_SHOWNORMAL)
	END IF

	' Updates the client area of the main window
	UpdateWindow (hWndMain)

	' set initial position of splitter panel
	GetClientRect (hSplitter, &rc)
	SendMessageA (hSplitter, $$WM_SET_SPLITTER_POSITION, 0, rc.bottom - $$INITIAL_CONSOLE_HEIGHT)

	' then dock splitter
	SendMessageA (hSplitter, $$WM_DOCK_SPLITTER, 0, 0)

	' Loads previous file set
	IF EdOpt.ReloadFilesAtStartup THEN		'&& argCount > 1 THEN
		SED_LoadPreviousFileSet ()
	END IF

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

	SHARED hInst

	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION
'
'
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION MessageLoop ()

	MSG msg
	SHARED hWndClient
	SHARED hWndMain
	SHARED hFind
	SHARED hAccel
	' main message loop

	IF LIBRARY (0) THEN RETURN

	' Message handler loop
	DO WHILE GetMessageA (&msg, NULL, 0, 0)
		' Processes accelerator keystrokes for window menu command
		' of the multiple document interface (MDI) child windows
		IFZ TranslateMDISysAccel (hWndClient, &msg) THEN
			' Processes accelerator keys for menu commands
			IFZ TranslateAcceleratorA (hWndMain, hAccel, &msg) THEN
				' Needed to process Find and Find/Replace dialog messages
				IFZ IsDialogMessageA (hFind, &msg) THEN
					' Determines whether a message is intended for the specified
					' dialog box and, if it is, processes the message.
					IFZ IsDialogMessageA (hWndMain, &msg) THEN
						' Translates virtual-key messages into character messages.
						TranslateMessage (&msg)
						' Dispatches a message to a window procedure.
						DispatchMessageA (&msg)
					END IF
				END IF
			END IF
		END IF
	LOOP

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION CleanUp ()

	SHARED hInst, className$
	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' #############################
' #####  GetNotifyMsg ()  #####
' #############################
'
FUNCTION GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

	NMHDR nmhdr

	RtlMoveMemory (&nmhdr, lParam, SIZE (nmhdr))		'kernel32 library function
	hwndFrom = nmhdr.hwndFrom
	idFrom = nmhdr.idFrom
	code = nmhdr.code

END FUNCTION
'
'
' #############################
' #####  CWIDESTRING$ ()  #####
' #############################
'
' Convert a C wide string to a byte string.
'
FUNCTION CWIDESTRING$ (addr)

	' get size of byte string buffer
	size = WideCharToMultiByte (GetACP (), NULL, addr, -1, NULL, 0, NULL, NULL)
	IFZ size THEN
		' error = GetLastError ()
		' XstSystemErrorNumberToName (error, @error$)
		' PRINT error$
		RETURN ""
	END IF

	text$ = NULL$ (size)
	WideCharToMultiByte (GetACP (), NULL, addr, -1, &text$, size, NULL, NULL)
	RETURN text$

END FUNCTION
'
' ###################################
' #####  InitializeKeywords ()  #####
' ###################################
'
FUNCTION InitializeKeywords ()

	SHARED keywords$
	SHARED keywords$[]

	' primary compiler keywords
	keywords$ = "ABS ALL ASC ASM ATTACH AUTO AUTOS AUTOX BIN$ BINB$ BITFIELD _
			CASE CEIL CFUNCTION CHR$ CJUST$ CLEAR CLOSE CLR CONSOLE CSIZE CSIZE$ CSTRING$ _
			DCOMPLEX DEC DECLARE DHIGH DIM DLOW DMAKE DO DOUBLE DOUBLEAT _
			ELSE END ENDIF EOF ERROR ERROR$ EXIT EXPLICIT EXPORT EXTERNAL EXTS EXTU _
			FALSE FIX FOR FORMAT$ FUNCADDR FUNCADDRESS FUNCTION _
			GHIGH GIANT GIANTAT GLOW GMAKE GOADDR GOADDRESS GOSUB GOTO HEX$ HEXX$ HIGH0 HIGH1 HIWORD _
			IF IFF IFT IFZ IMPORT INC INCHR INCHRI INFILE$ INLINE$ INSTR INSTRI INT INTERNAL _
			LCASE$ LCLIP$ LEFT$ LEN LIBRARY LJUST$ LOF LONGDOUBLE LONGDOUBLEAT LOOP LOWORD LTRIM$ _
			MAKE MAKEFILE MAX MID$ MIN MOD NEXT NULL NULL$ OCT$ OCTO$ OPEN PACKED POF POWER PRINT PROGRAM PROGRAM$ _
			QUIT RCLIP$ READ REDIM RETURN RIGHT$ RINCHR RINCHRI RINSTR RINSTRI RJUST$ ROTATEL ROUND ROUNDNE _
			ROTATER RTRIM$ SBYTE SBYTEAT SCOMPLEX SEEK SELECT SET SFUNCTION SGN SHARED SHELL SIGN _
			SIGNED$ SINGLE SINGLEAT SIZE SLONG SLONGAT SMAKE SPACE$ SSHORT _
			SSHORTAT STATIC STEP STOP STR$ STRING STRING$ STUFF$ SUB SUBADDR SUBADDRESS SWAP _
			TAB THEN TO TRIM$ TRUE TYPE UBOUND UBYTE UBYTEAT UCASE$ ULONG ULONGAT UNION UNTIL USHORT USHORTAT _
			VERSION VERSION$ VOID WHILE WRITE XLONG XLONGAT XMAKE _
			OR AND XOR NOT ?"

'	' xst library functions
'	keywords$ = keywords$ + "FPClassifyL IsFiniteL IsInfL IsNanL IsNormalL IsSubNormalL IsZeroL "
'	keywords$ = keywords$ + "HIWORD LOWORD MAKELONG PowL RGB SignBitL XstAbend XstAlert XstBackArrayToBinArray XstBackStringToBinString$ "
'	keywords$ = keywords$ + "XstBinArrayToBackArray XstBinRead XstBinStringToBackString$ XstBinStringToBackStringNL$ XstBinStringToBackStringThese$ "
'	keywords$ = keywords$ + "XstBinWrite XstBytesToBound XstCall XstCauseException XstCenterWindow XstChangeDirectory XstCompareStrings XstCopyArray "
'	keywords$ = keywords$ + "XstCopyDirectory XstCopyFile XstCopyMemory XstCreateDoubleImage$ XstDateAndTimeToFileTime XstDecomposePathname "
'	keywords$ = keywords$ + "XstDeleteFile XstDeleteLines XstEnableFPExceptions XstErrorNameToNumber XstErrorNumberToName XstExceptionNameToNumber "
'	keywords$ = keywords$ + "XstExceptionNumberToName XstExceptionToSystemException XstFileExists XstFileTimeToDateAndTime XstFileToSystemFile XstFindArray "
'	keywords$ = keywords$ + "XstFindFile XstFindFiles XstFindMemoryMatch XstGetClipboard XstGetCommandLine XstGetCommandLineArguments XstGetCPUName "
'	keywords$ = keywords$ + "XstGetCurrentDirectory XstGetDateAndTime XstGetDateAndTimeFormatted XstGetDrives XstGetEndian XstGetEndianName "
'	keywords$ = keywords$ + "XstGetEnvironmentVariable XstGetEnvironmentVariables XstGetException XstGetExceptionFunction XstGetExceptionInformation "
'	keywords$ = keywords$ + "XstGetExecutionPathArray XstGetFileAttributes XstGetFiles XstGetFilesAndAttributes XstGetFPUControlWord XstGetLocalDateAndTime "
'	keywords$ = keywords$ + "XstGetMemoryMap XstGetOSName XstGetOSVersion XstGetPathComponents XstGetProgramFileName$ XstGetSystemError XstGetSystemTime "
'	keywords$ = keywords$ + "XstGetTypedArray XstGuessFilename XstIsAbsolutePath XstIsDataDimension XstKillTimer XstLoadString XstLoadStringArray "
'	keywords$ = keywords$ + "XstLockFileSection XstLog XstLongDoubleToString$ XstLTRIM XstMakeDirectory XstMergeStrings$ XstMultiStringToStringArray "
'	keywords$ = keywords$ + "XstNextCField$ XstNextCLine$ XstNextField$ XstNextItem$ XstNextLine$ XstParse$ XstParseStringToStringArray XstPathString$ "
'	keywords$ = keywords$ + "XstPathToAbsolutePath XstQuickSort XstRaiseException XstRandom XstRandomCreateSeed XstRandomSeed XstRandomUniform XstReadString "
'	keywords$ = keywords$ + "XstRegisterException XstRenameFile XstReplace XstReplaceArray XstReplaceLines XstRTRIM XstSaveString XstSaveStringArray "
'	keywords$ = keywords$ + "XstSaveStringArrayCRLF XstSetClipboard XstSetCommandLineArguments XstSetCurrentDirectory XstSetDateAndTime XstSetEnvironmentVariable "
'	keywords$ = keywords$ + "XstSetException XstSetExceptionFunction XstSetFPUControlWord XstSetFPUPrecision XstSetFPURounding XstSetSystemError XstSleep "
'	keywords$ = keywords$ + "XstStartTimer XstStringArraySectionToString XstStringArraySectionToStringArray XstStringArrayToString XstStringArrayToStringCRLF "
'	keywords$ = keywords$ + "XstStringToLongDouble XstStringToNumber XstStringToStringArray XstStripChars XstSystemErrorNumberToName XstSystemErrorToError XstSystemExceptionNumberToName "
'	keywords$ = keywords$ + "XstSystemExceptionToException XstTally XstTranslateChars XstTRIM XstTry XstTypeSize XstUnlockFileSection XstVersion$ XstWriteString XsxVersion$ "
'	keywords$ = keywords$ + "XxxFormat$ XxxReadFile XxxWriteFile "

'	' xio library functions
'	keywords$ = keywords$ + "XioClearConsole XioClearEndOfLine XioCloseStdHandle XioCreateConsole XioDeleteConsole XioFreeConsole XioGetConsoleInfo "
'	keywords$ = keywords$ + "XioGetConsoleTextRect XioGetConsoleWindow XioGetStdIn XioGetStdOut XioGrabConsoleText XioHideConsole XioInkey "
'	keywords$ = keywords$ + "XioInsertLine XioPutConsoleText XioPutConsoleTextArray XioReadConsole XioScrollBufferUp XioSetConsoleBufferSize "
'	keywords$ = keywords$ + "XioSetConsoleCursorPos XioSetConsoleTextRect XioSetCursorType XioSetDefaultColors XioSetTextAttributes XioSetTextBackColor "
'	keywords$ = keywords$ + "XioSetTextColor XioShowConsole XioWriteConsole"

	DIM keywords$[600]
	count = -1
	index = 0
	done = 0
	DO UNTIL done
		INC count
		keywords$[count] = XstNextField$ (keywords$, @index, @done)
	LOOP
	REDIM keywords$[count - 1]

END FUNCTION
'
'
' #####################################
' #####  Scintilla_SetOptions ()  #####
' #####################################
'
FUNCTION Scintilla_SetOptions (pSci, fileName$)

	SHARED hMenu
	EditorOptionsType EdOpt
	FoldingOptionsType FoldOpt
	SHARED SciColorsAndFontsType scf
	SHARED keywords$
	SHARED fFoldingOn

	IFZ pSci THEN RETURN ($$TRUE)
	szFont$ = NULL$ (34)

	' Read the options
	GetEditorOptions (@EdOpt)
	GetFoldingOptions (@FoldOpt)

	' Set the default style
	szFont$ = scf.DefaultFontName
	SciMsg (pSci, $$SCI_STYLESETFONT, $$STYLE_DEFAULT, &szFont$)
	SciMsg (pSci, $$SCI_STYLESETSIZE, $$STYLE_DEFAULT, scf.DefaultFontSize)
	SED_SetCharset (pSci, $$STYLE_DEFAULT, scf.DefaultFontCharset)
	SciMsg (pSci, $$SCI_STYLESETBOLD, $$STYLE_DEFAULT, scf.DefaultFontBold)
	SciMsg (pSci, $$SCI_STYLESETITALIC, $$STYLE_DEFAULT, scf.DefaultFontItalic)
	SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$STYLE_DEFAULT, scf.DefaultFontUnderline)
	SciMsg (pSci, $$SCI_STYLESETFORE, $$STYLE_DEFAULT, scf.DefaultForeColor)
	SciMsg (pSci, $$SCI_STYLESETBACK, $$STYLE_DEFAULT, scf.DefaultBackColor)

	' Set all the other styles to the default
	SciMsg (pSci, $$SCI_STYLECLEARALL, 0, 0)

	' Set the style for the line numbers
  IF scf.AlwaysUseDefaultFont THEN
    szFont$ = scf.DefaultFontName
  ELSE
    szFont$ = scf.LineNumberFontName
  END IF
	SciMsg (pSci, $$SCI_STYLESETFONT, $$STYLE_LINENUMBER, &szFont$)
  IF scf.AlwaysUseDefaultFontSize THEN
    SciMsg (pSci, $$SCI_STYLESETSIZE, $$STYLE_LINENUMBER, scf.DefaultFontSize)
  ELSE
    SciMsg (pSci, $$SCI_STYLESETSIZE, $$STYLE_LINENUMBER, scf.LineNumberFontSize)
  END IF
	SED_SetCharset (pSci, $$STYLE_LINENUMBER, scf.LineNumberFontCharset)
	SciMsg (pSci, $$SCI_STYLESETBOLD, $$STYLE_LINENUMBER, scf.LineNumberFontBold)
	SciMsg (pSci, $$SCI_STYLESETITALIC, $$STYLE_LINENUMBER, scf.LineNumberFontItalic)
	SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$STYLE_LINENUMBER, scf.LineNumberFontUnderline)
	SciMsg (pSci, $$SCI_STYLESETFORE, $$STYLE_LINENUMBER, scf.LineNumberForeColor)
	SciMsg (pSci, $$SCI_STYLESETBACK, $$STYLE_LINENUMBER, scf.LineNumberBackColor)

	' XBLite specific

	sfileName$ = UCASE$ (fileName$)

	IF INSTR (sfileName$, ".X") || INSTR (sfileName$, ".XL") || INSTR (sfileName$, ".XBL") || INSTR (sfilename$, ".DEC") THEN

		IF EdOpt.SyntaxHighlighting = $$BST_CHECKED THEN

			' Set the Comments style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.CommentFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_COMMENT, &szFont$)
      IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_COMMENT, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_COMMENT, scf.CommentFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_COMMENT, scf.CommentFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_COMMENT, scf.CommentFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_COMMENT, scf.CommentFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_COMMENT, scf.CommentFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_COMMENT, scf.CommentForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_COMMENT, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_COMMENT, scf.CommentBackColor)
      END IF

			' Set the Keywords style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.KeywordFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_KEYWORD, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_KEYWORD, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_KEYWORD, scf.KeywordFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_KEYWORD, scf.KeywordFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_KEYWORD, scf.KeywordFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_KEYWORD, scf.KeywordFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_KEYWORD, scf.KeywordFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_KEYWORD, scf.KeywordForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_KEYWORD, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_KEYWORD, scf.KeywordBackColor)
      END IF

			' Set the Constants style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.ConstantFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_CONSTANT, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_CONSTANT, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_CONSTANT, scf.ConstantFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_CONSTANT, scf.ConstantFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_CONSTANT, scf.ConstantFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_CONSTANT, scf.ConstantFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_CONSTANT, scf.ConstantFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_CONSTANT, scf.ConstantForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_CONSTANT, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_CONSTANT, scf.ConstantBackColor)
      END IF

			' Set the ASM line style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.ASMFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_ASM, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_ASM, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_ASM, scf.ASMFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_ASM, scf.ASMFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_ASM, scf.ASMFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_ASM, scf.ASMFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_ASM, scf.ASMFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_ASM, scf.ASMForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_ASM, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_ASM, scf.ASMBackColor)
      END IF

			' Set the Identifiers style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.IdentifierFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_IDENTIFIER, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_IDENTIFIER, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_IDENTIFIER, scf.IdentifierFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_IDENTIFIER, scf.IdentifierFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_IDENTIFIER, scf.IdentifierFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_IDENTIFIER, scf.IdentifierFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_IDENTIFIER, scf.IdentifierFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_IDENTIFIER, scf.IdentifierForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_IDENTIFIER, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_IDENTIFIER, scf.IdentifierBackColor)
      END IF

			' Set the Numbers style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.NumberFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_NUMBER, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_NUMBER, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_NUMBER, scf.NumberFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_NUMBER, scf.NumberFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_NUMBER, scf.NumberFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_NUMBER, scf.NumberFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_NUMBER, scf.NumberFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_NUMBER, scf.NumberForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_NUMBER, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_NUMBER, scf.NumberBackColor)
      END IF

			' Set the Operators style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.OperatorFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_OPERATOR, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_OPERATOR, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_OPERATOR, scf.OperatorFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_OPERATOR, scf.OperatorFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_OPERATOR, scf.OperatorFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_OPERATOR, scf.OperatorFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_OPERATOR, scf.OperatorFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_OPERATOR, scf.OperatorForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_OPERATOR, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_OPERATOR, scf.OperatorBackColor)
      END IF

			' Set the Strings style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.StringFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_STRING, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_STRING, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_STRING, scf.StringFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_STRING, scf.StringFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_STRING, scf.StringFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_STRING, scf.StringFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_STRING, scf.StringFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_STRING, scf.StringForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_STRING, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_STRING, scf.StringBackColor)
      END IF

			' Set the char strings style the same as for strings
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.StringFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_B_CHAR, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_CHAR, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_B_CHAR, scf.StringFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_B_CHAR, scf.StringFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_B_CHAR, scf.StringFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_B_CHAR, scf.StringFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_B_CHAR, scf.StringFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_B_CHAR, scf.StringForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_CHAR, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_B_CHAR, scf.StringBackColor)
      END IF

			' Set the lexer as container lexer
			SciMsg (pSci, $$SCI_SETLEXER, $$SCLEX_CONTAINER, 0)

			IF FoldOpt.FoldingLevel THEN
				fFoldingOn = $$TRUE
				' Enable folding of the procedures and functions
				szKey$ = "fold" : szValue$ = "1"
				SciMsg (pSci, $$SCI_SETPROPERTY, &szKey$, &szValue$)
			ELSE
				fFoldingOn = $$FALSE
				szKey$ = "fold" : szValue$ = "0"
				SciMsg (pSci, $$SCI_SETPROPERTY, &szKey$, &szValue$)
			END IF
		END IF
	ELSE
		IF INSTR (sfileName$, ".ASM") THEN
			' set the lexer as ASM
			SciMsg (pSci, $$SCI_SETLEXER, $$SCLEX_ASM, 0)

			' initialize all assembly keyword sets
			InitializeAsmKeywords (pSci)

			' set asm colors and fonts

			' Set the ASM Comments style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.CommentFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_COMMENT, &szFont$)
      IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_COMMENT, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_COMMENT, scf.CommentFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_COMMENT, scf.CommentFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_COMMENT, scf.CommentFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_COMMENT, scf.CommentFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_COMMENT, scf.CommentFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_COMMENT, scf.CommentForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_COMMENT, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_COMMENT, scf.CommentBackColor)
      END IF

			' Set the ASM Numbers style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.NumberFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_NUMBER, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_NUMBER, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_NUMBER, scf.NumberFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_NUMBER, scf.NumberFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_NUMBER, scf.NumberFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_NUMBER, scf.NumberFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_NUMBER, scf.NumberFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_NUMBER, scf.NumberForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_NUMBER, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_NUMBER, scf.NumberBackColor)
      END IF

			' Set the ASM Strings style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.StringFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_STRING, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_STRING, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_STRING, scf.StringFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_STRING, scf.StringFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_STRING, scf.StringFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_STRING, scf.StringFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_STRING, scf.StringFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_STRING, scf.StringForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_STRING, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_STRING, scf.StringBackColor)
      END IF

			' Set the ASM Operators style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.OperatorFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_OPERATOR, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_OPERATOR, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_OPERATOR, scf.OperatorFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_OPERATOR, scf.OperatorFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_OPERATOR, scf.OperatorFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_OPERATOR, scf.OperatorFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_OPERATOR, scf.OperatorFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_OPERATOR, scf.OperatorForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_OPERATOR, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_OPERATOR, scf.OperatorBackColor)
      END IF

			' Set the ASM Identifiers style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.IdentifierFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_IDENTIFIER, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_IDENTIFIER, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_IDENTIFIER, scf.IdentifierFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_IDENTIFIER, scf.IdentifierFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_IDENTIFIER, scf.IdentifierFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_IDENTIFIER, scf.IdentifierFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_IDENTIFIER, scf.IdentifierFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_IDENTIFIER, scf.IdentifierForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_IDENTIFIER, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_IDENTIFIER, scf.IdentifierBackColor)
      END IF

			' Set the ASM CPU Keywords style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.KeywordFontName
      END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_CPUINSTRUCTION, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_CPUINSTRUCTION, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_CPUINSTRUCTION, scf.KeywordFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_CPUINSTRUCTION, scf.KeywordFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_CPUINSTRUCTION, scf.KeywordFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_CPUINSTRUCTION, scf.KeywordFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_CPUINSTRUCTION, scf.KeywordFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_CPUINSTRUCTION, scf.KeywordForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_CPUINSTRUCTION, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_CPUINSTRUCTION, scf.KeywordBackColor)
      END IF

			' Set the ASM Characters style
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.StringFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_CHARACTER, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_CHARACTER, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_CHARACTER, scf.StringFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_CHARACTER, scf.StringFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_CHARACTER, scf.StringFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_CHARACTER, scf.StringFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_CHARACTER, scf.StringFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_CHARACTER, scf.StringForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_CHARACTER, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_CHARACTER, scf.StringBackColor)
      END IF

			' Set the ASM FPU instruction
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.AsmFpuInstructionFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_MATHINSTRUCTION, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_MATHINSTRUCTION, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_MATHINSTRUCTION, scf.AsmFpuInstructionFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_MATHINSTRUCTION, scf.AsmFpuInstructionFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_MATHINSTRUCTION, scf.AsmFpuInstructionFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_MATHINSTRUCTION, scf.AsmFpuInstructionFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_MATHINSTRUCTION, scf.AsmFpuInstructionFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_MATHINSTRUCTION, scf.AsmFpuInstructionForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_MATHINSTRUCTION, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_MATHINSTRUCTION, scf.AsmFpuInstructionBackColor)
      END IF

			' Set the ASM register
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.AsmRegisterFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_REGISTER, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_REGISTER, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_REGISTER, scf.AsmRegisterFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_REGISTER, scf.AsmRegisterFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_REGISTER, scf.AsmRegisterFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_REGISTER, scf.AsmRegisterFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_REGISTER, scf.AsmRegisterFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_REGISTER, scf.AsmRegisterForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_REGISTER, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_REGISTER, scf.AsmRegisterBackColor)
      END IF

			' Set the ASM directive
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.AsmDirectiveFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_DIRECTIVE, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_DIRECTIVE, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_DIRECTIVE, scf.AsmDirectiveFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_DIRECTIVE, scf.AsmDirectiveFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_DIRECTIVE, scf.AsmDirectiveFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_DIRECTIVE, scf.AsmDirectiveFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_DIRECTIVE, scf.AsmDirectiveFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_DIRECTIVE, scf.AsmDirectiveForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_DIRECTIVE, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_DIRECTIVE, scf.AsmDirectiveBackColor)
      END IF

			' Set the ASM directive operand
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.AsmDirectiveOperandFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_DIRECTIVEOPERAND, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_DIRECTIVEOPERAND, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_DIRECTIVEOPERAND, scf.AsmDirectiveOperandFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_DIRECTIVEOPERAND, scf.AsmDirectiveOperandFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_DIRECTIVEOPERAND, scf.AsmDirectiveOperandFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_DIRECTIVEOPERAND, scf.AsmDirectiveOperandFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_DIRECTIVEOPERAND, scf.AsmDirectiveOperandFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_DIRECTIVEOPERAND, scf.AsmDirectiveOperandForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_DIRECTIVEOPERAND, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_DIRECTIVEOPERAND, scf.AsmDirectiveOperandBackColor)
      END IF

			' Set the ASM extended instruction
			IF scf.AlwaysUseDefaultFont THEN
        szFont$ = scf.DefaultFontName
      ELSE
        szFont$ = scf.AsmExtendedInstructionFontName
			END IF
			SciMsg (pSci, $$SCI_STYLESETFONT, $$SCE_ASM_EXTINSTRUCTION, &szFont$)
			IF scf.AlwaysUseDefaultFontSize THEN
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_EXTINSTRUCTION, scf.DefaultFontSize)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETSIZE, $$SCE_ASM_EXTINSTRUCTION, scf.AsmExtendedInstructionFontSize)
      END IF
			SED_SetCharset (pSci, $$SCE_ASM_EXTINSTRUCTION, scf.AsmExtendedInstructionFontCharset)
			SciMsg (pSci, $$SCI_STYLESETBOLD, $$SCE_ASM_EXTINSTRUCTION, scf.AsmExtendedInstructionFontBold)
			SciMsg (pSci, $$SCI_STYLESETITALIC, $$SCE_ASM_EXTINSTRUCTION, scf.AsmExtendedInstructionFontItalic)
			SciMsg (pSci, $$SCI_STYLESETUNDERLINE, $$SCE_ASM_EXTINSTRUCTION, scf.AsmExtendedInstructionFontUnderline)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_EXTINSTRUCTION, scf.AsmExtendedInstructionForeColor)
			IF scf.AlwaysUseDefaultBackColor THEN
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_EXTINSTRUCTION, scf.DefaultBackColor)
      ELSE
        SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_EXTINSTRUCTION, scf.AsmExtendedInstructionBackColor)
      END IF

			SciMsg (pSci, $$SCI_STYLESETBACK, $$SCE_ASM_STRINGEOL, 0xe0c0e0)
			SciMsg (pSci, $$SCI_STYLESETEOLFILLED, $$SCE_ASM_STRINGEOL, 1)

			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_COMMENTBLOCK, 0x808080)
			SciMsg (pSci, $$SCI_STYLESETFORE, $$SCE_ASM_STRINGEOL, 0x000000)

		END IF
	END IF

	' Caret
	SciMsg (pSci, $$SCI_SETCARETFORE, scf.CaretForeColor, 0)

	' Show caret line
	IF EdOpt.ShowCaretLine = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETCARETLINEVISIBLE, $$TRUE, 0)
	ELSE
		SciMsg (pSci, $$SCI_SETCARETLINEVISIBLE, $$FALSE, 0)
	END IF

	' Caret line color
	SciMsg (pSci, $$SCI_SETCARETLINEBACK, scf.CaretLineBackColor, 0)

	' Selection
	SciMsg (pSci, $$SCI_SETSELFORE, $$TRUE, scf.SelectionForeColor)
	SciMsg (pSci, $$SCI_SETSELBACK, $$TRUE, scf.SelectionBackColor)

	' Tabs
	IF EdOpt.UseTabs = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETUSETABS, $$TRUE, 0)
		CheckMenuItem (hMenu, $$IDM_USETABS, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETUSETABS, $$FALSE, 0)
		CheckMenuItem (hMenu, $$IDM_USETABS, $$MF_UNCHECKED)
	END IF
	SciMsg (pSci, $$SCI_SETTABWIDTH, EdOpt.TabSize, 0)

	' Auto indentation
	IF EdOpt.AutoIndent = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_AUTOINDENT, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_AUTOINDENT, $$MF_UNCHECKED)
	END IF
	SciMsg (pSci, $$SCI_SETINDENT, EdOpt.IndentSize, 0)

	' Indentation guides
	IF EdOpt.IndentGuides = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETINDENT, EdOpt.TabSize, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWINDENT, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETINDENT, 0, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWINDENT, $$MF_UNCHECKED)
	END IF

	IF EdOpt.IndentGuides = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETINDENTATIONGUIDES, $$TRUE, 0)
	ELSE
		SciMsg (pSci, $$SCI_SETINDENTATIONGUIDES, $$FALSE, 0)
	END IF

	SciMsg (pSci, $$SCI_STYLESETFORE, $$STYLE_INDENTGUIDE, scf.IndentGuideForeColor)
	SciMsg (pSci, $$SCI_STYLESETBACK, $$STYLE_INDENTGUIDE, scf.IndentGuideBackColor)

	' Set edge column and mode
	IF EdOpt.EdgeColumn = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETEDGEMODE, $$EDGE_LINE, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWEDGE, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETEDGEMODE, $$EDGE_NONE, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWEDGE, $$MF_UNCHECKED)
	END IF
	SciMsg (pSci, $$SCI_SETEDGECOLUMN, EdOpt.EdgeWidth, 0)
	SciMsg (pSci, $$SCI_SETEDGECOLOUR, scf.EdgeForeColor, 0)

	' Show white spaces as dots
	IF GetMenuState (hMenu, $$IDM_SHOWSPACES, $$MF_BYCOMMAND) = $$MF_CHECKED THEN
		SciMsg (pSci, $$SCI_SETVIEWWS, $$SCWS_VISIBLEALWAYS, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETVIEWWS, $$SCWS_INVISIBLE, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_UNCHECKED)
	END IF

	' White space
	IF EdOpt.WhiteSpace = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETVIEWWS, $$SCWS_VISIBLEALWAYS, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETVIEWWS, $$SCWS_INVISIBLE, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_UNCHECKED)
	END IF
	SciMsg (pSci, $$SCI_SETWHITESPACEFORE, $$TRUE, scf.WhitespaceForeColor)
	SciMsg (pSci, $$SCI_SETWHITESPACEBACK, $$TRUE, scf.WhitespaceBackColor)

	' End of line
	IF EdOpt.EndOfLine = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETVIEWEOL, $$TRUE, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWEOL, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETVIEWEOL, $$FALSE, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWEOL, $$MF_UNCHECKED)
	END IF

	' Magnification
	SciMsg (pSci, $$SCI_SETZOOM, EdOpt.Magnification, 0)

	' Margin 0 for numbers
	SciMsg (pSci, $$SCI_SETMARGINTYPEN, 0, $$SC_MARGIN_NUMBER)
	SciMsg (pSci, $$SCI_SETMARGINSENSITIVEN, 0, 1)
	IF EdOpt.LineNumbers = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETMARGINWIDTHN, 0, EdOpt.LineNumbersWidth)
		CheckMenuItem (hMenu, $$IDM_SHOWLINENUM, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETMARGINWIDTHN, 0, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWLINENUM, $$MF_UNCHECKED)
	END IF

	' Margin 1 for non-folding symbols
	SciMsg (pSci, $$SCI_SETMARGINTYPEN, 1, $$SC_MARGIN_SYMBOL)
	SciMsg (pSci, $$SCI_SETMARGINMASKN, 1, 1)
	SciMsg (pSci, $$SCI_SETMARGINSENSITIVEN, 1, 1)
	SciMsg (pSci, $$SCI_SETMARGINWIDTHN, 1, 16)

	SciMsg (pSci, $$SCI_SETFOLDMARGINCOLOUR, 2, RGB (200, 0, 200))
	SciMsg (pSci, $$SCI_SETFOLDMARGINHICOLOUR, 2, RGB (100, 0, 100))

	' Margin 2 for folding symbols
	SciMsg (pSci, $$SCI_SETMARGINTYPEN, 2, $$SC_MARGIN_SYMBOL)
	SciMsg (pSci, $$SCI_SETMARGINMASKN, 2, $$SC_MASK_FOLDERS)
	SciMsg (pSci, $$SCI_SETMARGINSENSITIVEN, 2, 1)
	IF EdOpt.Margin = $$BST_CHECKED THEN
		SciMsg (pSci, $$SCI_SETMARGINWIDTHN, 2, EdOpt.MarginWidth)
		CheckMenuItem (hMenu, $$IDM_SHOWMARGIN, $$MF_CHECKED)
	ELSE
		SciMsg (pSci, $$SCI_SETMARGINWIDTHN, 2, 0)
		CheckMenuItem (hMenu, $$IDM_SHOWMARGIN, $$MF_UNCHECKED)
	END IF

	SELECT CASE FoldOpt.FoldingSymbol

		CASE 1 :

			' Initialize fold symbols for folding - Arrow (mimics MacIntosh)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPEN, $$SC_MARK_ARROWDOWN)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDER, $$SC_MARK_ARROW)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERSUB, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERTAIL, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEREND, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPENMID, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERMIDTAIL, $$SC_MARK_EMPTY)

		CASE 2

			' Initialize fold symbols for folding - Plus/minus
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPEN, $$SC_MARK_MINUS)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDER, $$SC_MARK_PLUS)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERSUB, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERTAIL, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEREND, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPENMID, $$SC_MARK_EMPTY)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERMIDTAIL, $$SC_MARK_EMPTY)

		CASE 3

			' Initialize fold symbols for folding - Circle
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPEN, $$SC_MARK_CIRCLEMINUS)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDER, $$SC_MARK_CIRCLEPLUS)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERSUB, $$SC_MARK_VLINE)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERTAIL, $$SC_MARK_LCORNERCURVE)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEREND, $$SC_MARK_CIRCLEPLUSCONNECTED)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPENMID, $$SC_MARK_CIRCLEMINUSCONNECTED)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERMIDTAIL, $$SC_MARK_TCORNERCURVE)

		CASE 4

			' Initialize fold symbols for folding - Box tree
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPEN, $$SC_MARK_BOXMINUS)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDER, $$SC_MARK_BOXPLUS)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERSUB, $$SC_MARK_VLINE)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERTAIL, $$SC_MARK_LCORNER)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEREND, $$SC_MARK_BOXPLUSCONNECTED)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDEROPENMID, $$SC_MARK_BOXMINUSCONNECTED)
			SciMsg (pSci, $$SCI_MARKERDEFINE, $$SC_MARKNUM_FOLDERMIDTAIL, $$SC_MARK_TCORNER)

	END SELECT

	' Draw line below if not expanded
	SciMsg (pSci, $$SCI_SETFOLDFLAGS, 16, 0)

	' Fold margin colors.
	SciMsg (pSci, $$SCI_SETFOLDMARGINCOLOUR, 2, scf.FoldMarginForeColor)
	SciMsg (pSci, $$SCI_SETFOLDMARGINHICOLOUR, 2, scf.FoldMarginBackColor)

	' Colors for folders closed and folders opened
	SciMsg (pSci, $$SCI_MARKERSETFORE, $$SC_MARKNUM_FOLDER, scf.FoldForeColor)
	SciMsg (pSci, $$SCI_MARKERSETBACK, $$SC_MARKNUM_FOLDER, scf.FoldBackColor)
	SciMsg (pSci, $$SCI_MARKERSETFORE, $$SC_MARKNUM_FOLDEROPEN, scf.FoldOpenForeColor)
	SciMsg (pSci, $$SCI_MARKERSETBACK, $$SC_MARKNUM_FOLDEROPEN, scf.FoldOpenBackColor)

	' Add ".", "_", and "$" to the list of allowable characters for word identification
	szValue$ = "._$@%abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	SciMsg (pSci, $$SCI_SETWORDCHARS, 0, &szValue$)

	' Disable right click popup menu
	SciMsg (pSci, $$SCI_USEPOPUP, $$FALSE, $$FALSE)

	' For some reason it works with $$SCMOD_SHIFT and $$SCMOD_ALT but not with $$SCMOD_CTRL
	' Local KeyMod as long
	' Local KeyId as long
	' KeyMod = $$SCMOD_CTRL
	' Shift LEFT KeyMod, 16
	' KeyId = $$SCK_INSERT
	' KeyId = KeyId or KeyMod
	' SciMsg (pSci, $$SCI_ASSIGNCMDKEY, KeyId, $$SCI_COPY

END FUNCTION
'
'
' #######################
' #####  SciMsg ()  #####
' #######################
'
FUNCTION SciMsg (pSciWndData, wMsg, wParam, lParam)

	RETURN Scintilla_DirectFunction (pSciWndData, wMsg, wParam, lParam)
END FUNCTION
'
'
' ###############################
' #####  SED_SetCharset ()  #####
' ###############################
'
FUNCTION SED_SetCharset (pSci, Style, CharsetName$)

	SELECT CASE CharsetName$
		CASE "Default"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_DEFAULT)
		CASE "Ansi"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_ANSI)
		CASE "Arabic"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_ARABIC)
		CASE "Baltic"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_BALTIC)
		CASE "Chinese Big 5"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_CHINESEBIG5)
		CASE "East Europe"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_EASTEUROPE)
		CASE "GB 2312"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_GB2312)
		CASE "Greek"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_GREEK)
		CASE "Hangul"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_HANGUL)
		CASE "Hebrew"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_HEBREW)
		CASE "Johab"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_JOHAB)
		CASE "Mac"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_MAC)
		CASE "OEM"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_OEM)
		CASE "Russian"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_RUSSIAN)
		CASE "Shiftjis"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_SHIFTJIS)
		CASE "Symbol"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_SYMBOL)
		CASE "Thai"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_THAI)
		CASE "Turkish"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_TURKISH)
		CASE "Vietnamese"
			SciMsg (pSci, $$SCI_STYLESETCHARACTERSET, Style, $$SC_CHARSET_VIETNAMESE)
	END SELECT

END FUNCTION
'
'
' ######################################
' #####  SED_AppAlreadyRunning ()  #####
' ######################################
'
' Find currently running XSED app.
' If active, return -1, if not, return 0.
'
FUNCTION SED_AppAlreadyRunning (szClassName$)

	hWnd = FindWindowA (&szClassName$, NULL)
	IF hWnd THEN
		SED_ProcessCommandLine (hWnd)
		RETURN (-1)
	END IF
END FUNCTION
'
'
' #######################################
' #####  SED_ProcessCommandLine ()  #####
' #######################################
'
' Process command line args
' xsed [file] [line]
'
FUNCTION SED_ProcessCommandLine (hWnd)

	COPYDATASTRUCT DataToSend		' Data to send structure
	STATIC lsFileName$

	IFZ hWnd THEN RETURN

	IF (IsIconic (hWnd) <> 0) || (IsZoomed (hWnd) <> 0) THEN ShowWindow (hWnd, $$SW_RESTORE)
	SetForegroundWindow (hWnd)

	XstGetCommandLineArguments (@argCount, @argv$[])
	IF argCount > 0 THEN lsFileName$ = argv$[1]			' hopefully!
	IF argCount > 2 THEN
		lsLineNumber$ = argv$[2]
		ln = XLONG (lsLineNumber$)
		IF ln = 0 THEN ln = 1
	ELSE
		lsLineNumber$ = ""
		ln = 1
	END IF

	IF lsFileName$ THEN
		DataToSend.lpData = &lsFileName$
		DataToSend.cbData = LEN (lsFileName$)
		DataToSend.dwData = ln - 1
		SendMessageA (hWnd, $$WM_COPYDATA, SIZE (DataToSend), &DataToSend)
		IF GetEdit () THEN SendMessageA (GetEdit (), $$SCI_GOTOLINE, ln-1, 0)
	END IF

END FUNCTION
'
'
' ########################
' #####  GetEdit ()  #####
' ########################
'
FUNCTION GetEdit ()
	SHARED hWndClient
	RETURN GetDlgItem (MdiGetActive (hWndClient), $$IDC_EDIT)
END FUNCTION
'
'
' #############################
' #####  MdiGetActive ()  #####
' #############################
'
FUNCTION MdiGetActive (hWnd)
	RETURN SendMessageA (hWnd, $$WM_MDIGETACTIVE, 0, 0)
END FUNCTION
'
'
' ########################################
' #####  SED_ReadWindowPlacement ()  #####
' ########################################
'
' *****************************************
' Restores the window's state and placement
' *****************************************
'
FUNCTION SED_ReadWindowPlacement (hWnd)

	WINDOWPLACEMENT WinPla
	RECT rcDesktop
	RECT rc
	SHARED IniFile$

	WinPla.length = SIZE (WinPla)
	IF WinPla.showCmd = $$SW_SHOWMAXIMIZED THEN Zoomed = $$TRUE
	rs$ = IniRead (IniFile$, "Window Placement", "Zoomed", "")
	IF rs$ THEN Zoomed = XLONG (rs) ELSE RETURN
	WinPla.rcNormalPosition.left = XLONG (IniRead (IniFile$, "Window Placement", "Left", ""))
	WinPla.rcNormalPosition.right = XLONG (IniRead (IniFile$, "Window Placement", "Right", ""))
	WinPla.rcNormalPosition.top = XLONG (IniRead (IniFile$, "Window Placement", "Top", ""))
	WinPla.rcNormalPosition.bottom = XLONG (IniRead (IniFile$, "Window Placement", "Bottom", ""))

	' There is already an option to decide if it must we show the window maximized or not
	' IF Zoomed THEN WinPla.showCmd = $$SW_SHOWMAXIMIZED
	WinPla.showCmd = 0

	SystemParametersInfoA ($$SPI_GETWORKAREA, 0, &rcDesktop, 0)		'Desktop's real size, thanks to Borje

	' Make sure dialog is not horizontally oversized.
	IF WinPla.rcNormalPosition.right - WinPla.rcNormalPosition.left > rcDesktop.right THEN
		WinPla.rcNormalPosition.left = 0
		WinPla.rcNormalPosition.right = rcDesktop.right
	END IF

	' Make sure dialog is not vertically oversized.
	IF WinPla.rcNormalPosition.bottom - WinPla.rcNormalPosition.top > rcDesktop.bottom THEN
		WinPla.rcNormalPosition.top = 0
		WinPla.rcNormalPosition.bottom = rcDesktop.bottom
	END IF

	' Make sure left side of dialog is visible.
	IF WinPla.rcNormalPosition.left < 0 THEN
		WinPla.rcNormalPosition.right = WinPla.rcNormalPosition.right - WinPla.rcNormalPosition.left
		WinPla.rcNormalPosition.left = 0
	END IF

	' Make sure right side of dialog is visible.
	IF WinPla.rcNormalPosition.right > rcDesktop.right THEN
		WinPla.rcNormalPosition.left = WinPla.rcNormalPosition.left - (WinPla.rcNormalPosition.right - rcDesktop.right)
		WinPla.rcNormalPosition.right = rcDesktop.right
	END IF

	' Make sure top side of dialog is visible.
	IF WinPla.rcNormalPosition.top < 0 THEN
		WinPla.rcNormalPosition.bottom = WinPla.rcNormalPosition.bottom - WinPla.rcNormalPosition.top
		WinPla.rcNormalPosition.top = 0
	END IF

	' Make sure bottom side of dialog is visible.
	IF WinPla.rcNormalPosition.bottom > rcDesktop.bottom THEN
		WinPla.rcNormalPosition.top = WinPla.rcNormalPosition.top - (WinPla.rcNormalPosition.bottom - rcDesktop.bottom)
		WinPla.rcNormalPosition.bottom = rcDesktop.bottom
	END IF

	SystemParametersInfoA ($$SPI_GETWORKAREA, 0, &rc, 0)
	IF WinPla.rcNormalPosition.left = rc.left && WinPla.rcNormalPosition.right = rc.right THEN WinPla.rcNormalPosition.right = WinPla.rcNormalPosition.right + 2
	IF WinPla.rcNormalPosition.top = rc.top && WinPla.rcNormalPosition.bottom = rc.bottom THEN WinPla.rcNormalPosition.bottom = WinPla.rcNormalPosition.bottom + 2

	WinPla.length = SIZE (WinPla)
	SetWindowPlacement (hWnd, &WinPla)

END FUNCTION
'
'
' ########################
' #####  IniRead ()  #####
' ########################
'
' Description : Reads data from the Applications INI file.
' Usage       : sText$ = IniRead ("INIFILE", "SECTION", "KEY", "DEFAULT")
'             : lVal  = XLONG (IniRead ("INIFILE", "SECTION", "KEY", "DEFAULT"))
'
FUNCTION STRING IniRead (sIniFile$, sSection$, sKey$, sDefault$)

	sData$ = NULL$ (150)
	lResult = GetPrivateProfileStringA (&sSection$, &sKey$, &sDefault$, &sData$, LEN (sData$), &sIniFile$)

	RETURN CSIZE$ (sData$)

END FUNCTION
'
'
' #########################
' #####  CodeProc ()  #####
' #########################
'
' MDI child windows's procedure
' This handles messages for the MDI child windows.
'
FUNCTION CodeProc (hWnd, wMsg, wParam, lParam)

	TEXTRANGE txtrg
	WIN32_FIND_DATA WFD
	POINT pt
	RECT rc
	SciColorsAndFontsType ColOpt

	SHARED ghTabMdi, hCodeFinder, hWndClient
	SHARED SED_SavePos SED_LastPosition		' Last position/file name
	SHARED fClosed
	SHARED strContextMenu$		' Context menu non fixed string
	SHARED hWndMain

	CHARMAPINFO cmi

	SELECT CASE wMsg

		CASE $$WM_CREATE :
			' Creates an instance of the Scintilla control
			' and loads the file if it is an open action
			hSci = CreateSciControl (hWnd)
			' Insert new tab
			nTab = SendMessageA (ghTabMdi, $$TCM_GETITEMCOUNT, 0, 0)
			szText$ = GetWindowText$ (hWnd)
			XstGetPathComponents (szText$, "", "", "", @szText$, 0)
			InsertTabMdiItem (ghTabMdi, nTab, szText$)
			' Set it as the current selection on the tab control
			SendMessageA (ghTabMdi, $$TCM_SETCURSEL, nTab, 0)
			InvalidateRect (ghTabMdi, NULL, 1)
			RETURN

		CASE $$WM_SIZE :
			' Resize the child window
			MoveWindow (GetDlgItem (hWnd, $$IDC_EDIT), 0, 0, LOWORD (lParam), HIWORD (lParam), $$TRUE)

		CASE $$WM_SETFOCUS :
			' Post a message to restore the focus later
			' (some actions can steal the focus if we set it now)
			PostMessageA (hWnd, $$WM_USER + 999, GetEdit (), 0)
			RETURN

		CASE $$WM_USER + 999 :
			' Get the path from the window caption
			szText$ = GetWindowText$ (hWnd)
			' Get the time the file was last written
			fTime = SED_GetFileTime (szText$)
			' Get the stored time
			fSavedTime = GetPropA (hWnd, &"FTIME")
			' If they are different ask for reloading else store the new time
			IF fSavedTime THEN
				IF fSavedTime <> fTime THEN
					IF SED_MsgBox (hWnd, szText$ + "\r\n" + "File was changed by another application. Reload it?  ", $$MB_YESNO, "File Modified Externally") = $$IDYES THEN
						OpenThisFile (szText$)
					ELSE
						SetPropA (hWnd, &"FTIME", fTime)
					END IF
				END IF
			END IF
			IF wParam THEN SetFocus (wParam)		' Set the focus
			ShowLinCol ()		' Show line and column
			XstGetPathComponents (szText$, "", "", "", @szText$, 0)
			EnumMdiTitleToTab (szText$)		' activate the associated tab
			RETURN

		CASE $$WM_DRAWITEM :
			' The ownerdraw menu needs to redraw
			IFZ wParam THEN				' If identifier is 0, message was sent by a menu
				DrawMenu (lParam)		' Draw the menu
				RETURN ($$TRUE)
			END IF

		CASE $$WM_MEASUREITEM :						' Get menu item size
			IFZ wParam THEN									' A menu is calling
				MeasureMenu (hWnd, lParam)		' Do all work in separate Sub
				RETURN ($$TRUE)
			END IF

		CASE $$WM_CONTEXTMENU :
'			x = 0 : y = 0 : buffer$ = ""
			' Retrieve the current position

			curPos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
			GetWordAtPosition (curPos, @buffer$)

'			' Retrieve the starting position of the word
'			x = SendMessageA (GetEdit (), $$SCI_WORDSTARTPOSITION, curPos, 1)
'			' Retrieve the ending position of the word
'			y = SendMessageA (GetEdit (), $$SCI_WORDENDPOSITION, curPos, 0)
'			IF y > x THEN
'				buffer$ = NULL$ (y - x + 1)
'				' Text range
'				txtrg.chrg.cpMin = x
'				txtrg.chrg.cpMax = y
'				txtrg.lpstrText = &buffer$
'				SendMessageA (GetEdit (), $$SCI_GETTEXTRANGE, 0, &txtrg)
'				buffer$ = CSIZE$ (buffer$)
'			END IF
'			buffer$ = TRIM$ (buffer$)
'			' buffer$ = REMOVE$(buffer, ANY "()$$,")   '???

			hPopupMenu = CreatePopupMenu ()
			szText$ = GetWindowText$ (hWnd)
			XstGetPathComponents (szText$, "", "", "", @szText$, 0)

			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_UNDO, GetMenuTextAndBitmap ($$IDM_UNDO, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_REDO, GetMenuTextAndBitmap ($$IDM_REDO, 0))
			' AppendMenu hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, "")
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CUT, GetMenuTextAndBitmap ($$IDM_CUT, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_COPY, GetMenuTextAndBitmap ($$IDM_COPY, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_PASTE, GetMenuTextAndBitmap ($$IDM_PASTE, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CLEAR, GetMenuTextAndBitmap ($$IDM_CLEAR, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CLEARALL, GetMenuTextAndBitmap ($$IDM_CLEARALL, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_LINEDELETE, GetMenuTextAndBitmap ($$IDM_LINEDELETE, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_SELECTALL, GetMenuTextAndBitmap ($$IDM_SELECTALL, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_BLOCKINDENT, GetMenuTextAndBitmap ($$IDM_BLOCKINDENT, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_BLOCKUNINDENT, GetMenuTextAndBitmap ($$IDM_BLOCKUNINDENT, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_COMMENT, GetMenuTextAndBitmap ($$IDM_COMMENT, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_UNCOMMENT, GetMenuTextAndBitmap ($$IDM_UNCOMMENT, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_FORMATREGION, GetMenuTextAndBitmap ($$IDM_FORMATREGION, 0))
			' AppendMenuA (hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, "")
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_SELTOUPPERCASE, GetMenuTextAndBitmap ($$IDM_SELTOUPPERCASE, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_SELTOLOWERCASE, GetMenuTextAndBitmap ($$IDM_SELTOLOWERCASE, 0))

			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CHARMAP, GetMenuTextAndBitmap ($$IDM_CHARMAP, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_OPENASMFILE, GetMenuTextAndBitmap ($$IDM_OPENASMFILE, 0))

			ModifyMenuA (hPopupMenu, $$IDM_UNDO, $$MF_OWNERDRAW, $$IDM_UNDO, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_REDO, $$MF_OWNERDRAW, $$IDM_REDO, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CUT, $$MF_OWNERDRAW, $$IDM_CUT, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_COPY, $$MF_OWNERDRAW, $$IDM_COPY, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_PASTE, $$MF_OWNERDRAW, $$IDM_PASTE, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CLEAR, $$MF_OWNERDRAW, $$IDM_CLEAR, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CLEARALL, $$MF_OWNERDRAW, $$IDM_CLEARALL, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_LINEDELETE, $$MF_OWNERDRAW, $$IDM_LINEDELETE, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_SELECTALL, $$MF_OWNERDRAW, $$IDM_SELECTALL, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_BLOCKINDENT, $$MF_OWNERDRAW, $$IDM_BLOCKINDENT, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_BLOCKUNINDENT, $$MF_OWNERDRAW, $$IDM_BLOCKUNINDENT, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_COMMENT, $$MF_OWNERDRAW, $$IDM_COMMENT, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_UNCOMMENT, $$MF_OWNERDRAW, $$IDM_UNCOMMENT, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_FORMATREGION, $$MF_OWNERDRAW, $$IDM_FORMATREGION, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_SELTOUPPERCASE, $$MF_OWNERDRAW, $$IDM_SELTOUPPERCASE, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_SELTOLOWERCASE, $$MF_OWNERDRAW, $$IDM_SELTOLOWERCASE, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CHARMAP, $$MF_OWNERDRAW, $$IDM_CHARMAP, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_OPENASMFILE, $$MF_OWNERDRAW, $$IDM_OPENASMFILE, NULL)

			' IF UCASE$(RIGHT$(buffer$,2)) = ".X" || UCASE$(RIGHT$(buffer$, 4)) = ".XBL" || UCASE$(RIGHT$(buffer$, 4)) = ".DEC" THEN
			' AppendMenuA (hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
			' strContextMenu$ = buffer$
			' AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_GOTOSELFILE, &strContextMenu$)
			' ModifyMenuA (hPopupMenu, $$IDM_GOTOSELFILE, $$MF_OWNERDRAW, $$IDM_GOTOSELFILE, NULL)
			' ELSE
			IF buffer$ THEN
				AppendMenuA (hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
				strContextMenu$ = buffer$
				IF LEN (strContextMenu$) > 64 THEN strContextMenu$ = LEFT$ (strContextMenu$, 64)
				AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_GOTOSELPROC, &strContextMenu$)
				ModifyMenuA (hPopupMenu, $$IDM_GOTOSELPROC, $$MF_OWNERDRAW, $$IDM_GOTOSELPROC, NULL)
			END IF
			IF SED_LastPosition.Position <> -1 THEN
				AppendMenuA (hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
				AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_GOTOLASTPOSITION, NULL)
				ModifyMenuA (hPopupMenu, $$IDM_GOTOLASTPOSITION, $$MF_OWNERDRAW, $$IDM_GOTOLASTPOSITION, NULL)
			END IF
			' END IF

			' Remove non-useable menu items to keep size manageable
			IF SendMessageA (GetEdit (), $$SCI_GETSELECTIONSTART, 0, 0) = SendMessageA (GetEdit (), $$SCI_GETSELECTIONEND, 0, 0) THEN
				RemoveMenu (hPopupMenu, $$IDM_CUT, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_COPY, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_CLEAR, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_BLOCKINDENT, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_BLOCKUNINDENT, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_COMMENT, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_UNCOMMENT, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_FORMATREGION, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_SELTOUPPERCASE, $$MF_BYCOMMAND)
				RemoveMenu (hPopupMenu, $$IDM_SELTOLOWERCASE, $$MF_BYCOMMAND)
			END IF

			IFZ SendMessageA (GetEdit (), $$SCI_CANUNDO, 0, 0) THEN
				RemoveMenu (hPopupMenu, $$IDM_UNDO, $$MF_BYCOMMAND)
			END IF
			IFZ SendMessageA (GetEdit (), $$SCI_CANREDO, 0, 0) THEN
				RemoveMenu (hPopupMenu, $$IDM_REDO, $$MF_BYCOMMAND)
			END IF
			IFZ SendMessageA (GetEdit (), $$SCI_CANPASTE, 0, 0) THEN
				RemoveMenu (hPopupMenu, $$IDM_PASTE, $$MF_BYCOMMAND)
			END IF

			GetCursorPos (&pt)
			TrackPopupMenu (hPopupMenu, 0, pt.x, pt.y, 0, hWnd, 0)
			DestroyMenu (hPopupMenu)
			UpdateWindow (GetEdit ())

		CASE $$WM_COMMAND :

			SELECT CASE LOWORD (wParam)

				CASE $$IDM_UNDO 					: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_UNDO, 0)
				CASE $$IDM_REDO 					: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_REDO, 0)
				CASE $$IDM_CLEAR 					: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_CLEAR, 0)
				CASE $$IDM_CLEARALL 			: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_CLEARALL, 0)
				CASE $$IDM_CUT 						: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_CUT, 0)
				CASE $$IDM_COPY 					: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_COPY, 0)
				CASE $$IDM_PASTE 					: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_PASTE, 0)
				CASE $$IDM_SELECTALL 			: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_SELECTALL, 0)
				CASE $$IDM_LINEDELETE 		: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_LINEDELETE, 0)
				CASE $$IDM_BLOCKINDENT 		: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_BLOCKINDENT, 0)
				CASE $$IDM_BLOCKUNINDENT 	: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_BLOCKUNINDENT, 0)
				CASE $$IDM_COMMENT 				: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_COMMENT, 0)
				CASE $$IDM_UNCOMMENT 			: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_UNCOMMENT, 0)
				CASE $$IDM_FORMATREGION 	: SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_FORMATREGION, 0)
				CASE $$IDM_SELTOUPPERCASE : SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_SELTOUPPERCASE, 0)
				CASE $$IDM_SELTOLOWERCASE : SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_SELTOLOWERCASE, 0)

				CASE $$IDM_CHARMAP :
					' Display character map
					GetColorOptions (@ColOpt)
					cmi.font = ColOpt.DefaultFontName
					cmi.fontsize = 10
					cmi.zoomfontsize = 48
					GetClientRect (hWnd, &rc)
					pt.x = rc.right/2 - 310/2
					pt.y = rc.bottom/2 - 328/2
					ClientToScreen (hWnd, &pt)
					ID = NewDialogBox (hWnd, pt.x, pt.y, 0, 0, &CharMapProc(), &cmi)

				CASE $$IDM_OPENASMFILE :
					' get currently active file name
					file$ = GetWindowText$ (hWnd)
					XstGetPathComponents (file$, @path$, @drive$, @dir$, @fileName$, @attributes)
					GetFileExtension (fileName$, @f$, @ext$)
					' get current position and line
					curPos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
					nLine = SendMessageA (GetEdit (), $$SCI_LINEFROMPOSITION, curPos, 0) + 1

					SELECT CASE LCASE$(ext$)
						CASE "x", "xl", "xbl" :
							' make asm file path
							asmPath$ = path$ + f$ + ".asm"
							IF XstFileExists (asmPath$) THEN
								' file not found, show error message
								SED_MsgBox (hWnd, "Assembly file not found. Please compile program.  ", 0, "View Assembly File Error")
							ELSE
								' file exists
								' check if it is already displayed
								' find mdi window corresponding to asmPath$, activate it,
								' and then scroll to line corresponding to line in xblite file
                hMdi = GetWindow (hWndClient, $$GW_CHILD)		' first look at already opened docs

                DO WHILE hMdi
		              text$ = GetWindowText$ (hMdi)
                  IF UCASE$ (text$) = UCASE$ (asmPath$) THEN		' if already opened
                    SendMessageA (hWndClient, $$WM_MDIACTIVATE, hMdi, 0)		' activate it
                    XstGetPathComponents (asmPath$, "", "", "", @fn$, 0)
                    EnumMdiTitleToTab (fn$)   ' activate the associated tab
										found = $$TRUE
									  EXIT DO
									END IF
									hMdi = GetWindow (hMdi, $$GW_HWNDNEXT)
								LOOP

								' at this point asmPath$ is not currently open, so try to open file?
								IFZ found THEN
									IFZ OpenThisFile (asmPath$) THEN RETURN
									found = $$TRUE
								END IF

								IF found THEN
									' search for [] line in asm file
									srch$ = "; [" + STRING$ (nLine) + "]"
									' set the start and end positions and the find flag
									startPos = 0
									SendMessageA (GetEdit (), $$SCI_SETTARGETSTART, startPos, 0)
									endPos = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
									SendMessageA (GetEdit (), $$SCI_SETTARGETEND, endPos, 0)
									pos = SendMessageA (GetEdit (), $$SCI_SEARCHINTARGET, LEN (srch$), &srch$)
									IF pos <> -1 THEN
										SendMessageA (GetEdit (), $$SCI_GOTOPOS, pos, 0)
									END IF
									SetFocus (GetEdit ())
								END IF
							END IF
					END SELECT

				CASE $$IDM_GOTOSELPROC :
					' Retrieve the name of the function under the caret
					' Needed to get Ctrl+F7 to work
					x = 0 : y = 0 : buffer$ = ""
					' Retrieve the current position
					curPos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
					' Retrieve the starting position of the word
					x = SendMessageA (GetEdit (), $$SCI_WORDSTARTPOSITION, curPos, $$TRUE)
					' Retrieve the ending position of the word
					y = SendMessageA (GetEdit (), $$SCI_WORDENDPOSITION, curPos, $$FALSE)
					IF y > x THEN
						buffer$ = NULL$ (y - x + 1)
						' Text range
						txtrg.chrg.cpMin = x
						txtrg.chrg.cpMax = y
						txtrg.lpstrText = &buffer$
						SendMessageA (GetEdit (), $$SCI_GETTEXTRANGE, 0, &txtrg)
						buffer$ = CSIZE$ (buffer$)
					END IF
					buffer$ = TRIM$ (buffer$)
					' buffer = REMOVE$(buffer, ANY CHR$(13, 10))
					' buffer = REMOVE$(buffer, ANY "()$$,")
					' -----------------------------------------------------------------
					SED_CodeFinder (0)
					x = SendMessageA (hCodeFinder, $$CB_FINDSTRINGEXACT, 0, &buffer$)
'					Sleep (1000)
					IF x <> $$CB_ERR THEN
						SED_LastPosition.Position = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
						SED_LastPosition.FileName = GetWindowText$ (hWnd)
						y = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
						' Set to end position of document
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, y, 0)
						' Set function or procedure to top of editor
						p = SendMessageA (hCodeFinder, $$CB_GETITEMDATA, x, 0)
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, p, 0)
						SetFocus (GetEdit ())
					ELSE
'						SED_MsgBox (0, buffer$ + " function not found.  ", $$MB_OK, " Function Definition not found.")
						' If not found, call the normal help
						SendMessageA (hWndMain, $$WM_COMMAND, $$IDM_HELP, 0)
					END IF

				CASE $$IDM_GOTOLASTPOSITION :
' this doesn't work or make sense
' ====================================
'					dwRes = GetWindow (hWndClient, $$GW_CHILD)
					' Find matching child window
'					DO WHILE dwRes <> 0
'						szText$ = GetWindowText$ (dwRes)
'						IF UCASE$ (szText$) = UCASE$ (SED_LastPosition.FileName) THEN
'							nTab = MdiGetActive (dwRes)
'							MdiNext (hWndClient, nTab, 0)
'						END IF
'						dwRes = GetWindow (dwRes, $$GW_HWNDNEXT)
'					LOOP
'					IFZ dwRes THEN OpenThisFile (SED_LastPosition.FileName)
' =====================================

					activePath$ = GetWindowText$ (MdiGetActive (hWndClient))
					IF UCASE$ (activePath$) = UCASE$ (SED_LastPosition.FileName) THEN
						y = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
						' Set to end position of document
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, y, 0)
						' Set function or procedure to top of editor
						SendMessageA (GetEdit (), $$SCI_GOTOPOS, SED_LastPosition.Position, 0)
						SED_LastPosition.Position = -1
						SetFocus (GetEdit ())
					END IF

			END SELECT

		CASE $$WM_CLOSE
			' Retrieve the path and file name from the window's caption
		  szText$ = GetWindowText$ (hWnd)
			' See if the document has been modified
			IF SendMessageA (GetEdit (), $$SCI_GETMODIFY, 0, 0) THEN
				' Ask if the user wants to save the changes, save them if he clicks yes
				' and set the global fClosed flag to true.
				XstGetPathComponents (szText$, "", "", "", @fn$, 0)
				msg$ = " Save current changes? " + fn$
				RetVal = MessageBoxA (hWnd, &msg$, &" XSED", $$MB_YESNOCANCEL OR $$MB_ICONEXCLAMATION OR $$MB_APPLMODAL)
				IF RetVal = $$IDCANCEL THEN
					fClosed = $$FALSE
					RETURN
				ELSE
					fClosed = $$TRUE
					IF RetVal = $$IDYES THEN SaveFile (hWnd, $$FALSE)
				END IF
			ELSE
				fClosed = $$TRUE
			END IF

			' save recent file position and bookmarks
	    WriteRecentFile (GetEdit (), szText$)

			' Remove the associated tab
			szText$ = GetWindowText$ (hWnd)
			ret = EnumMdiTitleToTabRemove (szText$)

			' Remove the FTIME property
			RemovePropA (hWnd, &"FTIME")

			' See if there are more child windows opened
			h = GetWindow (hWndClient, $$GW_CHILD)
			hNext = GetWindow (h, $$GW_HWNDNEXT)
			IFZ hNext THEN		' If this is last document
				ClearStatusbar ()		' Clear the status bar
			ELSE
				' Activates the associated tab of the new active window
				szText$ = GetWindowText$ (hNext)
				IF szText$ THEN
					XstGetPathComponents (szText$, "", "", "", @szText$, 0)
					EnumMdiTitleToTab (szText$)
				END IF
			END IF

			' clear & hide console
'			ClearConsole ()
'			HideConsole ()

		CASE $$WM_NOTIFY
			' Process Scintilla control notification messages
			IF LOWORD (wParam) = $$IDC_EDIT THEN Sci_OnNotify (hWnd, wParam, lParam)

	END SELECT

	' Pass the message to the default MDI procedure
	RETURN DefMDIChildProcA (hWnd, wMsg, wParam, lParam)

END FUNCTION
'
'
' #################################
' #####  GetEditorOptions ()  #####
' #################################
'
FUNCTION GetEditorOptions (EditorOptionsType EdOpt)

	STRING rs
	SHARED IniFile$
	SHARED fMaximize
	SHARED TrimTrailingBlanks, ShowProcedureName, UpperCaseKeywords
	SHARED CURDIR$

	XstGetCurrentDirectory (@CURDIR$)

	rs = IniRead (IniFile$, "Editor options", "UseTabs", "")
	IF rs THEN EdOpt.UseTabs = XLONG (rs) ELSE EdOpt.UseTabs = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "TabSize", "")
	IF rs THEN EdOpt.TabSize = XLONG (rs) ELSE EdOpt.TabSize = 2
	rs = IniRead (IniFile$, "Editor options", "AutoIndent", "")
	IF rs THEN EdOpt.AutoIndent = XLONG (rs) ELSE EdOpt.AutoIndent = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "IndentSize", "")
	IF rs THEN EdOpt.IndentSize = XLONG (rs) ELSE EdOpt.IndentSize = 2
	rs = IniRead (IniFile$, "Editor options", "LineNumbers", "")
	IF rs THEN EdOpt.LineNumbers = XLONG (rs) ELSE EdOpt.LineNumbers = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "LineNumbersWidth", "")
	IF rs THEN EdOpt.LineNumbersWidth = XLONG (rs) ELSE EdOpt.LineNumbersWidth = 50
	rs = IniRead (IniFile$, "Editor options", "Margin", "")
	IF rs THEN EdOpt.Margin = XLONG (rs) ELSE EdOpt.Margin = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "MarginWidth", "")
	IF rs THEN EdOpt.MarginWidth = XLONG (rs) ELSE EdOpt.MarginWidth = 20
	rs = IniRead (IniFile$, "Editor options", "EdgeColumn", "")
	IF rs THEN EdOpt.EdgeColumn = XLONG (rs) ELSE EdOpt.EdgeColumn = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "EdgeWidth", "")
	IF rs THEN EdOpt.EdgeWidth = XLONG (rs) ELSE EdOpt.EdgeWidth = 255
	rs = IniRead (IniFile$, "Editor options", "IndentGuides", "")
	IF rs THEN EdOpt.IndentGuides = XLONG (rs) ELSE EdOpt.IndentGuides = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "Magnification", "")
	EdOpt.Magnification = XLONG (rs)
	rs = IniRead (IniFile$, "Editor options", "WhiteSpace", "")
	IF rs THEN EdOpt.WhiteSpace = XLONG (rs) ELSE EdOpt.WhiteSpace = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "EndOfLine", "")
	IF rs THEN EdOpt.EndOfLine = XLONG (rs) ELSE EdOpt.EndOfLine = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "SyntaxHighlighting", "")
	IF rs THEN EdOpt.SyntaxHighlighting = XLONG (rs) ELSE EdOpt.SyntaxHighlighting = $$BST_CHECKED
'	rs = IniRead (IniFile$, "Editor options", "CodeTips", "")
'	EdOpt.CodeTips = XLONG (rs)
	rs = IniRead (IniFile$, "Editor options", "MaximizeMainWindow", "")
	EdOpt.MaximizeMainWindow = XLONG (rs)
	rs = IniRead (IniFile$, "Editor options", "MaximizeEditWindows", "")
	IF rs THEN EdOpt.MaximizeEditWindows = XLONG (rs) ELSE EdOpt.MaximizeEditWindows = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "AskBeforeExit", "")
	IF rs THEN EdOpt.AskBeforeExit = XLONG (rs) ELSE EdOpt.AskBeforeExit = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "AllowMultipleInstances", "")
	IF rs THEN EdOpt.AllowMultipleInstances = XLONG (rs) ELSE EdOpt.AllowMultipleInstances = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "TrimTrailingBlanks", "")
	IF rs THEN EdOpt.TrimTrailingBlanks = XLONG (rs) ELSE EdOpt.TrimTrailingBlanks = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "ShowProcedureName", "")
	IF rs THEN EdOpt.ShowProcedureName = XLONG (rs) ELSE EdOpt.ShowProcedureName = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "UpperCaseKeywords", "")
	IF rs THEN EdOpt.UpperCaseKeywords = XLONG (rs) ELSE EdOpt.UpperCaseKeywords = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "ShowCaretLine", "")
	IF rs THEN EdOpt.ShowCaretLine = XLONG (rs) ELSE EdOpt.ShowCaretLine = $$BST_CHECKED
	rs = IniRead (IniFile$, "Editor options", "StartInLastFolder", "")
	IF rs THEN EdOpt.StartInLastFolder = XLONG (rs) ELSE EdOpt.StartInLastFolder = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "LastFolder", "")
	IF rs THEN EdOpt.LastFolder = rs ELSE EdOpt.LastFolder = CURDIR$
	rs = IniRead (IniFile$, "Editor options", "ReloadFilesAtStartup", "")
	IF rs THEN EdOpt.ReloadFilesAtStartup = XLONG (rs) ELSE EdOpt.ReloadFilesAtStartup = $$BST_UNCHECKED
	rs = IniRead (IniFile$, "Editor options", "BackupEditorFiles", "")
	IF rs THEN EdOpt.BackupEditorFiles = XLONG (rs) ELSE EdOpt.BackupEditorFiles = $$BST_CHECKED

	IF EdOpt.MaximizeEditWindows = $$BST_CHECKED THEN fMaximize = $$TRUE ELSE fMaximize = $$FALSE
	IF EdOpt.TrimTrailingBlanks = $$BST_CHECKED THEN TrimTrailingBlanks = $$TRUE ELSE TrimTrailingBlanks = $$FALSE
	IF EdOpt.ShowProcedureName = $$BST_CHECKED THEN ShowProcedureName = $$TRUE ELSE ShowProcedureName = $$FALSE
	IF EdOpt.UpperCaseKeywords = $$BST_CHECKED THEN UpperCaseKeywords = $$TRUE ELSE UpperCaseKeywords = $$FALSE
	CheckMenuOptions (@EdOpt)

END FUNCTION
'
'
' ###################################
' #####  ChangeButtonsState ()  #####
' ###################################
'
FUNCTION ChangeButtonsState ()

	SHARED hToolbar

	' Retrieves the handle of the edit window
	hSci = GetEdit ()
	' Disables toolbar buttons if there is not any file being edited
	IFZ hSci THEN
		DisableToolbarButtons ()
		RETURN
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_SAVEAS, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_SAVEAS, $$TRUE)
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_REFRESH, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_REFRESH, $$TRUE)
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_FIND, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_FIND, $$TRUE)
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_REPLACE, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_REPLACE, $$TRUE)
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_COMPILE, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_COMPILE, $$TRUE)
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_BUILD, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_BUILD, $$TRUE)
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_EXECUTE, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_EXECUTE, $$TRUE)
	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDT_PRINT, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDT_PRINT, $$TRUE)
	END IF

'	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_PRINTPREVIEW, 0) THEN
'		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_PRINTPREVIEW, $$TRUE)
'	END IF

	IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_CLOSEFILE, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_CLOSEFILE, $$TRUE)
	END IF

	IFZ SendMessageA (GetEdit, $$SCI_CANPASTE, 0, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_PASTE, $$FALSE)
	ELSE
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_PASTE, $$TRUE)
	END IF

	IF SendMessageA (GetEdit (), $$SCI_GETSELECTIONSTART, 0, 0) = SendMessageA (GetEdit (), $$SCI_GETSELECTIONEND, 0, 0) THEN
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_CUT, $$FALSE)
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_COPY, $$FALSE)
	ELSE
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_CUT, $$TRUE)
		SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_COPY, $$TRUE)
	END IF

	' Retrieves if the file has been modified since the last saving
	' and disable or enable the Save button.
	fModify = SendMessageA (hSci, $$SCI_GETMODIFY, 0, 0)
	IFZ fModify THEN
		IF SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_SAVE, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_SAVE, $$FALSE)
		END IF
	ELSE
		IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_SAVE, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_SAVE, $$TRUE)
		END IF
	END IF

	' Disable or enable the undo button
	IFZ SendMessageA (hSci, $$SCI_CANUNDO, 0, 0) THEN
		IF SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_UNDO, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_UNDO, $$FALSE)
		END IF
	ELSE
		IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_UNDO, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_UNDO, $$TRUE)
		END IF
	END IF

	' Disable or enable the redo button
	IFZ SendMessageA (hSci, $$SCI_CANREDO, 0, 0) THEN
		IF SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_REDO, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_REDO, $$FALSE)
		END IF
	ELSE
		IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_REDO, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_REDO, $$TRUE)
		END IF
	END IF

	' Disable or enable the paste button
	IFZ SendMessageA (hSci, $$SCI_CANPASTE, 0, 0) THEN
		IF SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_PASTE, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_PASTE, $$FALSE)
		END IF
	ELSE
		IFZ SendMessageA (hToolbar, $$TB_ISBUTTONENABLED, $$IDM_PASTE, 0) THEN
			SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_PASTE, $$TRUE)
		END IF
	END IF

END FUNCTION
'
'
' ######################################
' #####  DisableToolbarButtons ()  #####
' ######################################
'
FUNCTION DisableToolbarButtons ()

	SHARED hToolbar

	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_SAVE, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_SAVEAS, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_REFRESH, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_UNDO, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_REDO, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_CUT, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_COPY, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_PASTE, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_FIND, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_REPLACE, $$FALSE)

	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_COMPILE, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_BUILD, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_EXECUTE, $$FALSE)

	' SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_COMPILEANDRUN, $$FALSE
	' SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_COMPILEANDDEBUG, $$FALSE)

	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDT_PRINT, $$FALSE)
	' SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_PRINTPREVIEW, $$FALSE)
	SendMessageA (hToolbar, $$TB_ENABLEBUTTON, $$IDM_CLOSEFILE, $$FALSE)

END FUNCTION
'
'
' ################################
' #####  GetColorOptions ()  #####
' ################################
'
FUNCTION GetColorOptions (SciColorsAndFontsType ColOpt)

	STRING rs
	SHARED IniFile$

	' Default
	rs = IniRead (IniFile$, "Color options", "DefaultForeColor", "")
	IF rs THEN ColOpt.DefaultForeColor = XLONG (rs) ELSE ColOpt.DefaultForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "DefaultBackColor", "")
	IF rs THEN ColOpt.DefaultBackColor = XLONG (rs) ELSE ColOpt.DefaultBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "DefaultFontName", "")
	IF rs THEN ColOpt.DefaultFontName = rs ELSE ColOpt.DefaultFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "DefaultFontCharset", "")
	IF rs THEN ColOpt.DefaultFontCharset = rs ELSE ColOpt.DefaultFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "DefaultFontSize", "")
	IF rs THEN ColOpt.DefaultFontSize = XLONG (rs) ELSE ColOpt.DefaultFontSize = 10
	ColOpt.DefaultFontBold = XLONG (IniRead (IniFile$, "Color options", "DefaultFontBold", ""))
	ColOpt.DefaultFontItalic = XLONG (IniRead (IniFile$, "Color options", "DefaultFontItalic", ""))
	ColOpt.DefaultFontUnderline = XLONG (IniRead (IniFile$, "Color options", "DefaultFontUnderline", ""))
	' Comment
	rs = IniRead (IniFile$, "Color options", "CommentForeColor", "")
	IF rs THEN ColOpt.CommentForeColor = XLONG (rs) ELSE ColOpt.CommentForeColor = $$Green
	rs = IniRead (IniFile$, "Color options", "CommentBackColor", "")
	IF rs THEN ColOpt.CommentBackColor = XLONG (rs) ELSE ColOpt.CommentBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "CommentFontName", "")
	IF rs THEN ColOpt.CommentFontName = rs ELSE ColOpt.CommentFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "CommentFontCharset", "")
	IF rs THEN ColOpt.CommentFontCharset = rs ELSE ColOpt.CommentFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "CommentFontSize", "")
	IF rs THEN ColOpt.CommentFontSize = XLONG (rs) ELSE ColOpt.CommentFontSize = 10
	ColOpt.CommentFontBold = XLONG (IniRead (IniFile$, "Color options", "CommentFontBold", ""))
	ColOpt.CommentFontItalic = XLONG (IniRead (IniFile$, "Color options", "CommentFontItalic", ""))
	ColOpt.CommentFontUnderline = XLONG (IniRead (IniFile$, "Color options", "CommentFontUnderline", ""))
	' Constants
	rs = IniRead (IniFile$, "Color options", "ConstantForeColor", "")
	IF rs THEN ColOpt.ConstantForeColor = XLONG (rs) ELSE ColOpt.ConstantForeColor = RGB(222,122,0)
	rs = IniRead (IniFile$, "Color options", "ConstantBackColor", "")
	IF rs THEN ColOpt.ConstantBackColor = XLONG (rs) ELSE ColOpt.ConstantBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "ConstantFontName", "")
	IF rs THEN ColOpt.ConstantFontName = rs ELSE ColOpt.ConstantFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "ConstantFontCharset", "")
	IF rs THEN ColOpt.ConstantFontCharset = rs ELSE ColOpt.ConstantFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "ConstantFontSize", "")
	IF rs THEN ColOpt.ConstantFontSize = XLONG (rs) ELSE ColOpt.ConstantFontSize = 10
	ColOpt.ConstantFontBold = XLONG (IniRead (IniFile$, "Color options", "ConstantFontBold", ""))
	ColOpt.ConstantFontItalic = XLONG (IniRead (IniFile$, "Color options", "ConstantFontItalic", ""))
	ColOpt.ConstantFontUnderline = XLONG (IniRead (IniFile$, "Color options", "ConstantFontUnderline", ""))
	' Identifier
	rs = IniRead (IniFile$, "Color options", "IdentifierForeColor", "")
	IF rs THEN ColOpt.IdentifierForeColor = XLONG (rs) ELSE ColOpt.IdentifierForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "IdentifierBackColor", "")
	IF rs THEN ColOpt.IdentifierBackColor = XLONG (rs) ELSE ColOpt.IdentifierBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "IdentifierFontName", "")
	IF rs THEN ColOpt.IdentifierFontName = rs ELSE ColOpt.IdentifierFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "IdentifierFontCharset", "")
	IF rs THEN ColOpt.IdentifierFontCharset = rs ELSE ColOpt.IdentifierFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "IdentifierFontSize", "")
	IF rs THEN ColOpt.IdentifierFontSize = XLONG (rs) ELSE ColOpt.IdentifierFontSize = 10
	ColOpt.IdentifierFontBold = XLONG (IniRead (IniFile$, "Color options", "IdentifierFontBold", ""))
	ColOpt.IdentifierFontItalic = XLONG (IniRead (IniFile$, "Color options", "IdentifierFontItalic", ""))
	ColOpt.IdentifierFontUnderline = XLONG (IniRead (IniFile$, "Color options", "IdentifierFontUnderline", ""))
	' Keywords
	rs = IniRead (IniFile$, "Color options", "KeywordForeColor", "")
	IF rs THEN ColOpt.KeywordForeColor = XLONG (rs) ELSE ColOpt.KeywordForeColor = $$LightBlue
	rs = IniRead (IniFile$, "Color options", "KeywordBackColor", "")
	IF rs THEN ColOpt.KeywordBackColor = XLONG (rs) ELSE ColOpt.KeywordBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "KeywordFontName", "")
	IF rs THEN ColOpt.KeywordFontName = rs ELSE ColOpt.KeywordFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "KeywordFontCharset", "")
	IF rs THEN ColOpt.KeywordFontCharset = rs ELSE ColOpt.KeywordFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "KeywordFontSize", "")
	IF rs THEN ColOpt.KeywordFontSize = XLONG (rs) ELSE ColOpt.KeywordFontSize = 10
	ColOpt.KeywordFontBold = XLONG (IniRead (IniFile$, "Color options", "KeywordFontBold", ""))
	ColOpt.KeywordFontItalic = XLONG (IniRead (IniFile$, "Color options", "KeywordFontItalic", ""))
	ColOpt.KeywordFontUnderline = XLONG (IniRead (IniFile$, "Color options", "KeywordFontUnderline", ""))
	' Number
	rs = IniRead (IniFile$, "Color options", "NumberForeColor", "")
	IF rs THEN ColOpt.NumberForeColor = XLONG (rs) ELSE ColOpt.NumberForeColor = $$LightRed
	rs = IniRead (IniFile$, "Color options", "NumberBackColor", "")
	IF rs THEN ColOpt.NumberBackColor = XLONG (rs) ELSE ColOpt.NumberBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "NumberFontName", "")
	IF rs THEN ColOpt.NumberFontName = rs ELSE ColOpt.NumberFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "NumberFontCharset", "")
	IF rs THEN ColOpt.NumberFontCharset = rs ELSE ColOpt.NumberFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "NumberFontSize", "")
	IF rs THEN ColOpt.NumberFontSize = XLONG (rs) ELSE ColOpt.NumberFontSize = 10
	ColOpt.NumberFontBold = XLONG (IniRead (IniFile$, "Color options", "NumberFontBold", ""))
	ColOpt.NumberFontItalic = XLONG (IniRead (IniFile$, "Color options", "NumberFontItalic", ""))
	ColOpt.NumberFontUnderline = XLONG (IniRead (IniFile$, "Color options", "NumberFontUnderline", ""))
	' Line numbers
	rs = IniRead (IniFile$, "Color options", "LineNumberForeColor", "")
	IF rs THEN ColOpt.LineNumberForeColor = XLONG (rs) ELSE ColOpt.LineNumberForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "LineNumberBackColor", "")
	IF rs THEN ColOpt.LineNumberBackColor = XLONG (rs) ELSE ColOpt.LineNumberBackColor = $$LightGrey
	rs = IniRead (IniFile$, "Color options", "LineNumberFontName", "")
	IF rs THEN ColOpt.LineNumberFontName = rs ELSE ColOpt.LineNumberFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "LineNumberFontCharset", "")
	IF rs THEN ColOpt.LineNumberFontCharset = rs ELSE ColOpt.LineNumberFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "LineNumberFontSize", "")
	IF rs THEN ColOpt.LineNumberFontSize = XLONG (rs) ELSE ColOpt.LineNumberFontSize = 10
	ColOpt.LineNumberFontBold = XLONG (IniRead (IniFile$, "Color options", "LineNumberFontBold", ""))
	ColOpt.LineNumberFontItalic = XLONG (IniRead (IniFile$, "Color options", "LineNumberFontItalic", ""))
	ColOpt.LineNumberFontUnderline = XLONG (IniRead (IniFile$, "Color options", "LineNumberFontUnderline", ""))
	' Operators
	rs = IniRead (IniFile$, "Color options", "OperatorForeColor", "")
	IF rs THEN ColOpt.OperatorForeColor = XLONG (rs) ELSE ColOpt.OperatorForeColor = $$LightMagenta
	rs = IniRead (IniFile$, "Color options", "OperatorBackColor", "")
	IF rs THEN ColOpt.OperatorBackColor = XLONG (rs) ELSE ColOpt.OperatorBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "OperatorFontName", "")
	IF rs THEN ColOpt.OperatorFontName = rs ELSE ColOpt.OperatorFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "OperatorFontCharset", "")
	IF rs THEN ColOpt.OperatorFontCharset = rs ELSE ColOpt.OperatorFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "OperatorFontSize", "")
	IF rs THEN ColOpt.OperatorFontSize = XLONG (rs) ELSE ColOpt.OperatorFontSize = 10
	ColOpt.OperatorFontBold = XLONG (IniRead (IniFile$, "Color options", "OperatorFontBold", ""))
	ColOpt.OperatorFontItalic = XLONG (IniRead (IniFile$, "Color options", "OperatorFontItalic", ""))
	ColOpt.OperatorFontUnderline = XLONG (IniRead (IniFile$, "Color options", "OperatorFontUnderline", ""))
	' ASM
	rs = IniRead (IniFile$, "Color options", "ASMForeColor", "")
	IF rs THEN ColOpt.ASMForeColor = XLONG (rs) ELSE ColOpt.ASMForeColor = $$Brown
	rs = IniRead (IniFile$, "Color options", "ASMBackColor", "")
	IF rs THEN ColOpt.ASMBackColor = XLONG (rs) ELSE ColOpt.ASMBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "ASMFontName", "")
	IF rs THEN ColOpt.ASMFontName = rs ELSE ColOpt.ASMFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "ASMFontCharset", "")
	IF rs THEN ColOpt.ASMFontCharset = rs ELSE ColOpt.ASMFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "ASMFontSize", "")
	IF rs THEN ColOpt.ASMFontSize = XLONG (rs) ELSE ColOpt.ASMFontSize = 10
	ColOpt.ASMFontBold = XLONG (IniRead (IniFile$, "Color options", "ASMFontBold", ""))
	ColOpt.ASMFontItalic = XLONG (IniRead (IniFile$, "Color options", "ASMFontItalic", ""))
	ColOpt.ASMFontUnderline = XLONG (IniRead (IniFile$, "Color options", "ASMFontUnderline", ""))
	' Strings
	rs = IniRead (IniFile$, "Color options", "StringForeColor", "")
	IF rs THEN ColOpt.StringForeColor = XLONG (rs) ELSE ColOpt.StringForeColor = $$BrightRed
	rs = IniRead (IniFile$, "Color options", "StringBackColor", "")
	IF rs THEN ColOpt.StringBackColor = XLONG (rs) ELSE ColOpt.StringBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "StringFontName", "")
	IF rs THEN ColOpt.StringFontName = rs ELSE ColOpt.StringFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "StringFontCharset", "")
	IF rs THEN ColOpt.StringFontCharset = rs ELSE ColOpt.StringFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "StringFontSize", "")
	IF rs THEN ColOpt.StringFontSize = XLONG (rs) ELSE ColOpt.StringFontSize = 10
	ColOpt.StringFontBold = XLONG (IniRead (IniFile$, "Color options", "StringFontBold", ""))
	ColOpt.StringFontItalic = XLONG (IniRead (IniFile$, "Color options", "StringFontItalic", ""))
	ColOpt.StringFontUnderline = XLONG (IniRead (IniFile$, "Color options", "StringFontUnderline", ""))
	' Caret
	rs = IniRead (IniFile$, "Color options", "CaretForeColor", "")
	IF rs THEN ColOpt.CaretForeColor = XLONG (rs) ELSE ColOpt.CaretForeColor = $$Black
	' Edge
	rs = IniRead (IniFile$, "Color options", "EdgeForeColor", "")
	IF rs THEN ColOpt.EdgeForeColor = XLONG (rs) ELSE ColOpt.EdgeForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "EdgeBackColor", "")
	IF rs THEN ColOpt.EdgeBackColor = XLONG (rs) ELSE ColOpt.EdgeBackColor = $$White
	' Fold
	rs = IniRead (IniFile$, "Color options", "FoldForeColor", "")
	IF rs THEN ColOpt.FoldForeColor = XLONG (rs) ELSE ColOpt.FoldForeColor = $$LightRed
	rs = IniRead (IniFile$, "Color options", "FoldBackColor", "")
	IF rs THEN ColOpt.FoldBackColor = XLONG (rs) ELSE ColOpt.FoldBackColor = $$White
	' Fold open
	rs = IniRead (IniFile$, "Color options", "FoldOpenForeColor", "")
	IF rs THEN ColOpt.FoldOpenForeColor = XLONG (rs) ELSE ColOpt.FoldOpenForeColor = $$LightRed
	rs = IniRead (IniFile$, "Color options", "FoldOpenBackColor", "")
	IF rs THEN ColOpt.FoldOpenBackColor = XLONG (rs) ELSE ColOpt.FoldOpenBackColor = $$White
	' Fold margin
	rs = IniRead (IniFile$, "Color options", "FoldMarginForeColor", "")
	IF rs THEN ColOpt.FoldMarginForeColor = XLONG (rs) ELSE ColOpt.FoldMarginForeColor = RGB (200, 0, 200)
	rs = IniRead (IniFile$, "Color options", "FoldMarginBackColor", "")
	IF rs THEN ColOpt.FoldMarginBackColor = XLONG (rs) ELSE ColOpt.FoldMarginBackColor = RGB (100, 0, 100)
	' Indent guides
	rs = IniRead (IniFile$, "Color options", "IndentGuideForeColor", "")
	IF rs THEN ColOpt.IndentGuideForeColor = XLONG (rs) ELSE ColOpt.IndentGuideForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "IndentGuideBackColor", "")
	IF rs THEN ColOpt.IndentGuideBackColor = XLONG (rs) ELSE ColOpt.IndentGuideBackColor = $$White
	' Selection
	rs = IniRead (IniFile$, "Color options", "SelectionForeColor", "")
	IF rs THEN ColOpt.SelectionForeColor = XLONG (rs) ELSE ColOpt.SelectionForeColor = $$White
	rs = IniRead (IniFile$, "Color options", "SelectionBackColor", "")
	IF rs THEN ColOpt.SelectionBackColor = XLONG (rs) ELSE ColOpt.SelectionBackColor = $$MediumBlue
	' Whitespace
	rs = IniRead (IniFile$, "Color options", "WhitespaceForeColor", "")
	IF rs THEN ColOpt.WhitespaceForeColor = XLONG (rs) ELSE ColOpt.WhitespaceForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "WhitespaceBackColor", "")
	IF rs THEN ColOpt.WhitespaceBackColor = XLONG (rs) ELSE ColOpt.WhitespaceBackColor = $$White
	' Codetips
'	rs = IniRead (IniFile$, "Color options", "CodetipForeColor", "")
'	IF rs THEN ColOpt.CodetipForeColor = XLONG (rs) ELSE ColOpt.CodetipForeColor = $$LightGrey
'	rs = IniRead (IniFile$, "Color options", "CodetipBackColor", "")
'	IF rs THEN ColOpt.CodetipBackColor = XLONG (rs) ELSE ColOpt.CodetipBackColor = $$White
	' Submenus
	rs = IniRead (IniFile$, "Color options", "SubMenuTextForeColor", "")
	IF rs THEN ColOpt.SubMenuTextForeColor = XLONG (rs) ELSE ColOpt.SubMenuTextForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "SubMenuTextBackColor", "")
	IF rs THEN ColOpt.SubMenuTextBackColor = XLONG (rs) ELSE ColOpt.SubMenuTextBackColor = RGB (255, 249, 242)
	rs = IniRead (IniFile$, "Color options", "SubMenuHiTextForeColor", "")
	IF rs THEN ColOpt.SubMenuHiTextForeColor = XLONG (rs) ELSE ColOpt.SubMenuHiTextForeColor = $$Black
	rs = IniRead (IniFile$, "Color options", "SubMenuHiTextBackColor", "")
	IF rs THEN ColOpt.SubMenuHiTextBackColor = XLONG (rs) ELSE ColOpt.SubMenuHiTextBackColor = 0x00EFD3C1

	' Caret line background color
	rs = IniRead (IniFile$, "Color options", "CaretLineBackColor", "")
	IF rs THEN ColOpt.CaretLineBackColor = XLONG (rs) ELSE ColOpt.CaretLineBackColor = RGB (220, 240, 255)		'light blue
	' default styles
  rs = IniRead (IniFile$, "Color options", "AlwaysUseDefaultBackColor", "")
  IF rs THEN ColOpt.AlwaysUseDefaultBackColor = XLONG (rs) ELSE ColOpt.AlwaysUseDefaultBackColor = $$BST_UNCHECKED
  rs = IniRead (IniFile$, "Color options", "AlwaysUseDefaultFont", "")
  IF rs THEN ColOpt.AlwaysUseDefaultFont = XLONG (rs) ELSE ColOpt.AlwaysUseDefaultFont = $$BST_UNCHECKED
  rs = IniRead (IniFile$, "Color options", "AlwaysUseDefaultFontSize", "")
  IF rs THEN ColOpt.AlwaysUseDefaultFontSize = XLONG (rs) ELSE ColOpt.AlwaysUseDefaultFontSize = $$BST_UNCHECKED

	' asm fpu instruction
	rs = IniRead (IniFile$, "Color options", "AsmFpuInstructionForeColor", "")
	IF rs THEN ColOpt.AsmFpuInstructionForeColor = XLONG (rs) ELSE ColOpt.AsmFpuInstructionForeColor = $$BrightRed
	rs = IniRead (IniFile$, "Color options", "AsmFpuInstructionBackColor", "")
	IF rs THEN ColOpt.AsmFpuInstructionBackColor = XLONG (rs) ELSE ColOpt.AsmFpuInstructionBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "AsmFpuInstructionFontName", "")
	IF rs THEN ColOpt.AsmFpuInstructionFontName = rs ELSE ColOpt.AsmFpuInstructionFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "AsmFpuInstructionFontCharset", "")
	IF rs THEN ColOpt.AsmFpuInstructionFontCharset = rs ELSE ColOpt.AsmFpuInstructionFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "AsmFpuInstructionFontSize", "")
	IF rs THEN ColOpt.AsmFpuInstructionFontSize = XLONG (rs) ELSE ColOpt.AsmFpuInstructionFontSize = 10
	ColOpt.AsmFpuInstructionFontBold = XLONG (IniRead (IniFile$, "Color options", "AsmFpuInstructionFontBold", ""))
	ColOpt.AsmFpuInstructionFontItalic = XLONG (IniRead (IniFile$, "Color options", "AsmFpuInstructionFontItalic", ""))
	ColOpt.AsmFpuInstructionFontUnderline = XLONG (IniRead (IniFile$, "Color options", "AsmFpuInstructionFontUnderline", ""))

	' asm register
	rs = IniRead (IniFile$, "Color options", "AsmRegisterForeColor", "")
	IF rs THEN ColOpt.AsmRegisterForeColor = XLONG (rs) ELSE ColOpt.AsmRegisterForeColor = $$BrightGreen ' 0x46AA03
	rs = IniRead (IniFile$, "Color options", "AsmRegisterBackColor", "")
	IF rs THEN ColOpt.AsmRegisterBackColor = XLONG (rs) ELSE ColOpt.AsmRegisterBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "AsmRegisterFontName", "")
	IF rs THEN ColOpt.AsmRegisterFontName = rs ELSE ColOpt.AsmRegisterFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "AsmRegisterFontCharset", "")
	IF rs THEN ColOpt.AsmRegisterFontCharset = rs ELSE ColOpt.AsmRegisterFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "AsmRegisterFontSize", "")
	IF rs THEN ColOpt.AsmRegisterFontSize = XLONG (rs) ELSE ColOpt.AsmRegisterFontSize = 10
	ColOpt.AsmRegisterFontBold = XLONG (IniRead (IniFile$, "Color options", "AsmRegisterFontBold", ""))
	ColOpt.AsmRegisterFontItalic = XLONG (IniRead (IniFile$, "Color options", "AsmRegisterFontItalic", ""))
	ColOpt.AsmRegisterFontUnderline = XLONG (IniRead (IniFile$, "Color options", "AsmRegisterFontUnderline", ""))

	' asm directive
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveForeColor", "")
	IF rs THEN ColOpt.AsmDirectiveForeColor = XLONG (rs) ELSE ColOpt.AsmDirectiveForeColor = $$BrightRed
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveBackColor", "")
	IF rs THEN ColOpt.AsmDirectiveBackColor = XLONG (rs) ELSE ColOpt.AsmDirectiveBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveFontName", "")
	IF rs THEN ColOpt.AsmDirectiveFontName = rs ELSE ColOpt.AsmDirectiveFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveFontCharset", "")
	IF rs THEN ColOpt.AsmDirectiveFontCharset = rs ELSE ColOpt.AsmDirectiveFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveFontSize", "")
	IF rs THEN ColOpt.AsmDirectiveFontSize = XLONG (rs) ELSE ColOpt.AsmDirectiveFontSize = 10
	ColOpt.AsmDirectiveFontBold = XLONG (IniRead (IniFile$, "Color options", "AsmDirectiveFontBold", ""))
	ColOpt.AsmDirectiveFontItalic = XLONG (IniRead (IniFile$, "Color options", "AsmDirectiveFontItalic", ""))
	ColOpt.AsmDirectiveFontUnderline = XLONG (IniRead (IniFile$, "Color options", "AsmDirectiveFontUnderline", ""))

	' asm directive operand
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveOperandForeColor", "")
	IF rs THEN ColOpt.AsmDirectiveOperandForeColor = XLONG (rs) ELSE ColOpt.AsmDirectiveOperandForeColor = $$BrightRed
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveOperandBackColor", "")
	IF rs THEN ColOpt.AsmDirectiveOperandBackColor = XLONG (rs) ELSE ColOpt.AsmDirectiveOperandBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveOperandFontName", "")
	IF rs THEN ColOpt.AsmDirectiveOperandFontName = rs ELSE ColOpt.AsmDirectiveOperandFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveOperandFontCharset", "")
	IF rs THEN ColOpt.AsmDirectiveOperandFontCharset = rs ELSE ColOpt.AsmDirectiveOperandFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "AsmDirectiveOperandFontSize", "")
	IF rs THEN ColOpt.AsmDirectiveOperandFontSize = XLONG (rs) ELSE ColOpt.AsmDirectiveOperandFontSize = 10
	ColOpt.AsmDirectiveOperandFontBold = XLONG (IniRead (IniFile$, "Color options", "AsmDirectiveOperandFontBold", ""))
	ColOpt.AsmDirectiveOperandFontItalic = XLONG (IniRead (IniFile$, "Color options", "AsmDirectiveOperandFontItalic", ""))
	ColOpt.AsmDirectiveOperandFontUnderline = XLONG (IniRead (IniFile$, "Color options", "AsmDirectiveOperandFontUnderline", ""))

	' asm extended instruction
	rs = IniRead (IniFile$, "Color options", "AsmExtendedInstructionForeColor", "")
	IF rs THEN ColOpt.AsmExtendedInstructionForeColor = XLONG (rs) ELSE ColOpt.AsmExtendedInstructionForeColor = $$Blue
	rs = IniRead (IniFile$, "Color options", "AsmExtendedInstructionBackColor", "")
	IF rs THEN ColOpt.AsmExtendedInstructionBackColor = XLONG (rs) ELSE ColOpt.AsmExtendedInstructionBackColor = $$White
	rs = IniRead (IniFile$, "Color options", "AsmExtendedInstructionFontName", "")
	IF rs THEN ColOpt.AsmExtendedInstructionFontName = rs ELSE ColOpt.AsmExtendedInstructionFontName = "Courier New"
	rs = IniRead (IniFile$, "Color options", "AsmExtendedInstructionFontCharset", "")
	IF rs THEN ColOpt.AsmExtendedInstructionFontCharset = rs ELSE ColOpt.AsmExtendedInstructionFontCharset = "Default"
	rs = IniRead (IniFile$, "Color options", "AsmExtendedInstructionFontSize", "")
	IF rs THEN ColOpt.AsmExtendedInstructionFontSize = XLONG (rs) ELSE ColOpt.AsmExtendedInstructionFontSize = 10
	ColOpt.AsmExtendedInstructionFontBold = XLONG (IniRead (IniFile$, "Color options", "AsmExtendedInstructionFontBold", ""))
	ColOpt.AsmExtendedInstructionFontItalic = XLONG (IniRead (IniFile$, "Color options", "AsmExtendedInstructionFontItalic", ""))
	ColOpt.AsmExtendedInstructionFontUnderline = XLONG (IniRead (IniFile$, "Color options", "AsmExtendedInstructionFontUnderline", ""))

END FUNCTION
'
'
' ########################################
' #####  SED_LoadPreviousFileSet ()  #####
' ########################################
'
' Load previous file set with bookmarks and current position.
'
FUNCTION SED_LoadPreviousFileSet ()

	file$ = XstGetProgramFileName$ ()
	XstGetPathComponents (file$, @path$, "", "", "", 0)
	file$ = path$ + "XSED.LFS"

	fNumber = OPEN (file$, $$RD)
	IF fNumber < 3 THEN RETURN (-1)

	DO UNTIL EOF (fNumber)
		buffer$ = INFILE$ (fNumber)
		strPath$ = XstParse$ (buffer$, "|", 1)		'PARSE$(buffer, "|", 1)
		caretPos = XLONG (XstParse$ (buffer$, "|", 2))
		bk = XLONG (XstParse$ (buffer$, "|", 3))
		IF FileExist (strPath$) THEN
			OpenThisFile (strPath$)
			DO WHILE bk <> 0
				nLine = XLONG (XstParse$ (buffer$, "|", bk + 3))
				SendMessageA (GetEdit (), $$SCI_MARKERADD, nLine, 0)
				DEC bk
			LOOP
			endPos = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
			SendMessageA (GetEdit (), $$SCI_GOTOPOS, endPos, 0)
			LinesOnScreen = SendMessageA (GetEdit (), $$SCI_LINESONSCREEN, 0, 0)
			LineToGo = SendMessageA (GetEdit (), $$SCI_LINEFROMPOSITION, caretPos, 0)
			LineToGo = LineToGo - (LinesOnScreen \ 2)
			SendMessageA (GetEdit (), $$SCI_GOTOLINE, LineToGo, 0)
			SendMessageA (GetEdit (), $$SCI_GOTOPOS, caretPos, 0)
		END IF
	LOOP

	CLOSE (fNumber)

END FUNCTION
'
'
' ##########################
' #####  FileExist ()  #####
' ##########################
'
FUNCTION FileExist (FileSpec$)

	WIN32_FIND_DATA fd

	IF FileSpec$ THEN
		hFound = FindFirstFileA (&FileSpec$, &fd)
		IF hFound = $$INVALID_HANDLE_VALUE THEN RETURN
		FindClose (hFound)
		IF (fd.dwFileAttributes AND $$FILE_ATTRIBUTE_DIRECTORY) <> $$FILE_ATTRIBUTE_DIRECTORY AND (fd.dwFileAttributes AND $$FILE_ATTRIBUTE_TEMPORARY) <> $$FILE_ATTRIBUTE_TEMPORARY THEN
			RETURN (-1)
		END IF
	END IF

END FUNCTION
'
'
' #############################
' #####  OpenThisFile ()  #####
' #############################
'
' Returns handle to MDI child window on success,
' and 0 on failure
'
FUNCTION OpenThisFile (fn$)

	SHARED hWndClient
	SHARED fMaximize
	SHARED TrimTrailingBlanks

	$CRLF = "\r\n"

	' fModify - Modify flag - indicates if the file has been modified and needs saving

	IFZ fn$ THEN RETURN

	p = INSTR (fn$, ".")
	IF p THEN strExt$ = MID$ (fn$, p)
	SELECT CASE UCASE$ (strExt$)
		CASE ".X", ".XL", ".XBL", ".DEC", ".RC", ".S", ".XXX" : ValidExt = $$TRUE
		CASE ELSE : ValidExt = $$FALSE
	END SELECT

	IF XstLoadString (fn$, @buffer$) THEN
		IF ERROR (-1) THEN
			error = ERROR (0)
			error$ = ERROR$ (error)
			msg$ = "Error loading file " + fn$ + ": " + error$
			MessageBoxA (0, &msg$, &" OpenThisFile", $$MB_OK OR $$MB_ICONERROR OR $$MB_TASKMODAL)
			RETURN
		END IF
	END IF

	IF IsBinary (buffer$) && ValidExt = 0 THEN
		msg$ = fn$ + $CRLF + "The file is not in ASCII or ANSI format.  " + $CRLF + "It will not be loaded into the editor.  "
		MessageBoxA (0, &msg$, &" Not a valid text file", $$MB_OK OR $$MB_ICONWARNING OR $$MB_TASKMODAL)
		RETURN
	END IF

	' Trim trailing spaces and tabs
	IF TrimTrailingBlanks THEN TrimTrailingTabsAndSpaces (@buffer$)

	hMdi = GetWindow (hWndClient, $$GW_CHILD)		' first look at already opened docs

	DO WHILE hMdi
		szPath$ = GetWindowText$ (hMdi)
		IF UCASE$ (szPath$) = UCASE$ (fn$) THEN		' if already opened
			SendMessageA (hWndClient, $$WM_MDIACTIVATE, hMdi, 0)		' activate it
			XstGetPathComponents (szPath$, @path$, @drive$, @dir$, @filename$, @attributes)
			EnumMdiTitleToTab (filename$)		' activate the associated tab
			fModify = SendMessageA (GetEdit (), $$SCI_GETMODIFY, 0, 0)
			IF fModify THEN
				msg$ = "Warning! The modifications will be lost." + "\r\n" + "Do you want to reload the file anyway?"
				IF SED_MsgBox (GetEdit (), msg$, $$MB_YESNO, "Reload file") = $$IDYES THEN
					' Replace the text with the contents of the file
					SendMessageA (GetEdit (), $$SCI_SETTEXT, 0, &buffer$)
					' Empty the undo buffer (it al sets the state of the document as unmodified)
					SendMessageA (GetEdit (), $$SCI_EMPTYUNDOBUFFER, 0, 0)
					' Tell to Scintilla that the current state of the document is unmodified.
					' SendMessageA (GetEdit, $$SCI_SETSAVEPOINT, 0, 0
					' Retrieve the file time and store it in the properties list of the window
					fTime = SED_GetFileTime (fn$)
					SetPropA (MdiGetActive (hWndClient), &"FTIME", fTime)
				END IF
			ELSE
				SendMessageA (GetEdit (), $$SCI_SETTEXT, 0, &buffer$)
				' Empty the undo buffer (it also sets the state of the document as unmodified)
				SendMessageA (GetEdit (), $$SCI_EMPTYUNDOBUFFER, 0, 0)
				' SendMessageA (GetEdit, $$SCI_SETSAVEPOINT, 0, 0
				' Retrieve the file time and store it in the properties list of the window
				fTime = SED_GetFileTime (fn$)
				SetPropA (MdiGetActive (hWndClient), &"FTIME", fTime)
			END IF
			WriteRecentFiles (fn$)		' update MRU menu and exit
			RETURN
		END IF
		hMdi = GetWindow (hMdi, $$GW_HWNDNEXT)
	LOOP

	IF fMaximize THEN ws = $$WS_MAXIMIZE
	hMdi = CreateMdiChild ("XSED32", hWndClient, fn$, ws)

	WriteRecentFiles (fn$)		' update MRU menu and exit
	IF hMdi THEN
'		SED_ResetCodeFinder () ' not needed???
		SED_CodeFinder ($$TRUE)
	END IF
	RETURN hMdi

END FUNCTION
'
'
' ##################################
' #####  EnumMdiTitleToTab ()  #####
' ##################################
'
FUNCTION EnumMdiTitleToTab (szMdiCaption$)

	TC_ITEM ttc_item
	SHARED ghTabMdi

	nTab = SendMessageA (ghTabMdi, $$TCM_GETITEMCOUNT, 0, 0)

	FOR item = 0 TO nTab - 1
		' Get tab item text string
		sTabTxt$ = NULL$ (255)
		ttc_item.mask = $$TCIF_TEXT
		ttc_item.pszText = &sTabTxt$
		ttc_item.cchTextMax = LEN (sTabTxt$)
		SendMessageA (ghTabMdi, $$TCM_GETITEM, item, &ttc_item)
		sTabTxt$ = CSIZE$ (sTabTxt$)
		szTab$ = sTabTxt$
		IF szMdiCaption$ = szTab$ THEN
			' SelTab = item
			SendMessageA (ghTabMdi, $$TCM_SETCURSEL, item, 0)
			RETURN item
		END IF
	NEXT item

END FUNCTION
'
'
' #################################
' #####  WriteRecentFiles ()  #####
' #################################
'
' Save the list of recently opened files
'
FUNCTION WriteRecentFiles (OpenFName$)

	SHARED IniFile$
	SHARED RecentFiles$[]

	REDIM RecentFiles$[$$MAX_MRU-1]

	XstGetPathComponents (OpenFName$, @path$, @drive$, @dir$, @file$, @attributes)
	IFZ path$ THEN
		' IF INSTR(OpenFName$, ":") = 0 || INSTR(OpenFName$, "\\") = 0 || INSTR(OpenFName$, "/") = 0 THEN   ' Path not available?
		IF LEFT$ (UCASE$ (file$), 8) = "UNTITLED" THEN RETURN
	END IF

	szSection$ = "Reopen files"

	' if file is already on list, then remove it
	' at its current position, move the ones above
	' it down and insert it into position 0
	' otherwise, if it is a new file, then drop
	' the top $$MAX_MRU-1 files down one position and insert
	' the new file into position 0
	IF OpenFName$ THEN
		fn$ = UCASE$ (OpenFName$)
    FOR i = 0 TO $$MAX_MRU-1
			IF fn$ = UCASE$ (RecentFiles$[i]) THEN
				fOnList = $$TRUE
				pos = i
				EXIT FOR
			END IF
		NEXT i

		IF fOnList && pos = 0 THEN RETURN   ' do nothing, file is at top of list

    IF fOnList THEN
      szKey$ = "File " + STRING$ (pos+1)
      szText$  = NULL$ (300)
      GetPrivateProfileStringA (&szSection$, &szKey$, &szDefault$, &szText$, LEN (szText$), &IniFile$)
      szText$ = TRIM$(CSIZE$(szText$))
    END IF

		IF fOnList THEN
			start = pos - 1
		ELSE
      start = $$MAX_MRU-1-1
		END IF

		FOR i = start TO 0 STEP -1
      szKey$ = "File " + STRING$ (i+1)
      file$  = NULL$ (300)
      GetPrivateProfileStringA (&szSection$, &szKey$, &szDefault$, &file$, LEN (file$), &IniFile$)
      file$ = TRIM$(CSIZE$(file$))
      IF INSTR (file$, "|") THEN
        fn$ = XstParse$ (file$, "|", 1)
      ELSE
        fn$ = file$
      END IF
'      IFZ FileExist (fn$) THEN file$ = ""
		  szKey$ = "File " + STRING$ (i+1+1)
		  WritePrivateProfileStringA (&szSection$, &szKey$, &file$, &IniFile$)
			RecentFiles$[i + 1] = RecentFiles$[i]
		NEXT i

    IFZ szText$ THEN szText$ = OpenFName$
		szKey$ = "File " + STRING$ (1)
		WritePrivateProfileStringA (&szSection$, &szKey$, &szText$, &IniFile$)
		RecentFiles$[0] = OpenFName$
	END IF

	GetRecentFiles ()		' update MRU menu

END FUNCTION
'
'
' ################################
' #####  WriteRecentFile ()  #####
' ################################
'
' Save last position and bookmarks of recent file
' in Ini file
'
FUNCTION WriteRecentFile (hEdit, szPath$)

	SHARED IniFile$
	SHARED RecentFiles$[]

	$BIT0 = BITFIELD (1, 0)

	XstGetPathComponents (szPath$, @path$, @drive$, @dir$, @file$, @attributes)
	IFZ path$ THEN
		IF LEFT$ (UCASE$ (file$), 8) = "UNTITLED" THEN RETURN ($$TRUE)
	END IF

  IF szPath$ THEN
	' find file in ini file
    fn$ = UCASE$ (szPath$)
    FOR i = 0 TO $$MAX_MRU-1
		  IF fn$ = UCASE$ (RecentFiles$[i]) THEN
			  fOnList = $$TRUE
			  index = i
			  EXIT FOR
		  END IF
	  NEXT i

    curPos = SendMessageA (hEdit, $$SCI_GETCURRENTPOS, 0, 0)

		bk = 0 : buffer$ = ""
		fMark = 0
		fMark = SET (fMark, $BIT0)
		nLine = SendMessageA (hEdit, $$SCI_MARKERNEXT, 0, fMark)
		DO WHILE nLine <> -1
			INC bk
			buffer$ = buffer$ + "|" + STRING$ (nLine)
			fMark = 0
			fMark = SET (fMark, $BIT0)
			nLine = SendMessageA (hEdit, $$SCI_MARKERNEXT, nLine + 1, fMark)
		LOOP
		szText$    = szPath$ + "|" + STRING$ (curPos) + "|" + STRING$ (bk) + buffer$
  END IF

'  IFZ FileExist (szPath$) THEN szText$ = ""
	szSection$ = "Reopen files"
	szKey$     = "File " + STRING$ (index+1)
	WritePrivateProfileStringA (&szSection$, &szKey$, &szText$, &IniFile$)
END FUNCTION
'
'
' ###########################
' #####  SED_MsgBox ()  #####
' ###########################
'
FUNCTION SED_MsgBox (hWnd, strMessage$, dwStyle, strCaption$)

	MSGBOXPARAMS mbp

	szCaption$ = " XSED Editor"
	IF strCaption$ THEN szCaption$ = strCaption$
	IFZ dwStyle THEN dwStyle = $$MB_OK

	' Initializes MSGBOXPARAMS
	mbp.cbSize = SIZE (mbp)		                ' Size of the structure
	mbp.hwndOwner = hWnd		                  ' Handle of main window
	mbp.hInstance = GetModuleHandleA (NULL)		' Instance of application
	mbp.lpszText = &strMessage$		            ' Text of the message
	mbp.lpszCaption = &szCaption$		          ' Caption
	mbp.dwStyle = dwStyle OR $$MB_USERICON		' Style
	mbp.lpszIcon = 108		                    ' Icon identifier in the resource file

	RETURN MessageBoxIndirectA (&mbp)

END FUNCTION
'
'
' ################################
' #####  SED_GetFileTime ()  #####
' ################################
'
' Retrieves the date and time that a file was last modified.
'
FUNCTION SED_GetFileTime (FileSpec$)

	WIN32_FIND_DATA fd
	SYSTEMTIME ft

	IFZ FileSpec$ THEN RETURN

	hFound = FindFirstFileA (&FileSpec$, &fd)
	IF hFound = $$INVALID_HANDLE_VALUE THEN RETURN
	FindClose (hFound)

	' -- Convert the file time into a compatible system time
	FileTimeToSystemTime (&fd.ftLastWriteTime, &ft)

	strTime$ = STRING$ (ft.hour) + STRING$ (ft.minute) + STRING$ (ft.second)
	RETURN (XLONG (strTime$))

END FUNCTION
'
'
' ###############################
' #####  SED_CodeFinder ()  #####
' ###############################
'
' Find FUNCTIONs, update listbox with FUNCTION names
' If fClearTree = $$TRUE then delete all items in treeview
' and repopulate, otherwise, just add new functions.
'
FUNCTION SED_CodeFinder (fClearTree)

	SHARED hCodeFinder
	SHARED hTreeBrowser
	SHARED fShowTreeBrowser

	TV_ITEM tvi
	
	' Reset the combobox content
	SED_ResetCodeFinder ()

	' delete all items from the treeview function browser
	IF fShowTreeBrowser THEN
		IF fClearTree THEN ResetTreeBrowser ()
	END IF

	hSci = GetEdit ()
	IFZ hSci THEN RETURN

	' Get direct pointer for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN RETURN

	' Number of lines
	nLines = SciMsg (pSci, $$SCI_GETLINECOUNT, 0, 0)
	IFZ nLines THEN RETURN

	' Parse the text
	cnt = -1
	SetCursor (LoadCursorA (NULL, $$IDC_APPSTARTING))		' Show hourglass mouse
	FOR i = 0 TO nLines - 1
		nLen = SciMsg (pSci, $$SCI_LINELENGTH, i, 0)
		buffer$ = NULL$ (nLen)
		SciMsg (pSci, $$SCI_GETLINE, i, &buffer$)
		IsFUNCTION (buffer$, @strProcName$)
		IF strProcName$ THEN
			' add function to code finder combobox
			p = SendMessageA (hCodeFinder, $$CB_ADDSTRING, 0, &strProcName$)
			SendMessageA (hCodeFinder, $$CB_SETITEMDATA, p, i)

			IF fShowTreeBrowser THEN
				IF fClearTree THEN
					' add all functions to function tree browser
					' the weird WM_SETREDRAW bracketing on the first element is
					' a bug fix for how ResetTreeBrowser() was messing up last item in tree
					INC cnt
					IFZ cnt THEN
						SendMessageA (hTreeBrowser, $$WM_SETREDRAW, 0, 0 )
						ret = AddTreeViewItem (hTreeBrowser, 0, strProcName$, 0, 0, $$TVI_SORT, 0)
						SendMessageA (hTreeBrowser, $$WM_SETREDRAW, 1, 0 )
					ELSE
						ret = AddTreeViewItem (hTreeBrowser, 0, strProcName$, 0, 0, $$TVI_SORT, 0)
					END IF
				END IF
			END IF
		END IF
	NEXT i

	SetCursor (LoadCursorA (NULL, $$IDC_ARROW))

END FUNCTION
'
'
' ####################################
' #####  SED_ResetCodefinder ()  #####
' ####################################
'
' Reset the CodeFinder combobox content
'
FUNCTION SED_ResetCodeFinder ()
	SHARED hCodeFinder
	SendMessageA (hCodeFinder, $$CB_RESETCONTENT, 0, 0)
	buffer$ = "(FUNCTION finder)"
	p = SendMessageA (hCodeFinder, $$CB_ADDSTRING, 0, &buffer$)
	SendMessageA (hCodeFinder, $$CB_SETITEMDATA, p, 1)
	SendMessageA (hCodeFinder, $$CB_SETCURSEL, 0, 0)
END FUNCTION
'
'
' ###############################
' #####  CreateMdiChild ()  #####
' ###############################
'
' Create MDI child window
'
FUNCTION CreateMdiChild (WndClass$, hClient, Title$, Style)

	MDICREATESTRUCT mdi
	SHARED hInst

	IF IsZoomed (MdiGetActive (hClient)) THEN
		Style = Style OR $$WS_MAXIMIZE
	END IF

	XstGetOSVersion (@major, 0, 0, "", "")

	IF major < 4 THEN
		mdi.szClass = &WndClass$
		mdi.szTitle = &Title$
		mdi.hOwner = hInst		' GetWindowLongA (hClient, $$GWL_HINSTANCE)
		mdi.x = $$CW_USEDEFAULT
		mdi.y = $$CW_USEDEFAULT
		mdi.cx = $$CW_USEDEFAULT
		mdi.cy = $$CW_USEDEFAULT
		mdi.style = Style
		ret = SendMessageA (hClient, $$WM_MDICREATE, 0, &mdi)
	ELSE
		IF Title$ THEN
			RETURN CreateWindowExA ($$WS_EX_MDICHILD OR $$WS_EX_CLIENTEDGE, &WndClass$, &Title$, Style, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, hClient, NULL, hInst, NULL)
		ELSE
			RETURN CreateWindowExA ($$WS_EX_MDICHILD OR $$WS_EX_CLIENTEDGE, &WndClass$, NULL, Style, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, hClient, NULL, hInst, NULL)
		END IF
	END IF

END FUNCTION
'
'
' #################################
' #####  CheckMenuOptions ()  #####
' #################################
'
' Check or uncheck some of the menu options
'
FUNCTION CheckMenuOptions (EditorOptionsType EdOpt)

	SHARED hMenu

	IF EdOpt.UseTabs = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_USETABS, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_USETABS, $$MF_UNCHECKED)
	END IF

	IF EdOpt.AutoIndent = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_AUTOINDENT, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_AUTOINDENT, $$MF_UNCHECKED)
	END IF

	IF EdOpt.LineNumbers = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_SHOWLINENUM, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_SHOWLINENUM, $$MF_UNCHECKED)
	END IF

	IF EdOpt.Margin = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_SHOWMARGIN, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_SHOWMARGIN, $$MF_UNCHECKED)
	END IF

	IF EdOpt.IndentGuides = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_SHOWINDENT, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_SHOWINDENT, $$MF_UNCHECKED)
	END IF

	IF EdOpt.WhiteSpace = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_SHOWSPACES, $$MF_UNCHECKED)
	END IF

	IF EdOpt.EdgeColumn = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_SHOWEDGE, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_SHOWEDGE, $$MF_UNCHECKED)
	END IF

	IF EdOpt.EndOfLine = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_SHOWEOL, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_SHOWEOL, $$MF_UNCHECKED)
	END IF

	IF EdOpt.ShowProcedureName = $$BST_CHECKED THEN
		CheckMenuItem (hMenu, $$IDM_SHOWPROCNAME, $$MF_CHECKED)
	ELSE
		CheckMenuItem (hMenu, $$IDM_SHOWPROCNAME, $$MF_UNCHECKED)
	END IF

END FUNCTION
'
'
' #########################
' #####  IniWrite ()  #####
' #########################
'
' Description : Saves data to the Applications INI file.
' Usage       : lResult = IniWrite ("INIFILE", "SECTION", "KEY", "VALUE")
'
FUNCTION IniWrite (sIniFile$, sSection$, sKey$, sValue$)

	szSection$ = sSection$
	szKey$ = sKey$
	szIniFile$ = sIniFile$
	szValue$ = TRIM$ (sValue$)

	RETURN WritePrivateProfileStringA (&szSection$, &szKey$, &szValue$, &szIniFile$)

END FUNCTION
'
' ##########################
' #####  OnDestroy ()  #####
' ##########################
'
' Description : $$WM_DESTROY - Message handler.
' Release all the used resources, disable drag
' and drop and quit the application.
' The PostQuitMessage function closes the main window
' by sending zero to the main message loop.
'
FUNCTION OnDestroy (hWnd, wParam, lParam)

	SHARED hMenuTextBkBrush, hMenuHiBrush
	SHARED hImlHot, hImlDis, hImlNor
	SHARED hTabImagelist
	SHARED hAccel
	SHARED hFontSS8
	SHARED IniFile$

	XstGetCurrentDirectory (@curdir$)
	IniWrite (IniFile$, "Editor options", "LastFolder", curdir$)	 ' Save the current folder
	WriteRecentFiles ("")		                                       ' Clean the recent files registry
	IF hMenuTextBkBrush THEN DeleteObject (hMenuTextBkBrush)		   ' Delete the submenu text brush
	IF hMenuHiBrush THEN DeleteObject (hMenuHiBrush)		           ' Delete the highlighted text brush
	SED_SaveWindowPlacement (hWnd)		                             ' Save window's state and placement
	IF hImlHot THEN ImageList_Destroy (hImlHot)		                 ' Destroy Hot Selected ImageList Handle.
	IF hImlDis THEN ImageList_Destroy (hImlDis)		                 ' Destroy Dis Disabled ImageList Handle.
	IF hImlNor THEN ImageList_Destroy (hImlNor)		                 ' Destroy Nor Normal   ImageList Handle.
	IF hTabImagelist THEN ImageList_Destroy (hTabImageList)		     ' Destroy the Tab imagelist
	IF hAccel THEN DestroyAcceleratorTable (hAccel)		             ' Destroy the acceletator's table
	DragAcceptFiles (hWnd, $$FALSE)		                             ' Disable drag and drop files
	IF hFontSS8 THEN DeleteObject (hFontSS8)		                   ' Delete console font
	PostQuitMessage (0)		                                         ' Tell Windows to quit the application

END FUNCTION
'
' ########################################
' #####  SED_SaveWindowPlacement ()  #####
' ########################################
'
' Saves the window's state and placement
'
FUNCTION SED_SaveWindowPlacement (hWnd)

	WINDOWPLACEMENT WinPla
	SHARED IniFile$

	WinPla.length = SIZE (WinPla)
	IF GetWindowPlacement (hWnd, &WinPla) THEN
		IF WinPla.showCmd = $$SW_SHOWMAXIMIZED THEN Zoomed = $$TRUE
		IniWrite (IniFile$, "Window Placement", "Zoomed", STRING$ (Zoomed))
		IniWrite (IniFile$, "Window Placement", "Left", STRING$ (WinPla.rcNormalPosition.left))
		IniWrite (IniFile$, "Window Placement", "Right", STRING$ (WinPla.rcNormalPosition.right))
		IniWrite (IniFile$, "Window Placement", "Top", STRING$ (WinPla.rcNormalPosition.top))
		IniWrite (IniFile$, "Window Placement", "Bottom", STRING$ (WinPla.rcNormalPosition.bottom))
	END IF

END FUNCTION
'
' ###########################
' #####  ShowLinCol ()  #####
' ###########################
'
' Shows the line and column in the status bar
'
FUNCTION ShowLinCol ()

	SHARED hStatusbar

	' Retrieve the handle of the edit window
	hSci = GetEdit ()

	' If there is not any file being edited, clear the status bar
	IFZ hSci THEN
		szText$ = ""
		SendMessageA (hStatusbar, $$SB_SETTEXT, 1, &szText$)
		SendMessageA (hStatusbar, $$SB_SETTEXT, 2, &szText$)
		ChangeButtonsState ()
		RETURN
	END IF

	' Get direct pointer to the Scintilla control for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN RETURN

	' Retrieve the information and show it in the status bar
	curPos = SciMsg (pSci, $$SCI_GETCURRENTPOS, 0, 0)
	nLine = SciMsg (pSci, $$SCI_LINEFROMPOSITION, curPos, 0) + 1
	nCol = SciMsg (pSci, $$SCI_GETCOLUMN, curPos, 0) + 1
	szText$ = " " + STRING$ (nLine) + ":" + STRING$ (nCol)
	SendMessageA (hStatusbar, $$SB_SETTEXT, 1, &szText$)
	nLines = SciMsg (pSci, $$SCI_GETLINECOUNT, 0, 0)
	nTextLen = SciMsg (pSci, $$SCI_GETTEXTLENGTH, 0, 0)
	szText$ = " " + STRING$ (nLines) + " lines, " + STRING$ (nTextLen) + " characters"
	SendMessageA (hStatusbar, $$SB_SETTEXT, 2, &szText$)
	' Change the toolbar buttons state if needed
	ChangeButtonsState ()

END FUNCTION
'
' #########################
' #####  OnCreate ()  #####
' #########################
'
' Processes the WM_CREATE message of the main window
'
FUNCTION OnCreate (hWnd, wParam, lParam)

	SHARED hInst
	SHARED hFont
	SHARED hToolbar, hMenu, hAccel, hStatusbar, ghTabMdi
	SHARED hWndClient
	SHARED hCodeFinder
	SHARED NewComCtl
	SHARED hMenuWindow
	SHARED hWndMain
	SHARED hWndConsole
	SHARED hSplitter

	SHARED hSearchText0, hSearchText1, hSearchText2, hSearchText3, hSearchText4, hSearchText5
	SHARED hSearchEdit1, hSearchEdit2, hSearchEdit3
	SHARED hSearchButton1, hSearchButton2, hSearchButton3, hSearchButton4, hSearchButton5

	SHARED hFontMarlett

	SHARED hTreeBrowser
	SHARED fShowTreeBrowser
	SHARED IniFile$

	CLIENTCREATESTRUCT cc		' Client data for MDI windows
	RECT rc		' RECT structure

	' Initialize the common control library
	NewComCtl = InitComCtl32 ($$ICC_WIN95_CLASSES)

	' Retrieve the size of the bitmaps used in the image lists
	lBmpSize = AppLoadBitmaps ()

	' Create the toolbar, menu, accelerators table and status bar
	hToolbar = CreateToolBar (hWnd, lBmpSize)		' Toolbar
	hMenu = SED_CreateMenu (hWnd)								' Menu
	hAccel = SED_CreateAcceleratorTable ()			' Table of keyboard accelerators
	hStatusbar = CreateStatusbar (hWnd)					' Status bar

	' Create the tab control
	GetWindowRect (hWnd, &rc)
	ghTabMdi = CreateTabMdiCtl (hWnd, rc)

	IF hFont THEN SendMessageA (ghTabMdi, $$WM_SETFONT, hFont, $$TRUE)
	ShowWindow (ghTabMdi, $$SW_SHOW)

	' create vertical splitter control
	hSplitter = NewChild ($$DOCKSPLITTERCLASSNAME, "", 0, 0, 0, 290, 445, hWnd, $$IDC_SPLITTER, 0)

	' set splitter control style (default is $$SS_HORZ - horizontal)
	SendMessageA (hSplitter, $$WM_SET_SPLITTER_STYLE, 0, $$SS_VERT)

	' Create the MDI Client window
	cc.idFirstChild = 1		' Specifies the child window identifier of the first MDI child window created.
	cc.hWindowMenu = hMenuWindow		' For file list in Window menu

	hWndClient = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"MDICLIENT", NULL, $$WS_CHILD OR $$WS_CLIPCHILDREN OR $$WS_VISIBLE OR $$WS_VSCROLL OR $$WS_HSCROLL, 0, 0, 0, 0, hWnd, 0x0CAC, hInst, &cc)
	ShowWindow (hWndClient, $$SW_SHOW)

	' Create Output Console window
	title$  = " Output Console"
	styleEx = $$WS_EX_CLIENTEDGE '$$WS_EX_TOOLWINDOW | $$WS_EX_CLIENTEDGE
  style   = $$WS_CHILD | $$WS_CLIPCHILDREN '| $$WS_CAPTION | $$WS_SYSMENU '| $$WS_OVERLAPPEDWINDOW
	hWndConsole = CreateWindowExA (styleEx, &"XSEDCONSOLE", &title$, style, 0, 0, 0, 0, hWnd, 0, hInst, NULL)

	ShowWindow (hWndConsole, $$SW_SHOW)

	' set splitter panel window handles
	SendMessageA (hSplitter, $$WM_SET_SPLITTER_PANEL_HWND, hWndClient, hWndConsole)

	' Create the combobox code finder
	hCodeFinder = CreateComboboxFinder (hWnd, hToolbar, hFont)

	' Fill the Recent files menu (MRU) ..
	hWndMain = hWnd
	GetRecentFiles ()

	' create search for files and folders controls
	hSearchText0 = NewChild ("static", "", $$SS_LEFT, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_STATIC0, $$WS_EX_STATICEDGE) ' line control
	hSearchText1 = NewChild ("static", "", $$SS_LEFT, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_STATIC1, $$WS_EX_STATICEDGE) ' line control
	hSearchText5 = NewChild ("static", "   Find in Files", $$SS_LEFT | $$SS_CENTERIMAGE, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_STATIC5, 0)

	hSearchText2 = NewChild ("static", "Start scan in folder", $$SS_LEFT, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_STATIC2, 0)
	hSearchText3 = NewChild ("static", "Containing text", $$SS_LEFT, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_STATIC3, 0)
	hSearchText4 = NewChild ("static", "Using file filters", $$SS_LEFT, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_STATIC4, 0)

	hSearchEdit1 = NewChild ("edit", "c:\\xblite", $$ES_AUTOHSCROLL | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_EDIT1, $$WS_EX_CLIENTEDGE)
	hSearchButton2 = NewChild ("button", "Browse...", $$BS_PUSHBUTTON | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_BUTTON2, 0)
	hSearchEdit2 = NewChild ("edit", "", $$ES_AUTOHSCROLL | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_EDIT2, $$WS_EX_CLIENTEDGE)
	hSearchEdit3 = NewChild ("edit", "*.x", $$ES_AUTOHSCROLL | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_EDIT3, $$WS_EX_CLIENTEDGE)
	hSearchButton1 = NewChild ("button", "Search Now", $$BS_PUSHBUTTON | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_BUTTON1, 0)

'	hSearchButton3 = NewChild ("button", CHR$(114), $$BS_PUSHBUTTON | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_BUTTON3, 0)
	hSearchButton3 = NewChild ("static", CHR$(114), $$SS_CENTER | $$SS_CENTERIMAGE | $$SS_NOTIFY, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_BUTTON3, 0) ' x button
	hSearchButton4 = NewChild ("button", "Scan subfolders", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_BUTTON4, 0)
	hSearchButton5 = NewChild ("button", "Search for whole words", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 0, 0, 0, 0, hWnd, $$IDC_SEARCH_BUTTON5, 0)

	SetCheckBox (hSearchButton4)	' set scan subfolder to checked state

' add tooltips to search controls
	SetTooltip (hSearchEdit1, 	"Enter starting folder, eg, type c:\\mydata (or more simply click the ... button to the right of this editbox)" )
	SetTooltip (hSearchButton2, "Open the Browse For Folder dialog window to select a folder")
	SetTooltip (hSearchEdit2, 	"Enter search criteria using multiple words and/or quoted phrases using Boolean Operators (AND, OR, NOT, + | -)")
	SetTooltip (hSearchEdit3, 	"Specify which files to search, eg, to find all DEC and X with EVAL in the filename, specify EVAL*.DEC  EVAL*.X")
	SetTooltip (hSearchButton1, "Press to start search")
	SetTooltip (hSearchButton4, "Recursively scan all subfolders")
	SetTooltip (hSearchButton5, "Match only whole words")

	' set fonts
	SetNewFont (hSearchText2, hFont)
	SetNewFont (hSearchText3, hFont)
	SetNewFont (hSearchText4, hFont)
'	SetNewFont (hSearchText5, hFont)
	SetNewFont (hSearchEdit1, hFont)
	SetNewFont (hSearchEdit2, hFont)
	SetNewFont (hSearchEdit3, hFont)
	SetNewFont (hSearchButton1, hFont)
	SetNewFont (hSearchButton2, hFont)
	SetNewFont (hSearchButton4, hFont)
	SetNewFont (hSearchButton5, hFont)

	' create a Marlett symbol font to use to draw "x" in button (char # 114)
	hDC = GetDC ($$HWND_DESKTOP)
	pointSize = 7
	fHeight = -1 * pointSize * GetDeviceCaps (hDC, $$LOGPIXELSY) / 72
	hFontMarlett = CreateFontA (fHeight, 0, 0, 0, $$FW_THIN, 0, 0, 0, $$SYMBOL_CHARSET, 0, 0, $$PROOF_QUALITY, 0, &"Marlett")
	ReleaseDC ($$HWND_DESKTOP, hDC)

	SetNewFont (hSearchButton3, hFontMarlett)

	' create a treeview control to display functions
	hTreeBrowser = NewChild ($$WC_TREEVIEW, "", $$TVS_HASLINES | $$TVS_HASBUTTONS | $$TVS_LINESATROOT, 0, 0, 0, 0, hWnd, $$IDC_TREEBROWSER, $$WS_EX_CLIENTEDGE)
	fShowTreeBrowser = XLONG (IniRead (IniFile$, "Tree Browser", "Show", "0"))

END FUNCTION
'
' #############################
' #####  InitComctl32 ()  #####
' #############################
'
' Initialize comctl32.dll - return 1 if InitCommonControlsEx was used.
' Here we use LoadLibrary and GetProcAddress to avoid crash on failure.
' Example use:  NewComCtl = InitComctl32 ($$ICC_BAR_CLASSES)
'
FUNCTION InitComCtl32 (iccClasses)

	INITCOMMONCONTROLSEX iccex
	FUNCADDR InitCCEx (XLONG)

	hLib = LoadLibraryA (&"COMCTL32.DLL")
	IF hLib THEN
		InitCCEx = GetProcAddress (hLib, &"InitCommonControlsEx")
		IF InitCCEx THEN
			' ret = 1                  'return 1 on success
			iccex.dwSize = SIZE (iccex)		'fill the iccex structure
			iccex.dwICC = iccClasses		'tell what classes to initiate
			ret = @InitCCEx (&iccex)		' Returns TRUE if successful, or FALSE otherwise
		ELSE
			InitCommonControls ()
		END IF
		FreeLibrary (hLib)		'we can FreeLibrary now, because InitCommonControls(Ex)
	END IF		'has made sure comctl32.dll is loaded into the system.

	RETURN ret

END FUNCTION
'
' ###############################
' #####  AppLoadBitmaps ()  #####
' ###############################
'
' Description  : Loads the Applications Bitmaps from a Resource file.
' Return value : Returns the size of the bitmaps
' NOTE         : If you use 24x24 Bitmaps for the ToolBars, you will have to
' add 16x16 Bitmaps Strips for the Menus!
'
FUNCTION AppLoadBitmaps ()

	BITMAP bm
	SHARED hInst
	SHARED hImlHot, hImlDis, hImlNor

	' ----------------------------------------------------------------------------
	' Setup and Initialize the Menu, ToolBar Bitmaps and ImageLists.
	' ----------------------------------------------------------------------------
	' Normal Bitmap.
	hBmpNor = LoadImageA (hInst, &"TBNOR", $$IMAGE_BITMAP, 0, 0, $$LR_LOADTRANSPARENT OR $$LR_LOADMAP3DCOLORS OR $$LR_DEFAULTSIZE)
	' Hot Bitmap (same as normal).
	hBmpHot = LoadImageA (hInst, &"TBNOR", $$IMAGE_BITMAP, 0, 0, $$LR_LOADTRANSPARENT OR $$LR_LOADMAP3DCOLORS OR $$LR_DEFAULTSIZE)
	' Disabled Bitmap.
	hBmpDis = LoadImageA (hInst, &"TBDIS", $$IMAGE_BITMAP, 0, 0, $$LR_LOADTRANSPARENT OR $$LR_LOADMAP3DCOLORS OR $$LR_DEFAULTSIZE)

	' ----------------------------------------------------------------------------
	' Get and Save the Bitmap size for later use.
	' ----------------------------------------------------------------------------
	GetObjectA (hBmpNor, SIZE (bm), &bm)		' Get the Bitmap's sizes.
	lBmpSize = bm.height		' Save Bitmap size for later use.

	' ----------------------------------------------------------------------------
	' Create the Menu and ToolBar ImageLists Hot Selected, Disabled and Normal.
	' ----------------------------------------------------------------------------
	hImlHot = ImageList_Create (lBmpSize, lBmpSize, $$ILC_COLORDDB OR $$ILC_MASK, 1, 0)
	ImageList_AddMasked (hImlHot, hBmpHot, RGB (255, 0, 255))
	ImageList_Add (hImlHot, hBmpHot, RGB (255, 0, 255))

	hImlDis = ImageList_Create (lBmpSize, lBmpSize, $$ILC_COLORDDB OR $$ILC_MASK, 1, 0)
	ImageList_AddMasked (hImlDis, hBmpDis, RGB (255, 0, 255))
	ImageList_Add (hImlDis, hBmpDis, RGB (255, 0, 255))

	hImlNor = ImageList_Create (lBmpSize, lBmpSize, $$ILC_COLORDDB OR $$ILC_MASK, 1, 0)
	ImageList_AddMasked (hImlNor, hBmpNor, RGB (255, 0, 255))
	ImageList_Add (hImlNor, hBmpNor, RGB (255, 0, 255))

	' ----------------------------------------------------------------------------
	' Clean-Up and Delete the Bitmap Handles they are no longer need.
	' ----------------------------------------------------------------------------
	IF hBmpHot THEN DeleteObject (hBmpHot)
	IF hBmpDis THEN DeleteObject (hBmpDis)
	IF hBmpNor THEN DeleteObject (hBmpNor)

	RETURN lBmpSize

END FUNCTION
'
' ##############################
' #####  CreateToolBar ()  #####
' ##############################
'
' Description  : Creates a ToolBar Control.
' Return value : Returns the handle of the Toolbar
' Parameters   : hWnd      = Handle of the main window
' lBmpSize  = Size of the bitmaps 16x16 or 24x24
'
FUNCTION CreateToolBar (hWnd, lBmpSize)

	SHARED hInst
	SHARED NewComCtl
	SHARED hImlNor, hImlDis, hImlHot
	' Toolbar Variables.

	TBBUTTON Tbb[]
	TBADDBITMAP Tabm

	TOOLBUTTONS = 26
'	TOOLBUTTONS = 25
	DIM Tbb[TOOLBUTTONS - 1]

	' Check For Correct Bitmap Sizes!
	IF lBmpSize <> 24 THEN
		IF lBmpSize <> 16 THEN
			' Bitmap Size Is Incorrect Inform The USER.
			MessageBoxA (0, &"ToolBar bitmap sizes need to be 16x16 Or 24x24!", &" Error", $$MB_OK OR $$MB_ICONERROR)
			RETURN
		END IF
	END IF

	' ----------------------------------------------------------------------------
	' Create the ToolBar Window.
	' ----------------------------------------------------------------------------
	hToolbar = CreateWindowExA (0, &"ToolbarWindow32", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$TBSTYLE_TOOLTIPS OR $$TBSTYLE_FLAT OR $$TBSTYLE_LIST OR $$TBSTYLE_TRANSPARENT, 0, 0, 0, 0, hWnd, $$ID_TOOLBAR, hInst, NULL)
	IFZ hToolbar THEN RETURN

	' If new Common Controls Library then we can use more modern features
	IF NewComCtl THEN SendMessageA (hToolbar, $$TB_SETEXTENDEDSTYLE, 0, $$TBSTYLE_EX_DRAWDDARROWS)

	' ----------------------------------------------------------------------------
	' Initialize the Tbb() Array of ToolBar Buttons.
	' ----------------------------------------------------------------------------
	FOR x = 0 TO TOOLBUTTONS - 1

		' Set the initial states for each button.
		Tbb[x].iBitmap = 0
		Tbb[x].idCommand = 0
		Tbb[x].fsState = $$TBSTATE_ENABLED
		Tbb[x].fsStyle = $$TBSTYLE_BUTTON OR $$TBSTYLE_AUTOSIZE
		Tbb[x].dwData = 0
		Tbb[x].iString = 0

		SELECT CASE x

			CASE 0 : Tbb[x].iBitmap = 1
				Tbb[x].idCommand = $$IDM_NEW
			CASE 1 : Tbb[x].iBitmap = 2
				Tbb[x].idCommand = $$IDM_OPEN
				IF NewComCtl THEN
					Tbb[x].fsStyle = $$TBSTYLE_DROPDOWN
				ELSE
					Tbb[x].fsStyle = $$TBSTYLE_BUTTON
				END IF
			CASE 2 : Tbb[x].iBitmap = 3
				Tbb[x].idCommand = $$IDM_SAVE
			CASE 3 : Tbb[x].iBitmap = 4
				Tbb[x].idCommand = $$IDM_SAVEAS
			CASE 4 : Tbb[x].iBitmap = 108
				Tbb[x].idCommand = $$IDM_REFRESH
			CASE 5 : Tbb[x].iBitmap = 5
				Tbb[x].idCommand = $$IDM_CLOSEFILE
			CASE 6 : Tbb[x].fsStyle = $$TBSTYLE_SEP
			CASE 7 : Tbb[x].iBitmap = 12
				Tbb[x].idCommand = $$IDM_UNDO
			CASE 8 : Tbb[x].iBitmap = 13
				Tbb[x].idCommand = $$IDM_REDO
			CASE 9 : Tbb[x].fsStyle = $$TBSTYLE_SEP
			CASE 10 : Tbb[x].iBitmap = 17
				Tbb[x].idCommand = $$IDM_CUT
			CASE 11 : Tbb[x].iBitmap = 18
				Tbb[x].idCommand = $$IDM_COPY
			CASE 12 : Tbb[x].iBitmap = 19
				Tbb[x].idCommand = $$IDM_PASTE
			CASE 13 : Tbb[x].fsStyle = $$TBSTYLE_SEP
			CASE 14 : Tbb[x].iBitmap = 33
				Tbb[x].idCommand = $$IDM_FIND
			CASE 15 : Tbb[x].iBitmap = 35
				Tbb[x].idCommand = $$IDM_REPLACE
			CASE 16 : Tbb[x].fsStyle = $$TBSTYLE_SEP
			CASE 17 : Tbb[x].iBitmap = 42
				Tbb[x].idCommand = $$IDM_COMPILE
			CASE 18 : Tbb[x].iBitmap = 91
				Tbb[x].idCommand = $$IDM_BUILD
			CASE 19 : Tbb[x].iBitmap = 43
				Tbb[x].idCommand = $$IDM_EXECUTE
			CASE 20 : Tbb[x].fsStyle = $$TBSTYLE_SEP
			CASE 21 : Tbb[x].iBitmap = 218		' Make room for the combobox
				Tbb[x].fsStyle = $$TBSTYLE_SEP
			CASE 22 : Tbb[x].fsStyle = $$TBSTYLE_SEP
			' CASE 23 : Tbb[x].iBitmap   = 8
			' Tbb[x].idCommand = $$IDM_PRINTPREVIEW
			CASE 23 : Tbb[x].iBitmap = 9
				Tbb[x].idCommand = $$IDT_PRINT
			CASE 24 : Tbb[x].iBitmap = 87
				Tbb[x].idCommand = $$IDM_XBLHTMLHELP
			CASE 25 : Tbb[x].iBitmap   = 109
			  Tbb[x].idCommand = $$IDM_MAIL
		END SELECT

	NEXT x

	' ----------------------------------------------------------------------------
	' Initialize the ToolBar Window and Send Windows the Information.
	' ----------------------------------------------------------------------------
	Tabm.nID = $$ID_TOOLBAR		' $$IDB_STD_LARGE_COLOR ' Use the ID of the bitmap image, ie, $$ID_TOOLBAR
	Tabm.hInst = hInst		' GetModuleHandle(NULL)   ' $$HINST_COMMCTRL
	' if using a bitmap in a linked resource file
	' Set the ToolBar bitmap size.
	IF lBmpSize = 16 THEN SendMessageA (hToolbar, $$TB_SETBITMAPSIZE, 0, MAKELONG (16, 16))
	IF lBmpSize = 24 THEN SendMessageA (hToolbar, $$TB_SETBITMAPSIZE, 0, MAKELONG (24, 24))

	' Add The ImageLists to the ToolBar.
	SendMessageA (hToolbar, $$TB_SETIMAGELIST, 0, hImlNor)		' Normal
	SendMessageA (hToolbar, $$TB_SETDISABLEDIMAGELIST, 0, hImlDis)		' Disabled
	SendMessageA (hToolbar, $$TB_SETHOTIMAGELIST, 0, hImlHot)		' Hot Selected

	' Add The ImageList Bitmaps To The ToolBar Buttons.
	SendMessageA (hToolbar, $$TB_ADDBITMAP, TOOLBUTTONS, &Tabm)

	' Set the ToolBar Buttons.
	SendMessageA (hToolbar, $$TB_BUTTONSTRUCTSIZE, SIZE (TBBUTTON), 0)
	SendMessageA (hToolbar, $$TB_ADDBUTTONS, TOOLBUTTONS, &Tbb[0])

	' Force ToolBar to initially resize.
	SendMessageA (hToolbar, $$WM_SIZE, 0, 0)

	' Return the handle of the Toolbar
	RETURN hToolbar

END FUNCTION
'
' ###############################
' #####  SED_CreateMenu ()  #####
' ###############################
'
'
' Create main menu
'
FUNCTION SED_CreateMenu (hWnd)

	SHARED hMenuWindow
	SHARED hMenuFile
	SHARED hMenuRecentFiles
	STATIC init
	MENUITEMINFO mii
	SHARED templateCount
	SHARED tools$[]

	' Note: hMenuReopen and hMenuWindow are declared global.
	' hMenuWindow is used in the OnCreate function to create the MDICLIENT window
	' and needs to know the value of this handle.

	hMenu = CreateMenu ()
	hMenuFile = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuFile, GetMenuTextAndBitmap ($$IDM_FILEHEADER, 0))
	' AppendMenuA (hMenuFile, $$MF_ENABLED OR $$MF_OWNERDRAW, $$IDM_NEW, GetMenuTextAndBitmap($$IDM_NEW, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_NEW, GetMenuTextAndBitmap ($$IDM_NEW, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_OPEN, GetMenuTextAndBitmap ($$IDM_OPEN, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_SAVE, GetMenuTextAndBitmap ($$IDM_SAVE, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_SAVEAS, GetMenuTextAndBitmap ($$IDM_SAVEAS, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_HTMLCODE, GetMenuTextAndBitmap ($$IDM_HTMLCODE, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_CLOSEFILE, GetMenuTextAndBitmap ($$IDM_CLOSEFILE, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_CLOSEALL, GetMenuTextAndBitmap ($$IDM_CLOSEALL, 0))
	AppendMenuA (hMenuFile, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_PRINTERSETUP, GetMenuTextAndBitmap ($$IDM_PRINTERSETUP, 0))
'	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_PRINTPREVIEW, GetMenuTextAndBitmap ($$IDM_PRINTPREVIEW, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_PRINT, GetMenuTextAndBitmap ($$IDM_PRINT, 0))
	AppendMenuA (hMenuFile, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
'	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_RECENTSTART, GetMenuTextAndBitmap ($$IDM_RECENTSTART, 0))

  hMenuRecentFiles = CreatePopupMenu ()
	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_STRING | $$MIIM_DATA | $$MIIM_ID | $$MIIM_SUBMENU
	mii.fType = $$MFT_STRING
	mii.wID = $$IDM_RECENTSTART
	mii.hSubMenu = hMenuRecentFiles
	mii.dwTypeData = GetMenuTextAndBitmap ($$IDM_RECENTSTART, 0)
	InsertMenuItemA (hMenuFile, GetMenuItemCount (hMenuFile), 1, &mii)


	AppendMenuA (hMenuFile, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_EXPLOREHERE, GetMenuTextAndBitmap ($$IDM_EXPLOREHERE, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_DOS, GetMenuTextAndBitmap ($$IDM_DOS, 0))
	AppendMenuA (hMenuFile, $$MF_ENABLED, $$IDM_EXIT, GetMenuTextAndBitmap ($$IDM_EXIT, 0))
	hMenuEdit = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuEdit, GetMenuTextAndBitmap ($$IDM_EDITHEADER, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_UNDO, GetMenuTextAndBitmap ($$IDM_UNDO, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_REDO, GetMenuTextAndBitmap ($$IDM_REDO, 0))
	AppendMenuA (hMenuEdit, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_LINEDELETE, GetMenuTextAndBitmap ($$IDM_LINEDELETE, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_CLEAR, GetMenuTextAndBitmap ($$IDM_CLEAR, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_CLEARALL, GetMenuTextAndBitmap ($$IDM_CLEARALL, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_CUT, GetMenuTextAndBitmap ($$IDM_CUT, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_COPY, GetMenuTextAndBitmap ($$IDM_COPY, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_PASTE, GetMenuTextAndBitmap ($$IDM_PASTE, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_SELECTALL, GetMenuTextAndBitmap ($$IDM_SELECTALL, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_BLOCKINDENT, GetMenuTextAndBitmap ($$IDM_BLOCKINDENT, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_BLOCKUNINDENT, GetMenuTextAndBitmap ($$IDM_BLOCKUNINDENT, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_COMMENT, GetMenuTextAndBitmap ($$IDM_COMMENT, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_UNCOMMENT, GetMenuTextAndBitmap ($$IDM_UNCOMMENT, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_FORMATREGION, GetMenuTextAndBitmap ($$IDM_FORMATREGION, 0))
	AppendMenuA (hMenuEdit, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_SELTOUPPERCASE, GetMenuTextAndBitmap ($$IDM_SELTOUPPERCASE, 0))
	AppendMenuA (hMenuEdit, $$MF_ENABLED, $$IDM_SELTOLOWERCASE, GetMenuTextAndBitmap ($$IDM_SELTOLOWERCASE, 0))
	'AppendMenuA (hMenuEdit, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)

	hMenuSearch = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuSearch, GetMenuTextAndBitmap ($$IDM_SEARCHHEADER, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_FIND, GetMenuTextAndBitmap ($$IDM_FIND, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_FINDNEXT, GetMenuTextAndBitmap ($$IDM_FINDNEXT, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_FINDBACKWARDS, GetMenuTextAndBitmap ($$IDM_FINDBACKWARDS, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_REPLACE, GetMenuTextAndBitmap ($$IDM_REPLACE, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_GOTOLINE, GetMenuTextAndBitmap ($$IDM_GOTOLINE, 0))
	AppendMenuA (hMenuSearch, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_TOGGLEBOOKMARK, GetMenuTextAndBitmap ($$IDM_TOGGLEBOOKMARK, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_NEXTBOOKMARK, GetMenuTextAndBitmap ($$IDM_NEXTBOOKMARK, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_PREVIOUSBOOKMARK, GetMenuTextAndBitmap ($$IDM_PREVIOUSBOOKMARK, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_DELETEBOOKMARKS, GetMenuTextAndBitmap ($$IDM_DELETEBOOKMARKS, 0))
	AppendMenuA (hMenuSearch, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	' AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_FILEFIND, GetMenuTextAndBitmap($$IDM_FILEFIND, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_EXPLORER, GetMenuTextAndBitmap ($$IDM_EXPLORER, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_WINDOWSFIND, GetMenuTextAndBitmap ($$IDM_WINDOWSFIND, 0))
	AppendMenuA (hMenuSearch, $$MF_ENABLED, $$IDM_FINDINFILES, GetMenuTextAndBitmap ($$IDM_FINDINFILES, 0))

	hMenuCode = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuCode, GetMenuTextAndBitmap ($$IDM_CODEHEADER, 0))
	AppendMenuA (hMenuCode, $$MF_ENABLED, $$IDM_NEWFUNCTION, GetMenuTextAndBitmap ($$IDM_NEWFUNCTION, 0))
  AppendMenuA (hMenuCode, $$MF_ENABLED, $$IDM_DELETEFUNCTION, GetMenuTextAndBitmap ($$IDM_DELETEFUNCTION, 0))
'  AppendMenuA (hMenuCode, $$MF_ENABLED, $$IDM_RENAMEFUNCTION, GetMenuTextAndBitmap ($$IDM_RENAMEFUNCTION, 0))
  AppendMenuA (hMenuCode, $$MF_ENABLED, $$IDM_CLONEFUNCTION, GetMenuTextAndBitmap ($$IDM_CLONEFUNCTION, 0))
  AppendMenuA (hMenuCode, $$MF_ENABLED, $$IDM_IMPORTFUNCTION, GetMenuTextAndBitmap ($$IDM_IMPORTFUNCTION, 0))
  AppendMenuA (hMenuCode, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)

	hMenuMacro = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuMacro, GetMenuTextAndBitmap ($$IDM_MACROHEADER, 0))
	AppendMenuA (hMenuMacro, $$MF_ENABLED, $$IDM_MACRORECORD, GetMenuTextAndBitmap ($$IDM_MACRORECORD, 0))
  AppendMenuA (hMenuMacro, $$MF_ENABLED, $$IDM_MACROSTOPRECORD, GetMenuTextAndBitmap ($$IDM_MACROSTOPRECORD, 0))
  AppendMenuA (hMenuMacro, $$MF_ENABLED, $$IDM_MACROPLAY, GetMenuTextAndBitmap ($$IDM_MACROPLAY, 0))

  hMenuTemplates = CreatePopupMenu ()
	' owner-draw doesn't work here
	' AppendMenuA (hMenuEdit, $$MF_POPUP OR $$MF_ENABLED, hMenuTemplates, GetMenuTextAndBitmap($$IDM_TEMPLATES, 0))
	' label$ = "template 0"
	' AppendMenuA (hMenuTemplates, $$MF_ENABLED, $$IDM_TEMPLATESTART, &label$)

	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_STRING | $$MIIM_DATA | $$MIIM_ID | $$MIIM_SUBMENU
	' ***** don't use $$MFT_STRING | $$MFT_OWNERDRAW together *****
	mii.fType = $$MFT_STRING
	mii.wID = $$IDM_TEMPLATES
	mii.hSubMenu = hMenuTemplates
	mii.dwTypeData = GetMenuTextAndBitmap ($$IDM_TEMPLATES, 0)
	InsertMenuItemA (hMenuCode, GetMenuItemCount (hMenuCode), 1, &mii)

	' add sub-menu template items here
	FOR i = $$IDM_TEMPLATESTART TO $$IDM_TEMPLATESTART + templateCount - 1

		textAddr = GetMenuTextAndBitmap (i, 0)
		SELECT CASE UBYTEAT(textAddr)
			CASE '|'	:
				' insert a horizontal separator
				AppendMenuA (hMenuTemplates, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
			CASE '>'  :
				' create a popup menu for subsequent items and link previous
				' item to the popup menu
				hSubMenu = CreatePopupMenu ()
				mii.cbSize = SIZE (mii)
				mii.fMask = $$MIIM_STRING | $$MIIM_DATA | $$MIIM_ID | $$MIIM_SUBMENU
				' ***** don't use $$MFT_STRING | $$MFT_OWNERDRAW together *****
				mii.fType = $$MFT_STRING
				mii.wID = i-1
				mii.hSubMenu = hSubMenu
				mii.dwTypeData = GetMenuTextAndBitmap (i-1, 0)
				ret = SetMenuItemInfoA (hMenuTemplates, GetMenuItemCount (hMenuTemplates)-1, 1, &mii)
				fSubMenu = $$TRUE
			CASE '<' 	:
				' end of submenu items
				fSubMenu = $$FALSE
			CASE ELSE :
				' add item as a normal menu item or add to current submenu
				IF fSubMenu THEN
					AppendMenuA (hSubMenu, $$MF_ENABLED, i, textAddr)
				ELSE
					AppendMenuA (hMenuTemplates, $$MF_ENABLED, i, textAddr)
				END IF
		END SELECT
	NEXT i

  AppendMenuA (hMenuCode, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuCode, $$MF_ENABLED, $$IDM_MSGBOXBUILDER, GetMenuTextAndBitmap ($$IDM_MSGBOXBUILDER, 0))

	hMenuRun = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuRun, GetMenuTextAndBitmap ($$IDM_RUNHEADER, 0))
	AppendMenuA (hMenuRun, $$MF_ENABLED, $$IDM_COMPILE, GetMenuTextAndBitmap ($$IDM_COMPILE, 0))
	AppendMenuA (hMenuRun, $$MF_ENABLED, $$IDM_COMPILE_LIB, GetMenuTextAndBitmap ($$IDM_COMPILE_LIB, 0))
	AppendMenuA (hMenuRun, $$MF_ENABLED, $$IDM_BUILD, GetMenuTextAndBitmap ($$IDM_BUILD, 0))
	' AppendMenuA (hMenuRun, $$MF_ENABLED, $$IDM_COMPILEANDDEBUG, GetMenuTextAndBitmap($$IDM_COMPILEANDDEBUG, 0))
	AppendMenuA (hMenuRun, $$MF_ENABLED, $$IDM_EXECUTE, GetMenuTextAndBitmap ($$IDM_EXECUTE, 0))
	AppendMenuA (hMenuRun, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuRun, $$MF_ENABLED, $$IDM_COMMANDLINE, GetMenuTextAndBitmap ($$IDM_COMMANDLINE, 0))
	' AppendMenuA (hMenuRun, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	' AppendMenuA (hMenuRun, $$MF_ENABLED, $$IDM_DEBUGTOOL, GetMenuTextAndBitmap($$IDM_DEBUGTOOL, 0))

	hMenuView = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuView, GetMenuTextAndBitmap ($$IDM_VIEWHEADER, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_TOGGLE, GetMenuTextAndBitmap ($$IDM_TOGGLE, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_TOGGLEALL, GetMenuTextAndBitmap ($$IDM_TOGGLEALL, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_FOLDALL, GetMenuTextAndBitmap ($$IDM_FOLDALL, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_EXPANDALL, GetMenuTextAndBitmap ($$IDM_EXPANDALL, 0))
	AppendMenuA (hMenuView, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_ZOOMIN, GetMenuTextAndBitmap ($$IDM_ZOOMIN, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_ZOOMOUT, GetMenuTextAndBitmap ($$IDM_ZOOMOUT, 0))
	AppendMenuA (hMenuView, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_USETABS, GetMenuTextAndBitmap ($$IDM_USETABS, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_AUTOINDENT, GetMenuTextAndBitmap ($$IDM_AUTOINDENT, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_SHOWLINENUM, GetMenuTextAndBitmap ($$IDM_SHOWLINENUM, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_SHOWMARGIN, GetMenuTextAndBitmap ($$IDM_SHOWMARGIN, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_SHOWINDENT, GetMenuTextAndBitmap ($$IDM_SHOWINDENT, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_SHOWSPACES, GetMenuTextAndBitmap ($$IDM_SHOWSPACES, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_SHOWEOL, GetMenuTextAndBitmap ($$IDM_SHOWEOL, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_SHOWEDGE, GetMenuTextAndBitmap ($$IDM_SHOWEDGE, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_SHOWPROCNAME, GetMenuTextAndBitmap ($$IDM_SHOWPROCNAME, 0))
	AppendMenuA (hMenuView, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_CVEOLTOCRLF, GetMenuTextAndBitmap ($$IDM_CVEOLTOCRLF, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_CVEOLTOCR, GetMenuTextAndBitmap ($$IDM_CVEOLTOCR, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_CVEOLTOLF, GetMenuTextAndBitmap ($$IDM_CVEOLTOLF, 0))
	AppendMenuA (hMenuView, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_REPLSPCWITHTABS, GetMenuTextAndBitmap ($$IDM_REPLSPCWITHTABS, 0))
	AppendMenuA (hMenuView, $$MF_ENABLED, $$IDM_REPLTABSWITHSPC, GetMenuTextAndBitmap ($$IDM_REPLTABSWITHSPC, 0))

	hMenuWindow = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuWindow, GetMenuTextAndBitmap ($$IDM_WINDOWHEADER, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_CASCADE, GetMenuTextAndBitmap ($$IDM_CASCADE, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_TILEH, GetMenuTextAndBitmap ($$IDM_TILEH, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_TILEV, GetMenuTextAndBitmap ($$IDM_TILEV, 0))
	AppendMenuA (hMenuWindow, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_RESTOREWSIZE, GetMenuTextAndBitmap ($$IDM_RESTOREWSIZE, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_SWITCHWINDOW, GetMenuTextAndBitmap ($$IDM_SWITCHWINDOW, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_ARRANGE, GetMenuTextAndBitmap ($$IDM_ARRANGE, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_CLOSEWINDOWS, GetMenuTextAndBitmap ($$IDM_CLOSEWINDOWS, 0))
	AppendMenuA (hMenuWindow, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_SHOWCONSOLE, GetMenuTextAndBitmap ($$IDM_SHOWCONSOLE, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_HIDECONSOLE, GetMenuTextAndBitmap ($$IDM_HIDECONSOLE, 0))
	AppendMenuA (hMenuWindow, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_SHOWTREEBROWSER, GetMenuTextAndBitmap ($$IDM_SHOWTREEBROWSER, 0))
	AppendMenuA (hMenuWindow, $$MF_ENABLED, $$IDM_HIDETREEBROWSER, GetMenuTextAndBitmap ($$IDM_HIDETREEBROWSER, 0))

	hMenuOptions = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuOptions, GetMenuTextAndBitmap ($$IDM_OPTIONSHEADER, 0))
	AppendMenuA (hMenuOptions, $$MF_ENABLED, $$IDM_EDITOROPT, GetMenuTextAndBitmap ($$IDM_EDITOROPT, 0))
	AppendMenuA (hMenuOptions, $$MF_ENABLED, $$IDM_COMPILEROPT, GetMenuTextAndBitmap ($$IDM_COMPILEROPT, 0))
	AppendMenuA (hMenuOptions, $$MF_ENABLED, $$IDM_COLORSOPT, GetMenuTextAndBitmap ($$IDM_COLORSOPT, 0))
	AppendMenuA (hMenuOptions, $$MF_ENABLED, $$IDM_TOOLSOPT, GetMenuTextAndBitmap ($$IDM_TOOLSOPT, 0))
	AppendMenuA (hMenuOptions, $$MF_ENABLED, $$IDM_FOLDINGOPT, GetMenuTextAndBitmap ($$IDM_FOLDINGOPT, 0))
	AppendMenuA (hMenuOptions, $$MF_ENABLED, $$IDM_PRINTINGOPT, GetMenuTextAndBitmap ($$IDM_PRINTINGOPT, 0))

	hMenuTools = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuTools, GetMenuTextAndBitmap($$IDM_TOOLSHEADER, 0))
	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_CALCULATOR, GetMenuTextAndBitmap ($$IDM_CALCULATOR, 0))

	toolCount = 0
	IF tools$[] THEN
		toolCount = UBOUND(tools$[]) + 1
	' add sub-menu template items here
		FOR i = $$IDM_TOOLSTART TO $$IDM_TOOLSTART + toolCount - 1
			AppendMenuA (hMenuTools, $$MF_ENABLED, i, GetMenuTextAndBitmap (i, 0))
		NEXT i
	END IF

'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_CODEC, GetMenuTextAndBitmap ($$IDM_CODEC, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_CHARMAP, GetMenuTextAndBitmap ($$IDM_CHARMAP, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_CODETIPSBUILDER, GetMenuTextAndBitmap ($$IDM_CODETIPSBUILDER, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_CODETYPEBUILDER, GetMenuTextAndBitmap ($$IDM_CODETYPEBUILDER, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_CODEKEEPER, GetMenuTextAndBitmap ($$IDM_CODEKEEPER, 0))

'	AppendMenuA (hMenuTools, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_PBFORMS, GetMenuTextAndBitmap ($$IDM_PBFORMS, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_PBCOMBR, GetMenuTextAndBitmap ($$IDM_PBCOMBR, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_TYPELIBBR, GetMenuTextAndBitmap ($$IDM_TYPELIBBR, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_DLGEDITOR, GetMenuTextAndBitmap ($$IDM_DLGEDITOR, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_IMGEDITOR, GetMenuTextAndBitmap ($$IDM_IMGEDITOR, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_RCEDITOR, GetMenuTextAndBitmap ($$IDM_RCEDITOR, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_VISDES, GetMenuTextAndBitmap ($$IDM_VISDES, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_TBBDES, GetMenuTextAndBitmap ($$IDM_TBBDES, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_POFFS, GetMenuTextAndBitmap ($$IDM_POFFS, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_PBWINSPY, GetMenuTextAndBitmap ($$IDM_PBWINSPY, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_INCLEAN, GetMenuTextAndBitmap ($$IDM_INCLEAN, 0))
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_COPYCAT, GetMenuTextAndBitmap ($$IDM_COPYCAT, 0))
'	AppendMenuA (hMenuTools, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_MORETOOLS, GetMenuTextAndBitmap ($$IDM_MORETOOLS, 0))
'	AppendMenuA (hMenuTools, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
'	AppendMenuA (hMenuTools, $$MF_ENABLED, $$IDM_CALCULATOR, GetMenuTextAndBitmap ($$IDM_CALCULATOR, 0))

	hMenuHelp = CreatePopupMenu ()
	AppendMenuA (hMenu, $$MF_POPUP OR $$MF_ENABLED, hMenuHelp, GetMenuTextAndBitmap ($$IDM_HELPHEADER, 0))
	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_HELP, GetMenuTextAndBitmap($$IDM_HELP, 0))
	AppendMenuA (hMenuHelp, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)

	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_XBLHTMLHELP, GetMenuTextAndBitmap ($$IDM_XBLHTMLHELP, 0))
	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_XSEDHTMLHELP, GetMenuTextAndBitmap ($$IDM_XSEDHTMLHELP, 0))
	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_GOASMHELP, GetMenuTextAndBitmap ($$IDM_GOASMHELP, 0))
	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_WIN32HELP, GetMenuTextAndBitmap ($$IDM_WIN32HELP, 0))
	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_RCHELP, GetMenuTextAndBitmap ($$IDM_RCHELP, 0))
	' AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_MSDN, GetMenuTextAndBitmap($$IDM_MSDN, 0))
	AppendMenuA (hMenuHelp, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)

	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_XBLSITE, GetMenuTextAndBitmap ($$IDM_XBLSITE, 0))
	' AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_MSDNSITE, GetMenuTextAndBitmap($$IDM_MSDNSITE, 0))
	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_GOOGLE, GetMenuTextAndBitmap ($$IDM_GOOGLE, 0))
	AppendMenuA (hMenuHelp, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)

	AppendMenuA (hMenuHelp, $$MF_ENABLED, $$IDM_ABOUT, GetMenuTextAndBitmap ($$IDM_ABOUT, 0))

	SetMenu (hWnd, hMenu)

	' menu item changed to ownerdraw, done here since if done above
	' using AppendMenuA with $$MF_ENABLED OR $$MF_OWNERDRAW flags
	' causes shortcut keys to fail
	ModifyMenuA (hMenuFile, $$IDM_NEW, $$MF_OWNERDRAW, $$IDM_NEW, NULL)
	ModifyMenuA (hMenuFile, $$IDM_OPEN, $$MF_OWNERDRAW, $$IDM_OPEN, NULL)
	ModifyMenuA (hMenuFile, $$IDM_SAVE, $$MF_OWNERDRAW, $$IDM_SAVE, NULL)
	ModifyMenuA (hMenuFile, $$IDM_SAVEAS, $$MF_OWNERDRAW, $$IDM_SAVEAS, NULL)
	ModifyMenuA (hMenuFile, $$IDM_HTMLCODE, $$MF_OWNERDRAW, $$IDM_HTMLCODE, NULL)
	ModifyMenuA (hMenuFile, $$IDM_CLOSEFILE, $$MF_OWNERDRAW, $$IDM_CLOSEFILE, NULL)
	ModifyMenuA (hMenuFile, $$IDM_CLOSEALL, $$MF_OWNERDRAW, $$IDM_CLOSEALL, NULL)
	ModifyMenuA (hMenuFile, $$IDM_PRINTERSETUP, $$MF_OWNERDRAW, $$IDM_PRINTERSETUP, NULL)
'	ModifyMenuA (hMenuFile, $$IDM_PRINTPREVIEW, $$MF_OWNERDRAW, $$IDM_PRINTPREVIEW, NULL)
	ModifyMenuA (hMenuFile, $$IDM_PRINT, $$MF_OWNERDRAW, $$IDM_PRINT, NULL)

  ModifyMenuA (hMenuFile, $$IDM_RECENTSTART, $$MF_OWNERDRAW, $$IDM_RECENTSTART, NULL)

	ModifyMenuA (hMenuFile, $$IDM_EXPLOREHERE, $$MF_OWNERDRAW, $$IDM_EXPLOREHERE, NULL)
	ModifyMenuA (hMenuFile, $$IDM_DOS, $$MF_OWNERDRAW, $$IDM_DOS, NULL)
	ModifyMenuA (hMenuFile, $$IDM_EXIT, $$MF_OWNERDRAW, $$IDM_EXIT, NULL)

	ModifyMenuA (hMenuEdit, $$IDM_UNDO, $$MF_OWNERDRAW, $$IDM_UNDO, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_REDO, $$MF_OWNERDRAW, $$IDM_REDO, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_LINEDELETE, $$MF_OWNERDRAW, $$IDM_LINEDELETE, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_CLEAR, $$MF_OWNERDRAW, $$IDM_CLEAR, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_CLEARALL, $$MF_OWNERDRAW, $$IDM_CLEARALL, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_CUT, $$MF_OWNERDRAW, $$IDM_CUT, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_COPY, $$MF_OWNERDRAW, $$IDM_COPY, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_PASTE, $$MF_OWNERDRAW, $$IDM_PASTE, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_SELECTALL, $$MF_OWNERDRAW, $$IDM_SELECTALL, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_BLOCKINDENT, $$MF_OWNERDRAW, $$IDM_BLOCKINDENT, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_BLOCKUNINDENT, $$MF_OWNERDRAW, $$IDM_BLOCKUNINDENT, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_COMMENT, $$MF_OWNERDRAW, $$IDM_COMMENT, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_UNCOMMENT, $$MF_OWNERDRAW, $$IDM_UNCOMMENT, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_FORMATREGION, $$MF_OWNERDRAW, $$IDM_FORMATREGION, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_SELTOUPPERCASE, $$MF_OWNERDRAW, $$IDM_SELTOUPPERCASE, NULL)
	ModifyMenuA (hMenuEdit, $$IDM_SELTOLOWERCASE, $$MF_OWNERDRAW, $$IDM_SELTOLOWERCASE, NULL)

	ModifyMenuA (hMenuSearch, $$IDM_FIND, $$MF_OWNERDRAW, $$IDM_FIND, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_FINDNEXT, $$MF_OWNERDRAW, $$IDM_FINDNEXT, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_FINDBACKWARDS, $$MF_OWNERDRAW, $$IDM_FINDBACKWARDS, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_REPLACE, $$MF_OWNERDRAW, $$IDM_REPLACE, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_GOTOLINE, $$MF_OWNERDRAW, $$IDM_GOTOLINE, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_TOGGLEBOOKMARK, $$MF_OWNERDRAW, $$IDM_TOGGLEBOOKMARK, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_NEXTBOOKMARK, $$MF_OWNERDRAW, $$IDM_NEXTBOOKMARK, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_PREVIOUSBOOKMARK, $$MF_OWNERDRAW, $$IDM_PREVIOUSBOOKMARK, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_DELETEBOOKMARKS, $$MF_OWNERDRAW, $$IDM_DELETEBOOKMARKS, NULL)
	' ModifyMenuA (hMenuSearch, $$IDM_FILEFIND, $$MF_OWNERDRAW, $$IDM_FILEFIND, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_EXPLORER, $$MF_OWNERDRAW, $$IDM_EXPLORER, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_WINDOWSFIND, $$MF_OWNERDRAW, $$IDM_WINDOWSFIND, NULL)
	ModifyMenuA (hMenuSearch, $$IDM_FINDINFILES, $$MF_OWNERDRAW, $$IDM_FINDINFILES, NULL)

	ModifyMenuA (hMenuCode, $$IDM_NEWFUNCTION, $$MF_OWNERDRAW, $$IDM_NEWFUNCTION, NULL)
  ModifyMenuA (hMenuCode, $$IDM_DELETEFUNCTION, $$MF_OWNERDRAW, $$IDM_DELETEFUNCTION, NULL)
'  ModifyMenuA (hMenuCode, $$IDM_RENAMEFUNCTION, $$MF_OWNERDRAW, $$IDM_RENAMEFUNCTION, NULL)
  ModifyMenuA (hMenuCode, $$IDM_CLONEFUNCTION, $$MF_OWNERDRAW, $$IDM_CLONEFUNCTION, NULL)
  ModifyMenuA (hMenuCode, $$IDM_IMPORTFUNCTION, $$MF_OWNERDRAW, $$IDM_IMPORTFUNCTION, NULL)

	ModifyMenuA (hMenuCode, $$IDM_TEMPLATES, $$MF_OWNERDRAW, $$IDM_TEMPLATES, NULL)
	FOR i = $$IDM_TEMPLATESTART TO $$IDM_TEMPLATESTART + templateCount - 1
		ModifyMenuA (hMenuCode, i, $$MF_OWNERDRAW, i, NULL)
	NEXT i

	ModifyMenuA (hMenuCode, $$IDM_MSGBOXBUILDER, $$MF_OWNERDRAW, $$IDM_MSGBOXBUILDER, NULL)

	ModifyMenuA (hMenuMacro, $$IDM_MACRORECORD, $$MF_OWNERDRAW, $$IDM_MACRORECORD, NULL)
	ModifyMenuA (hMenuMacro, $$IDM_MACROSTOPRECORD, $$MF_OWNERDRAW, $$IDM_MACROSTOPRECORD, NULL)
	ModifyMenuA (hMenuMacro, $$IDM_MACROPLAY, $$MF_OWNERDRAW, $$IDM_MACROPLAY, NULL)

	ModifyMenuA (hMenuRun, $$IDM_COMPILE, $$MF_OWNERDRAW, $$IDM_COMPILE, NULL)
  ModifyMenuA (hMenuRun, $$IDM_COMPILE_LIB, $$MF_OWNERDRAW, $$IDM_COMPILE_LIB, NULL)
	ModifyMenuA (hMenuRun, $$IDM_BUILD, $$MF_OWNERDRAW, $$IDM_BUILD, NULL)
	' ModifyMenuA (hMenuRun, $$IDM_COMPILEANDDEBUG, $$MF_OWNERDRAW, $$IDM_COMPILEANDDEBUG, NULL)
	ModifyMenuA (hMenuRun, $$IDM_EXECUTE, $$MF_OWNERDRAW, $$IDM_EXECUTE, NULL)
	ModifyMenuA (hMenuRun, $$IDM_COMMANDLINE, $$MF_OWNERDRAW, $$IDM_COMMANDLINE, NULL)
	' ModifyMenuA (hMenuRun, $$IDM_DEBUGTOOL, $$MF_OWNERDRAW, $$IDM_DEBUGTOOL, NULL)

	ModifyMenuA (hMenuView, $$IDM_TOGGLE, $$MF_OWNERDRAW, $$IDM_TOGGLE, NULL)
	ModifyMenuA (hMenuView, $$IDM_TOGGLEALL, $$MF_OWNERDRAW, $$IDM_TOGGLEALL, NULL)
	ModifyMenuA (hMenuView, $$IDM_FOLDALL, $$MF_OWNERDRAW, $$IDM_FOLDALL, NULL)
	ModifyMenuA (hMenuView, $$IDM_EXPANDALL, $$MF_OWNERDRAW, $$IDM_EXPANDALL, NULL)
	ModifyMenuA (hMenuView, $$IDM_ZOOMIN, $$MF_OWNERDRAW, $$IDM_ZOOMIN, NULL)
	ModifyMenuA (hMenuView, $$IDM_ZOOMOUT, $$MF_OWNERDRAW, $$IDM_ZOOMOUT, NULL)
	ModifyMenuA (hMenuView, $$IDM_USETABS, $$MF_OWNERDRAW, $$IDM_USETABS, NULL)
	ModifyMenuA (hMenuView, $$IDM_AUTOINDENT, $$MF_OWNERDRAW, $$IDM_AUTOINDENT, NULL)
	ModifyMenuA (hMenuView, $$IDM_SHOWLINENUM, $$MF_OWNERDRAW, $$IDM_SHOWLINENUM, NULL)
	ModifyMenuA (hMenuView, $$IDM_SHOWMARGIN, $$MF_OWNERDRAW, $$IDM_SHOWMARGIN, NULL)
	ModifyMenuA (hMenuView, $$IDM_SHOWINDENT, $$MF_OWNERDRAW, $$IDM_SHOWINDENT, NULL)
	ModifyMenuA (hMenuView, $$IDM_SHOWSPACES, $$MF_OWNERDRAW, $$IDM_SHOWSPACES, NULL)
	ModifyMenuA (hMenuView, $$IDM_SHOWEOL, $$MF_OWNERDRAW, $$IDM_SHOWEOL, NULL)
	ModifyMenuA (hMenuView, $$IDM_SHOWEDGE, $$MF_OWNERDRAW, $$IDM_SHOWEDGE, NULL)
	ModifyMenuA (hMenuView, $$IDM_SHOWPROCNAME, $$MF_OWNERDRAW, $$IDM_SHOWPROCNAME, NULL)
	ModifyMenuA (hMenuView, $$IDM_CVEOLTOCRLF, $$MF_OWNERDRAW, $$IDM_CVEOLTOCRLF, NULL)
	ModifyMenuA (hMenuView, $$IDM_CVEOLTOCR, $$MF_OWNERDRAW, $$IDM_CVEOLTOCR, NULL)
	ModifyMenuA (hMenuView, $$IDM_CVEOLTOLF, $$MF_OWNERDRAW, $$IDM_CVEOLTOLF, NULL)
	ModifyMenuA (hMenuView, $$IDM_REPLSPCWITHTABS, $$MF_OWNERDRAW, $$IDM_REPLSPCWITHTABS, NULL)
	ModifyMenuA (hMenuView, $$IDM_REPLTABSWITHSPC, $$MF_OWNERDRAW, $$IDM_REPLTABSWITHSPC, NULL)

	ModifyMenuA (hMenuWindow, $$IDM_CASCADE, $$MF_OWNERDRAW, $$IDM_CASCADE, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_TILEH, $$MF_OWNERDRAW, $$IDM_TILEH, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_TILEV, $$MF_OWNERDRAW, $$IDM_TILEV, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_RESTOREWSIZE, $$MF_OWNERDRAW, $$IDM_RESTOREWSIZE, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_SWITCHWINDOW, $$MF_OWNERDRAW, $$IDM_SWITCHWINDOW, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_ARRANGE, $$MF_OWNERDRAW, $$IDM_ARRANGE, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_CLOSEWINDOWS, $$MF_OWNERDRAW, $$IDM_CLOSEWINDOWS, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_HIDECONSOLE, $$MF_OWNERDRAW, $$IDM_HIDECONSOLE, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_SHOWCONSOLE, $$MF_OWNERDRAW, $$IDM_SHOWCONSOLE, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_HIDETREEBROWSER, $$MF_OWNERDRAW, $$IDM_HIDETREEBROWSER, NULL)
	ModifyMenuA (hMenuWindow, $$IDM_SHOWTREEBROWSER, $$MF_OWNERDRAW, $$IDM_SHOWTREEBROWSER, NULL)

	ModifyMenuA (hMenuOptions, $$IDM_EDITOROPT, $$MF_OWNERDRAW, $$IDM_EDITOROPT, NULL)
	ModifyMenuA (hMenuOptions, $$IDM_COMPILEROPT, $$MF_OWNERDRAW, $$IDM_COMPILEROPT, NULL)
	ModifyMenuA (hMenuOptions, $$IDM_COLORSOPT, $$MF_OWNERDRAW, $$IDM_COLORSOPT, NULL)
	ModifyMenuA (hMenuOptions, $$IDM_TOOLSOPT, $$MF_OWNERDRAW, $$IDM_TOOLSOPT, NULL)
	ModifyMenuA (hMenuOptions, $$IDM_FOLDINGOPT, $$MF_OWNERDRAW, $$IDM_FOLDINGOPT, NULL)
	ModifyMenuA (hMenuOptions, $$IDM_PRINTINGOPT, $$MF_OWNERDRAW, $$IDM_PRINTINGOPT, NULL)

	ModifyMenuA (hMenuTools, $$IDM_CALCULATOR, $$MF_OWNERDRAW, $$IDM_CALCULATOR, NULL)
	IF toolCount THEN
		FOR i = $$IDM_TOOLSTART TO $$IDM_TOOLSTART + toolCount - 1
			ModifyMenuA (hMenuTools, i, $$MF_OWNERDRAW, i, NULL)
		NEXT i
	END IF

	' ModifyMenuA (hMenuTools, $$IDM_CODEC, $$MF_OWNERDRAW, $$IDM_CODEC, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_CHARMAP, $$MF_OWNERDRAW, $$IDM_CHARMAP, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_CODETIPSBUILDER, $$MF_OWNERDRAW, $$IDM_CODETIPSBUILDER, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_CODETYPEBUILDER, $$MF_OWNERDRAW, $$IDM_CODETYPEBUILDER, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_CODEKEEPER, $$MF_OWNERDRAW, $$IDM_CODEKEEPER, NULL)

	' ModifyMenuA (hMenuTools, $$IDM_PBFORMS, $$MF_OWNERDRAW, $$IDM_PBFORMS, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_PBCOMBR, $$MF_OWNERDRAW, $$IDM_PBCOMBR, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_TYPELIBBR, $$MF_OWNERDRAW, $$IDM_TYPELIBBR, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_DLGEDITOR, $$MF_OWNERDRAW, $$IDM_DLGEDITOR, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_IMGEDITOR, $$MF_OWNERDRAW, $$IDM_IMGEDITOR, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_RCEDITOR, $$MF_OWNERDRAW, $$IDM_RCEDITOR, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_VISDES, $$MF_OWNERDRAW, $$IDM_VISDES, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_TBBDES, $$MF_OWNERDRAW, $$IDM_TBBDES, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_POFFS, $$MF_OWNERDRAW, $$IDM_POFFS, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_PBWINSPY, $$MF_OWNERDRAW, $$IDM_PBWINSPY, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_INCLEAN, $$MF_OWNERDRAW, $$IDM_INCLEAN, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_COPYCAT, $$MF_OWNERDRAW, $$IDM_COPYCAT, NULL)
	' ModifyMenuA (hMenuTools, $$IDM_MORETOOLS, $$MF_OWNERDRAW, $$IDM_MORETOOLS, NULL)


	ModifyMenuA (hMenuHelp, $$IDM_HELP, $$MF_OWNERDRAW, $$IDM_HELP, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_ABOUT, $$MF_OWNERDRAW, $$IDM_ABOUT, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_XBLSITE, $$MF_OWNERDRAW, $$IDM_XBLSITE, NULL)
	' ModifyMenuA (hMenuHelp, $$IDM_MSDNSITE, $$MF_OWNERDRAW, $$IDM_MSDNSITE, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_GOOGLE, $$MF_OWNERDRAW, $$IDM_GOOGLE, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_XBLHTMLHELP, $$MF_OWNERDRAW, $$IDM_XBLHTMLHELP, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_XSEDHTMLHELP, $$MF_OWNERDRAW, $$IDM_XSEDHTMLHELP, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_GOASMHELP, $$MF_OWNERDRAW, $$IDM_GOASMHELP, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_WIN32HELP, $$MF_OWNERDRAW, $$IDM_WIN32HELP, NULL)
	ModifyMenuA (hMenuHelp, $$IDM_RCHELP, $$MF_OWNERDRAW, $$IDM_RCHELP, NULL)
	' ModifyMenuA (hMenuHelp, $$IDM_MSDN, $$MF_OWNERDRAW, $$IDM_MSDN, NULL)

	RETURN hMenu

END FUNCTION
'
' #####################################
' #####  GetMenuTextAndBitmap ()  #####
' #####################################
'
' Description : Return menu item string pointer and zero-based bitmap number (-1 = no bitmap).
' Bitmap ImageList Strip starts at Zero, so BmpNum starts at Zero.
'
FUNCTION GetMenuTextAndBitmap (ItemId, @BmpNum)

	SHARED RecentFiles$[]
	SHARED strContextMenu$
	STATIC menu$, init
	SHARED templateCount, templateMenu$[], templateFN$[]
	SHARED tools$[]

	$TAB = "\t"

	IFZ init THEN GOSUB Initialize

	SELECT CASE TRUE
		CASE (ItemId >= $$IDM_RECENTSTART+1) && (ItemId <= $$IDM_RECENTSTART + 1 + $$MAX_MRU) :
	 		BmpNum = 2
			IF (ItemId - $$IDM_RECENTSTART) >= 1 && (ItemId - $$IDM_RECENTSTART) <= UBOUND (RecentFiles$[]) + 1 THEN
				menu$ = STRING$ (ItemId - $$IDM_RECENTSTART) + " " + RecentFiles$[ItemId - $$IDM_RECENTSTART - 1]
				RETURN (&menu$)
			END IF
  END SELECT

	SELECT CASE TRUE
		upp =  $$IDM_TOOLSTART + UBOUND(tools$[]) + 1
		CASE (ItemId >= $$IDM_TOOLSTART) && (ItemId <= upp) :
			menu$ = ""
			XstGetPathComponents (tools$[ItemId-$$IDM_TOOLSTART], "", "", "", @menu$, 0)
			ext$ = ""
			GetFileExtension (menu$, "", @ext$)
			BmpNum = 124
			IF ext$ THEN
				SELECT CASE LCASE$(ext$)
					CASE "exe" : BmpNum = 94
					CASE "bat" : BmpNum = 77
					CASE "hlp" : BmpNum = 87
					CASE "chm" : BmpNum = 88
					CASE "txt", "x", "xl", "xbl", "c", "h", "dec", "xxx" : BmpNum = 31
				END SELECT
			END IF
			RETURN (&menu$)
	END SELECT

	' TEMPLATES SUBMENU
	SELECT CASE TRUE
		CASE (ItemId >= $$IDM_TEMPLATESTART) && (ItemId <= $$IDM_TEMPLATESMAX) :
			BmpNum = 0
			menu$ = templateMenu$[ItemId - $$IDM_TEMPLATESTART]
			RETURN (&menu$)
	END SELECT

	SELECT CASE ItemId

			' FILE MENU.
		CASE $$IDM_FILEHEADER   : BmpNum = -1 : menu$ = "&File"
		CASE $$IDM_NEW          : BmpNum = 1  : menu$ = "&New" + $TAB + "Ctrl+N"
		CASE $$IDM_OPEN         : BmpNum = 2  : menu$ = "&Open..." + $TAB + "Ctrl+O"
		CASE $$IDM_SAVE         : BmpNum = 3  : menu$ = "&Save" + $TAB + "Ctrl+S"
		CASE $$IDM_SAVEAS       : BmpNum = 4  : menu$ = "Save File &As..."
		CASE $$IDM_HTMLCODE     : BmpNum = 32 : menu$ = "Save File As &Html..."
		CASE $$IDM_CLOSEFILE    : BmpNum = 5  : menu$ = "&Close" + $TAB + "Ctrl+F4"
		CASE $$IDM_CLOSEALL     : BmpNum = 6  : menu$ = "Close A&ll Files"
		CASE $$IDM_PRINTERSETUP : BmpNum = 7  : menu$ = "Page Set&up..."
'		CASE $$IDM_PRINTPREVIEW : BmpNum = 8  : menu$ = "Print Pre&view" + $TAB + "Ctrl+Shift+P"
		CASE $$IDM_PRINT        : BmpNum = 9  : menu$ = "&Print File..." + $TAB + "Ctrl+P"
		CASE $$IDM_RECENTSTART  : BmpNum = 2  : menu$ = "&Recent Files"
		CASE $$IDM_EXPLOREHERE  : BmpNum = 116 : menu$ = "&Explore Here"
		CASE $$IDM_DOS          : BmpNum = 10 : menu$ = "Comman&d Prompt" + $TAB + "F7"
		CASE $$IDM_EXIT         : BmpNum = 11 : menu$ = "E&xit" + $TAB + "Alt+F4"


			' CASE $$IDM_GOTOSELFILE :   ' Ownerdraw context menu (include files)
			' BmpNum = 2 : menu$ = strContextMenu$

		CASE $$IDM_GOTOSELPROC :		' Ownerdraw context menu (Find Functions)
			BmpNum = 33 : menu$ = strContextMenu$

		CASE $$IDM_GOTOLASTPOSITION :		' Ownerdraw context menu (Goto last position)
			BmpNum = 36 : menu$ = "Goto Last Position"

		' EDIT MENU.
		CASE $$IDM_EDITHEADER      : BmpNum = -1 : menu$ = "&Edit"
		CASE $$IDM_UNDO            : BmpNum = 12 : menu$ = "U&ndo" + $TAB + "Ctrl+Z"
		CASE $$IDM_REDO            : BmpNum = 13 : menu$ = "Red&o" + $TAB + "Ctrl+Shift+Z"
		CASE $$IDM_LINEDELETE      : BmpNum = 14 : menu$ = "&Delete Line" + $TAB + "Ctrl+Y"
		CASE $$IDM_CLEAR           : BmpNum = 15 : menu$ = "Clea&r"
		CASE $$IDM_CLEARALL        : BmpNum = 16 : menu$ = "Cl&ear All"
		CASE $$IDM_CUT             : BmpNum = 17 : menu$ = "Cu&t" + $TAB + "Ctrl+X"
		CASE $$IDM_COPY            : BmpNum = 18 : menu$ = "&Copy" + $TAB + "Ctrl+C"
		CASE $$IDM_PASTE           : BmpNum = 19 : menu$ = "&Paste" + $TAB + "Ctrl+V"
		CASE $$IDM_SELECTALL       : BmpNum = 21 : menu$ = "Select &All" + $TAB + "Ctrl+A"
		CASE $$IDM_BLOCKINDENT     : BmpNum = 24 : menu$ = "Block Indent" + $TAB + "Tab"
		CASE $$IDM_BLOCKUNINDENT   : BmpNum = 25 : menu$ = "Block Unindent" + $TAB + "Shift+Tab"
		CASE $$IDM_COMMENT         : BmpNum = 22 : menu$ = "&Block Comment" + $TAB + "Ctrl+Q"
		CASE $$IDM_UNCOMMENT       : BmpNum = 23 : menu$ = "Bloc&k Uncomment" + $TAB + "Ctrl+Shift+Q"
		CASE $$IDM_FORMATREGION    : BmpNum = 26 : menu$ = "&Format Text" + $TAB + "Ctrl+B"
		CASE $$IDM_SELTOUPPERCASE  : BmpNum = 28 : menu$ = "Selection to &Upper Case" + $TAB + "Ctrl+U"
		CASE $$IDM_SELTOLOWERCASE  : BmpNum = 29 : menu$ = "Selection to &Lower Case" + $TAB + "Ctrl+L"


		' SEARCH MENU
		CASE $$IDM_SEARCHHEADER  : BmpNum = -1 : menu$ = "&Search"
		CASE $$IDM_FIND          : BmpNum = 33 : menu$ = "&Find..." + $TAB + "Ctrl+F"
		CASE $$IDM_FINDNEXT      : BmpNum = 34 : menu$ = "Find &Next" + $TAB + "F3"
		CASE $$IDM_FINDBACKWARDS : BmpNum = 125 : menu$ = "Find &Backwards" + $TAB + "Shift+F3"
		CASE $$IDM_REPLACE       : BmpNum = 35 : menu$ = "Find and R&eplace..." + $TAB + "Ctrl+R"
		CASE $$IDM_GOTOLINE      : BmpNum = 36 : menu$ = "&Go to Line...       " + $TAB + "Ctrl+G"

		' SEARCH MENU BOOKMARKS
		CASE $$IDM_TOGGLEBOOKMARK   : BmpNum = 37 : menu$ = "Toggle Bookmark" + $TAB + "Ctrl+F2"
		CASE $$IDM_NEXTBOOKMARK     : BmpNum = 38 : menu$ = "Next Bookmark" + $TAB + "F2"
		CASE $$IDM_PREVIOUSBOOKMARK : BmpNum = 39 : menu$ = "Previous Bookmark" + $TAB + "Shift+F2"
		CASE $$IDM_DELETEBOOKMARKS  : BmpNum = 40 : menu$ = "Delete Bookmarks" + $TAB + "Ctrl+Shift+F2"

		' SEARCH MENU FILEFIND
		' CASE $$IDM_FILEFIND  : BmpNum =  41 : menu$ = "Find Files..." + $TAB + "Ctrl+Shift+F"
		CASE $$IDM_EXPLORER    : BmpNum = 116 : menu$ = "Explore..." + $TAB + "Ctrl+Shift+O"
		CASE $$IDM_WINDOWSFIND : BmpNum = 122 : menu$ = "Windows Find..." + $TAB + "Ctrl+Alt+F"
		CASE $$IDM_FINDINFILES : BmpNum = 123 : menu$ = "Find in Files..." + $TAB + "Alt+Shift+F"

		'CODE MENU
		CASE $$IDM_CODEHEADER      : BmpNum = -1  : menu$ = "&Code"
    CASE $$IDM_NEWFUNCTION     : BmpNum = 31  : menu$ = "&New Function"
    CASE $$IDM_DELETEFUNCTION  : BmpNum = 31  : menu$ = "&Delete Function"
'    CASE $$IDM_RENAMEFUNCTION  : BmpNum = 31 : menu$ = "&Rename Function"
    CASE $$IDM_CLONEFUNCTION   : BmpNum = 31  : menu$ = "&Clone Function"
    CASE $$IDM_IMPORTFUNCTION  : BmpNum = 31  : menu$ = "&Import Function"
		CASE $$IDM_TEMPLATES       : BmpNum = 31  : menu$ = "&Template Code"
		CASE $$IDM_MSGBOXBUILDER   : BmpNum = 121 : menu$ = "&Message Box Builder" + $TAB + "Ctrl+M"

		' MACRO MENU
		CASE $$IDM_MACROHEADER      : BmpNum = -1   : menu$ = "&Macro"
    CASE $$IDM_MACRORECORD      : BmpNum = 128  : menu$ = "Macro &Record"
    CASE $$IDM_MACROSTOPRECORD  : BmpNum = 127  : menu$ = "Macro &Stop Recording"
    CASE $$IDM_MACROPLAY        : BmpNum = 126  : menu$ = "Macro &Play"

		' RUN MENU
		CASE $$IDM_RUNHEADER   : BmpNum = -1 : menu$ = "&Run"
		CASE $$IDM_COMPILE     : BmpNum = 42 : menu$ = "&Compile" + $TAB + "F9"
		CASE $$IDM_COMPILE_LIB : BmpNum = 65 : menu$ = "Compile As &Library (DLL)" + $TAB + "Shift+F9"
		CASE $$IDM_BUILD       : BmpNum = 91 : menu$ = "&Build" + $TAB + "F10"
		' CASE $$IDM_COMPILEANDDEBUG  : BmpNum =  44  : menu$ = "Compile and &Debug" + $TAB + "F6"
		CASE $$IDM_EXECUTE     : BmpNum = 43 : menu$ = "E&xecute Without Compiling" + $TAB + "F11"
		CASE $$IDM_COMMANDLINE : BmpNum = 46 : menu$ = "Co&mmand Line..."
		' CASE $$IDM_DEBUGTOOL : BmpNum =  47  : menu$ = "Debu&gging Tool"

		' VIEW MENU
		CASE $$IDM_VIEWHEADER   : BmpNum = -1 : menu$ = "&View"
		CASE $$IDM_TOGGLE       : BmpNum = 48 : menu$ = "Toggle &Current Function" + $TAB + "F8"
		CASE $$IDM_TOGGLEALL    : BmpNum = 49 : menu$ = "Toggle Current Function and All &Below      " + $TAB + "Ctrl+F8"
		CASE $$IDM_FOLDALL      : BmpNum = 50 : menu$ = "&Fold All Functions" + $TAB + "Alt+F8"
		CASE $$IDM_EXPANDALL    : BmpNum = 51 : menu$ = "&Expand All Functions" + $TAB + "Shift+F8"
		CASE $$IDM_ZOOMIN       : BmpNum = 52 : menu$ = "&Zoom In" + $TAB + "Ctrl+F5"
		CASE $$IDM_ZOOMOUT      : BmpNum = 53 : menu$ = "Zoom &Out" + $TAB + "Ctrl+Shift+F5"
		CASE $$IDM_USETABS      : BmpNum = -1 : menu$ = "Use &Tabs" + $TAB + "Ctrl+Shift+T"
		CASE $$IDM_AUTOINDENT   : BmpNum = -1 : menu$ = "&Auto Indentation" + $TAB + "Ctrl+Shift+A"
		CASE $$IDM_SHOWLINENUM  : BmpNum = -1 : menu$ = "&Line Numbers" + $TAB + "Ctrl+Shift+L"
		CASE $$IDM_SHOWMARGIN   : BmpNum = -1 : menu$ = "&Margin" + $TAB + "Ctrl+Shift+M"
		CASE $$IDM_SHOWINDENT   : BmpNum = -1 : menu$ = "&Indentation Guides" + $TAB + "Ctrl+Shift+I"
		CASE $$IDM_SHOWSPACES   : BmpNum = -1 : menu$ = "&Whitespace" + $TAB + "Ctrl+Shift+W"
		CASE $$IDM_SHOWEOL      : BmpNum = -1 : menu$ = "En&d of Line" + $TAB + "Ctrl+Shift+D"
		CASE $$IDM_SHOWEDGE     : BmpNum = -1 : menu$ = "Ed&ge" + $TAB + "Ctrl+Shift+G"
		CASE $$IDM_SHOWPROCNAME : BmpNum = -1 : menu$ = "Show Function &Name" + $TAB + "Ctrl+Shift+N"
		CASE $$IDM_CVEOLTOCRLF  : BmpNum = 54 : menu$ = "Convert End of Line Characters to CRLF"
		CASE $$IDM_CVEOLTOCR    : BmpNum = 55 : menu$ = "Convert End of Line Characters to CR"
		CASE $$IDM_CVEOLTOLF    : BmpNum = 56 : menu$ = "Convert End of Line Characters to LF"
		CASE $$IDM_REPLSPCWITHTABS : BmpNum = 120 : menu$ = "Replace Spaces with Tabs"
		CASE $$IDM_REPLTABSWITHSPC : BmpNum = 119 : menu$ = "Replace Tabs with Spaces"

		' WINDOW MENU
		CASE $$IDM_WINDOWHEADER : BmpNum = -1 : menu$ = "&Window"
		CASE $$IDM_CASCADE      : BmpNum = 57 : menu$ = "&Cascade"
		CASE $$IDM_TILEH        : BmpNum = 58 : menu$ = "Tile &Horizontal"
		CASE $$IDM_TILEV        : BmpNum = 59 : menu$ = "Tile &Vertical"
		CASE $$IDM_RESTOREWSIZE : BmpNum = 60 : menu$ = "&Restore Main Window Size"
		CASE $$IDM_SWITCHWINDOW : BmpNum = 61 : menu$ = "&Switch Window    " + $TAB + "Ctrl+W"
		CASE $$IDM_ARRANGE      : BmpNum = 62 : menu$ = "Arrange &Icons"
		CASE $$IDM_CLOSEWINDOWS : BmpNum = 63 : menu$ = "Close &All"
		CASE $$IDM_SHOWCONSOLE  : BmpNum = 60 : menu$ = "Show Console Window" + $TAB + "Ctrl+Shift+S"
		CASE $$IDM_HIDECONSOLE  : BmpNum = 63 : menu$ = "Hide Console Window" + $TAB + "Ctrl+Shift+H"
		CASE $$IDM_SHOWTREEBROWSER   : BmpNum = 60  : menu$ = "Show Function &Browser" + $TAB + "Ctrl+Shift+B"
		CASE $$IDM_HIDETREEBROWSER   : BmpNum = 63  : menu$ = "Hide Function Br&owser" + $TAB + "Ctrl+Alt+B"

	' OPTIONS MENU
		CASE $$IDM_OPTIONSHEADER : BmpNum = -1 : menu$ = "&Options"
		CASE $$IDM_EDITOROPT     : BmpNum = 64 : menu$ = "&Editor..."
		CASE $$IDM_COMPILEROPT   : BmpNum = 65 : menu$ = "&Compiler..."
		CASE $$IDM_COLORSOPT     : BmpNum = 66 : menu$ = "C&olors and Fonts..."
		CASE $$IDM_TOOLSOPT      : BmpNum = 67 : menu$ = "&Tools..."
		CASE $$IDM_FOLDINGOPT    : BmpNum = 100 : menu$ = "&Folding..."
		CASE $$IDM_PRINTINGOPT	 : BmpNum = 9  : menu$ = "&Printing..."

		' CONTEXT MENU
		CASE $$IDM_CHARMAP        : BmpNum = 117 : menu$ = "C&haracter Map" + $TAB + "Ctrl+Shift+K"
		CASE $$IDM_OPENASMFILE		: BmpNum = 2   : menu$ = "&View Assembly File"

		' TOOLS MENU
		CASE $$IDM_TOOLSHEADER     : BmpNum = -1 : menu$ = "&Tools"
'		CASE $$IDM_CODEC           : BmpNum = 69 : menu$ = "Code &Analyzer"
'		CASE $$IDM_CODETIPSBUILDER : BmpNum = 70 : menu$ = "Codetips &Builder"
'		CASE $$IDM_CODETYPEBUILDER : BmpNum = 98 : menu$ = "Codet&ype Builder"
'		CASE $$IDM_CODEKEEPER      : BmpNum = 71 : menu$ = "Code &Keeper" + $TAB + "F9"


'		CASE $$IDM_PBFORMS    : BmpNum = 72 : menu$ = "PowerBasic &Forms" + $TAB + "F7"
'		CASE $$IDM_PBCOMBR    : BmpNum = 73 : menu$ = "PowerBasic &COM Browser"
'		CASE $$IDM_TYPELIBBR  : BmpNum = 74 : menu$ = "&TypeLib Browser"
'		CASE $$IDM_DLGEDITOR  : BmpNum = 75 : menu$ = "&Dialog Editor"
'		CASE $$IDM_IMGEDITOR  : BmpNum = 76 : menu$ = "&Image Editor"
'		CASE $$IDM_RCEDITOR   : BmpNum = 77 : menu$ = "&Resource Editor"
'		CASE $$IDM_VISDES     : BmpNum = 78 : menu$ = "&Visual Designer"
'		CASE $$IDM_TBBDES     : BmpNum = 79 : menu$ = "Tool&bar Paint"
'		CASE $$IDM_POFFS      : BmpNum = 80 : menu$ = "&Poffs"
'		CASE $$IDM_PBWINSPY   : BmpNum = 81 : menu$ = "PBWin&Spy"
'		CASE $$IDM_INCLEAN    : BmpNum = 82 : menu$ = "Inc&Lean"
'		CASE $$IDM_COPYCAT    : BmpNum = 83 : menu$ = "Cop&yCat"
'		CASE $$IDM_MORETOOLS  : BmpNum = 124 : menu$ = "More Tools..." + $TAB + "F11"
		CASE $$IDM_CALCULATOR : BmpNum = 84 : menu$ = "Calc&ulator"

		' HELP MENU
		CASE $$IDM_HELPHEADER  : BmpNum = -1  : menu$ = "&Help"
		CASE $$IDM_HELP        : BmpNum = 85  : menu$ = "&Help" + $TAB + "F1"
		CASE $$IDM_ABOUT       : BmpNum = 86  : menu$ = "&About XSED"
		CASE $$IDM_XBLSITE     : BmpNum = 113 : menu$ = "&XBLite Home Page"
		CASE $$IDM_GOOGLE      : BmpNum = 115 : menu$ = "&Google"
		CASE $$IDM_XBLHTMLHELP : BmpNum = 87  : menu$ = "XBLite HTML Help"
		CASE $$IDM_XSEDHTMLHELP : BmpNum = 87 : menu$ = "XSED HTML Help"
		CASE $$IDM_GOASMHELP	 : BmpNum = 87  : menu$ = "GoAsm HTML Help"
		CASE $$IDM_WIN32HELP   : BmpNum = 87  : menu$ = "Win32 Help"
		CASE $$IDM_RCHELP      : BmpNum = 87  : menu$ = "Resource Help"

		' CONSOLE WINDOW CONTEXT
		CASE $$IDM_CONSOLE_JUMP		  : BmpNum = 36 : menu$ = "Jump To Line Error"
		CASE $$IDM_CONSOLE_COPY		  : BmpNum = 18 : menu$ = "Copy Contents To Clipboard"
		CASE $$IDM_CONSOLE_COPYLINE	: BmpNum = 0  : menu$ = "Copy Selected Line To Clipboard"
		CASE $$IDM_CONSOLE_CLEAR	  : BmpNum = 26 : menu$ = "Clear Console Window"
		CASE $$IDM_CONSOLE_HIDE     : BmpNum = 63 : menu$ = "Hide Console Window"

		' TREEVIEW CONTEXT
		CASE $$IDM_TREE_UPDATE : BmpNum = 108 : menu$ = "Update Function Browser"
		CASE $$IDM_TREE_HIDE   : BmpNum = 63  : menu$ = "Hide Function Browser"
	END SELECT

	RETURN (&menu$)


SUB Initialize
	' get template menu item info
	init = $$TRUE
	templateCount = GetTemplates (@templateMenu$[], @templateFN$[])

	' get tool menu file names
	XstGetCommandLineArguments (@argc, @argv$[])
	file$ = argv$[0]
	XstGetPathComponents (file$, @path$, @drive$, @dir$, @filename$, @attributes)
	path$ = path$ + "tools"
	XstFindFiles (path$, "*.*", 0, @tools$[])

	' filter out any *.gid and *.ini files
	IFZ tools$[] THEN EXIT SUB
	upp = UBOUND (tools$[])
	count = -1
	FOR i = 0 TO upp
		GetFileExtension (tools$[i], @file$, @ext$)
		SELECT CASE LCASE$(ext$)
			CASE "gid", "ini" :
			CASE ELSE  : INC count : tools$[count] = tools$[i]
		END SELECT
	NEXT i
	REDIM tools$[count]
END SUB

END FUNCTION
'
' ###########################################
' #####  SED_CreateAcceleratorTable ()  #####
' ###########################################
'
' Creates a table of keyboard accelerators
'
FUNCTION SED_CreateAcceleratorTable ()

	' ACCELAPI ac[]
	ACCEL ac[]
	DIM ac[69]

	' // Alt+X - Quit the application
	ac[0].fVirt = $$FVIRTKEY OR $$FALT
	ac[0].key = ASC ("X")
	ac[0].cmd = $$IDM_EXIT

	' // Ctrl+O - Open
	ac[1].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[1].key = ASC ("O")
	ac[1].cmd = $$IDM_OPEN

	' // Ctrl+N - New
	ac[2].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[2].key = ASC ("N")
	ac[2].cmd = $$IDM_NEW

	' // Ctrl+S - Save As...
	ac[3].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[3].key = ASC ("S")
	ac[3].cmd = $$IDM_SAVE

	' // Ctr+F4
	ac[4].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[4].key = $$VK_F4
	ac[4].cmd = $$IDM_CLOSEFILE

	' // Alt+F4
	ac[5].fVirt = $$FVIRTKEY OR $$FALT
	ac[5].key = $$VK_F4
	ac[5].cmd = $$IDM_EXIT

	' // F3
	ac[6].fVirt = $$FVIRTKEY
	ac[6].key = $$VK_F3
	ac[6].cmd = $$IDM_FINDNEXT

	' // F8
	ac[7].fVirt = $$FVIRTKEY
	ac[7].key = $$VK_F8
	ac[7].cmd = $$IDM_TOGGLE

	' // Ctrl+F8
	ac[8].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[8].key = $$VK_F8
	ac[8].cmd = $$IDM_TOGGLEALL

	' // Alt+F8
	ac[9].fVirt = $$FVIRTKEY OR $$FALT
	ac[9].key = $$VK_F8
	ac[9].cmd = $$IDM_FOLDALL

	' // Shift+F8
	ac[10].fVirt = $$FVIRTKEY OR $$FSHIFT
	ac[10].key = $$VK_F8
	ac[10].cmd = $$IDM_EXPANDALL

	' // Ctrl+F - Find
	ac[11].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[11].key = ASC ("F")
	ac[11].cmd = $$IDM_FIND

	' // Ctrl+F - Find and replace
	ac[12].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[12].key = ASC ("R")
	ac[12].cmd = $$IDM_REPLACE

	' // Ctrl+W - Switch windows
	ac[13].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[13].key = ASC ("W")
	ac[13].cmd = $$IDM_SWITCHWINDOW

	' // Ctrl+F5 - Zoom in
	ac[14].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[14].key = $$VK_F5
	ac[14].cmd = $$IDM_ZOOMIN

	' // Ctrl+Shift+F5 - Zoom out
	ac[15].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[15].key = $$VK_F5
	ac[15].cmd = $$IDM_ZOOMOUT

	' // Ctrl+G - Go to line...
	ac[16].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[16].key = ASC ("G")
	ac[16].cmd = $$IDM_GOTOLINE

	' // Ctrl+Q - Block comment
	ac[17].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[17].key = ASC ("Q")
	ac[17].cmd = $$IDM_COMMENT

	' // Ctrl+Shift+Q - Block uncomment
	ac[18].fVirt = $$FVIRTKEY OR $$FSHIFT OR $$FCONTROL
	ac[18].key = ASC ("Q")
	ac[18].cmd = $$IDM_UNCOMMENT

	' // Ctrl+F2 - Togle bookmark
	ac[19].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[19].key = $$VK_F2
	ac[19].cmd = $$IDM_TOGGLEBOOKMARK

	' // F2 - Next bookmark
	ac[20].fVirt = $$FVIRTKEY
	ac[20].key = $$VK_F2
	ac[20].cmd = $$IDM_NEXTBOOKMARK

	' // Shift+F2 - Previous bookmark
	ac[21].fVirt = $$FVIRTKEY OR $$FSHIFT
	ac[21].key = $$VK_F2
	ac[21].cmd = $$IDM_PREVIOUSBOOKMARK

	' // Ctrl+Shift+F2 - Delete bookmarks
	ac[22].fVirt = $$FVIRTKEY OR $$FSHIFT OR $$FCONTROL
	ac[22].key = $$VK_F2
	ac[22].cmd = $$IDM_DELETEBOOKMARKS

	' // Ctrl+Shift+U - Update Treeview Browser
	ac[23].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[23].key = ASC ("U")
	ac[23].cmd = $$IDM_TREE_UPDATE

	' // Ctrl+Shift+L - Show/hide line numbers
	ac[24].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[24].key = ASC ("L")
	ac[24].cmd = $$IDM_SHOWLINENUM

	' // Ctrl+Shift+M - Show/hide margin
	ac[25].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[25].key = ASC ("M")
	ac[25].cmd = $$IDM_SHOWMARGIN

	' // Ctrl+Shift+I - Show/hide indentation lines
	ac[26].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[26].key = ASC ("I")
	ac[26].cmd = $$IDM_SHOWINDENT

	' // Ctrl+Shift+W - Show/hide white spaces
	ac[27].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[27].key = ASC ("W")
	ac[27].cmd = $$IDM_SHOWSPACES

	' // Ctrl+Shift+D - Show/hide end of lines
	ac[28].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[28].key = ASC ("D")
	ac[28].cmd = $$IDM_SHOWEOL

	' // F1 - Help
	ac[29].fVirt = $$FVIRTKEY
	ac[29].key = $$VK_F1
	ac[29].cmd = $$IDM_HELP

	' // Ctrl+Shift+G - Show/hide edge
	ac[30].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[30].key = ASC ("G")
	ac[30].cmd = $$IDM_SHOWEDGE

	' // Ctrl+Shift+A - Auto indentation on/off
	ac[31].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[31].key = ASC ("A")
	ac[31].cmd = $$IDM_AUTOINDENT

	' // Ctrl+Shift+B - show treeview browser
	ac[32].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[32].key = ASC ("B")
	ac[32].cmd = $$IDM_SHOWTREEBROWSER

 	' // Ctrl+Alt+B - hide treeview browser
	ac[33].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FALT
	ac[33].key = ASC ("B")
	ac[33].cmd = $$IDM_HIDETREEBROWSER

	' // Ctrl+Y - Delete line
	ac[34].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[34].key = ASC ("Y")
	ac[34].cmd = $$IDM_LINEDELETE

	' // Ctrl+Shift+Z - Redo
	ac[35].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[35].key = ASC ("Z")
	ac[35].cmd = $$IDM_REDO

	' // F9 - Compile
	ac[36].fVirt = $$FVIRTKEY
	ac[36].key = $$VK_F9
	ac[36].cmd = $$IDM_COMPILE

	' // F10 - Build
	ac[37].fVirt = $$FVIRTKEY
	ac[37].key = $$VK_F10
	ac[37].cmd = $$IDM_BUILD

	' // Ctrl+Enter - Autocomplete - Use Ctrl+SpaceBar
	ac[38].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[38].key = $$VK_RETURN
	ac[38].cmd = $$IDM_AUTOCOMPLETE

	' // Ctrl+Shift+H - Hide console ouput window
	ac[39].fVirt = $$FVIRTKEY OR $$FSHIFT OR $$FCONTROL
	ac[39].key = ASC ("H")
	ac[39].cmd = $$IDM_HIDECONSOLE

	' not used yet
	' // Ctrl+Shift+F - FileFind
	ac[40].fVirt = $$FVIRTKEY OR $$FSHIFT OR $$FCONTROL
	ac[40].key = ASC ("F")
	ac[40].cmd = 0		'$$IDM_FILEFIND

	' // Ctrl+U - Convert selected text to upper case
	ac[41].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[41].key = ASC ("U")
	ac[41].cmd = $$IDM_SELTOUPPERCASE

	' // Ctrl+L - Convert selected text to lower case
	ac[42].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[42].key = ASC ("L")
	ac[42].cmd = $$IDM_SELTOLOWERCASE

	' *** Remove this one
	' // Ctrl+M - Converto selected text to mixed case
	ac[43].fVirt = 0 '$$FVIRTKEY OR $$FCONTROL
	ac[43].key = 0 'ASC ("M")
	ac[43].cmd = 0		'$$IDM_SELTOMIXEDCASE

	' // Ctrl+P - Print
	ac[44].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[44].key = ASC ("P")
	ac[44].cmd = $$IDM_PRINT

	' // Ctrl+P - Print preview
	ac[45].fVirt = 0 '$$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[45].key = 0 'ASC ("P")
	ac[45].cmd = 0 '$$IDM_PRINTPREVIEW

	' // F7 - Command Prompt
	ac[46].fVirt = $$FVIRTKEY
	ac[46].key = $$VK_F7
	ac[46].cmd = $$IDM_DOS

	' // Shift+F9 - Compile as Library
	ac[47].fVirt = $$FVIRTKEY OR $$FSHIFT
	ac[47].key =  $$VK_F9
	ac[47].cmd = $$IDM_COMPILE_LIB

	' ***** not used
	' // F6 - Compile and debug
	ac[48].fVirt = 0 '$$FVIRTKEY
	ac[48].key = 0 '$$VK_F6
	ac[48].cmd = 0		'$$IDM_COMPILEANDDEBUG

	' // Ctrl+B - Formats selected text
	ac[49].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[49].key = ASC ("B")
	ac[49].cmd = $$IDM_FORMATREGION

	' *** eliminate this one
	' ' // Ctrl+Shift+B - Formats selected text
	ac[50].fVirt = 0 '$$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[50].key = 0 'ASC ("B")
	ac[50].cmd = 0		'$$IDM_TABULATEREGION

	' // Ctrl+Shift+E - Launches Explorer
	ac[51].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[51].key = ASC ("O")
	ac[51].cmd = $$IDM_EXPLORER

	' // Ctrl+Shift+K - Charmap
	ac[52].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[52].key = ASC ("K")
	ac[52].cmd = $$IDM_CHARMAP

	' // Ctrl+Shift+N - Display function name
	ac[53].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[53].key = ASC ("N")
	ac[53].cmd = $$IDM_SHOWPROCNAME

	' not used - remove
	' // Ctrl+Shift+R - Restore project window
	ac[54].fVirt = 0 '$$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[54].key = 0 'ASC ("R")
	ac[54].cmd = 0		'$$IDM_RESTOREPROJECTWINDOW

	' // Ctrl+Shift+Up arrow - Goto to the beginning of the procedure or function
	ac[55].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[55].key = $$VK_UP
	ac[55].cmd = $$IDM_GOTOBEGINPROC

	' // Ctrl+Shift+Down arrow - Goto to the end of the procedure or function
	ac[56].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[56].key = $$VK_DOWN
	ac[56].cmd = $$IDM_GOTOENDPROC

	' // Ctrl+Alt+Up arrow - Goto to the beginning of the procedure or function
	ac[57].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FALT
	ac[57].key = $$VK_UP
	ac[57].cmd = $$IDM_GOTOBEGINTHISPROC

	' // Ctrl+Alt+Down arrow - Goto to the end of the procedure or function
	ac[58].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FALT
	ac[58].key = $$VK_DOWN
	ac[58].cmd = $$IDM_GOTOENDTHISPROC

	' // Ctrl+Shift+S - Show Console Window
	ac[59].fVirt = $$FVIRTKEY OR $$FCONTROL OR $$FSHIFT
	ac[59].key = ASC ("S")
	ac[59].cmd = $$IDM_SHOWCONSOLE

	' // Ctrl+Spacebar - Autocomplete (same as Ctrl+Enter)
	ac[60].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[60].key = $$VK_SPACE
	ac[60].cmd = $$IDM_AUTOCOMPLETE

	' // Ctrl+M - Message box builder
	ac[61].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[61].key = ASC ("M")
	ac[61].cmd = $$IDM_MSGBOXBUILDER

	' // Ctrl+Alt+F - Windows Find
	ac[62].fVirt = $$FVIRTKEY OR $$FALT OR $$FCONTROL
	ac[62].key = ASC ("F")
	ac[62].cmd = $$IDM_WINDOWSFIND

	' // Alt+Shift+F - Find in Files
	ac[63].fVirt = $$FVIRTKEY OR $$FALT OR $$FSHIFT
	ac[63].key = ASC ("F")
	ac[63].cmd = $$IDM_FINDINFILES

  ' not used, remove
	' // F11 - More tools
	ac[64].fVirt = 0 '$$FVIRTKEY
	ac[64].key = 0 '$$VK_F11
	ac[64].cmd = 0 '$$IDM_MORETOOLS

	' // F11 - Execute without compiling
	ac[65].fVirt = $$FVIRTKEY
	ac[65].key = $$VK_F11
	ac[65].cmd = $$IDM_EXECUTE

	' // Shift+F3 - Search backwards
	ac[66].fVirt = $$FVIRTKEY OR $$FSHIFT
	ac[66].key = $$VK_F3
	ac[66].cmd = $$IDM_FINDBACKWARDS

	' not used - delete it
	' // Alt+F7 - Goto or load the file with has the same name as the one under the caret
	ac[67].fVirt = 0 '$$FVIRTKEY OR $$FALT
	ac[67].key = 0 '$$VK_F7
	ac[67].cmd = 0		'$$IDM_GOTOSELFILE

	' // Ctrl+F7 - Search the function/sub that has the same name as the word under the caret
	ac[68].fVirt = $$FVIRTKEY OR $$FCONTROL
	ac[68].key = $$VK_F7
	ac[68].cmd = $$IDM_GOTOSELPROC

	' // Shift+F7 - Returns to the last saved position
	ac[69].fVirt = $$FVIRTKEY OR $$FSHIFT
	ac[69].key = $$VK_F7
	ac[69].cmd = $$IDM_GOTOLASTPOSITION

	RETURN CreateAcceleratorTableA (&ac[0], UBOUND (ac[]) + 1)

END FUNCTION
'
' ################################
' #####  CreateStatusbar ()  #####
' ################################
'
' Creates the status bar
'
FUNCTION CreateStatusbar (hWnd)

	' Create the status bar window
	hStatus = CreateStatusWindowA ($$WS_CHILD OR $$WS_BORDER OR $$WS_VISIBLE OR $$SBARS_SIZEGRIP, NULL, hWnd, 200)
	StatusBar_SetPartsBySize (hStatus, "90, 80, 200, 60, -1")
	' Show the date
	szFmt$ = "dd MMM yyyy"
	szDate$ = NULL$ (255)
	GetDateFormatA ($$LOCALE_USER_DEFAULT, 0, NULL, &szFmt$, &szDate$, LEN (szDate$))
	szDate$ = " " + CSIZE$ (szDate$)
	SendMessageA (hStatus, $$SB_SETTEXT, 0, &szDate$)
	RETURN hStatus

END FUNCTION
'
' #########################################
' #####  StatusBar_SetPartsBySize ()  #####
' #########################################
'
' DESC: Sets n parts of an existing status bar
' SYNTAX: StatusBar_SetPartsBySize(hStatus,sSizes)
' Parameters:
' hStatus   - The handle of the Status Bar control.
' sSizes    - Comma delited string of desired sizes
' e.g.:  sSizes = "90,34,42,184"  'in pixels
' creates 4 parts of 90, 34, 42 and 184 pixels
' e.g.:  sSizes = "90,34,42,184,-1"
' creates 5 parts, the last one extending until the
' right edge of the window.
' Return Values:
' If the operation succeeds, the return value is TRUE.
' If the operation fails, the return value is FALSE.
'
FUNCTION StatusBar_SetPartsBySize (hStatus, sSizes$)

	IFZ sSizes$ THEN RETURN
	IFZ hStatus THEN RETURN

	count = XstTally (sSizes$, ",")
	Parts = count + 1

	IF Parts < 2 THEN
		RETURN SendMessageA (hStatus, $$SB_SIMPLE, 1, 0)
	END IF

	DIM Part[Parts]

	' calculate each segment bounds
	FOR x = 1 TO Parts
		y = XLONG (XstNextItem$ (sSizes$, @index, @term, @done))
		' y = VAL(PARSE$(sSizes, ",", x))
		IF x = 1 THEN
			Part[x] = y
		ELSE
			IF y < 1 THEN
				Part[x] = -1
			ELSE
				Part[x] = Part[x - 1] + y
			END IF
		END IF
	NEXT

	IFZ SendMessageA (hStatus, $$SB_SETPARTS, Parts, &Part[1]) THEN
		RETURN SendMessageA (hStatus, $$SB_SIMPLE, 1, 0)
	END IF

END FUNCTION
'
' ################################
' #####  CreateTabMdiCtl ()  #####
' ################################
'
FUNCTION CreateTabMdiCtl (hWnd, RECT rc)

	SHARED hInst
	SHARED hTabImageList

'	hWndTab = CreateWindowExA ($$WS_EX_STATICEDGE, &"SysTabControl32", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$TCS_SINGLELINE OR $$TCS_RIGHTJUSTIFY OR $$TCS_TABS OR $$TCS_FOCUSNEVER OR $$TCS_TOOLTIPS OR $$TCS_BOTTOM, rc.left, rc.top, rc.right, rc.bottom, hWnd, $$IDC_TABMDI, hInst, NULL)
	hWndTab = CreateWindowExA ($$WS_EX_STATICEDGE, &"SysTabControl32", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$TCS_SINGLELINE OR $$TCS_RIGHTJUSTIFY OR $$TCS_TABS OR $$TCS_FOCUSNEVER OR $$TCS_TOOLTIPS, rc.left, rc.top, rc.right, rc.bottom, hWnd, $$IDC_TABMDI, hInst, NULL)
	IFZ hWndTab THEN RETURN

	hTabImageList = ImageList_Create (16, 16, $$ILC_MASK, 2, 1)
	hIcon = LoadIconA (hInst, 101)
	ImageList_AddIcon (hTabImageList, hIcon)
	DestroyIcon (hIcon)
	SendMessageA (hWndTab, $$TCM_SETIMAGELIST, 0, hTabImageList)

	RETURN hWndTab

END FUNCTION
'
' #####################################
' #####  CreateComboboxFinder ()  #####
' #####################################
'
' Creates a Combobox and embeds it in the Toolbar
' Returns the handle of the the combobox
'
FUNCTION CreateComboboxFinder (hWnd, hToolbar, hFont)

	SHARED hInst
	Style = $$WS_CHILD OR $$WS_VISIBLE OR $$CBS_DROPDOWNLIST OR $$CBS_SORT OR $$WS_VSCROLL OR $$WS_HSCROLL OR $$CBS_NOINTEGRALHEIGHT
	hCodeFinder = CreateWindowExA (0, &"COMBOBOX", NULL, Style, 478, 2, 231, 300, hWnd, $$IDC_CODEFINDER, hInst, NULL)
	IF hFont THEN SendMessageA (hCodeFinder, $$WM_SETFONT, hFont, 0)
	SetParent (hCodeFinder, hToolbar)
	SendMessageA (hCodeFinder, $$CB_RESETCONTENT, 0, 0)
	txt$ = "(FUNCTION finder)"
	SendMessageA (hCodeFinder, $$CB_ADDSTRING, 0, &txt$)
	SendMessageA (hCodeFinder, $$CB_SETITEMDATA, 0, 1)
	SendMessageA (hCodeFinder, $$CB_SETCURSEL, 0, 0)
	RETURN hCodeFinder

END FUNCTION
'
' ###############################
' #####  GetRecentFiles ()  #####
' ###############################
'
' Read the list of recently opened files
' and update MRU file list in popmenu
'
FUNCTION GetRecentFiles ()

	MENUITEMINFO mii

	SHARED RecentFiles$[]
	SHARED hMenuFile
	SHARED hWndMain
	SHARED hMenuRecentFiles

	REDIM RecentFiles$[$$MAX_MRU-1]

	FOR i = 1 TO $$MAX_MRU		' clear recent files popmenu
		IFZ RemoveMenu (hMenuRecentFiles, $$IDM_RECENTSTART + i, $$MF_BYCOMMAND) THEN EXIT FOR
	NEXT i

	Bc = 1
	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_TYPE OR $$MIIM_ID OR $$MIIM_SUBMENU
	mii.fType = $$MFT_STRING

	FOR i = 1 TO $$MAX_MRU
		file$ = GetRecentFileName (i)
		IF file$ THEN
'			IF FileExist (file$) THEN
				RecentFiles$[Bc - 1] = file$
				file$ = "&" + STRING$ (Bc) + " " + file$
				mii.wID = $$IDM_RECENTSTART + Bc
				mii.dwTypeData = &file$
				mii.cch = LEN (file$)
				ret = InsertMenuItemA (hMenuRecentFiles, $$IDM_DOS, $$FALSE, &mii)
				ret = ModifyMenuA (hMenuRecentFiles, $$IDM_RECENTSTART + Bc, $$MF_OWNERDRAW, $$IDM_RECENTSTART + Bc, NULL)
				fInserted = $$TRUE
				INC Bc
'			END IF
		END IF
	NEXT

END FUNCTION
'
' ##################################
' #####  GetRecentFileName ()  #####
' ##################################
'
' Retrieve the name of the recent file
'
FUNCTION STRING GetRecentFileName (idx)

	SHARED IniFile$

	IF (idx < 1) || (idx > $$MAX_MRU) THEN RETURN ""

	szSection$ = "Reopen files"
	szKey$     = "File " + STRING$ (idx)
	file$      = NULL$ (300)
	ret = GetPrivateProfileStringA (&szSection$, &szKey$, &szDefault$, &file$, LEN (file$), &IniFile$)
	IF ret THEN
    filePath$ = TRIM$(CSIZE$ (file$))
    file$ = XstParse$ (filePath$, "|", 1)
    IF file$ THEN RETURN file$
    RETURN filePath$
	ELSE
		RETURN ""
	END IF

END FUNCTION
'
' #######################
' #####  OnSize ()  #####
' #######################
'
' Processes the WM_SIZE message
'
FUNCTION OnSize (hWnd, wMsg, wParam, lParam)

	RECT rc, spRect
	SHARED hToolbar
	SHARED hStatusbar
	SHARED ghTabMdi
	SHARED hWndClient
	SHARED hWndConsole
	SHARED hSplitter
	SHARED hWndMain
	SHARED hSearchText1, hSearchText2, hSearchText3, hSearchText4, hSearchText5, hSearchText0
	SHARED hSearchEdit1, hSearchEdit2, hSearchEdit3
	SHARED hSearchButton1, hSearchButton2, hSearchButton3, hSearchButton4, hSearchButton5
	SHARED fShowSearchControls
	SHARED fShowTreeBrowser
	SHARED hTreeBrowser

'	fShowTreeBrowser = $$TRUE

	TabHeight = 34
	IF fShowTreeBrowser THEN treeWidth = 200

	' Get the size of the toolbar and status bar
	GetWindowRect (hToolbar, &rc)
	ToolHeight = rc.bottom - rc.top
	GetWindowRect (hStatusbar, &rc)
	StatHeight = rc.bottom - rc.top

	' get size of the splitter control
	GetWindowRect (hSplitter, &spRect)
	spHeight = spRect.bottom - spRect.top - 8

	' get current position of splitter bar
	ySplitPos = SendMessageA (hSplitter, $$WM_GET_SPLITTER_POSITION, 0, 0)

	' If the window isn't minimized, resize it
	IF wParam <> $$SIZE_MINIMIZED THEN
		SendMessageA (hStatusbar, wMsg, wParam, lParam)
		SendMessageA (hToolbar, wMsg, wParam, lParam)
		' Retrieve the coordinates of the window's client area after
		' resizing the statusbar and the toolbar
		GetClientRect (hWnd, &rc)
		x = rc.left
		h = TabHeight - 8
		w = rc.right + 2
		y = ToolHeight + h
		MoveWindow (ghTabMdi, x, ToolHeight, w, h, 1)
		newSplitHeight = rc.bottom - (ToolHeight + StatHeight) - TabHeight + 10

		IF fShowSearchControls THEN
			searchHeight = 110
			searchWidth = rc.right + 2
			newSplitHeight = newSplitHeight - searchHeight
			top = rc.bottom - StatHeight - searchHeight

			MoveWindow (hSearchText0, 0, top, searchWidth-2, 2, 1)						' horizontal line
			MoveWindow (hSearchText5, 0, top+4, 150, 20, 1)										' bar text "Find in Files"
			MoveWindow (hSearchButton3, searchWidth-20, top + 6, 15, 15, 1)	  ' close button
			MoveWindow (hSearchText1, 0, top+24, searchWidth-2, 2, 1)						' horizontal line

			MoveWindow (hSearchText2, 20, top + 30, 150, 16, 1)
			MoveWindow (hSearchText3, 310, top + 30, 150, 16, 1)
			MoveWindow (hSearchText4, 480, top + 30, 150, 16, 1)

			MoveWindow (hSearchEdit1, 20, top + 46, 200, 22, 1)			' start folder edit
			MoveWindow (hSearchButton2, 226, top + 46, 70, 22, 1)		' browse button
			MoveWindow (hSearchEdit2, 310, top + 46, 160, 22, 1)		' text to search edit
			MoveWindow (hSearchEdit3, 480, top + 46, 150, 22, 1)		' file filters edit
			MoveWindow (hSearchButton1, 550, top + 76, 80, 22, 1)		' search now button

			MoveWindow (hSearchButton4, 20, top + 76, 100, 18, 1)		' scan subfolders checkbox
			MoveWindow (hSearchButton5, 130, top + 76, 180, 18, 1)	' search whole words checkbox

		END IF

		' move splitter control
		MoveWindow (hSplitter, x, y, rc.right-treeWidth, newSplitHeight-2, 1)
		' move treeview control
		MoveWindow (hTreeBrowser, w - treeWidth, y, treeWidth-2, newSplitHeight-2, 1)

		' set splitter bar to new proportional position
		IF spHeight THEN
			IF fShowSearchControls THEN
				SendMessageA (hSplitter, $$WM_SET_SPLITTER_POSITION, 0, newSplitHeight - $$INITIAL_CONSOLE_HEIGHT)
			ELSE
				newSplitPos = ySplitPos * newSplitHeight / DOUBLE(spHeight)
				SendMessageA (hSplitter, $$WM_SET_SPLITTER_POSITION, 0, newSplitPos)
			END IF
		END IF
	END IF

END FUNCTION
'
' #########################
' #####  OnNotify ()  #####
' #########################
'
' Processes the notify messages of the main window
'
FUNCTION OnNotify (hWnd, wParam, lParam)

	TOOLTIPTEXT ttt
	RECT rc		            ' Window coordinates
	POINT pt
	TC_HITTESTINFO pInfo
	TC_ITEM ttc_item		  ' TC_ITEM structure
	TPMPARAMS tpmp
	NM_TREEVIEW nmtv
	TV_HITTESTINFO tvhti

	SHARED NewComCtl
	SHARED ghTabMdi
	SHARED RecentFiles$[]
	SHARED hTreeBrowser
	SHARED fShowTreeBrowser
	SHARED hCodeFinder

	' Retrieves the coordinates of the window's client area
	GetClientRect (hWnd, &rc)
	GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

	' handle notify messages from treeview function browser
	IF hwndFrom = hTreeBrowser THEN
		SELECT CASE code :
'			CASE $$NM_DBLCLK : ' MessageBoxA (hWnd, &"Doubleclick selection", &"TreeView Test", 0)
'			CASE $$NM_RETURN : ' MessageBoxA (hWnd, &"Return key pressed", &"TreeView Test", 0)
			CASE $$NM_RCLICK :
				'PRINT "Tree RCLICK"
				' do a hittest to determine which item was clicked
				pos = GetMessagePos ()
				pt.x = LOWORD (pos)
				pt.y = HIWORD (pos)
				ScreenToClient (hwndFrom, &pt)
				tvhti.pt = pt
				hItem = SendMessageA (hwndFrom, $$TVM_HITTEST, 0, &tvhti)
				IF hItem THEN
					IF tvhti.flags & $$TVHT_ONITEM THEN
						' set position in editor
'						SendMessageA (hwndFrom, $$TVM_SELECTITEM, $$TVGN_CARET, hItem)
'						GetTreeViewItemData (hTreeBrowser, hItem, @line)
'						IFZ line THEN RETURN
'						' End position = length of the document
'						endPos = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
'						' Set to end position of document
'						SendMessageA (GetEdit (), $$SCI_GOTOLINE, endPos, 0)
'						' Set function or procedure to top of editor
'						SendMessageA (GetEdit (), $$SCI_GOTOLINE, line, 0)

						' create context pop menu
						hPopupMenu = CreatePopupMenu ()
						AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_TREE_HIDE, GetMenuTextAndBitmap ($$IDM_TREE_HIDE, 0))
						AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_TREE_UPDATE, GetMenuTextAndBitmap ($$IDM_TREE_UPDATE, 0))
						' AppendMenu hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, "")
						ModifyMenuA (hPopupMenu, $$IDM_TREE_HIDE, $$MF_OWNERDRAW, $$IDM_TREE_HIDE, NULL)
						ModifyMenuA (hPopupMenu, $$IDM_TREE_UPDATE, $$MF_OWNERDRAW, $$IDM_TREE_UPDATE, NULL)

						GetCursorPos (&pt)
						TrackPopupMenu (hPopupMenu, 0, pt.x, pt.y, 0, hWnd, 0)
						DestroyMenu (hPopupMenu)
						UpdateWindow (GetEdit ())

					END IF
				END IF
				
'			CASE $$TVN_SELCHANGING :
'				IF fShowTreeBrowser THEN SED_CodeFinder (0)

			CASE $$TVN_SELCHANGED :
				RtlMoveMemory (&nmtv, lParam, SIZE (nmtv))
				action = nmtv.action
				' only set position in current editor if action in treeview is by user (mouse or keyboard)
				SELECT CASE action
					CASE $$TVC_BYKEYBOARD, $$TVC_BYMOUSE : ' PRINT "kb, mouse"
						hItem = GetTreeViewSelection (hTreeBrowser)
						GetTreeViewItemText (hTreeBrowser, hItem, @text$)
						index = SendMessageA (hCodeFinder, $$CB_FINDSTRINGEXACT, -1, &text$) 
						' get line data stored in listview
						line = SendMessageA (hCodeFinder, $$CB_GETITEMDATA, index, 0)
						IFZ line THEN RETURN
						' End position = length of the document
						endPos = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
						' Set to end position of document
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, endPos, 0)
						' Set function or procedure to top of editor
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, line, 0)
					CASE $$TVC_UNKNOWN : ' PRINT "unknown"
				END SELECT
				RETURN
		END SELECT
	END IF

	' Toolbar notification messages
	IF code = $$TTN_NEEDTEXT THEN
		RtlMoveMemory (&ttt, lParam, SIZE (ttt))
		szText$ = ""
		' Toolbar tooltips
		SELECT CASE idFrom
			CASE $$IDM_NEW           : szText$ = " New File "
			CASE $$IDM_OPEN          : szText$ = " Open File "
			CASE $$IDM_SAVE          : szText$ = " Save File "
			CASE $$IDM_SAVEAS        : szText$ = " Save File As..."
			CASE $$IDM_REFRESH       : szText$ = " Refresh File "
			CASE $$IDM_CLOSEFILE     : szText$ = " Close File "
			CASE $$IDM_CUT           : szText$ = " Cut "
			CASE $$IDM_COPY          : szText$ = " Copy "
			CASE $$IDM_PASTE         : szText$ = " Paste "
			CASE $$IDM_UNDO          : szText$ = " Undo "
			CASE $$IDM_REDO          : szText$ = " Redo "
			CASE $$IDM_FIND          : szText$ = " Find "
			CASE $$IDM_REPLACE       : szText$ = " Replace "
			CASE $$IDM_COMPILE       : szText$ = " Compile "
			CASE $$IDM_BUILD         : szText$ = " Build "
			CASE $$IDM_EXECUTE       : szText$ = " Execute Without Compiling "
'			CASE $$IDM_PRINTPREVIEW  : szText$ = " Print Preview "
			CASE $$IDT_PRINT         : szText$ = " Print File "
			CASE $$IDM_MAIL          : szText$ = " Email Us "
			CASE $$IDM_XBLHTMLHELP   : szText$ = " XBLite Html Help "
		END SELECT

		IF szText$ THEN
			ttt.lpszText = &szText$
			RtlMoveMemory (lParam, &ttt, SIZE (ttt))
			RETURN
		END IF

		' Tab tooltip
		GetCursorPos (&pInfo.pt)
		ScreenToClient (ghTabMdi, &pInfo.pt)
		' TabIdx = TabCtrl_HitTest (ghTabMdi, &pInfo)
		TabIdx = SendMessageA (ghTabMdi, $$TCM_HITTEST, 0, &pInfo)
		IF TabIdx >= 0 THEN
			szText$ = GetTabName (TabIdx)
			szCaption$ = GetMdiWindowTextFromTabCaption (szText$)
			IF szCaption$ THEN
				ttt.lpszText = &szCaption$
				RtlMoveMemory (lParam, &ttt, SIZE (ttt))
				RETURN
			END IF
		END IF

	ELSE

		IF NewComCtl && (code = $$TBN_DROPDOWN) THEN
			SELECT CASE idFrom
				' Dropdown recent files menu
				CASE $$ID_TOOLBAR :
					SendMessageA (hwndFrom, $$TB_GETITEMRECT, 1, &rc)
					MapWindowPoints (hwndFrom, $$HWND_DESKTOP, &rc, 2)
					GetRecentFiles ()		' Get the recent files names
					hPopupMenu = CreatePopupMenu ()
					FOR i = 0 TO UBOUND (RecentFiles$[])
						IF RecentFiles$[i] THEN
							text$ = "&" + STRING$ (i) + " " + RecentFiles$[i]
							AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_RECENTSTART + i + 1, &text$)
							ModifyMenuA (hPopupMenu, $$IDM_RECENTSTART + i + 1, $$MF_OWNERDRAW, $$IDM_RECENTSTART + i + 1, NULL)
						END IF
					NEXT
					TrackPopupMenu (hPopupMenu, 0, rc.left, rc.bottom, 0, hWnd, NULL)
					DestroyMenu (hPopupMenu)
					RETURN
			END SELECT
		END IF
	END IF

	' Tab notifications

	IF code = $$NM_RCLICK THEN
		GetCursorPos (&pInfo.pt)
		ScreenToClient (ghTabMdi, &pInfo.pt)
		TabIdx = SendMessageA (ghTabMdi, $$TCM_HITTEST, 0, &pInfo)
		IF TabIdx >= 0 THEN
		  ' set focus to selected tab
		  SendMessageA (ghTabMdi, $$TCM_SETCURFOCUS, TabIdx, 0)
      ' map tab control for popupmenu
		  SendMessageA (hwndFrom, $$TCM_GETITEMRECT, TabIdx, &rc)
		  MapWindowPoints (hwndFrom, $$HWND_DESKTOP, &rc, 2)
		' create a popupmenu for tab
		  hPopupMenu = CreatePopupMenu ()
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_NEW, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_NEW, $$MF_OWNERDRAW, $$IDM_NEW, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_OPEN, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_OPEN, $$MF_OWNERDRAW, $$IDM_OPEN, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_SAVE, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_SAVE, $$MF_OWNERDRAW, $$IDM_SAVE, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_SAVEAS, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_SAVEAS, $$MF_OWNERDRAW, $$IDM_SAVEAS, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CLOSEFILE, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_CLOSEFILE, $$MF_OWNERDRAW, $$IDM_CLOSEFILE, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CLOSEALL, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_CLOSEALL, $$MF_OWNERDRAW, $$IDM_CLOSEALL, NULL)
      AppendMenuA (hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_COMPILE, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_COMPILE, $$MF_OWNERDRAW, $$IDM_COMPILE, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_BUILD, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_BUILD, $$MF_OWNERDRAW, $$IDM_BUILD, NULL)
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_EXECUTE, 0)
		  ModifyMenuA (hPopupMenu, $$IDM_EXECUTE, $$MF_OWNERDRAW, $$IDM_EXECUTE, NULL)

      tpmp.cbSize = SIZE(tpmp)
      tpmp.rcExclude = rc
      TrackPopupMenuEx (hPopupMenu, 0, rc.left, rc.bottom, hWnd, &tpmp)
		  DestroyMenu (hPopupMenu)
		END IF
		RETURN
	END IF

	SELECT CASE TRUE
		CASE code >= $$TCN_LAST && code <= $$TCN_FIRST :		' Tab control notifications
			SELECT CASE idFrom
				CASE $$IDC_TABMDI
					SELECT CASE code
						CASE $$TCN_SELCHANGE		' identify which tab
							ret = SendMessageA (ghTabMdi, $$TCM_GETCURSEL, 0, 0)
							sTabTxt$ = NULL$ (255)
							ttc_item.mask = $$TCIF_TEXT
							ttc_item.pszText = &sTabTxt$
							ttc_item.cchTextMax = LEN (sTabTxt$)
							SendMessageA (ghTabMdi, $$TCM_GETITEM, ret, &ttc_item)
							' get and activate associated Document view
							sTabTxt$ = CSIZE$ (sTabTxt$)
							hMdi = EnumTabToMdiHandle (sTabTxt$)
							' reset code finder
							SED_CodeFinder ($$TRUE)
					END SELECT
			END SELECT
	END SELECT

END FUNCTION
'
' ###########################
' #####  GetTabName ()  #####
' ###########################
'
' Gets the name of the tab
'
FUNCTION STRING GetTabName (nTab)

	TC_ITEM ttc_item
	SHARED ghTabMdi

	strTabName$ = NULL$ (255)
	ttc_item.mask = $$TCIF_TEXT
	ttc_item.pszText = &strTabName$
	ttc_item.cchTextMax = LEN (strTabName$)
	SendMessageA (ghTabMdi, $$TCM_GETITEM, nTab, &ttc_item)

	RETURN (TRIM$ (CSIZE$ (strTabName$)))

END FUNCTION
'
' ###############################################
' #####  GetMdiWindowTextFromTabCaption ()  #####
' ###############################################
'
' Using the Tab caption find the associated Mdi Child handle
'
FUNCTION STRING GetMdiWindowTextFromTabCaption (sTabCaption$)

	SHARED hWndClient

	zTab$ = sTabCaption$

	' get the first DocView handle
	hMdi = GetWindow (hWndClient, $$GW_CHILD)
	' cycle thru all the open DocView windows
	DO WHILE hMdi
		' get the DocView caption text
		szPath$ = GetWindowText$ (hMdi)
		XstGetPathComponents (szPath$, "", "", "", @zText$, 0)
		IF zText$ = zTab$ THEN RETURN szPath$
		hMdi = GetWindow (hMdi, $$GW_HWNDNEXT)
	LOOP

END FUNCTION
'
' ###################################
' #####  EnumTabToMdiHandle ()  #####
' ###################################
'
' Using the Tab caption find the associated
' Mdi Child handle and make that window the
' active document view.
'
FUNCTION EnumTabToMdiHandle (sTabCaption$)

	SHARED hWndClient

	zTab$ = sTabCaption$
	szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
	' get the first DocView handle
	hMdi = GetWindow (hWndClient, $$GW_CHILD)
	' cycle thru all the open DocView windows
	DO WHILE hMdi
		' get the DocView caption text
		zText$ = GetWindowText$ (hMdi)
		IF szPath$ <> zText$ THEN
			XstGetPathComponents (zText$, "", "", "", @zText$, 0)
			IF zText$ = zTab$ THEN
				' bring DocView to the front and make it the active window
				IF IsIconic (hMdi) THEN
					SendMessageA (hWndClient, $$WM_MDIRESTORE, hMdi, 0)
				ELSE
					SendMessageA (hWndClient, $$WM_MDIACTIVATE, hMdi, 0)
				END IF
				' return handle as success
				RETURN hMdi
			END IF
		END IF
		hMdi = GetWindow (hMdi, $$GW_HWNDNEXT)
	LOOP

END FUNCTION
'
' ################################
' #####  GetDroppedFiles ()  #####
' ################################
'
' GetDroppedFiles - Retrieves the paths of the dropped files
'
FUNCTION GetDroppedFiles (hfInfo, @DroppedFiles$[])

	DIM DroppedFiles$[]

	Count = DragQueryFileA (hfInfo, 0xFFFFFFFF&, NULL, 0)		' Get the number of dropped files

	IF Count THEN		' If we got something...
		DIM DroppedFiles$[Count - 1]
		FOR i = 0 TO Count - 1
			fName$ = NULL$ (255)
			ln = DragQueryFileA (hfInfo, i, &fName$, LEN (fName$))		' Retrieve the path and get his length
			IF ln THEN
				tmp$ = TRIM$ (LEFT$ (fName$, ln))
				IF tmp$ THEN
					XstGetFileAttributes (tmp$, @attr)
					IFZ attr AND $$FileDirectory THEN
						' (GETATTR(tmp) AND 16) = 0 THEN    ' Make sure it's a file, not a folder
						DroppedFiles$[i] = tmp$
					END IF
				END IF
			END IF
		NEXT
	END IF

	DragFinish (hfInfo)
	RETURN Count

END FUNCTION
'
' #################################
' #####  OnSysColorChange ()  #####
' #################################
'
' WM_SYSCOLORCHANGE - Message handler.
'
FUNCTION OnSysColorChange (hWnd, wParam, lParam)

	SHARED hToolbar
	SHARED hStatusbar

	IFZ hMenu THEN hMenu = GetMenu (hWnd)		' Menu font size may have changed,
	IF hMenu THEN DestroyMenu (hMenu)		' so destroy old menu and create a
	hMenu = SED_CreateMenu (hWnd)		' new to use new font's measurements
	' Forward this message to common controls so that they will
	' be properly updated if the user changes the color settings.
	SendMessageA (hToolbar, $$WM_SYSCOLORCHANGE, wParam, lParam)
	SendMessageA (hStatusbar, $$WM_SYSCOLORCHANGE, wParam, lParam)

END FUNCTION
'
' #########################
' #####  DrawMenu ()  #####
' #########################
'
' Description : Draw Owner Drawn Menu Items
' called from the WM_DRAWITEM message
'
FUNCTION DrawMenu (lParam)

	RECT rc
	SIZEAPI szl		' used to calculate text extent
	DRAWITEMSTRUCT dis

	SHARED hMenuHiBrush
	SHARED hImlDis, hImlNor, hImlHot
	SHARED SciColorsAndFontsType scf
	SHARED hMenuTextBkBrush

	$TAB = "\t"

	IFZ lParam THEN RETURN

	RtlMoveMemory (&dis, lParam, SIZE (dis))		' Get structure from given pointer
	menuBtnW = GetSystemMetrics ($$SM_CYMENU) - 1		' for "button" size

	' Calculate pos for eventual shortcut. We need to look at all items
	' in dropped menu and calculate largest width, which then is used
	' as base to calculate all shortcuts' pos.
	count = GetMenuItemCount (dis.hwndItem)		' hwndItem is dropped menu's handle
	upp = count - 1
	FOR c = 0 TO upp
		id = GetMenuItemID (dis.hwndItem, c)
		IF id THEN
			sCaption$ = CSTRING$ (GetMenuTextAndBitmap (id, 0))
			IF INSTR (sCaption$, $TAB) THEN		' if it has shortcut (Ctrl+X, etc.)
				sShortCut$ = TRIM$ (XstParse$ (sCaption$, $TAB, 2))
			ELSE
				sShortCut$ = ""
			END IF

			IF sShortCut$ THEN
				GetTextExtentPoint32A (dis.hDC, &sShortCut$, LEN (sShortCut$), &szl)
				ShortCutWidth = MAX (ShortCutWidth, szl.cx)
			END IF
		END IF
	NEXT c

	' Get menu item string and split up into ev. text and shortcut part.
	sCaption$ = CSTRING$ (GetMenuTextAndBitmap (dis.itemID, @BmpNum))

	IF INSTR (sCaption$, $TAB) THEN		' if it has shortcut (Ctrl+X, etc.)
		' sShortCut = TRIM$(PARSE$(sCaption, $TAB, 2))
		sShortCut$ = XstParse$ (sCaption$, $TAB, 2)
		sCaption$ = TRIM$ (XstParse$ (sCaption$, $TAB, 1))
	ELSE
		' sCaption = TRIM$(sCaption$)
		' sCaption = sCaption
		sShortCut$ = ""
	END IF

	' Calculate menu item string's height.
	ret = GetTextExtentPoint32A (dis.hDC, &sCaption$, LEN (sCaption$), &szl)

	' Set up colors depending on what drawing actions we need to take.
	SELECT CASE TRUE
		CASE (dis.itemState AND $$ODS_SELECTED) :		' menu item is selected
			nState = $$IMG_HOT
			hBrush = hMenuHiBrush
			SetBkColor (dis.hDC, GetSysColor ($$COLOR_HIGHLIGHT))
			SetTextColor (dis.hDC, GetSysColor ($$COLOR_HIGHLIGHTTEXT))
			bHighlight = $$TRUE		' flag, so later we can add or remove the 3D edge around the icon
			' Selected but grayed or disabled
			IF (dis.itemState AND $$ODS_GRAYED) THEN
				nState = $$IMG_DIS
				bGrayed = $$TRUE
			ELSE
				IF (dis.itemState AND $$ODS_DISABLED) THEN
					nState = $$IMG_DIS
					bDisabled = $$TRUE
				END IF
			END IF
		CASE (dis.itemState AND $$ODS_GRAYED) :		' menu item is grayed
			nState = $$IMG_DIS
			hBrush = GetSysColorBrush ($$COLOR_MENU)
			SetBkColor (dis.hDC, GetSysColor ($$COLOR_MENU))
			SetTextColor (dis.hDC, GetSysColor ($$COLOR_MENUTEXT))
			bGrayed = $$TRUE
		CASE (dis.itemState AND $$ODS_DISABLED) :		' menu item is disabled
			nState = $$IMG_DIS
			hBrush = GetSysColorBrush ($$COLOR_MENU)
			SetBkColor (dis.hDC, GetSysColor ($$COLOR_MENU))
			SetTextColor (dis.hDC, GetSysColor ($$COLOR_MENUTEXT))
			bDisabled = $$TRUE
		CASE ELSE :		' not selected or disabled
			nState = $$IMG_NOR
			hBrush = GetSysColorBrush ($$COLOR_MENU)
			SetBkColor (dis.hDC, GetSysColor ($$COLOR_MENU))
			SetTextColor (dis.hDC, GetSysColor ($$COLOR_MENUTEXT))
	END SELECT

	drawTxtFlags = $$DST_PREFIXTEXT
	drawBmpFlags = $$DST_BITMAP

	IF bGrayed || bDisabled THEN		' if grayed or disabled item
		IF (dis.itemState AND $$ODS_SELECTED) THEN		' if it's selected
			SetTextColor (dis.hDC, GetSysColor ($$COLOR_GRAYTEXT))
		ELSE
			drawTxtFlags = drawTxtFlags OR $$DSS_DISABLED
		END IF
	END IF

	' Calculate rect for highlight area (selected item) and fill rect with proper
	' color, either COLOR_MENU or COLOR_HIGHLIGHT, depending on selection state.

	rc = dis.rcItem

	IF bGrayed || bDisabled || (BmpNum = -1) THEN		' grayed or no bitmap
		rc.left = 0
	ELSE
		rc.left = menuBtnW + 4		' enabled, with bitmap
	END IF

	' For GRAYED With Bitmap.
	IF bGrayed || bDisabled THEN
		IF BmpNum >= 0 THEN
			rc.left = menuBtnW + 4
			hBrush = GetSysColorBrush ($$COLOR_MENU)
			drawTxtFlags = drawTxtFlags OR $$DSS_DISABLED
		END IF
	END IF

	ret = FillRect (dis.hDC, &rc, hBrush)

	IF dis.itemID = 0 || dis.itemID = $$IDM_RECENTSEPARATOR THEN		' Separator
		rc.left = menuBtnW + 4
		FillRect (dis.hDC, &rc, hMenuTextBkBrush)
		rc.left = rc.left + 4
		rc.top = rc.top + (rc.bottom - rc.top) \ 2.0
		DrawEdge (dis.hDC, &rc, $$EDGE_ETCHED, $$BF_TOP)
		RETURN		' nothing else to draw
	END IF

	' Draw the disabled bitmap.

	IF bGrayed || bDisabled THEN
		' Draw Disabled Bitmap.
		IF BmpNum >= 0 THEN hBmp = GetMenuBmpHandle (BmpNum, nState)
		IF nState = $$IMG_DIS THEN
			ImageList_DrawEx (hImlDis, BmpNum, dis.hDC, ((menuBtnW + 3) \ 2) - 8, ((dis.rcItem.top + dis.rcItem.bottom) \ 2) - 8, 16, 16, $$CLR_NONE, $$CLR_NONE, $$ILD_TRANSPARENT)
		END IF
	END IF

	' Draw the bitmap "button", if item is not grayed out (disabled).
	'
	' ImageList Draw Style Constants.
	' $$IMG_DIS = 0 : $$IMG_NOR = 1 : $$IMG_HOT = 2

	IF (dis.itemState AND $$ODS_CHECKED) THEN
		' Make adjustements for checked items
		BmpNum = $$OMENU_CHECKEDICON
		hBmp = GetMenuBmpHandle ($$OMENU_CHECKEDICON, nState)
		nState = $$IMG_NOR
	ELSE
		IF BmpNum >= 0 THEN hBmp = GetMenuBmpHandle (BmpNum, nState)
	END IF

	IF hBmp <> 0 THEN		' Draw bitmap, centered in "button"
		SELECT CASE nState
			CASE $$IMG_NOR : h = hImlNor
			CASE $$IMG_HOT : h = hImlHot
			CASE $$IMG_DIS : h = hImlDis
		END SELECT
		ret = ImageList_DrawEx (h, BmpNum, dis.hDC, ((menuBtnW + 3) \ 2) - 8, ((dis.rcItem.top + dis.rcItem.bottom) \ 2) - 8, 16, 16, $$CLR_NONE, $$CLR_NONE, $$ILD_TRANSPARENT)

		' Calculate the RECT we need for the 3D edge.
		rc = dis.rcItem
		rc.left = 0		' Size and pos for "button"..
		rc.right = menuBtnW + 4
		rc.bottom = rc.top + GetSystemMetrics ($$SM_CYMENU) + 1

		' Draw "button" flat
		DrawEdge (dis.hDC, &rc, $$BDR_RAISEDINNER, $$BF_FLAT OR $$BF_RECT)
	END IF

	DeleteObject (hBmp)		' Delete the bitmap when done, to avoid memory leaks!

	' Draw the menu text next to bitmap button, with centered y-pos.
	rc = dis.rcItem
	rc.left = menuBtnW + 4
	rc.right = dis.rcItem.right
	rc.top = rc.top + ((rc.bottom - rc.top) - szl.cy) \ 2
	' rc.top = rc.top - 3
	rc.top = rc.top - 4

	IF bHighlight THEN
		FillRect (dis.hDC, &rc, hMenuHiBrush)
		IF bGrayed || bDisabled THEN
			SetTextColor (dis.hDC, GetSysColor ($$COLOR_GRAYTEXT))
		ELSE
			SetTextColor (dis.hDC, scf.SubMenuHiTextForeColor)
		END IF
		' Draw frame using custom colored pen
		MoveToEx (dis.hDC, dis.rcItem.left, dis.rcItem.top, 0)
		LineTo (dis.hDC, dis.rcItem.right - 1, dis.rcItem.top)
		LineTo (dis.hDC, dis.rcItem.right - 1, dis.rcItem.bottom - 1)
		LineTo (dis.hDC, dis.rcItem.left, dis.rcItem.bottom - 1)
		LineTo (dis.hDC, dis.rcItem.left, dis.rcItem.top)
	ELSE
		IF bGrayed || bDisabled THEN
			FillRect (dis.hDC, &rc, hMenuTextBkBrush)
			SetTextColor (dis.hDC, GetSysColor ($$COLOR_GRAYTEXT))
		ELSE
			FillRect (dis.hDC, &rc, hMenuTextBkBrush)
			SetTextColor (dis.hDC, scf.SubMenuTextForeColor)
		END IF
	END IF

	SetBkMode (dis.hDC, $$TRANSPARENT)
	rc.top = rc.top + 3
	rc.left = menuBtnW + 8
	DrawStateA (dis.hDC, hMenuTextBkBrush, 0, &sCaption$, LEN (sCaption$), rc.left, rc.top, rc.right, szl.cy, drawTxtFlags)
	IF ShortCutWidth THEN		' if there's shortcut text (Ctrl+N, etc)
		DrawStateA (dis.hDC, 0, 0, &sShortCut$, LEN (sShortCut$), dis.rcItem.right - ShortCutWidth - 8, rc.top, rc.right, szl.cy, drawTxtFlags)
	END IF
END FUNCTION
'
' #################################
' #####  GetMenuBmpHandle ()  #####
' #################################
'
' Description : Get desired Menu Item's bitmap handle.
'
FUNCTION GetMenuBmpHandle (BmpNum, nState)

	SHARED hInst

	' Load the Bitmap Strips.

	SELECT CASE nState
		CASE $$IMG_DIS : bmp$ = "TBDIS"		' Disabled bitmap strip.
		CASE $$IMG_NOR : bmp$ = "TBNOR"		' Normal bitmap strip.
		CASE $$IMG_HOT : bmp$ = "TBHOT"		' Hot Selected bitmap strip.
	END SELECT

	hBmp1 = LoadImageA (hInst, &bmp$, $$IMAGE_BITMAP, 0, 0, $$LR_LOADTRANSPARENT OR $$LR_LOADMAP3DCOLORS OR $$LR_DEFAULTSIZE)

	' Create memory DC's and draw the bitmaps.
	hdc = GetDC (0)											' GET device context FOR screen
	memDC1 = CreateCompatibleDC (hdc)		' Create two memory device contexts
	memDC2 = CreateCompatibleDC (hdc)
	hBmp2 = CreateCompatibleBitmap (hdc, 16, 16)		' Create compatible 16x16 pixel bmp
	ReleaseDC (0, hdc)									' Release the DC - don't need it anymore.

	SelectObject (memDC1, hBmp1)				' Select the bitmaps into the mem dc's
	SelectObject (memDC2, hBmp2)

	BitBlt (memDC2, 0, 0, 16, 16, memDC1, BmpNum * 16, 0, $$SRCCOPY)		' copy bNum part of hBmp1 strip to hBmp2

	DeleteDC (memDC1)			' Cleanup memDC's and delete main bmp strip object
	DeleteDC (memDC2)
	DeleteObject (hBmp1)	' (note: 16x16 pixel hBmp2 is deleted in DrawMenu routine)

	RETURN hBmp2					' return handle to 16x16 pixel bitmap

END FUNCTION
'
' ############################
' #####  MeasureMenu ()  #####
' ############################
'
' Description : Called form the WM_MEASUREITEM message
'
FUNCTION MeasureMenu (hWnd, lParam)

	SIZEAPI sl
	MEASUREITEMSTRUCT mis
	NONCLIENTMETRICS ncm

	RtlMoveMemory (&mis, lParam, SIZE (mis))		' lParam points to MEASUREITEMSTRUCT
	txt$ = CSTRING$ (GetMenuTextAndBitmap (mis.itemID, 0))		' get menu item's text

	hDC = GetDC (hWnd)		' grab dialog's DC
	ncm.cbSize = SIZE (ncm)		' grab menu font
	SystemParametersInfoA ($$SPI_GETNONCLIENTMETRICS, SIZE (ncm), &ncm, 0)
	IF ncm.lfMenuFont THEN
		hf = CreateFontIndirectA (&ncm.lfMenuFont)		' create font from menu LogFont data
		IF hf THEN hf = SelectObject (hDC, hf)		' select it in DC
	END IF
	GetTextExtentPoint32A (hDC, &txt$, LEN (txt$), &sl)		' get text size
	' @lpMis.itemWidth  = sl.cx                          ' set width
	mis.itemWidth = sl.cx + $$OMENU_EXTRAWIDTH		' set width
	mis.itemHeight = GetSystemMetrics ($$SM_CYMENU) + 1		' set height
	IF hf THEN DeleteObject (SelectObject (hDC, hf))		' delete our tmp menu font object
	ReleaseDC (hWnd, hDC)		' release DC to avoid memory leak

	IF mis.itemID = 0 || mis.itemID = $$IDM_RECENTSEPARATOR THEN		' Separator
		mis.itemHeight = mis.itemHeight \ 2
	END IF

	RtlMoveMemory (lParam, &mis, SIZE (mis))

END FUNCTION
'
' ############################
' #####  DrawTabItem ()  #####
' ############################
'
' Draw the tab
'
FUNCTION DrawTabItem (lParam)

	DRAWITEMSTRUCT dis
	RECT lRect
	RECT rc
	TC_ITEM ttc_item

	SHARED ghTabMdi

	IFZ lParam THEN RETURN
	RtlMoveMemory (&dis, lParam, SIZE (dis))

	' Get tab item text string
	szText$ = NULL$ (255)
	ttc_item.mask = $$TCIF_TEXT
	ttc_item.pszText = &szText$
	ttc_item.cchTextMax = LEN (szText$)
	SendMessageA (ghTabMdi, $$TCM_GETITEM, dis.itemID, &ttc_item)
	szText$ = CSIZE$ (szText$)

	SendMessageA (ghTabMdi, $$TCM_GETITEMRECT, dis.itemID, &lRect)

	IF dis.itemState = $$ODS_SELECTED THEN
		rc = lRect
		rc.top = rc.top - 4
		' First fill the background of the tab...
		FillRect (dis.hDC, &rc, GetStockObject ($$LTGRAY_BRUSH))
		' Use a bold font if selected
		hFontTab = CreateFontA (- 8, 0, 0, 0, $$FW_BOLD, 0, 0, 0, 0, 0, 0, 0, 0, &"MS Sans Serif")
		nLeftmargin = 1
		nColor = RGB (0, 0, 128)
		SetBkColor (dis.hDC, RGB (204, 204, 204))		'$$LTGRAY
	ELSE
		' Or a normal one if not selected
		hFontTab = CreateFontA (- 8, 0, 0, 0, $$FW_NORMAL, 0, 0, 0, 0, 0, 0, 0, 0, &"MS Sans Serif")
		nLeftmargin = 4
		nColor = RGB (50, 50, 50)
	END IF

	hFontTab = SelectObject (dis.hDC, hFontTab)
	SetTextColor (dis.hDC, nColor)
	TextOutA (dis.hDC, lRect.left + nLeftMargin, lRect.top + 3, &szText$, LEN (szText$))
	DeleteObject (SelectObject (dis.hDC, hFontTab))

END FUNCTION
'
' #################################
' #####  CreateSciControl ()  #####
' #################################
'
' Creates an instance of the Scintilla Control Editor
' and loads the file if it is an open action.
' The caption of the window holds the path.

FUNCTION CreateSciControl (hWnd)

	SHARED hInst
	SHARED cUntitledBas		' Untitled bas file counter
	FoldingOptionsType FoldOpt
	SHARED fFoldingOn
	SHARED TrimTrailingBlanks

	$CRLF = "\r\n"

	hSci = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"Scintilla", NULL, $$WS_CHILD OR $$WS_CLIPCHILDREN OR $$WS_VISIBLE OR $$ES_MULTILINE OR $$WS_VSCROLL OR $$WS_HSCROLL OR $$ES_AUTOHSCROLL OR $$ES_AUTOVSCROLL OR $$ES_NOHIDESEL, 0, 0, 0, 0, hWnd, $$IDC_EDIT, hInst, NULL)

	' Retrieve the path of the file from the window's caption
	szText$ = GetWindowText$ (hWnd)
	IF szText$ THEN GetFileExtension (szText$, @file$, @strExt$)

	' p = RINSTR(szText$, ".")
	' IF p THEN strExt$ = UCASE$(MID$(szText$, p))
	' IF strExt$ = ".X" || strExt$ = ".XBL" || strExt$ = "DEC" || strExt$ = ".RC" THEN ValidExt = $$TRUE
	IF strExt$ THEN
		SELECT CASE UCASE$ (strExt$)
			CASE "X", "XL", "XBL", "DEC", "RC", "ASM", "S" : ValidExt = $$TRUE
		END SELECT
	END IF

	' Get a direct pointer for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	GetFoldingOptions (@FoldOpt)
	IF FoldOpt.FoldingLevel THEN fFoldingOn = $$TRUE

	IF szText$ THEN
		err = ERROR (0)
		nFile = OPEN (szText$, $$RD)
		IF ERROR (-1) THEN
			err = ERROR (0)
			err$ = ERROR$ (err)
			msg$ = "Error" + STRING$ (err) + " loading the file " + szText$
			MessageBoxA (hWnd, &msg$, &" File Error", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
			INC cUntitledBas
			txt$ = "Untitled" + STRING$ (cUntitledBas) + ".x"
			SetWindowTextA (hWnd, &txt$)
		ELSE
			buffer$ = NULL$ (LOF (nFile))
			READ [nFile], buffer$
			CLOSE (nFile)

			IF IsBinary (buffer$) && ValidExt = 0 THEN
				msg$ = fn$ + $CRLF + "The file is not in ASCII or ANSI format." + $CRLF + "It will not be loaded into the editor."
				MessageBoxA (hWnd, &msg$, &" Not a valid text file", $$MB_OK OR $$MB_ICONWARNING OR $$MB_TASKMODAL)
			ELSE
				' Trim trailing spaces and tabs
				IF TrimTrailingBlanks THEN TrimTrailingTabsAndSpaces (@buffer$)
        ' Refresh recently opened file list
'				WriteRecentFiles (szText$)
				' Put the text in the edit control
				SendMessageA (hSci, $$SCI_INSERTTEXT, 0, &buffer$)
				' Empty the undo buffer (it also sets the state of the document as unmodified)
				SendMessageA (hSci, $$SCI_EMPTYUNDOBUFFER, 0, 0)

				SELECT CASE UCASE$ (strExt$)
					CASE "ASM", "S", "RC" :
					CASE ELSE :
						' Colourise the doc
						Colourise (hSci, 0, -1)

						' Fold the doc
						IF fFoldingOn THEN FoldXBLDoc (hSci, 0, -1, 0)
				END SELECT

				' Tell to Scintilla that the current state of the document is unmodified.
				' SendMessage hSci, $$SCI_SETSAVEPOINT, 0, 0
				' Retrieve the file time and store it in the properties list of the window
				fTime = SED_GetFileTime (szText$)
				SetPropA (hWnd, &"FTIME", fTime)
			END IF
		END IF
	ELSE
		INC cUntitledBas
		txt$ = "Untitled" + STRING$ (cUntitledBas) + ".x"
		ret = SetWindowTextA (hWnd, &txt$)
	END IF

	' Retrieve the name again and set the control options
	szText$ = GetWindowText$ (hWnd)
	IF szText$ THEN
		IF pSci THEN Scintilla_SetOptions (pSci, szText$)
	END IF
	RETURN hSci

END FUNCTION
'
' #############################
' #####  Sci_OnNotify ()  #####
' #############################
'
' Process the Scintilla Edit Control notification messges
'
FUNCTION Sci_OnNotify (hWnd, wParam, lParam)

	PROC tmpPROC
	SCNotification NSC
	SHARED ShowProcedureName
	SHARED hCodeFinder
	FoldingOptionsType FoldOpt
	SHARED hMenu
	SHARED UpperCaseKeywords
	SHARED keywords$[]
	STATIC curStyle
	SHARED hTreeBrowser
	SHARED fShowTreeBrowser

	$TAB = "\t"

	RtlMoveMemory (&NSC, lParam, SIZE (NSC))

	SELECT CASE NSC.hdr.code

		CASE $$SCN_STYLENEEDED :		' syntax color the line
			hSci = GetEdit ()
			startPos = SendMessageA (hSci, $$SCI_GETENDSTYLED, 0, 0)
			lineNumber = SendMessageA (hSci, $$SCI_LINEFROMPOSITION, startPos, 0)
			startPos = SendMessageA (hSci, $$SCI_POSITIONFROMLINE, lineNumber, 0)
			endPos = NSC.position
			Colourise (hSci, startPos, endPos)

		CASE $$SCN_UPDATEUI :
			' Show line and column
			ShowLinCol ()

			' Show the function name in the codefinder combobox
			IF ShowProcedureName THEN
				IFZ SED_WithinProc (@tmpPROC) THEN
					buffer$ = tmpPROC.ProcName
				ELSE
					buffer$ = "(FUNCTION finder)"
				END IF

				' set function name in codefinder
				index = SendMessageA (hCodeFinder, $$CB_SELECTSTRING, -1, &buffer$)

				' select function in function treeview browser
'				IF fShowTreeBrowser THEN
'					' select item in tree browser
'					IF index <> $$CB_ERR THEN
'						DEC index
'						hItem = GetTreeViewNextItem (hTreeBrowser, index)
'						ret = SelectTreeViewItem (hTreeBrowser, hItem)
'					END IF
'				END IF

			END IF

			' CASE $$SCN_NEEDSHOWN :
			' PRINT "SCN_NEEDSHOW: position="; NSC.position, "length="; NSC.length
			' EnsureRangeVisible (NSC.position, NSC.position + NSC.length, 0)

		CASE $$SCN_MODIFIED :

			IF NSC.linesAdded THEN
				' if lines changed, then fold entire doc
				FoldXBLDoc (GetEdit (), 0, -1, 0)

				' update functions, data in codefinder so treeview can
				' have correct line data
				IF fShowTreeBrowser THEN SED_CodeFinder (0)
			END IF

			' get current style for auto-uppercase keywords mode
			IF (NSC.modificationType & $$SC_MOD_CHANGESTYLE) THEN
				startPos = NSC.position
				curStyle = SendMessageA (GetEdit (), $$SCI_GETSTYLEAT, startPos, 0)
			END IF

			' SELECT CASE ALL TRUE
			' CASE NSC.modificationType & $$SC_MOD_INSERTTEXT : PRINT "INSERTTEXT ";
			' CASE NSC.modificationType & $$SC_MOD_DELETETEXT : PRINT "DELETETEXT ";
			' CASE NSC.modificationType & $$SC_MOD_CHANGESTYLE : PRINT "CHANGESTYLE ";
			' CASE NSC.modificationType & $$SC_MOD_CHANGEFOLD : PRINT "CHANGEFOLD ";
			' END SELECT
			' PRINT

			' IF (NSC.modificationType & $$SC_MOD_CHANGEFOLD) THEN
			' FoldChanged (NSC.nLine, NSC.foldLevelNow, NSC.foldLevelPrev)
			' END IF


		CASE $$SCN_MARGINCLICK :		' Margin mouse click
			hSci = GetEdit ()
			IF NSC.margin = 2 THEN		' Fold margin
				LineNumber = SendMessageA (hSci, $$SCI_LINEFROMPOSITION, NSC.position, 0)
				IF (SendMessageA (hSci, $$SCI_GETFOLDLEVEL, LineNumber, 0) && $$SC_FOLDLEVELHEADERFLAG) <> 0 THEN		' If is the head line...
					IF ToggleFolding (LineNumber) = -1 THEN
						SendMessageA (hSci, $$SCI_GOTOLINE, LineNumber, 0)
						curPos = SendMessageA (hSci, $$SCI_POSITIONFROMLINE, LineNumber, 0)
						SendMessageA (hSci, $$SCI_SETSELECTIONSTART, curPos, 0)
						SendMessageA (hSci, $$SCI_SETSELECTIONEND, SendMessageA (hSci, $$SCI_GETLINEENDPOSITION, LineNumber, 0), 0)
					END IF
				ELSE
					SendMessageA (hSci, $$SCI_GOTOLINE, LineNumber, 0)
					curPos = SendMessageA (hSci, $$SCI_POSITIONFROMLINE, LineNumber, 0)
					SendMessageA (hSci, $$SCI_SETSELECTIONSTART, curPos, 0)
					SendMessageA (hSci, $$SCI_SETSELECTIONEND, SendMessageA (hSci, $$SCI_GETLINEENDPOSITION, LineNumber, 0), 0)
				END IF
			ELSE
				LineNumber = SendMessageA (hSci, $$SCI_LINEFROMPOSITION, NSC.position, 0)
				SendMessageA (hSci, $$SCI_GOTOLINE, LineNumber, 0)
				curPos = SendMessageA (hSci, $$SCI_POSITIONFROMLINE, LineNumber, 0)
				SendMessageA (hSci, $$SCI_SETSELECTIONSTART, curPos, 0)
				SendMessageA (hSci, $$SCI_SETSELECTIONEND, SendMessageA (hSci, $$SCI_GETLINEENDPOSITION, LineNumber, 0), 0)
			END IF

		CASE $$SCN_CHARADDED :

			' auto-uppercase keywords
			IF UpperCaseKeywords THEN

				SELECT CASE curStyle
					CASE $$SCE_B_STRING, $$SCE_B_COMMENT : GOTO getout
				END SELECT

				IF NSC.ch = ' ' THEN
					hSci = GetEdit ()
					curPos = SendMessageA (hSci, $$SCI_GETCURRENTPOS, 0, 0)
					pos = curPos - 1
					GetWordAtPosition (pos, @word$)
					IFZ word$ THEN GOTO getout

					upp = UBOUND(keywords$[])
					wordUpper$ = UCASE$(word$)
					FOR i = 0 TO upp
						IF keywords$[i] = wordUpper$ THEN
							IF keywords$[i] != word$ THEN
								' SET word TO upper CASE
								start = SendMessageA (hSci, $$SCI_WORDSTARTPOSITION, pos, 1)
								SendMessageA (hSci, $$SCI_SETSELECTIONSTART, start, 0)
								SendMessageA (hSci, $$SCI_SETSELECTIONEND, curPos, 0)
								ChangeSelectedTextCase (1)
							END IF
							GOTO getout
						END IF
					NEXT i
				END IF
			END IF
getout:

			' display codetip string on ( char
			' IF NSC.ch = 40 THEN ShowCodetip ()  ' Show codetip
			' IF NSC.ch = 41 THEN SendMessageA (GetEdit(), $$SCI_CALLTIPCANCEL, 0, 0)

			' Auto indentation - since SCN_KEY isn't sent in the Windows version,
			' we detect the new line if the char added is a carriage return
			IF NSC.ch = 13 THEN		' carriage RETURN
				IF (GetMenuState (hMenu, $$IDM_AUTOINDENT, $$MF_BYCOMMAND) AND $$MF_CHECKED) = $$MF_CHECKED THEN
					hSci = GetEdit ()
					curPos = SendMessageA (hSci, $$SCI_GETCURRENTPOS, 0, 0)								' current position
					LineNumber = SendMessageA (hSci, $$SCI_LINEFROMPOSITION, curPos, 0)		' line number
					LineLen = SendMessageA (hSci, $$SCI_LINELENGTH, LineNumber - 1, 0)		' length of the line
					buffer$ = NULL$ (LineLen)		' size the buffer
					SendMessageA (hSci, $$SCI_GETLINE, LineNumber - 1, &buffer$)					' get the text of the line
					TabSize = SendMessageA (hSci, $$SCI_GETTABWIDTH, 0, 0)								' size of the tab
					nSpaces = 0
					' note : could use {} brackets to extract individual characters
					' upp = LEN(buffer$)
					' FOR i = 1 TO upp
					' IF MID$(buffer$, i, 1) <> " " THEN
					' IF MID$(buffer$, i, 1) = $TAB THEN
					' nSpaces = nSpaces + TabSize
					' ELSE
					' EXIT FOR
					' END IF
					' ELSE
					' nSpaces = nSpaces + 1
					' END IF
					' NEXT i

					upp = LEN (buffer$) - 1
					FOR i = 0 TO upp
						ch = buffer${i}
						IF ch <> ' ' THEN
							IF ch = '\t' THEN
								nSpaces = nSpaces + TabSize
							ELSE
								EXIT FOR
							END IF
						ELSE
							INC nSpaces
						END IF
					NEXT i

					' Checking for indentation keywords like IF, THEN, FOR, DO...
					' works only if there is not a comment at the end of the line.
					' If single quote is found, then strip off comment part
					IF INSTR (buffer$, "'") THEN SplitOffComment (@buffer$, @buffer$, @comment$)
					buffer$ = TRIM$ (buffer$)
					IF (LEFT$ (buffer$, 3) = "IF " && RIGHT$ (buffer$, 5) = " THEN") || LEFT$ (buffer$, 4) = "ELSE" || LEFT$ (buffer$, 7) = "SELECT " || LEFT$ (buffer$, 5) = "CASE " || LEFT$ (buffer$, 4) = "FOR " || LEFT$ (buffer$, 3) = "DO " || buffer$ = "DO" THEN
						IndentSize = SendMessageA (hSci, $$SCI_GETINDENT, 0, 0)		' size of the indent
						strFill$ = SPACE$ (nSpaces + IndentSize)		' add spaces to indent the line
					ELSE
						strFill$ = SPACE$ (nSpaces)		' add the same spaces on the left that the line above
					END IF
					strFill$ = SpacesToTabs (strFill$)
					SendMessageA (hSci, $$SCI_ADDTEXT, LEN (strFill$), &strFill$)		' indents the line with tabs
				END IF
			END IF

		CASE $$SCN_MACRORECORD :
			RecordMacroCommand (NSC)

	END SELECT

END FUNCTION
'
' #############################
' #####  SpacesToTabs ()  #####
' #############################
'
' Replaces spaces with tabs in line of
' code before first printable character.
'
FUNCTION STRING SpacesToTabs (InString$)

	SHARED hMenu

	IF (GetMenuState (hMenu, $$IDM_USETABS, $$MF_BYCOMMAND) AND $$MF_CHECKED) <> $$MF_CHECKED THEN
		RETURN (InString$)
	END IF

	IFZ InString$ THEN RETURN ""

	TabSize = SendMessageA (GetEdit (), $$SCI_GETTABWIDTH, 0, 0)
	IF TabSize < 1 THEN RETURN InString$

	buffer$ = InString$
	upp = LEN (InString$) - 1
	FOR i = 0 TO upp
		ch = buffer${i}
		SELECT CASE ch
			CASE 32 : sSpc$ = sSpc$ + CHR$ (32)
			CASE 9 : sTab$ = sTab$ + CHR$ (9)
			CASE ELSE : EXIT FOR
		END SELECT
	NEXT i

	IF LEN (sSpc$) >= TabSize THEN
		XstReplace (@sSpc$, SPACE$ (TabSize), @"\t", 0)
		sOutString$ = sTab$ + sSpc$ + MID$ (buffer$, i + 1)
	ELSE
		sOutString$ = InString$
	END IF
	RETURN (sOutString$)

END FUNCTION
'
' ##############################
' #####  ToggleFolding ()  #####
' ##############################
'
' Toggle procedure/function folding
'
FUNCTION ToggleFolding (LineNumber)

	hSci = GetEdit ()
	' Get direct pointer for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN EXIT FUNCTION
	IF (SciMsg (pSci, $$SCI_GETFOLDLEVEL, LineNumber, 0) AND $$SC_FOLDLEVELHEADERFLAG) = 0 THEN		' If is not the head line...
		LineNumber = SciMsg (pSci, $$SCI_GETFOLDPARENT, LineNumber, 0)		' Get the number of the head line of the procedure or function
	END IF
	IF LineNumber > -1 THEN
		SciMsg (pSci, $$SCI_TOGGLEFOLD, LineNumber, 0)		' Toggle the sub or function
		SciMsg (pSci, $$SCI_GOTOLINE, LineNumber, 0)		' Set the caret position
	END IF
	RETURN LineNumber		' Return the current line
END FUNCTION
'
' ###############################
' #####  SED_WithinProc ()  #####
' ###############################
'
' Returns 0 if cursor within FUNCTION,
' and -1 on failure
'
FUNCTION SED_WithinProc (PROC tmpPROC)

	curPos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)		' Current position
	LineNumber = SendMessageA (GetEdit (), $$SCI_LINEFROMPOSITION, curPos, 0)		' Line number
	LineCount = SendMessageA (GetEdit (), $$SCI_GETLINECOUNT, 0, 0)		' Number of lines

	tmpPROC.WhatIsUp = $$ID_ProcNull		' Start with false
	tmpPROC.UpLnNo = 0
	tmpPROC.WhatIsDown = $$ID_ProcNull		' Start with false
	tmpPROC.DnLnNo = LineCount
	tmpPROC.ProcName = "(FUNCTION finder)"

	' Check current line
	LineLen = SendMessageA (GetEdit (), $$SCI_LINELENGTH, LineNumber, 0)		' Length of the line
	buffer$ = NULL$ (LineLen)		' Size the buffer
	SendMessageA (GetEdit (), $$SCI_GETLINE, LineNumber, &buffer$)		' Get the text of the line

	IFZ IsFUNCTION (buffer$, @fn$) THEN
		tmpPROC.WhatIsUp = $$ID_ProcStart		' Proc. Begins
		tmpPROC.UpLnNo = LineNumber
		tmpPROC.ProcName = fn$
	ELSE
		IFZ IsENDFUNCTION (buffer$) THEN
			tmpPROC.WhatIsDown = $$ID_ProcEnd
			tmpPROC.DnLnNo = LineNumber
		END IF
	END IF

	' Check for beginning of FUNCTION if not found
	IF tmpPROC.WhatIsUp = $$ID_ProcNull THEN
		FOR i = LineNumber - 1 TO 0 STEP - 1
			LineLen = SendMessageA (GetEdit (), $$SCI_LINELENGTH, i, 0)		' Length of the line
			buffer$ = NULL$ (LineLen)		' Size the buffer$
			SendMessageA (GetEdit (), $$SCI_GETLINE, i, &buffer$)		' Get the text of the line

			IFZ IsFUNCTION (buffer$, @fn$) THEN
				tmpPROC.WhatIsUp = $$ID_ProcStart
				tmpPROC.UpLnNo = i
				tmpPROC.ProcName = fn$
				EXIT FOR
			ELSE
				IFZ IsENDFUNCTION (buffer$) THEN
					tmpPROC.WhatIsUp = $$ID_ProcEnd
					tmpPROC.UpLnNo = i
					EXIT FOR
				END IF
			END IF

		NEXT i
	END IF

	' Check for END FUNCTION
	IF tmpPROC.WhatIsDown = $$ID_ProcNull THEN
		FOR i = LineNumber + 1 TO LineCount
			LineLen = SendMessageA (GetEdit (), $$SCI_LINELENGTH, i, 0)		' Length of the line
			buffer$ = NULL$ (LineLen)		' Size the buffer$
			SendMessageA (GetEdit (), $$SCI_GETLINE, i, &buffer$)		' Get the text of the line

			IFZ IsFUNCTION (buffer$, @fn$) THEN
				tmpPROC.WhatIsDown = $$ID_ProcStart
				tmpPROC.DnLnNo = i
				tmpPROC.ProcName = fn$
				EXIT FOR
			ELSE
				IFZ IsENDFUNCTION (buffer$) THEN
					tmpPROC.WhatIsDown = $$ID_ProcEnd
					tmpPROC.DnLnNo = i
					EXIT FOR
				END IF
			END IF
		NEXT i
	END IF

	IF (tmpPROC.WhatIsUp = $$ID_ProcStart) && (tmpPROC.WhatIsDown = $$ID_ProcEnd) THEN
		RETURN
	ELSE
		RETURN ($$TRUE)
	END IF

END FUNCTION
'
' ###########################
' #####  IsFUNCTION ()  #####
' ###########################
'
' If line$ is a FUNCTION line, return 0
' and name of function in fn$, on failure,
' return -1.
'
FUNCTION IsFUNCTION (line$, @fn$)

	IFZ line$ THEN RETURN ($$TRUE)
	fn$ = ""
	buffer$ = LTRIM$ (line$)
	IF LEFT$ (buffer$, 9) = "FUNCTION " || LEFT$ (buffer$, 10) = "CFUNCTION " THEN
		p = INSTR (buffer$, "(")
		IFZ p THEN RETURN ($$TRUE)
		fn$ = TRIM$ (LEFT$ (buffer$, p - 1))
		p = RINSTR (fn$, " ")
		IF p THEN fn$ = TRIM$ (MID$ (fn$, p))
		RETURN
	END IF
	RETURN ($$TRUE)

END FUNCTION
'
' ##############################
' #####  IsENDFUNCTION ()  #####
' ##############################
'
' If line$ is a END FUNCTION line, return 0
' or, on failure, return -1.
'
FUNCTION IsENDFUNCTION (line$)
	IFZ line$ THEN RETURN ($$TRUE)
	fn$ = ""
	buffer$ = LTRIM$ (line$)
	IF LEFT$ (buffer$, 4) = "END " && INSTR (buffer$, "FUNCTION") THEN
		RETURN
	END IF
	RETURN ($$TRUE)

END FUNCTION
'
' ###############################
' #####  ClearStatusbar ()  #####
' ###############################
'
' Clear the status bar and disable the toolbar burrons if there is not any file being edited
'
FUNCTION ClearStatusbar ()
	SHARED hStatusbar
	szText$ = ""
	SendMessageA (hStatusbar, $$SB_SETTEXT, 1, &szText$)
	SendMessageA (hStatusbar, $$SB_SETTEXT, 2, &szText$)
	SendMessageA (hStatusbar, $$SB_SETTEXT, 4, &szText$)
	DisableToolbarButtons ()
END FUNCTION
'
'
' ########################################
' #####  EnumMdiTitleToTabRemove ()  #####
' ########################################
'
FUNCTION EnumMdiTitleToTabRemove (szMdiCaption$)

	TC_ITEM ttc_item
	SHARED ghTabMdi

	sCaption$ = TRIM$ (szMdiCaption$)
	nTab = SendMessageA (ghTabMdi, $$TCM_GETITEMCOUNT, 0, 0)

	IFZ nTab THEN EXIT FUNCTION

	FOR item = 0 TO nTab - 1
		' Get tab item text string
		sTabTxt$ = NULL$ (255)
		ttc_item.mask = $$TCIF_TEXT
		ttc_item.pszText = &sTabTxt$
		ttc_item.cchTextMax = LEN (sTabTxt$)
		SendMessageA (ghTabMdi, $$TCM_GETITEM, item, &ttc_item)
		sTabTxt$ = TRIM$ (CSIZE$ (sTabTxt$))
		XstGetPathComponents (sCaption$, "", "", "", @sCaption$, 0)
		' sCaption$ = GetFileName (sCaption)
		IF sCaption$ = sTabTxt$ THEN
			' delete this tab
			SendMessageA (ghTabMdi, $$TCM_DELETEITEM, item, 0)
			' find next available MDI docview in hierarchy and activate it...
			hMdi = SendMessageA (hWndClient, $$WM_MDIGETACTIVE, 0, 0)
			IF hMdi THEN
				' using handle, get associated tab via caption string...
				' get the DocView caption text
				szText$ = GetWindowText$ (hMdi)
				' find the associated tab and activate it
				EnumMdiTitleToTab (szText$)
			END IF
			' get and activate associated Document view
			itemNext = SendMessageA (ghTabMdi, $$TCM_GETCURSEL, 0, 0)
			sTabTxt$ = NULL$ (255)
			ttc_item.mask = $$TCIF_TEXT
			ttc_item.pszText = &sTabTxt$
			ttc_item.cchTextMax = LEN (sTabTxt$)
			SendMessageA (ghTabMdi, $$TCM_GETITEM, itemNext, &ttc_item)
			sTabTxt$ = CSIZE$ (sTabTxt$)
			EnumTabToMdiHandle (sTabTxt$)
			' return item next...
			RETURN itemNext
			EXIT FUNCTION
		END IF
	NEXT

END FUNCTION
'
'
' #########################
' #####  SaveFile ()  #####
' #########################
'
' Save file to disk
'
FUNCTION SaveFile (hWnd, Ask)

	SHARED hWndClient, hWndMain
	SHARED IniFile$
	SHARED ghTabMdi
	SHARED TrimTrailingBlanks

	IFZ GetEdit () THEN RETURN ($$TRUE)
	szText$ = GetWindowText$ (MdiGetActive (hWndClient))
	XstGetPathComponents (szText$, @Path$, @drive$, @dir$, @f$, @attributes)

	' IF INSTR(szText, ANY ":\/") = 0 THEN  ' if no path, it's a new doc
	IFZ Path$ THEN
		self$ = XstGetProgramFileName$ ()
		XstGetPathComponents (self$, @Path$, "", "", "", 0)
		IF RIGHT$ (Path$, 1) <> "\\" THEN Path$ = Path$ + "\\"
		IF LEFT$ (UCASE$ (szText$), 8) = "UNTITLED" && INSTR (szText$, ".") = 0 THEN
			f$ = szText$ + ".x"
		ELSE
			f$ = szText$
		END IF
		Ask = $$TRUE		' we need the dialog for new docs
		' ELSE
		' Path = GetFilePath(szText)
		' f    = GetFileName(szText)
	END IF

	' p = RINSTR (f$, ".")
	' IF p THEN szExt$ = UCASE$(MID$(f$, p + 1))
	GetFileExtension (f$, @file$, @szExt$)
	szExt$ = UCASE$ (szExt$)
	SELECT CASE szExt$
		CASE "X", "XBL", "XL", "RC", "DEC", "HTML", "HTM", "S", "ASM", "XXX" :
		CASE ELSE : szExt$ = ""
	END SELECT

	' IF szExt$ <> "X" && szExt$ <> "XBL" && szExt$ <> "RC" & szExt$ <> "DEC" & szExt$ <> "HTML" & szExt$ <> "HTM" & szExt$ <> "S" THEN szExt$ = ""

	fOptions$ = fOptions$ + "XBLite Code Files (*.x, *.xl, *.xbl) |*.x;*.xl;*.xbl | _
XBLite DEC Files (*.dec)|*.dec| _
Resource Files (*.rc)|*.rc| _
HTML Files (*.html, *.htm)|*.html;*.htm| _
Assembly files (*.s, *.asm)|*.s;*.asm| _
Template files (*.xxx)|*.dec| _
All Files (*.*)|*.*"

	IF Ask THEN
		Style = $$OFN_EXPLORER OR $$OFN_FILEMUSTEXIST OR $$OFN_HIDEREADONLY OR $$OFN_OVERWRITEPROMPT
		IFZ (SaveFileDialog (hWndMain, "", @f$, Path$, fOptions$, "x", Style)) THEN RETURN
	ELSE
		Style = $$OFN_EXPLORER OR $$OFN_HIDEREADONLY
		f$ = Path$ + f$
	END IF

	' Backup the file
	IF (XLONG (IniRead (IniFile$, "Editor options", "BackupEditorFiles", ""))) THEN
		GetFileExtension (f$, @file$, @fExt$)
		fBak$ = file$ + ".bak"
		IF FileExist (f$) THEN XstCopyFile (f$, fBak$)
	END IF

	nLen = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
	Buffer$ = NULL$ (nLen+1)
	SendMessageA (GetEdit (), $$SCI_GETTEXT, LEN (Buffer$), &Buffer$)
	Buffer$ = CSIZE$(Buffer$)

	' Remove trailing spaces and tabs
	IF TrimTrailingBlanks THEN TrimTrailingTabsAndSpaces (@Buffer$)

	IFZ Buffer$ THEN
		msg$ = "Error saving the empty file " + f$
		MessageBoxA (hWnd, &msg$, &" SaveFile Error", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	' save file buffer
	IF XstSaveString (f$, Buffer$) THEN
		err = ERROR (0)
		msg$ = "Error" + STRING$ (err) + " saving the file " + f$
		MessageBoxA (hWnd, &msg$, &" SaveFile Error", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	' If dialog, update caption in case name was changed and also the tab name
	IF Ask THEN
		SetWindowTextA (MdiGetActive (hWndClient), &f$)
		nTab = TabCtrl_GetCurSel (ghTabMdi)
		XstGetPathComponents (f$, "", "", "", @fn$, 0)
		SetTabName (ghTabMdi, nTab, fn$)
	END IF

	' Tell to Scintilla that the current state of the document is unmodified.
	SendMessageA (GetEdit (), $$SCI_SETSAVEPOINT, 0, 0)

	' Update reopen file list (MRU menu)
	WriteRecentFiles (f$)

	' Retrieve the file time and store it in the properties list of the window
	fTime = SED_GetFileTime (f$)
	SetPropA (MdiGetActive (hWndClient), &"FTIME", fTime)

	GetFileExtension (f$, @file$, @fExt$)
	IF fExt$ THEN
		IF UCASE$ (fExt$) <> UCASE$ (szExt$) THEN
			pSci = SendMessageA (GetEdit (), $$SCI_GETDIRECTPOINTER, 0, 0)
			Scintilla_SetOptions (pSci, f$)
		END IF
	END IF

END FUNCTION
'
'
' ###############################
' #####  SaveFileDialog ()  #####
' ###############################
'
' Open a Save File Dialog window
' return selected file name in Filespec$
'
FUNCTION SaveFileDialog (hWnd, Caption$, @Filespec$, InitialDir$, Filter$, DefExtension$, Flags)

	OPENFILENAME ofn
	SHARED hInst

	XstReplace (@Filter$, "|", CHR$ (0), 0)

	IFZ InitialDir$ THEN
		self$ = XstGetProgramFileName$ ()
		XstGetPathComponents (self$, @path$, @drive$, @dir$, @fn$, @attributes)
		InitialDir$ = path$
	END IF

	IFZ Filespec$ THEN
		Filespec$ = NULL$ (255)
	ELSE
		Filespec$ = Filespec$ + NULL$ (255 - LEN (Filespec$))
	END IF

	FileTitle$ = NULL$ (255)

	ofn.lStructSize = SIZE (ofn)
	ofn.hwndOwner = hWnd
	ofn.hInstance = hInst
	ofn.lpstrFilter = &Filter$
	ofn.nFilterIndex = 1
	ofn.lpstrFile = &Filespec$
	ofn.nMaxFile = LEN (Filespec$)
	ofn.lpstrFileTitle = &FileTitle$
	ofn.nMaxFileTitle = LEN (FileTitle$)
	ofn.lpstrInitialDir = &InitialDir$
	IF Caption$ THEN
		ofn.lpstrTitle = &Caption$
	END IF
	ofn.flags = Flags
	ofn.lpstrDefExt = &DefExtension$

	' call dialog
	IFZ GetSaveFileNameA (&ofn) THEN
		Flags = ofn.flags
		Filespec$ = ""
		RETURN
	ELSE
		Flags = ofn.flags
		Filespec$ = CSIZE$ (Filespec$)
		RETURN ($$TRUE)
	END IF

END FUNCTION
'
'
' #################################
' #####  GetFileExtension ()  #####
' #################################
'
' Get filename extension (without .) and
' filename without extension.
'
FUNCTION GetFileExtension (fileName$, @file$, @ext$)

	ext$ = ""
	file$ = ""
	IFZ fileName$ THEN RETURN ($$TRUE)

	f$ = TRIM$ (fileName$)
	fPos = RINSTR (f$, ".")

	IF fPos THEN
		ext$ = RIGHT$ (f$, LEN (f$) - fPos)
		file$ = LEFT$ (f$, fPos - 1)
		RETURN
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  SetTabName ()  #####
' ###########################
'
' Changes the name of the tab
'
FUNCTION SetTabName (hTabCtrl, nTab, strName$)

	TC_ITEM ttc_item

	IFZ strName$ THEN RETURN ($$TRUE)

	ttc_item.mask = $$TCIF_TEXT
	ttc_item.pszText = &strName$
	ttc_item.cchTextMax = 255
	RETURN SendMessageA (hTabCtrl, $$TCM_SETITEM, nTab, &ttc_item)

END FUNCTION
'
'
' ##################################
' #####  TabCtrl_GetCurSel ()  #####
' ##################################
'
' Get currently selected tab control
'
FUNCTION TabCtrl_GetCurSel (hWnd)
	RETURN SendMessageA (hWnd, $$TCM_GETCURSEL, 0, 0)
END FUNCTION
'
'
' ########################
' #####  MdiNext ()  #####
' ########################
'
' Send message to MDI client window to activate
' the next or previous child window.
'
FUNCTION MdiNext (hWndClient, hwndChild, fNext)
	RETURN SendMessageA (hWndClient, $$WM_MDINEXT, hwndChild, fNext)
END FUNCTION
'
' #################################
' #####  InsertTabMdiItem ()  #####
' #################################
'
' Insert a new Tab item
'
FUNCTION InsertTabMdiItem (hTab, item, szTabText$)

	TC_ITEM ttc_item
	SHARED ghTabMdi

	IFZ szTabText$ THEN RETURN ($$TRUE)

	IFZ SendMessageA (ghTabMdi, $$TCM_GETITEMCOUNT, 0, 0) THEN
		ShowWindow (ghTabMdi, $$SW_SHOW)
	END IF

	' Insert a tab...
	ttc_item.mask = $$TCIF_TEXT OR $$TCIF_IMAGE OR $$TCIF_RTLREADING OR $$TCIF_PARAM OR $$TCIF_STATE OR $$TCIS_BUTTONPRESSED OR $$TCIS_HIGHLIGHTED
	ttc_item.pszText = &szTabText$
	ttc_item.cchTextMax = LEN (szTabText$)
	' ttc_item.iImage     = -1
	ttc_item.iImage = 0
	ttc_item.lParam = 0

	RETURN SendMessageA (hTab, $$TCM_INSERTITEM, item, &ttc_item)

END FUNCTION
'
' #########################
' #####  IsBinary ()  #####
' #########################
'
' Check text string for 0x00 character.
' If it exists, then the file is binary.
' Returns -1 if text is binary, or 0
' on failure (is ASCII text).
'
FUNCTION IsBinary (text$)

	IFZ text$ THEN RETURN ($$FALSE)
	upp = LEN (text$) - 1
	IF upp > 65535 THEN upp = 65535
	FOR i = 0 TO upp
		IF text${i} = 0 THEN RETURN ($$TRUE)
	NEXT i
	RETURN ($$FALSE)
END FUNCTION
'
' ############################
' #####  IsAWordChar ()  #####
' ############################
'
'
FUNCTION IsAWordChar (ch)
'	RETURN (ch < 0x80) && (isalnum (ch) || ch == '.' || ch == '_')
' add '$' character for functions that end in $
' add '?' for use as PRINT
	RETURN (ch < 0x80) && (isalnum (ch) || ch == '.' || ch == '_' || ch == '$' || ch = '?')
END FUNCTION
'
' ################################
' #####  IsTypeCharacter ()  #####
' ################################
'
'
FUNCTION IsTypeCharacter (ch)
	RETURN (ch == '%' || ch == '&' || ch == '@' || ch == '!' || ch == '#' || ch == '$')
END FUNCTION
'
' #########################
' #####  IsADigit ()  #####
' #########################
'
'
FUNCTION IsADigit (ch)
	RETURN (ch >= '0') && (ch <= '9')
END FUNCTION
'
' #############################
' #####  IsAWordStart ()  #####
' #############################
'
'
FUNCTION IsAWordStart (ch)
	RETURN (ch < 0x80) && (isalnum (ch) || ch == '_' || ch = '?')
END FUNCTION
'
' ###########################
' #####  isoperator ()  #####
' ###########################
'
'
FUNCTION IsOperator (ch)
	IF (__isascii (ch) && isalnum (ch)) THEN RETURN (0)
	' '.' left out as it is used to make up numbers
	IF (ch == '^' || ch == '&' || ch == '*' || ch == '(' || ch == ')' || ch == '-' || ch == '+' || ch == '=' || ch == '|' || ch == '{' || ch == '}' || ch == '[' || ch == ']' || ch == '<' || ch == '>' || ch == '!' || ch == '~' || ch == '\\' || ch == '/' || ch == ',' || ch == ';' || ch == ':') THEN RETURN (1)
	RETURN (0)
END FUNCTION
'
' ############################
' #####  IsSpaceChar ()  #####
' ############################
'
'
FUNCTION IsSpaceChar (ch)
	RETURN (ch == ' ') || ((ch >= 0x09) && (ch <= 0x0d))
END FUNCTION
'
' ##########################
' #####  Colourise ()  #####
' ##########################
'
' Start syntax coloring from start to end
' positions in document. Use end = -1 to
' color to the end of the doc.
'
FUNCTION Colourise (hEdit, start, finish)
	SHARED keywords$[], keywords2$[]
	TEXTRANGE tr

	lengthDoc = SendMessageA (hEdit, $$SCI_GETLENGTH, 0, 0)
	IF (finish == -1) THEN finish = lengthDoc
	length = finish - start

	cdoc$ = NULL$ (finish)
	tr.chrg.cpMin = start
	tr.chrg.cpMax = finish
	tr.lpstrText = &cdoc$
	ret = SendMessageA (hEdit, $$SCI_GETTEXTRANGE, 0, &tr)

	styleStart = 0
	IF (start > 0) THEN
		styleStart = SendMessageA (hEdit, $$SCI_GETSTYLEAT, start - 1, 0)
	END IF
	ColouriseXBLDoc (hEdit, @cdoc$, start, length, styleStart, @keywords$[], @keywords2$[])

END FUNCTION
'
' ################################
' #####  ColouriseXBLDoc ()  #####
' ################################
'
' Syntax coloring lexer for XBLite
'
FUNCTION ColouriseXBLDoc (hEdit, @doc$, start, lengthDoc, initStyle, @keyWords$[], @keyWords2$[])

	' IFZ keyWords$[] THEN PRINT "No keywords loaded"

	SendMessageA (hEdit, $$SCI_STARTSTYLING, start, 31)

	state = initStyle
	chPrev = ' '
	chNext = doc${0}
	startSeg = 0

	FOR i = 0 TO lengthDoc - 1
		statePrev = state
		ch = chNext
		chNext = ' '
		IF (i + 1 < lengthDoc) THEN chNext = doc${i + 1}
		chNext2 = ' '
		chNext3 = ' '
		IF (i + 2 < lengthDoc) THEN chNext2 = doc${i + 2}
		IF (i + 3 < lengthDoc) THEN chNext3 = doc${i + 3}

		' if (IsLeadByte(codePage, ch)) {	// dbcs
		' if (i + 2 < lengthDoc) {
		' chNext = doc$[i + 2];
		' }
		' chPrev = ' ';
		' i += 1;
		' continue;
		' }

		SELECT CASE state
			CASE $$SCE_B_DEFAULT :

				SELECT CASE TRUE

					CASE (IsAWordStart (ch)) :
						ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_DEFAULT)
						state = $$SCE_B_KEYWORD
						startSeg = i
					CASE (ch == ''') :
					  SELECT CASE TRUE
					    CASE (chNext = 13) || (chNext = 10)   : state = $$SCE_B_COMMENT
					    CASE chNext2 = '''                    : state = $$SCE_B_CHAR
					    CASE (chNext = '\\' && chNext3 = ''') : state = $$SCE_B_CHAR
					    CASE ELSE                             : state = $$SCE_B_COMMENT
					  END SELECT

'						IF chNext2 = ''' || (chNext = '\\' && chNext3 = ''') THEN
'							state = $$SCE_B_CHAR
'						ELSE
'							state = $$SCE_B_COMMENT
'						END IF
						ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_DEFAULT)
						' state = $$SCE_B_COMMENT
						startSeg = i

'					CASE ((ch == '?') && (chPrev = '\n' || chPrev = '\r')) || (ch == '?' && (i = 0)) :		' is ? first char in line
'						ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_DEFAULT)
'						state = $$SCE_B_ASM
'						startSeg = i

					CASE (ch == '\"') :
						ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_DEFAULT)
						state = $$SCE_B_STRING
						startSeg = i
					CASE (ch == '$' && IsSpaceChar (chNext) = 0 && IsOperator (chNext) = 0) :
						ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_DEFAULT)
						state = $$SCE_B_CONSTANT
						startSeg = i
					CASE (IsOperator (ch)) :
						ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_DEFAULT)
						ColourSegHwnd (hEdit, i, i, $$SCE_B_OPERATOR)
						startSeg = i + 1
				END SELECT

			CASE $$SCE_B_KEYWORD :
				IF (!IsAWordChar (ch)) THEN
					ClassifyWord (hEdit, @doc$, startSeg, i - 1, @keyWords$[])
					state = $$SCE_B_DEFAULT
					startSeg = i
					SELECT CASE TRUE
						CASE (ch == ''') :		'state = $$SCE_B_COMMENT
					    SELECT CASE TRUE
					      CASE (chNext = 13) || (chNext = 10)   : state = $$SCE_B_COMMENT
					      CASE chNext2 = '''                    : state = $$SCE_B_CHAR
					      CASE (chNext = '\\' && chNext3 = ''') : state = $$SCE_B_CHAR
					      CASE ELSE                             : state = $$SCE_B_COMMENT
					    END SELECT
'							IF chNext2 = ''' || (chNext = '\\' && chNext3 = ''') THEN
'								state = $$SCE_B_CHAR
'							ELSE
'								state = $$SCE_B_COMMENT
'							END IF
'						CASE (ch == '?') : state = $$SCE_B_ASM
						CASE (ch == '\"') : state = $$SCE_B_STRING
						CASE (ch == '$' && !IsSpaceChar (chNext) && IsOperator (chNext) = 0) : state = $$SCE_B_CONSTANT
						CASE (IsOperator (ch)) :
							ColourSegHwnd (hEdit, startSeg, i, $$SCE_B_OPERATOR)
							state = $$SCE_B_DEFAULT
							startSeg = i + 1
					END SELECT
				END IF

			CASE ELSE :
				SELECT CASE TRUE
					CASE (state == $$SCE_B_CONSTANT) :
						IF (IsSpaceChar (ch)) || IsOperator (ch) THEN
							state = $$SCE_B_DEFAULT
							ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_CONSTANT)
							startSeg = i
						END IF
					CASE (state == $$SCE_B_COMMENT) :
						IF (ch == '\r' || ch == '\n') THEN
							ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_COMMENT)
							state = $$SCE_B_DEFAULT
							startSeg = i
						END IF
						' ***** new section *****
					CASE (state == $$SCE_B_CHAR) :
						IF (ch == '\\') THEN
							IF (chNext == '\"' || chNext == ''' || chNext == '\\') THEN
								INC i
								ch = chNext
								chNext = ' '
								IF (i + 1 < lengthDoc) THEN chNext = doc${i + 1}
							END IF
						ELSE
							IF (ch == ''') THEN
								IF chNext == ''' && chPrev = ''' THEN		'skip it, we have '''

								ELSE
									ColourSegHwnd (hEdit, startSeg, i, $$SCE_B_CHAR)
									state = $$SCE_B_DEFAULT
									INC i
									ch = chNext
									chNext = ' '
									IF (i + 1 < lengthDoc) THEN chNext = doc${i + 1}
									startSeg = i
								END IF
							END IF
						END IF

'					CASE (state == $$SCE_B_ASM) :
'						IF (ch == '\r' || ch == '\n') THEN
'							ColourSegHwnd (hEdit, startSeg, i - 1, $$SCE_B_ASM)
'							state = $$SCE_B_DEFAULT
'							startSeg = i
'						END IF

					CASE (state == $$SCE_B_STRING) :
						' IF (ch == '\"') THEN
						' ColourSegHwnd (hEdit, startSeg, i, $$SCE_B_STRING)
						' state = $$SCE_B_DEFAULT
						' INC i
						' ch = chNext
						' chNext = ' '
						' IF (i + 1 < lengthDoc) THEN chNext = doc${i + 1}
						' startSeg = i
						' END IF

						SELECT CASE ch
							CASE '\\' :
								IF (chNext == '\"' || chNext == ''' || chNext == '\\') THEN
									INC i
									ch = chNext
									chNext = ' '
									IF (i + 1 < lengthDoc) THEN chNext = doc${i + 1}
								END IF

							CASE '\"' :
								ColourSegHwnd (hEdit, startSeg, i, $$SCE_B_STRING)
								state = $$SCE_B_DEFAULT
								INC i
								ch = chNext
								chNext = ' '
								IF (i + 1 < lengthDoc) THEN chNext = doc${i + 1}
								startSeg = i
						END SELECT
				END SELECT

				IF (state == $$SCE_B_DEFAULT) THEN		' One of the above succeeded
					SELECT CASE TRUE
						CASE (ch == ''') : state = $$SCE_B_COMMENT
'						CASE (ch == '?') : state = $$SCE_B_ASM
						CASE (ch == '\"') : state = $$SCE_B_STRING
						CASE (ch == '$' && IsSpaceChar (chNext) = 0 && IsOperator (chNext) = 0) : state = $$SCE_B_CONSTANT
						CASE (IsAWordStart (ch)) : state = $$SCE_B_KEYWORD
						CASE (IsOperator (ch)) :
							ColourSegHwnd (hEdit, startSeg, i, $$SCE_B_OPERATOR)
							startSeg = i + 1
					END SELECT
				END IF
		END SELECT
		chPrev = ch
	NEXT i
	IF (startSeg < lengthDoc) THEN ColourSegHwnd (hEdit, startSeg, lengthDoc - 1, state)

END FUNCTION
'
' ##############################
' #####  ColourSegHwnd ()  #####
' ##############################
'
' Set color attribute (state) of range of characters.
'
FUNCTION ColourSegHwnd (hWnd, start, finish, chAttr)
	' Only perform styling if non empty range
	IF (finish != start - 1) THEN
		IF (finish < start) THEN
			PRINT "Bad color positions "; start; " -"; finish
		END IF
		SendMessageA (hWnd, $$SCI_SETSTYLING, finish - start + 1, chAttr)
	END IF
END FUNCTION
'
' #############################
' #####  ClassifyWord ()  #####
' #############################
'
' Check if text is a digit or a keyword.
' Then set its state in document (colourise).
'
FUNCTION ClassifyWord (hEdit, @doc$, start, finish, @keyWords$[])

	IFZ doc$ THEN RETURN

	wordIsNumber = IsADigit (doc${start}) || (doc${start} == '.')
	length = MIN (finish - start + 1, 40)
	s$ = MID$ (doc$, start + 1, length)
	chAttr = 0
	IF (wordIsNumber) THEN
		chAttr = $$SCE_B_NUMBER
	ELSE
		IF (WordInList (@s$, @keyWords$[])) THEN
			chAttr = $$SCE_B_KEYWORD
		END IF
	END IF
	ColourSegHwnd (hEdit, start, finish, chAttr)

END FUNCTION
'
' ###########################
' #####  WordInList ()  #####
' ###########################
'
' Determine if word$ is within keyword list array.
'
FUNCTION WordInList (word$, @list$[])
	IFZ list$[] THEN RETURN ($$FALSE)
	IFZ word$ THEN RETURN ($$FALSE)
	upp = UBOUND (list$[])
	FOR i = 0 TO upp
		' Initial test is to mostly avoid slow function call
		s$ = list$[i]
		IF ((s${0} == word${0}) && (strcmp (&s$, &word$) == 0)) THEN
			RETURN ($$TRUE)
		END IF
	NEXT i
	RETURN ($$FALSE)
END FUNCTION
'
' ##############################
' #####  IsStartOfLine ()  #####
' ##############################
'
' check if current position of cursor is first char in line
'
FUNCTION IsStartOfLine (hEdit)

	curPos = SendMessageA (hEdit, $$SCI_GETCURRENTPOS, 0, 0)
	line = SendMessageA (hEdit, $$SCI_LINEFROMPOSITION, curPos, 0)
	startOfLine = SendMessageA (hEdit, $$SCI_POSITIONFROMLINE, line, 0)
	IF curPos = startOfLine THEN RETURN ($$TRUE)
	RETURN ($$FALSE)

END FUNCTION
'
' #########################
' #####  FileOpen ()  #####
' #########################
'
' Open a file in a MDI window
'
FUNCTION FileOpen ()

	SHARED CURDIR$
	SHARED hWndMain

	XstGetCurrentDirectory (@CURDIR$)
	' Path  = CURDIR$

	fOptions$ = fOptions$ + "XBLite Code Files (*.x, *.xl, *.xbl)|*.x;*.xl;*.xbl| _
XBLite DEC Files (*.dec)|*.dec| _
Resource Files (*.rc)|*.rc| _
Text Files (*.txt)|*.text| _
HTML Files (*.html, *.htm)|*.html;*.htm| _
Assembly files (*.s, *.asm)|*.s;*.asm| _
Template files (*.xxx)|*.xxx| _
All Files (*.*)|*.*"

	f$ = "*.x;*.xl;*.xbl;*.dec;*.asm"
	Style = $$OFN_EXPLORER OR $$OFN_FILEMUSTEXIST OR $$OFN_HIDEREADONLY
	IF OpenFileDialog (hWndMain, "", @f$, CURDIR$, fOptions$, "x", Style) THEN hMdi = OpenThisFile (f$)

	RETURN hMdi

END FUNCTION
'
' ###############################
' #####  OpenFileDialog ()  #####
' ###############################
'
' Open a file open dialog window to select filename.
'
FUNCTION OpenFileDialog (hWnd, Caption$, Filespec$, InitialDir$, Filter$, DefExtension$, Flags)

	SHARED CURDIR$
	OPENFILENAME ofn
	SHARED hInst

	XstReplace (@Filter$, "|", CHR$ (0), 0)

	IFZ InitialDir$ THEN
		XstGetCurrentDirectory (@CURDIR$)
		InitialDir$ = CURDIR$
	END IF

	IFZ Filespec$ THEN
		Filespec$ = NULL$ (255)
	ELSE
		Filespec$ = Filespec$ + NULL$ (255 - LEN (Filespec$))
	END IF

	FileTitle$ = NULL$ (255)

	ofn.lStructSize = SIZE (ofn)
	ofn.hwndOwner = hWnd
	ofn.hInstance = hInst
	ofn.lpstrFilter = &Filter$
	ofn.nFilterIndex = 1
	ofn.lpstrFile = &Filespec$
	ofn.nMaxFile = LEN (Filespec$)
	ofn.lpstrFileTitle = &FileTitle$
	ofn.nMaxFileTitle = LEN (FileTitle$)
	ofn.lpstrInitialDir = &InitialDir$
	IF Caption$ THEN
		ofn.lpstrTitle = &Caption$
	END IF
	ofn.flags = Flags
	ofn.lpstrDefExt = &DefExtension$

	' call dialog
	IFZ GetOpenFileNameA (&ofn) THEN
		Flags = ofn.flags
		Filespec$ = ""
		RETURN
	ELSE
		Flags = ofn.flags
		Filespec$ = CSIZE$ (Filespec$)
		RETURN ($$TRUE)
	END IF

END FUNCTION
'
' #########################################
' #####  SED_SaveLoadedFilesPaths ()  #####
' #########################################
'
' Save the path of the loaded files
'
FUNCTION SED_SaveLoadedFilesPaths ()

	SHARED hWndClient

	$BIT0 = BITFIELD (1, 0)

	self$ = XstGetProgramFileName$ ()
	XstGetPathComponents (self$, @path$, "", "", "", 0)
	f$ = path$ + "xsed.lfs"

	err = ERROR (0)
	fNumber = OPEN (f$, $$WRNEW)
	IF ERROR (-1) THEN RETURN (-1)

	' Count the number of child windows
	p = 0
	p1 = GetWindow (hWndClient, $$GW_CHILD)

	DO WHILE p1 <> 0
		p1 = GetWindow (p1, $$GW_HWNDNEXT)
		INC p
	LOOP

	' Save the paths, positions and bookmarks
	FOR i = 1 TO p
		szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
		hEdit = GetEdit ()
		curPos = SendMessageA (hEdit, $$SCI_GETCURRENTPOS, 0, 0)
		IF (INSTR (szPath$, ":") <> 0) || (INSTR (szPath$, "\\") <> 0) || (INSTR (szPath$, "/") <> 0) THEN
			bk = 0 : buffer$ = ""
			fMark = 0
			' BIT SET fMark, 0
			fMark = SET (fMark, $BIT0)
			nLine = SendMessageA (hEdit, $$SCI_MARKERNEXT, 0, fMark)
			DO WHILE nLine <> -1
				INC bk
				buffer$ = buffer$ + "|" + STRING$ (nLine)
				fMark = 0
				' BIT SET fMark, 0
				fMark = SET (fMark, $BIT0)
				nLine = SendMessageA (hEdit, $$SCI_MARKERNEXT, nLine + 1, fMark)
			LOOP
			PRINT [fNumber], szPath$ + "|" + STRING$ (curPos) + "|" + STRING$ (bk) + buffer$
		END IF
		MdiNext (hWndClient, hWndActive, 0)		' Set focus to next child window
	NEXT

	CLOSE (fNumber)

END FUNCTION
'
' ###############################
' #####  OpenRecentFile ()  #####
' ###############################
'
' Opens a file from the Recent files menu
'
FUNCTION STRING OpenRecentFile (wParam)

	SHARED hWndMain
	SHARED RecentFiles$[]
	SHARED IniFile$

	' Get the name of the file from the ini file
	ctrlID = LOWORD (wParam)

	IF (ctrlID - $$IDM_RECENTSTART >= 1) && (ctrlID - $$IDM_RECENTSTART <= UBOUND (RecentFiles$[]) + 1) THEN
    index = ctrlID - $$IDM_RECENTSTART
		f$ = RecentFiles$[index - 1]
	END IF
	IFZ FileExist (f$) THEN
		IFZ f$ THEN f$ = "(no name found)"
		msg$ = "The file " + f$ + "\r\n" + " does not exist.   "
		MessageBoxA (hWndMain, &msg$, &" OpenRecentFile Error", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		GetRecentFiles ()
		EXIT FUNCTION
	END IF

	' open selected recent file
	OpenThisFile (f$)

	' get last position and bookmarks from ini file
	szSection$ = "Reopen files"
	szKey$     = "File " + STRING$ (index)
	buffer$      = NULL$ (300)
	ret = GetPrivateProfileStringA (&szSection$, &szKey$, &szDefault$, &buffer$, LEN (buffer$), &IniFile$)
  buffer$ = TRIM$(CSIZE$(buffer$))
	IF buffer$ THEN
	  IF INSTR (buffer$, "|") THEN
		  strPath$ = XstParse$ (buffer$, "|", 1)
		  caretPos = XLONG (XstParse$ (buffer$, "|", 2))
		  bk = XLONG (XstParse$ (buffer$, "|", 3))
		  hEdit = GetEdit ()
			DO WHILE bk <> 0
				nLine = XLONG (XstParse$ (buffer$, "|", bk + 3))
				SendMessageA (hEdit, $$SCI_MARKERADD, nLine, 0)
				DEC bk
			LOOP
			endPos = SendMessageA (hEdit, $$SCI_GETTEXTLENGTH, 0, 0)
			SendMessageA (hEdit, $$SCI_GOTOPOS, endPos, 0)
			LinesOnScreen = SendMessageA (hEdit, $$SCI_LINESONSCREEN, 0, 0)
			LineToGo = SendMessageA (hEdit, $$SCI_LINEFROMPOSITION, caretPos, 0)
			LineToGo = LineToGo - (LinesOnScreen \ 2)
			SendMessageA (hEdit, $$SCI_GOTOLINE, LineToGo, 0)
			SendMessageA (hEdit, $$SCI_GOTOPOS, caretPos, 0)
		END IF
  END IF

	RETURN (f$)

END FUNCTION
'
' #############################
' #####  BlockComment ()  #####
' #############################
'
' Block comment the currently selected text
' Use ' for normal file, ; for ASM file
'
FUNCTION BlockComment ()

	SHARED hWndClient

	hEdit = GetEdit ()
	IFZ hEdit THEN EXIT FUNCTION

	path$ = GetWindowText$ (MdiGetActive (hWndClient))
	GetFileExtension (path$, @f$, @ext$)
	SELECT CASE LCASE$(ext$)
		CASE "s", "asm" : commentChr$ = ";"
		CASE ELSE : commentChr$ = "'"
	END SELECT

	' Get direct pointer for faster access
	pSci = SendMessageA (hEdit, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN EXIT FUNCTION

	curPos = SciMsg (pSci, $$SCI_GETCURRENTPOS, 0, 0)
	startPos = SciMsg (pSci, $$SCI_GETSELECTIONSTART, 0, 0)
	startLine = SciMsg (pSci, $$SCI_LINEFROMPOSITION, startPos, 0)
	endPos = SciMsg (pSci, $$SCI_GETSELECTIONEND, 0, 0)
	endLine = SciMsg (pSci, $$SCI_LINEFROMPOSITION, endPos, 0)
	nCol = SciMsg (pSci, $$SCI_GETCOLUMN, endPos, 0)
	IF nCol = 0 && endLine > startLine THEN endLine = endLine - 1
	SciMsg (pSci, $$SCI_GOTOLINE, startLine, 0)
	IF (SciMsg (pSci, $$SCI_GETFOLDLEVEL, startLine, 0) AND $$SC_FOLDLEVELHEADERFLAG) <> 0 THEN		' If is the head line...
		IFZ SciMsg (pSci, $$SCI_GETFOLDEXPANDED, startLine, 0) THEN		' If it is folded...
			ToggleFolding (startLine)		' ...toggle it
		END IF
	END IF
	FOR i = startLine TO endLine
		szText$ = ""
		nLen = SciMsg (pSci, $$SCI_LINELENGTH, i, 0)
		buffer$ = NULL$ (nLen)
		SciMsg (pSci, $$SCI_GETLINE, i, &buffer$)
		buffer$ = CSIZE$ (buffer$)
		' IndentSize = SciMsg (pSci, $$SCI_GETINDENT, 0, 0)
		upp = LEN (buffer$)
		FOR x = 1 TO upp
			IF MID$ (buffer$, x, 1) <> " " && MID$ (buffer$, x, 1) <> CHR$ (9) THEN
				szText$ = LEFT$ (buffer$, x - 1)
				EXIT FOR
			END IF
		NEXT
		' buffer$ = LTRIM$(buffer$, ANY CHR$(32, 9, 13, 10))
		buffer$ = LTRIM$ (buffer$)
		pos = SciMsg (pSci, $$SCI_POSITIONFROMLINE, i, 0)
		IF buffer$ THEN
			szText$ = commentChr$ + szText$
			SciMsg (pSci, $$SCI_SETTARGETSTART, pos, 0)
			SciMsg (pSci, $$SCI_SETTARGETEND, pos + LEN (szText$) - 1, 0)
			SciMsg (pSci, $$SCI_REPLACETARGET, -1, &szText$)
			IF startLine <> endLine THEN curPos = curPos + 1
		END IF
	NEXT
	SciMsg (pSci, $$SCI_SETCURRENTPOS, curPos, 0)

END FUNCTION
'
' ###############################
' #####  BlockUncomment ()  #####
' ###############################
'
' Block uncomment currently selected lines
'
FUNCTION BlockUncomment ()

	SHARED hWndClient

	hEdit = GetEdit ()
	IFZ hEdit THEN EXIT FUNCTION

	path$ = GetWindowText$ (MdiGetActive (hWndClient))
	GetFileExtension (path$, @f$, @ext$)
	SELECT CASE LCASE$(ext$)
		CASE "s", "asm" : comment = ';'
		CASE ELSE : comment = '''
	END SELECT

	' Get direct pointer for faster access
	pSci = SendMessageA (hEdit, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN EXIT FUNCTION

	curPos = SciMsg (pSci, $$SCI_GETCURRENTPOS, 0, 0)
	startPos = SciMsg (pSci, $$SCI_GETSELECTIONSTART, 0, 0)
	startLine = SciMsg (pSci, $$SCI_LINEFROMPOSITION, startPos, 0)
	endPos = SciMsg (pSci, $$SCI_GETSELECTIONEND, 0, 0)
	endLine = SciMsg (pSci, $$SCI_LINEFROMPOSITION, endPos, 0)
	nCol = SciMsg (pSci, $$SCI_GETCOLUMN, endPos, 0)
	IF nCol = 0 && endLine > startLine THEN endLine = endLine - 1
	SciMsg (pSci, $$SCI_GOTOLINE, startLine, 0)
	IF (SciMsg (pSci, $$SCI_GETFOLDLEVEL, startLine, 0) AND $$SC_FOLDLEVELHEADERFLAG) <> 0 THEN		' If is the head line...
		IFZ SciMsg (pSci, $$SCI_GETFOLDEXPANDED, startLine, 0) THEN		' If it is folded...
			ToggleFolding (startLine)		' ...toggle it
		END IF
	END IF

	FOR i = startLine TO endLine
		szText$ = ""
		nLen = SciMsg (pSci, $$SCI_LINELENGTH, i, 0)
		buffer$ = NULL$ (nLen)
		SciMsg (pSci, $$SCI_GETLINE, i, &buffer$)
		buffer$ = CSIZE$ (buffer$)
		' IndentSize = SciMsg (pSci, $$SCI_GETINDENT, 0, 0)
		szText$ = ""
		upp = LEN (buffer$)
		FOR x = 1 TO upp
			IF MID$ (buffer$, x, 1) <> " " && MID$ (buffer$, x, 1) <> CHR$ (9) THEN
				szText$ = LEFT$ (buffer$, x - 1)
				EXIT FOR
			END IF
		NEXT

		' buffer$ = LTRIM$(buffer$, ANY CHR$(32, 9, 13, 10))
		buffer$ = LTRIM$ (buffer$)
		pos = SciMsg (pSci, $$SCI_POSITIONFROMLINE, i, 0)

		IF buffer$ THEN
			IF buffer${0} = comment THEN 			' LEFT$ (buffer$, 1) = "'" THEN
				IF szText$ THEN
					SciMsg (pSci, $$SCI_SETTARGETSTART, pos, 0)
					SciMsg (pSci, $$SCI_SETTARGETEND, pos + LEN (szText$) + 1, 0)
					SciMsg (pSci, $$SCI_REPLACETARGET, -1, &szText$)
				ELSE
					szText$ = "" + CHR$ (0)
					SciMsg (pSci, $$SCI_SETTARGETSTART, pos, 0)
					SciMsg (pSci, $$SCI_SETTARGETEND, pos + 1, 0)
					SciMsg (pSci, $$SCI_REPLACETARGET, -1, &szText$)
				END IF
				IF startLine <> endLine THEN curPos = curPos - 1
			END IF
		END IF
	NEXT i
	SciMsg (pSci, $$SCI_SETCURRENTPOS, curPos, 0)

END FUNCTION
'
' #######################################
' #####  ChangeSelectedTextCase ()  #####
' #######################################
'
' Converts selected text to uppercase
' fCase = 1 (upper case), 2 (lower case)
'
FUNCTION ChangeSelectedTextCase (fCase)

	TEXTRANGE txtrg		' Text range structure

	' If startSelPos and endSelPos are the same there is not selection,
	startSelPos = SendMessageA (GetEdit (), $$SCI_GETSELECTIONSTART, 0, 0)
	endSelPos = SendMessageA (GetEdit (), $$SCI_GETSELECTIONEND, 0, 0)
	IF startSelPos = endSelPos THEN EXIT FUNCTION

	' Allocate the buffer
	buffer$ = NULL$ (endSelPos - startSelPos)

	' Text range
	txtrg.chrg.cpMin = startSelPos
	txtrg.chrg.cpMax = endSelPos
	txtrg.lpstrText = &buffer$

	' Retrieve the text
	SendMessageA (GetEdit (), $$SCI_GETTEXTRANGE, 0, &txtrg)

	' Convert it to upper or lower case
	SELECT CASE fCase
		CASE 1 : buffer$ = UCASE$ (buffer$)
		CASE 2 : buffer$ = LCASE$ (buffer$)
		CASE ELSE : EXIT FUNCTION
	END SELECT

	' Replace the selected text
	SendMessageA (GetEdit (), $$SCI_REPLACESEL, 0, &buffer$)

END FUNCTION
'
' ############################
' #####  FindReplace ()  #####
' ############################
'
' Open Find/Replace dialog box
'
FUNCTION FindReplaceDialog (hWnd, wParam)

	SHARED hInst
	STATIC FINDREPLACE fr		' // FINDREPLACE structure
	STATIC szFindText$		' // Text to search
	STATIC szReplText$		' // Replace text
	SHARED szLastFind$		' // Last word found
	SHARED dwFindMsg
	SHARED startPos
	SHARED endPos

	IF GetEdit () THEN		' If there is an active window
		' ==================================================================
		' Fills the search box with the selected word.
		' If there are carriage returns or/and line feeds, this mean that
		' there is a block selected, instead of a word, so avoid it.
		' ==================================================================
		startPos = SendMessageA (GetEdit (), $$SCI_GETSELECTIONSTART, 0, 0)
		endPos = SendMessageA (GetEdit (), $$SCI_GETSELECTIONEND, 0, 0)
		IF endPos > startPos THEN
			buffer$ = NULL$ (endPos - startPos + 1)
			SendMessageA (GetEdit (), $$SCI_GETSELTEXT, 0, &buffer$)
			buffer$ = CSIZE$ (buffer$)
			IF buffer$ THEN
				IF INSTR (buffer$, CHR$ (13)) = 0 && INSTR (buffer$, CHR$ (10)) = 0 THEN
					szFindText$ = buffer$  + NULL$ (255 - LEN (buffer$))
					szLastFind$ = buffer$
				END IF
			ELSE
				szFindText$ = szLastFind$  + NULL$ (255 - LEN (szLastFind$))
			END IF
		ELSE
			szFindText$ = szLastFind$  + NULL$ (255 - LEN (szLastFind$))
		END IF

		IFZ TRIM$(CSIZE$(szFindText$)) THEN szFindText$ = "find" + NULL$(255 - 4) 'NULL$ (255)
		IFZ TRIM$(CSIZE$(szReplText$)) THEN szReplText$ = "replace" + NULL$(255 - 7) 'NULL$ (255)

		' Register a Windows message to communicate with the dialog
		' Sends messages identified by dwFindMsg.
		dwFindMsg = RegisterWindowMessageA (&"commdlg_FindReplace")
		fr.lStructSize = SIZE (fr)
		fr.hwndOwner = hWnd
		fr.hInstance = hInst
		fr.flags = $$FR_DOWN | $$FR_ENABLETEMPLATE | $$FR_ENABLEHOOK
		fr.lCustData = LOWORD (wParam)
		fr.lpfnHook = &FRHookProc()  'NULL

		IF LOWORD (wParam) = $$IDM_FIND THEN
			fr.lpstrFindWhat = &szFindText$
			fr.lpstrReplaceWith = NULL
			fr.wFindWhatLen = 255
			fr.wReplaceWithLen = 0
			fr.lpTemplateName = &"custfind"
			hFind = FindTextA (&fr)		' Find
		ELSE
			fr.lpstrFindWhat = &szFindText$
			fr.lpstrReplaceWith = &szReplText$
			fr.wFindWhatLen = 255
			fr.wReplaceWithLen = 255
			fr.lpTemplateName = &"custreplace"
			hFind = ReplaceTextA (&fr)		' Find and Replace
		END IF
		IFZ hFind THEN fr.lCustData = 0
	END IF
	RETURN (hFind)
END FUNCTION
'
' ###############################
' #####  FindReplaceMsg ()  #####
' ###############################
'
' Respond to FindReplace Dialog box
' user request/search. For multiple
' replace, a selection on the text
' must be made.
'
FUNCTION FindReplaceMsg (hWnd, hFind, lParam)

	SHARED hInst
	STATIC FINDREPLACE fr		' FINDREPLACE structure
	SHARED szFindText$			' Text to search
	STATIC szReplText$			' Replace text
	SHARED szLastFind$			' Last word found
	SHARED dwFindMsg				' Registered message handle
	SHARED startPos					' Starting position
	SHARED endPos						' Ending position
	SHARED curPos						' Current position
	SHARED findFlags				' Find flags
	SHARED updown						' Search direction
	SHARED find$[], replace$[] ' mru lists for find/replace comboboxes
	STATIC findCount				' count of items in mru find list
	STATIC replaceCount			' count of items in mru replace list
	SHARED fromCursorState  ' if From Cursor is checked, start search from current pos, else, from start of doc
	SHARED fDlgState        ' set to $$TRUE when dialog is open
	RtlMoveMemory (&fr, lParam, SIZE (fr))

	' PRINT "find    = "; CSTRING$(fr.lpstrFindWhat)
	' PRINT "replace = "; CSTRING$(fr.lpstrReplaceWith)

	IF (fr.flags AND $$FR_DIALOGTERM) = $$FR_DIALOGTERM THEN
		IF szLastFind$ <> szFindText$ THEN szLastFind$ = szFindText$
		hFind = 0
		fDlgState = 0  ' dlg box closed
	ELSE
		hSci = GetEdit ()
		IFZ hSci THEN	RETURN

		SELECT CASE TRUE

			CASE (fr.flags AND $$FR_FINDNEXT) = $$FR_FINDNEXT :
				' Find next
				' Get the options checked in the dialog box
				findFlags = 0
				IF (fr.flags AND $$FR_MATCHCASE) = $$FR_MATCHCASE THEN findFlags = findFlags OR $$SCFIND_MATCHCASE
				IF (fr.flags AND $$FR_WHOLEWORD) = $$FR_WHOLEWORD THEN findFlags = findFlags OR $$SCFIND_WHOLEWORD
				' If FR_DOWN = FALSE we must seach backwards
				updown = 0
				IF (fr.flags AND $$FR_DOWN) = $$FR_DOWN THEN updown = $$FR_DOWN

				IFZ fDlgState THEN
					IFZ fromCursorState THEN
						SendMessageA (hSci, $$SCI_SETCURRENTPOS, 0, 0)  ' start search from start of doc
						fDlgState = $$TRUE
					END IF
				END IF

				' Begin to search from the current position
				curPos = SendMessageA (hSci, $$SCI_GETCURRENTPOS, 0, 0)

				IF startPos <> curPos THEN
					IF updown = $$FR_DOWN THEN
						startPos = curPos
					ELSE
						IF curPos < startPos THEN startPos = curPos
						IFZ startPos THEN startPos = curPos
					END IF
				END IF

				' For backward searches the end position must be less than the start position
				endPos = SendMessageA (hSci, $$SCI_GETTEXTLENGTH, 0, 0)
				IF updown <> $$FR_DOWN THEN
					endPos = 0		' Search backwards
					SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos - 1, 0)
				ELSE
					IFZ startPos THEN
						SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos, 0)
					ELSE
						SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos + 1, 0)
					END IF
				END IF

				' Set the end position and the find flags
				SendMessageA (hSci, $$SCI_SETTARGETEND, endPos, 0)
				SendMessageA (hSci, $$SCI_SETSEARCHFLAGS, findFlags, 0)

				' Search for the text to find
				szFindText$ = CSTRING$ (fr.lpstrFindWhat)
				IFZ szFindText$ THEN RETURN
				hr = SendMessageA (hSci, $$SCI_SEARCHINTARGET, LEN (szFindText$), &szFindText$)
				IF hr = -1 THEN
					MessageBoxA (hFind, &"No match found   ", &" Find", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
				ELSE
					' Position the caret and select the text
					SendMessageA (hSci, $$SCI_SETCURRENTPOS, hr, 0)
					SendMessageA (hSci, $$SCI_GOTOPOS, hr, 0)
					SendMessageA (hSci, $$SCI_SETSELECTIONSTART, hr, 0)
					SendMessageA (hSci, $$SCI_SETSELECTIONEND, hr + LEN (szFindText$), 0)
					' Increase the position
					startPos = hr
				END IF

				' update mru list for combobox in find dialog
				find$ = szFindText$
				GOSUB UpdateFR


			CASE (fr.flags AND $$FR_REPLACE) = $$FR_REPLACE :
				findFlags = 0
				' Get the options checked in the dialog box
				IF (fr.flags AND $$FR_MATCHCASE) = $$FR_MATCHCASE THEN findFlags = findFlags OR $$SCFIND_MATCHCASE
				IF (fr.flags AND $$FR_WHOLEWORD) = $$FR_WHOLEWORD THEN findFlags = findFlags OR $$SCFIND_WHOLEWORD

				IFZ fDlgState THEN
					IFZ fromCursorState THEN
						SendMessageA (hSci, $$SCI_SETCURRENTPOS, 0, 0)  ' start search from start of doc
						fDlgState = $$TRUE
					END IF
				END IF

				' Begin to search from the current position
				startPos = SendMessageA (hSci, $$SCI_GETCURRENTPOS, 0, 0)
				' End position = length of the document
				endPos = SendMessageA (hSci, $$SCI_GETTEXTLENGTH, 0, 0)
				' See if there is text selected
				x = SendMessageA (hSci, $$SCI_GETSELECTIONSTART, 0, 0)
				y = SendMessageA (hSci, $$SCI_GETSELECTIONEND, 0, 0)
				IF y > x THEN startPos = x
				' Set the start position
				SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos, 0)
				' Set the end position
				SendMessageA (hSci, $$SCI_SETTARGETEND, endPos, 0)
				' Set the search flags
				SendMessageA (hSci, $$SCI_SETSEARCHFLAGS, findFlags, 0)
				' Search the text to replace
				szFindText$ = CSTRING$ (fr.lpstrFindWhat)
				IFZ szFindText$ THEN RETURN

				hr = SendMessageA (hSci, $$SCI_SEARCHINTARGET, LEN (szFindText$), &szFindText$)
				IF hr = -1 THEN
					MessageBoxA (hFind, &"Match not found   ", &" Replace", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
				ELSE
					' Position the caret and select the text
					SendMessageA (hSci, $$SCI_SETCURRENTPOS, hr, 0)
					SendMessageA (hSci, $$SCI_GOTOPOS, hr, 0)
					SendMessageA (hSci, $$SCI_SETSELECTIONSTART, hr, 0)
					SendMessageA (hSci, $$SCI_SETSELECTIONEND, hr + LEN (szFindText$), 0)
					' Replace the selection
					szReplText$ = CSTRING$ (fr.lpstrReplaceWith)
					IFZ szReplText$ THEN szReplText$ = NULL$ (1)
					ret = SendMessageA (hSci, $$SCI_REPLACESEL, 0, &szReplText$)
					' Increase the position
					startPos = hr
				END IF

				' update mru lists for comboboxes in find/replace dialog
				find$ = szFindText$
				replace$ = szReplText$
				GOSUB UpdateFR

				' Send a message to search for the next occurrence
				fr.flags = fr.flags OR $$FR_FINDNEXT
				ret = SendMessageA (hWnd, dwFindMsg, 0, &fr)


			CASE (fr.flags AND $$FR_REPLACEALL) = $$FR_REPLACEALL :
				' Replace all
				findFlags = 0
				IF (fr.flags AND $$FR_MATCHCASE) = $$FR_MATCHCASE THEN findFlags = findFlags OR $$SCFIND_MATCHCASE
				IF (fr.flags AND $$FR_WHOLEWORD) = $$FR_WHOLEWORD THEN findFlags = findFlags OR $$SCFIND_WHOLEWORD
				' Begin to search from the beginning
				endPos = SendMessageA (hSci, $$SCI_GETTEXTLENGTH, 0, 0)
				' Reset counter and starting position
				numItems = 0
				startPos = 0
				fInSelection = 0
				' If startSelPos and endSelPos are the same there is not a selection,
				' so begin replacing at the current position.
				' otherwise make the changes only in the selected text
				startSelPos = SendMessageA (hSci, $$SCI_GETSELECTIONSTART, 0, 0)
				endSelPos = SendMessageA (hSci, $$SCI_GETSELECTIONEND, 0, 0)
				IF endSelPos > startSelPos THEN
					startPos = startSelPos
					endPos = endSelPos
					fInSelection = $$TRUE
				END IF
				IF endSelPos = startSelPos THEN startPos = startSelPos

				szFindText$ = CSTRING$ (fr.lpstrFindWhat)
				szReplText$ = CSTRING$ (fr.lpstrReplaceWith)

				' empty replace string should be able to remove find text (delete it)
				IFZ szFindText$ THEN RETURN

				' update mru lists for comboboxes in find/replace dialog
				find$ = szFindText$
				replace$ = szReplText$
				GOSUB UpdateFR

				IFZ szReplText$ THEN szReplText$ = NULL$ (1)

				DO
					' Set the find flags and the starting and ending positions
					SendMessageA (hSci, $$SCI_SETSEARCHFLAGS, findFlags, 0)
					SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos, 0)
					SendMessageA (hSci, $$SCI_SETTARGETEND, endPos, 0)
					' Search for the text to replace
					hr = SendMessageA (hSci, $$SCI_SEARCHINTARGET, LEN (szFindText$), &szFindText$)
					' Store the position
					curPos = hr
					' If hr = -1 there are no more text to replace
					IF hr = -1 THEN
						text$ = STRING$ (numItems) + " replacements  "
						MessageBoxA (hFind, &text$, &" Replace all", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
						EXIT DO
					ELSE
						' Replace the text
						SendMessageA (hSci, $$SCI_REPLACETARGET, -1, &szReplText$)
						' Increase the counter
						INC numItems
					END IF
					' Calculate the new start position
					startPos = curPos + LEN (szReplText$)
					' Calculate the new end position (the length of the text may have changed)
					IF fInSelection THEN
						endPos = SendMessageA (hSci, $$SCI_GETSELECTIONEND, 0, 0)
					ELSE
						endPos = SendMessageA (hSci, $$SCI_GETTEXTLENGTH, 0, 0)
					END IF
					IF endPos <= startPos THEN
						text$ = STRING$ (numItems) + " replacements  "
						MessageBoxA (hFind, &text$, &" Replace all", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
						EXIT DO
					END IF
				LOOP
		END SELECT
	END IF

SUB UpdateFR
	' update mru lists for comboboxes in find/replace dialog
	IF find$ THEN
		fUnique = $$TRUE
		upp = UBOUND(find$[])
		FOR i = 0 TO upp
			IF find$ = find$[i] THEN
				fUnique = $$FALSE
				EXIT FOR
			END IF
		NEXT i
		IF fUnique THEN
			REDIM find$[findCount]
			find$[findCount] = find$
			INC findCount
		END IF
	END IF

	IF replace$ THEN
		fUnique = $$TRUE
		upp = UBOUND(replace$[])
		FOR i = 0 TO upp
			IF replace$ = replace$[i] THEN
				fUnique = $$FALSE
				EXIT FOR
			END IF
		NEXT i
		IF fUnique THEN
			REDIM replace$[replaceCount]
			replace$[replaceCount] = replace$
			INC replaceCount
		END IF
	END IF
END SUB


END FUNCTION
'
' #############################
' #####  FindUpOrDown ()  #####
' #############################
'
' Forward or backward search
'
FUNCTION FindUpOrDown ()

	SHARED szFindText$		' Text to search
	SHARED startPos				' Starting position
	SHARED endPos					' Ending position
	SHARED curPos					' Current position
	SHARED findFlags			' Find flags
	SHARED updown					' Search direction

' if text is highlighted, then use it as search text
	hSci = GetEdit ()
	IFZ hSci THEN RETURN

	start = SendMessageA (hSci, $$SCI_GETSELECTIONSTART, 0, 0)
	end = SendMessageA (hSci, $$SCI_GETSELECTIONEND, 0, 0)
	IF end > start THEN
		buffer$ = NULL$ (end - start + 1)
		SendMessageA (hSci, $$SCI_GETSELTEXT, 0, &buffer$)
		buffer$ = CSIZE$ (buffer$)
		IF buffer$ THEN
			IF INSTR (buffer$, CHR$ (13)) = 0 && INSTR (buffer$, CHR$ (10)) = 0 THEN
				szFindText$ = buffer$ ' + NULL$ (255 - LEN (buffer$))
			END IF
		END IF
	END IF

	IF szFindText$ THEN
		' Begin to search from the current position
		curPos = SendMessageA (hSci, $$SCI_GETCURRENTPOS, 0, 0)
		IF startPos <> curPos THEN
			IF updown = $$FR_DOWN THEN
				startPos = curPos
			ELSE
				IF curPos < startPos THEN startPos = curPos
				IF startPos = 0 THEN startPos = curPos
			END IF
		END IF
		' For backward searches the end position must be less than the start position
		endPos = SendMessageA (hSci, $$SCI_GETTEXTLENGTH, 0, 0)
		IF updown <> $$FR_DOWN THEN
			endPos = 0		' Search backwards
			SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos - 1, 0)
		ELSE
			IF startPos = 0 THEN
				SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos, 0)
			ELSE
				SendMessageA (hSci, $$SCI_SETTARGETSTART, startPos + 1, 0)
			END IF
		END IF
		' Set the end position and the find flags
		SendMessageA (hSci, $$SCI_SETTARGETEND, endPos, 0)
		SendMessageA (hSci, $$SCI_SETSEARCHFLAGS, findFlags, 0)
		' Search for the text to find
		hr = SendMessageA (hSci, $$SCI_SEARCHINTARGET, LEN (szFindText$), &szFindText$)
		IF hr = -1 THEN
			MessageBoxA (hFind, &"No match found   ", &" Find Next", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		ELSE
			' Position the caret and select the text
			SendMessageA (hSci, $$SCI_SETCURRENTPOS, hr, 0)
			SendMessageA (hSci, $$SCI_GOTOPOS, hr, 0)
			SendMessageA (hSci, $$SCI_SETSELECTIONSTART, hr, 0)
			SendMessageA (hSci, $$SCI_SETSELECTIONEND, hr + LEN (szFindText$), 0)
			' Increase the position
			startPos = hr
		END IF
	END IF
END FUNCTION
'
' ########################################
' #####  ShowGotoLinePopupDialog ()  #####
' ########################################
'
' Go to line popup dialog
'
FUNCTION ShowGotoLinePopupDialog (hParent)

	RECT rc
	WNDCLASSEX wc
	SHARED hInst
	MSG msg

	curPos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
	nLine = SendMessageA (GetEdit (), $$SCI_LINEFROMPOSITION, curPos, 0) + 1
	nLines = SendMessageA (GetEdit (), $$SCI_GETLINECOUNT, 0, 0)

	hFnt = GetStockObject ($$ANSI_VAR_FONT)

	szClassName$ = "GotoLine"
	wc.cbSize = SIZE (wc)
	wc.style = $$CS_HREDRAW OR $$CS_VREDRAW
	wc.lpfnWndProc = &GotoLinePopupDlgProc ()
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = hInst
	wc.hCursor = LoadCursorA (NULL, $$IDC_ARROW)
	wc.hbrBackground = $$COLOR_3DFACE + 1
	wc.lpszMenuName = NULL
	wc.lpszClassName = &szClassName$
	wc.hIcon = 0
	wc.hIconSm = 0
	RegisterClassExA (&wc)

	GetWindowRect (hParent, &rc)		' for centering child in parent
	rc.right = rc.right - rc.left		' parent's width
	rc.bottom = rc.bottom - rc.top		' parent's height

	hDlg = CreateWindowExA ($$WS_EX_DLGMODALFRAME OR $$WS_EX_CONTROLPARENT, &szClassName$, &"Go to line", $$WS_CAPTION OR $$WS_POPUPWINDOW OR $$WS_VISIBLE, rc.left + (rc.right - 261) / 2, rc.top + (rc.bottom - 123) / 2, 261, 123, hParent, 0, hInst, NULL)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Static", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$SS_ETCHEDFRAME, 15, 13, 135, 68, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Static", &"Last Line :", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_GROUP OR $$SS_RIGHT, 18, 20, 68, 13, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Static", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_GROUP OR $$SS_RIGHT, 90, 20, 48, 13, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	txt$ = STRING$ (nLines)
	SetWindowTextA (hCtl, &txt$)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Static", &"Current Line :", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_GROUP OR $$SS_RIGHT, 18, 37, 68, 13, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Static", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_GROUP OR $$SS_RIGHT, 90, 37, 48, 13, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	txt$ = STRING$ (nLine)
	SetWindowTextA (hCtl, &txt$)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Static", &"&Go to Line :", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_GROUP OR $$SS_RIGHT, 18, 57, 68, 13, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE OR $$WS_EX_NOPARENTNOTIFY, &"Edit", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_GROUP OR $$WS_TABSTOP OR $$ES_NUMBER OR $$ES_AUTOHSCROLL, 90, 55, 51, 20, hDlg, 100, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	s$ = STRING$ (nLines)
	limit = LEN (s$)
	SendMessageA (hCtl, $$EM_LIMITTEXT, limit, 0)
	SetFocus (hCtl)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Button", &"&Ok", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_DISABLED OR $$WS_TABSTOP OR $$BS_DEFPUSHBUTTON, 165, 13, 75, 23, hDlg, $$IDOK, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_NOPARENTNOTIFY, &"Button", &"&Cancel", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP, 165, 41, 75, 23, hDlg, $$IDCANCEL, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	ShowWindow (hDlg, $$SW_SHOW)
	UpdateWindow (hDlg)

	DO WHILE GetMessageA (&msg, NULL, 0, 0)
		IFZ IsDialogMessageA (hDlg, &msg) THEN
			TranslateMessage (&msg)
			DispatchMessageA (&msg)
		END IF
	LOOP

	RETURN msg.wParam

END FUNCTION
'
' #####################################
' #####  GotoLinePopupDlgProc ()  #####
' #####################################
'
' GotoLine Popup dialog procedure
'
FUNCTION GotoLinePopupDlgProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg
		CASE $$WM_CREATE :		' Entrance
			EnableWindow (GetParent (hWnd), $$FALSE)		' To make popup dialog modal

		CASE $$WM_COMMAND :
			SELECT CASE LOWORD (wParam)
				CASE $$IDCANCEL :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						EXIT FUNCTION
					END IF
				CASE $$IDOK :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						szBuffer$ = GetWindowText$ (GetDlgItem (hWnd, 100))
						nLine = XLONG (szBuffer$) - 1
						SendMessageA (GetEdit (), $$SCI_GOTOLINE, nLine, 0)
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						EXIT FUNCTION
					END IF
				CASE 100 :		' Go to line edit control
					IF HIWORD (wParam) = $$EN_CHANGE THEN
						szBuffer$ = GetWindowText$ (GetDlgItem (hWnd, 100))
						IF szBuffer$ THEN
							IF XLONG (szBuffer$) > SendMessageA (GetEdit (), $$SCI_GETLINECOUNT, 0, 0) THEN
								EnableWindow (GetDlgItem (hWnd, $$IDOK), $$FALSE)
							ELSE
								EnableWindow (GetDlgItem (hWnd, $$IDOK), $$TRUE)
							END IF
						ELSE
							EnableWindow (GetDlgItem (hWnd, $$IDOK), $$FALSE)
						END IF
					END IF
			END SELECT

		CASE $$WM_CLOSE :
			EnableWindow (GetParent (hWnd), $$TRUE)		' Maintains parent's zorder

		CASE $$WM_DESTROY :		' Exit
			PostQuitMessage (0)
			EXIT FUNCTION

	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
' ###############################
' #####  GetCurrentLine ()  #####
' ###############################
'
' Retrieves the line number at the caret position
'
FUNCTION GetCurrentLine ()

	SHARED curPos

	hSci = GetEdit ()
	curPos = SendMessageA (hSci, $$SCI_GETCURRENTPOS, 0, 0)
	RETURN SendMessageA (hSci, $$SCI_LINEFROMPOSITION, curPos, 0)
END FUNCTION
'
' ######################################
' #####  ToggleAllFoldersBelow ()  #####
' ######################################
'
' Toggle all functions and procedures below
'
FUNCTION ToggleAllFoldersBelow (LineNumber)

	hSci = GetEdit ()
	' Get direct pointer for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN EXIT FUNCTION
	' Force the lexer to style the whole document
	' SciMsg (pSci, $$SCI_COLOURISE, 0, -1)
	' Toggle the first sub or function
	LineNumber = ToggleFolding (LineNumber)
	' Determine wether the fold is expanded or not
	FoldState = SciMsg (pSci, $$SCI_GETFOLDEXPANDED, LineNumber, 0)
	' Toggle the rest of functions/procedures
	LineCount = SciMsg (pSci, $$SCI_GETLINECOUNT, 0, 0)		' Number of lines
	SetCursor (LoadCursorA (NULL, $$IDC_APPSTARTING))		' Show hourglass mouse
	FOR i = LineNumber TO LineCount
		IF (SciMsg (pSci, $$SCI_GETFOLDLEVEL, i, 0) AND $$SC_FOLDLEVELHEADERFLAG) THEN		' If we are in the head line ...
			IF SciMsg (pSci, $$SCI_GETFOLDEXPANDED, i, 0) <> FoldState THEN		' If the state is different ...
				SciMsg (pSci, $$SCI_TOGGLEFOLD, i, 0)		' Toggle it
			END IF
		END IF
	NEXT i
	SetCursor (LoadCursorA (NULL, $$IDC_ARROW))		' Show standard mouse
END FUNCTION
'
' ##################################
' #####  FoldAllProcedures ()  #####
' ##################################
'
' Folds all functions and procedures
'
FUNCTION FoldAllProcedures ()

	hSci = GetEdit ()
	' Get direct pointer for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN EXIT FUNCTION
	' Force the lexer to style the whole document
	' SciMsg (pSci, $$SCI_COLOURISE, 0, -1)
	LineCount = SciMsg (pSci, $$SCI_GETLINECOUNT, 0, 0)		' Number of lines
	SetCursor (LoadCursorA (NULL, $$IDC_APPSTARTING))		' Show hourglass mouse
	FOR i = 0 TO LineCount
		IF (SciMsg (pSci, $$SCI_GETFOLDLEVEL, i, 0) AND $$SC_FOLDLEVELHEADERFLAG) THEN		' If we are in the head line ...
			IF SciMsg (pSci, $$SCI_GETFOLDEXPANDED, i, 0) THEN		' If it is expanded...
				SciMsg (pSci, $$SCI_TOGGLEFOLD, i, 0)		' fold it
			END IF
		END IF
	NEXT
	SetCursor (LoadCursorA (NULL, $$IDC_ARROW))		' Show standard mouse
END FUNCTION
'
' ####################################
' #####  ExpandAllProcedures ()  #####
' ####################################
'
' Expands all functions and procedures
'
FUNCTION ExpandAllProcedures ()

	hSci = GetEdit ()
	' Get direct pointer for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN EXIT FUNCTION
	' Force the lexer to style the whole document
	' SciMsg (pSci, $$SCI_COLOURISE, 0, -1)
	LineCount = SciMsg (pSci, $$SCI_GETLINECOUNT, 0, 0)		' Number of lines
	SetCursor (LoadCursorA (NULL, $$IDC_APPSTARTING))		' Show hourglass mouse
	FOR i = 1 TO LineCount
		IF (SciMsg (pSci, $$SCI_GETFOLDLEVEL, i, 0) AND $$SC_FOLDLEVELHEADERFLAG) THEN		' If we are in the head line ...
			IFZ SciMsg (pSci, $$SCI_GETFOLDEXPANDED, i, 0) THEN		' If it is not expanded...
				SciMsg (pSci, $$SCI_TOGGLEFOLD, i, 0)		' expand it
			END IF
		END IF
	NEXT
	SetCursor (LoadCursorA (NULL, $$IDC_ARROW))		' Show standard mouse
END FUNCTION
'
' ###########################
' #####  FoldXBLDoc ()  #####
' ###########################
'
' Set folding points for FUNCTION/END FUNCTION lines.
'
FUNCTION FoldXBLDoc (hEdit, start, finish, lineNumber)

	TEXTRANGE tr
	SHARED fFoldingOn

	IFZ fFoldingOn THEN RETURN

	' Get direct pointer for faster access
	pSci = SendMessageA (hEdit, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN RETURN

	' PRINT "FoldXBLDoc: start="; start, "end="; end, "lineNumber="; lineNumber

	lengthDoc = SciMsg (pSci, $$SCI_GETLENGTH, 0, 0)
	IFZ lengthDoc THEN RETURN

	IF (finish == -1) THEN finish = lengthDoc
	length = finish - start
	' PRINT "FoldXBLDoc: length="; length, "lengthDoc="; lengthDoc

	doc$ = NULL$ (length)
	tr.chrg.cpMin = start
	tr.chrg.cpMax = finish
	tr.lpstrText = &doc$
	SciMsg (pSci, $$SCI_GETTEXTRANGE, 0, &tr)

	lineCurrent = lineNumber
	levelCurrent = $$SC_FOLDLEVELBASE
	IF (lineCurrent > 0) THEN
		levelCurrent = SciMsg (pSci, $$SCI_GETFOLDLEVEL, lineCurrent - 1, 0) >> 16
	END IF
	levelNext = levelCurrent
	chNext = doc${0}

	styleNext = SciMsg (pSci, $$SCI_GETSTYLEAT, start, 0)
	style = initStyle

	visibleChars = 0

	FOR i = 0 TO length - 1
		ch = chNext
		chNext = ' '
		style = styleNext
		styleNext = 0
		IF (i + 1 < length) THEN
			chNext = doc${i + 1}
			styleNext = SciMsg (pSci, $$SCI_GETSTYLEAT, i + 1, 0)
		END IF

		IF style = $$SCE_B_KEYWORD THEN
			SELECT CASE ch
				CASE 'F', 'C' :
					IF (ch = 'F' && chNext = 'U') || (ch = 'C' && chNext = 'F') THEN
						GOSUB GetLine
						IF firstWord$ = "FUNCTION" || firstWord$ = "CFUNCTION" THEN IncLevelNext = $$TRUE
					ELSE
						IF ch = 'F' && chNext = 'O' THEN
							GOSUB GetLine
							IF firstWord$ = "FOR" THEN
								IFZ INSTR (line$, "NEXT") THEN IncLevelNext = $$TRUE
							END IF
						END IF
					END IF
				CASE 'E' :
					IF chNext = 'N' THEN
						GOSUB GetLine
						IF firstWord$ = "END" THEN
							SELECT CASE secondWord$
								CASE "FUNCTION", "SELECT", "SUB" : DecLevelNext = $$TRUE
							END SELECT
						END IF
					END IF
				CASE 'D' :
					IF chNext = 'O' THEN
						GOSUB GetLine
						SELECT CASE firstWord$
							CASE "DOUBLE" :
							CASE "DO" :
								SELECT CASE secondWord$
									CASE "DO", "LOOP", "FOR", "NEXT" :
									CASE ELSE : IncLevelNext = $$TRUE
								END SELECT
						END SELECT
					END IF
				CASE 'L' :
					IF chNext = 'O' THEN
						GOSUB GetLine
						IF firstWord$ = "LOOP" THEN DecLevelNext = $$TRUE
					END IF
				CASE 'N' :
					IF chNext = 'E' THEN
						GOSUB GetLine
						IF firstWord$ = "NEXT" THEN DecLevelNext = $$TRUE
					END IF
				CASE 'S' :
					IF chNext = 'U' THEN
						GOSUB GetLine
						IF firstWord$ = "SUB" THEN IncLevelNext = $$TRUE
					ELSE
						IF chNext = 'E' THEN
							GOSUB GetLine
							IF firstWord$ = "SELECT" THEN IncLevelNext = $$TRUE
						END IF
					END IF
			END SELECT
		END IF

		atEOL = (ch == '\r' && chNext != '\n') || (ch == '\n')

		IF atEOL THEN
			IF IncLevelNext THEN INC levelNext
			IF DecLevelNext THEN DEC levelNext
			levelUse = levelCurrent
			lev = levelUse | levelNext << 16
			IFZ visibleChars THEN lev = lev | $$SC_FOLDLEVELWHITEFLAG

			IF (levelUse < levelNext) THEN
				lev = lev | $$SC_FOLDLEVELHEADERFLAG
			END IF

			levC = SciMsg (pSci, $$SCI_GETFOLDLEVEL, lineCurrent, 0)
			IF (lev != levC) THEN
				SciMsg (pSci, $$SCI_SETFOLDLEVEL, lineCurrent, lev)
			END IF

			INC lineCurrent
			levelCurrent = levelNext
			IncLevelNext = 0
			DecLevelNext = 0
			visibleChars = 0
		END IF

		IF (!IsSpaceChar (ch)) THEN INC visibleChars

	NEXT i

SUB GetLine
	bytes = SciMsg (pSci, $$SCI_GETLINE, lineCurrent, 0)
	line$ = NULL$ (bytes)
	SciMsg (pSci, $$SCI_GETLINE, lineCurrent, &line$)
	line$ = LTRIM$ (line$)
	index = 0
	done = 0
	firstWord$ = XstNextField$ (line$, @index, @done)
	' check for GOTO tag which ends in :
	p = LEN(firstWord$)-1
	IF firstWord${p} = ':' THEN ' skip it, find next word
		firstWord$ = XstNextField$ (line$, @index, @done)
	END IF
	secondWord$ = XstNextField$ (line$, @index, @done)
END SUB

END FUNCTION
'
' ##################################
' #####  GetFoldingOptions ()  #####
' ##################################
'
' Reads the Folding options from the .INI file
'
FUNCTION GetFoldingOptions (FoldingOptionsType FoldOpt)

	SHARED IniFile$
	SHARED fFoldingOn

	rs$ = IniRead (IniFile$, "Folding options", "FoldingLevel", "")
	IF rs$ THEN FoldOpt.FoldingLevel = XLONG (rs$) ELSE FoldOpt.FoldingLevel = 0
	IF FoldOpt.FoldingLevel THEN fFoldingOn = $$TRUE

	rs$ = IniRead (IniFile$, "Folding options", "FoldingSymbol", "")
	IF rs$ THEN FoldOpt.FoldingSymbol = XLONG (rs$) ELSE FoldOpt.FoldingSymbol = 4

END FUNCTION
'
' ####################################
' #####  WriteFoldingOptions ()  #####
' ####################################
'
' Writes the Folding options to the .INI file
'
FUNCTION WriteFoldingOptions (FoldingOptionsType FoldOpt)

	SHARED IniFile$

	IniWrite (IniFile$, "Folding options", "FoldingLevel", STRING$ (FoldOpt.FoldingLevel))
	IniWrite (IniFile$, "Folding options", "FoldingSymbol", STRING$ (FoldOpt.FoldingSymbol))

END FUNCTION
'
' ##########################################
' #####  SED_ReplaceSpacesWithTabs ()  #####
' ##########################################
'
' Replace spaces with tabs
'
FUNCTION SED_ReplaceSpacesWithTabs ()

	$TAB = "\t"

	LineNumber = GetCurrentLine ()
	TabSize = SendMessageA (GetEdit (), $$SCI_GETTABWIDTH, 0, 0)
	IF TabSize < 1 THEN EXIT FUNCTION
	nLen = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
	Buffer$ = NULL$ (nLen + 1)
	SendMessageA (GetEdit (), $$SCI_GETTEXT, LEN (Buffer$), &Buffer$)
	Buffer$ = CSIZE$ (Buffer$)
	XstReplace (@Buffer$, SPACE$ (TabSize), $TAB, 0)
	SendMessageA (GetEdit (), $$SCI_SETTEXT, 0, &Buffer$)
	SendMessageA (GetEdit (), $$SCI_GOTOLINE, LineNumber, 0)		' Set the caret position

END FUNCTION
'
' ##########################################
' #####  SED_ReplaceTabsWithSpaces ()  #####
' ##########################################
'
' Replace tabs with spaces
'
FUNCTION SED_ReplaceTabsWithSpaces ()

	$TAB = "\t"

	LineNumber = GetCurrentLine ()
	TabSize = SendMessageA (GetEdit (), $$SCI_GETTABWIDTH, 0, 0)
	IF TabSize < 1 THEN EXIT FUNCTION
	nLen = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
	Buffer$ = NULL$ (nLen + 1)
	SendMessageA (GetEdit (), $$SCI_GETTEXT, LEN (Buffer$), &Buffer$)
	Buffer$ = CSIZE$ (Buffer$)
	XstReplace (@Buffer$, $TAB, SPACE$ (TabSize), 0)
	SendMessageA (GetEdit (), $$SCI_SETTEXT, 0, &Buffer$)
	SendMessageA (GetEdit (), $$SCI_GOTOLINE, LineNumber, 0)		' Set the caret position

END FUNCTION
'
' ###################################
' #####  EnsureRangeVisible ()  #####
' ###################################
'
' Ensure that a range of lines that is currently
' invisible should be made visible
'
FUNCTION EnsureRangeVisible (posStart, posEnd, fEnforcePolicy)
	start = MIN (posStart, posEnd)
	end = MAX (posStart, posEnd)
	lineStart = SendMessageA (GetEdit (), $$SCI_LINEFROMPOSITION, start, 0)
	lineEnd = SendMessageA (GetEdit (), $$SCI_LINEFROMPOSITION, end, 0)
	IF fEnforcePolicy THEN
		msg = $$SCI_ENSUREVISIBLEENFORCEPOLICY
	ELSE
		msg = $$SCI_ENSUREVISIBLE
	END IF
	FOR line = lineStart TO lineEnd
		SendMessageA (GetEdit (), msg, line, 0)
	NEXT line
END FUNCTION
'
' ############################
' #####  FoldChanged ()  #####
' ############################
'
FUNCTION FoldChanged (line, levelNow, levelPrev)

	IF (levelNow & $$SC_FOLDLEVELHEADERFLAG) THEN
		IF (!(levelPrev & $$SC_FOLDLEVELHEADERFLAG)) THEN
			SendMessageA (GetEdit (), $$SCI_SETFOLDEXPANDED, line, 1)
		END IF
	ELSE
		IF (levelPrev & $$SC_FOLDLEVELHEADERFLAG) THEN
			IF !SendMessageA (GetEdit (), $$SCI_GETFOLDEXPANDED, line, 0) THEN
				' Removing the fold from one that has been contracted so should expand
				' otherwise lines are left invisible with no way to make them visible
				Expand (line, $$TRUE, $$FALSE, 0, levelPrev)
			END IF
		END IF
	END IF

END FUNCTION
'
' #######################
' #####  Expand ()  #####
' #######################
'
FUNCTION Expand (line, doExpand, force, visLevels, level)

	lineMaxSubord = SendMessageA (GetEdit (), $$SCI_GETLASTCHILD, line, level & $$SC_FOLDLEVELNUMBERMASK)
	INC line
	DO WHILE (line <= lineMaxSubord)
		IF (force) THEN
			IF (visLevels > 0) THEN
				SendMessageA (GetEdit (), $$SCI_SHOWLINES, line, line)
			ELSE
				SendMessageA (GetEdit (), $$SCI_HIDELINES, line, line)
			END IF
		ELSE
			IF (doExpand) THEN
				SendMessageA (GetEdit (), $$SCI_SHOWLINES, line, line)
			END IF
		END IF
		levelLine = level
		IF (levelLine == -1) THEN
			levelLine = SendMessageA (GetEdit (), $$SCI_GETFOLDLEVEL, line, 0)
		END IF
		IF (levelLine & $$SC_FOLDLEVELHEADERFLAG) THEN
			IF (force) THEN
				IF (visLevels > 1) THEN
					SendMessageA (GetEdit (), $$SCI_SETFOLDEXPANDED, line, 1)
				ELSE
					SendMessageA (GetEdit (), $$SCI_SETFOLDEXPANDED, line, 0)
				END IF
				Expand (line, doExpand, force, visLevels - 1, level)
			ELSE
				IF (doExpand) THEN
					IF !SendMessageA (GetEdit (), $$SCI_GETFOLDEXPANDED, line, 0) THEN
						SendMessageA (GetEdit (), $$SCI_SETFOLDEXPANDED, line, 1)
					END IF
					Expand (line, true, force, visLevels - 1, level)
				ELSE
					Expand (line, false, force, visLevels - 1, level)
				END IF
			END IF
		ELSE
			INC line
		END IF
	LOOP
END FUNCTION
'
' ###########################
' #####  MdiCascade ()  #####
' ###########################
'
' Cascade all open Mdi windows
'
FUNCTION MdiCascade (hClient)
	RETURN SendMessageA (hClient, $$WM_MDICASCADE, 0, 0)
END FUNCTION
'
' ########################
' #####  MdiTile ()  #####
' ########################
'
' Tile all open Mdi windows either
' vertically (How = 1) or horizontally (How = 0)
'
FUNCTION MdiTile (hClient, How)
	IFZ (How) THEN
		How = $$MDITILE_VERTICAL
	END IF
	RETURN SendMessageA (hClient, $$WM_MDITILE, How, 0)
END FUNCTION
'
' ###############################
' #####  MdiIconArrange ()  #####
' ###############################
'
' Arrange Mdi icons
'
FUNCTION MdiIconArrange (hClient)
	RETURN SendMessageA (hClient, $$WM_MDIICONARRANGE, 0, 0)
END FUNCTION
'
' #############################################
' #####  RestoreMainWindowDefaultSize ()  #####
' #############################################
'
' Restores the main window default size
'
FUNCTION RestoreMainWindowDefaultSize (hWnd)

	RECT rc
	' Retrieve the size of the working area
	SystemParametersInfoA ($$SPI_GETWORKAREA, 0, &rc, 0)
	' Resize the window
	RETURN MoveWindow (hWnd, rc.left, rc.top, rc.right - rc.left + 2, rc.bottom - rc.top + 2, $$TRUE)
END FUNCTION
'
' ##################################
' #####  ShowEditorOptions ()  #####
' ##################################
'
' Editor Options popup dialog
'
FUNCTION ShowEditorOptions (hParent)

	RECT rc
	WNDCLASSEX wc
	EditorOptionsType EdOpt
	SHARED hInst
	MSG msg

	hFnt = GetStockObject ($$ANSI_VAR_FONT)

	szClassName$ = "Editor_Options"
	wc.cbSize = SIZE (wc)
	wc.style = $$CS_HREDRAW OR $$CS_VREDRAW
	wc.lpfnWndProc = &EditorOptionsDlgProc ()
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = hInst
	wc.hCursor = LoadCursorA (NULL, $$IDC_ARROW)
	wc.hbrBackground = $$COLOR_3DFACE + 1
	wc.lpszMenuName = NULL
	wc.lpszClassName = &szClassName$
	wc.hIcon = 0
	wc.hIconSm = 0
	RegisterClassExA (&wc)

	GetWindowRect (hParent, &rc)		' for centering child in parent
	rc.right = rc.right - rc.left		' parent's width
	rc.bottom = rc.bottom - rc.top		' parent's height

	x = rc.left + (rc.right - 390) / 2
	IF x < 0 THEN x = 10
	y = rc.top + (rc.bottom - 566) / 2
	IF y < 0 THEN y = 10
	hDlg = CreateWindowExA ($$WS_EX_DLGMODALFRAME OR $$WS_EX_CONTROLPARENT, &szClassName$, &"Editor options", $$WS_CAPTION OR $$WS_POPUPWINDOW OR $$WS_VISIBLE, x, y, 390, 466, hParent, 0, hInst, NULL)

	hCtl = CreateWindowExA (0, &"Button", &"Edit preferences", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 15, 8, 354, 376, hDlg, 0, hInst, NULL)

	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	SetFocus (hCtl)

	hCtl = CreateWindowExA (0, &"Button", &"Use &tabs", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 33, 150, 16, hDlg, $$IDCO_USETABS, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Tab size", $$WS_CHILD OR $$WS_VISIBLE, 212, 33, 54, 16, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"ComboBox", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$CBS_DROPDOWNLIST OR $$CBS_HASSTRINGS OR $$CBS_DISABLENOSCROLL, 282, 31, 42, 160, hDlg, $$IDCO_CBTABSIZE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	FOR i = 0 TO 8
		Combo_AddString (hCtl, STRING$ (i))
	NEXT

	hCtl = CreateWindowExA (0, &"Button", &"&Auto indentation", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 57, 150, 16, hDlg, $$IDCO_AUTOINDENT, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Indent size", $$WS_CHILD OR $$WS_VISIBLE, 212, 57, 54, 16, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"ComboBox", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$CBS_DROPDOWNLIST OR $$CBS_HASSTRINGS OR $$CBS_DISABLENOSCROLL, 282, 55, 42, 160, hDlg, $$IDCO_CBINDENTSIZE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	FOR i = 0 TO 8
		Combo_AddString (hCtl, STRING$ (i))
	NEXT

	hCtl = CreateWindowExA (0, &"Button", &"&Line numbers", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 81, 150, 16, hDlg, $$IDCO_LINENUMBERS, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Width", $$WS_CHILD OR $$WS_VISIBLE, 212, 81, 54, 16, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"Edit", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$ES_RIGHT OR $$ES_NUMBER OR $$ES_AUTOHSCROLL, 282, 79, 40, 21, hDlg, $$IDCO_LINENUMBERSWIDTH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	SendMessageA (hCtl, $$EM_LIMITTEXT, 3, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Margin", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 104, 150, 16, hDlg, $$IDCO_MARGIN, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Width", $$WS_CHILD OR $$WS_VISIBLE, 212, 104, 54, 16, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"Edit", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$ES_RIGHT OR $$ES_NUMBER OR $$ES_AUTOHSCROLL, 282, 102, 40, 21, hDlg, $$IDCO_MARGINWIDTH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	SendMessageA (hCtl, $$EM_LIMITTEXT, 2, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Ed&ge column", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 128, 150, 17, hDlg, $$IDCO_EDGECOLUMN, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Edge", $$WS_CHILD OR $$WS_VISIBLE, 212, 128, 54, 16, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"Edit", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$ES_RIGHT OR $$ES_NUMBER OR $$ES_AUTOHSCROLL, 282, 126, 40, 21, hDlg, $$IDCO_EDGEWIDTH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	SendMessageA (hCtl, $$EM_LIMITTEXT, 3, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Indentation guides", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 152, 150, 17, hDlg, $$IDCO_INDENTGUIDES, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Magnification", $$WS_CHILD OR $$WS_VISIBLE, 212, 152, 150, 16, hDlg, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"Edit", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$ES_LEFT, 282, 152, 25, 20, hDlg, $$IDCO_BUDDY, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	SetDlgItemInt (hDlg, $$IDCO_BUDDY, 0, $$FALSE)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"msctls_updown32", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_BORDER OR $$UDS_WRAP OR $$UDS_ARROWKEYS OR $$UDS_ALIGNRIGHT OR $$UDS_SETBUDDYINT, 306, 152, 10, 20, hDlg, $$IDCO_MAGNIFICATION, hInst, NULL)
	' Set the base
	SendMessageA (hCtl, $$UDM_SETBASE, 1, 0)
	' Set the range
	SendMessageA (hCtl, $$UDM_SETRANGE, 0, MAKELONG (20, - 10))
	' Set the initial value
	SendMessageA (hCtl, $$UDM_SETPOS, 0, 0)
	' Set the buddy control
	SendMessageA (hCtl, $$UDM_SETBUDDY, GetDlgItem (hDlg, $$IDCO_BUDDY), 0)
	' Correct for Windows using a default size for the updown control
	SetWindowPos (hCtl, NULL, 306, 152, 18, 20, $$SWP_NOZORDER)
	' Correct for the auto-resizing of the buddy control
	SetWindowPos (GetDlgItem (hDlg, $$IDCO_BUDDY), NULL, 282, 152, 25, 20, $$SWP_NOZORDER)

	hCtl = CreateWindowExA (0, &"Button", &"&Whitespace", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 176, 150, 16, hDlg, $$IDCO_WHITESPACE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&End of line", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 212, 176, 150, 16, hDlg, $$IDCO_ENDOFLINE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Color syntax &highlighting", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 198, 150, 16, hDlg, $$IDCO_SYNTAXHIGH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Auto uppercase keywords", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 212, 198, 150, 16, hDlg, $$IDCO_UPPERCASEKEYWORDS, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Ma&ximize main window", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 220, 150, 16, hDlg, $$IDCO_MAXMAINWINDOW, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Maximi&ze edit windows", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 212, 220, 150, 16, hDlg, $$IDCO_MAXEDITWINDOWS, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"As&k before exiting the editor", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 242, 150, 16, hDlg, $$IDCO_ASKBEFOREEXIT, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Allow m&ultiple instances", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 212, 242, 150, 16, hDlg, $$IDCO_ALLOWMULTINST, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Trim trailing spaces and tabs", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 264, 160, 16, hDlg, $$IDCO_TRIMTRAILBLANKS, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Show function name", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 212, 264, 150, 16, hDlg, $$IDCO_SHOWPROCNAME, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Show caret line", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 286, 150, 16, hDlg, $$IDCO_SHOWCARETLINE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Start in last folder", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 212, 286, 150, 16, hDlg, $$IDCO_STARTINLASTFOLDER, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Reload previous file set at start", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 33, 308, 165, 16, hDlg, $$IDCO_RELOADFILESATSTARTUP, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Backup editor files", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 212, 308, 155, 16, hDlg, $$IDCO_BACKUPEDITORFILES, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Ok", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 121, 400, 75, 23, hDlg, $$IDOK, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Cancel", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 207, 400, 75, 23, hDlg, $$IDCANCEL, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Help", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 293, 400, 75, 23, hDlg, $$IDBO_EDITOR_HELP, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	GetEditorOptions (@EdOpt)

	CheckDlgButton (hDlg, $$IDCO_USETABS, EdOpt.UseTabs)
	Combo_SetCurSel (GetDlgItem (hDlg, $$IDCO_CBTABSIZE), EdOpt.TabSize)
	CheckDlgButton (hDlg, $$IDCO_AUTOINDENT, EdOpt.AutoIndent)
	Combo_SetCurSel (GetDlgItem (hDlg, $$IDCO_CBINDENTSIZE), EdOpt.IndentSize)
	CheckDlgButton (hDlg, $$IDCO_LINENUMBERS, EdOpt.LineNumbers)
	txt$ = STRING$ (EdOpt.LineNumbersWidth)
	SetWindowTextA (GetDlgItem (hDlg, $$IDCO_LINENUMBERSWIDTH), &txt$)
	CheckDlgButton (hDlg, $$IDCO_MARGIN, EdOpt.Margin)
	txt$ = STRING$ (EdOpt.MarginWidth)
	SetWindowTextA (GetDlgItem (hDlg, $$IDCO_MARGINWIDTH), &txt$)
	CheckDlgButton (hDlg, $$IDCO_EDGECOLUMN, EdOpt.EdgeColumn)
	txt$ = STRING$ (EdOpt.EdgeWidth)
	SetWindowTextA (GetDlgItem (hDlg, $$IDCO_EDGEWIDTH), &txt$)
	CheckDlgButton (hDlg, $$IDCO_INDENTGUIDES, EdOpt.IndentGuides)
	CheckDlgButton (hDlg, $$IDCO_WHITESPACE, EdOpt.WhiteSpace)
	CheckDlgButton (hDlg, $$IDCO_ENDOFLINE, EdOpt.EndOfLine)
	txt$ = STRING$ (EdOpt.Magnification)
	SetWindowTextA (GetDlgItem (hDlg, $$IDCO_BUDDY), &txt$)
	CheckDlgButton (hDlg, $$IDCO_SYNTAXHIGH, EdOpt.SyntaxHighlighting)
'	CheckDlgButton (hDlg, $$IDCO_CODETIPS, EdOpt.CodeTips)
	CheckDlgButton (hDlg, $$IDCO_MAXMAINWINDOW, EdOpt.MaximizeMainWindow)
	CheckDlgButton (hDlg, $$IDCO_MAXEDITWINDOWS, EdOpt.MaximizeEditWindows)
	CheckDlgButton (hDlg, $$IDCO_ASKBEFOREEXIT, EdOpt.AskBeforeExit)
	CheckDlgButton (hDlg, $$IDCO_ALLOWMULTINST, EdOpt.AllowMultipleInstances)
	CheckDlgButton (hDlg, $$IDCO_TRIMTRAILBLANKS, EdOpt.TrimTrailingBlanks)
	CheckDlgButton (hDlg, $$IDCO_SHOWPROCNAME, EdOpt.ShowProcedureName)
	CheckDlgButton (hDlg, $$IDCO_UPPERCASEKEYWORDS, EdOpt.UpperCaseKeywords)
	CheckDlgButton (hDlg, $$IDCO_SHOWCARETLINE, EdOpt.ShowCaretLine)
	CheckDlgButton (hDlg, $$IDCO_STARTINLASTFOLDER, EdOpt.StartInLastFolder)
	CheckDlgButton (hDlg, $$IDCO_RELOADFILESATSTARTUP, EdOpt.ReloadFilesAtStartup)
	CheckDlgButton (hDlg, $$IDCO_BACKUPEDITORFILES, EdOpt.BackupEditorFiles)

	ShowWindow (hDlg, $$SW_SHOW)
	UpdateWindow (hDlg)

	DO WHILE GetMessageA (&msg, NULL, 0, 0)
		IFZ IsDialogMessageA (hDlg, &msg) THEN
			TranslateMessage (&msg)
			DispatchMessageA (&msg)
		END IF
	LOOP

	RETURN msg.wParam

END FUNCTION
'
' #####################################
' #####  EditorOptionsDlgProc ()  #####
' #####################################
'
' Editor options dialog procedure
'
FUNCTION EditorOptionsDlgProc (hWnd, msg, wParam, lParam)

	EditorOptionsType EdOpt
	SHARED hWndMain

	SELECT CASE msg

		CASE $$WM_CREATE :
			EnableWindow (GetParent (hWnd), $$FALSE)		' To make popup dialog modal

		CASE $$WM_COMMAND :
			SELECT CASE LOWORD (wParam)
				CASE $$IDCANCEL :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						RETURN
					END IF
				CASE $$IDOK :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						EdOpt.UseTabs = IsDlgButtonChecked (hWnd, $$IDCO_USETABS)
						EdOpt.TabSize = XLONG (Combo_GetLbText (GetDlgItem (hWnd, $$IDCO_CBTABSIZE), -1))
						EdOpt.AutoIndent = IsDlgButtonChecked (hWnd, $$IDCO_AUTOINDENT)
						EdOpt.IndentSize = XLONG (Combo_GetLbText (GetDlgItem (hWnd, $$IDCO_CBINDENTSIZE), -1))
						EdOpt.LineNumbers = IsDlgButtonChecked (hWnd, $$IDCO_LINENUMBERS)
						szText$ = GetWindowText$ (GetDlgItem (hWnd, $$IDCO_LINENUMBERSWIDTH))
						EdOpt.LineNumbersWidth = XLONG (szText$)
						EdOpt.Margin = IsDlgButtonChecked (hWnd, $$IDCO_MARGIN)
						szText$ = GetWindowText$ (GetDlgItem (hWnd, $$IDCO_MARGINWIDTH))
						EdOpt.MarginWidth = XLONG (szText$)
						EdOpt.EdgeColumn = IsDlgButtonChecked (hWnd, $$IDCO_EDGECOLUMN)
						szText$ = GetWindowText$ (GetDlgItem (hWnd, $$IDCO_EDGEWIDTH))
						EdOpt.EdgeWidth = XLONG (szText$)
						EdOpt.IndentGuides = IsDlgButtonChecked (hWnd, $$IDCO_INDENTGUIDES)
						EdOpt.WhiteSpace = IsDlgButtonChecked (hWnd, $$IDCO_WHITESPACE)
						EdOpt.EndOfLine = IsDlgButtonChecked (hWnd, $$IDCO_ENDOFLINE)

						szText$ = GetWindowText$ (GetDlgItem (hWnd, $$IDCO_BUDDY))
						EdOpt.Magnification = XLONG (szText$)
						IF GetEdit () THEN SendMessageA (GetEdit (), $$SCI_SETZOOM, EdOpt.Magnification, 0)
						EdOpt.SyntaxHighlighting = IsDlgButtonChecked (hWnd, $$IDCO_SYNTAXHIGH)
'						EdOpt.CodeTips = IsDlgButtonChecked (hWnd, $$IDCO_CODETIPS)
						EdOpt.MaximizeMainWindow = IsDlgButtonChecked (hWnd, $$IDCO_MAXMAINWINDOW)
						EdOpt.MaximizeEditWindows = IsDlgButtonChecked (hWnd, $$IDCO_MAXEDITWINDOWS)
						EdOpt.AskBeforeExit = IsDlgButtonChecked (hWnd, $$IDCO_ASKBEFOREEXIT)
						EdOpt.AllowMultipleInstances = IsDlgButtonChecked (hWnd, $$IDCO_ALLOWMULTINST)
						EdOpt.TrimTrailingBlanks = IsDlgButtonChecked (hWnd, $$IDCO_TRIMTRAILBLANKS)
						EdOpt.ShowProcedureName = IsDlgButtonChecked (hWnd, $$IDCO_SHOWPROCNAME)
						EdOpt.UpperCaseKeywords = IsDlgButtonChecked (hWnd, $$IDCO_UPPERCASEKEYWORDS)
						EdOpt.ShowCaretLine = IsDlgButtonChecked (hWnd, $$IDCO_SHOWCARETLINE)
						EdOpt.StartInLastFolder = IsDlgButtonChecked (hWnd, $$IDCO_STARTINLASTFOLDER)
						EdOpt.ReloadFilesAtStartup = IsDlgButtonChecked (hWnd, $$IDCO_RELOADFILESATSTARTUP)
						EdOpt.BackupEditorFiles = IsDlgButtonChecked (hWnd, $$IDCO_BACKUPEDITORFILES)
						WriteEditorOptions (@EdOpt)
						CheckMenuOptions (@EdOpt)
						' Retrieve the name again and set the control options
						IF GetEdit () THEN
							szPath$ = GetWindowText$ (GetParent (GetEdit ()))
							IF szPath$ THEN
								' Get direct pointer for faster access
								pSci = SendMessageA (GetEdit (), $$SCI_GETDIRECTPOINTER, 0, 0)
								IF pSci THEN Scintilla_SetOptions (pSci, szPath$)
							END IF
						END IF
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						RETURN
					END IF
			END SELECT

		CASE $$WM_CLOSE :
			EnableWindow (GetParent (hWnd), $$TRUE)		' Maintains parent's zorder
			InvalidateRect (hWndMain, NULL, $$TRUE)		' Redraw areas covered by dialog

		CASE $$WM_DESTROY :
			PostQuitMessage (0)
			RETURN

	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
' ################################
' #####  Combo_AddString ()  #####
' ################################
'
' DESC: Adds a string to the list box of a combo box.
' SYNTAX: Index = Combo_AddString(hComboBox, Text)
' NOTES: If the combo box does not have the $$CBS_SORT style, the string is
' added to the end of the list.  Otherwise, the string is inserted
' into the list and the list is sorted.  The return value is the
' zero-based index to the string in the list box of the combo box.
' The return value is $$CB_ERR if an error occurs; the return value is
' $$CB_ERRSPACE if insufficient space is available to store the new
' string.
'
FUNCTION Combo_AddString (hComboBox, text$)
	RETURN SendMessageA (hComboBox, $$CB_ADDSTRING, 0, &text$)
END FUNCTION
'
' ################################
' #####  Combo_SetCurSel ()  #####
' ################################
'
' DESC: Selects indexed string in list box of combo box.
' SYNTAX: Index = Combo_SetCurSel(hComboBox, Index)
' NOTES: Select a string in the list box of a combo box. If necessary, the
' list box scrolls the string into view (if the list box is visible).
' The text in the edit control of the combo box is changed to reflect
' the new selection. Any previous selection in the list box is removed.
' The return value is the index of the item selected if the message is
' successful. The return value is $$CB_ERR if the index parameter is
' greater than the number of items in the list or if index is set to
' -1 (which clears the selection).
'
FUNCTION Combo_SetCurSel (hComboBox, index)
	RETURN SendMessageA (hComboBox, $$CB_SETCURSEL, index, 0)
END FUNCTION
'
' ################################
' #####  Combo_GetLbText ()  #####
' ################################
'
' DESC: Gets string from the list box of a combo box.
' SYNTAX: Text$ = Combo_GetLbText(hComboBox, Index)
' NOTES: If the item does not exist a null string is returned.  If -1 is
' specified for the index, the current selection is returned.
'
FUNCTION STRING Combo_GetLbText (hComboBox, index)

	szText$ = NULL$ (255)

	IF index < 0 THEN
		index = Combo_GetCurSel (hComboBox)
	END IF

	SendMessageA (hComboBox, $$CB_GETLBTEXT, index, &szText$)
	szText$ = CSIZE$ (szText$)
	RETURN (szText$)

END FUNCTION
'
' ################################
' #####  Combo_GetCurSel ()  #####
' ################################
'
' DESC: Gets index of selected list-box item in combo box.
' SYNTAX: Index = Combo_GetCurSel(hComboBox)
' NOTES: Retrieve the index of the currently selected item, if any, in the
' list box of a combo box.  The return value is the zero-based index
' of the currently selected item, or it is $$CB_ERR if no item is
' selected.
'
FUNCTION Combo_GetCurSel (hComboBox)
	RETURN SendMessageA (hComboBox, $$CB_GETCURSEL, 0, 0)
END FUNCTION
'
' ###################################
' #####  WriteEditorOptions ()  #####
' ###################################
'
' Writes the Editor options to the .INI file
'
FUNCTION WriteEditorOptions (EditorOptionsType EdOpt)

	SHARED IniFile$
	SHARED fMaximize
	SHARED TrimTrailingBlanks
	SHARED ShowProcedureName
	SHARED UpperCaseKeywords

	IniWrite (IniFile$, "Editor options", "UseTabs", STRING$ (EdOpt.UseTabs))
	IniWrite (IniFile$, "Editor options", "TabSize", STRING$ (EdOpt.TabSize))
	IniWrite (IniFile$, "Editor options", "AutoIndent", STRING$ (EdOpt.AutoIndent))
	IniWrite (IniFile$, "Editor options", "IndentSize", STRING$ (EdOpt.IndentSize))
	IniWrite (IniFile$, "Editor options", "LineNumbers", STRING$ (EdOpt.LineNumbers))
	IniWrite (IniFile$, "Editor options", "LineNumbersWidth", STRING$ (EdOpt.LineNumbersWidth))
	IniWrite (IniFile$, "Editor options", "Margin", STRING$ (EdOpt.Margin))
	IniWrite (IniFile$, "Editor options", "MarginWidth", STRING$ (EdOpt.MarginWidth))
	IniWrite (IniFile$, "Editor options", "EdgeColumn", STRING$ (EdOpt.EdgeColumn))
	IniWrite (IniFile$, "Editor options", "EdgeWidth", STRING$ (EdOpt.EdgeWidth))
	IniWrite (IniFile$, "Editor options", "IndentGuides", STRING$ (EdOpt.IndentGuides))
	IniWrite (IniFile$, "Editor options", "Magnification", STRING$ (EdOpt.Magnification))
	IniWrite (IniFile$, "Editor options", "WhiteSpace", STRING$ (EdOpt.WhiteSpace))
	IniWrite (IniFile$, "Editor options", "EndOfLine", STRING$ (EdOpt.EndOfLine))
	IniWrite (IniFile$, "Editor options", "SyntaxHighlighting", STRING$ (EdOpt.SyntaxHighlighting))
	IniWrite (IniFile$, "Editor options", "MaximizeMainWindow", STRING$ (EdOpt.MaximizeMainWindow))
	IniWrite (IniFile$, "Editor options", "MaximizeEditWindows", STRING$ (EdOpt.MaximizeEditWindows))
	IniWrite (IniFile$, "Editor options", "AskBeforeExit", STRING$ (EdOpt.AskBeforeExit))
	IniWrite (IniFile$, "Editor options", "AllowMultipleInstances", STRING$ (EdOpt.AllowMultipleInstances))
	IniWrite (IniFile$, "Editor options", "TrimTrailingBlanks", STRING$ (EdOpt.TrimTrailingBlanks))
	IniWrite (IniFile$, "Editor options", "ShowProcedureName", STRING$ (EdOpt.ShowProcedureName))
	IniWrite (IniFile$, "Editor options", "UpperCaseKeywords", STRING$ (EdOpt.UpperCaseKeywords))
	IniWrite (IniFile$, "Editor options", "ShowCaretLine", STRING$ (EdOpt.ShowCaretLine))
	IniWrite (IniFile$, "Editor options", "StartInLastFolder", STRING$ (EdOpt.StartInLastFolder))
	IniWrite (IniFile$, "Editor options", "LastFolder", EdOpt.LastFolder)
	IniWrite (IniFile$, "Editor options", "ReloadFilesAtStartup", STRING$ (EdOpt.ReloadFilesAtStartup))
	IniWrite (IniFile$, "Editor options", "BackupEditorFiles", STRING$ (EdOpt.BackupEditorFiles))

	IF EdOpt.MaximizeEditWindows = $$BST_CHECKED THEN fMaximize = $$TRUE ELSE fMaximize = $$FALSE
	IF EdOpt.TrimTrailingBlanks = $$BST_CHECKED THEN TrimTrailingBlanks = $$TRUE ELSE TrimTrailingBlanks = $$FALSE
	IF EdOpt.ShowProcedureName = $$BST_CHECKED THEN ShowProcedureName = $$TRUE ELSE ShowProcedureName = $$FALSE
	IF EdOpt.UpperCaseKeywords = $$BST_CHECKED THEN UpperCaseKeywords = $$TRUE ELSE UpperCaseKeywords = $$FALSE

END FUNCTION
'
' ####################################
' #####  ShowCompilerOptions ()  #####
' ####################################
'
' Compiler Options popup dialog
'
FUNCTION ShowCompilerOptions (hParent)

	RECT rc
	WNDCLASSEX wc
	CompilerOptionsType CpOpt
	MSG msg

	SHARED hInst
	SHARED hStatusbar
	SHARED fCpOpLib, fCpOpBc, fCpOpRc, fCpOpMak, fCpOpRcf, fCpOpBat
	SHARED fCpOpNoWinMain, fCpOpNoDllMain, fCpOpM4
	SHARED fMakeClean

	hFnt = GetStockObject ($$ANSI_VAR_FONT)

	szClassName$ = "Compiler_Options"
	wc.cbSize = SIZE (wc)
	wc.style = $$CS_HREDRAW OR $$CS_VREDRAW
	wc.lpfnWndProc = &CompilerOptionsDlgProc ()
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = hInst
	wc.hCursor = LoadCursorA ($$NULL, $$IDC_ARROW)
	wc.hbrBackground = $$COLOR_3DFACE + 1
	wc.lpszMenuName = NULL
	wc.lpszClassName = &szClassName$
	wc.hIcon = 0
	wc.hIconSm = 0
	RegisterClassExA (&wc)

	GetWindowRect (hParent, &rc)		' for centering child in parent
	rc.right = rc.right - rc.left		' parent's width
	rc.bottom = rc.bottom - rc.top		' parent's height

	w = 383
	h = 540
	x = rc.left + (rc.right - w) / 2
	IF x < 0 THEN x = 10
	y = rc.top + (rc.bottom - h) / 2
	IF y < 0 THEN y = 10

	hDlg = CreateWindowExA ($$WS_EX_DLGMODALFRAME OR $$WS_EX_CONTROLPARENT, &szClassName$, &"Compiler options", $$WS_CAPTION OR $$WS_POPUPWINDOW OR $$WS_VISIBLE, x, y, w, h, hParent, 0, hInst, NULL)

	hCtl = CreateWindowExA (0, &"Button", &" XBLite Compiler ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 8, 8, 360, 52, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Path", $$WS_CHILD OR $$WS_VISIBLE, 17, 31, 72, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"Edit", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$ES_AUTOHSCROLL, 93, 28, 228, 21, hDlg, $$IDCO_XBLPATH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	SetFocus (hCtl)

	hCtl = CreateWindowExA (0, &"Button", &"...", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 329, 28, 28, 21, hDlg, $$IDBO_XBLPATH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &" Compiler Results ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 8, 70, 360, 47, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Display Output", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 91, 96, 16, hDlg, $$IDCO_DISPRES, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Enable Log File", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 132, 91, 99, 16, hDlg, $$IDCO_ENABLELOG, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"Beep On Completion", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 242, 91, 115, 16, hDlg, $$IDCO_BEEPONEND, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &" Debugging Tool ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 8, 126, 360, 51, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Path", $$WS_CHILD OR $$WS_VISIBLE, 17, 147, 72, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"Edit", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$ES_AUTOHSCROLL, 93, 144, 228, 21, hDlg, $$IDCO_DEBUGTOOLPATH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"...", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 329, 144, 28, 21, hDlg, $$IDBO_DEBUGTOOLPATH, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &" Command Line Options ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 8, 188, 360, 224, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)


	hCtl = CreateWindowExA (0, &"Button", &" Makefile Options ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 8, 424, 360, 46, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"clean", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 444, 80, 16, hDlg, $$IDCO_CLEAN, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Enable 'clean' makefile option ", $$WS_CHILD OR $$WS_VISIBLE, 115, 444, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)



	hCtl = CreateWindowExA (0, &"Button", &"-lib", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 208, 80, 16, hDlg, $$IDCO_LIB, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-bc", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 230, 80, 16, hDlg, $$IDCO_BC, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-rc", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 252, 80, 16, hDlg, $$IDCO_RC, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-m4", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 274, 80, 16, hDlg, $$IDCO_M4, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-mak", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 296, 80, 16, hDlg, $$IDCO_MAK, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-rcf", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 318, 80, 16, hDlg, $$IDCO_RCF, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-bat", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 340, 80, 16, hDlg, $$IDCO_BAT, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-nowinmain", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 362, 80, 16, hDlg, $$IDCO_NOWINMAIN, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"-nodllmain", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX OR $$BS_LEFT OR $$BS_VCENTER, 23, 384, 80, 16, hDlg, $$IDCO_NODLLMAIN, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)


	hCtl = CreateWindowExA (0, &"Static", &"Compile as function library (DLL) ", $$WS_CHILD OR $$WS_VISIBLE, 115, 208, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Turn on bounds checking ", $$WS_CHILD OR $$WS_VISIBLE, 115, 230, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Remove comments in output ASM ", $$WS_CHILD OR $$WS_VISIBLE, 115, 252, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Enable m4.exe preprocessor ", $$WS_CHILD OR $$WS_VISIBLE, 115, 274, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Suppress output of .mak file ", $$WS_CHILD OR $$WS_VISIBLE, 115, 296, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Suppress output of .rc file ", $$WS_CHILD OR $$WS_VISIBLE, 115, 318, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Suppress output of .bat file ", $$WS_CHILD OR $$WS_VISIBLE, 115, 340, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Suppress ASM output of WinMain() ", $$WS_CHILD OR $$WS_VISIBLE, 115, 362, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Static", &"Suppress ASM output of DllMain() ", $$WS_CHILD OR $$WS_VISIBLE, 115, 384, 220, 16, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)


	hCtl = CreateWindowExA (0, &"Button", &"&Ok", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 113, h-55, 75, 23, hDlg, $$IDOK, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Cancel", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 201, h-55, 75, 23, hDlg, $$IDCANCEL, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"Button", &"&Help", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_CENTER OR $$BS_VCENTER, 291, h-55, 75, 23, hDlg, $$IDBO_COMPILER_HELP, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	GetCompilerOptions (@CpOpt)

	SetWindowTextA (GetDlgItem (hDlg, $$IDCO_XBLPATH), &CpOpt.XBLPath)
	SetWindowTextA (GetDlgItem (hDlg, $$IDCO_DEBUGTOOLPATH), &CpOpt.DebugToolPath)
	CheckDlgButton (hDlg, $$IDCO_DISPRES, CpOpt.DisplayResults)
	CheckDlgButton (hDlg, $$IDCO_ENABLELOG, CpOpt.EnableLogFile)
	CheckDlgButton (hDlg, $$IDCO_BEEPONEND, CpOpt.BeepOnCompletion)

	CheckDlgButton (hDlg, $$IDCO_LIB, fCpOpLib)
	CheckDlgButton (hDlg, $$IDCO_BC, fCpOpBc)
	CheckDlgButton (hDlg, $$IDCO_RC, fCpOpRc)
	CheckDlgButton (hDlg, $$IDCO_MAK, fCpOpMak)
	CheckDlgButton (hDlg, $$IDCO_RCF, fCpOpRcf)
	CheckDlgButton (hDlg, $$IDCO_BAT, fCpOpBat)
	CheckDlgButton (hDlg, $$IDCO_NOWINMAIN, fCpOpNoWinMain)
	CheckDlgButton (hDlg, $$IDCO_NODLLMAIN, fCpOpNoDllMain)
	CheckDlgButton (hDlg, $$IDCO_M4, fCpOpM4)
	CheckDlgButton (hDlg, $$IDCO_CLEAN, fMakeClean)

	ShowWindow (hDlg, $$SW_SHOW)
	UpdateWindow (hDlg)

	DO WHILE GetMessageA (&msg, NULL, 0, 0)
		IFZ IsDialogMessageA (hDlg, &msg) THEN
			TranslateMessage (&msg)
			DispatchMessageA (&msg)
		END IF
	LOOP

	RETURN msg.wParam

END FUNCTION
'
' #######################################
' #####  CompilerOptionsDlgProc ()  #####
' #######################################
'
' Compiler options dialog procedure
'
FUNCTION CompilerOptionsDlgProc (hWnd, msg, wParam, lParam)

	CompilerOptionsType CpOpt
	SHARED fCpOpLib, fCpOpBc, fCpOpRc, fCpOpMak, fCpOpRcf, fCpOpBat
	SHARED fCpOpNoWinMain, fCpOpNoDllMain, fCpOpM4
	SHARED fMakeClean

	SELECT CASE msg
		CASE $$WM_CREATE :		' Entrance
			EnableWindow (GetParent (hWnd), $$FALSE)		' To make popup dialog modal

		CASE $$WM_COMMAND :
			SELECT CASE LOWORD (wParam)
				CASE $$IDCANCEL :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						RETURN
					END IF

				CASE $$IDOK :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						szPath$ = GetWindowText$ (GetDlgItem (hWnd, $$IDCO_XBLPATH))
						CpOpt.XBLPath = szPath$

						CpOpt.DisplayResults = IsDlgButtonChecked (hWnd, $$IDCO_DISPRES)
						CpOpt.EnableLogFile = IsDlgButtonChecked (hWnd, $$IDCO_ENABLELOG)
						CpOpt.BeepOnCompletion = IsDlgButtonChecked (hWnd, $$IDCO_BEEPONEND)

						szPath$ = GetWindowText$ (GetDlgItem (hWnd, $$IDCO_DEBUGTOOLPATH))
						CpOpt.DebugToolPath = szPath$

						' these options are not saved in ini file, they are only for current instance of xsed
						fCpOpLib = IsDlgButtonChecked (hWnd, $$IDCO_LIB)
						fCpOpBc = IsDlgButtonChecked (hWnd, $$IDCO_BC)
						fCpOpRc = IsDlgButtonChecked (hWnd, $$IDCO_RC)
						fCpOpMak = IsDlgButtonChecked (hWnd, $$IDCO_MAK)
						fCpOpRcf = IsDlgButtonChecked (hWnd, $$IDCO_RCF)
						fCpOpBat = IsDlgButtonChecked (hWnd, $$IDCO_BAT)
						fCpOpNoWinMain = IsDlgButtonChecked (hWnd, $$IDCO_NOWINMAIN)
						fCpOpNoDllMain = IsDlgButtonChecked (hWnd, $$IDCO_NODLLMAIN)
						fCpOpM4 = IsDlgButtonChecked (hWnd, $$IDCO_M4)
						fMakeClean = IsDlgButtonChecked (hWnd, $$IDCO_CLEAN)

						WriteCompilerOptions (@CpOpt)
						' update help file paths since they depend on location of compiler
						WriteHelpFilePaths ()
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						RETURN
					END IF

				CASE $$IDBO_XBLPATH :
					szPath$ = SearchForExePath ()
					IF szPath$ THEN SetWindowTextA (GetDlgItem (hWnd, $$IDCO_XBLPATH), &szPath$)
					SetFocus (GetDlgItem (hWnd, $$IDCO_XBLPATH))

				CASE $$IDBO_DEBUGTOOLPATH :
					szPath$ = SearchForExePath ()
					IF szPath$ THEN SetWindowTextA (GetDlgItem (hWnd, $$IDCO_DEBUGTOOLPATH), &szPath$)
					SetFocus (GetDlgItem (hWnd, $$IDCO_DEBUGTOOLPATH))
			END SELECT

		CASE $$WM_CLOSE :
			EnableWindow (GetParent (hWnd), $$TRUE)		' Maintains parent's zorder

		CASE $$WM_DESTROY :		' Exit
			PostQuitMessage (0)
			RETURN

	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
' #################################
' #####  SearchForExePath ()  #####
' #################################
'
' Search for executable program path
'
FUNCTION STRING SearchForExePath ()
	XstGetCurrentDirectory (@Path$)
	fOptions$ = "EXE files (*.EXE)|*.EXE|"
	fOptions$ = fOptions$ + "All Files (*.*)|*.*"
	f$ = "*.EXE"
	Style = $$OFN_EXPLORER OR $$OFN_FILEMUSTEXIST OR $$OFN_HIDEREADONLY
	IF OpenFileDialog (hWndMain, "", @f$, Path$, fOptions$, "EXE", Style) THEN RETURN f$
END FUNCTION
'
' ################################
' #####  BrowseForFolder ()  #####
' ################################
'
' Browse for folder dialog
'
FUNCTION STRING BrowseForFolder (hWnd, strTitle$, StartFolder$)

	BROWSEINFO bi

	bi.hWndOwner = hWnd
	bi.lpszTitle = &strTitle$
	bi.ulFlags = $$BIF_RETURNONLYFSDIRS OR $$BIF_DONTGOBELOWDOMAIN OR $$BIF_USENEWUI OR $$BIF_RETURNFSANCESTORS
	bi.lpfnCallback = &BrowseForFolderProc ()
	bi.lParam = &StartFolder$

	lpIDList = SHBrowseForFolderA (&bi)

	szBuffer$ = NULL$ (255)
	IF lpIDList && SHGetPathFromIDListA (lpIDList, &szBuffer$) THEN
		szBuffer$ = CSIZE$ (szBuffer$)
		CoTaskMemFree (lpIDList)
		RETURN (szBuffer$)
	END IF

END FUNCTION
'
' ####################################
' #####  BrowseForFolderProc ()  #####
' ####################################
'
' Browse for folder dialog procedure
'
FUNCTION BrowseForFolderProc (hWnd, wMsg, wParam, lParam)

	IF wMsg = $$BFFM_INITIALIZED THEN
		SendMessageA (hWnd, $$BFFM_SETSELECTIONA, $$TRUE, lParam)
	ELSE
		IF wMsg = $$BFFM_SELCHANGED THEN
			szBuffer$ = NULL$ (255)
			SHGetPathFromIDListA (wParam, &szBuffer$)
			szBuffer$ = CSIZE$ (szBuffer$)
			IF szBuffer$ THEN
				XstGetFileAttributes (szBuffer$, @attributes)
			ELSE
				SendMessageA (hWnd, $$BFFM_ENABLEOK, $$FALSE, $$FALSE)
				MessageBeep ($$MB_ICONEXCLAMATION)
				RETURN
			END IF
			IF !wParam || !(attributes AND $$FileDirectory) || MID$ (szBuffer$, 2, 1) <> ":" THEN
				SendMessageA (hWnd, $$BFFM_ENABLEOK, $$FALSE, $$FALSE)
				MessageBeep ($$MB_ICONEXCLAMATION)
			ELSE
				IF (attributes AND $$FileSystem) && RIGHT$ (szBuffer$, 2) <> ":\\" THEN		' exclude system folders, allow root directories
					SendMessageA (hWnd, $$BFFM_ENABLEOK, $$FALSE, $$FALSE)
					MessageBeep ($$MB_ICONEXCLAMATION)
				END IF
			END IF
		END IF
	END IF

END FUNCTION
'
' ###################################
' #####  GetCompilerOptions ()  #####
' ###################################
'
' Reads the Compiler options from the .INI file
'
FUNCTION GetCompilerOptions (CompilerOptionsType CpOpt)

	SHARED IniFile$

	CpOpt.XBLPath = IniRead (IniFile$, "Compiler options", "XBLPath", "")
	IFZ CpOpt.XBLPath THEN CpOpt.XBLPath = "C:\\xblite\\bin\\xblite.exe"

	rs$ = IniRead (IniFile$, "Compiler options", "DisplayResults", "")
	IF rs$ THEN CpOpt.DisplayResults = XLONG (rs$) ELSE CpOpt.DisplayResults = $$BST_CHECKED

	rs$ = IniRead (IniFile$, "Compiler options", "EnableLogFile", "")
	IF rs$ THEN CpOpt.EnableLogFile = XLONG (rs$) ELSE CpOpt.EnableLogFile = $$BST_UNCHECKED

	rs$ = IniRead (IniFile$, "Compiler options", "BeepOnCompletion", "")
	IF rs$ THEN CpOpt.BeepOnCompletion = XLONG (rs$) ELSE CpOpt.BeepOnCompletion = $$BST_UNCHECKED

	CpOpt.DebugToolPath = IniRead (IniFile$, "Compiler options", "DebugToolPath", "")

END FUNCTION
'
' #####################################
' #####  WriteCompilerOptions ()  #####
' #####################################
'
' Writes the Editor options to the .INI file
'
FUNCTION WriteCompilerOptions (CompilerOptionsType CpOpt)

	SHARED IniFile$

	IniWrite (IniFile$, "Compiler options", "XBLPath", CpOpt.XBLPath)

	IniWrite (IniFile$, "Compiler options", "DisplayResults", STRING$ (CpOpt.DisplayResults))
	IniWrite (IniFile$, "Compiler options", "EnableLogFile", STRING$ (CpOpt.EnableLogFile))
	IniWrite (IniFile$, "Compiler options", "BeepOnCompletion", STRING$ (CpOpt.BeepOnCompletion))
	IniWrite (IniFile$, "Compiler options", "DebugToolPath", CpOpt.DebugToolPath)

END FUNCTION
'
' #####################################
' #####  SED_SaveUntitledFile ()  #####
' #####################################
'
' Save untitled file in Windows temporary folder
'
FUNCTION SED_SaveUntitledFile (hWnd, @szPath$)

	IFZ szPath$ THEN RETURN

	szStr$ = NULL$ (255)
	GetTempPathA (LEN (szStr$), &szStr$)
	szStr$ = CSIZE$ (szStr$)
	XstChangeDirectory (szStr$)
	szPath$ = szStr$ + szPath$

	nLen = SendMessageA (GetEdit (), $$SCI_GETTEXTLENGTH, 0, 0)
	Buffer$ = NULL$ (nLen+1)
	SendMessageA (GetEdit (), $$SCI_GETTEXT, LEN (Buffer$), &Buffer$)
	Buffer$ = CSIZE$ (Buffer$)

	' save file buffer
	IF XstSaveString (@szPath$, @Buffer$) THEN
		error = ERROR (0)
		msg$ = "Error" + STRING$ (error) + " saving the file " + szPath$ + "   "
		MessageBoxA (hWnd, &msg$, &" SaveFile", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		RETURN
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
' #####################################
' #####  ReplaceFileExtension ()  #####
' #####################################
'
' Replace file extension with new one.
' Returns 0 on success, -1 on failure.
'
FUNCTION ReplaceFileExtension (@file$, ext$)

	IFZ file$ THEN RETURN ($$TRUE)
	IFZ ext$ THEN RETURN ($$TRUE)

	p = INSTR (file$, ".")
	IFZ p THEN RETURN ($$TRUE)
	file$ = LEFT$ (file$, p) + ext$
	RETURN
END FUNCTION
'
' ##################################
' #####  ExecuteActiveFile ()  #####
' ##################################
'
' Run the currently active file executable.
' Returns 0 on success, -1 on failure
'
FUNCTION ExecuteActiveFile (hWnd)

	SHARED hWndClient
	SHARED CommandLine$
	CompilerOptionsType CpOpt

	szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
	IFZ szPath$ THEN
		MessageBoxA (hWnd, &"Can't retrieve the path of the file to execute   ", &" Execute", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF
	strCurDir$ = ""

	XstGetPathComponents (szPath$, "", "", "", @fn$, 0)
	IF (INSTR (szPath$, ":") = 0) && (INSTR (szPath$, "\\") = 0) && (INSTR (szPath$, "/") = 0) && (LEFT$ (UCASE$ (fn$), 8) = "UNTITLED") THEN
		XstGetCurrentDirectory (@strCurDir$)
		IFZ SED_SaveUntitledFile (hWnd, @szPath$) THEN
			MessageBoxA (hWnd, &"Error saving untitled file   ", &" Execute", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
			RETURN ($$TRUE)
		END IF
	END IF

  GetFileExtension (szPath$, @file$, @strExt$)
  SELECT CASE LCASE$ (strExt$)
    CASE "x", "xl", "xbl" :
		CASE "asm" :
    CASE ELSE :
      MessageBoxA (hWnd, &"This is not an XBLite program or assembly file   ", &" Execute", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		  RETURN ($$TRUE)
  END SELECT

	' Change the directory
	XstGetPathComponents (szPath$, @szDir$, "", "", "", 0)
	XstGetCurrentDirectory (@CURDIR$)
	IF szDir$ <> CURDIR$ THEN XstChangeDirectory (szDir$)

	IF ReplaceFileExtension (@szPath$, "exe") THEN
		msg$ = "File extension error with " + szPath$
		MessageBoxA (hWnd, &msg$, &" Execute", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	IFZ FileExist (szPath$) THEN
		msg$ = "Can't find the file " + szPath$
		MessageBoxA (hWnd, &msg$, &" Execute", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	' get compiler path
	GetCompilerOptions (@CpOpt)

	' get path for \xblite\programs for xblite DLLs
	' set PATH to include \xblite\programs
	IF CpOpt.XBLPath THEN
		comp$ = CpOpt.XBLPath
		pos = INSTR (comp$, "bin")
		IF pos THEN
			p$ = LEFT$ (comp$, pos - 1) + "programs"
		END IF
		XstGetEnvironmentVariable ("PATH", @curPATH$)
		XstSetEnvironmentVariable ("PATH", p$ + ";" + curPATH$)
	END IF

	' run program executable
  IF CommandLine$ THEN
    ShellExecuteA (NULL, &"open", &szPath$, &CommandLine$, NULL, $$SW_SHOWNORMAL)
  ELSE
    ShellExecuteA (NULL, &"open", &szPath$, NULL, NULL, $$SW_SHOWNORMAL)
  END IF

	' restore old PATH
	IF curPATH$ THEN XstSetEnvironmentVariable ("PATH", curPATH$)

	' Restore old directory
	IF (strCurDir$) THEN XstChangeDirectory (strCurDir$)

END FUNCTION
'
' ##################################
' #####  CompileActiveFile ()  #####
' ##################################
'
' Compile currently active file.
' Compile as library DLL if fAsLib = $$TRUE
'
FUNCTION CompileActiveFile (hWnd, fAsLib)

	SHARED hWndClient
	SHARED hToolbar
	CompilerOptionsType CpOpt
	SHARED hSplitter
	SHARED hWndMain
	RECT rc
	SHARED hListBox
	SHARED fRanCompiler
	SHARED fCpOpLib, fCpOpBc, fCpOpRc, fCpOpMak, fCpOpRcf, fCpOpBat
	SHARED fCpOpNoWinMain, fCpOpNoDllMain, fCpOpM4

	$QUOTE = "\""

	szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
	IFZ szPath$ THEN
		MessageBoxA (hWnd, &"Can't retrieve the path of the file to execute   ", &" Compile", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF
	strCurDir$ = ""

	XstGetPathComponents (szPath$, "", "", "", @fn$, 0)
	IF (INSTR (szPath$, ":") = 0) && (INSTR (szPath$, "\\") = 0) && (INSTR (szPath$, "/") = 0) && (LEFT$ (UCASE$ (fn$), 8) = "UNTITLED") THEN
		XstGetCurrentDirectory (@strCurDir$)
		IFZ SED_SaveUntitledFile (hWnd, @szPath$) THEN
			MessageBoxA (hWnd, &"Error saving untitled file   ", &" Compile", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
			RETURN ($$TRUE)
		END IF
	END IF

  GetFileExtension (szPath$, @file$, @strExt$)
  SELECT CASE UCASE$ (strExt$)
    CASE "X", "XL", "XBL" :
    CASE ELSE :
      MessageBoxA (hWnd, &"This is not an XBLite program file   ", &" Compile", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		  RETURN ($$TRUE)
  END SELECT

'	IF INSTR (UCASE$ (szPath$), ".X") = 0 && INSTR (UCASE$ (szPath$), ".XBL") = 0 THEN
'		MessageBoxA (hWnd, &"This is not an XBLite program file   ", &" Compile", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
'		RETURN ($$TRUE)
'	END IF

	' Change the directory
	XstGetPathComponents (szPath$, @szDir$, "", "", "", 0)
	XstGetCurrentDirectory (@CURDIR$)
	IF szDir$ <> CURDIR$ THEN XstChangeDirectory (szDir$)

	' update toolbar
	UpdateWindow (hToolbar)

	' get compiler info
	GetCompilerOptions (@CpOpt)

	strCommand$ = ""
	IFZ CpOpt.XBLPath THEN
		MessageBoxA (hWnd, &"No compiler path found  ", &" Compile", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	' run compiler, do not output normal error messages which require
	' user response (-conoff command line switch)
	strCommand$ = CpOpt.XBLPath + " " + $QUOTE + szPath$ + $QUOTE + " -conoff"

	' generate a .log error file (if there are errors)
	IF CpOpt.EnableLogFile THEN
		strCommand$ = strCommand$ + " -log"
	END IF

	' compile as a DLL
	IF fAsLib THEN
		strCommand$ = strCommand$ + " -lib"
	END IF

	' use compiler command line switches selected in compiler options
	SELECT CASE ALL TRUE
		CASE fCpOpLib				: strCommand$ = strCommand$ + " -lib"
		CASE fCpOpBc				: strCommand$ = strCommand$ + " -bc"
		CASE fCpOpRc				: strCommand$ = strCommand$ + " -rc"
		CASE fCpOpMak				: strCommand$ = strCommand$ + " -mak"
		CASE fCpOpRcf				: strCommand$ = strCommand$ + " -rcf"
		CASE fCpOpBat				: strCommand$ = strCommand$ + " -bat"
		CASE fCpOpNoWinMain	: strCommand$ = strCommand$ + " -nowinmain"
		CASE fCpOpNoDllMain	: strCommand$ = strCommand$ + " -nodllmain"
		CASE fCpOpM4				: strCommand$ = strCommand$ + " -m4"
	END SELECT


	' Update the client area of the control before shelling
	UpdateWindow (GetEdit ())
	IF CpOpt.DisplayResults = $$BST_CHECKED THEN
		' Open console window
		SendMessageA (hSplitter, $$WM_UNDOCK_SPLITTER, 0, 0)

		' Clear the console
		SendMessageA (hListBox, $$LB_RESETCONTENT, 0, 0)

		Listbox_AddString (hListBox, "> Executing: " + strCommand$)
	END IF

	XstGetPathComponents (szPath$, @workDir$, "", "", "", 0)
	ShellEx (strCommand$, workDir$, @output$, 0)

	IF CpOpt.DisplayResults = $$BST_CHECKED THEN
		' parse output string into lines
		XstStringToStringArray (output$, @output$[])

		' print ouput$[] to output console
		upp = UBOUND (output$[])
		FOR i = 0 TO upp
			IF output$[i] THEN
				Listbox_AddString (hListBox, LTRIM$ (output$[i]))
			END IF
		NEXT i

		Listbox_AddString (hListBox, "> Execution finished.")
	END IF

	IF CpOpt.BeepOnCompletion THEN MessageBeep ($$MB_ICONEXCLAMATION)

	SetFocus (GetEdit ())

	' Restore old directory
	IF (strCurDir$) THEN XstChangeDirectory (strCurDir$)

	' set fRanCompiler flag to $$TRUE (just ran compiler)
'	fRanCompiler = $$TRUE
END FUNCTION
'
'
' ########################
' #####  ShellEx ()  #####
' ########################
'
' PURPOSE	: ShellEx () is a replacement for the SHELL
' intrinsic function. Use only for commands
' that do not expect user input.
' Do not use to shell batch *.bat files.
' ShellEx() captures output from the shelled program.
' It also allows a working directory to be specified,
' and returns the exit code for the shelled program.
'
' IN	: command$ - 	the command to be executed, including a path if necessary,
' and any switches or parameters required by the command.
' : workDir$ -  the working directory for the command$, if any. Can be null ("").
' : outputMode - determines how output is treated. If outputMode = $$Console (-1),
' then captured output is printed on the console as it is generated,
' as well as being stored in the output$ variable.
' If outputMode = $$Default (0), output is not printed.
' Any other value is interpreted as a window handle (hWnd),
' to which the output is sent using SetWindowTextA and UpdateWindow.

' OUT	: output$  -  the captured output generated when the command is executed,
' which would normally be sent to a DOS window.
'
' ShellEx() function written by Ken Minogue - May 2002
'
FUNCTION ShellEx (command$, workDir$, output$, outputMode)

	PROCESS_INFORMATION procInfo
	STARTUPINFO startInfo
	SECURITY_ATTRIBUTES saP, saT, pa
	SHARED hStdoutRd, hStdoutWr, hChild

	output$ = ""
	IFZ command$ THEN RETURN

	' allow handles to be inherited
	saT.inherit = 1
	saP.inherit = 1
	pa.inherit = 1
	saT.length = SIZE (SECURITY_ATTRIBUTES)
	saP.length = SIZE (SECURITY_ATTRIBUTES)
	pa.length = SIZE (SECURITY_ATTRIBUTES)
	saT.securityDescriptor = NULL
	saP.securityDescriptor = NULL
	pa.securityDescriptor = NULL

	' Create a pipe that will be used for the child process's STDOUT.
	' This returns two handles:
	' hStdoutRd is a handle to the read end of the pipe
	' hStdoutWr is a handle to the write end of the pipe
	IFZ CreatePipe (&hStdoutRd, &hStdoutWr, &pa, 0) THEN
		' PRINT "Pipe creation failed"
		RETURN ($$TRUE)
	END IF

	' Create the child process, directing STDOUT and STDERR to the pipe's write handle
	RtlZeroMemory (&startInfo, SIZE (STARTUPINFO))
	startInfo.cb = SIZE (STARTUPINFO)
	startInfo.dwFlags = $$STARTF_USESHOWWINDOW OR $$STARTF_USESTDHANDLES
	startInfo.wShowWindow = $$SW_HIDE		' don't show the DOS console window
	startInfo.hStdInput = GetStdHandle ($$STD_INPUT_HANDLE)
	startInfo.hStdOutput = hStdoutWr
	startInfo.hStdError = hStdoutWr
	IFZ CreateProcessA (NULL, &command$, &saP, &saT, 1, 0, 0, &workDir$, &startInfo, &procInfo) THEN
		' PRINT "Create process failed"
		GOSUB CloseHandles
		RETURN ($$TRUE)
	END IF

	' optional - wait for process to finish
	' res = WaitForSingleObject (procInfo.hProcess, $$INFINITE)

	' handle for child process, used to get exit code.
	hChild = procInfo.hProcess

	' The parent's write handle to the pipe must be closed,
	' or ReadFile() will never return FALSE.
	IFZ CloseHandle (hStdoutWr) THEN
		' PRINT "Close handle failed"
		hStdoutWr = 0
		GOSUB CloseHandles
		RETURN ($$TRUE)
	END IF
	hStdoutWr = 0

	' Read output from the child process. ReadFile() returns FALSE
	' when the child process closes the write handle to the pipe, or terminates.
	DO
		chBuf$ = NULL$ ($$BUFSIZE)
		ret = ReadFile (hStdoutRd, &chBuf$, $$BUFSIZE, &bytesRead, 0)
		IF (!ret || (bytesRead == 0)) THEN EXIT DO
		buf$ = CSTRING$ (&chBuf$)
		output$ = output$ + buf$
		SELECT CASE outputMode
			CASE $$Default :
			CASE $$Console : PRINT buf$;
			CASE ELSE :
				hWnd = outputMode
				IF IsWindow (hWnd) THEN
					SendMessageA (hWnd, $$WM_SETTEXT, 0, &output$)
					UpdateWindow (hWnd)
				END IF
		END SELECT
	LOOP

	' child process is finished.
	GetExitCodeProcess (hChild, &exitCode)
	GOSUB CloseHandles
	RETURN (exitCode)

SUB CloseHandles
	IF hStdoutRd THEN CloseHandle (hStdoutRd)
	IF hStdoutWr THEN CloseHandle (hStdoutWr)
	IF hChild THEN CloseHandle (hChild)
	IF procInfo.hThread THEN CloseHandle (procInfo.hThread)
	hStdoutRd = 0
	hStdoutWr = 0
	hChild = 0
END SUB

END FUNCTION
'
' ################################
' #####  BuildActiveFile ()  #####
' ################################
'
' Build currently active file using nmake.
' File must have previously been compiled.
'
FUNCTION BuildActiveFile (hWnd)

	SHARED hWndClient
	SHARED hToolbar
	CompilerOptionsType CpOpt
	SHARED hSplitter
	SHARED hListBox
	RECT rc
	SHARED fRanCompiler
	SHARED hWndMain
	SHARED fMakeClean

	$QUOTE = "\""

	szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
	IFZ szPath$ THEN
		MessageBoxA (hWnd, &"Can't retrieve the path of the file to execute   ", &" Build", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF
	strCurDir$ = ""

	XstGetPathComponents (szPath$, "", "", "", @fn$, 0)
	IF (INSTR (szPath$, ":") = 0) && (INSTR (szPath$, "\\") = 0) && (INSTR (szPath$, "/") = 0) && (LEFT$ (UCASE$ (fn$), 8) = "UNTITLED") THEN
		XstGetCurrentDirectory (@strCurDir$)
		IFZ SED_SaveUntitledFile (hWnd, @szPath$) THEN
			MessageBoxA (hWnd, &"Error saving untitled file   ", &" Build", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
			RETURN ($$TRUE)
		END IF
	END IF

  GetFileExtension (szPath$, @file$, @strExt$)
  SELECT CASE LCASE$ (strExt$)
    CASE "x", "xl", "xbl" :
		CASE "asm" :
    CASE ELSE :
      MessageBoxA (hWnd, &"This is not an XBLite program or assembly file.  ", &" Build", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		  RETURN ($$TRUE)
  END SELECT

'	IF INSTR (UCASE$ (szPath$), ".X") = 0 && INSTR (UCASE$ (szPath$), ".XBL") = 0 THEN		' If it is not a .BAS file
'		MessageBoxA (hWnd, &"This is not an XBLite program file   ", &" Build", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
'		RETURN ($$TRUE)
'	END IF

	' Change the directory
	XstGetPathComponents (szPath$, @szDir$, "", "", "", 0)
	XstGetCurrentDirectory (@CURDIR$)
	IF szDir$ <> CURDIR$ THEN XstChangeDirectory (szDir$)

	IF ReplaceFileExtension (@szPath$, "mak") THEN
		msg$ = "File extension error with " + szPath$ + SPACE$ (4)
		MessageBoxA (hWnd, &msg$, &" Build", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	IFZ FileExist (szPath$) THEN
		msg$ = "Can't find the MAKE file " + szPath$ + SPACE$ (4) + "\r\n"
		msg$ = msg$ + "Please compile program.    "
		MessageBoxA (hWnd, &msg$, &" Build", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	' update toolbar
	UpdateWindow (hToolbar)

	' get compiler info
	GetCompilerOptions (@CpOpt)

	strCommand$ = ""
	IFZ CpOpt.XBLPath THEN
		MessageBoxA (hWnd, &"No compiler path found  ", &" Build", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	' get path to nmake
	XstGetPathComponents (CpOpt.XBLPath, @compPath$, "", "", "", 0)

	makePath$ = compPath$ + "nmake.exe"
	IFZ FileExist (makePath$) THEN
		msg$ = "Can't find the nmake.exe program "
		MessageBoxA (hWnd, &msg$, &" Build", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		RETURN ($$TRUE)
	END IF

	' set xblite variables PATH, LIB, INCLUDE, XBLDIR
	IF compPath$ THEN
		pos = INSTR (compPath$, "bin")
		IF pos THEN
		  a$ = LEFT$ (compPath$, pos - 1)
			lib$ = a$ + "lib"
			include$ = a$ + "include"
			xbldir$ = LEFT$ (compPath$, pos - 2)
		END IF
		' set PATH
		XstGetEnvironmentVariable ("PATH", @curPATH$)
		XstSetEnvironmentVariable ("PATH", compPath$ + ";" + curPATH$)
		' set LIB
		XstGetEnvironmentVariable ("LIB", @curLIB$)
		XstSetEnvironmentVariable ("LIB", lib$ + ";" + curLIB$)
		' set INCLUDE
		XstGetEnvironmentVariable ("INCLUDE", @curINCLUDE$)
		XstSetEnvironmentVariable ("INCLUDE", include$ + ";" + curINCLUDE$)
		' set XBLDIR
    XstGetEnvironmentVariable ("XBLDIR", @curXBLDIR$)
    XstSetEnvironmentVariable ("XBLDIR", xbldir$)
	END IF

	strCommand$ = makePath$ + " -f " + $QUOTE + szPath$ + $QUOTE

	' add makefile clean option
	IF fMakeClean THEN
		strCommand$ = strCommand$ + " clean"
	END IF

	' Update the client area of the control before shelling
	UpdateWindow (GetEdit ())

	IF CpOpt.DisplayResults = $$BST_CHECKED THEN
		' Open console window
		SendMessageA (hSplitter, $$WM_UNDOCK_SPLITTER, 0, 0)
		' Clear the console
		SendMessageA (hListBox, $$LB_RESETCONTENT, 0, 0)
		Listbox_AddString (hListBox, "> Executing: " + strCommand$)
	END IF

	XstGetPathComponents (szPath$, @workDir$, "", "", "", 0)
	ShellEx (strCommand$, workDir$, @output$, 0)

	IF CpOpt.DisplayResults = $$BST_CHECKED THEN
		' parse output string into lines
		XstStringToStringArray (output$, @output$[])

		' print ouput$[] to output console
		upp = UBOUND (output$[])
		FOR i = 0 TO upp
			IF output$[i] THEN
				Listbox_AddString (hListBox, LTRIM$ (output$[i]))
			END IF
		NEXT i

		Listbox_AddString (hListBox, "> Execution finished.")
	END IF

	IF CpOpt.BeepOnCompletion THEN MessageBeep ($$MB_ICONEXCLAMATION)

	SetFocus (GetEdit ())

	' restore environ variables
	XstSetEnvironmentVariable ("PATH", curPath$)
	XstSetEnvironmentVariable ("LIB", curLIB$)
	XstSetEnvironmentVariable ("INCLUDE", curINCLUDE$)
	XstSetEnvironmentVariable ("XBLDIR", curXBLDIR$)

	' Restore old directory
	IF (strCurDir$) THEN XstChangeDirectory (strCurDir$)

	' set fRanCompiler flag to 0 (did not run compiler)
'	fRanCompiler = $$FALSE
END FUNCTION
'
'
' ############################
' #####  ConsoleProc ()  #####
' ############################
'
' Output Console window procedure
'
FUNCTION ConsoleProc (hWnd, wMsg, wParam, lParam)

	SHARED hInst
	SHARED hListBox
	RECT rc
	SHARED hSplitter
	SHARED hFontSS8
	SHARED hWndMain
	SHARED fRanCompiler
	POINT pt
	UBYTE image[]
	SHARED hWndClient
	CompilerOptionsType CpOpt

	SELECT CASE wMsg

		CASE $$WM_CREATE :
			' create listbox control
			hListBox = NewChild ("listbox", "", $$LBS_HASSTRINGS | $$LBS_NOTIFY | $$LBS_NOINTEGRALHEIGHT | $$WS_VSCROLL, 0, 0, 0, 0, hWnd, $$IDC_LISTBOX, 0)
			' initialize font in listbox
			' maybe make this an option for user to choose
			hFontSS8 = NewFont ("Courier New", 9, $$FW_NORMAL, $$FALSE, $$FALSE)
			SetNewFont (hListBox, hFontSS8)

		CASE $$WM_CLOSE :
			SendMessageA (hSplitter, $$WM_DOCK_SPLITTER, 0, 0)

		CASE $$WM_COMMAND :
			id = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl = lParam

			SELECT CASE id
			  CASE $$IDM_CONSOLE_JUMP     : SendMessageA (hWnd, $$WM_COMMAND, MAKELONG($$IDC_LISTBOX, $$LBN_DBLCLK), hListBox)
        CASE $$IDM_CONSOLE_COPY     : CopyOutputConsoleToClipboard ()
        CASE $$IDM_CONSOLE_COPYLINE : selItem = SendMessageA (hListBox, $$LB_GETCURSEL, 0, 0)
							                        text$ = NULL$ (1024)
							                        SendMessageA (hListBox, $$LB_GETTEXT, selItem, &text$)
							                        text$ = CSIZE$ (text$)
							                        IF text$ THEN XstSetClipboard (1, @text$, @image[])

        CASE $$IDM_CONSOLE_CLEAR    : SendMessageA (hListBox, $$LB_RESETCONTENT, 0, 0)
        CASE $$IDM_CONSOLE_HIDE     : SendMessageA (hWnd, $$WM_CLOSE, 0, 0)
				CASE $$IDM_SHOWCONSOLE      : ShowWindow (hWnd, $$SW_SHOW)
			END SELECT

			SELECT CASE notifyCode
				CASE $$LBN_DBLCLK :
					SELECT CASE id :
						CASE $$IDC_LISTBOX :
							selItem = SendMessageA (hwndCtl, $$LB_GETCURSEL, 0, 0)
							text$ = NULL$ (1024)
							SendMessageA (hwndCtl, $$LB_GETTEXT, selItem, &text$)
							text$ = CSIZE$ (text$)
							IFZ text$ THEN RETURN

							' get path$, line, col
							err = ParseErrorMsg (text$, @path$, @line, @msg$, @column)
							IF err THEN RETURN

							' check special case if error is GoASM line number (full path$ is not returned from ParseErrorMsg)
							XstGetPathComponents (path$, @p$, "", "", "", 0)
							IFZ p$ THEN
								' see if asm file is currently active
								IF GetEdit () THEN
									fullpath$ = GetWindowText$ (MdiGetActive (hWndClient))
									XstGetPathComponents (fullpath$, @p$, "", "", @f$, @attributes)
									IF f$ = path$ THEN
										pos = SendMessageA (GetEdit (), $$SCI_FINDCOLUMN, line - 1, 0)
										SendMessageA (GetEdit (), $$SCI_GOTOPOS, pos, 0)
										SetFocus (GetEdit ())
										RETURN
									END IF
								END IF
							END IF

		          ' check if it is a *.dec file error message
		          GetFileExtension (path$, @fn$, @ext$)
		          IF UCASE$ (ext$) = "DEC" THEN     ' is it a dec file
                IFZ INSTR (path$, "\\") THEN    ' with no full path
                  GetCompilerOptions (@CpOpt)		' so look in \include folder
	                IF CpOpt.XBLPath THEN
		                comp$ = CpOpt.XBLPath
		                pos = INSTR (comp$, "bin")
		                IF pos THEN                 ' create path to \include folder
			                newPath$ = LEFT$ (comp$, pos - 1) + "include\\" + path$
		                END IF
                  END IF
									IFZ FileExist (newPath$) THEN   ' try looking in executable directory
										szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
										XstGetPathComponents (@szPath$, @newPath$, "", "", "", 0)
										newPath$ = newPath$ + path$
									END IF
									path$ = newPath$
                END IF
		          END IF

							' find mdi window corresponding to path$, activate it,
							' and then scroll to line & col
              hMdi = GetWindow (hWndClient, $$GW_CHILD)		' first look at already opened docs

              DO WHILE hMdi
		            text$ = GetWindowText$ (hMdi)
                IF UCASE$ (text$) = UCASE$ (path$) THEN		' if already opened
                  SendMessageA (hWndClient, $$WM_MDIACTIVATE, hMdi, 0)		' activate it
                  XstGetPathComponents (path$, "", "", "", @fn$, 0)
                  EnumMdiTitleToTab (fn$)   ' activate the associated tab
									IF line = -1 THEN					' message was from find in file search
										pos = column
									ELSE
										pos = SendMessageA (GetEdit (), $$SCI_FINDCOLUMN, line - 1, column - 1)
									END IF
									SendMessageA (GetEdit (), $$SCI_GOTOPOS, pos, 0)
									SetFocus (GetEdit ())
									RETURN
								END IF
								hMdi = GetWindow (hMdi, $$GW_HWNDNEXT)
							LOOP

							' at this point path$ is not currently open, so try to open file?
              IFZ OpenThisFile (path$) THEN RETURN
							IF line = -1 THEN							' message was from find in file search
								pos = column
							ELSE
								pos = SendMessageA (GetEdit (), $$SCI_FINDCOLUMN, line - 1, column - 1)
							END IF
							SendMessageA (GetEdit (), $$SCI_GOTOPOS, pos, 0)
							SetFocus (GetEdit ())
					END SELECT
			END SELECT

		CASE $$WM_SIZE :
			GetClientRect (hWnd, &rc)
			MoveWindow (hListBox, rc.left, rc.top, rc.right, rc.bottom - rc.top, $$TRUE)
			InvalidateRect (hListBox, NULL, $$TRUE)

		CASE $$WM_CONTEXTMENU :

			hPopupMenu = CreatePopupMenu ()
		  AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CONSOLE_JUMP, GetMenuTextAndBitmap ($$IDM_CONSOLE_JUMP, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CONSOLE_COPY, GetMenuTextAndBitmap ($$IDM_CONSOLE_COPY, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CONSOLE_COPYLINE, GetMenuTextAndBitmap ($$IDM_CONSOLE_COPYLINE, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CONSOLE_CLEAR, GetMenuTextAndBitmap ($$IDM_CONSOLE_CLEAR, 0))
			AppendMenuA (hPopupMenu, $$MF_ENABLED, $$IDM_CONSOLE_HIDE, GetMenuTextAndBitmap ($$IDM_CONSOLE_HIDE, 0))

			' AppendMenu (hPopupMenu, $$MF_SEPARATOR OR $$MF_OWNERDRAW, 0, "")

			ModifyMenuA (hPopupMenu, $$IDM_CONSOLE_JUMP, $$MF_OWNERDRAW, $$IDM_CONSOLE_JUMP, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CONSOLE_COPY, $$MF_OWNERDRAW, $$IDM_CONSOLE_COPY, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CONSOLE_COPYLINE, $$MF_OWNERDRAW, $$IDM_CONSOLE_COPYLINE, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CONSOLE_CLEAR, $$MF_OWNERDRAW, $$IDM_CONSOLE_CLEAR, NULL)
			ModifyMenuA (hPopupMenu, $$IDM_CONSOLE_HIDE, $$MF_OWNERDRAW, $$IDM_CONSOLE_HIDE, NULL)

			GetCursorPos (&pt)
			TrackPopupMenu (hPopupMenu, 0, pt.x, pt.y, 0, hWnd, 0)
			DestroyMenu (hPopupMenu)

		CASE $$WM_DRAWITEM :
			' The ownerdrawn menu needs to redraw
			IFZ wParam THEN				' If identifier is 0, message was sent by a menu
				DrawMenu (lParam)		' Draw the menu
				RETURN ($$TRUE)
			END IF

		CASE $$WM_MEASUREITEM :						' Get menu item size
			IFZ wParam THEN									' A menu is calling
				MeasureMenu (hWnd, lParam)		' Do all work in separate Sub
				RETURN ($$TRUE)
			END IF

		CASE ELSE : RETURN DefWindowProcA (hWnd, wMsg, wParam, lParam)
	END SELECT


END FUNCTION
'
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject ($$DEFAULT_GUI_FONT)		' get a font handle
	bytes = GetObjectA (hFont, SIZE (lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$		' set font name
	lf.italic = italic		' set italic
	lf.underline = underline		' set underline
	lf.weight = weight		' set weight
	lf.height = -1 * pointSize * GetDeviceCaps (hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)		' create a new font and get handle

END FUNCTION
'
'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION SetNewFont (hwndCtl, hFont)

	SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
'
'
' ##############################
' #####  ParseErrorMsg ()  #####
' ##############################
'
' Parse compiler error message into component parts.
' Return 0 on success, -1 on failure.
'
FUNCTION ParseErrorMsg (err$, @path$, @line, @msg$, @col)

	path$ = ""
	line = 0
	msg$ = ""
	col = 0
	IFZ err$ THEN RETURN ($$TRUE)

	' skip line if it begins with >
	IF err${0} = '>' THEN RETURN ($$TRUE)

	' skip line if it doesn't have )
	IFZ INSTR (err$, ")") THEN RETURN ($$TRUE)

	' check to see if it is a GoASM error line
	IF LEFT$(err$, 4) = "Line" THEN
		temp$ = MID$(err$, 6)
		pos = INSTR (MID$(err$, 6), " ")
		IF pos THEN
			line$ = LEFT$(temp$, pos-1)
			line = XLONG (line$)

			' now find file name (file)
			pos1 = INSTR (temp$, "(")
			IFZ pos1 THEN RETURN
			pos2 = INSTR (temp$, ")")
			IF pos2 <= pos1 THEN RETURN
			path$ = MID$ (temp$, pos1+1, pos2-pos1-1)
			RETURN
		END IF
	END IF



	' look for :
	p0 = RINSTR (err$, ":")
	IFZ p0 THEN RETURN ($$TRUE)

	' get path$ and line no
	p = INSTR (err$, "(")
	IF p THEN
		path$ = LEFT$ (err$, p - 1)
		p1 = INSTR (err$, ")")
		IF p1 > p THEN
			line$ = MID$ (err$, p + 1, p1 - p - 1)
			line = XLONG (line$)
		END IF
	ELSE
		RETURN ($$TRUE)
	END IF

	' get msg$ and column no
	m$ = LTRIM$ (MID$ (err$, p0 + 1))
	p = INSTR (m$, "(")
	IF p THEN
		msg$ = LEFT$ (m$, p - 1)
		p1 = INSTR (m$, ")")
		IF p1 > p THEN
			col$ = MID$ (m$, p + 1, p1 - p - 1)
			col = XLONG (col$)
		END IF
	END IF

END FUNCTION
'
' #########################################
' #####  ShowFoldingOptionsDialog ()  #####
' #########################################
'
' Folding Options popup dialog
'
FUNCTION ShowFoldingOptionsDialog (hParent)

	RECT rc
	WNDCLASSEX wcex
	SHARED hInst
	MSG msg
	FoldingOptionsType FoldOpt

	hFnt = GetStockObject ($$ANSI_VAR_FONT)

	szClassName$ = "Folding_Options"
	wcex.cbSize = SIZE (wcex)
	wcex.style = $$CS_HREDRAW OR $$CS_VREDRAW
	wcex.lpfnWndProc = &FoldingOptionsDlgProc ()
	wcex.cbClsExtra = 0
	wcex.cbWndExtra = 0
	wcex.hInstance = hInst
	wcex.hCursor = LoadCursorA (NULL, $$IDC_ARROW)
	wcex.hbrBackground = $$COLOR_3DFACE + 1
	wcex.lpszMenuName = NULL
	wcex.lpszClassName = &szClassName$
	wcex.hIcon = 0
	wcex.hIconSm = 0
	RegisterClassExA (&wcex)

	GetWindowRect (hParent, &rc)		' For centering child in parent
	rc.right = rc.right - rc.left		' Parent's width
	rc.bottom = rc.bottom - rc.top		' Parent's height

	szCaption$ = "Folding options"
	width = 392
	height = 210
	x = rc.left + (rc.right - width) / 2
	y = rc.top + (rc.bottom - height) / 2
	IF x < 0 THEN x = 10
	IF y < 0 THEN y = 10
	hWndPopup = CreateWindowExA ($$WS_EX_DLGMODALFRAME OR $$WS_EX_CONTROLPARENT, &szClassName$, &szCaption$, $$WS_CAPTION OR $$WS_POPUPWINDOW OR $$WS_VISIBLE, x, y, width, height, hParent, 0, hInst, NULL)

	hCtl = CreateWindowExA ($$WS_EX_TRANSPARENT, &"BUTTON", &" Folding style ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX, 10, 5, 180, 130, hWndPopup, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"  None ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON OR $$WS_TABSTOP OR $$WS_GROUP, 20, 30, 150, 20, hWndPopup, $$IDC_FOLDINGLEVELNONE, hInst, NULL)
	' Note: if several groups of Option controls are needed in a dialog,
	' add $$WS_TABSTOP OR $$WS_GROUP style to first control in each group.
	' and make sure at least one control in each group is checked via:
	' SendMessageA (hCtl, $$BM_SETCHECK, $$BST_CHECKED, 0)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)
	SetFocus (hCtl)

	hCtl = CreateWindowExA (0, &"BUTTON", &"  Keyword style ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON OR $$WS_TABSTOP, 20, 55, 150, 20, hWndPopup, $$IDC_FOLDINGLEVELKEYWORD, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_TRANSPARENT, &"BUTTON", &" Folding symbol ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX, 202, 5, 170, 130, hWndPopup, -1, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &" Arrow ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON OR $$WS_TABSTOP OR $$WS_GROUP, 212, 30, 150, 20, hWndPopup, $$IDC_FOLDINGSYMBOLARROW, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &" Plus/Minus ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON OR $$WS_TABSTOP, 212, 55, 150, 20, hWndPopup, $$IDC_FOLDINGSYMBOLPLUSMINUS, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &" Circle ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON OR $$WS_TABSTOP, 212, 80, 150, 20, hWndPopup, $$IDC_FOLDINGSYMBOLCIRCLE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &" Box tree ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON OR $$WS_TABSTOP, 212, 105, 150, 20, hWndPopup, $$IDC_FOLDINGSYMBOLBOXTREE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"&Apply", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_DEFPUSHBUTTON, 210, 150, 75, 23, hWndPopup, $$IDOK, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"&Close", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP, 297, 150, 75, 23, hWndPopup, $$IDCANCEL, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	GetFoldingOptions (@FoldOpt)

	IFZ FoldOpt.FoldingLevel THEN
		CheckDlgButton (hWndPopup, $$IDC_FOLDINGLEVELNONE, $$BST_CHECKED)
	ELSE
		IF FoldOpt.FoldingLevel = 1 THEN
			CheckDlgButton (hWndPopup, $$IDC_FOLDINGLEVELKEYWORD, $$BST_CHECKED)
		END IF
	END IF

	SELECT CASE FoldOpt.FoldingSymbol
		CASE 1 :
			CheckDlgButton (hWndPopup, $$IDC_FOLDINGSYMBOLARROW, $$BST_CHECKED)
		CASE 2 :
			CheckDlgButton (hWndPopup, $$IDC_FOLDINGSYMBOLPLUSMINUS, $$BST_CHECKED)
		CASE 3 :
			CheckDlgButton (hWndPopup, $$IDC_FOLDINGSYMBOLCIRCLE, $$BST_CHECKED)
		CASE 4 :
			CheckDlgButton (hWndPopup, $$IDC_FOLDINGSYMBOLBOXTREE, $$BST_CHECKED)
	END SELECT

	ShowWindow (hWndPopup, $$SW_SHOW)
	UpdateWindow (hWndPopup)

	DO WHILE GetMessageA (&msg, NULL, 0, 0)
		IFZ IsDialogMessageA (hDlg, &msg) THEN
			TranslateMessage (&msg)
			DispatchMessageA (&msg)
		END IF
	LOOP

	RETURN msg.wParam

END FUNCTION
'
' ######################################
' #####  FoldingOptionsDlgProc ()  #####
' ######################################
'
' Folding Options Dialog Procedure
'
FUNCTION FoldingOptionsDlgProc (hWnd, wMsg, wParam, lParam)

	FoldingOptionsType FoldOpt
	SHARED fFoldingOn

	SELECT CASE wMsg
		CASE $$WM_CREATE :
			EnableWindow (GetParent (hWnd), 0)		' To make the popup dialog modal

		CASE $$WM_COMMAND :
			SELECT CASE LOWORD (wParam)
				CASE $$IDOK :
					IF HIWORD (wParam) = $$BN_CLICKED THEN

						IF IsDlgButtonChecked (hWnd, $$IDC_FOLDINGLEVELNONE) THEN
							FoldOpt.FoldingLevel = 0
							fFoldingOn = $$FALSE
						END IF
						IF IsDlgButtonChecked (hWnd, $$IDC_FOLDINGLEVELKEYWORD) THEN
							FoldOpt.FoldingLevel = 1
							fFoldingOn = $$TRUE
						END IF

						SELECT CASE TRUE
							CASE IsDlgButtonChecked (hWnd, $$IDC_FOLDINGSYMBOLARROW) :
								FoldOpt.FoldingSymbol = 1
							CASE IsDlgButtonChecked (hWnd, $$IDC_FOLDINGSYMBOLPLUSMINUS) :
								FoldOpt.FoldingSymbol = 2
							CASE IsDlgButtonChecked (hWnd, $$IDC_FOLDINGSYMBOLCIRCLE) :
								FoldOpt.FoldingSymbol = 3
							CASE IsDlgButtonChecked (hWnd, $$IDC_FOLDINGSYMBOLBOXTREE) :
								FoldOpt.FoldingSymbol = 4
						END SELECT

						WriteFoldingOptions (@FoldOpt)

						' Retrieve the name of the file and set the control options
						IF GetEdit () THEN
							szPath$ = GetWindowText$ (GetParent (GetEdit ()))
							IF szPath$ THEN
								' Get direct pointer for faster access
								pSci = SendMessageA (GetEdit (), $$SCI_GETDIRECTPOINTER, 0, 0)
								IF pSci THEN Scintilla_SetOptions (pSci, szPath$)
								' ' Force the lexer to style the whole document
								' SciMsg(pSci, $$SCI_COLOURISE, 0, -1)
								' fold the entire doc
								IF fFoldingOn THEN
									FoldXBLDoc (GetEdit (), 0, -1, 0)
								ELSE
									UnFoldXBLDoc (GetEdit ())
								END IF
							END IF
						END IF
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						EXIT FUNCTION
					END IF
				CASE $$IDCANCEL :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						EXIT FUNCTION
					END IF
			END SELECT

		CASE $$WM_CLOSE :
			EnableWindow (GetParent (hWnd), 1)		' Maintains parent's zorder

		CASE $$WM_DESTROY :
			PostQuitMessage (0)		' This function closes the main window
			' by sending zero to the main message loop
			EXIT FUNCTION

	END SELECT

	RETURN DefWindowProcA (hWnd, wMsg, wParam, lParam)

END FUNCTION
'
' #############################
' #####  UnFoldXBLDoc ()  #####
' #############################
'
' Set all fold levels back to base level of 1024.
'
FUNCTION UnFoldXBLDoc (hEdit)

	' Get direct pointer for faster access
	pSci = SendMessageA (hEdit, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN RETURN

	lines = SciMsg (pSci, $$SCI_GETLINECOUNT, 0, 0)

	FOR i = 0 TO lines - 1
		SciMsg (pSci, $$SCI_SETFOLDLEVEL, i, 1024)
	NEXT i

END FUNCTION
'
' #############################
' #####  TerminateApp ()  #####
' #############################
'
' Purpose: Shut down a 32-Bit Process
'
' Parameters:
' dwPID: Process ID of the process to shut down.
' dwTimeout: Wait time in milliseconds before shutting down the process.
'
' Return Value:
' $$TA_FAILED - If the shutdown failed.
' $$TA_SUCCESS_CLEAN - If the process was shutdown using WM_CLOSE.
' $$TA_SUCCESS_KILL - if the process was shut down with TerminateProcess().
'
' Based on code from http://support.microsoft.com/kb/q178893/
' How To Terminate an Application "Cleanly" in Win32
'
FUNCTION TerminateApp (dwPID, dwTimeout)

	' If we can't open the process with PROCESS_TERMINATE rights,
	' then we give up immediately.
	hProc = OpenProcess ($$SYNCHRONIZE | $$PROCESS_TERMINATE, $$FALSE, dwPID)

	IF (hProc == NULL) THEN RETURN $$TA_FAILED

	' TerminateAppEnum() posts WM_CLOSE to all windows whose PID
	' matches your process's.
	EnumWindows (&TerminateAppEnum (), dwPID)

	' Wait on the handle. If it signals, great. If it times out,
	' then you kill it.
	IF (WaitForSingleObject (hProc, dwTimeout) != $$WAIT_OBJECT_0) THEN
		dwRet = TerminateProcess (hProc, 0)		' ?TA_SUCCESS_KILL:TA_FAILED);
		IF dwRet THEN
			dwRet = $$TA_SUCCESS_KILL
		ELSE
			dwRet = $$TA_FAILED
		END IF
	ELSE
		dwRet = $$TA_SUCCESS_CLEAN
	END IF

	CloseHandle (hProc)

	RETURN dwRet
END FUNCTION
'
'
FUNCTION TerminateAppEnum (hwnd, lParam)

	GetWindowThreadProcessId (hwnd, &dwID)

	IF (dwID == lParam) THEN PostMessageA (hwnd, $$WM_CLOSE, 0, 0)

	RETURN (1)
END FUNCTION
'
' ###########################
' #####  PrintSetup ()  #####
' ###########################
'
' Display Printer Setup Dialog
'
FUNCTION PrintSetup (hWnd)

	SHARED hInst
	SHARED RECT pagesetupMargin
	SHARED hDevMode
	SHARED hDevNames

	PAGESETUPDLG pdlg

	pdlg.lStructSize = SIZE (pdlg)
	pdlg.hwndOwner = hWnd
	pdlg.hInstance = hInst

	IF (pagesetupMargin.left != 0 || pagesetupMargin.right != 0 || pagesetupMargin.top != 0 || pagesetupMargin.bottom != 0) THEN
		pdlg.flags = $$PSD_MARGINS
		pdlg.rtMargin.left = pagesetupMargin.left
		pdlg.rtMargin.top = pagesetupMargin.top
		pdlg.rtMargin.right = pagesetupMargin.right
		pdlg.rtMargin.bottom = pagesetupMargin.bottom
	END IF

	pdlg.hDevMode = hDevMode
	pdlg.hDevNames = hDevNames

	IF (!PageSetupDlgA (&pdlg)) THEN RETURN

	pagesetupMargin.left = pdlg.rtMargin.left
	pagesetupMargin.top = pdlg.rtMargin.top
	pagesetupMargin.right = pdlg.rtMargin.right
	pagesetupMargin.bottom = pdlg.rtMargin.bottom

	hDevMode = pdlg.hDevMode
	hDevNames = pdlg.hDevNames

	RETURN ($$TRUE)

END FUNCTION
'
' ######################
' #####  Print ()  #####
' ######################
'
' Display the Print dialog (if param showDialog asks it),
' allowing it to choose what to print on which printer.
' If OK, print the user choice, with optionally defined header and footer.
' Parameters:
' hWnd - owner window handle
' showDialog - false if must print silently (using default settings)
'
FUNCTION Print (hWnd, showDialog)

	SHARED hInst
	SHARED hWndClient
	SHARED RECT pagesetupMargin
	SHARED hDevMode
	SHARED hDevNames
	TEXTRANGE crange
	SHARED fPrintingColorMode
	SHARED fPrintingMagnification

	PRINTDLG pdlg
	RECT rectMargins, rectPhysMargins
	POINT ptPage, ptDpi
	RECT rectSetup
	UBYTE localeInfo[3]
	TEXTMETRIC tm
	DOCINFO di
	RangeToFormat frPrint
	RECT rcw
	STATIC init

	' set printer options (magnification & color mode)
	GetPrintingOptions ()
	IF fPrintingMagnification THEN
		SendMessageA (GetEdit(), $$SCI_SETPRINTMAGNIFICATION, fPrintingMagnification, 0)
	END IF
	SendMessageA (GetEdit(), $$SCI_SETPRINTCOLOURMODE, fPrintingColorMode, 0)

	' initialize printer setup to get margins
	IFZ init THEN
		init = $$TRUE
		PrintSetup (hWnd)
	END IF

	pdlg.lStructSize = SIZE (pdlg)
	pdlg.hwndOwner = hWnd
	pdlg.hInstance = hInst
	pdlg.flags = $$PD_USEDEVMODECOPIES | $$PD_ALLPAGES | $$PD_RETURNDC
	pdlg.nFromPage = 1
	pdlg.nToPage = 1
	pdlg.nMinPage = 1
	pdlg.nMaxPage = 0xffff		' We do not know how many pages in the
	' document until the printer is selected and the paper size is known.
	pdlg.nCopies = 1
	pdlg.hdc = 0
	pdlg.hDevMode = hDevMode
	pdlg.hDevNames = hDevNames

	' See if a range has been selected
	crange = GetSelection ()
	startPos = crange.chrg.cpMin
	endPos = crange.chrg.cpMax

	IF (startPos == endPos) THEN
		pdlg.flags = pdlg.flags | $$PD_NOSELECTION
	ELSE
		pdlg.flags = pdlg.flags | $$PD_SELECTION
	END IF

	IF (!showDialog) THEN
		' Don't display dialog box, just use the default printer and options
		pdlg.flags = pdlg.flags | $$PD_RETURNDEFAULT
		pdlg.hDevMode = NULL
		pdlg.hDevNames = NULL
	END IF

	IF !PrintDlgA (&pdlg) THEN
		' PRINT "PrintDlgA error"
		' error = CommDlgExtendedError ()
		' PRINT "error="; error
		' PRINT error$
		RETURN
	END IF

	hDevMode = pdlg.hDevMode
	hDevNames = pdlg.hDevNames

	hdc = pdlg.hdc

	' Get printer resolution
	ptDpi.x = GetDeviceCaps (hdc, $$LOGPIXELSX)		' dpi in X direction
	ptDpi.y = GetDeviceCaps (hdc, $$LOGPIXELSY)		' dpi in Y direction

	' Start by getting the physical page size (in device units).
	ptPage.x = GetDeviceCaps (hdc, $$PHYSICALWIDTH)		' device units
	ptPage.y = GetDeviceCaps (hdc, $$PHYSICALHEIGHT)		' device units

	' Get the dimensions of the unprintable
	' part of the page (in device units).
	rectPhysMargins.left = GetDeviceCaps (hdc, $$PHYSICALOFFSETX)
	rectPhysMargins.top = GetDeviceCaps (hdc, $$PHYSICALOFFSETY)

	' To get the right and lower unprintable area,
	' we take the entire width and height of the paper and
	' subtract everything else.
	rectPhysMargins.right = ptPage.x - GetDeviceCaps (hdc, $$HORZRES) - rectPhysMargins.left		' left unprintable margin
	rectPhysMargins.bottom = ptPage.y - GetDeviceCaps (hdc, $$VERTRES) - rectPhysMargins.top		' right unprintable margin

	' At this point, rectPhysMargins contains the widths of the
	' unprintable regions on all four sides of the page in device units.

	' Take in account the page setup given by the user (IF one value is not null)
	IF (pagesetupMargin.left != 0 || pagesetupMargin.right != 0 || pagesetupMargin.top != 0 || pagesetupMargin.bottom != 0) THEN

		' Convert the hundredths of millimeters (HiMetric) or
		' thousandths of inches (HiEnglish) margin values
		' from the Page Setup dialog to device units.
		' (There are 2540 hundredths of a mm in an inch.)

		GetLocaleInfoA ($$LOCALE_USER_DEFAULT, $$LOCALE_IMEASURE, &localeInfo[], SIZE (localeInfo[]))

		IF (localeInfo[0] == '0') THEN		' Metric system. '1' is US System
			rectSetup.left = MulDiv (pagesetupMargin.left, ptDpi.x, 2540)
			rectSetup.top = MulDiv (pagesetupMargin.top, ptDpi.y, 2540)
			rectSetup.right = MulDiv (pagesetupMargin.right, ptDpi.x, 2540)
			rectSetup.bottom = MulDiv (pagesetupMargin.bottom, ptDpi.y, 2540)
		ELSE
			rectSetup.left = MulDiv (pagesetupMargin.left, ptDpi.x, 1000)
			rectSetup.top = MulDiv (pagesetupMargin.top, ptDpi.y, 1000)
			rectSetup.right = MulDiv (pagesetupMargin.right, ptDpi.x, 1000)
			rectSetup.bottom = MulDiv (pagesetupMargin.bottom, ptDpi.y, 1000)
		END IF

		' Dont reduce margins below the minimum printable area
		rectMargins.left = MAX (rectPhysMargins.left, rectSetup.left)
		rectMargins.top = MAX (rectPhysMargins.top, rectSetup.top)
		rectMargins.right = MAX (rectPhysMargins.right, rectSetup.right)
		rectMargins.bottom = MAX (rectPhysMargins.bottom, rectSetup.bottom)
	ELSE
		rectMargins.left = rectPhysMargins.left
		rectMargins.top = rectPhysMargins.top
		rectMargins.right = rectPhysMargins.right
		rectMargins.bottom = rectPhysMargins.bottom
	END IF

	' rectMargins now contains the values used to shrink the printable
	' area of the page.

	' Convert device coordinates into logical coordinates
	DPtoLP (hdc, &rectMargins, 2)
	DPtoLP (hdc, &rectPhysMargins, 2)

	' Convert page size to logical units and we're done!
	DPtoLP (hdc, &ptPage, 1)

	' Get the path from the window caption, use as name of print job
	file$ = GetWindowText$ (MdiGetActive (hWndClient))
	XstGetPathComponents (file$, @path$, @drive$, @dir$, @filename$, @attributes)

	XstGetDateAndTimeFormatted (0, 1, @date$, 5, @time$)
	headerFormat$ = filename$
	headerFormat$ = headerFormat$ + " - Printed on " + date$ + " " + time$
	headerFormat$ = headerFormat$ + " - Page "

	GetFileInfo (file$, @created$, @modified$, @size)
	footerFormat$ = file$
	footerFormat$ = footerFormat$ + " - Created: " + created$
	footerFormat$ = footerFormat$ + " - Modified: " + modified$
	footerFormat$ = footerFormat$ + " - Size: " + STRING$ (size) + "kb"

	headerBold = $$TRUE

	IFZ headerSize THEN headerSize = 12
	IFZ headerBold THEN
		headerBold = $$FW_NORMAL
	ELSE
		headerBold = $$FW_BOLD
	END IF
	IFZ headerFont$ THEN headerFont$ = "Arial"
	IF headerTextColor = 0 && headerBkColor = 0 THEN
		headerTextColor = $$Black
		headerBkColor = $$White
	END IF

	headerLineHeight = MulDiv (headerSize, ptDpi.y, 72)
	fontHeader = CreateFontA (headerLineHeight, 0, 0, 0, headerBold, headerItalics, headerUnderlined, 0, 0, 0, 0, 0, 0, &headerFont$)

	SelectObject (hdc, fontHeader)
	GetTextMetricsA (hdc, &tm)
	headerLineHeight = tm.height + tm.externalLeading

	footerItalics = $$TRUE

	IFZ footerSize THEN footerSize = 10
	IFZ footerBold THEN
		footerBold = $$FW_NORMAL
	ELSE
		footerBold = $$FW_BOLD
	END IF
	IFZ footerFont$ THEN footerFont$ = "Arial Narrow"
	IF footerTextColor = 0 && footerBkColor = 0 THEN
		footerTextColor = $$Black
		footerBkColor = $$White
	END IF

	footerLineHeight = MulDiv (footerSize, ptDpi.y, 72)
	fontFooter = CreateFontA (footerLineHeight, 0, 0, 0, footerBold, footerItalics, footerUnderlined, 0, 0, 0, 0, 0, 0, &footerFont$)
	SelectObject (hdc, fontFooter)
	GetTextMetricsA (hdc, &tm)
	footerLineHeight = tm.height + tm.externalLeading

	di.size = SIZE (di)
	jobName$ = filename$
	IFZ jobName$ THEN jobName$ = "XSED Print Job"
	di.docName = &jobName$
	di.output = 0
	di.dataType = 0
	di.type = 0
	IF (StartDocA (hdc, &di) < 0) THEN
		msg$ = "Can not start printer document.   "
		MessageBoxA (hWnd, &msg$, &" Print", $$MB_OK)
		RETURN
	END IF

	lengthDoc = SendMessageA (GetEdit (), $$SCI_GETLENGTH, 0, 0)
	lengthDocMax = lengthDoc
	lengthPrinted = 0

	' Requested to print selection
	IF (pdlg.flags & $$PD_SELECTION) THEN
		IF (startPos > endPos) THEN
			lengthPrinted = endPos
			lengthDoc = startPos
		ELSE
			lengthPrinted = startPos
			lengthDoc = endPos
		END IF

		IF (lengthPrinted < 0) THEN lengthPrinted = 0
		IF (lengthDoc > lengthDocMax) THEN lengthDoc = lengthDocMax
	END IF

	' We must substract the physical margins from the printable area

	frPrint.hdc = hdc
	frPrint.hdcTarget = hdc
	frPrint.rc.left = rectMargins.left - rectPhysMargins.left
	frPrint.rc.top = rectMargins.top - rectPhysMargins.top
	frPrint.rc.right = ptPage.x - rectMargins.right - rectPhysMargins.left
	frPrint.rc.bottom = ptPage.y - rectMargins.bottom - rectPhysMargins.top
	frPrint.rcPage.left = 0
	frPrint.rcPage.top = 0
	frPrint.rcPage.right = ptPage.x - rectPhysMargins.left - rectPhysMargins.right - 1
	frPrint.rcPage.bottom = ptPage.y - rectPhysMargins.top - rectPhysMargins.bottom - 1
	IF headerSize THEN
		frPrint.rc.top = frPrint.rc.top + headerLineHeight + headerLineHeight / 2
	END IF
	IF footerSize THEN
		frPrint.rc.bottom = frPrint.rc.bottom - footerLineHeight + footerLineHeight / 2
	END IF

	' Print each page
	pageNum = 1
	' bool printPage;
	' PropSet propsPrint;
	' propsPrint.superPS = &props;
	' SetFileProperties(propsPrint);

	DO WHILE (lengthPrinted < lengthDoc)
		printPage = (!(pdlg.flags & $$PD_PAGENUMS) || (pageNum >= pdlg.nFromPage) && (pageNum <= pdlg.nToPage))

		' get page number string for footer format
		' char pageString[32];
		pageString$ = NULL$ (32)
		sprintf (&pageString$, &"%0d", pageNum)
		pageString$ = CSIZE$ (pageString$)

		IF (printPage) THEN
			StartPage (hdc)

			IF (headerSize) THEN
				sHeader$ = headerFormat$ + pageString$
				SetTextColor (hdc, headerTextColor)
				SetBkColor (hdc, headerBkColor)
				SelectObject (hdc, fontHeader)
				ta = SetTextAlign (hdc, $$TA_BOTTOM)
				rcw.left = frPrint.rc.left
				rcw.top = frPrint.rc.top - headerLineHeight - headerLineHeight / 2
				rcw.right = frPrint.rc.right
				rcw.bottom = frPrint.rc.top - headerLineHeight / 2
				rcw.bottom = rcw.top + headerLineHeight
				ExtTextOutA (hdc, frPrint.rc.left + 5, frPrint.rc.top - headerLineHeight / 2, $$ETO_OPAQUE, &rcw, &sHeader$, LEN (sHeader$), NULL)
				SetTextAlign (hdc, ta)
				pen = CreatePen (0, 1, headerTextColor)
				penOld = SelectObject (hdc, pen)
				MoveToEx (hdc, frPrint.rc.left, frPrint.rc.top - headerLineHeight / 4, NULL)
				LineTo (hdc, frPrint.rc.right, frPrint.rc.top - headerLineHeight / 4)
				SelectObject (hdc, penOld)
				DeleteObject (pen)
			END IF
		END IF

		frPrint.chrg.cpMin = lengthPrinted
		frPrint.chrg.cpMax = lengthDoc

		lengthPrinted = SendMessageA (GetEdit (), $$SCI_FORMATRANGE, printPage, &frPrint)

		IF (printPage) THEN
			IF footerSize THEN
				sFooter$ = footerFormat$
				SetTextColor (hdc, footerTextColor)
				SetBkColor (hdc, footerBkColor)
				SelectObject (hdc, fontFooter)
				ta = SetTextAlign (hdc, $$TA_TOP)
				rcw.left = frPrint.rc.left
				rcw.top = frPrint.rc.bottom + footerLineHeight / 2
				rcw.right = frPrint.rc.right
				rcw.bottom = frPrint.rc.bottom + footerLineHeight + footerLineHeight / 2
				ret = ExtTextOutA (hdc, frPrint.rc.left + 5, frPrint.rc.bottom + footerLineHeight / 2, $$ETO_OPAQUE, &rcw, &sFooter$, LEN (sFooter$), NULL)
				SetTextAlign (hdc, ta)
				pen = CreatePen (0, 1, footerTextColor)
				penOld = SelectObject (hdc, pen)
				SetBkColor (hdc, footerBkColor)
				MoveToEx (hdc, frPrint.rc.left, frPrint.rc.bottom + footerLineHeight / 4, NULL)
				LineTo (hdc, frPrint.rc.right, frPrint.rc.bottom + footerLineHeight / 4)
				SelectObject (hdc, penOld)
				DeleteObject (pen)
			END IF

			EndPage (hdc)
		END IF
		INC pageNum

		IF ((pdlg.flags & $$PD_PAGENUMS) && (pageNum > pdlg.nToPage)) THEN EXIT DO

	LOOP

	SendMessageA (GetEdit (), $$SCI_FORMATRANGE, $$FALSE, 0)

	EndDoc (hdc)
	DeleteDC (hdc)
	IF (fontHeader) THEN DeleteObject (fontHeader)
	IF (fontFooter) THEN DeleteObject (fontFooter)

END FUNCTION
'
' #############################
' #####  GetSelection ()  #####
' #############################
'
' Get currently selected text range from
' active mdi window.
'
FUNCTION TEXTRANGE GetSelection ()
	TEXTRANGE crange
	crange.chrg.cpMin = SendMessageA (GetEdit (), $$SCI_GETSELECTIONSTART, 0, 0)
	crange.chrg.cpMax = SendMessageA (GetEdit (), $$SCI_GETSELECTIONEND, 0, 0)
	RETURN crange
END FUNCTION
'
' ############################
' #####  GetFileInfo ()  #####
' ############################
'
' Return file creation date, file modifed date, and size.
'
FUNCTION GetFileInfo (file$, @created$, @modified$, @bytes)

	' define constant
	$MaxDword = 0xFFFF

	' assign FILEINFOR TYPE struct to fi[]
	FILEINFO fi[]

	created$ = ""
	modified$ = ""
	bytes = 0

	IFZ file$ THEN RETURN ($$TRUE)

	maxLen = XstGetFilesAndAttributes (file$, -1, @files$[], @fi[])

	upp = UBOUND (files$[])
	IF upp = -1 THEN
		' PRINT "No file found"
		RETURN ($$TRUE)
	END IF

	' get size of file in kb
	' file size in bytes = sizeHigh * $MaxDword + sizeLow
	bytes = ((fi[0].sizeHigh * $MaxDword + fi[0].sizeLow) / 1024.0) + 0.5

	' create giant argument for fileTime$$ from high and low filetime values from fi[]
	fileTimeMod$$ = GMAKE (fi[0].modifyTimeHigh, fi[0].modifyTimeLow)
	fileTimeCreate$$ = GMAKE (fi[0].createTimeHigh, fi[0].createTimeLow)

	FileTimeToLocalFileTime (&fileTimeMod$$, &fileTimeModLocal$$)
	FileTimeToLocalFileTime (&fileTimeCreate$$, &fileTimeCreateLocal$$)

	' convert fileTime$$ to system time
	XstFileTimeToDateAndTime (fileTimeModLocal$$, @year, @month, @day, @hour, @minute, @second, @nanos)
	GOSUB FormatTimeStamp
	modified$ = timeStamp$

	XstFileTimeToDateAndTime (fileTimeCreateLocal$$, @year, @month, @day, @hour, @minute, @second, @nanos)
	GOSUB FormatTimeStamp
	created$ = timeStamp$

SUB FormatTimeStamp
	timeStamp$ = ""
	month$ = ""
	day$ = ""
	date$ = ""
	hour$ = ""
	minute$ = ""
	second$ = ""
	time$ = ""
	month$ = STRING$ (month)
	IF LEN (month$) < 2 THEN month$ = "0" + month$
	day$ = STRING$ (day)
	IF LEN (day$) < 2 THEN day$ = "0" + day$
	date$ = month$ + "/" + day$ + "/" + STRING$ (year)
	hour$ = STRING$ (hour)
	IF LEN (hour$) < 2 THEN hour$ = "0" + hour$
	minute$ = STRING$ (minute)
	IF LEN (minute$) < 2 THEN minute$ = "0" + minute$
	second$ = STRING$ (second)
	IF LEN (second$) < 2 THEN second$ = "0" + second$
	time$ = hour$ + ":" + minute$ + ":" + second$
	timeStamp$ = date$ + " " + time$
END SUB

END FUNCTION
'
'
' ########################################
' #####  CommandLineInputBoxProc ()  #####
' ########################################
'
' Return address of users text entry in editbox.
'
FUNCTION CommandLineInputBoxProc (hwndDlg, msg, wParam, lParam)

	STATIC text$

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			IF text$ THEN SetDlgItemTextA (hwndDlg, 202, &text$)
			XstCenterWindow (hwndDlg)

		CASE $$WM_CTLCOLORDLG, $$WM_CTLCOLORBTN, $$WM_CTLCOLORSTATIC :
			RETURN SetColor (0, RGB (192, 192, 192), wParam, lParam)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD (wParam)
			ID = LOWORD (wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID :

						CASE $$IDCANCEL :
							EndDialog (hwndDlg, 0)

						CASE $$IDOK:
							text$ = NULL$ (2047)
							GetDlgItemTextA (hwndDlg, 202, &text$, LEN (text$))
							text$ = CSIZE$ (text$)
							IF text$ THEN
								EndDialog (hwndDlg, &text$)
							ELSE
								EndDialog (hwndDlg, 0)
							END IF

					END SELECT
			END SELECT

		CASE ELSE : RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION SetColor (txtColor, bkColor, wParam, lParam)
	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush (bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush
END FUNCTION
'
' #################################
' #####  SED_FormatRegion ()  #####
' #################################
'
' Formats and indents the selected region.
' Only whole lines of code are formatted.
'
FUNCTION SED_FormatRegion (hWnd)

	SHARED hWndClient

	msg$ = "Are you sure you want to reformat the selected text?   "
	IF MessageBoxA (hWnd, &msg$, &" Format Region", $$MB_YESNO OR $$MB_ICONQUESTION OR $$MB_APPLMODAL) = $$IDNO THEN RETURN

	szPath$ = GetWindowText$ (MdiGetActive (hWndClient))

	' validate file extension, is xb file?
	GetFileExtension (@szPath$, "", @ext$)
	SELECT CASE UCASE$(ext$)
		CASE "X", "XBL", "XL" :
		CASE ELSE :
			msg$ = "The active file is not a valid XBLite file!   "
			MessageBoxA (hWnd, &msg$, &" Format Region", $$MB_OK OR $$MB_ICONEXCLAMATION OR $$MB_APPLMODAL)
			RETURN
	END SELECT

	' backup source file
	msg$ = "Do you want to first backup the active file?   "
	IF MessageBoxA (hWnd, &msg$, &" Format Region", $$MB_YESNO OR $$MB_ICONQUESTION OR $$MB_APPLMODAL) = $$IDYES THEN
		bak$ = LEFT$ (szPath$, x) + "bakf"
		IF XstCopyFile (szPath$, bak$) THEN RETURN ($$TRUE)
	END IF

	hEdit = GetEdit ()
	IFZ hEdit THEN RETURN
	startPos = SendMessageA (hEdit, $$SCI_GETSELECTIONSTART, 0, 0)
	endPos = SendMessageA (hEdit, $$SCI_GETSELECTIONEND, 0, 0)
	startLine = SendMessageA (hEdit, $$SCI_LINEFROMPOSITION, startPos, 0)
	endLine = SendMessageA (hEdit, $$SCI_LINEFROMPOSITION, endPos, 0)

	FOR i = startLine TO endLine
		len = SendMessageA (hEdit, $$SCI_LINELENGTH, i, 0)		' length of the line
		line$ = NULL$ (len)		' size the buffer
		SendMessageA (hEdit, $$SCI_GETLINE, i, &line$)		' get the text of the line
		code$ = code$ + line$		' build code string
	NEXT i

	FormatCode (@code$, $$TRUE)		' format the lines of code

	' lose the last CRLF
	code$ = RTRIM$ (code$)

	' set current position to the end of last line
	end = SendMessageA (hEdit, $$SCI_GETLINEENDPOSITION, endLine, 0)
	SendMessageA (hEdit, $$SCI_GOTOPOS, end, 0)

	' set the anchor to the beginning of the first line
	start = SendMessageA (hEdit, $$SCI_POSITIONFROMLINE, startLine, 0)
	SendMessageA (hEdit, $$SCI_SETANCHOR, start, 0)

	' replace the selection
	SendMessageA (hEdit, $$SCI_REPLACESEL, 0, &code$)

END FUNCTION
'
'
' ###########################
' #####  FormatCode ()  #####
' ###########################
'
' Indent code based on keywords.
' If fIndentComment is $$TRUE, then indent all
' commented lines at same level of indentation
' as previous line.
'
FUNCTION FormatCode (@code$, fIndentComment)

	IFZ code$ THEN RETURN ($$TRUE)
	XstStringToStringArray (code$, @code$[])

	upp = UBOUND (code$[])
	indentCount = 0
	FOR i = 0 TO upp
		line$ = code$[i]
		IFZ line$ THEN DO NEXT
		IndentTheLine (@line$, @newLine$, fIndentComment, @indentCount)
		code$[i] = newLine$
	NEXT i

	XstStringArrayToStringCRLF (@code$[], @code$)

END FUNCTION
'
'
' ##############################
' #####  IndentTheLine ()  #####
' ##############################
'
' Indent current line.
'
FUNCTION IndentTheLine (@sourceLine$, @newLine$, fIndentComment, @indentCount)

	' remove any commented code
	SplitOffComment (@sourceLine$, @code$, @comment$)

	' format code
	wsCode$ = WhiteSpaceTheLine$ (@code$)

	' indent code
	CalculateTheIndentAndOutputTheLine (@wsCode$, @comment$, @newLine$, fIndentComment, @indentCount)

END FUNCTION
'
'
' ###################################################
' #####  CalculateTheIndentAndOutputTheLine ()  #####
' ###################################################
'
FUNCTION CalculateTheIndentAndOutputTheLine (@source$, @comment$, @newLine$, fIndentComment, @indentCount)

	firstWord$ = XstNextField$ (source$, @index, @done)
	firstPhrase$ = firstWord$ + " " + XstNextField$ (source$, @index, @done)

	index = 0
	done = 0
	DO
		prevWord$ = lastWord$
		lastWord$ = XstNextField$ (source$, @index, @done)
	LOOP UNTIL done
	lastWord$ = prevWord$

	SELECT CASE firstWord$
			' Check for keywords that decrement the indent
		CASE "CASE", "ELSE", "END", "LOOP", "NEXT", "ENDIF", "SUB" :
			DEC indentCount
			' If this is an END SELECT then decrement it again unless the previous line was a END SELECT
			IF (firstPhrase$ = "END SELECT") THEN DEC indentCount
	END SELECT

	IF indentCount < 0 THEN indentCount = 0

	' identify GOTO labels - do not indent
	IF RIGHT$ (firstWord$, 1) = ":" THEN fLabel = $$TRUE

	' output newLine$
	SELECT CASE TRUE
		CASE fLabel :		' do not indent labels
			IF comment$ THEN
				newLine$ = source$ + $$TAB_TAB + comment$
			ELSE
				newLine$ = source$
			END IF
		CASE source$ = "" :
			IF LEFT$ (comment$, 1) = "?" THEN		' do not indent ASM lines
				newLine$ = comment$
			ELSE
				IF fIndentComment THEN
					IF comment$ THEN
						comment$ = "' " + LTRIM$ (MID$ (comment$, 2))
						newLine$ = CHR$ (9, indentCount) + comment$
					ELSE
						newLine$ = ""
					END IF
				ELSE
					newLine$ = comment$
				END IF
			END IF
		CASE comment$ = "" : newLine$ = CHR$ (9, indentCount) + source$
		CASE ELSE : newLine$ = CHR$ (9, indentCount) + source$ + $$TAB_TAB + comment$
	END SELECT

	SELECT CASE firstWord$
		CASE "CASE", "ELSE", "SUB", "UNION" :
			INC indentCount
		CASE "TYPE" :
			IFZ INSTR (source$, "=") THEN INC indentCount
		CASE "SELECT"
			INC indentCount
			INC indentCount
		CASE "FUNCTION"
			INC indentCount
		CASE "FOR"
			IFZ INSTR (source$, "NEXT ") THEN INC indentCount
		CASE "DO"
			IF INSTR (source$, " LOOP", 3) = 0 && INSTR (source$, " DO", 3) = 0 && INSTR (source$, " NEXT", 3) = 0 && INSTR (source$, " FOR", 3) = 0 THEN
				INC indentCount
			END IF
	END SELECT
	IF lastWord$ = "THEN" THEN INC indentCount

END FUNCTION
'
'
' ################################
' #####  SplitOffComment ()  #####
' ################################
'
' Split source line into code and comment component strings.
'
FUNCTION SplitOffComment (@sourceString$, @code$, @comment$)

	IFZ sourceString$ THEN RETURN

	fQuotedMaterial = $$FALSE
	source$ = TRIM$ (sourceString$)

	IFZ source$ THEN
		code$ = source$
		comment$ = ""
		RETURN
	END IF

	' Check if the line only has a comment or is an ASM line
	IF LEFT$ (source$, 1) = "'" || LEFT$ (source$, 1) = "?" THEN
		code$ = ""
		comment$ = source$
		RETURN
	END IF

	' Find the comment start if any
	nextCh = ASC (source$, 1)
	ch = ' '
	upp = LEN (source$)

	FOR pos = 1 TO upp

		' prevCh = ch
		ch = nextCh
		nextCh = ' '

		IF pos + 1 <= upp THEN nextCh = ASC (source$, pos + 1)

		SELECT CASE ch
			CASE '\"' : fQuotedMaterial = NOT fQuotedMaterial

			CASE '\t' :

			CASE ''' :
				skip = IsCharLiteral (@source$, pos)
				IF skip THEN		' it is a char literal
					pos = pos + skip
					IF pos > upp THEN EXIT FOR
					nextCh = ' '
					IF pos + 1 <= upp THEN nextCh = ASC (source$, pos + 1)
					DO NEXT
				ELSE
					IF fQuotedMaterial = $$FALSE THEN
						' Break up the line
						code$ = TRIM$ (LEFT$ (source$, pos - 1))
						comment$ = TRIM$ (MID$ (source$, pos))
						RETURN
					END IF
				END IF
		END SELECT

	NEXT pos
	' No comment found
	code$ = source$
	comment$ = ""

END FUNCTION
'
'
' ##############################
' #####  IsCharLiteral ()  #####
' ##############################
'
' Determine if char ' at pos is part of char literal
' string within string s$.
' Return value is 0 if not literal char string
' and not 0 if it is part of a literal char string
' (or optionally the number of chars to skip after initial ' pos
' if you want to jump over a literal string).
'
FUNCTION IsCharLiteral (s$, pos)

	upp = LEN (s$)

	nextCh = ' '
	nextCh2 = ' '
	nextCh3 = ' '
	IF pos + 1 <= upp THEN nextCh = ASC (s$, pos + 1)
	IF pos + 2 <= upp THEN nextCh2 = ASC (s$, pos + 2)		' get next char
	IF pos + 3 <= upp THEN nextCh3 = ASC (s$, pos + 3)		' get next char

	chPrev = ' '
	chPrev2 = ' '
	chPrev3 = ' '
	IF pos - 1 >= 1 THEN chPrev = ASC (s$, pos - 1)
	IF pos - 2 >= 1 THEN chPrev2 = ASC (s$, pos - 2)
	IF pos - 3 >= 1 THEN chPrev3 = ASC (s$, pos - 3)

	SELECT CASE nextCh
		CASE '\\' :		' we have '\
			IF nextCh3 = ''' THEN RETURN (3)		' we have '\char'

		CASE ELSE :		' we have 'char
			IF nextCh2 = ''' THEN RETURN (2)		' we have 'char'
	END SELECT

	SELECT CASE chPrev
		CASE '\\' :		' we could have \' or '\'' or '\\'
			IF nextCh = ''' && chPrev2 = ''' THEN RETURN ($$TRUE)		' we have '\''
			IF chPrev2 = '\\' && chPrev3 = ''' THEN RETURN ($$TRUE)		' we have '\\'

		CASE ELSE :
			IF chPrev2 = ''' THEN RETURN ($$TRUE)		' we have 'char'
			IF chPrev2 = '\\' && chPrev3 = ''' THEN RETURN ($$TRUE)		' we have '\char'
	END SELECT

	RETURN ($$FALSE)

END FUNCTION
'
'
' ###################################
' #####  WhiteSpaceTheLine$ ()  #####
' ###################################
'
' Add white space to properly format a de-commented line.
'
FUNCTION WhiteSpaceTheLine$ (line$)

	IFZ line$ THEN EXIT FUNCTION
	s$ = line$
	XstReplace (@s$, $$TAB, $$SINGLE_SPACE, 0)

	' split line into sections based on double-quote
	' skip over double-quoted strings

	pos = 0
	posStart = pos
	lineBuffer$ = ""
	len = LEN (s$)
	qType = 0
	DO
		pos = FindNextQuote (@s$, pos + 1, @qType)
		IF pos = len THEN atEnd = $$TRUE

		IF pos THEN
			SELECT CASE qType
				CASE $$DQ :
					IF fSQ THEN DO LOOP
					IF IsStringQuote (s$, pos) THEN
						fDQ = NOT fDQ
						INC quoteCount
						posEnd = pos - 1
					ELSE
						DO LOOP
					END IF

				CASE $$SQ :
					IF fDQ THEN DO LOOP
					IF IsCharLiteral (s$, pos) THEN
						fSQ = NOT fSQ
						INC quoteCount
						posEnd = pos - 1
					ELSE
						DO LOOP
					END IF
			END SELECT
		ELSE
			posEnd = len
			quoteCount = 1		' end of line, not a quote
		END IF

		sectionModified$ = ""
		sectionRaw$ = MID$ (s$, posStart + 1, posEnd - posStart)
		posStart = posEnd + 1

		IF (quoteCount > 0) && (quoteCount MOD 2 = 0) THEN
			IF qType = $$DQ THEN
				sectionModifed$ = $$DOUBLE_QUOTE + sectionRaw$ + $$DOUBLE_QUOTE
				prev$ = RIGHT$ (lineBuffer$, 1)
				IF INSTR ("(&", prev$) THEN
					lineBuffer$ = lineBuffer$ + sectionModifed$
				ELSE
					lineBuffer$ = lineBuffer$ + $$SINGLE_SPACE + sectionModifed$
				END IF
			END IF
			IF qType = $$SQ THEN
				sectionModifed$ = $$SINGLE_QUOTE + sectionRaw$ + $$SINGLE_QUOTE
				lineBuffer$ = lineBuffer$ + $$SINGLE_SPACE + sectionModifed$
			END IF
		ELSE
			DO
			LOOP UNTIL XstReplace (@sectionRaw$, $$DOUBLE_SPACE, $$SINGLE_SPACE, 0) <= 0
			sectionRaw$ = TRIM$ (sectionRaw$)
			IFZ sectionRaw$ THEN DO LOOP

			' add white space to enable better parsing of words
			sectionRaw$ = AddWhiteSpace$ (@sectionRaw$)

			' Loop through the each of the words in the section
			index = 0
			done = 0
			state = 0
			lastState = 0
			prev$ = ""
			DO
				word$ = XstNextField$ (sectionRaw$, @index, @done)
				lastState = state
				fSpace = $$FALSE
				prev$ = RIGHT$ (sectionModified$, 1)
				SELECT CASE word$
					CASE "=", "+", "-", "*", "<", ">", "|", "^", "~", ":", "'", "!"  :
						fSpace = $$TRUE
						state = $$STATE_OPERATOR
						SELECT CASE word$
							CASE "=" : IF INSTR ("=<>", prev$) THEN fSpace = $$FALSE
							CASE "<" : IF INSTR ("<", prev$) THEN fSpace = $$FALSE
							CASE ">" : IF INSTR ("><", prev$) THEN fSpace = $$FALSE

							CASE "!" :
								IF INSTR ("(", prev$) THEN fSpace = $$FALSE
								IF lastState = $$STATE_NUMBER THEN
									fSpace = $$FALSE
									state = $$STATE_NUMBER
								END IF
								IF lastState = $$STATE_KEYWORD THEN
									fSpace = $$FALSE
									state = $$STATE_KEYWORD
								END IF

							CASE "~" : IF INSTR ("(", prev$) THEN fSpace = $$FALSE
							CASE "*" : IF INSTR ("*", prev$) THEN fSpace = $$FALSE
							CASE "^" : IF INSTR ("^", prev$) THEN fSpace = $$FALSE
							CASE "|" : IF INSTR ("|", prev$) THEN fSpace = $$FALSE
							CASE "+", "-" :
								IF lastState = $$STATE_NUMBER && (prev$ = "d" || prev$ = "e") THEN
									fSpace = $$FALSE
									state = $$STATE_NUMBER
								END IF
								IF prev$ = "(" THEN fSpace = $$FALSE
						END SELECT
						IF fSpace THEN
							sectionModified$ = sectionModified$ + $$SINGLE_SPACE + word$
						ELSE
							sectionModified$ = sectionModified$ + word$
						END IF

					CASE "[", "]", "{", "}" :
						sectionModified$ = sectionModified$ + word$
						state = $$STATE_BRACKET

					CASE "" :		' do nothing

					CASE ",", ";" :
						sectionModified$ = sectionModified$ + word$
						state = $$STATE_SEPARATOR

					CASE "(" :
						fSpace = $$TRUE
						state = $$STATE_BRACKET
						SELECT CASE TRUE
							CASE INSTR ("(!~", prev$) : fSpace = $$FALSE
						END SELECT
						IF fSpace THEN
							sectionModified$ = sectionModified$ + $$SINGLE_SPACE + word$
						ELSE
							sectionModified$ = sectionModified$ + word$
						END IF

					CASE ")" :
						sectionModified$ = sectionModified$ + word$
						state = $$STATE_BRACKET

					CASE ELSE :
						IF GIANT (word$) = 0 && word$ <> "0" THEN		'is it a number?
							' it is not a number, it is an intrinsic or function name or var name
							state = $$STATE_KEYWORD
							prev2$ = RIGHT$ (sectionModified$, 2)
							SELECT CASE TRUE
								CASE INSTR ("([{!~", prev$) : sectionModified$ = sectionModified$ + word$
								CASE (prev2$ = "(-") || (prev2$ = "(+") : sectionModified$ = sectionModified$ + word$
								CASE ELSE : sectionModified$ = sectionModified$ + $$SINGLE_SPACE + word$
							END SELECT
						ELSE
							' yes it's a number
							state = $$STATE_NUMBER
							SELECT CASE TRUE
								CASE (lastState = $$STATE_NUMBER) || (INSTR ("({", prev$)) :
									sectionModified$ = sectionModified$ + word$
								CASE (prev2$ = "(-") || (prev2$ = "(+") : sectionModified$ = sectionModified$ + word$
								CASE ELSE : sectionModified$ = sectionModified$ + $$SINGLE_SPACE + word$
							END SELECT
						END IF
				END SELECT
			LOOP UNTIL done
			lineBuffer$ = lineBuffer$ + sectionModified$
		END IF

	LOOP UNTIL pos = 0 || atEnd = $$TRUE

	RETURN LTRIM$ (lineBuffer$)

END FUNCTION
'
' ##############################
' #####  IsStringQuote ()  #####
' ##############################
'
' Return $$TRUE if double quote at position
' in string$ is a string quote.
'
FUNCTION IsStringQuote (s$, position)

	IFZ s$ THEN RETURN

	x = position - 1

	chPrev = ' '
	IF x - 1 >= 0 THEN chPrev = s${x - 1}
	chPrev2 = ' '
	IF x - 2 >= 0 THEN chPrev2 = s${x - 2}
	chNext = ' '
	IF x + 1 <= LEN (s$) - 1 THEN chNext = s${x + 1}

	IF chPrev = 39 && chNext = 39 THEN RETURN										' is '"'
	IF chPrev = 92 && chPrev2 = 39 && chNext = 39 THEN RETURN		' is '\"'
	IF chPrev = 34 && chNext = 34 THEN RETURN										' is """
	IF chPrev = 92 && chPrev2 = 34 && chNext = 34 THEN RETURN		' is "\""

	IF chPrev = 92 && chPrev2 <> 92 THEN RETURN   							' is \" and not "\\"

	RETURN ($$TRUE)

END FUNCTION
'
' ###############################
' #####  AddWhiteSpace$ ()  #####
' ###############################
'
' add a space char before and after each operator or bracket
' character in order to get proper tokens
'
FUNCTION AddWhiteSpace$ (@line$)
	IFZ line$ THEN EXIT FUNCTION

' replace ! operators
' this is due to the problem of a! < b! vs a !< b!
	text$ = line$
	DO
	LOOP UNTIL XstReplace (@text$, "!=", "<>", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!<=", ">", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!<", ">=", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!>=", "<", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!>", "<=", 0) <= 0

	newline$ = text$

	count = 0
	FOR i = 0 TO LEN (text$) - 1
		SELECT CASE text${i}
			CASE '(', ')', ',', '~', '|', '=', '<', '>', '+', '-', '*', '\\', '/', '{', '}', ';', '^', '!' :		' &, : have been left out
				pos = i + 2 * count
				newline$ = LEFT$ (newline$, pos) + " " + CHR$ (text${i}) + " " + RIGHT$ (newline$, LEN (newline$) - pos - 1)
				INC count
		END SELECT
	NEXT i
	RETURN newline$
END FUNCTION
'
' ##############################
' #####  FindNextQuote ()  #####
' ##############################
'
' Find next single or double quote character
'
FUNCTION FindNextQuote (src$, index, @style)

	IFZ src$ THEN RETURN
	' ftype = 0
	IF index < 1 THEN index = 1
	length = LEN (src$)
	IF index > length THEN RETURN		'length
	start = index - 1
	upp = length - 1

	FOR i = start TO upp
		ch = src${i}
		SELECT CASE ch
			CASE 34  : style = 1 : EXIT FOR		' found double quote
			CASE ''' : style = 2 : EXIT FOR		' found single quote
		END SELECT
	NEXT i

	IF i + 1 > length THEN RETURN (0)
	RETURN (i + 1)

END FUNCTION
'
' ###################################
' #####  InsertTemplateCode ()  #####
' ###################################
'
' Insert selected menu item template file at current position.
'
FUNCTION InsertTemplateCode (hWnd, id)

	CompilerOptionsType CpOpt
	SHARED templateFN$[]

	' get compiler path
	GetCompilerOptions (@CpOpt)

	' default path to templates directory
	f$ = "c:\\xblite\\templates\\"

	' get path for \xblite\templates
	IF CpOpt.XBLPath THEN
		comp$ = CpOpt.XBLPath
		pos = INSTR (comp$, "bin")
		IF pos THEN
			f$ = LEFT$ (comp$, pos - 1) + "templates\\"
		END IF
	END IF

	upp = UBOUND (templateFN$[])
	item = id - $$IDM_TEMPLATESTART
	IF item > upp || item < 0 THEN RETURN
	tplFN$ = templateFN$[item]
	IFZ tplFN$ THEN RETURN

	f$ = f$ + tplFN$
	IF XstLoadString (f$, @code$) THEN RETURN
	IFZ code$ THEN RETURN

	SendMessageA (GetEdit (), $$SCI_INSERTTEXT, -1, &code$)

END FUNCTION
'
' #############################
' #####  GetTemplates ()  #####
' #############################
'
' Retrieve template text labels and filenames
' for use in template menu items.
' Return count of template files.
'
FUNCTION GetTemplates (@name$[], @fn$[])

	CompilerOptionsType CpOpt

	' get compiler path
	GetCompilerOptions (@CpOpt)

	' default path to templates.xxx
	f$ = "c:\\xblite\\templates\\templates.xxx"

	' get path for \xblite\templates
	IF CpOpt.XBLPath THEN
		comp$ = CpOpt.XBLPath
		pos = INSTR (comp$, "bin")
		IF pos THEN
			f$ = LEFT$ (comp$, pos - 1) + "templates\\templates.xxx"
		END IF
	END IF

	IF XstLoadStringArray (f$, @text$[]) THEN RETURN
	upp = UBOUND (text$[])

	DIM name$[upp]
	DIM fn$[upp]

	FOR i = 0 TO upp
		t$ = LTRIM$(text$[i])
		t$ = LEFT$(t$, INSTR (t$, "#") - 1) 		' skip # commented sections
		IFZ t$ THEN DO NEXT
		index = 0 : term = 0 : done = 0
		name$ = TRIM$ (XstNextItem$ (t$, @index, @term, @done))
		fn$ = TRIM$ (XstNextItem$ (t$, @index, @term, @done))
		SELECT CASE TRUE
			CASE (name$ = "") && (fn$ = ""):
			CASE ELSE :
				name$[count] = name$
				fn$[count] = fn$
				INC count
		END SELECT
	NEXT i

	REDIM name$[count - 1]
	REDIM fn$[count - 1]

	RETURN count
END FUNCTION
'
' ###############################
' #####  GetWindowText$ ()  #####
' ###############################
'
FUNCTION GetWindowText$ (hWnd)

	STATIC init, text$, length
	IFZ init THEN GOSUB Initialize
	IFZ GetWindowTextA (hWnd, &text$, length) THEN
		EXIT FUNCTION
	ELSE
		RETURN (CSIZE$ (text$))
	END IF

SUB Initialize
	init = $$TRUE
	text$ = NULL$ (255)
	length = LEN (text$)
END SUB

END FUNCTION
'
' ###########################################
' #####  CreateAutoCompletionString ()  #####
' ###########################################
'
' Create the required autocompletion string based
' on match string (chars typed in by user).
'
FUNCTION CreateAutoCompletionString (@match$, @auto$)

	GetAutoCompletionList (@autoList$[])
	auto$ = ""
	IFZ autoList$[] THEN RETURN
	IFZ match$ THEN RETURN
	GetMatchingList (@autoList$[], @match$, @matchList$[])
	IFZ matchList$[] THEN RETURN
	' use ; as separator
	upp = UBOUND (matchList$[])
	FOR i = 0 TO upp
		auto$ = auto$ + matchList$[i] + ";"
	NEXT i
	' remove last ; char
	auto$ = LEFT$ (auto$, LEN (auto$) - 1)

END FUNCTION
'
' ################################
' #####  GetMatchingList ()  #####
' ################################
'
' Build a list of matching functions/keywords
' which match a string to the autocompletion
' function list.
'
FUNCTION GetMatchingList (@list$[], @match$, @matchList$[])

	IFZ match$ THEN RETURN
	IFZ list$[] THEN RETURN
	DIM matchList$[5000]
	upp = UBOUND (list$[])
	len = LEN (match$)
	FOR i = 0 TO upp
		x$ = LEFT$ (list$[i], len)
		IF x$ = match$ THEN
			matchList$[count] = list$[i]
			INC count
		END IF
	NEXT i
	IF count THEN
		REDIM matchList$[count - 1]
	ELSE
		REDIM matchList$[]
	END IF

END FUNCTION
'
' ######################################
' #####  GetAutoCompletionList ()  #####
' ######################################
'
' Assemble list of all function and keyword
' declarations used by XBLite.
'
FUNCTION GetAutoCompletionList (@completionList$[])

	STATIC init
	STATIC autoList$[]		' contains list of both *.dec functions and keywords

	' build autoList$[], get *.dec and keyword lists just once
	IFZ init THEN GOSUB Initialize

	' get currently active file function list
	GetActiveFileDeclarations (@activeList$[])

	' copy autoList$[] to completionList$[]
	XstCopyArray (@autoList$[], @completionList$[])

	IFZ activeList$[] THEN GOTO sort

	' add the two lists
	up = UBOUND (completionList$[])
	add = UBOUND (activeList$[])

	end = up + add + 1
	REDIM completionList$[end]
	start = up + 1

	c = 0
	FOR i = start TO end
		completionList$[i] = activeList$[c]
		INC c
	NEXT i

	' sort the final list
sort:
	flags = $$SortIncreasing | $$SortAlphabetic | $$SortCaseSensitive
	XstQuickSort (@completionList$[], @order[], 0, UBOUND (completionList$[]), flags)

SUB Initialize
	init = $$TRUE
	GetFunctionDeclarations (@autoList$[])
	GetKeywordDeclarations (@kwList$[])
	IFZ kwList$[] THEN EXIT SUB

	IFZ autoList$[] THEN
		upp = UBOUND (kwList$[])
		DIM autoList$[upp]
		FOR i = 0 TO upp
			autoList$[i] = kwList$[i]
		NEXT i

	ELSE

		' add the two lists
		up = UBOUND (autoList$[])
		add = UBOUND (kwList$[])

		end = up + add + 1
		REDIM autoList$[end]
		start = up + 1
		c = 0
		FOR i = start TO end
			autoList$[i] = kwList$[c]
			INC c
		NEXT i
	END IF
END SUB

END FUNCTION
'
' #######################################
' #####  GetKeywordDeclarations ()  #####
' #######################################
'
' Create a list of keyword and intrinsic
' function declarations.
'
FUNCTION GetKeywordDeclarations (@kwList$[])

	DIM kwList$[1000]

	' keywords
	kw$ = "ALL ATTACH AUTO AUTOS AUTOX _
			CASE CFUNCTION CLEAR CONSOLE _
			DCOMPLEX DEC DECLARE DIM DO DOUBLE _
			ELSE END ENDIF EXIT EXPLICIT EXPORT EXTERNAL _
			FALSE FOR FUNCADDR FUNCTION _
			GIANT GOADDR GOSUB GOTO _
			IF IFF IFT IFZ IMPORT INC INTERNAL _
			LONGDOUBLE LOOP _
			MAKEFILE MOD NEXT PRINT PROGRAM _
			READ REDIM RETURN _
			SBYTE SCOMPLEX SELECT SFUNCTION SHARED _
			SINGLE SLONG SSHORT _
			STATIC STEP STOP STRING SUB SUBADDR SWAP _
			THEN TO TRUE TYPE UBYTE ULONG UNION UNTIL USHORT _
			VERSION VOID WHILE WRITE XLONG _
			OR AND XOR NOT"

	' parse keywords into kwList$[]
	index = 0
	done = 0
	DO
		kwList$[count] = XstNextField$ (@kw$, @index, @done)
		INC count
	LOOP UNTIL done

	' add instrinsic functions here
	kwList$[count] = "ABS (numeric)"
	INC count
	kwList$[count] = "ASC (string$, [position])"
	INC count
	kwList$[count] = "BIN$ (integers, [digits])"
	INC count
	kwList$[count] = "BINB$ (integers, [digits])"
	INC count
	kwList$[count] = "BITFIELD (width, offset)"
	INC count
	kwList$[count] = "CHR$ (integer, [count])"
	INC count
	kwList$[count] = "CJUST$ (string$, length)"
	INC count
	kwList$[count] = "CLOSE (fileNumber)"
	INC count
	kwList$[count] = "CLR (integer, bitspec)"
	INC count
	kwList$[count] = "CSIZE (string$)"
	INC count
	kwList$[count] = "CSIZE$ (string$)"
	INC count
	kwList$[count] = "CSTRING$ (address)"
	INC count
	kwList$[count] = "DHIGH (double)"
	INC count
	kwList$[count] = "DLOW (double)"
	INC count
	kwList$[count] = "DMAKE (high32, low32)"
	INC count
	kwList$[count] = "DOUBLEAT (address, [offset])"
	INC count
	kwList$[count] = "EOF (fileNumber)"
	INC count
	kwList$[count] = "ERROR (newError)"
	INC count
	kwList$[count] = "ERROR$ (error)"
	INC count
	kwList$[count] = "EXTS (integer, bitspec)"
	INC count
	kwList$[count] = "EXTU (integer, bitspec)"
	INC count
	kwList$[count] = "FIX (float)"
	INC count
	kwList$[count] = "FORMAT$ (format$, argument)"
	INC count
	kwList$[count] = "FUNCADDRESS (FuncName())"
	INC count
	kwList$[count] = "GHIGH (giant)"
	INC count
	kwList$[count] = "GIANTAT (address, [offset])"
	INC count
	kwList$[count] = "GLOW (giant)"
	INC count
	kwList$[count] = "GMAKE (high32, low32)"
	INC count
	kwList$[count] = "GOADDRAT (address, [offset])"
	INC count
	kwList$[count] = "GOADDRESS (label)"
	INC count
	kwList$[count] = "HEX$ (integers, [digits])"
	INC count
	kwList$[count] = "HEXX$ (integers, [digits])"
	INC count
	kwList$[count] = "HIGH0 (integer)"
	INC count
	kwList$[count] = "HIGH1 (integer)"
	INC count
	kwList$[count] = "HIWORD (x)"
	INC count
	kwList$[count] = "INCHR (searchMe$, searchFor$, [start]) "
	INC count
	kwList$[count] = "INCHRI (searchMe$, searchFor$, [start])"
	INC count
	kwList$[count] = "INFILE$ (fileNumber)"
	INC count
	kwList$[count] = "INLINE$ (prompt$)"
	INC count
	kwList$[count] = "INSTR (searchMe$, searchFor$, [start])"
	INC count
	kwList$[count] = "INSTRI (searchMe$, searchFor$, [start])"
	INC count
	kwList$[count] = "INT (float)"
	INC count
	kwList$[count] = "LCASE$ (string$)"
	INC count
	kwList$[count] = "LCLIP$(string$, [count])"
	INC count
	kwList$[count] = "LEFT$(string$, [length])"
	INC count
	kwList$[count] = "LEN (string$)"
	INC count
	kwList$[count] = "LIBRARY (0)"
	INC count
	kwList$[count] = "LJUST$ (string$, length)"
	INC count
	kwList$[count] = "LOF (fileNumber)"
	INC count
	kwList$[count] = "LONGDOUBLEAT (address, [offset])"
	INC count
	kwList$[count] = "LOWORD (x)"
	INC count
	kwList$[count] = "LTRIM$ (string$)"
	INC count
	kwList$[count] = "MAKE (integer, bitspec)"
	INC count
	kwList$[count] = "MAX (numeric1, numeric2)"
	INC count
	kwList$[count] = "MID$ (string$, start, [length])"
	INC count
	kwList$[count] = "MIN (numeric1, numeric2)"
	INC count
	kwList$[count] = "NULL$ (length)"
	INC count
	kwList$[count] = "OCT$ (integer, [digits])"
	INC count
	kwList$[count] = "OCTO$ (integer, [digits])"
	INC count
	kwList$[count] = "OPEN (fileName$, mode)"
	INC count
	kwList$[count] = "POF (fileNumber)"
	INC count
	kwList$[count] = "POWER (x, y)"
	INC count
	kwList$[count] = "PROGRAM$ (0)"
	INC count
	kwList$[count] = "QUIT (integer)"
	INC count
	kwList$[count] = "RCLIP$ (string$, [count])"
	INC count
	kwList$[count] = "RGB (r, g, b)"
	INC count
	kwList$[count] = "RIGHT$(string$, [length])"
	INC count
	kwList$[count] = "RINCHR (searchMe$, searchFor$, [start])"
	INC count
	kwList$[count] = "RINCHRI (searchMe$, searchFor$, [start])"
	INC count
	kwList$[count] = "RINSTR (searchMe$, searchFor$, [start])"
	INC count
	kwList$[count] = "RINSTRI (searchMe$, searchFor$, [start])"
	INC count
	kwList$[count] = "RJUST$ (string$, length)"
	INC count
	kwList$[count] = "ROTATEL (integer, count)"
	INC count
	kwList$[count] = "ROTATER (integer, count)"
	INC count
	kwList$[count] = "RTRIM$ (string$)"
	INC count
	kwList$[count] = "SBYTEAT (address, [offset])"
	INC count
	kwList$[count] = "SEEK (fileNumber, filePointer)"
	INC count
	kwList$[count] = "SET (integer, bitspec)"
	INC count
	kwList$[count] = "SGN (numeric)"
	INC count
	kwList$[count] = "SHELL (command$)"
	INC count
	kwList$[count] = "SIGN (numeric)"
	INC count
	kwList$[count] = "SIGNED$ (numeric)"
	INC count
	kwList$[count] = "SINGLEAT (address, [offset])"
	INC count
	kwList$[count] = "SIZE (data)"
	INC count
	kwList$[count] = "SLONGAT (address, [offset])"
	INC count
	kwList$[count] = "SMAKE (integer)"
	INC count
	kwList$[count] = "SPACE$ (length)"
	INC count
	kwList$[count] = "SSHORTAT (address, [offset])"
	INC count
	kwList$[count] = "STR$ (numeric)"
	INC count
	kwList$[count] = "STRING$ (numeric)"
	INC count
	kwList$[count] = "STUFF$ (stringInto$, stringFrom$, start, [length])"
	INC count
	kwList$[count] = "SUBADDRAT (address, [offset])"
	INC count
	kwList$[count] = "SUBADDRESS (sublabel)"
	INC count
	kwList$[count] = "TAB (integer)"
	INC count
	kwList$[count] = "TRIM$ (string$)"
	INC count
	kwList$[count] = "TYPE (data)"
	INC count
	kwList$[count] = "UBOUND (array[])"
	INC count
	kwList$[count] = "UBYTEAT (address, [offset])"
	INC count
	kwList$[count] = "UCASE$ (string$)"
	INC count
	kwList$[count] = "ULONGAT (address, [offset])"
	INC count
	kwList$[count] = "USHORTAT (address, [offset])"
	INC count
	kwList$[count] = "VERSION$ (0)"
	INC count
	kwList$[count] = "XLONGAT (address, [offset])"
	INC count
	kwList$[count] = "XMAKE (numeric)"

	REDIM kwList$[count]

END FUNCTION
'
' ########################################
' #####  GetFunctionDeclarations ()  #####
' ########################################
'
' Get all function declarations from all XBLite
' DEC files.
'
FUNCTION GetFunctionDeclarations (@funcList$[])

	CompilerOptionsType CpOpt
	DIM funcList$[256]

	GetCompilerOptions (@CpOpt)
	path$ = CpOpt.XBLPath
	pos = INSTR (comp$, "bin")
	IF pos THEN
		path$ = LEFT$ (path$, pos - 1) + "include"
	ELSE
		' try this...
		path$ = "c:\\xblite\\include"
	END IF

	' get a list of all *.dec file in the \include dir
	filter$ = "*.dec"
	XstFindFiles (path$, filter$, $$TRUE, @files$[])

	' now search each file for function declarations
	upp = UBOUND (files$[])
	FOR i = 0 TO upp
	  f$ = files$[i]
		' PRINT "working on "; f$
		' skip static library .dec files since they are normally duplicates
		IF INSTR(f$, "_s") THEN DO NEXT
		' load file into string array
		XstLoadStringArray (f$, @string$[])
		IFZ string$[] THEN DO NEXT
		up = UBOUND (string$[])
		' search for function declarations within string array
		FOR j = 0 TO up
			line$ = TRIM$ (string$[j])
			index = 0
			done = 0
			firstWord$ = XstNextField$ (line$, @index, @done)
			IF firstWord$ <> "EXTERNAL" THEN DO NEXT
			secondWord$ = XstNextField$ (line$, @index, @done)
			index2 = index
			thirdWord$ = XstNextField$ (line$, @index, @done)
			index3 = index
			IF secondWord$ = "FUNCTION" || secondWord$ = "CFUNCTION" THEN
				SELECT CASE thirdWord$
					CASE "XLONG", "ULONG", "SLONG", "UBYTE", "SBYTE", "USHORT", "SSHORT", "SINGLE", "DOUBLE", "LONGDOUBLE", "GIANT" :
						pos = index3
					CASE ELSE :
						pos = index2
				END SELECT
				' get function
				funcName$ = LTRIM$ (MID$ (line$, pos + 1))
				XstReplace (@funcName$, "\t", " ", 0)		' replace tabs with space
				' reduce spaces
				DO
					ret = XstReplace (@funcName$, "  ", " ", 0)
				LOOP UNTIL ret <= 0
				funcList$[count] = funcName$
				INC count
				IF count >= UBOUND (funcList$[]) THEN
					REDIM funcList$[count * 2]
				END IF
			END IF
		NEXT j
	NEXT i
	REDIM funcList$[count - 1]

END FUNCTION
'
' ##########################################
' #####  GetActiveFileDeclarations ()  #####
' ##########################################
'
' Get all function declarations from currently
' active file.
'
FUNCTION GetActiveFileDeclarations (@activeList$[])

	DIM activeList$[256]

	len = SendMessageA (GetEdit (), $$SCI_GETTEXT, 0, NULL)
	text$ = NULL$ (len + 1)
	SendMessageA (GetEdit (), $$SCI_GETTEXT, len + 1, &text$)
	XstStringToStringArray (@text$, @string$[])
	IFZ string$[] THEN
		DIM activeList$[]
		RETURN
	END IF

	up = UBOUND (string$[])
	' search for function declarations within string array
	FOR j = 0 TO up
		line$ = TRIM$ (string$[j])
		index = 0
		done = 0
		firstWord$ = XstNextField$ (line$, @index, @done)
		IF firstWord$ <> "DECLARE" THEN DO NEXT
		secondWord$ = XstNextField$ (line$, @index, @done)
		IF secondWord$ = "FUNCTION" || secondWord$ = "CFUNCTION" THEN
			' get function
			funcName$ = LTRIM$ (MID$ (line$, index + 1))
			XstReplace (@funcName$, "\t", " ", 0)		' replace tabs with space
			' reduce spaces
			DO
				ret = XstReplace (@funcName$, "  ", " ", 0)
			LOOP UNTIL ret <= 0
			activeList$[count] = funcName$
			INC count
			IF count >= UBOUND (activeList$[]) THEN
				REDIM activeList$[count * 2]
			END IF
		END IF
	NEXT j
	REDIM activeList$[count - 1]

END FUNCTION
'
' #############################
' #####  AutoComplete ()  #####
' #############################
'
' Display autocompletion listbox, fill with
' matching autocompletion strings. Autocompletion
' listbox contains function declarations from
' current program, xblite intrinsics, and all
' functions declared in *.dec files.
'
FUNCTION AutoComplete ()

	TEXTRANGE txtrg
	SHARED hWndMain
	SHARED hWndClient
	RECT rc, rcl
	POINT pt

	IFZ GetEdit () THEN EXIT FUNCTION

	' Get direct pointer for faster access
	pSci = SendMessageA (GetEdit (), $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN EXIT FUNCTION

	curPos = SciMsg (pSci, $$SCI_GETCURRENTPOS, 0, 0)
	x = SciMsg (pSci, $$SCI_WORDSTARTPOSITION, curPos, $$TRUE)
	y = SciMsg (pSci, $$SCI_WORDENDPOSITION, curPos, $$TRUE)

	IF y <= x THEN EXIT FUNCTION
	match$ = NULL$ (y - x + 1)
	txtrg.chrg.cpMin = x
	txtrg.chrg.cpMax = y
	txtrg.lpstrText = &match$
	SciMsg (pSci, $$SCI_GETTEXTRANGE, 0, &txtrg)
	match$ = CSIZE$ (match$)

	IF LEN (match$) < 2 THEN
		MessageBoxA (hWndMain, &"Word too short to search   ", &" AutoComplete", $$MB_OK OR $$MB_ICONINFORMATION OR $$MB_APPLMODAL)
		EXIT FUNCTION
	END IF

	' **********************************************
	' this section of code builds a word list
	' based on text in currently open mdi windows
	' this might be added in building autocompletion list
	' since this would include all strings and variable names

	' szFindText$ = buffer$
	' findFlags = $$SCFIND_WORDSTART
	' SciMsg (pSci, $$SCI_AUTOCSETIGNORECASE, $$TRUE, 0)   ' Ignore case

	' ' Count the number of child windows
	' p = 0
	' p1 = GetWindow(hWndClient, $$GW_CHILD)
	' DO WHILE p1 <> 0
	' p1 = GetWindow(p1, $$GW_HWNDNEXT)
	' INCR p
	' LOOP

	' DO WHILE p <> 0
	' hWndActive = MdiGetActive(hWndClient)
	' pSci = SendMessageA (GetEdit(), $$SCI_GETDIRECTPOINTER, 0, 0)
	' IFZ pSci THEN EXIT DO
	' ' Search whole document
	' startPos = 0
	' endPos = SciMsg (pSci, $$SCI_GETTEXTLENGTH, 0, 0)
	' DO
	' ' Set the find flags and the starting and ending positions
	' SciMsg (pSci, $$SCI_SETSEARCHFLAGS, findFlags, 0)
	' SciMsg (pSci, $$SCI_SETTARGETSTART, startPos, 0)
	' SciMsg (pSci, $$SCI_SETTARGETEND, endPos, 0)
	' ' Search for the text to replace
	' hr = SciMsg (pSci, $$SCI_SEARCHINTARGET, LEN(szFindText$), &szFindText$)
	' ' Increase the starting position
	' startPos = hr + 1
	' ' If hr = -1 there are no more text to scan
	' IF hr = -1 THEN
	' EXIT DO
	' ELSE
	' x = SciMsg(pSci, $$SCI_WORDSTARTPOSITION, hr, $$TRUE)
	' y = SciMsg(pSci, $$SCI_WORDENDPOSITION, hr, $$TRUE)
	' buffer$ = NULL$(y - x + 1)
	' txtrg.chrg.cpMin = x
	' txtrg.chrg.cpMax = y
	' txtrg.lpstrText = &buffer$
	' SciMsg (pSci, $$SCI_GETTEXTRANGE, 0, &txtrg)
	' buffer$ = LEFT$(buffer$, LEN(buffer$) - 1)
	' IF UCASE$(buffer$) <> UCASE$(szFindText$) THEN   ' Skip our own word
	' ARRAY SCAN WordList(), COLLATE UCASE, = buffer, TO iPos
	' IFZ iPos THEN
	' INC numItems
	' '                  REDIM PRESERVE WordList(numItems - 1)
	' '                  WordList(UBOUND(WordList)) = buffer
	' END IF
	' END IF
	' END IF
	' LOOP
	' MdiNext (hWndClient, hWndActive, 0)      ' Set focus to next child window
	' DEC p                                 ' Decrement window counter
	' LOOP
	' ***************************************************

	' create autocompletion string
	CreateAutoCompletionString (@match$, @autoList$)
	IFZ autoList$ THEN RETURN
	' set list separator
	SciMsg (pSci, $$SCI_AUTOCSETSEPARATOR, ';', 0)
	' display autocompletion listbox
	SciMsg (pSci, $$SCI_AUTOCSHOW, LEN (match$), &autoList$)
	' find listbox control window, resize if too wide
	hEdit = GetEdit ()
	hList = GetWindow (hEdit, $$GW_CHILD)
	IFZ hList THEN RETURN
	GetClientRect (hEdit, &rc)
	GetWindowRect (hList, &rcl)
	wList = rcl.right - rcl.left
	width = rc.right - rc.left
  pt.x = rcl.left
  pt.y = rcl.top
  ScreenToClient (hEdit, &pt)
  IF wList > width - pt.x THEN
    SetWindowPos (hList, 0, pt.x, pt.y, width - pt.x - 1, rcl.bottom - rcl.top, $$SWP_NOZORDER)
  END IF


END FUNCTION

' ShowColorOptions popup dialog
'
FUNCTION ShowColorOptionsDialog (hParent)

	WNDCLASSEX wcex
	SHARED hInst
	RECT rc
	MSG msg
	SciColorsAndFontsType ColOpt

	hFnt = GetStockObject ($$ANSI_VAR_FONT)

	' Register the window class
	szClassName$ = "Color_Options"
	wcex.cbSize = SIZE (wcex)
	wcex.style = $$CS_HREDRAW OR $$CS_VREDRAW
	wcex.lpfnWndProc = &ColorOptionsDlgProc ()
	wcex.cbClsExtra = 0
	wcex.cbWndExtra = 0
	wcex.hInstance = hInst
	wcex.hCursor = LoadCursorA (NULL, $$IDC_ARROW)
	wcex.hbrBackground = $$COLOR_3DFACE + 1
	wcex.lpszMenuName = NULL
	wcex.lpszClassName = &szClassName$
	wcex.hIcon = 0
	wcex.hIconSm = 0
	RegisterClassExA (&wcex)

	' Window caption
	szCaption$ = "Colors and Fonts"

	GetWindowRect (hParent, &rc)		' for centering child in parent
	x = rc.left + (rc.right - 548) / 2
	IF x < 0 THEN x = 10
	y = rc.top + (rc.bottom - 380) / 2
	IF y < 0 THEN y = 10
	w = 548
	h = 415
	hDlg = CreateWindowExA ($$WS_EX_DLGMODALFRAME OR $$WS_EX_CONTROLPARENT, &szClassName$, &szCaption$, $$WS_CAPTION OR $$WS_POPUPWINDOW OR $$WS_VISIBLE, x, y, w, h, hParent, 0, hInst, NULL)

	IFZ hDlg THEN
		MessageBoxA (hParent, &"Error creating the dialog   ", &" ShowColorOptionsDialog", $$MB_OK OR $$MB_ICONERROR OR $$MB_APPLMODAL)
		EXIT FUNCTION
	END IF

	hCtl = CreateWindowExA ($$WS_EX_TRANSPARENT, &"BUTTON", &" Color Selection ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 208, 16, 324, 100, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	' hCtl = CreateWindowExA (0, &"STATIC", &" Item", $$WS_CHILD OR $$WS_VISIBLE, 20, 30, 240, 20, hDlg, -1, hInst, NULL)
	' IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"ListBox", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_BORDER OR $$WS_VSCROLL OR $$WS_TABSTOP OR $$LBS_NOTIFY, 16, 16, 180, 298, hDlg, $$IDC_LBCOLSEL, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	Listbox_AddString (hCtl, "Default")
	Listbox_AddString (hCtl, "Caret")
	Listbox_AddString (hCtl, "Caret Line")
	Listbox_AddString (hCtl, "Comments")
	Listbox_AddString (hCtl, "Constants")
	Listbox_AddString (hCtl, "Edge")
	Listbox_AddString (hCtl, "Fold")
	Listbox_AddString (hCtl, "Fold Open")
	Listbox_AddString (hCtl, "Fold Margin")
	Listbox_AddString (hCtl, "Identifiers")
	Listbox_AddString (hCtl, "Indent Guides")
	Listbox_AddString (hCtl, "Keywords")
	Listbox_AddString (hCtl, "Numbers")
	Listbox_AddString (hCtl, "Line Numbers")
	Listbox_AddString (hCtl, "Operators")
	Listbox_AddString (hCtl, "Inline ASM")
	Listbox_AddString (hCtl, "Selection")
	Listbox_AddString (hCtl, "Strings")
	Listbox_AddString (hCtl, "Submenu Text")
	Listbox_AddString (hCtl, "Submenu Highlighted Text")
	Listbox_AddString (hCtl, "Whitespace")
	Listbox_AddString (hCtl, "ASM FPU Instruction")
	Listbox_AddString (hCtl, "ASM Register")
	Listbox_AddString (hCtl, "ASM Directive")
	Listbox_AddString (hCtl, "ASM Directive Operand")
	Listbox_AddString (hCtl, "ASM Extended Instruction")

	Listbox_SetCurSel (hCtl, 0)
	SetFocus (hCtl)

	hCtl = CreateWindowExA (0, &"STATIC", &"Foreground", $$WS_CHILD OR $$WS_VISIBLE, 218, 42, 60, 24, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	' hCtl = CreateCBColorList (hDlg, $$IDC_CBFORECOLOR, 280, 70, 240, 240, $$FALSE, GetSysColor($$COLOR_WINDOWTEXT), GetSysColor($$COLOR_WINDOWTEXT))
	hCtl = CreateComboColor (hDlg, $$IDC_CBFORECOLOR, 286, 38, 168, 240, GetSysColor ($$COLOR_WINDOWTEXT), GetSysColor ($$COLOR_WINDOWTEXT))
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"Custom", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP, 466, 38, 50, 23, hDlg, $$IDB_USERFORECOLOR, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"STATIC", &"Background", $$WS_CHILD OR $$WS_VISIBLE, 218, 82, 60, 24, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	' hCtl = CreateCBColorList(hDlg, $$IDC_CBBACKCOLOR, 280, 140, 240, 240, $$FALSE, GetSysColor($$COLOR_WINDOWTEXT), GetSysColor($$COLOR_WINDOWTEXT))
	hCtl = CreateComboColor (hDlg, $$IDC_CBBACKCOLOR, 286, 78, 168, 240, GetSysColor ($$COLOR_WINDOWTEXT), GetSysColor ($$COLOR_WINDOWTEXT))

	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"Custom", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP, 466, 78, 50, 23, hDlg, $$IDB_USERBACKCOLOR, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_TRANSPARENT, &"BUTTON", &" Font Selection", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 208, 126, 238, 80, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"COMBOBOX", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$WS_VSCROLL OR $$CBS_DROPDOWNLIST OR $$CBS_OWNERDRAWFIXED OR $$CBS_HASSTRINGS OR $$CBS_SORT, 218, 144, 218, 200, hDlg, $$IDC_CBFONTS, hInst, NULL)

	' Nicer with a bit bigger font, so increase line height in control - adjust to own liking.
	ItemHeight = SendMessageA (hCtl, $$CB_GETITEMHEIGHT, 0, 0)		' get current line height
	SendMessageA (hCtl, $$CB_SETITEMHEIGHT, -1, ItemHeight + 1)		' increase in edit part..
	SendMessageA (hCtl, $$CB_SETITEMHEIGHT, 0, ItemHeight + 1)		' increase in list..

	' Fill the fonts combobox
	FillFontCombo (hCtl)

	' Reset the FullRange static variable
	FillFontSizeCombo (hDlg, "")

	hCtl = CreateWindowExA (0, &"BUTTON", &"Always use the default background color", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX, 20, 312, 260, 20, hDlg, $$IDK_USEDEFAULTCOLOR, hInst, NULL)
  IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

  hCtl = CreateWindowExA (0, &"BUTTON", &"Always use the default font", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX, 20, 334, 260, 20, hDlg, $$IDK_USEDEFAULTFONT, hInst, NULL)
  IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

  hCtl = CreateWindowExA (0, &"BUTTON", &"Always use the default font size", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX, 20, 356, 260, 20, hDlg, $$IDK_USEDEFAULTSIZE, hInst, NULL)
  IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	' hCtl = CreateWindowExA ($$WS_EX_TRANSPARENT, "BUTTON", " Charset ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 280, 222, 166, 80, hDlg, -1, hInst, NULL)
	' IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	' hCtl = CreateWindowExA (0, "COMBOBOX", "", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$CBS_DROPDOWNLIST OR $$WS_VSCROLL, 290, 244, 146, 146, hDlg, $$IDC_CBCHARSET, hInst, NULL)
	' IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	' Combo_AddString hCtl, "Default"
	' Combo_AddString hCtl, "Ansi"
	' Combo_AddString hCtl, "Arabic"
	' Combo_AddString hCtl, "Baltic"
	' Combo_AddString hCtl, "Chinese Big 5"
	' Combo_AddString hCtl, "East Europe"
	' Combo_AddString hCtl, "GB 2312"
	' Combo_AddString hCtl, "Greek"
	' Combo_AddString hCtl, "Hangul"
	' Combo_AddString hCtl, "Hebrew"
	' Combo_AddString hCtl, "Johab"
	' Combo_AddString hCtl, "Mac"
	' Combo_AddString hCtl, "OEM"
	' Combo_AddString hCtl, "Russian"
	' Combo_AddString hCtl, "Shiftjis"
	' Combo_AddString hCtl, "Symbol"
	' Combo_AddString hCtl, "Thai"
	' Combo_AddString hCtl, "Turkish"
	' Combo_AddString hCtl, "Vietnamese"

	hCtl = CreateWindowExA ($$WS_EX_TRANSPARENT, &"BUTTON", &" Font Size ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 456, 126, 76, 80, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"COMBOBOX", NULL, $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$CBS_DROPDOWNLIST OR $$WS_VSCROLL, 466, 148, 56, 146, hDlg, $$IDC_CBFONTSIZE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"Bold", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX, 218, 179, 64, 20, hDlg, $$IDK_BOLD, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"Italic", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX, 294, 179, 64, 20, hDlg, $$IDK_ITALIC, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"Underline", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$BS_AUTOCHECKBOX, 370, 179, 64, 20, hDlg, $$IDK_UNDERLINE, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	GetClientRect (hDlg, &rc)

	hCtl = CreateWindowExA (0, &"BUTTON", &"&Apply", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP, (rc.right - rc.left) - 185, (rc.bottom - rc.top) - 35, 75, 23, hDlg, $$IDOK, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA (0, &"BUTTON", &"&Close", $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP, (rc.right - rc.left) - 86, (rc.bottom - rc.top) - 35, 75, 23, hDlg, $$IDCANCEL, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_TRANSPARENT, &"BUTTON", &" Text Example ", $$WS_CHILD OR $$WS_VISIBLE OR $$BS_GROUPBOX OR $$BS_LEFT, 208, 216, 324, 90, hDlg, 0, hInst, NULL)
	IF hFnt THEN SendMessageA (hCtl, $$WM_SETFONT, hFnt, 0)

	hCtl = CreateWindowExA ($$WS_EX_STATICEDGE, &"STATIC", &"Sample Text", $$WS_CHILD OR $$WS_VISIBLE OR $$SS_CENTER OR $$SS_CENTERIMAGE, 218, 236, 304, 58, hDlg, $$IDC_STATICEXAMPLE, hInst, NULL)

	' Select the default
	FillFontSizeCombo (hDlg, "Default")
	SED_ColorsAndFontsChangeSelection (hDlg, "Default")

	GetColorOptions (@ColOpt)
  IF ColOpt.AlwaysUseDefaultBackColor THEN CheckDlgButton (hDlg, $$IDK_USEDEFAULTCOLOR, $$BST_CHECKED)
  IF ColOpt.AlwaysUseDefaultFont THEN CheckDlgButton (hDlg, $$IDK_USEDEFAULTFONT, $$BST_CHECKED)
  IF ColOpt.AlwaysUseDefaultFontSize THEN CheckDlgButton (hDlg, $$IDK_USEDEFAULTSIZE, $$BST_CHECKED)

	' display sample text
	SetFontExample (hDlg)

	' Show the window
	ShowWindow (hDlg, $$SW_SHOW)
	UpdateWindow (hDlg)

	' Message handler loop
	DO WHILE GetMessageA (&msg, NULL, 0, 0)
		IFZ IsDialogMessageA (hDlg, &msg) THEN
			TranslateMessage (&msg)
			DispatchMessageA (&msg)
		END IF
	LOOP

	RETURN msg.wParam

END FUNCTION
'
' ####################################
' #####  ColorOptionsDlgProc ()  #####
' ####################################
'
' Color options dialog procedure
'
FUNCTION ColorOptionsDlgProc (hWnd, wMsg, wParam, lParam)

	SHARED SciColorsAndFontsType scf
	SHARED hMenuTextBkBrush, hMenuHiBrush
	SHARED hExFont

	STATIC hFocus

	SELECT CASE wMsg

		CASE $$WM_CREATE :		' Entrance
			EnableWindow (GetParent (hWnd), $$FALSE)		' To make popup dialog modal

		CASE $$WM_NCACTIVATE :
			IFZ wParam THEN hFocus = GetFocus ()

		CASE $$WM_SETFOCUS :
			IF hFocus THEN
				PostMessageA (hWnd, $$WM_USER + 999, hFocus, 0)
				hFocus = 0
			END IF

		CASE $$WM_USER + 999 :
			IF wParam THEN SetFocus (wParam)

		CASE $$WM_DRAWITEM :		' Must pass this one on to ownerdrawn combo!
			IF wParam = $$IDC_CBFORECOLOR THEN
				SendMessageA (GetDlgItem (hWnd, $$IDC_CBFORECOLOR), wMsg, wParam, lParam)
				RETURN ($$TRUE)
			END IF
			IF wParam = $$IDC_CBBACKCOLOR THEN
				SendMessageA (GetDlgItem (hWnd, $$IDC_CBBACKCOLOR), wMsg, wParam, lParam)
				RETURN ($$TRUE)
			END IF
			IF wParam = $$IDC_CBFONTS THEN
				DrawFontCombo (GetDlgItem (hWnd, $$IDC_CBFONTS), wParam, lParam)
				RETURN ($$TRUE)
			END IF

		CASE $$WM_COMMAND :
			' -------------------------------------------------------
			' Messages from controls and menu items are handled here.
			' -------------------------------------------------------
			SELECT CASE LOWORD (wParam)

				CASE $$IDOK :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						' Get the selection
						curSel = Listbox_GetCurSel (GetDlgItem (hWnd, $$IDC_LBCOLSEL))
						curSelStr$ = Listbox_GetText (GetDlgItem (hWnd, $$IDC_LBCOLSEL), curSel)

						' Save the options in the structure
						SED_ColorsAndFontsStoreSelection (hWnd, curSelStr$)

						' Get the Use always default background setting
            scf.AlwaysUseDefaultBackColor = IsDlgButtonChecked (hWnd, $$IDK_USEDEFAULTCOLOR)

            ' Get the Use always default font
            scf.AlwaysUseDefaultFont = IsDlgButtonChecked (hWnd, $$IDK_USEDEFAULTFONT)

            ' Get the Use always default font size
            scf.AlwaysUseDefaultFontSize = IsDlgButtonChecked (hWnd, $$IDK_USEDEFAULTSIZE)

						' If the colors for the submenu have been changed create new brushes
						OldSubmenuTextBackColor = XLONG (IniRead (IniFile$, "Color options", "SubMenuTextBackColor", ""))
						IF scf.SubMenuTextBackColor <> OldSubmenuTextBackColor THEN
							DeleteObject (hMenuTextBkBrush)
							hMenuTextBkBrush = CreateSolidBrush (scf.SubMenuTextBackColor)
							bBrushChanged = $$TRUE
						END IF
						OldSubmenuHiTextBackColor = XLONG (IniRead (IniFile$, "Color options", "SubMenuHiTextBackColor", ""))
						IF scf.SubMenuHiTextBackColor <> OldSubmenuHiTextBackColor THEN
							DeleteObject (hMenuHiBrush)
							hMenuHiBrush = CreateSolidBrush (scf.SubMenuHiTextBackColor)
							bBrushChanged = $$TRUE
						END IF
						IF bBrushChanged THEN SED_MsgBox (hWnd, "New brushes have been created.", $$MB_OK, curSelStr$)

						' Set the focus in the listbox
						SetFocus (GetDlgItem (hWnd, $$IDC_LBCOLSEL))

						' Write the options to the .INI file
						WriteColorOptions (@scf)

						' Change the options of the current document if any
						IF GetEdit () THEN
							szPath$ = GetWindowText$ (GetParent (GetEdit ()))
							' GetWindowText GetParent(GetEdit), szPath, SIZEOF(szPath)
							IF szPath$ THEN
								' Get direct pointer for faster access
								pSci = SendMessageA (GetEdit (), $$SCI_GETDIRECTPOINTER, 0, 0)
								IF pSci THEN Scintilla_SetOptions (pSci, szPath$)
							END IF
						END IF
						RETURN
					END IF

				CASE $$IDCANCEL :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						SendMessageA (hWnd, $$WM_CLOSE, wParam, lParam)
						RETURN
					END IF

				CASE $$IDC_CBFONTS :
					IF HIWORD (wParam) = $$CBN_SELCHANGE THEN		' Selection change
						strFontName$ = Combo_GetLbText (GetDlgItem (hWnd, $$IDC_CBFONTS), -1)
						FillFontSizeCombo (hWnd, strFontName$)
						SetFontExample (hWnd)
						RETURN
					END IF

				CASE $$IDC_CBFONTSIZE :
					IF HIWORD (wParam) = $$CBN_SELCHANGE THEN		' Selection change
						SetFontExample (hWnd)
						RETURN
					END IF

				CASE $$IDK_BOLD, $$IDK_ITALIC, $$IDK_UNDERLINE :
					SetFontExample (hWnd)
					RETURN

				CASE $$IDC_CBFORECOLOR :
					IF HIWORD (wParam) = $$CBN_SELCHANGE THEN		' Selection change
						selColor = SendMessageA (GetDlgItem (hWnd, $$IDC_CBFORECOLOR), $$CBCOL_GETSELCOLOR, $$TRUE, 0)
						SendMessageA (GetDlgItem (hWnd, $$IDC_CBFORECOLOR), $$CBCOL_SETUSERCOLOR, selColor, 0)
						hStatic = GetDlgItem (hWnd, $$IDC_STATICEXAMPLE)
						InvalidateRect (hStatic, NULL, $$TRUE)
					END IF
					RETURN

				CASE $$IDC_CBBACKCOLOR :
					IF HIWORD (wParam) = $$CBN_SELCHANGE THEN		' Selection change
						selColor = SendMessageA (GetDlgItem (hWnd, $$IDC_CBBACKCOLOR), $$CBCOL_GETSELCOLOR, $$TRUE, 0)
						SendMessageA (GetDlgItem (hWnd, $$IDC_CBBACKCOLOR), $$CBCOL_SETUSERCOLOR, selColor, 0)
						hStatic = GetDlgItem (hWnd, $$IDC_STATICEXAMPLE)
						InvalidateRect (hStatic, NULL, $$TRUE)
					END IF
					RETURN

				CASE $$IDB_USERFORECOLOR :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						selColor = SendMessageA (GetDlgItem (hWnd, $$IDC_CBFORECOLOR), $$CBCOL_GETUSERCOLOR, 0, 0)
						userColor = SED_ChooseColor (hWnd, selColor)
						IF userColor THEN
							SendMessageA (GetDlgItem (hWnd, $$IDC_CBFORECOLOR), $$CBCOL_SETUSERCOLOR, userColor, 0)
							InvalidateRect (GetDlgItem (hWnd, $$IDC_CBFORECOLOR), NULL, $$TRUE)
							UpdateWindow (GetDlgItem (hWnd, $$IDC_CBFORECOLOR))
						END IF
						RETURN
					END IF

				CASE $$IDB_USERBACKCOLOR :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						selColor = SendMessageA (GetDlgItem (hWnd, $$IDC_CBBACKCOLOR), $$CBCOL_GETUSERCOLOR, 0, 0)
						userColor = SED_ChooseColor (hWnd, selColor)
						IF userColor THEN
							SendMessageA (GetDlgItem (hWnd, $$IDC_CBBACKCOLOR), $$CBCOL_SETUSERCOLOR, userColor, 0)
							InvalidateRect (GetDlgItem (hWnd, $$IDC_CBBACKCOLOR), NULL, $$TRUE)
							UpdateWindow (GetDlgItem (hWnd, $$IDC_CBBACKCOLOR))
						END IF
						RETURN
					END IF

				CASE $$IDC_LBCOLSEL :		' Listbox control
					IF HIWORD (wParam) = $$LBN_DBLCLK || HIWORD (wParam) = $$LBN_SELCHANGE THEN
						curSel = Listbox_GetCurSel (GetDlgItem (hWnd, $$IDC_LBCOLSEL))
						curSelStr$ = Listbox_GetText (GetDlgItem (hWnd, $$IDC_LBCOLSEL), curSel)
						SED_ColorsAndFontsChangeSelection (hWnd, curSelStr$)
						SetFontExample (hWnd)
						RETURN
					END IF

			END SELECT

		CASE $$WM_CTLCOLORSTATIC :
			hdcStatic = wParam
			hwndStatic = lParam
			IF lParam = GetDlgItem (hWnd, $$IDC_STATICEXAMPLE) THEN
				hCbForeCol = GetDlgItem (hWnd, $$IDC_CBFORECOLOR)
				hCbBackCol = GetDlgItem (hWnd, $$IDC_CBBACKCOLOR)
				txtColor = SendMessageA (hCbForeCol, $$CBCOL_GETSELCOLOR, 0, 0)
				bkColor = SendMessageA (hCbBackCol, $$CBCOL_GETSELCOLOR, 0, 0)
				RETURN SetColor (txtColor, bkColor, wParam, lParam)
			END IF

		CASE $$WM_CLOSE :
			EnableWindow (GetParent (hWnd), $$TRUE)		' Maintains parent's zorder
			IF hExFont THEN DeleteObject (hExFont)

		CASE $$WM_DESTROY		' Exit
			PostQuitMessage (0)
			RETURN

	END SELECT

	RETURN DefWindowProcA (hWnd, wMsg, wParam, lParam)

END FUNCTION
'
' ##################################
' #####  Listbox_AddString ()  #####
' ##################################
'
' DESC: Add a string to a listbox.
' SYNTAX: RetVal = Listbox_AddString(hListBox, Text$)
' RETURNS: The return value is the zero-based index to the string in the list
' box. The return value is $$LB_ERR if an error occurs; the return value
' is $$LB_ERRSPACE if insufficient space is available to store the new
' string.
' REMARKS: If the listbox does not have the $$LBS_SORT style, the string is
' added to the end of the list. Otherwise, the string is inserted
' into the list and the list is sorted.
'
FUNCTION Listbox_AddString (hListBox, @text$)
	IFZ text$ THEN RETURN ($$TRUE)
	RETURN SendMessageA (hListBox, $$LB_ADDSTRING, 0, &text$)
END FUNCTION
'
' ##################################
' #####  Listbox_SetCurSel ()  #####
' ##################################
'
' DESC: Set the highlighted item in a listbox.
' SYNTAX: RetVal = Listbox_SetCurSel(hListBox, ItemPosition)
' RETURNS: The return value is $$LB_ERR if an error occurs.  The return value
' will be $$LB_ERR even though no error has occurred if the index
' parameter is -1.
' REMARKS: Listbox_SetCurSel selects a string and scrolls it into view, if necessary.
' When the new string is selected, the listbox removes the highlight
' from the previously selected string.  If the index parameter is -1,
' the listbox is set to have no selection.
'
FUNCTION Listbox_SetCurSel (hListBox, index)

	IF (GetWindowLongA (hListBox, $$GWL_STYLE) AND $$LBS_MULTIPLESEL) THEN
		msg = $$LB_SETSEL
	ELSE
		msg = $$LB_SETCURSEL
	END IF

	RETURN SendMessageA (hListBox, msg, index, 0)

END FUNCTION
'
' ##################################
' #####  FillFontSizeCombo ()  #####
' ##################################
'
' Fill a combobox with the allowed font sizes
'
FUNCTION FillFontSizeCombo (hWnd, fontName$)

	STATIC FullRange

	fontName$ = CSIZE$ (fontName$)
	hCb = GetDlgItem (hWnd, $$IDC_CBFONTSIZE)

	SELECT CASE fontName$
		CASE ""
			FullRange = $$FALSE
		CASE "Fixedsys"
			FullRange = $$FALSE
			Combo_ResetContent (hCb)
			Combo_AddString (hCb, "9")
		CASE "Courier"
			FullRange = $$FALSE
			Combo_ResetContent (hCb)
			Combo_AddString (hCb, "10")
			Combo_AddString (hCb, "12")
			Combo_AddString (hCb, "15")
		CASE "Terminal"
			FullRange = $$FALSE
			Combo_ResetContent (hCb)
			Combo_AddString (hCb, "5")
			Combo_AddString (hCb, "6")
			Combo_AddString (hCb, "12")
			Combo_AddString (hCb, "14")
		CASE ELSE
			IF FullRange THEN EXIT SELECT
			FullRange = $$TRUE
			Combo_ResetContent (hCb)
			Combo_AddString (hCb, "8")
			Combo_AddString (hCb, "9")
			Combo_AddString (hCb, "10")
			Combo_AddString (hCb, "11")
			Combo_AddString (hCb, "12")
			Combo_AddString (hCb, "14")
			Combo_AddString (hCb, "16")
			Combo_AddString (hCb, "18")
			Combo_AddString (hCb, "20")
			Combo_AddString (hCb, "22")
			Combo_AddString (hCb, "24")
			Combo_AddString (hCb, "26")
			Combo_AddString (hCb, "28")
			Combo_AddString (hCb, "32")
			Combo_AddString (hCb, "36")
	END SELECT

	Combo_SetCurSel (hCb, 0)

END FUNCTION
'
' ##############################
' #####  FillFontCombo ()  #####
' ##############################
'
' Fill a combo box with the names of all fonts of a certain type
'
FUNCTION FillFontCombo (hWnd)

	SendMessageA (hWnd, $$CB_RESETCONTENT, 0, 0)
	hDC = GetDC ($$HWND_DESKTOP)
	EnumFontFamiliesA (hDC, NULL, &EnumFontName (), hWnd)
	ReleaseDC ($$HWND_DESKTOP, hDC)

END FUNCTION
'
' #############################
' #####  EnumFontName ()  #####
' #############################
'
' Enumerate the names of all the fonts. Note the difference between
' how to enumerate them - $$TMPF_FIXED_PITCH has the bit cleared..
' $$TMPF_FIXED_PITCH for fixed pitch fonts
' $$TMPF_TRUETYPE OR $$TMPF_VECTOR for True type and vector fonts
' $$TMPF_DEVICE for device fonts (like printer fonts)
' Exclude what you don't want to include in list.
'
FUNCTION EnumFontName (lfAddr, tmAddr, fontType, hWnd)

	LOGFONT lf
	TEXTMETRIC tm

	RtlMoveMemory (&lf, lfAddr, SIZE (lf))

	SELECT CASE TRUE
		CASE (fontType AND $$TRUETYPE_FONTTYPE) :		' true type fonts
			SendMessageA (hWnd, $$CB_ADDSTRING, 0, &lf.faceName)
		CASE (fontType AND $$TMPF_FIXED_PITCH) = 0 :		' <- check if bit is cleared!
			SendMessageA (hWnd, $$CB_ADDSTRING, 0, &lf.faceName)		' fixed pitch fonts
		CASE (fontType AND $$TMPF_VECTOR) :
			SendMessageA (hWnd, $$CB_ADDSTRING, 0, &lf.faceName)		' vector fonts
		CASE (fontType AND $$TMPF_DEVICE) :
			SendMessageA (hWnd, $$CB_ADDSTRING, 0, &lf.faceName)		' device fonts
		CASE ELSE :
			SendMessageA (hWnd, $$CB_ADDSTRING, 0, &lf.faceName)		' system, fonts - the rest..
	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
' ###################################
' #####  Combo_ResetContent ()  #####
' ###################################
'
' DESC: Removes all items from the list box of a combo box.
' SYNTAX: Combo_ResetContent hComboBox
'
FUNCTION Combo_ResetContent (hComboBox)
	RETURN SendMessageA (hComboBox, $$CB_RESETCONTENT, 0, 0)
END FUNCTION
'
' ###############################
' #####  SetFontExample ()  #####
' ###############################
'
FUNCTION SetFontExample (hWnd)

	SHARED hExFont

	hCbFonts = GetDlgItem (hWnd, $$IDC_CBFONTS)
	hCbFontSize = GetDlgItem (hWnd, $$IDC_CBFONTSIZE)
	hCbExample = GetDlgItem (hWnd, $$IDC_STATICEXAMPLE)

	fontName$ = Combo_GetLbText (hCbFonts, -1)
	IFZ fontName$ THEN
		SetWindowTextA (hCbExample, NULL)
		InvalidateRect (hCbExample, NULL, $$TRUE)
		RETURN
	ELSE
		SetWindowTextA (hCbExample, &"Sample Text")
	END IF
	fontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
	fontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
	fontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
	fontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)

	IF hExFont THEN DeleteObject (hExFont)
	IF fontBold THEN weight = $$FW_BOLD ELSE weight = $$FW_NORMAL
	hExFont = NewFont (fontName$, fontSize, weight, fontItalic, fontUnderline)
	IF hExFont THEN SendMessageA (hCbExample, $$WM_SETFONT, hExFont, 0)
	InvalidateRect (hCbExample, NULL, $$TRUE)

END FUNCTION
'
' ##################################################
' #####  SED_ColorsAndFontsChangeSelection ()  #####
' ##################################################
'
' Change the selection
'
FUNCTION SED_ColorsAndFontsChangeSelection (hWnd, curSelStr$)

	SHARED SciColorsAndFontsType scf

	hCbForeCol = GetDlgItem (hWnd, $$IDC_CBFORECOLOR)
	hCbBackCol = GetDlgItem (hWnd, $$IDC_CBBACKCOLOR)
	hCbFonts = GetDlgItem (hWnd, $$IDC_CBFONTS)
	' hCbCharset  = GetDlgItem(hWnd, $$IDC_CBCHARSET)
	hCbFontSize = GetDlgItem (hWnd, $$IDC_CBFONTSIZE)

	SELECT CASE curSelStr$

		CASE "Default"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.DefaultFontName THEN scf.DefaultFontName = "Courier New"
			szTxt$ = scf.DefaultFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)

			IFZ scf.DefaultFontCharset THEN scf.DefaultFontCharset = "Ansi"
			' szTxt$ = scf.DefaultFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)

			IF scf.DefaultFontSize = 0 THEN scf.DefaultFontSize = 10
			szTxt$ = STRING$ (scf.DefaultFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.DefaultForeColor = 0 && scf.DefaultBackColor = 0 THEN
				scf.DefaultForeColor = $$Black
				scf.DefaultBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.DefaultForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.DefaultBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			' Checkboxes
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.DefaultFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.DefaultFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.DefaultFontUnderline)

		CASE "Comments"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.CommentFontName THEN scf.CommentFontName = "Courier New"
			szTxt$ = scf.CommentFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.CommentFontCharset THEN scf.CommentFontCharset = "Ansi"
			szTxt$ = scf.CommentFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.CommentFontSize = 0 THEN scf.CommentFontSize = 10
			szTxt$ = STRING$ (scf.CommentFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Green, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.CommentForeColor = 0 && scf.CommentBackColor = 0 THEN
				scf.CommentForeColor = $$Green
				scf.CommentBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.CommentForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.CommentBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			' Checkboxes
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.CommentFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.CommentFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.CommentFontUnderline)

		CASE "Constants"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.ConstantFontName THEN scf.ConstantFontName = "Courier New"
			szTxt$ = scf.ConstantFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.ConstantFontCharset THEN scf.ConstantFontCharset = "Ansi"
			szTxt$ = scf.ConstantFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.ConstantFontSize = 0 THEN scf.ConstantFontSize = 10
			szTxt$ = STRING$ (scf.ConstantFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, RGB(222,122,0), 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.ConstantForeColor = 0 && scf.ConstantBackColor = 0 THEN
				scf.ConstantForeColor = RGB(222,122,0)
				scf.ConstantBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.ConstantForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.ConstantBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.ConstantFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.ConstantFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.ConstantFontUnderline)

		CASE "Identifiers"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.IdentifierFontName THEN scf.IdentifierFontName = "Courier New"
			szTxt$ = scf.IdentifierFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.IdentifierFontCharset THEN scf.IdentifierFontCharset = "Ansi"
			szTxt$ = scf.IdentifierFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.IdentifierFontSize = 0 THEN scf.IdentifierFontSize = 10
			szTxt$ = STRING$ (scf.IdentifierFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.IdentifierForeColor = 0 && scf.IdentifierBackColor = 0 THEN
				scf.IdentifierForeColor = $$Black
				scf.IdentifierBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.IdentifierForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.IdentifierBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.IdentifierFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.IdentifierFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.IdentifierFontUnderline)

		CASE "Keywords"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.KeywordFontName THEN scf.KeywordFontName = "Courier New"
			szTxt$ = scf.KeywordFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.KeywordFontCharset THEN scf.KeywordFontCharset = "Ansi"
			szTxt$ = scf.KeywordFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.KeywordFontSize = 0 THEN scf.KeywordFontSize = 10
			szTxt$ = STRING$ (scf.KeywordFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$LightBlue, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.KeywordForeColor = 0 && scf.KeywordBackColor = 0 THEN
				scf.KeywordForeColor = $$LightBlue
				scf.KeywordBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.KeywordForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.KeywordBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.KeywordFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.KeywordFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.KeywordFontUnderline)

		CASE "Numbers"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.NumberFontName THEN scf.NumberFontName = "Courier New"
			szTxt$ = scf.NumberFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.NumberFontCharset THEN scf.NumberFontCharset = "Ansi"
			szTxt$ = scf.NumberFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.NumberFontSize = 0 THEN scf.NumberFontSize = 10
			szTxt$ = STRING$ (scf.NumberFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$LightRed, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.NumberForeColor = 0 && scf.NumberBackColor = 0 THEN
				scf.NumberForeColor = $$LightRed
				scf.NumberBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.NumberForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.NumberBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.NumberFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.NumberFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.NumberFontUnderline)

		CASE "Line Numbers"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.LineNumberFontName THEN scf.LineNumberFontName = "Courier New"
			szTxt$ = scf.LineNumberFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.LineNumberFontCharset THEN scf.LineNumberFontCharset = "Ansi"
			szTxt$ = scf.LineNumberFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.LineNumberFontSize = 0 THEN scf.LineNumberFontSize = 10
			szTxt$ = STRING$ (scf.LineNumberFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			' SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, RGB(235, 235, 235), 0
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$LightGrey, 0)
			IF scf.LineNumberForeColor = 0 && scf.LineNumberBackColor = 0 THEN
				scf.LineNumberForeColor = $$Black
				scf.LineNumberBackColor = $$LightGrey
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.LineNumberForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.LineNumberBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.LineNumberFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.LineNumberFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.LineNumberFontUnderline)

		CASE "Operators"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.OperatorFontName THEN scf.OperatorFontName = "Courier New"
			szTxt$ = scf.OperatorFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.OperatorFontCharset THEN scf.OperatorFontCharset = "Ansi"
			szTxt$ = scf.OperatorFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.OperatorFontSize = 0 THEN scf.OperatorFontSize = 10
			szTxt$ = STRING$ (scf.OperatorFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$LightMagenta, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.OperatorForeColor = 0 && scf.OperatorBackColor = 0 THEN
				scf.OperatorForeColor = $$LightMagenta
				scf.OperatorBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.OperatorForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.OperatorBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.OperatorFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.OperatorFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.OperatorFontUnderline)

		CASE "Inline ASM"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.ASMFontName THEN scf.ASMFontName = "Courier New"
			szTxt$ = scf.ASMFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.ASMFontCharset THEN scf.ASMFontCharset = "Ansi"
			szTxt$ = scf.ASMFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.ASMFontSize = 0 THEN scf.ASMFontSize = 10
			szTxt$ = STRING$ (scf.ASMFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Brown, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.ASMForeColor = 0 && scf.ASMBackColor = 0 THEN
				scf.ASMForeColor = $$Brown
				scf.ASMBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.ASMForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.ASMBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.ASMFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.ASMFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.ASMFontUnderline)

		CASE "Strings"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.StringFontName THEN scf.StringFontName = "Courier New"
			szTxt$ = scf.StringFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.StringFontCharset THEN scf.StringFontCharset = "Ansi"
			szTxt$ = scf.StringFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.StringFontSize = 0 THEN scf.StringFontSize = 10
			szTxt$ = STRING$ (scf.StringFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$BrightRed, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.StringForeColor = 0 && scf.StringBackColor = 0 THEN
				scf.StringForeColor = $$BrightRed
				scf.StringBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.StringForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.StringBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.StringFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.StringFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.StringFontUnderline)

		CASE "Caret"
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.CaretForeColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$FALSE)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Edge"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.EdgeForeColor = 0 && scf.EdgeBackColor = 0 THEN
				scf.EdgeBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.EdgeForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.EdgeBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Fold"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$LightRed, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.FoldForeColor = 0 && scf.FoldBackColor = 0 THEN
				scf.FoldForeColor = $$LightRed
				scf.FoldBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.FoldForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.FoldBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Fold Open"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$LightRed, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.FoldOpenForeColor = 0 && scf.FoldOpenBackColor = 0 THEN
				scf.FoldOpenForeColor = $$LightRed
				scf.FoldOpenBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.FoldOpenForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.FoldOpenBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Fold Margin"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, RGB (200, 0, 200), 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, RGB (100, 0, 100), 0)
			IF scf.FoldMarginForeColor = 0 && scf.FoldMarginBackColor = 0 THEN
				scf.FoldMarginForeColor = RGB (200, 0, 200)
				scf.FoldMarginBackColor = RGB (100, 0, 100)
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.FoldMarginForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.FoldMarginBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Indent Guides"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.IndentGuideForeColor = 0 && scf.IndentGuideBackColor = 0 THEN
				scf.IndentGuideForeColor = $$Black
				scf.IndentGuideBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.IndentGuideForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.IndentGuideBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Selection"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$MediumBlue, 0)
			IF scf.SelectionForeColor = 0 && scf.SelectionBackColor = 0 THEN
				scf.SelectionForeColor = $$White
				scf.SelectionBackColor = $$MediumBlue
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.SelectionForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.SelectionBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Whitespace"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.WhitespaceForeColor = 0 && scf.WhitespaceBackColor = 0 THEN
				scf.WhitespaceBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.WhitespaceForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.WhitespaceBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Submenu Text"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, RGB (255, 249, 242), 0)
			IF scf.SubMenuTextForeColor = 0 && scf.SubMenuTextBackColor = 0 THEN
				scf.SubMenuTextForeColor = $$Black
				scf.SubMenuTextBackColor = RGB (255, 249, 242)
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.SubMenuTextForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.SubMenuTextBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Submenu Highlighted Text"
			' Default color
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Black, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, 0x00EFD3C1, 0)
			IF scf.SubMenuHiTextForeColor = 0 && scf.SubMenuHiTextBackColor = 0 THEN
				scf.SubMenuHiTextForeColor = $$Black
				scf.SubMenuHiTextBackColor = 0x00EFD3C1
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.SubMenuHiTextForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.SubMenuHiTextBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "Caret Line"
			EnableWindow (hCbForeCol, $$FALSE)
			EnableWindow (hCbBackCol, $$TRUE)
			' Default color
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, RGB (220, 240, 255), 0)
			' User selected color
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.CaretLineBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_ITALIC, $$BST_UNCHECKED)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, $$BST_UNCHECKED)
			Combo_SetCurSel (hCbFonts, -1)
			' Combo_SetCurSel (hCbCharset, -1)
			Combo_SetCurSel (hCbFontSize, -1)
			EnableWindow (hCbFonts, $$FALSE)
			' EnableWindow (hCbCharset, $$FALSE)
			EnableWindow (hCbFontSize, $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$FALSE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$FALSE)

		CASE "ASM FPU Instruction"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.AsmFpuInstructionFontName THEN scf.AsmFpuInstructionFontName = "Courier New"
			szTxt$ = scf.AsmFpuInstructionFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.AsmFpuInstructionFontCharset THEN scf.AsmFpuInstructionFontCharset = "Ansi"
			szTxt$ = scf.AsmFpuInstructionFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.AsmFpuInstructionFontSize = 0 THEN scf.AsmFpuInstructionFontSize = 10
			szTxt$ = STRING$ (scf.AsmFpuInstructionFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$BrightRed, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.AsmFpuInstructionForeColor = 0 && scf.AsmFpuInstructionBackColor = 0 THEN
				scf.AsmFpuInstructionForeColor = $$BrightRed
				scf.AsmFpuInstructionBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.AsmFpuInstructionForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.AsmFpuInstructionBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.AsmFpuInstructionFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.AsmFpuInstructionFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.AsmFpuInstructionFontUnderline)

		CASE "ASM Register"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.AsmRegisterFontName THEN scf.AsmRegisterFontName = "Courier New"
			szTxt$ = scf.AsmRegisterFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.AsmRegisterFontCharset THEN scf.AsmRegisterFontCharset = "Ansi"
			szTxt$ = scf.AsmRegisterFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.AsmRegisterFontSize = 0 THEN scf.AsmRegisterFontSize = 10
			szTxt$ = STRING$ (scf.AsmRegisterFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$BrightGreen, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.AsmRegisterForeColor = 0 && scf.AsmRegisterBackColor = 0 THEN
				scf.AsmRegisterForeColor = $$BrightGreen
				scf.AsmRegisterBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.AsmRegisterForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.AsmRegisterBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.AsmRegisterFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.AsmRegisterFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.AsmRegisterFontUnderline)

		CASE "ASM Directive"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.AsmDirectiveFontName THEN scf.AsmDirectiveFontName = "Courier New"
			szTxt$ = scf.AsmDirectiveFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.AsmDirectiveFontCharset THEN scf.AsmDirectiveFontCharset = "Ansi"
			szTxt$ = scf.AsmDirectiveFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.AsmDirectiveFontSize = 0 THEN scf.AsmDirectiveFontSize = 10
			szTxt$ = STRING$ (scf.AsmDirectiveFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$BrightRed, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.AsmDirectiveForeColor = 0 && scf.AsmDirectiveBackColor = 0 THEN
				scf.AsmDirectiveForeColor = $$BrightRed
				scf.AsmDirectiveBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.AsmDirectiveForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.AsmDirectiveBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.AsmDirectiveFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.AsmDirectiveFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.AsmDirectiveFontUnderline)

		CASE "ASM Directive Operand"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.AsmDirectiveOperandFontName THEN scf.AsmDirectiveOperandFontName = "Courier New"
			szTxt$ = scf.AsmDirectiveFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.AsmDirectiveOperandFontCharset THEN scf.AsmDirectiveOperandFontCharset = "Ansi"
			szTxt$ = scf.AsmDirectiveOperandFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.AsmDirectiveOperandFontSize = 0 THEN scf.AsmDirectiveOperandFontSize = 10
			szTxt$ = STRING$ (scf.AsmDirectiveOperandFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$BrightRed, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.AsmDirectiveOperandForeColor = 0 && scf.AsmDirectiveOperandBackColor = 0 THEN
				scf.AsmDirectiveOperandForeColor = $$BrightRed
				scf.AsmDirectiveOperandBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.AsmDirectiveOperandForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.AsmDirectiveOperandBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.AsmDirectiveOperandFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.AsmDirectiveOperandFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.AsmDirectiveOperandFontUnderline)

		CASE "ASM Extended Instruction"
			EnableWindow (hCbForeCol, $$TRUE)
			EnableWindow (hCbBackCol, $$TRUE)
			EnableWindow (hCbFonts, $$TRUE)
			' EnableWindow (hCbCharset, $$TRUE)
			EnableWindow (hCbFontSize, $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_BOLD), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_ITALIC), $$TRUE)
			EnableWindow (GetDlgItem (hWnd, $$IDK_UNDERLINE), $$TRUE)
			IFZ scf.AsmExtendedInstructionFontName THEN scf.AsmExtendedInstructionFontName = "Courier New"
			szTxt$ = scf.AsmExtendedInstructionFontName
			SendMessageA (hCbFonts, $$CB_SELECTSTRING, -1, &szTxt$)
			IFZ scf.AsmExtendedInstructionFontCharset THEN scf.AsmExtendedInstructionFontCharset = "Ansi"
			szTxt$ = scf.AsmExtendedInstructionFontCharset
			' SendMessageA (hCbCharset, $$CB_SELECTSTRING, -1, &szTxt$)
			IF scf.AsmExtendedInstructionFontSize = 0 THEN scf.AsmExtendedInstructionFontSize = 10
			szTxt$ = STRING$ (scf.AsmExtendedInstructionFontSize)
			SendMessageA (hCbFontSize, $$CB_SELECTSTRING, -1, &szTxt$)
			' Default color
			SendMessageA (hCbForeCol, $$CBCOL_SETAUTOCOLOR, $$Blue, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETAUTOCOLOR, $$White, 0)
			IF scf.AsmExtendedInstructionForeColor = 0 && scf.AsmExtendedInstructionBackColor = 0 THEN
				scf.AsmExtendedInstructionForeColor = $$Blue
				scf.AsmExtendedInstructionBackColor = $$White
			END IF
			' User selected color
			SendMessageA (hCbForeCol, $$CBCOL_SETUSERCOLOR, scf.AsmExtendedInstructionForeColor, 0)
			SendMessageA (hCbBackCol, $$CBCOL_SETUSERCOLOR, scf.AsmExtendedInstructionBackColor, 0)
			' Select the user color
			Combo_SetCurSel (hCbForeCol, 17)
			Combo_SetCurSel (hCbBackCol, 17)
			CheckDlgButton (hWnd, $$IDK_BOLD, scf.AsmExtendedInstructionFontBold)
			CheckDlgButton (hWnd, $$IDK_ITALIC, scf.AsmExtendedInstructionFontItalic)
			CheckDlgButton (hWnd, $$IDK_UNDERLINE, scf.AsmExtendedInstructionFontUnderline)

	END SELECT

END FUNCTION
'
' ##################################
' #####  Listbox_GetCurSel ()  #####
' ##################################
'
' DESC: Get the current selection index of the listbox.
' SYNTAX: ItemPosition = Listbox_GetCurSel( hListBox )
'
FUNCTION Listbox_GetCurSel (hListBox)

	IF (GetWindowLongA (hListBox, $$GWL_STYLE) AND $$LBS_MULTIPLESEL) THEN
		msg = $$LB_GETCARETINDEX
	ELSE
		msg = $$LB_GETCURSEL
	END IF

	RETURN SendMessageA (hListBox, msg, 0, 0)

END FUNCTION
'
' ################################
' #####  Listbox_GetText ()  #####
' ################################
'
' DESC: Return the text of the selected listbox item.
' SYNTAX: Text$ = Listbox_GetText( hListBox, ItemPosition )
'
FUNCTION STRING Listbox_GetText (hListBox, index)

	buffer$ = NULL$ (255)

	IF index < 0 THEN
		index = Listbox_GetCurSel (hListBox)
	END IF

	SendMessageA (hListBox, $$LB_GETTEXT, index, &buffer$)

	RETURN (CSIZE$ (buffer$))

END FUNCTION
'
' ##############################
' #####  DrawFontCombo ()  #####
' ##############################
'
' WM_DRAWITEM ownerdrawn procedure for font combobox
' this draws the fontname text with the fontname font
'
FUNCTION DrawFontCombo (hWnd, wParam, lParam)

	DRAWITEMSTRUCT dis

	RtlMoveMemory (&dis, lParam, SIZE (dis))

	IF dis.itemID = 0xFFFFFFFF THEN EXIT FUNCTION		'empty list, take a break..

	SELECT CASE dis.itemAction
		CASE $$ODA_DRAWENTIRE, $$ODA_SELECT :
			' CLEAR BACKGROUND
			IF (dis.itemState AND $$ODS_SELECTED) = 0 || (dis.itemState AND $$ODS_COMBOBOXEDIT) THEN		'or if in edit part of combo
				SetBkColor (dis.hDC, GetSysColor ($$COLOR_WINDOW))		'text background
				SetTextColor (dis.hDC, GetSysColor ($$COLOR_WINDOWTEXT))		'text color
				FillRect (dis.hDC, &dis.rcItem, GetSysColorBrush ($$COLOR_WINDOW))		'clear background
			ELSE
				SetBkColor (dis.hDC, GetSysColor ($$COLOR_HIGHLIGHT))		'sel text background
				SetTextColor (dis.hDC, GetSysColor ($$COLOR_HIGHLIGHTTEXT))		'sel text color
				FillRect (dis.hDC, &dis.rcItem, GetSysColorBrush ($$COLOR_HIGHLIGHT))		'clear background
			END IF

			' get fontname, create the font and then draw text
			zTxt$ = Combo_GetLbText (hWnd, dis.itemID)
			IF zTxt$ THEN
				hFnt = NewFont (zTxt$, 11, 0, 0, 0)
				IF hFnt THEN hFnt = SelectObject (dis.hDC, hFnt)
				DrawTextA (dis.hDC, &zTxt$, LEN (zTxt$), &dis.rcItem, $$DT_SINGLELINE OR $$DT_LEFT OR $$DT_VCENTER)
				IF hFnt THEN DeleteObject (SelectObject (dis.hDC, hFnt))
			END IF

			' draw focus rect around selected item
			IF (dis.itemState AND $$ODS_SELECTED) THEN		' if selected
				DrawFocusRect (dis.hDC, &dis.rcItem)		' draw a focus rectangle around all
			END IF
			RETURN ($$TRUE)

	END SELECT

END FUNCTION
'
' #################################################
' #####  SED_ColorsAndFontsStoreSelection ()  #####
' #################################################
'
' Save the font color and name selections
'
FUNCTION SED_ColorsAndFontsStoreSelection (hWnd, curSelStr$)

	SHARED SciColorsAndFontsType scf

	hCbForeCol = GetDlgItem (hWnd, $$IDC_CBFORECOLOR)
	hCbBackCol = GetDlgItem (hWnd, $$IDC_CBBACKCOLOR)
	hCbFonts = GetDlgItem (hWnd, $$IDC_CBFONTS)
	' hCbCharset  = GetDlgItem(hWnd, $$IDC_CBCHARSET)
	hCbFontSize = GetDlgItem (hWnd, $$IDC_CBFONTSIZE)

	SELECT CASE curSelStr$
			' Color and fonts
		CASE "Default"
			scf.DefaultForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.DefaultBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.DefaultFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.DefaultFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.DefaultFontName)
			scf.DefaultFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.DefaultFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.DefaultFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.DefaultFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Comments"
			scf.CommentForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.CommentBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.CommentFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.CommentFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.CommentFontName)
			scf.CommentFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.CommentFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.CommentFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.CommentFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Constants"
			scf.ConstantForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.ConstantBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.ConstantFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.ConstantFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.ConstantFontName)
			scf.ConstantFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.ConstantFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.ConstantFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.ConstantFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Identifiers"
			scf.IdentifierForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.IdentifierBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.IdentifierFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.IdentifierFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.IdentifierFontName)
			scf.IdentifierFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.IdentifierFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.IdentifierFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.IdentifierFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Keywords"
			scf.KeywordForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.KeywordBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.KeywordFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.KeywordFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.KeywordFontName)
			scf.KeywordFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.KeywordFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.KeywordFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.KeywordFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Numbers"
			scf.NumberForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.NumberBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.NumberFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.NumberFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.NumberFontName)
			scf.NumberFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.NumberFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.NumberFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.NumberFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Line Numbers"
			scf.LineNumberForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.LineNumberBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.LineNumberFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.LineNumberFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.LineNumberFontName)
			scf.LineNumberFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.LineNumberFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.LineNumberFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.LineNumberFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Operators"
			scf.OperatorForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.OperatorBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.OperatorFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.OperatorFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.OperatorFontName)
			scf.OperatorFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.OperatorFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.OperatorFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.OperatorFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Inline ASM"
			scf.ASMForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.ASMBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.ASMFontName = Combo_GetLbText (hCbFonts, -1)
			' scf.ASMFontCharset = Combo_GetLbText(hCbCharset, -1)
			FillFontSizeCombo (hCbFontSize, scf.ASMFontName)
			scf.ASMFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.ASMFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.ASMFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.ASMFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "Strings"
			scf.StringForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.StringBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.StringFontName = Combo_GetLbText (hCbFonts, -1)
			FillFontSizeCombo (hCbFontSize, scf.StringFontName)
			scf.StringFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.StringFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.StringFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.StringFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "ASM FPU Instruction"
			scf.AsmFpuInstructionForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmFpuInstructionBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmFpuInstructionFontName = Combo_GetLbText (hCbFonts, -1)
			FillFontSizeCombo (hCbFontSize, scf.AsmFpuInstructionFontName)
			scf.AsmFpuInstructionFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.AsmFpuInstructionFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.AsmFpuInstructionFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.AsmFpuInstructionFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "ASM Register"
			scf.AsmRegisterForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmRegisterBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmRegisterFontName = Combo_GetLbText (hCbFonts, -1)
			FillFontSizeCombo (hCbFontSize, scf.AsmRegisterFontName)
			scf.AsmRegisterFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.AsmRegisterFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.AsmRegisterFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.AsmRegisterFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "ASM Directive"
			scf.AsmDirectiveForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmDirectiveBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmDirectiveFontName = Combo_GetLbText (hCbFonts, -1)
			FillFontSizeCombo (hCbFontSize, scf.AsmDirectiveFontName)
			scf.AsmDirectiveFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.AsmDirectiveFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.AsmDirectiveFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.AsmDirectiveFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "ASM Directive Operand"
			scf.AsmDirectiveOperandForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmDirectiveOperandBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmDirectiveOperandFontName = Combo_GetLbText (hCbFonts, -1)
			FillFontSizeCombo (hCbFontSize, scf.AsmDirectiveOperandFontName)
			scf.AsmDirectiveOperandFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.AsmDirectiveOperandFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.AsmDirectiveOperandFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.AsmDirectiveOperandFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)
		CASE "ASM Extended Instruction"
			scf.AsmExtendedInstructionForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmExtendedInstructionBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.AsmExtendedInstructionFontName = Combo_GetLbText (hCbFonts, -1)
			FillFontSizeCombo (hCbFontSize, scf.AsmExtendedInstructionFontName)
			scf.AsmExtendedInstructionFontSize = XLONG (Combo_GetLbText (hCbFontSize, -1))
			scf.AsmExtendedInstructionFontBold = IsDlgButtonChecked (hWnd, $$IDK_BOLD)
			scf.AsmExtendedInstructionFontItalic = IsDlgButtonChecked (hWnd, $$IDK_ITALIC)
			scf.AsmExtendedInstructionFontUnderline = IsDlgButtonChecked (hWnd, $$IDK_UNDERLINE)

		' Color only
		CASE "Caret"
			scf.CaretForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Edge"
			scf.EdgeForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.EdgeBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Fold"
			scf.FoldForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.FoldBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Fold Open"
			scf.FoldOpenForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.FoldOpenBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Fold Margin"
			scf.FoldMarginForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.FoldMarginBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Indent Guides"
			scf.IndentGuideForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.IndentGuideBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Selection"
			scf.SelectionForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.SelectionBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Whitespace"
			scf.WhitespaceForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.WhitespaceBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Submenu Text"
			scf.SubMenuTextForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.SubMenuTextBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Submenu Highlighted Text"
			scf.SubMenuHiTextForeColor = SendMessageA (hCbForeCol, $$CBCOL_GETUSERCOLOR, 0, 0)
			scf.SubMenuHiTextBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
		CASE "Caret line"
			scf.CaretLineBackColor = SendMessageA (hCbBackCol, $$CBCOL_GETUSERCOLOR, 0, 0)
	END SELECT
END FUNCTION
'
' ##################################
' #####  WriteColorOptions ()  #####
' ##################################
'
' Writes the Colors options to the .INI file
'
FUNCTION WriteColorOptions (SciColorsAndFontsType ColOpt)

	SHARED IniFile$
	' Default
	IniWrite (IniFile$, "Color options", "DefaultForeColor", STRING$ (ColOpt.DefaultForeColor))
	IniWrite (IniFile$, "Color options", "DefaultBackColor", STRING$ (ColOpt.DefaultBackColor))
	IniWrite (IniFile$, "Color options", "DefaultFontName", ColOpt.DefaultFontName)
	IniWrite (IniFile$, "Color options", "DefaultFontCharset", ColOpt.DefaultFontCharset)
	IniWrite (IniFile$, "Color options", "DefaultFontSize", STRING$ (ColOpt.DefaultFontSize))
	IniWrite (IniFile$, "Color options", "DefaultFontBold", STRING$ (ColOpt.DefaultFontBold))
	IniWrite (IniFile$, "Color options", "DefaultFontItalic", STRING$ (ColOpt.DefaultFontItalic))
	IniWrite (IniFile$, "Color options", "DefaultFontUnderline", STRING$ (ColOpt.DefaultFontUnderline))
	' Comments
	IniWrite (IniFile$, "Color options", "CommentForeColor", STRING$ (ColOpt.CommentForeColor))
	IniWrite (IniFile$, "Color options", "CommentBackColor", STRING$ (ColOpt.CommentBackColor))
	IniWrite (IniFile$, "Color options", "CommentFontName", ColOpt.CommentFontName)
	IniWrite (IniFile$, "Color options", "CommentForeCharset", ColOpt.CommentFontCharset)
	IniWrite (IniFile$, "Color options", "CommentFontSize", STRING$ (ColOpt.CommentFontSize))
	IniWrite (IniFile$, "Color options", "CommentFontBold", STRING$ (ColOpt.CommentFontBold))
	IniWrite (IniFile$, "Color options", "CommentFontItalic", STRING$ (ColOpt.CommentFontItalic))
	IniWrite (IniFile$, "Color options", "CommentFontUnderline", STRING$ (ColOpt.CommentFontUnderline))
	' Constants
	IniWrite (IniFile$, "Color options", "ConstantForeColor", STRING$ (ColOpt.ConstantForeColor))
	IniWrite (IniFile$, "Color options", "ConstantBackColor", STRING$ (ColOpt.ConstantBackColor))
	IniWrite (IniFile$, "Color options", "ConstantFontName", ColOpt.ConstantFontName)
	IniWrite (IniFile$, "Color options", "ConstantFontCharset", ColOpt.ConstantFontCharset)
	IniWrite (IniFile$, "Color options", "ConstantFontSize", STRING$ (ColOpt.ConstantFontSize))
	IniWrite (IniFile$, "Color options", "ConstantFontBold", STRING$ (ColOpt.ConstantFontBold))
	IniWrite (IniFile$, "Color options", "ConstantFontItalic", STRING$ (ColOpt.ConstantFontItalic))
	IniWrite (IniFile$, "Color options", "ConstantFontUnderline", STRING$ (ColOpt.ConstantFontUnderline))
	' Identifier
	IniWrite (IniFile$, "Color options", "IdentifierForeColor", STRING$ (ColOpt.IdentifierForeColor))
	IniWrite (IniFile$, "Color options", "IdentifierBackColor", STRING$ (ColOpt.IdentifierBackColor))
	IniWrite (IniFile$, "Color options", "IdentifierFontName", ColOpt.IdentifierFontName)
	IniWrite (IniFile$, "Color options", "IdentifierFontCharset", ColOpt.IdentifierFontCharset)
	IniWrite (IniFile$, "Color options", "IdentifierFontSize", STRING$ (ColOpt.IdentifierFontSize))
	IniWrite (IniFile$, "Color options", "IdentifierFontBold", STRING$ (ColOpt.IdentifierFontBold))
	IniWrite (IniFile$, "Color options", "IdentifierFontItalic", STRING$ (ColOpt.IdentifierFontItalic))
	IniWrite (IniFile$, "Color options", "IdentifierFontUnderline", STRING$ (ColOpt.IdentifierFontUnderline))
	' Keywords
	IniWrite (IniFile$, "Color options", "KeywordForeColor", STRING$ (ColOpt.KeywordForeColor))
	IniWrite (IniFile$, "Color options", "KeywordBackColor", STRING$ (ColOpt.KeywordBackColor))
	IniWrite (IniFile$, "Color options", "KeywordFontName", ColOpt.KeywordFontName)
	IniWrite (IniFile$, "Color options", "KeywordFontCharset", ColOpt.KeywordFontCharset)
	IniWrite (IniFile$, "Color options", "KeywordFontSize", STRING$ (ColOpt.KeywordFontSize))
	IniWrite (IniFile$, "Color options", "KeywordFontBold", STRING$ (ColOpt.KeywordFontBold))
	IniWrite (IniFile$, "Color options", "KeywordFontItalic", STRING$ (ColOpt.KeywordFontItalic))
	IniWrite (IniFile$, "Color options", "KeywordFontUnderline", STRING$ (ColOpt.KeywordFontUnderline))
	' Numbers
	IniWrite (IniFile$, "Color options", "NumberForeColor", STRING$ (ColOpt.NumberForeColor))
	IniWrite (IniFile$, "Color options", "NumberBackColor", STRING$ (ColOpt.NumberBackColor))
	IniWrite (IniFile$, "Color options", "NumberFontName", ColOpt.NumberFontName)
	IniWrite (IniFile$, "Color options", "NumberFontCharset", ColOpt.NumberFontCharset)
	IniWrite (IniFile$, "Color options", "NumberFontSize", STRING$ (ColOpt.NumberFontSize))
	IniWrite (IniFile$, "Color options", "NumberFontBold", STRING$ (ColOpt.NumberFontBold))
	IniWrite (IniFile$, "Color options", "NumberFontItalic", STRING$ (ColOpt.NumberFontItalic))
	IniWrite (IniFile$, "Color options", "NumberFontUnderline", STRING$ (ColOpt.NumberFontUnderline))
	' Line numbers
	IniWrite (IniFile$, "Color options", "LineNumberForeColor", STRING$ (ColOpt.LineNumberForeColor))
	IniWrite (IniFile$, "Color options", "LineNumberBackColor", STRING$ (ColOpt.LineNumberBackColor))
	IniWrite (IniFile$, "Color options", "LineNumberFontName", ColOpt.LineNumberFontName)
	IniWrite (IniFile$, "Color options", "LineNumberFontCharset", ColOpt.LineNumberFontCharset)
	IniWrite (IniFile$, "Color options", "LineNumberFontSize", STRING$ (ColOpt.LineNumberFontSize))
	IniWrite (IniFile$, "Color options", "LineNumberFontBold", STRING$ (ColOpt.LineNumberFontBold))
	IniWrite (IniFile$, "Color options", "LineNumberFontItalic", STRING$ (ColOpt.LineNumberFontItalic))
	IniWrite (IniFile$, "Color options", "LineNumberFontUnderline", STRING$ (ColOpt.LineNumberFontUnderline))
	' Operators
	IniWrite (IniFile$, "Color options", "OperatorForeColor", STRING$ (ColOpt.OperatorForeColor))
	IniWrite (IniFile$, "Color options", "OperatorBackColor", STRING$ (ColOpt.OperatorBackColor))
	IniWrite (IniFile$, "Color options", "OperatorFontName", ColOpt.OperatorFontName)
	IniWrite (IniFile$, "Color options", "OperatorFontCharset", ColOpt.OperatorFontCharset)
	IniWrite (IniFile$, "Color options", "OperatorFontSize", STRING$ (ColOpt.OperatorFontSize))
	IniWrite (IniFile$, "Color options", "OperatorFontBold", STRING$ (ColOpt.OperatorFontBold))
	IniWrite (IniFile$, "Color options", "OperatorFontItalic", STRING$ (ColOpt.OperatorFontItalic))
	IniWrite (IniFile$, "Color options", "OperatorFontUnderline", STRING$ (ColOpt.OperatorFontUnderline))
	' ASM
	IniWrite (IniFile$, "Color options", "ASMForeColor", STRING$ (ColOpt.ASMForeColor))
	IniWrite (IniFile$, "Color options", "ASMBackColor", STRING$ (ColOpt.ASMBackColor))
	IniWrite (IniFile$, "Color options", "ASMFontName", ColOpt.ASMFontName)
	IniWrite (IniFile$, "Color options", "ASMFontCharset", ColOpt.ASMFontCharset)
	IniWrite (IniFile$, "Color options", "ASMFontSize", STRING$ (ColOpt.ASMFontSize))
	IniWrite (IniFile$, "Color options", "ASMFontBold", STRING$ (ColOpt.ASMFontBold))
	IniWrite (IniFile$, "Color options", "ASMFontItalic", STRING$ (ColOpt.ASMFontItalic))
	IniWrite (IniFile$, "Color options", "ASMFontUnderline", STRING$ (ColOpt.ASMFontUnderline))
	' Strings
	IniWrite (IniFile$, "Color options", "StringForeColor", STRING$ (ColOpt.StringForeColor))
	IniWrite (IniFile$, "Color options", "StringBackColor", STRING$ (ColOpt.StringBackColor))
	IniWrite (IniFile$, "Color options", "StringFontName", ColOpt.StringFontName)
	IniWrite (IniFile$, "Color options", "StringFontCharset", ColOpt.StringFontCharset)
	IniWrite (IniFile$, "Color options", "StringFontSize", STRING$ (ColOpt.StringFontSize))
	IniWrite (IniFile$, "Color options", "StringFontBold", STRING$ (ColOpt.StringFontBold))
	IniWrite (IniFile$, "Color options", "StringFontItalic", STRING$ (ColOpt.StringFontItalic))
	IniWrite (IniFile$, "Color options", "StringFontUnderline", STRING$ (ColOpt.StringFontUnderline))
	' Asm  fpu instruction
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionForeColor", STRING$ (ColOpt.AsmFpuInstructionForeColor))
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionBackColor", STRING$ (ColOpt.AsmFpuInstructionBackColor))
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionFontName", ColOpt.AsmFpuInstructionFontName)
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionFontCharset", ColOpt.AsmFpuInstructionFontCharset)
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionFontSize", STRING$ (ColOpt.AsmFpuInstructionFontSize))
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionFontBold", STRING$ (ColOpt.AsmFpuInstructionFontBold))
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionFontItalic", STRING$ (ColOpt.AsmFpuInstructionFontItalic))
	IniWrite (IniFile$, "Color options", "AsmFpuInstructionFontUnderline", STRING$ (ColOpt.AsmFpuInstructionFontUnderline))
	' Asm  register
	IniWrite (IniFile$, "Color options", "AsmRegisterForeColor", STRING$ (ColOpt.AsmRegisterForeColor))
	IniWrite (IniFile$, "Color options", "AsmRegisterBackColor", STRING$ (ColOpt.AsmRegisterBackColor))
	IniWrite (IniFile$, "Color options", "AsmRegisterFontName", ColOpt.AsmRegisterFontName)
	IniWrite (IniFile$, "Color options", "AsmRegisterFontCharset", ColOpt.AsmRegisterFontCharset)
	IniWrite (IniFile$, "Color options", "AsmRegisterFontSize", STRING$ (ColOpt.AsmRegisterFontSize))
	IniWrite (IniFile$, "Color options", "AsmRegisterFontBold", STRING$ (ColOpt.AsmRegisterFontBold))
	IniWrite (IniFile$, "Color options", "AsmRegisterFontItalic", STRING$ (ColOpt.AsmRegisterFontItalic))
	IniWrite (IniFile$, "Color options", "AsmRegisterFontUnderline", STRING$ (ColOpt.AsmRegisterFontUnderline))
	' Asm  directive
	IniWrite (IniFile$, "Color options", "AsmDirectiveForeColor", STRING$ (ColOpt.AsmDirectiveForeColor))
	IniWrite (IniFile$, "Color options", "AsmDirectiveBackColor", STRING$ (ColOpt.AsmDirectiveBackColor))
	IniWrite (IniFile$, "Color options", "AsmDirectiveFontName", ColOpt.AsmDirectiveFontName)
	IniWrite (IniFile$, "Color options", "AsmDirectiveFontCharset", ColOpt.AsmDirectiveFontCharset)
	IniWrite (IniFile$, "Color options", "AsmDirectiveFontSize", STRING$ (ColOpt.AsmDirectiveFontSize))
	IniWrite (IniFile$, "Color options", "AsmDirectiveFontBold", STRING$ (ColOpt.AsmDirectiveFontBold))
	IniWrite (IniFile$, "Color options", "AsmDirectiveFontItalic", STRING$ (ColOpt.AsmDirectiveFontItalic))
	IniWrite (IniFile$, "Color options", "AsmDirectiveFontUnderline", STRING$ (ColOpt.AsmDirectiveFontUnderline))
	' Asm  directive operand
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandForeColor", STRING$ (ColOpt.AsmDirectiveOperandForeColor))
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandBackColor", STRING$ (ColOpt.AsmDirectiveOperandBackColor))
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandFontName", ColOpt.AsmDirectiveOperandFontName)
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandFontCharset", ColOpt.AsmDirectiveOperandFontCharset)
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandFontSize", STRING$ (ColOpt.AsmDirectiveOperandFontSize))
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandFontBold", STRING$ (ColOpt.AsmDirectiveOperandFontBold))
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandFontItalic", STRING$ (ColOpt.AsmDirectiveOperandFontItalic))
	IniWrite (IniFile$, "Color options", "AsmDirectiveOperandFontUnderline", STRING$ (ColOpt.AsmDirectiveOperandFontUnderline))
	' Asm  extended instruction
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionForeColor", STRING$ (ColOpt.AsmExtendedInstructionForeColor))
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionBackColor", STRING$ (ColOpt.AsmExtendedInstructionBackColor))
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionFontName", ColOpt.AsmExtendedInstructionFontName)
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionFontCharset", ColOpt.AsmExtendedInstructionFontCharset)
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionFontSize", STRING$ (ColOpt.AsmExtendedInstructionFontSize))
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionFontBold", STRING$ (ColOpt.AsmExtendedInstructionFontBold))
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionFontItalic", STRING$ (ColOpt.AsmExtendedInstructionFontItalic))
	IniWrite (IniFile$, "Color options", "AsmExtendedInstructionFontUnderline", STRING$ (ColOpt.AsmExtendedInstructionFontUnderline))

	' Caret
	IniWrite (IniFile$, "Color options", "CaretForeColor", STRING$ (ColOpt.CaretForeColor))
	' Edge
	IniWrite (IniFile$, "Color options", "EdgeForeColor", STRING$ (ColOpt.EdgeForeColor))
	IniWrite (IniFile$, "Color options", "EdgeBackColor", STRING$ (ColOpt.EdgeBackColor))
	' Fold
	IniWrite (IniFile$, "Color options", "FoldForeColor", STRING$ (ColOpt.FoldForeColor))
	IniWrite (IniFile$, "Color options", "FoldBackColor", STRING$ (ColOpt.FoldBackColor))
	' Fold open
	IniWrite (IniFile$, "Color options", "FoldOpenForeColor", STRING$ (ColOpt.FoldOpenForeColor))
	IniWrite (IniFile$, "Color options", "FoldOpenBackColor", STRING$ (ColOpt.FoldOpenBackColor))
	' Fold margin
	IniWrite (IniFile$, "Color options", "FoldMarginForeColor", STRING$ (ColOpt.FoldMarginForeColor))
	IniWrite (IniFile$, "Color options", "FoldMarginBackColor", STRING$ (ColOpt.FoldMarginBackColor))
	' Indent guides
	IniWrite (IniFile$, "Color options", "InsertGuideForeColor", STRING$ (ColOpt.IndentGuideForeColor))
	IniWrite (IniFile$, "Color options", "InsertGuideBackColor", STRING$ (ColOpt.IndentGuideBackColor))
	' Selection
	IniWrite (IniFile$, "Color options", "SelectionForeColor", STRING$ (ColOpt.SelectionForeColor))
	IniWrite (IniFile$, "Color options", "SelectionBackColor", STRING$ (ColOpt.SelectionBackColor))
	' Whitespace
	IniWrite (IniFile$, "Color options", "WhitespaceForeColor", STRING$ (ColOpt.WhitespaceForeColor))
	IniWrite (IniFile$, "Color options", "WhitespaceBackColor", STRING$ (ColOpt.WhitespaceBackColor))
	' Codetips
'	IniWrite (IniFile$, "Color options", "CodetipForeColor", STRING$ (ColOpt.CodetipForeColor))
'	IniWrite (IniFile$, "Color options", "CodetipBackColor", STRING$ (ColOpt.CodetipBackColor))
	' Submenus
	IniWrite (IniFile$, "Color options", "SubMenuTextForeColor", STRING$ (ColOpt.SubMenuTextForeColor))
	IniWrite (IniFile$, "Color options", "SubMenuTextBackColor", STRING$ (ColOpt.SubMenuTextBackColor))
	IniWrite (IniFile$, "Color options", "SubMenuHiTextForeColor", STRING$ (ColOpt.SubMenuHiTextForeColor))
	IniWrite (IniFile$, "Color options", "SubMenuHiTextBackColor", STRING$ (ColOpt.SubMenuHiTextBackColor))
	' Caret line background color
	IniWrite (IniFile$, "Color options", "CaretLineBackColor", STRING$ (ColOpt.CaretLineBackColor))
  ' Use always the default background color
  IniWrite (IniFile$, "Color options", "AlwaysUseDefaultBackColor", STRING$ (ColOpt.AlwaysUseDefaultBackColor))
  ' Use always the default font
  IniWrite (IniFile$, "Color options", "AlwaysUseDefaultFont",STRING$(ColOpt.AlwaysUseDefaultFont))
  ' Use always the default font size
  IniWrite (IniFile$, "Color options", "AlwaysUseDefaultFontSize", STRING$(ColOpt.AlwaysUseDefaultFontSize))

END FUNCTION
'
' ################################
' #####  SED_ChooseColor ()  #####
' ################################
'
' Open choose color dialog
'
FUNCTION SED_ChooseColor (hParent, defaultColor)

	CHOOSECOLOR cc

	DIM lCustomColor[15]

	cc.lStructSize = SIZE (cc)
	cc.hwndOwner = hParent		'Handle of owner window.  If 0, dialog appears at top/left.
	cc.lpCustColors = &lCustomColor[0]

	' xRed = ExtractRedColor(defaultColor)
	' xGreen = ExtractGreenColor(defaultColor)
	' xBlue = ExtractBlueColor(defaultColor)
	' cc.rgbResult = RGB(xRed, xGreen, xBlue)

	cc.rgbResult = defaultColor		'set the default color

	' try these options one by one, for different effects...
	cc.flags = cc.flags OR $$CC_RGBINIT OR $$CC_FULLOPEN		'tells control to start at default color

	FOR i = 1 TO 16		' create initial grayscale color map for
		cl = i * 16 - 1		' COMDLG32's extra colors in ChooseColor dialog
		lCustomColor[16 - i] = RGB (cl, cl, cl)
	NEXT

	lResult = ChooseColorA (&cc)
	IF lResult THEN RETURN cc.rgbResult

END FUNCTION
'
' ##############################
' #####  XSED_AboutBox ()  #####
' ##############################
'
' About XSED dialog box
'
FUNCTION XSED_AboutBox (hWnd)

	SHARED hInst

	' note that resources must use resource number 23, eg, "pinky.htm  23 DISCARDABLE pinky.htm"
	res$ = "res://"   													' this indicates that it is a resource url
	fn$ = NULL$(256)
	GetModuleFileNameA (hInst, &fn$, LEN(fn$)) 	' get executable file name
	url$ = res$ + CSIZE$(fn$) + "/about.html"   ' add htm file to display
	ShowHTMLDlg (hWnd, url$, 0, 0, 380, 370, 0, 0, 1)

END FUNCTION
'
' #########################
' #####  HtmlHelp ()  #####
' #########################
'
' Display Html Help file *.chm.
'
FUNCTION HtmlHelp (hwndCaller, file$, command, dwData)

FUNCADDR HHelp (XLONG, XLONG, XLONG, XLONG)

	hhctrl = LoadLibraryA (&"hhctrl.ocx")
	IFZ hhctrl THEN
		error$ = "Error : LoadLibraryA : hhctrl.ocx"
		GOSUB ErrorFound
	END IF

' get function addresses

	HHelp = GetProcAddress (hhctrl, &"HtmlHelpA")
	IFZ HHelp THEN
		error$ = "Error : GetProcAddress : HtmlHelpA"
		GOSUB ErrorFound
	END IF

' call the function
	IFZ file$ THEN
		ret = @HHelp (hwndCaller, NULL, command, dwData)
	ELSE
		ret = @HHelp (hwndCaller, &file$, command, dwData)
	END IF

' free ocx library
	FreeLibrary (hhctrl)

  RETURN ret

' ***** ErrorFound *****
SUB ErrorFound
	MessageBoxA (NULL, &error$, &"HtmlHelp() Error", 0)
'	PRINT error$
 	RETURN ($$TRUE)
END SUB

END FUNCTION
'
' ###################################
' #####  WriteHelpFilePaths ()  #####
' ###################################
'
' Write help file paths to ini file.
'
FUNCTION WriteHelpFilePaths ()

  SHARED IniFile$
  CompilerOptionsType CpOpt

  GetCompilerOptions (@CpOpt)

	IF CpOpt.XBLPath THEN
		comp$ = CpOpt.XBLPath
		pos = INSTR (comp$, "bin")
		IF pos THEN
		  p$ = LEFT$ (comp$, pos - 1)
		  p1$ = ""
			p1$ =  p$ + "manual\\xblite_manual.chm"
			IniWrite (IniFile$, "Tools options", "XBLHelp", p1$)
		  p1$ = ""
			p1$ = p$ + "manual\\xsed.chm"
			IniWrite (IniFile$, "Tools options", "XSEDHelp", p1$)
		  p1$ = ""
			p1$ = p$ + "manual\\goasm.chm"
			IniWrite (IniFile$, "Tools options", "GoAsmHelp", p1$)
			p1$ = ""
			p1$ = p$ + "bin\\rc.hlp"
      IniWrite (IniFile$, "Tools options", "RCHelp", p1$)
    END IF
	END IF

END FUNCTION
'
' ##################################
' #####  InsertNewFunction ()  #####
' ##################################
'
' Insert a new function. Add function to PROLOG
' function declaration list, then add function
' to end of program body.
'
FUNCTION InsertNewFunction (hWnd)

	SHARED hCodeFinder
	SHARED hInst
	SHARED fNewFunctionHeader    ' flag to indicate if header is used

  $CRLF = "\r\n"

  hEdit = GetEdit()
  IFZ hEdit THEN RETURN

	' Open New Function Dialog Box
	addr = DialogBoxParamA (hInst, 300, hWnd, &NewFunctionInputBoxProc (), 0)
	IF addr THEN
    fname$ = CSTRING$ (addr)
  ELSE
    RETURN
  END IF

  char = fname${0}
	IF ((char >= '0') AND (char <= '9')) THEN
		msg$ = " Function name cannot begin with a digit.   "
		SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " New Function")
		RETURN
	END IF

	lastChar = UBOUND(fname$)
	FOR i = 0 TO lastChar
		cchar = fname${i}
		IF ((cchar >= 'a') AND (cchar <= 'z')) THEN DO NEXT
		IF ((cchar >= 'A') AND (cchar <= 'Z')) THEN DO NEXT
		IF ((cchar >= '0') AND (cchar <= '9')) THEN DO NEXT
		IF ((cchar >= 192) AND (cchar <= 214)) THEN DO NEXT
		IF ((cchar >= 216) AND (cchar <= 246)) THEN DO NEXT
		IF ((cchar >= 248) AND (cchar <= 255)) THEN DO NEXT
		IF (cchar = '_') THEN DO NEXT
		IF (cchar = '$') THEN									' only explicit type is STRING
			IF (i = lastChar) THEN EXIT FOR
		END IF
		IF (cchar = ' ') THEN                 ' one space only allowed between TYPE declaration and function name
		  IFZ spaceCount THEN
		    INC spaceCount
		    index = 0
	      done = 0
	      firstFunc$ = XstNextField$ (fname$, @index, @done)
	      secondFunc$ = XstNextField$ (fname$, @index, @done)
	      SELECT CASE firstFunc$
	        CASE "XLONG", "ULONG", "USHORT", "SSHORT", "SLONG", "UBYTE", "SBYTE", "STRING", "SINGLE", "DOUBLE", "LONGDOUBLE", "GIANT", "VOID" : DO NEXT
	      END SELECT
      END IF
		END IF
		msg$ = " Function name contains an invalid character.   "
		SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " New Function")
		RETURN
	NEXT i

	' check to see if it already exists
	' see if fname$ is in function name combobox
	search$ = fname$
	IF secondFunc$ THEN search$ = secondFunc$
	find = SendMessageA (hCodeFinder, $$CB_FINDSTRINGEXACT, -1, &search$)
  IF find > 0 THEN
    msg$ = " Function name already exists.   "
		SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " New Function")
		' select function
		Combo_SetCurSel (hCodeFinder, find)
		SendMessageA (hWnd, $$WM_COMMAND, MAKELONG($$IDC_CODEFINDER, $$CBN_SELCHANGE), 0)
		RETURN
  END IF

  ' find last DECLARE/INTERNAL/EXTERNAL FUNCTION in PROLOG
  ' find last END FUNCTION if it exists

	endLine = SendMessageA (hEdit, $$SCI_GETLINECOUNT, 0, 0) - 1

	FOR i = 0 TO endLine
		length = SendMessageA (hEdit, $$SCI_LINELENGTH, i, 0)		' length of the line
		line$ = NULL$ (length)		' size the buffer
		SendMessageA (hEdit, $$SCI_GETLINE, i, &line$)		' get the text of the line
		line$ = LTRIM$(line$)
	  index = 0
	  done = 0
	  firstWord$ = XstNextField$ (line$, @index, @done)
	  secondWord$ = XstNextField$ (line$, @index, @done)
	  SELECT CASE firstWord$
	    CASE "DECLARE", "INTERNAL", "EXTERNAL" :
        IF secondWord$ = "FUNCTION" THEN lastDecLine = i
      CASE "END" :
        IF secondWord$ = "FUNCTION" THEN lastFuncLine = i
	  END SELECT
	NEXT i

'  IFZ lastDecLine * lastFuncLine THEN
'    SED_MsgBox (hWnd, " Cannot add new function!   ", $$MB_OK | $$MB_ICONEXCLAMATION, " Insert New Function")
'  END IF
  IF lastDecLine = 0 && lastFuncLine = 0 THEN
    lastDecLine = endLine
    lastFuncLine = endLine
  END IF

' insert function declaration
  text$ = "DECLARE FUNCTION " + fname$ + " ()" + "\r\n"
  SendMessageA (hEdit, $$SCI_GOTOLINE, lastDecLine + 1, 0)
  SendMessageA (hEdit, $$SCI_INSERTTEXT, -1, &text$)

' insert function header and function body

  body$ = "FUNCTION " + fname$ + " ()" + $CRLF
  body$ = body$ + $CRLF
  body$ = body$ + "END FUNCTION" + $CRLF

  IF secondFunc$ THEN fname$ = secondFunc$

  IF fNewFunctionHeader THEN
    length = LEN(fname$)
    header$ = "'" + $CRLF
    header$ = header$ + "' " + CHR$('#', length+14) + $CRLF
    header$ = header$ + "' " + CHR$('#', 5) + SPACE$(2) + fname$ + SPACE$(2) + CHR$('#', 5) + $CRLF
    header$ = header$ + "' " + CHR$('#', length+14) + $CRLF
    header$ = header$ + "'" + $CRLF
    header$ = header$ + "'" + $CRLF
    header$ = header$ + "'" + $CRLF
  ELSE
    header$ = $CRLF
  END IF

  text$ = header$ + body$

  SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 1 + 1, 0)  ' add one line to compensate for inserted DECLARE FUNCTION
  SendMessageA (hEdit, $$SCI_INSERTTEXT, -1, &text$)

	y = SendMessageA (hEdit, $$SCI_GETTEXTLENGTH, 0, 0)
	' Set to end position of document
	SendMessageA (hEdit, $$SCI_GOTOLINE, y, 0)

	' set position to first line of function
	IF fNewFunctionHeader THEN
		SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 9, 0)
	ELSE
		SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 3, 0)
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
' ########################################
' #####  NewFunctionInputBoxProc ()  #####
' ########################################
'
FUNCTION NewFunctionInputBoxProc (hwndDlg, msg, wParam, lParam)

	STATIC text$
	SHARED fNewFunctionHeader
	$NEW_FUNCTION_CHECKBOX = 303

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			text$ = ""
			XstCenterWindow (hwndDlg)
			SELECT CASE fNewFunctionHeader
        CASE $$BST_CHECKED   : CheckDlgButton (hwndDlg, $NEW_FUNCTION_CHECKBOX, $$BST_CHECKED)
        CASE $$BST_UNCHECKED : CheckDlgButton (hwndDlg, $NEW_FUNCTION_CHECKBOX, $$BST_UNCHECKED)
			END SELECT

		CASE $$WM_CTLCOLORDLG, $$WM_CTLCOLORBTN, $$WM_CTLCOLORSTATIC :
			RETURN SetColor (0, GetSysColor($$COLOR_BTNFACE), wParam, lParam)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD (wParam)
			ID = LOWORD (wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID :

					  CASE $NEW_FUNCTION_CHECKBOX :
					    SELECT CASE IsDlgButtonChecked (hwndDlg, $NEW_FUNCTION_CHECKBOX)
                CASE $$BST_CHECKED   : fNewFunctionHeader = $$BST_CHECKED
                CASE $$BST_UNCHECKED : fNewFunctionHeader = $$BST_UNCHECKED
					    END SELECT

 						CASE $$IDCANCEL :
							EndDialog (hwndDlg, 0)

						CASE $$IDOK:
							text$ = NULL$ (255)
							GetDlgItemTextA (hwndDlg, 302, &text$, LEN (text$))
							text$ = CSIZE$ (text$)
							IF text$ THEN
								EndDialog (hwndDlg, &text$)
							ELSE
								EndDialog (hwndDlg, 0)
							END IF

					END SELECT
			END SELECT

		CASE ELSE : RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)
END FUNCTION
'
' ###############################
' #####  DeleteFunction ()  #####
' ###############################
'
' Delete function at current cursor position
'
FUNCTION DeleteFunction (hWnd)

  PROC proc

  hEdit = GetEdit ()
  IFZ hEdit THEN RETURN

  IFZ SED_WithinProc (@proc) THEN   ' we are inside a function body
    fn$ = proc.ProcName
    start = proc.UpLnNo
    finish = proc.DnLnNo
    ' delete function body
    ' set text starting target position
    posStart = SendMessageA (hEdit, $$SCI_POSITIONFROMLINE, start, 0)
    SendMessageA (hEdit, $$SCI_SETTARGETSTART, posStart, 0)
    ' set text ending target position
    lenLast = SendMessageA (hEdit, $$SCI_LINELENGTH, finish, 0)
    pEnd = SendMessageA (hEdit, $$SCI_POSITIONFROMLINE, finish, 0)
    posEnd = lenLast + pEnd
    SendMessageA (hEdit, $$SCI_SETTARGETEND, posEnd, 0)
    ' replace selection with empty string
    SendMessageA (hEdit, $$SCI_REPLACETARGET, 0, NULL)

    ' delete function declaration in PROLOG
    endLine = SendMessageA (hEdit, $$SCI_GETLINECOUNT, 0, 0) - 1

    FOR i = 0 TO endLine
		  length = SendMessageA (hEdit, $$SCI_LINELENGTH, i, 0)		' length of the line
		  line$ = NULL$ (length)		' size the buffer
		  SendMessageA (hEdit, $$SCI_GETLINE, i, &line$)					' get the text of the line
		  line$ = LTRIM$(line$)
      index = 0
      done = 0
      firstWord$ = XstNextField$ (line$, @index, @done)
      secondWord$ = XstNextField$ (line$, @index, @done)
      SELECT CASE firstWord$
        CASE "DECLARE", "INTERNAL", "EXTERNAL" :
          IF secondWord$ = "FUNCTION" THEN
            IF INSTR (line$, fn$) THEN
              ' set text starting target position
              posStart = SendMessageA (hEdit, $$SCI_POSITIONFROMLINE, i, 0)
              SendMessageA (hEdit, $$SCI_SETTARGETSTART, posStart, 0)
              ' set text ending target position
              lenLast = SendMessageA (hEdit, $$SCI_LINELENGTH, i, 0)
              posEnd = posStart + lenLast
              SendMessageA (hEdit, $$SCI_SETTARGETEND, posEnd, 0)
              ' replace line with empty string
              SendMessageA (hEdit, $$SCI_REPLACETARGET, 0, NULL)
              EXIT FOR
            END IF
          END IF
      END SELECT
    NEXT i
		RETURN ($$TRUE)
  END IF

END FUNCTION
'
' ##############################
' #####  CloneFunction ()  #####
' ##############################
'
' Copy function at current cursor position.
' Add new function name to PROLOG
' function declaration list, then add function
' to end of program body.
'
FUNCTION CloneFunction (hWnd)

	SHARED hCodeFinder
	SHARED hInst
	SHARED fCloneFunctionHeader    ' flag to indicate if header is used
  PROC proc

  $CRLF = "\r\n"

  hEdit = GetEdit ()
  IFZ hEdit THEN RETURN

  IFZ SED_WithinProc (@proc) THEN   ' we are inside a function body
    fn$   = proc.ProcName
    start = proc.UpLnNo
    finish  = proc.DnLnNo

    ' copy function body text
    SED_GetTextLines (hEdit, start, finish, @funcBody$)
    funcBody$ = TRIM$ (funcBody$)
    IFZ funcBody$ THEN RETURN

    ' copy function declaration in PROLOG
    endLine = SendMessageA (hEdit, $$SCI_GETLINECOUNT, 0, 0) - 1

    FOR i = 0 TO endLine
		  length = SendMessageA (hEdit, $$SCI_LINELENGTH, i, 0)		' length of the line
		  line$ = NULL$ (length)																	' size the buffer
		  SendMessageA (hEdit, $$SCI_GETLINE, i, &line$)					' get the text of the line
		  line$ = LTRIM$(line$)
      index = 0
      done = 0
      firstWord$ = XstNextField$ (line$, @index, @done)
      secondWord$ = XstNextField$ (line$, @index, @done)
      SELECT CASE firstWord$
        CASE "DECLARE", "INTERNAL", "EXTERNAL" :
          IF secondWord$ = "FUNCTION" THEN
            IF INSTR (line$, fn$) THEN
              ' get length of text in line
              length = SendMessageA (hEdit, $$SCI_GETLINE, i, 0)
              IF length THEN
                funcDec$ = NULL$(length)
                ' get function declaration line
                SendMessageA (hEdit, $$SCI_GETLINE, i, &funcDec$)
                funcDec$ = TRIM$ (CSIZE$ (funcDec$))
                IFZ funcDec$ THEN RETURN
              END IF
              EXIT FOR
            END IF
          END IF
      END SELECT
    NEXT i
  ELSE
    RETURN
  END IF

	' Open Clone Function Dialog Box
	addr = DialogBoxParamA (hInst, 400, hWnd, &CloneFunctionInputBoxProc (), 0)
	IF addr THEN
    fname$ = CSTRING$ (addr)
  ELSE
    RETURN
  END IF

  char = fname${0}
	IF ((char >= '0') AND (char <= '9')) THEN
		msg$ = " Function name cannot begin with a digit.   "
		SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " Clone Function")
		RETURN
	END IF

	lastChar = UBOUND(fname$)
	FOR i = 0 TO lastChar
		cchar = fname${i}
		IF ((cchar >= 'a') AND (cchar <= 'z')) THEN DO NEXT
		IF ((cchar >= 'A') AND (cchar <= 'Z')) THEN DO NEXT
		IF ((cchar >= '0') AND (cchar <= '9')) THEN DO NEXT
		IF ((cchar >= 192) AND (cchar <= 214)) THEN DO NEXT
		IF ((cchar >= 216) AND (cchar <= 246)) THEN DO NEXT
		IF ((cchar >= 248) AND (cchar <= 255)) THEN DO NEXT
		IF (cchar = '_') THEN DO NEXT
		IF (cchar = '$') THEN									' only explicit type is STRING
			IF (i = lastChar) THEN EXIT FOR
		END IF
		msg$ = " Function name contains an invalid character.   "
		SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " Clone Function")
		RETURN
	NEXT i

	' check to see if it already exists
	' see if fname$ is in function name combobox
	search$ = fname$
	IF secondFunc$ THEN search$ = secondFunc$
	find = SendMessageA (hCodeFinder, $$CB_FINDSTRINGEXACT, -1, &search$)
  IF find > 0 THEN
    msg$ = " Function name already exists.   "
		SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " Clone Function")
		' select function
		Combo_SetCurSel (hCodeFinder, find)
		SendMessageA (hWnd, $$WM_COMMAND, MAKELONG($$IDC_CODEFINDER, $$CBN_SELCHANGE), 0)
		RETURN
  END IF

  ' find last DECLARE/INTERNAL/EXTERNAL FUNCTION in PROLOG
  ' find last END FUNCTION if it exists

	endLine = SendMessageA (hEdit, $$SCI_GETLINECOUNT, 0, 0) - 1

	FOR i = 0 TO endLine
		length = SendMessageA (hEdit, $$SCI_LINELENGTH, i, 0)		' length of the line
		line$ = NULL$ (length)																	' size the buffer
		SendMessageA (hEdit, $$SCI_GETLINE, i, &line$)					' get the text of the line
		line$ = LTRIM$(line$)
	  index = 0
	  done = 0
	  firstWord$ = XstNextField$ (line$, @index, @done)
	  secondWord$ = XstNextField$ (line$, @index, @done)
	  SELECT CASE firstWord$
	    CASE "DECLARE", "INTERNAL", "EXTERNAL" :
        IF secondWord$ = "FUNCTION" THEN lastDecLine = i
      CASE "END" :
        IF secondWord$ = "FUNCTION" THEN lastFuncLine = i
	  END SELECT
	NEXT i

'  IFZ lastDecLine * lastFuncLine THEN
'    SED_MsgBox (hWnd, " Cannot add new function!   ", $$MB_OK | $$MB_ICONEXCLAMATION, " Insert New Function")
'  END IF
  IF lastDecLine = 0 && lastFuncLine = 0 THEN
    lastDecLine = endLine
    lastFuncLine = endLine
  END IF

' insert function declaration
  XstReplace (@funcDec$, fn$, fname$, 1)
  funcDec$ = funcDec$ + $CRLF
'  text$ = "DECLARE FUNCTION " + fname$ + " ()" + "\r\n"
  SendMessageA (hEdit, $$SCI_GOTOLINE, lastDecLine + 1, 0)
  SendMessageA (hEdit, $$SCI_INSERTTEXT, -1, &funcDec$)

' insert function header and function body

  XstReplace (@funcBody$, fn$, fname$, 1)
  body$ = funcBody$ + $CRLF

  IF fCloneFunctionHeader THEN
    length = LEN(fname$)
    header$ = "'" + $CRLF
    header$ = header$ + "' " + CHR$('#', length+14) + $CRLF
    header$ = header$ + "' " + CHR$('#', 5) + SPACE$(2) + fname$ + SPACE$(2) + CHR$('#', 5) + $CRLF
    header$ = header$ + "' " + CHR$('#', length+14) + $CRLF
    header$ = header$ + "'" + $CRLF
    header$ = header$ + "'" + $CRLF
    header$ = header$ + "'" + $CRLF
  ELSE
    header$ = $CRLF
  END IF

  text$ = header$ + body$

  SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 1 + 1, 0)  ' add one line to compensate for inserted DECLARE FUNCTION
  SendMessageA (hEdit, $$SCI_INSERTTEXT, -1, &text$)

	y = SendMessageA (hEdit, $$SCI_GETTEXTLENGTH, 0, 0)
	' Set to end position of document
	SendMessageA (hEdit, $$SCI_GOTOLINE, y, 0)

	' set position to first line of function
	IF fCloneFunctionHeader THEN
		SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 9, 0)
	ELSE
		SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 3, 0)
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
' #################################
' #####  SED_GetTextRange ()  #####
' #################################
'
' Copy text in editor hEdit from position min to max.
'
FUNCTION SED_GetTextRange (hEdit, minimum, maximum, @text$)

  TEXTRANGE tr

  IFZ hEdit THEN RETURN ($$TRUE)

  tr.chrg.cpMin = minimum
  tr.chrg.cpMax = maximum
  text$ = NULL$ (maximum - minimum + 1)
  tr.lpstrText = &text$

  RETURN SendMessageA (hEdit, $$SCI_GETTEXTRANGE, 0, &tr)

END FUNCTION
'
' #################################
' #####  SED_GetTextLines ()  #####
' #################################
'
' Copy text lines in editor hEdit from line number start
' to line end (0 based).
'
FUNCTION SED_GetTextLines (hEdit, start, finish, @text$)

  IFZ hEdit THEN RETURN
  text$ = ""
  minimum = SendMessageA (hEdit, $$SCI_POSITIONFROMLINE, start, 0)
  lenLast = SendMessageA (hEdit, $$SCI_LINELENGTH, finish, 0)
  pEnd = SendMessageA (hEdit, $$SCI_POSITIONFROMLINE, finish, 0)
  maximum = lenLast + pEnd
  RETURN SED_GetTextRange (hEdit, minimum, maximum, @text$)

END FUNCTION
'
' ##########################################
' #####  CloneFunctionInputBoxProc ()  #####
' ##########################################
'
FUNCTION CloneFunctionInputBoxProc (hwndDlg, msg, wParam, lParam)

	STATIC text$
	SHARED fCloneFunctionHeader
	$CLONE_FUNCTION_CHECKBOX = 403

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			text$ = ""
			XstCenterWindow (hwndDlg)
			SELECT CASE fCloneFunctionHeader
        CASE $$BST_CHECKED   : CheckDlgButton (hwndDlg, $CLONE_FUNCTION_CHECKBOX, $$BST_CHECKED)
        CASE $$BST_UNCHECKED : CheckDlgButton (hwndDlg, $CLONE_FUNCTION_CHECKBOX, $$BST_UNCHECKED)
			END SELECT

		CASE $$WM_CTLCOLORDLG, $$WM_CTLCOLORBTN, $$WM_CTLCOLORSTATIC :
			RETURN SetColor (0, GetSysColor($$COLOR_BTNFACE), wParam, lParam)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD (wParam)
			ID = LOWORD (wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID :

					  CASE $CLONE_FUNCTION_CHECKBOX :
					    SELECT CASE IsDlgButtonChecked (hwndDlg, $CLONE_FUNCTION_CHECKBOX)
                CASE $$BST_CHECKED   : fCloneFunctionHeader = $$BST_CHECKED
                CASE $$BST_UNCHECKED : fCloneFunctionHeader = $$BST_UNCHECKED
					    END SELECT

 						CASE $$IDCANCEL :
							EndDialog (hwndDlg, 0)

						CASE $$IDOK:
							text$ = NULL$ (255)
							GetDlgItemTextA (hwndDlg, 402, &text$, LEN (text$))
							text$ = CSIZE$ (text$)
							IF text$ THEN
								EndDialog (hwndDlg, &text$)
							ELSE
								EndDialog (hwndDlg, 0)
							END IF

					END SELECT
			END SELECT

		CASE ELSE : RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)
END FUNCTION
'
' ###############################
' #####  ImportFunction ()  #####
' ###############################
'
' Import a function from a valid xblite file.
'
FUNCTION ImportFunction (hWnd)

  SHARED hInst
  SHARED fImportFunctionHeader
	SHARED importFuncName$, importFileName$
	SHARED hCodeFinder

  $CRLF = "\r\n"

  hEdit = GetEdit()
  IFZ hEdit THEN RETURN

	' Open Import Function Dialog Box
	IFZ DialogBoxParamA (hInst, 500, hWnd, &ImportFunctionInputBoxProc (), 0) THEN RETURN

	GetFileExtension (importFileName$, @file$, @ext$)
	SELECT CASE UCASE$ (ext$)
    CASE "X", "XL", "XBL" :
    CASE ELSE :
      msg$ = " Not an XBLite file extension.   "
		  SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " Clone Function")
		  RETURN
	END SELECT

	' check to see if function name already exists in current program
	' see if importFuncName$ is in function name combobox
	search$ = importFuncName$
	find = SendMessageA (hCodeFinder, $$CB_FINDSTRINGEXACT, -1, &search$)
  IF find > 0 THEN
    msg$ = " Function name already exists.   "
		SED_MsgBox (hWnd, msg$, $$MB_OK | $$MB_ICONEXCLAMATION, " Clone Function")
		' select function
		Combo_SetCurSel (hCodeFinder, find)
		SendMessageA (hWnd, $$WM_COMMAND, MAKELONG($$IDC_CODEFINDER, $$CBN_SELCHANGE), 0)
		RETURN
  END IF

	' load file
	IF XstLoadStringArray (@importFileName$, @text$[]) THEN
    SED_MsgBox (hWnd, " Error loading file!   ", $$MB_OK | $$MB_ICONEXCLAMATION, " Import Function")
    RETURN
  END IF

	IFZ text$[] THEN
    SED_MsgBox (hWnd, " Empty file!   ", $$MB_OK | $$MB_ICONEXCLAMATION, " Import Function")
    RETURN
  END IF

	' find function declaration in PROLOG and function body
	upper = UBOUND (text$[])

	FOR i = 0 TO upper
		line$ = text$[i]
	  index = 0
	  done = 0
	  firstWord$ = XstNextField$ (line$, @index, @done)
	  secondWord$ = XstNextField$ (line$, @index, @done)
	  SELECT CASE firstWord$
	    CASE "DECLARE", "INTERNAL" :
        IF secondWord$ = "FUNCTION" THEN
          IF INSTR (line$, importFuncName$) THEN
            funcDec$ = line$
          END IF
        END IF
      CASE "FUNCTION" :
        IF INSTR (line$, importFuncName$) THEN
          startLine = i
        END IF
      CASE "END" :
        IF secondWord$ = "FUNCTION" THEN
          IF startLine THEN
            endLine = i
            EXIT FOR
          END IF
        END IF
	  END SELECT
	NEXT i

	IFZ funcDec$ THEN
    SED_MsgBox (hWnd, " Function declaration not found!   ", $$MB_OK | $$MB_ICONEXCLAMATION, " Import Function")
    RETURN
  END IF

  IFZ endLine THEN
    SED_MsgBox (hWnd, " Function body not found!   ", $$MB_OK | $$MB_ICONEXCLAMATION, " Import Function")
    RETURN
  END IF

  ' create function body string
  FOR i = startLine TO endLine
    body$ = body$ + text$[i] + $CRLF
  NEXT i

  ' find last DECLARE/INTERNAL/EXTERNAL FUNCTION in PROLOG
  ' find last END FUNCTION if it exists

	endLine = SendMessageA (hEdit, $$SCI_GETLINECOUNT, 0, 0) - 1

	FOR i = 0 TO endLine
		len = SendMessageA (hEdit, $$SCI_LINELENGTH, i, 0)		' length of the line
		line$ = NULL$ (len)		' size the buffer
		SendMessageA (hEdit, $$SCI_GETLINE, i, &line$)		' get the text of the line
		line$ = LTRIM$(line$)
	  index = 0
	  done = 0
	  firstWord$ = XstNextField$ (line$, @index, @done)
	  secondWord$ = XstNextField$ (line$, @index, @done)
	  SELECT CASE firstWord$
	    CASE "DECLARE", "INTERNAL", "EXTERNAL" :
        IF secondWord$ = "FUNCTION" THEN lastDecLine = i
      CASE "END" :
        IF secondWord$ = "FUNCTION" THEN lastFuncLine = i
	  END SELECT
	NEXT i

'  IFZ lastDecLine * lastFuncLine THEN
'    SED_MsgBox (hWnd, " Cannot add new function!   ", $$MB_OK | $$MB_ICONEXCLAMATION, " Insert New Function")
'  END IF
  IF lastDecLine = 0 && lastFuncLine = 0 THEN
    lastDecLine = endLine
    lastFuncLine = endLine
  END IF

' insert function declaration
  funcDec$ = funcDec$ + $CRLF
  SendMessageA (hEdit, $$SCI_GOTOLINE, lastDecLine + 1, 0)
  SendMessageA (hEdit, $$SCI_INSERTTEXT, -1, &funcDec$)

' insert function header and function body
  IF fImportFunctionHeader THEN
    len = LEN(importFuncName$)
    header$ = "'" + $CRLF
    header$ = header$ + "' " + CHR$('#', len+14) + $CRLF
    header$ = header$ + "' " + CHR$('#', 5) + SPACE$(2) + importFuncName$ + SPACE$(2) + CHR$('#', 5) + $CRLF
    header$ = header$ + "' " + CHR$('#', len+14) + $CRLF
    header$ = header$ + "'" + $CRLF
    header$ = header$ + "'" + $CRLF
    header$ = header$ + "'" + $CRLF
  ELSE
    header$ = $CRLF
  END IF

  text$ = header$ + body$

  SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 1 + 1, 0)  ' add one line to compensate for inserted DECLARE FUNCTION
  SendMessageA (hEdit, $$SCI_INSERTTEXT, -1, &text$)

	y = SendMessageA (hEdit, $$SCI_GETTEXTLENGTH, 0, 0)
	' Set to end position of document
	SendMessageA (hEdit, $$SCI_GOTOLINE, y, 0)

	' set position to first line of function
	IF fImportFunctionHeader THEN
		SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 9, 0)
	ELSE
		SendMessageA (hEdit, $$SCI_GOTOLINE, lastFuncLine + 3, 0)
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
' ###########################################
' #####  ImportFunctionInputBoxProc ()  #####
' ###########################################
'
FUNCTION ImportFunctionInputBoxProc (hwndDlg, msg, wParam, lParam)

	SHARED fImportFunctionHeader
	SHARED importFuncName$, importFileName$
	SHARED hWndMain

	$IMPORT_FUNCTION_CHECKBOX = 503
	$IMPORT_FUNCTION_FILEDIALOG_PB = 506

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			importFuncName$ = ""
			XstCenterWindow (hwndDlg)
			IF importFileName$ THEN
        SetDlgItemTextA (hwndDlg, 505, &importFileName$)
      END IF
			SELECT CASE fImportFunctionHeader
        CASE $$BST_CHECKED   : CheckDlgButton (hwndDlg, $IMPORT_FUNCTION_CHECKBOX, $$BST_CHECKED)
        CASE $$BST_UNCHECKED : CheckDlgButton (hwndDlg, $IMPORT_FUNCTION_CHECKBOX, $$BST_UNCHECKED)
			END SELECT

		CASE $$WM_CTLCOLORDLG, $$WM_CTLCOLORBTN, $$WM_CTLCOLORSTATIC :
			RETURN SetColor (0, GetSysColor($$COLOR_BTNFACE), wParam, lParam)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD (wParam)
			ID = LOWORD (wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID :

					  CASE $IMPORT_FUNCTION_CHECKBOX :
					    SELECT CASE IsDlgButtonChecked (hwndDlg, $IMPORT_FUNCTION_CHECKBOX)
                CASE $$BST_CHECKED   : fImportFunctionHeader = $$BST_CHECKED
                CASE $$BST_UNCHECKED : fImportFunctionHeader = $$BST_UNCHECKED
					    END SELECT

            CASE $IMPORT_FUNCTION_FILEDIALOG_PB :
              XstGetCurrentDirectory (@CURDIR$)
              fOptions$ = fOptions$ + "XBLite Code Files (*.x, *.xl, *.xbl)|*.x;*.xl;*.xbl"
              f$ = "*.x;*.xl;*.xbl"
              style = $$OFN_EXPLORER OR $$OFN_FILEMUSTEXIST OR $$OFN_HIDEREADONLY
              OpenFileDialog (hWndMain, "", @f$, CURDIR$, fOptions$, "x", style)
              IF f$ THEN
                importFileName$ = f$
                SetDlgItemTextA (hwndDlg, 505, &importFileName$)
              END IF

 						CASE $$IDCANCEL :
							EndDialog (hwndDlg, 0)

						CASE $$IDOK:
							importFuncName$ = NULL$ (255)
							GetDlgItemTextA (hwndDlg, 502, &importFuncName$, LEN (importFuncName$))
							importFuncName$ = TRIM$ (CSIZE$ (importFuncName$))
							importFileName$ = NULL$ (255)
							GetDlgItemTextA (hwndDlg, 505, &importFileName$, LEN (importFileName$))
							importFileName$ = TRIM$ (CSIZE$ (importFileName$))
							IF importFuncName$ <> "" && importFileName$ <> "" THEN
								EndDialog (hwndDlg, 1)
							ELSE
							  SED_MsgBox (hWnd, " Function or file name error!    ", $$MB_OK | $$MB_ICONEXCLAMATION, " Import Function")
								EndDialog (hwndDlg, 0)
							END IF
					END SELECT
			END SELECT

		CASE ELSE : RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)
END FUNCTION
'
' #############################################
' #####  CopyOutputConsoleToClipboard ()  #####
' #############################################
'
FUNCTION CopyOutputConsoleToClipboard ()

  SHARED hListBox
  UBYTE image[]

  $CRLF = "\r\n"

  count = SendMessageA (hListBox, $$LB_GETCOUNT, 0, 0)
  IF count <= 0 THEN RETURN

  FOR i = 0 TO count - 1
    text$ = NULL$ (1024)
    SendMessageA (hListBox, $$LB_GETTEXT, i, &text$)
    text$ = CSIZE$ (text$)
    clip$ = clip$ + text$ + $CRLF
  NEXT i

  IF clip$ THEN XstSetClipboard (1, @clip$, @image[])

END FUNCTION
'
' ##########################################
' #####  TrimTrailingTabsAndSpaces ()  #####
' ##########################################
'
' Trim all trailing spaces and tabs from end of each line.
'
FUNCTION TrimTrailingTabsAndSpaces (@text$)

  IFZ text$ THEN RETURN ($$TRUE)

'  XstStringToStringArray (@text$, @text$[])
'  upp = UBOUND (text$[])
'  text$ = ""
'  FOR i = 0 TO upp
'    text$ = text$ + RTRIM$ (text$[i]) + "\r\n"
'  NEXT i

	tmp$ = text$
	l = LEN(tmp$)
	out$ = NULL$ (l)

	upp = l-1
	index = upp

	FOR i = upp TO 0 STEP -1
		ch = tmp${i}
		SELECT CASE ch
			CASE '\t', ' ' : IF fTrim THEN DO NEXT
											 out${index} = ch : DEC index
			CASE '\n', '\r' : fTrim = $$TRUE  : out${index} = ch : DEC index
			CASE ELSE       : fTrim = $$FALSE : out${index} = ch : DEC index
		END SELECT
	NEXT i

	text$ = MID$ (out$, index+2)

END FUNCTION
'
' ###############################
' #####  SaveFileAsHtml ()  #####
' ###############################
'
' Save color syntax document as HTML
' Based on SaveToHTML() in exporters.cxx in scite.
'
FUNCTION SaveFileAsHtml ()

  SHARED hWndMain
  SHARED hWndClient
  SHARED IniFile$
  SHARED SciColorsAndFontsType scf
  UBYTE acc[]

	hSci = GetEdit ()
  IFZ hSci THEN RETURN ($$TRUE)

	szText$ = GetWindowText$ (MdiGetActive (hWndClient))
	XstGetPathComponents (szText$, @path$, @drive$, @dir$, @f$, @attributes)
  GetFileExtension (f$, @fn$, @szExt$)
  fn$ = fn$ + ".html"

	fOptions$ = fOptions$ + "HTML Files (*.html, *.htm)|*.html;*.htm| _
			All Files (*.*)|*.*"

	style = $$OFN_EXPLORER OR $$OFN_FILEMUSTEXIST OR $$OFN_HIDEREADONLY OR $$OFN_OVERWRITEPROMPT
	IFZ (SaveFileDialog (hWndMain, "Save File As HTML ", @fn$, path$, fOptions$, "html", style)) THEN RETURN

	' Get direct pointer for faster access
	pSci = SendMessageA (hSci, $$SCI_GETDIRECTPOINTER, 0, 0)
	IFZ pSci THEN RETURN ($$TRUE)

	' Colourise the doc
	Colourise (hSci, 0, -1)

	tabSize = XLONG (IniRead (IniFile$, "Editor options", "TabSize", ""))
	IF tabSize = 0 THEN tabSize = 4

' set some html properties, these can be altered
  wysiwyg = $$TRUE        ' enables users custom fonts and fontsize, replace tabs with spaces
  tabs = $$TRUE           ' use tab characters
  onlyStylesUsed = $$TRUE ' use styles set up by user

	lengthDoc = SendMessageA (hSci, $$SCI_GETLENGTH, 0, 0)

  DIM styleIsUsed[$$STYLE_MAX]

	IF (onlyStylesUsed) THEN
'	check the used styles
    FOR i = 0 TO lengthDoc-1
      style = SciMsg (pSci, $$SCI_GETSTYLEAT, i, 0)
			styleIsUsed[style & 0x7F] = $$TRUE
    NEXT i
  ELSE
    FOR i = 0 TO $$STYLE_MAX
      styleIsUsed[i] = $$TRUE
    NEXT i
  END IF
	styleIsUsed[$$STYLE_DEFAULT] = $$TRUE

  ' Open a file
  fn = OPEN (fn$, $$WRNEW)
  IF fn < 3 THEN
    msg$ = "Could not save file " + fn$ + ".    "
    MessageBoxA (hWnd, &msg$, &" SaveFileAsHtml", $$MB_OK | $$MB_ICONWARNING)
    RETURN ($$TRUE)
  END IF

  ' Write HTML to file
  a$ = "<!DOCTYPE html  PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"DTD/xhtml1-strict.dtd\">\n"
  WRITE [fn], a$
  a$ = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  WRITE [fn], a$
  a$ = "<head>\n"
  WRITE [fn], a$
  a$ = "<title>" + f$ +"</title>\n"
  WRITE [fn], a$
  a$ = "<meta name=\"GENERATOR\" content=\"XBLite - http://perso.wanadoo.fr/xblite/\" />\n"
  WRITE [fn], a$
  a$ = "<style type=\"text/css\">\n"
  WRITE [fn], a$

' create a series of styles
  FOR istyle = 0 TO $$STYLE_MAX
		IF ((istyle > $$STYLE_DEFAULT) && (istyle <= $$STYLE_LASTPREDEFINED)) THEN DO NEXT
		IF (styleIsUsed[istyle]) THEN

      font$    = "Courier New"
      fontSize = 10
      bold     = 0
      italic   = 0
      fc       = 0
      bc       = RGB(255,255,255)

      SELECT CASE istyle
        CASE $$SCE_B_DEFAULT, $$STYLE_DEFAULT :
          font$     = scf.DefaultFontName
          fontSize  = scf.DefaultFontSize
          bold      = scf.DefaultFontBold
          italic    = scf.DefaultFontItalic
          fc        = scf.DefaultForeColor
          bc        = scf.DefaultBackColor
        CASE $$SCE_B_COMMENT, $$SCE_ASM_COMMENT :
          font$     = scf.CommentFontName
          fontSize  = scf.CommentFontSize
          bold      = scf.CommentFontBold
          italic    = scf.CommentFontItalic
          fc        = scf.CommentForeColor
          bc        = scf.CommentBackColor
        CASE $$SCE_B_NUMBER, $$SCE_ASM_NUMBER  :
          font$     = scf.NumberFontName
          fontSize  = scf.NumberFontSize
          bold      = scf.NumberFontBold
          italic    = scf.NumberFontItalic
          fc        = scf.NumberForeColor
          bc        = scf.NumberBackColor
        CASE $$SCE_B_KEYWORD, $$SCE_ASM_CPUINSTRUCTION  :
          font$     = scf.KeywordFontName
          fontSize  = scf.KeywordFontSize
          bold      = scf.KeywordFontBold
          italic    = scf.KeywordFontItalic
          fc        = scf.KeywordForeColor
          bc        = scf.KeywordBackColor
        CASE $$SCE_B_STRING, $$SCE_B_CHAR, $$SCE_ASM_STRING, $$SCE_ASM_CHARACTER:
          font$     = scf.StringFontName
          fontSize  = scf.StringFontSize
          bold      = scf.StringFontBold
          italic    = scf.StringFontItalic
          fc        = scf.StringForeColor
          bc        = scf.StringBackColor
        CASE $$SCE_B_OPERATOR, $$SCE_ASM_OPERATOR   :
          font$     = scf.OperatorFontName
          fontSize  = scf.OperatorFontSize
          bold      = scf.OperatorFontBold
          italic    = scf.OperatorFontItalic
          fc        = scf.OperatorForeColor
          bc        = scf.OperatorBackColor
        CASE $$SCE_B_IDENTIFIER, $$SCE_ASM_IDENTIFIER:
          font$     = scf.IdentifierFontName
          fontSize  = scf.IdentifierFontSize
          bold      = scf.IdentifierFontBold
          italic    = scf.IdentifierFontItalic
          fc        = scf.IdentifierForeColor
          bc        = scf.IdentifierBackColor
        CASE $$SCE_B_CONSTANT  :
          font$     = scf.ConstantFontName
          fontSize  = scf.ConstantFontSize
          bold      = scf.ConstantFontBold
          italic    = scf.ConstantFontItalic
          fc        = scf.ConstantForeColor
          bc        = scf.ConstantBackColor
        CASE $$SCE_B_ASM        :
          font$     = scf.ASMFontName
          fontSize  = scf.ASMFontSize
          bold      = scf.ASMFontBold
          italic    = scf.ASMFontItalic
          fc        = scf.ASMForeColor
          bc        = scf.ASMBackColor
        CASE $$SCE_ASM_MATHINSTRUCTION        :
          font$     = scf.AsmFpuInstructionFontName
          fontSize  = scf.AsmFpuInstructionFontSize
          bold      = scf.AsmFpuInstructionFontBold
          italic    = scf.AsmFpuInstructionFontItalic
          fc        = scf.AsmFpuInstructionForeColor
          bc        = scf.AsmFpuInstructionBackColor
        CASE $$SCE_ASM_REGISTER      :
          font$     = scf.AsmRegisterFontName
          fontSize  = scf.AsmRegisterFontSize
          bold      = scf.AsmRegisterFontBold
          italic    = scf.AsmRegisterFontItalic
          fc        = scf.AsmRegisterForeColor
          bc        = scf.AsmRegisterBackColor
        CASE $$SCE_ASM_DIRECTIVE      :
          font$     = scf.AsmDirectiveFontName
          fontSize  = scf.AsmDirectiveFontSize
          bold      = scf.AsmDirectiveFontBold
          italic    = scf.AsmDirectiveFontItalic
          fc        = scf.AsmDirectiveForeColor
          bc        = scf.AsmDirectiveBackColor
        CASE $$SCE_ASM_DIRECTIVEOPERAND     :
          font$     = scf.AsmDirectiveOperandFontName
          fontSize  = scf.AsmDirectiveOperandFontSize
          bold      = scf.AsmDirectiveOperandFontBold
          italic    = scf.AsmDirectiveOperandFontItalic
          fc        = scf.AsmDirectiveOperandForeColor
          bc        = scf.AsmDirectiveOperandBackColor
        CASE $$SCE_ASM_EXTINSTRUCTION     :
          font$     = scf.AsmExtendedInstructionFontName
          fontSize  = scf.AsmExtendedInstructionFontSize
          bold      = scf.AsmExtendedInstructionFontBold
          italic    = scf.AsmExtendedInstructionFontItalic
          fc        = scf.AsmExtendedInstructionForeColor
          bc        = scf.AsmExtendedInstructionBackColor
				CASE ELSE :
          font$     = "Courrier New"
          fontSize  = 8
          bold      = 0
          italic    = 0
          fc        = $$Black
          bc        = $$White
      END SELECT

			IF istyle == $$STYLE_DEFAULT THEN
        a$ = "span {\n"
        WRITE [fn], a$
      ELSE
        a$ = ".S" + STRING$(istyle) + " {\n"
        WRITE [fn], a$
      END IF

      IF italic THEN
        a$ = "\tfont-style: italic;\n"
        WRITE [fn], a$
      END IF

      IF bold THEN
        a$ = "\tfont-weight: bold;\n"
        WRITE [fn], a$
      END IF

      IF wysiwyg THEN
        a$ = "\tfont-family: '" + font$ + "';\n"
        WRITE [fn], a$
        a$ = "\tfont-size: " + STRING$(fontSize) + "pt;\n"
        WRITE [fn], a$
      END IF

      fc$ = RGBToHTMLHEX$ (fc)
      a$ = "\tcolor: " + fc$ + ";\n"
      WRITE [fn], a$

      bc$ = RGBToHTMLHEX$ (bc)
      a$ = "\tbackground: " + bc$ + ";\n"
      WRITE [fn], a$

      a$ = "}\n"
      WRITE [fn], a$

    END IF
  NEXT istyle

  a$ = "</style>\n"
  WRITE [fn], a$

  a$ ="</head>\n"
  WRITE [fn], a$

	bc$ = RGBToHTMLHEX$ (scf.DefaultBackColor)
	a$ = "<body bgcolor=\"" + bc$ + "\">\n"
  WRITE [fn], a$

  styleCurrent = SciMsg (pSci, $$SCI_GETSTYLEAT, 0, 0)
  inStyleSpan = $$FALSE

'		Global span for default attributes
	IF (wysiwyg) THEN
    a$ = "<span>"
    WRITE [fn], a$
  ELSE
    a$ = "<pre>"
    WRITE [fn], a$
  END IF

	IF (styleIsUsed[styleCurrent]) THEN
    a$ = "<span class=\"S" + STRING$(styleCurrent) + "\">"
    WRITE [fn], a$
		inStyleSpan = $$TRUE
  END IF

'	Else, this style has no definition (beside default one):
'	no span for it, except the global one

' Get all bytes in doc into array acc[]
  DIM acc[lengthDoc-1]
  FOR i = 0 TO lengthDoc-1
    acc[i] = SciMsg (pSci, $$SCI_GETCHARAT, i, 0)
  NEXT i

  ' Go thru all chars in doc, using span class= on every style change
  column = 0
	FOR i = 0 TO lengthDoc - 1
    ch = acc[i]
    style = SciMsg (pSci, $$SCI_GETSTYLEAT, i, 0)

		IF (style != styleCurrent) THEN
			IF (inStyleSpan) THEN
        a$ = "</span>"
        WRITE [fn], a$
				inStyleSpan = $$FALSE
      END IF
			IF (ch != '\r' && ch != '\n') THEN  ' No need of a span for the EOL
        IF (styleIsUsed[style]) THEN
          a$ = "<span class=\"S" + STRING$(style) + "\">"
          WRITE [fn], a$
					inStyleSpan = $$TRUE
        END IF
				styleCurrent = style
      END IF
    END IF

    IF (ch == ' ') THEN
			IF (wysiwyg) THEN
				prevCh = '\0'
				IF (column == 0) THEN	' At start of line, must put a &nbsp; because regular space will be collapsed
					prevCh = ' '
        END IF
				DO WHILE (i < lengthDoc && acc[i] == ' ')
					IF (prevCh != ' ') THEN
					  a$ = " "
					  WRITE [fn], a$
          ELSE
					  a$ = "&nbsp;"
					  WRITE [fn], a$
          END IF
					prevCh = acc[i]
					INC i
					INC column
        LOOP
				DEC i  ' the last incrementation will be done by the for loop
      ELSE
				a$ = " " : WRITE [fn], a$
				INC column
      END IF

		ELSE
      IF (ch == '\t') THEN
				ts = tabSize - (column MOD tabSize)
				IF (wysiwyg) THEN
					FOR itab = 0 TO ts - 1
						IF (itab MOD 2) THEN
						  a$ = " " : WRITE [fn], a$
            ELSE
							a$ = "&nbsp;" : WRITE [fn], a$
            END IF
          NEXT itab
					column = column + ts
        ELSE
					IF (tabs) THEN
						a$ = CHR$(ch) : WRITE [fn], a$
						INC column
          ELSE
						FOR itab = 0 TO ts - 1
							a$ = " " : WRITE [fn], a$
            NEXT itab
						column = column + ts
          END IF
        END IF
      ELSE
        IF (ch == '\r' || ch == '\n') THEN
				  IF (inStyleSpan) THEN
					  a$ = "</span>" : WRITE [fn], a$
					  inStyleSpan = $$FALSE
          END IF
          ' CR+LF line ending, skip the "extra" EOL char
				  IF (ch == '\r' && acc[i + 1] == '\n') THEN INC i

				  column = 0
				  IF wysiwyg THEN
					  a$ = "<br/>" : WRITE [fn], a$
          END IF

				  styleCurrent = SciMsg (pSci, $$SCI_GETSTYLEAT, i+1, 0)
					a$ = CHR$('\n') : WRITE [fn], a$

				  IF ((styleIsUsed[styleCurrent]) && (acc[i + 1] != '\r') && (acc[i + 1] != '\n')) THEN
					  ' We know it's the correct next style,
					  ' but no (empty) span for an empty line
					  a$ = "<span class=\"S" + STRING$(styleCurrent) + "\">"
					  WRITE [fn], a$
					  inStyleSpan = $$TRUE
				  END IF

        ELSE
          SELECT CASE (ch)
				    CASE '<': a$ = "&lt;"  : WRITE [fn], a$
				    CASE '>': a$ = "&gt;"  : WRITE [fn], a$
				    CASE '&': a$ = "&amp;" : WRITE [fn], a$
				    CASE ELSE : a$ = CHR$(ch) : WRITE [fn], a$
          END SELECT
          INC column
        END IF
      END IF
    END IF

  NEXT i

	IF (inStyleSpan) THEN
    a$ = "</span>"
    WRITE [fn], a$
  END IF

  IF (!wysiwyg) THEN
    a$ = "</pre>"
    WRITE [fn], a$
  ELSE
    a$ ="</span>"
    WRITE [fn], a$
  END IF

  a$ = "\n</body>\n</html>\n"
  WRITE [fn], a$
  CLOSE (fn)

END FUNCTION
'
' ##############################
' #####  RGBToHTMLHEX$ ()  #####
' ##############################
'
' Convert a RGB value into a HTML compatible hex string.
' EX: RGB(100,200,255) == FFC864  is translated to #64C8FF
'
FUNCTION RGBToHTMLHEX$ (rgb)

	r = rgb{8, 0}
	g = rgb{8, 8}
	b = rgb{8, 16}
	s$ = "#" + HEX$(r, 2) + HEX$(g, 2) + HEX$(b, 2)
	RETURN s$

END FUNCTION
'
' ################################
' #####  CloseAllWindows ()  #####
' ################################
'
' Close all open MDI child windows
'
FUNCTION CloseAllWindows ()

	SHARED hWndClient

	hWndFirst = MdiGetActive (hWndClient)
	hWndActive = hWndFirst
	hWndPrev = 0
	DO WHILE hWndActive
		IF SendMessageA (MdiGetActive (hWndClient), $$WM_CLOSE, 0, 0) THEN EXIT DO
		IF fClosed THEN
			IF hWndFirst = hWndActive THEN
				IF hWndFirst = hWndPrev THEN
					hWndFirst = 0
					hWndPrev = 0
				ELSE
					hWndFirst = hWndPrev
				END IF
			END IF
		ELSE
			IF hWndPrev = 0 THEN
				hWndPrev = hWndActive
			END IF
			IF hWndFirst = 0 THEN
				hWndFirst = hWndActive
			END IF
		END IF
		MdiNext (hWndClient, hWndActive, 0)
		hWndActive = MdiGetActive (hWndClient)
	LOOP UNTIL hWndActive = hWndFirst
END FUNCTION
'
' ########################
' #####  GetHelp ()  #####
' ########################
'
' Retrieve the word under the caret and activate the compiler's help file
' if it is a XBLite keyword or the Windows 32 help file if it is not.
'
FUNCTION GetHelp (hWnd)

	SHARED keywords$		' xblite keywords list
	SHARED IniFile$
	TEXTRANGE txtrg
	STATIC fWin32Hlp

	x = 0 : y = 0
	' Retrieve the current position
	curPos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
	' Retrieve the starting position of the word
	x = SendMessageA (GetEdit (), $$SCI_WORDSTARTPOSITION, curPos, $$TRUE)
	' Retrieve the ending position of the word
	y = SendMessageA (GetEdit (), $$SCI_WORDENDPOSITION, curPos, $$TRUE)
	IF y > x THEN
		' Prepare the buffer
		buffer$ = NULL$ (y - x + 1)
		' Read also the characters before and after the word
		IF x > 0 THEN x = x - 1 : buffer$ = buffer$ + NULL$ (1)
		y = y + 1 : buffer$ = buffer$ + NULL$ (1)
		' Text range
		txtrg.chrg.cpMin = x
		txtrg.chrg.cpMax = y
		txtrg.lpstrText = &buffer$
		SendMessageA (GetEdit (), $$SCI_GETTEXTRANGE, 0, &txtrg)
		buffer$ = CSIZE$ (buffer$)
		buffer$ = TRIM$ (buffer$)
		IF buffer$ THEN
			IF INSTR (keywords$, buffer$) THEN
				p$ = IniRead (IniFile$, "Tools options", "XBLHelp", "")
				' call the xblite html help file
				IF p$ THEN
					HtmlHelp (0, p$, $$HH_DISPLAY_INDEX, &buffer$)
				END IF
			ELSE
				' Get the path of the file
				szPath$ = GetWindowText$ (MdiGetActive (hWndClient))
				IF INSTR (UCASE$ (szPath$), ".RC") THEN		' It is a resource file
					p$ = IniRead (IniFile$, "Tools options", "RCHelp", "")
					IF p$ THEN WinHelpA (hWnd, &p$, $$HELP_KEY, &buffer$)
				ELSE
					' open win32.hlp file if it exists
					IFZ fWin32Hlp THEN
						path$ = IniRead (IniFile$, "Tools options", "Win32Help", "")
						IFZ path$ THEN
							ret = SED_MsgBox (hWnd, "Win32 Programmers Reference Help not found.   \r\nDo you want to locate it?   ", $$MB_YESNO, " Win32Help")
						END IF
						' do this once
						IF ret = $$IDNO THEN fWin32Hlp = $$TRUE

						IF ret = $$IDYES THEN
							' find win32.hlp file
							XstGetCurrentDirectory (@CURDIR$)
							fOptions$ = fOptions$ + "Help files (*.hlp)|*.hlp| _
									All Files (*.*)|*.*"

							path$ = "win32.hlp"
							style = $$OFN_EXPLORER OR $$OFN_FILEMUSTEXIST OR $$OFN_HIDEREADONLY
							IF OpenFileDialog (hWnd, "", @path$, CURDIR$, fOptions$, "hlp", style) THEN
								IF INSTRI (path$, "win32.hlp") THEN
									IniWrite (IniFile$, "Tools options", "Win32Help", path$)
								END IF
							END IF
						END IF
						p$ = IniRead (IniFile$, "Tools options", "Win32Help", "")
						IF p$ THEN WinHelpA (hWnd, &p$, $$HELP_KEY, &buffer$)
					END IF
				END IF
			END IF
		END IF
	ELSE
		' call xblite html help file
		szPath$ = IniRead (IniFile$, "Tools options", "XBLHelp", "")
		IF szPath$ THEN ShellExecuteA (hWnd, &"open", &szPath$, NULL, NULL, $$SW_SHOWNORMAL)
	END IF
END FUNCTION
'
' ########################
' #####  OnClose ()  #####
' ########################
'
' Close the active MDI window
'
FUNCTION OnClose ()

	SHARED hWndClient

	' Save paths of loaded files
	SED_SaveLoadedFilesPaths ()

	' Close the MDI child window
	hWndFirst = MdiGetActive (hWndClient)
	hWndActive = hWndFirst
	hWndPrev = 0

	DO WHILE hWndActive
		IF SendMessageA (MdiGetActive (hWndClient), $$WM_CLOSE, 0, 0) THEN EXIT DO
		IF fClosed THEN
			IF hWndFirst = hWndActive THEN
				IF hWndFirst = hWndPrev THEN
					hWndFirst = 0
					hWndPrev = 0
				ELSE
					hWndFirst = hWndPrev
				END IF
			END IF
		ELSE
			IFZ hWndPrev THEN hWndPrev = hWndActive
			IFZ hWndFirst THEN hWndFirst = hWndActive
		END IF
		MdiNext (hWndClient, hWndActive, 0)
		hWndActive = MdiGetActive (hWndClient)
	LOOP UNTIL hWndActive = hWndFirst
	IF hWndActive THEN RETURN
END FUNCTION
'
' #############################
' #####  ClearConsole ()  #####
' #############################
'
FUNCTION ClearConsole ()
  SHARED hListBox
  SendMessageA (hListBox, $$LB_RESETCONTENT, 0, 0)
END FUNCTION
'
' ############################
' #####  HideConsole ()  #####
' ############################
'
FUNCTION HideConsole ()
	SHARED hSplitter
	SendMessageA (hSplitter, $$WM_DOCK_SPLITTER, 0, 0)
END FUNCTION

'
' #############################
' #####  NewDialogBox ()  #####
' #############################
'
FUNCTION  NewDialogBox (hWndParent, x, y, width, height, dlgProcAddr, initParam)

	SHARED hInst
	TDLGDATA tdd				' user defined in this program
	DLGTEMPLATE dltt

' fill in DLGTEMPLATE struct
	dltt.style 	= $$DS_MODALFRAME | $$DS_3DLOOK | $$WS_POPUP | $$WS_CAPTION | $$WS_SYSMENU | $$WS_VISIBLE | $$DS_ABSALIGN  | $$DS_SETFONT
	dltt.dwExtendedStyle 	= 0
	dltt.cdit 						= 0					' number of control items in dialog box, this creates an empty dialog box

	bu = GetDialogBaseUnits ()				' get dialog base units
	screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	screenHeight = GetSystemMetrics ($$SM_CYSCREEN)

	dialogUnitX = (x*4)/LOWORD(bu)
	dialogUnitY = (y*8)/HIWORD(bu)

	dltt.x = dialogUnitX
	dltt.y = dialogUnitY

	dialogUnitWidth = (width*4)/LOWORD(bu)		' convert width in pixels to dialog units
	dialogUnitHeight = (height*8)/HIWORD(bu)	' convert height in pixels to dialog units

	dltt.cx = dialogUnitWidth
	dltt.cy = dialogUnitHeight

' fill in TDLGDATA struct
	tdd.dltt 	= dltt
	tdd.menu 	= 0
	tdd.class = 0
	tdd.title = 0

' create dialog box
	RETURN DialogBoxIndirectParamA (hInst, &tdd, hWndParent, dlgProcAddr, initParam)

END FUNCTION
'
'
' ###########################
' #####  CharMapProc ()  ####
' ###########################
'
FUNCTION  CharMapProc (hwndDlg, msg, wParam, lParam)

	POINT pt
	CHARMAPINFO cmi
	STATIC hFont, hFontPop
	RECT rc, rd
	STATIC x0, y0, s, b
	SHARED selection
	STATIC lastSelection, hStatus
	SHARED hKeyHook, hWndDialog
	SHARED hImlHot

	$OFFSET = 1024
	$POPOFFSET = 1280
	$STATUSBAR = 2000

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			RtlMoveMemory (&cmi, lParam, SIZE(cmi))
			IF cmi.fontsize < 8 THEN cmi.fontsize = 8
'			SetWindowPos (hwndDlg, 0, 0, 0, 310, 328, $$SWP_NOZORDER | $$SWP_NOMOVE)
			width = 340
			height = 380
			SetWindowPos (hwndDlg, 0, 0, 0, width, height, $$SWP_NOZORDER | $$SWP_NOMOVE)
			hFont = NewFont (cmi.font, cmi.fontsize, $$FW_NORMAL, 0, 0)
			hFontPop = NewFont (cmi.font, cmi.zoomfontsize, $$FW_NORMAL, 0, 0)

			index = 0			' character index (0 - 255)
			id = $OFFSET	' control id start
			s = 19				' grid size
			b = 1					' gap size
			x0 = 8
			y0 = 8

			FOR i = 0 TO 15
				y = i * (s + b) + y0
				FOR j = 0 TO 15
					x = j * (s + b) + x0
					hStatic = NewChild ("static", CHR$(index), $$SS_CENTER | $$WS_VISIBLE, x, y, s, s, hwndDlg, id, 0)
					IF hFont THEN SetNewFont (hStatic, hFont)
					INC index
					INC id
				NEXT j
			NEXT i

			spop = 72			' popup size
			index = 0
			idpop = $POPOFFSET
			FOR i = 0 TO 15
				y = i * (s + b) + y0
				FOR j = 0 TO 15
					x = j * (s + b) + x0
					hPopStatic = NewChild ("static", CHR$(index), $$SS_CENTER | $$SS_CENTERIMAGE, x+20, y+20, spop, spop, hwndDlg, idpop, $$WS_EX_CLIENTEDGE)
					IF hFontPop THEN SetNewFont (hPopStatic, hFontPop)
					ShowWindow (hPopStatic, $$SW_HIDE)
					INC index
					INC idpop
				NEXT j
			NEXT i

			' draw some border lines using static controls
			DrawLineStatic (hwndDlg, x0-1, y0-1, x0-1, 16 * (s + b) + y0 - 1, $$Grey)
			DrawLineStatic (hwndDlg, x0-1, y0-1, 16 * (s + b) + x0 - 1, y0-1, $$Grey)
			DrawLineStatic (hwndDlg, 16 * (s + b) + x0 - 1, y0-1, 16 * (s + b) + x0 - 1, 16 * (s + b) + y0 - 1, $$Grey)
			DrawLineStatic (hwndDlg, x0, 16 * (s + b) + y0 - 1, 16 * (s + b) + x0 - 2, 16 * (s + b) + y0 - 1, $$Grey)

			DrawLineStatic (hwndDlg, 16 * (s + b) + x0, y0-1, 16 * (s + b) + x0, 16 * (s + b) + y0, $$White)
			DrawLineStatic (hwndDlg, x0-1, 16 * (s + b) + y0, 16 * (s + b) + x0 - 1, 16 * (s + b) + y0, $$White)

			' create a status bar
			text$ = " " + cmi.font
			hStatus = CreateStatusWindowA ($$WS_VISIBLE | $$WS_CHILD, &text$, hwndDlg, $STATUSBAR)
			DIM widths[2]
			widths[0] = 160
			widths[1] = 240
			widths[2] = -1
			SendMessageA (hStatus, $$SB_SETPARTS, 3, &widths[])

			' set text in title bar
			text$ = " ANSI Character Map for "
			IF cmi.font THEN text$ = text$ + cmi.font
			SetWindowTextA (hwndDlg, &text$)

			' set icon in title bar
			hIconApp = ImageList_GetIcon (hImlHot, 117, $$ILD_TRANSPARENT)
			SendMessageA (hwndDlg, $$WM_SETICON, $$ICON_SMALL, hIconApp)
			SendMessageA (hwndDlg, $$WM_SETICON, $$ICON_BIG, hIconApp)

			selection = $OFFSET + 65   ' set selected character
			lastSelection = 0
			hWndDialog = hwndDlg

			' install a keyboard hook
			threadId = GetCurrentThreadId()
			hKeyHook = SetWindowsHookExA ($$WH_KEYBOARD, &KBHookProc(), GetModuleHandleA (0), threadId)

			'	redraw window
			InvalidateRect (hwndDlg, NULL, 0)

			RETURN

		CASE $$WM_RBUTTONDOWN :
      pt.x = LOWORD(lParam)
      pt.y = HIWORD(lParam)
      ClientToScreen (hwndDlg, &pt)
      hWndPoint = WindowFromPoint (pt.x, pt.y)
      IFZ hWndPoint THEN RETURN
      ScreenToClient (hWndPoint, &pt)
      hWndChild = ChildWindowFromPoint (hWndPoint, pt.x, pt.y)
			id = GetDlgCtrlID (hWndChild)
			hPop = GetDlgItem (hwndDlg, id+256)
			GetClientRect (hPop, &rc)
			GetClientRect (hwndDlg, &rd)
			x = pt.x
			IF x + rc.right + 4 > rd.right THEN
				x = rd.right - rc.right - 12
			END IF
			y = pt.y - rc.bottom - 4
			IF y < 10 THEN y = 10
			SetWindowPos (hPop, 0, x, y, 0, 0, $$SWP_NOZORDER | $$SWP_NOSIZE)
			ShowWindow (hPop, $$SW_SHOW)

			lastSelection = selection
			selection = id
			InvalidateRect (hWndChild, NULL, 1)					' set char selection color
			hLastSelection = GetDlgItem (hwndDlg, lastSelection)
			InvalidateRect (hLastSelection, NULL, 1)		' set last selection back to white
			RETURN

		CASE $$WM_RBUTTONUP :
			FOR id = $POPOFFSET TO $POPOFFSET + 256
				hPop = GetDlgItem (hwndDlg, id)
				ShowWindow (hPop, $$SW_HIDE)
			NEXT id
			RETURN

		CASE $$WM_LBUTTONDBLCLK :
      pt.x = LOWORD(lParam)
      pt.y = HIWORD(lParam)
      ClientToScreen (hwndDlg, &pt)
      hWndPoint = WindowFromPoint (pt.x, pt.y)
      IFZ hWndPoint THEN RETURN
      ScreenToClient (hWndPoint, &pt)
      hWndChild = ChildWindowFromPoint (hWndPoint, pt.x, pt.y)
			id = GetDlgCtrlID (hWndChild)
			text$ = CHR$(id-$OFFSET)
			pos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
			SendMessageA (GetEdit (), $$SCI_INSERTTEXT, pos, &text$)
			SendMessageA (GetEdit (), $$SCI_SETCURRENTPOS, pos+1, 0)
			RETURN

		CASE $$WM_LBUTTONDOWN:
      pt.x = LOWORD(lParam)
      pt.y = HIWORD(lParam)
      ClientToScreen (hwndDlg, &pt)
      hWndPoint = WindowFromPoint (pt.x, pt.y)
      IFZ hWndPoint THEN RETURN
      ScreenToClient (hWndPoint, &pt)
      hWndChild = ChildWindowFromPoint (hWndPoint, pt.x, pt.y)
			id = GetDlgCtrlID (hWndChild)
			lastSelection = selection
			selection = id
			InvalidateRect (hWndChild, NULL, 1)					' set char selection color
			hLastSelection = GetDlgItem (hwndDlg, lastSelection)
			InvalidateRect (hLastSelection, NULL, 1)		' set last selection back to white
			RETURN

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE TRUE :
						CASE id = $$IDCANCEL :									' window close button pressed
							DeleteObject (hFont)
							DeleteObject (hFontPop)
							UnhookWindowsHookEx (hKeyHook)
							EndDialog (hwndDlg, ID)
					END SELECT
			END SELECT

		CASE $$WM_CTLCOLORSTATIC :
'			hdcStatic = wParam
'			hStatic = lParam

			ID = GetDlgCtrlID (lParam)

			' set statusbar text
			IF ID = selection THEN
				chr = ID - $OFFSET
				c$ = STRING$(chr)
				SELECT CASE LEN(c$)
					CASE 1 : alt$ = " Alt + 000" + c$
					CASE 2 : alt$ = " Alt + 00"  + c$
					CASE 3 : alt$ = " Alt + 0"   + c$
				END SELECT
				SendMessageA (hStatus, $$SB_SETTEXT, 1, &alt$)
				ch$ = " Char: " + CHR$(chr)
				SendMessageA (hStatus, $$SB_SETTEXT, 2, &ch$)
			END IF

			' set color of controls
			IF ID = selection THEN
				RETURN SetColor (RGB(255, 255, 255), RGB(0, 0, 160), wParam, lParam)	' white text, blue background
			ELSE
				RETURN SetColor (RGB(0, 0, 0), RGB(255, 255, 255), wParam, lParam)  	' black text, white background
			END IF

		CASE ELSE :	RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  FRHookProc ()  #####
' ###########################
'
' Find/Replace dialog box hook function
' This is used to fill the dialog comboboxes with
' previously entered search strings.
FUNCTION FRHookProc (hDlg, msg, wParam, lParam)

	SHARED find$[]
	SHARED replace$[]

	SHARED fromCursorState, fromTopState
	STATIC upState, downState
	STATIC matchWordState, matchCaseState
	SHARED fDlgState

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			#hComboboxFind = GetDlgItem (hDlg, 0x0480)
			' fill up combobox with find$[] array
			IF #hComboboxFind THEN
				upper = UBOUND(find$[])
				FOR i = 0 TO upper
					ret = SendMessageA (#hComboboxFind, $$CB_ADDSTRING, 0, &find$[i])
				NEXT i
			END IF

			#hComboboxReplace = GetDlgItem (hDlg, 0x0481)
			IF #hComboboxReplace THEN
				upper = UBOUND(replace$[])
				FOR i = 0 TO upper
					ret = SendMessageA (#hComboboxReplace, $$CB_ADDSTRING, 0, &replace$[i])
				NEXT i
			END IF

			IF fromCursorState = fromTopState THEN
				fromCursorState = $$BST_CHECKED
				fromTopState = $$BST_UNCHECKED
			END IF

			IF upState = downState THEN
				downState = $$BST_CHECKED
				upState = $$BST_UNCHECKED
			END IF

			' set previous state
			SendMessageA (GetDlgItem (hDlg, 0x0403), $$BM_SETCHECK, fromCursorState, 0)
			SendMessageA (GetDlgItem (hDlg, 0x0404), $$BM_SETCHECK, fromTopState, 0)
			SendMessageA (GetDlgItem (hDlg, 0x0420), $$BM_SETCHECK, upState, 0)
			SendMessageA (GetDlgItem (hDlg, 0x0421), $$BM_SETCHECK, downState, 0)
			SendMessageA (GetDlgItem (hDlg, 0x0410), $$BM_SETCHECK, matchWordState, 0)
			SendMessageA (GetDlgItem (hDlg, 0x0411), $$BM_SETCHECK, matchCaseState, 0)

			ShowWindow (hDlg, $$SW_SHOW)
			UpdateWindow (hDlg)

		CASE $$WM_COMMAND:
			ID = LOWORD (wParam)
'			PRINT "FRHookProc: WM_COMMAND: ID="; HEXX$(ID)

			SELECT CASE ID
				CASE 0x403, 0x404:
					fromCursorState = SendMessageA (GetDlgItem (hDlg, 0x0403), $$BM_GETCHECK, 0, 0)
					fromTopState    = SendMessageA (GetDlgItem (hDlg, 0x0404), $$BM_GETCHECK, 0, 0)
					fDlgState = 0
				CASE 0x420, 0x421:
					upState         = SendMessageA (GetDlgItem (hDlg, 0x0420), $$BM_GETCHECK, 0, 0)
					downState       = SendMessageA (GetDlgItem (hDlg, 0x0421), $$BM_GETCHECK, 0, 0)
				CASE 0x410:
					matchWordState  = SendMessageA (GetDlgItem (hDlg, 0x0410), $$BM_GETCHECK, 0, 0)
				CASE 0x411:
					matchCaseState  = SendMessageA (GetDlgItem (hDlg, 0x0411), $$BM_GETCHECK, 0, 0)
			END SELECT
			RETURN

		CASE ELSE : RETURN

	END SELECT

END FUNCTION
'
' #######################################
' #####  ShowPrintingOptionsDialog  #####
' #######################################
'
' Display printing options dialog box
'
FUNCTION ShowPrintingOptionsDialog (hWnd)

	SHARED hInst

	hDlg = CreateDialogParamA (hInst, 600, hWnd, &PrintingOptionsProc(), 0)

END FUNCTION
'
' #################################
' #####  PrintingOptionsProc  #####
' #################################
'
'
'
FUNCTION PrintingOptionsProc (hWnd, msg, wParam, lParam)

	SHARED fPrintingColorMode
	SHARED fPrintingMagnification
	SHARED hWndMain
	RECT rc, rcd
	POINT pt

	$MAGMAX = 6

	SELECT CASE msg

		CASE $$WM_INITDIALOG:
			' center dialog on window
			GetClientRect (hWndMain, &rc)
			GetClientRect (hWnd, &rcd)
			pt.x = ((rc.right-rc.left)/2) - ((rcd.right-rcd.left)/2)
			pt.y = ((rc.bottom-rc.top)/2) - ((rcd.bottom-rcd.top)/2)
			ClientToScreen (hWndMain, &pt)
			SetWindowPos (hWnd, 0, pt.x, pt.y, 0, 0, $$SWP_NOSIZE	| $$SWP_NOZORDER)

			GetPrintingOptions ()

			SELECT CASE fPrintingColorMode
				CASE $$SC_PRINT_NORMAL 					: CheckDlgButton (hWnd, $$IDR_PRINTINGNORMAL, $$BST_CHECKED)
				CASE $$SC_PRINT_INVERTLIGHT 		: CheckDlgButton (hWnd, $$IDR_PRINTINGLIGHT, $$BST_CHECKED)
				CASE $$SC_PRINT_BLACKONWHITE  	: CheckDlgButton (hWnd, $$IDR_PRINTINGBW, $$BST_CHECKED)
				CASE $$SC_PRINT_COLOURONWHITE  	: CheckDlgButton (hWnd, $$IDR_PRINTINGCOLORW, $$BST_CHECKED)
			END SELECT

			hCombo = GetDlgItem (hWnd, $$IDCO_PRINTINGMAGVALUE)
			FOR i = $MAGMAX TO -$MAGMAX STEP -1
				s$ = STRING$(i)
				SendMessageA (hCombo, $$CB_INSERTSTRING, 0, &s$)
			NEXT i
			SendMessageA (hCombo, $$CB_SETCURSEL, fPrintingMagnification+$MAGMAX, 0)
			RETURN ($$TRUE)

		CASE $$WM_CTLCOLORDLG :
			RETURN SetColor (RGB(0, 0, 0), GetSysColor($$COLOR_BTNFACE), wParam, lParam)

		CASE $$WM_CTLCOLORBTN :
			RETURN SetColor (RGB(0, 0, 0), GetSysColor($$COLOR_BTNFACE), wParam, lParam)

		CASE $$WM_CTLCOLORSTATIC :
			RETURN SetColor (RGB(0, 0, 0), GetSysColor($$COLOR_BTNFACE), wParam, lParam)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			ID         = LOWORD(wParam)
			hwndCtl    = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID :

						CASE $$IDCANCEL :
							EndDialog (hWnd, ID)

						CASE $$IDOK :
							SELECT CASE ALL TRUE
								CASE IsDlgButtonChecked (hWnd, $$IDR_PRINTINGNORMAL) = $$BST_CHECKED : fPrintingColorMode = $$SC_PRINT_NORMAL
								CASE IsDlgButtonChecked (hWnd, $$IDR_PRINTINGLIGHT)  = $$BST_CHECKED : fPrintingColorMode = $$SC_PRINT_INVERTLIGHT
								CASE IsDlgButtonChecked (hWnd, $$IDR_PRINTINGBW)     = $$BST_CHECKED : fPrintingColorMode = $$SC_PRINT_BLACKONWHITE
								CASE IsDlgButtonChecked (hWnd, $$IDR_PRINTINGCOLORW) = $$BST_CHECKED : fPrintingColorMode = $$SC_PRINT_COLOURONWHITE
							END SELECT

							index = SendMessageA (GetDlgItem (hWnd, $$IDCO_PRINTINGMAGVALUE), $$CB_GETCURSEL, 0, 0)
							s$ = NULL$(20)
							SendMessageA (GetDlgItem (hWnd, $$IDCO_PRINTINGMAGVALUE), $$CB_GETLBTEXT, index, &s$)
							s$ = CSIZE$ (s$)
							fPrintingMagnification = XLONG(s$)
							WritePrintingOptions ()
							EndDialog (hWnd, ID)
					END SELECT

			END SELECT
	END SELECT

END FUNCTION

'
' ###################################
' #####  GetPrintingOptions ()  #####
' ###################################
'
' Reads the Printing options from the .INI file
'
FUNCTION GetPrintingOptions ()

	SHARED IniFile$
	SHARED fPrintingColorMode
	SHARED fPrintingMagnification

	rs$ = IniRead (IniFile$, "Printing options", "ColorMode", "")
	IF rs$ THEN fPrintingColorMode = XLONG (rs$) ELSE fPrintingColorMode = 2

	rs$ = IniRead (IniFile$, "Printing options", "Magnification", "")
	IF rs$ THEN fPrintingMagnification = XLONG (rs$) ELSE fPrintingMagnification = 0

END FUNCTION
'
' ####################################
' #####  WritePrintingOptions ()  #####
' ####################################
'
' Writes the Printing options to the .INI file
'
FUNCTION WritePrintingOptions ()

	SHARED IniFile$
	SHARED fPrintingColorMode
	SHARED fPrintingMagnification

	IniWrite (IniFile$, "Printing options", "ColorMode", STRING$ (fPrintingColorMode))
	IniWrite (IniFile$, "Printing options", "Magnification", STRING$ (fPrintingMagnification))

END FUNCTION
'
' ###################################
' #####  InitializeAsmKeywords  #####
' ###################################
'
FUNCTION InitializeAsmKeywords (pSci)

	' cpu instructions
	cpu$ = "aaa aad aam aas adc add and call cbw _
			clc cld cli cmc cmp cmps cmpsb cmpsw cwd daa das dec div esc hlt _
			idiv imul in inc int into iret ja jae jb jbe jc jcxz je jg jge jl _
			jle jmp jna jnae jnb jnbe jnc jne jng jnge jnl jnle jno jnp jns _
			jnz jo jp jpe jpo js jz lahf lds lea les lods lodsb lodsw loop _
			loope loopew loopne loopnew loopnz loopnzw loopw loopz loopzw _
			mov movs movsb movsw mul neg nop not or out pop popf push pushf _
			rcl rcr ret retf retn rol ror sahf sal sar sbb scas scasb scasw _
			shl shr stc std sti stos stosb stosw sub test wait xchg xlat _
			xlatb xor _
			bound enter ins insb insw leave outs outsb outsw popa pusha pushw _
			arpl lar lsl sgdt sidt sldt smsw str verr verw clts lgdt lidt lldt lmsw ltr _
			bsf bsr bt btc btr bts cdq cmpsd cwde insd iretd iretdf iretf _
			jecxz lfs lgs lodsd loopd  looped  loopned loopnzd loopzd  lss _
			movsd movsx movzx outsd popad popfd pushad pushd  pushfd scasd seta _
			setae setb setbe setc sete setg setge setl setle setna setnae setnb _
			setnbe setnc setne setng setnge setnl setnle setno setnp setns _
			setnz seto setp setpe setpo sets setz shld shrd stosd _
			bswap cmpxchg invd invlpg wbinvd xadd _
			lock rep repe repne repnz repz _
			cflush cpuid emms femms _
			cmovo cmovno cmovb cmovc cmovnae cmovae cmovnb cmovnc _
			cmove cmovz cmovne cmovnz cmovbe cmovna cmova cmovnbe _
			cmovs cmovns cmovp cmovpe cmovnp cmovpo cmovl cmovnge _
			cmovge cmovnl cmovle cmovng cmovg cmovnle _
			cmpxchg486 cmpxchg8b _
			loadall loadall286 ibts icebp int1 int3 int01 int03 iretw _
			popaw popfw pushaw pushfw rdmsr rdpmc rdshr rdtsc _
			rsdc rsldt rsm rsts salc smi smint smintold svdc svldt svts _
			syscall sysenter sysexit sysret ud0 ud1 ud2 umov xbts wrmsr wrshr"
	SciMsg (pSci, $$SCI_SETKEYWORDS, 0, &cpu$)

	' fpu instructions
	fpu$ = "f2xm1 fabs fadd faddp fbld fbstp fchs fclex fcom fcomp fcompp fdecstp _
			fdisi fdiv fdivp fdivr fdivrp feni ffree fiadd ficom ficomp fidiv _
			fidivr fild fimul fincstp finit fist fistp fisub fisubr fld fld1 _
			fldcw fldenv fldenvw fldl2e fldl2t fldlg2 fldln2 fldpi fldz fmul _
			fmulp fnclex fndisi fneni fninit fnop fnsave fnsavew fnstcw fnstenv _
			fnstenvw fnstsw fpatan fprem fptan frndint frstor frstorw fsave _
			fsavew fscale fsqrt fst fstcw fstenv fstenvw fstp fstsw fsub fsubp _
			fsubr fsubrp ftst fwait fxam fxch fxtract fyl2x fyl2xp1 _
			fsetpm fcos fldenvd fnsaved fnstenvd fprem1 frstord fsaved fsin fsincos _
			fstenvd fucom fucomp fucompp fcomi fcomip ffreep _
			fcmovb fcmove fcmovbe fcmovu fcmovnb fcmovne fcmovnbe fcmovnu"
	SciMsg (pSci, $$SCI_SETKEYWORDS, 1, &fpu$)

	' extended instructions (these are MMX, SSE, SSE2 instructions)
	ext$ = "addpd addps addsd addss andpd andps andnpd andnps _
			cmpeqpd cmpltpd cmplepd cmpunordpd cmpnepd cmpnltpd cmpnlepd cmpordpd _
			cmpeqps cmpltps cmpleps cmpunordps cmpneps cmpnltps cmpnleps cmpordps _
			cmpeqsd cmpltsd cmplesd cmpunordsd cmpnesd cmpnltsd cmpnlesd cmpordsd _
			cmpeqss cmpltss cmpless cmpunordss cmpness cmpnltss cmpnless cmpordss _
			comisd comiss cvtdq2pd cvtdq2ps cvtpd2dq cvtpd2pi cvtpd2ps _
			cvtpi2pd cvtpi2ps cvtps2dq cvtps2pd cvtps2pi cvtss2sd cvtss2si _
			cvtsd2si cvtsd2ss cvtsi2sd cvtsi2ss _
			cvttpd2dq cvttpd2pi cvttps2dq cvttps2pi cvttsd2si cvttss2si _
			divpd divps divsd divss fxrstor fxsave ldmxscr lfence mfence _
			maskmovdqu maskmovdq maxpd maxps paxsd maxss minpd minps minsd minss _
			movapd movaps movdq2q movdqa movdqu movhlps movhpd movhps movd movq _
			movlhps movlpd movlps movmskpd movmskps movntdq movnti movntpd movntps _
			movntq movq2dq movsd movss movupd movups mulpd mulps mulsd mulss _
			orpd orps packssdw packsswb packuswb paddb paddsb paddw paddsw _
			paddd paddsiw paddq paddusb paddusw pand pandn pause paveb pavgb pavgw _
			pavgusb pdistib pextrw pcmpeqb pcmpeqw pcmpeqd pcmpgtb pcmpgtw pcmpgtd _
			pf2id pf2iw pfacc pfadd pfcmpeq pfcmpge pfcmpgt pfmax pfmin pfmul _
			pmachriw pmaddwd pmagw pmaxsw pmaxub pminsw pminub pmovmskb _
			pmulhrwc pmulhriw pmulhrwa pmulhuw pmulhw pmullw pmuludq _
			pmvzb pmvnzb pmvlzb pmvgezb pfnacc pfpnacc por prefetch prefetchw _
			prefetchnta prefetcht0 prefetcht1 prefetcht2 pfrcp pfrcpit1 pfrcpit2 _
			pfrsqit1 pfrsqrt pfsub pfsubr pi2fd pf2iw pinsrw psadbw pshufd _
			pshufhw pshuflw pshufw psllw pslld psllq pslldq psraw psrad _
			psrlw psrld psrlq psrldq psubb psubw psubd psubq psubsb psubsw _
			psubusb psubusw psubsiw pswapd punpckhbw punpckhwd punpckhdq punpckhqdq _
			punpcklbw punpcklwd punpckldq punpcklqdq pxor rcpps rcpss _
			rsqrtps rsqrtss sfence shufpd shufps sqrtpd sqrtps sqrtsd sqrtss _
			stmxcsr subpd subps subsd subss ucomisd ucomiss _
			unpckhpd unpckhps unpcklpd unpcklps xorpd xorps"
	SciMsg (pSci, $$SCI_SETKEYWORDS, 5, &ext$)

 ' registers
	reg$ = "ah al ax bh bl bp bx ch cl cr0 cr2 cr3 cr4 cs _
			cx dh di dl dr0 dr1 dr2 dr3 dr6 dr7 ds dx eax ebp ebx ecx edi edx _
			es esi esp fs gs si sp ss st tr3 tr4 tr5 tr6 tr7 _
			st0 st1 st2 st3 st4 st5 st6 st7 mm0 mm1 mm2 mm3 mm4 mm5 mm6 mm7 _
			xmm0 xmm1 xmm2 xmm3 xmm4 xmm5 xmm6 xmm7"
	SciMsg (pSci, $$SCI_SETKEYWORDS, 2, &reg$)

	' directives (masm and nasm)
	dir$ = ".186 .286 .286c .286p .287 .386 .386c .386p .387 .486 .486p _
			.8086 .8087 .alpha .break .code .const .continue .cref .data .data?  _
			.dosseg .else .elseif .endif .endw .err .err1 .err2 .errb _
			.errdef .errdif .errdifi .erre .erridn .erridni .errnb .errndef _
			.errnz .exit .fardata .fardata? .if .lall .lfcond .list .listall _
			.listif .listmacro .listmacroall  .model .no87 .nocref .nolist _
			.nolistif .nolistmacro .radix .repeat .sall .seq .sfcond .stack _
			.startup .tfcond .type .until .untilcxz .while .xall .xcref _
			.xlist alias align assume catstr code comm comment const data db dd df dosseg dq _
			dt dup dw echo else elseif elseif1 elseif2 elseifb elseifdef elseifdif _
			elseifdifi elseife elseifidn elseifidni elseifnb elseifndef end _
			endif endm endp ends eq equ even exitm extern externdef extrn for _
			forc ge goto group gt high highword if if1 if2 ifb ifdef ifdif _
			ifdifi ife  ifidn ifidni ifnb ifndef include includelib instr invoke _
			irp irpc label le length lengthof local low lowword lroffset _
			lt macro mask mod .msfloat name ne offset opattr option org %out _
			page popcontext proc proto ptr public purge pushcontext record _
			repeat rept seg segment short size sizeof sizestr struc struct _
			substr subtitle subttl textequ this title type typedef union while width _
			db dw dd dq dt resb resw resd resq rest incbin equ times _
			%define %idefine %xdefine %xidefine %undef %assign %iassign _
			%strlen %substr %macro %imacro %endmacro %rotate .nolist _
			%if %elif %else %endif %ifdef %ifndef %elifdef %elifndef _
			%ifmacro %ifnmacro %elifmacro %elifnmacro %ifctk %ifnctk %elifctk %elifnctk _
			%ifidn %ifnidn %elifidn %elifnidn %ifidni %ifnidni %elifidni %elifnidni _
			%ifid %ifnid %elifid %elifnid %ifstr %ifnstr %elifstr %elifnstr _
			%ifnum %ifnnum %elifnum %elifnnum %error %rep %endrep %exitrep _
			%include %push %pop %repl struct endstruc istruc at iend align alignb _
			%arg %stacksize %local %line _
			bits use16 use32 section absolute extern global common cpu org _
			section group import export"
	SciMsg (pSci, $$SCI_SETKEYWORDS, 3, &dir$)

	' directive operand
	oper$ = "$ ? @b @f addr basic byte c carry? dword _
			far far16 fortran fword near near16 overflow? parity? pascal qword  _
			real4  real8 real10 sbyte sdword sign? stdcall sword syscall tbyte _
			vararg word zero? flat near32 far32 _
			abs all assumes at casemap common compact _
			cpu dotname emulator epilogue error export expr16 expr32 farstack flat _
			forceframe huge language large listing ljmp loadds m510 medium memory _
			nearstack nodotname noemulator nokeyword noljmp nom510 none nonunique _
			nooldmacros nooldstructs noreadonly noscoped nosignextend nothing _
			notpublic oldmacros oldstructs os_dos para private prologue radix _
			readonly req scoped setif2 smallstack tiny use16 use32 uses _
			a16 a32 o16 o32 byte word dword nosplit $ $$ seq wrt _
			flat large small .text .data .bss near far _
			%0 %1 %2 %3 %4 %5 %6 %7 %8 %9"
	SciMsg (pSci, $$SCI_SETKEYWORDS, 4, &oper$)

END FUNCTION

'
' ############################
' #####  ShowHTMLDlg ()  #####
' ############################
'
' PURPOSE : Display a html file or url in a dialog box.
'           This utilizes the IE4.0+ mshtml.dll library
'           function ShowHTMLDialog (). The bool flags
'           resize, status, center allow one to resize
'           the dialog window, to show a statusbar, and
'           to center the dialog window. url$ can be any
'           valid displayable html file or url address.

FUNCTION  ShowHTMLDlg (hwndParent, url$, x, y, w, h, resize, status, center)

	USHORT wideUrl[255]
	USHORT wideOptions[255]

	FUNCADDR ShowHTMLDialog (ULONG, ULONG, ULONG, ULONG, ULONG)
	FUNCADDR CreateURLMoniker (ULONG, ULONG, ULONG)

' initialize unicode arrays
	wideUrl[0] = 0
	wideOptions[0] = 0

' convert url$ to unicode
  ret = MultiByteToWideChar ($$CP_ACP, 0, &url$, -1, &wideUrl[0], 256)
	IFZ ret THEN RETURN

' load the mshtml.dll library
  hInstMSHTML = LoadLibraryA (&"mshtml.dll")
	IFZ hInstMSHTML THEN RETURN

' load urlmon.dll library
	hInstUrlmon = LoadLibraryA (&"urlmon.dll")
	IFZ hInstUrlmon THEN GOTO end

' get function address for the ShowHTMLDialog ()
	ShowHTMLDialog = GetProcAddress (hInstMSHTML, &"ShowHTMLDialog")
	IFZ ShowHTMLDialog THEN GOTO end

' get function address for CreateURLMoniker ()
	CreateURLMoniker = GetProcAddress (hInstUrlmon, &"CreateURLMoniker")
	IFZ CreateURLMoniker THEN GOTO end

' create URL Moniker (urlmon.dll)
' ret = CreateURLMoniker (pmkContext, lpszURL, ppmk)
' pmkContext - [in] Address of the IMoniker interface for the
'              URL moniker to use as the base context when the
'              szURL parameter is a partial URL string.
'              The pmkContext parameter can be NULL.
' lpszURL    - [in] Address of a string value that contains the
'              display name to be parsed.
' ppmk       - [out] Address of a pointer to an IMoniker interface
'              for the new URL moniker.
' return     - S_OK (=0) success

	ppmk = 0
  moniker = @CreateURLMoniker (0, &wideUrl[0], &ppmk)
	IF moniker THEN GOTO end

' show the html dialog window
'	hResult = ShowHTMLDialog (hwndParent, pMk, pvarArgIn, pchOptions, pvarArgOut)
' hwndParent - Handle to the parent of the dialog box.
' pMk        - Address of an IMoniker interface from which the HTML for
'              the dialog box is loaded.
' pvarArgIn  - Address of a VARIANT structure that contains the
'              input data for the dialog box. The data passed in
'              this VARIANT is placed in the window object's
'              IHTMLDialog::dialogArguments property. This parameter
'              can be NULL.
' pchOptions - Window ornaments for the dialog box. This parameter
'              can be NULL or the address of a string that contains
'              a combination of values, each separated by a semicolon (;).
'              See the description of the features parameter of the
'              IHTMLWindow2::showModalDialog method of the window object
'              for detailed information.
' pvarArgOut - Address of a VARIANT structure that contains the output
'              data for the dialog box. This VARIANT receives the data
'              that was placed in the window object's IHTMLDialog::returnValue
'              property. This parameter can be NULL.
' Return Value - Returns S_OK if successful, or an error value otherwise.

' set dialog display options
	options$ = ""
	IFZ center THEN
		options$ = options$ + "center:0"      + ";"
		options$ = options$ + "dialogLeft:"   + STRING$(x) + "px" + ";"
		options$ = options$ + "dialogTop:"    + STRING$(y) + "px" + ";"
	END IF
	IF w       THEN options$ = options$ + "dialogWidth:"  + STRING$(w) + "px" + ";"
	IF h       THEN options$ = options$ + "dialogHeight:" + STRING$(h) + "px" + ";"
	IF resize  THEN options$ = options$ + "resizable:1"   + ";"
	IF status  THEN options$ = options$ + "status:1"      + ";"

	options$ = options$ + "help:0"        									' turn off help icon

' convert options$ to unicode
  ret = MultiByteToWideChar ($$CP_ACP, 0, &options$, -1, &wideOptions[0], 256)
	IFZ ret THEN GOTO end

' show html dialog
  dlgRet = @ShowHTMLDialog (hwndParent, ppmk, 0, &wideOptions[0], 0)

' free the dll libraries
end:
  IF hInstMSHTML THEN FreeLibrary (hInstMSHTML)
  IF hInstUrlmon THEN FreeLibrary (hInstUrlmon)

END FUNCTION
'
' ######################################
' #####  GetWordAtCurrentPosition  #####
' ######################################
'
'
'
FUNCTION GetWordAtPosition (position, @word$)

	TEXTRANGE txtrg

	x = 0 : y = 0 : word$ = ""
	hEdit = GetEdit ()
	IFZ hEdit THEN RETURN ($$TRUE)

	curPos = position

	' Retrieve the starting position of the word
	x = SendMessageA (hEdit, $$SCI_WORDSTARTPOSITION, curPos, 1)

	' Retrieve the ending position of the word
	y = SendMessageA (hEdit, $$SCI_WORDENDPOSITION, curPos, 0)
	IF y > x THEN
		word$ = NULL$ (y - x + 1)
		' get text from range
		txtrg.chrg.cpMin = x
		txtrg.chrg.cpMax = y
		txtrg.lpstrText = &word$
		SendMessageA (GetEdit (), $$SCI_GETTEXTRANGE, 0, &txtrg)
		word$ = TRIM$(CSIZE$ (word$))
		RETURN
	END IF
	RETURN ($$TRUE)

END FUNCTION
'
' ###################################
' #####  ShowFindFilesControls  #####
' ###################################
'
'
'
FUNCTION ShowFindFilesControls (hWnd, fShow)

	IF fShow THEN
		show = $$SW_SHOW
	ELSE
		show = $$SW_HIDE
	END IF

	FOR i = $$IDC_SEARCH_FIRST TO $$IDC_SEARCH_LAST
		h = GetDlgItem (hWnd, i)
		ShowWindow (h, show)
	NEXT i

END FUNCTION
'
' ##########################
' #####  StringSearch  #####
' ##########################
'
' Search in s$ for find$, returning $$TRUE if a match is found
' at position. If fFullWords is $$TRUE, then return is $$TRUE
' if whole word is found. position is zero-based.
'
FUNCTION StringSearch (s$, find$, fFullWords, @position)

	IFZ s$ THEN RETURN
	IFZ find$ THEN RETURN

	lenFind = LEN (find$)
	bufIndex = lenFind
	bufPtr = &s$
	findPtr = &find$
	bufLen = LEN (s$)
	initBufPtr = bufPtr

	position = 0

  DO
    i = _memicmp (bufPtr, findPtr, lenFind)						' do memory comparison
    IF fFullWords THEN       													' apply restrictive pattern matching
      IFZ i THEN																			' found a match
				IF bufPtr = initBufPtr THEN
					IFZ isalpha (UBYTEAT(bufPtr+lenFind)) THEN 	' is char after non alpha
						position = bufPtr - initBufPtr
            RETURN $$TRUE
          END IF
				ELSE
					IFZ isalpha (UBYTEAT(bufPtr-1)) THEN					' is char before non alpha
						IFZ isalpha (UBYTEAT(bufPtr+lenFind)) THEN 	' is char after non alpha
							position = bufPtr - initBufPtr
							RETURN $$TRUE
						END IF
					END IF
				END IF
      END IF
    ELSE
      IFZ i THEN
				position = bufPtr - &s$
				RETURN $$TRUE
			END IF
    END IF
    INC bufPtr
    INC bufIndex
    IF bufIndex > bufLen THEN EXIT DO
  LOOP

END FUNCTION
'
' ######################
' #####  FindFile  #####
' ######################
'
'
'
FUNCTION FindFile (dir$, fileMask$, fRecurse, find$)

	WIN32_FIND_DATA fd
	GIANT fs

	IFZ dir$ THEN RETURN
	IF RIGHT$ (dir$, 1) = "\\" THEN dir$ = LEFT$(dir$, LEN(dir$)-1)
	s$ = dir$ + "\\*"
	h = FindFirstFileA (&s$, &fd)
  IF (h != $$INVALID_HANDLE_VALUE) THEN
		DO
			IF (strcmp (&".", &fd.cFileName) && strcmp (&"..", &fd.cFileName)) THEN
				IF (fd.dwFileAttributes & $$FILE_ATTRIBUTE_DIRECTORY) THEN

					IF fRecurse THEN
						s$ = dir$ + "\\" + fd.cFileName
'						? ">>>>> "; s$; " <<<<<"
						FindFile (s$, fileMask$, fRecurse, find$)
					END IF
				ELSE
'					fs = CalcFileSize (fd.nFileSizeHigh, fd.nFileSizeLow)
'					? dir$ + "\\" + fd.cFileName, " *** "; fs; " bytes ***"
					s$ = dir$ + "\\" + fd.cFileName
					IF Like (s$, fileMask$) THEN
'? "Like ok: ", s$, fileMask$, find$
						 DoFileSearch (s$, find$)
					END IF
				END IF
			END IF
		LOOP WHILE (FindNextFileA (h, &fd))
		FindClose (h)
	END IF

END FUNCTION
'
' ##########################
' #####  CalcFileSize  #####
' ##########################
'
'
'
FUNCTION GIANT CalcFileSize (ULONG high, ULONG low)

  RETURN (high * $$TWO32 + low)
END FUNCTION

'
'
' #####################
' #####  Like ()  #####
' #####################
'
' If match if found, returns $$TRUE.
'
FUNCTION  Like (string$, mask$)

  IFZ string$ THEN RETURN
  IFZ mask$ THEN RETURN
  IF mask${0} == '*' && mask${1} == '\0' THEN RETURN ($$TRUE)
  RETURN (DoMatch (&string$, &mask$) == $$LIKE_TRUE)

END FUNCTION
'
'
' ########################
' #####  DoMatch ()  #####
' ########################
'
' Match strings pointed to by
' stringAddr and maskAddr.
' Return $$LIKE_TRUE, $$LIKE_FALSE, or $$LIKE_ABORT
' Mask characters:
' * - match any char, zero or more times
' ? - match any one char
' # - match any one digit 0123456789
' $ - match any one alpha char a-z, A-Z
' [c-c]  - match any one char within a range of chars; [A-Z]
' [!c-c] - match any one char not within a range of chars; [!x-z]
'
FUNCTION  DoMatch (stringAddr, maskAddr)

  p = maskAddr
  text = stringAddr

  DO WHILE (UBYTEAT (p) && UBYTEAT (text))
'PRINT UBYTEAT (p), CHR$ (UBYTEAT (p))
'PRINT UBYTEAT (text), CHR$ (UBYTEAT (text))

    SELECT CASE UBYTEAT (p)
      CASE '\\' :
        INC p
        IF UBYTEAT (text) != UBYTEAT (p) THEN RETURN ($$LIKE_FALSE)
      CASE '#'  :                     ' match any one digit 0123456789
        IFZ IsDigit (UBYTEAT (text)) THEN RETURN ($$LIKE_FALSE)
      CASE '$'  :                     ' match any one alpha char a-z A-Z
        IFZ IsAlpha (UBYTEAT (text)) THEN RETURN ($$LIKE_FALSE)
      CASE '['  :                     ' match one from a range; [a-z]
        IFZ ParseRange (p, @not, @start, @end, @count, @error) THEN RETURN (error)
        IFZ not THEN
          IFZ CheckRange (UBYTEAT (text), start, end) THEN RETURN ($$LIKE_FALSE)
        ELSE
          IFT CheckRange (UBYTEAT (text), start, end) THEN RETURN ($$LIKE_FALSE)
        END IF
        p = p + count
      CASE '?'  :                     ' match any one char
      CASE '*'  :                     ' match zero or more - all chars
        DO WHILE UBYTEAT (p) == '*'   ' advance past all *'s
          INC p
        LOOP
        IF UBYTEAT (p) == '\0' THEN RETURN ($$LIKE_TRUE) ' trailing percent matches everything
        DO WHILE UBYTEAT (text)       ' optimization to prevent most recursion
          matched = DoMatch (text, p)
          pchar = UBYTEAT (p)
          IF ((UBYTEAT(text) == pchar || pchar == '\\' || pchar == '*' || pchar == '?' || pchar == '#' || pchar == '$' || pchar == '[') && (matched != $$LIKE_FALSE)) THEN
            RETURN matched
          END IF
          INC text
        LOOP
        RETURN ($$LIKE_ABORT)
      CASE ELSE : IF UBYTEAT (text) != UBYTEAT (p) THEN RETURN ($$LIKE_FALSE)
    END SELECT
    INC p
    INC text
  LOOP

  IF (UBYTEAT (text) != '\0') THEN
    RETURN ($$LIKE_ABORT)
  ELSE
' End of input string.  Do we have matching string remaining?
    IF (UBYTEAT (p) == '\0' || (UBYTEAT (p) == '*' && UBYTEAT (p+1) == '\0')) THEN
      RETURN ($$LIKE_TRUE)
    ELSE
      RETURN ($$LIKE_ABORT)
    END IF
  END IF
  RETURN

END FUNCTION
'
'
' ########################
' #####  IsDigit ()  #####
' ########################
'
' Returns $$TRUE if char is 0123456789.
'
FUNCTION  IsDigit (char)
  IF char > 47 && char < 58 THEN RETURN ($$TRUE)
END FUNCTION
'
'
' ########################
' #####  IsAlpha ()  #####
' ########################
'
' Returns $$TRUE if char is a-z or A-Z.
'
FUNCTION  IsAlpha (char)
  IF (char > 64 && char < 91) || (char > 96 && char < 123) THEN RETURN ($$TRUE)
END FUNCTION
'
'
' ###########################
' #####  ParseRange ()  #####
' ###########################
'
' Returns $$TRUE if range is valid.
' Returns not = $$TRUE if ! char is used.
' Returns start character and end character.
' On error, returns error code in error.
' Returned count contains number of bytes remaining in p
' Range must be from lower ascii value to higher ascii value; [A-Z]
' or equal; [!x-x]
'
FUNCTION  ParseRange (p, @not, @start, @end, @count, @error)

  not = 0
  start = 0
  end = 0
  count = 0
  error = 0

' find closing bracket
  pp = p
  DO WHILE UBYTEAT (p)
    INC pp
    INC count
    IF UBYTEAT (pp) == ']' THEN
      fBracket = $$TRUE
      EXIT DO
    END IF
  LOOP

  IFZ fBracket THEN
    error = $$LIKE_MISSING_BRACKET
    RETURN
  END IF

' check max chars [!A-Z]
' count will be 4 or 5

  SELECT CASE count
    CASE 4 :
      start = UBYTEAT (p+1)
      IF UBYTEAT (p+2) != '-' THEN error = $$LIKE_BAD_RANGE_FORMAT : RETURN
      end = UBYTEAT (p+3)
      not = $$FALSE
    CASE 5 :
      IF UBYTEAT (p+1) != '!' THEN error = $$LIKE_BAD_RANGE_FORMAT : RETURN
      start = UBYTEAT (p+2)
      IF UBYTEAT (p+3) != '-' THEN error = $$LIKE_BAD_RANGE_FORMAT : RETURN
      end = UBYTEAT (p+4)
      not = $$TRUE
    CASE ELSE : error = $$LIKE_BAD_RANGE_FORMAT : RETURN
  END SELECT

  IF end - start < 0 THEN error = $$LIKE_INVALID_RANGE : RETURN

  RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  CheckRange ()  #####
' ###########################
'
' Returns $$TRUE if char is within range of start and end.
'
FUNCTION  CheckRange (char, start, end)
  IF char > start-1 && char < end+1 THEN RETURN ($$TRUE)
END FUNCTION
'
' ##########################
' #####  DoFileSearch  #####
' ##########################
'
' Search in fileName$ for find$. Update console window with
' positive finds.
'
FUNCTION DoFileSearch (fileName$, find$)

	SHARED hListBox, hSearchButton5
	SHARED searchFilesScanned, searchFilesMatched
	SHARED hStatusbar

	IFZ fileName$ THEN RETURN
	IFZ find$ THEN RETURN

	XstLoadString (fileName$, @text$)		' load file into string
	IFZ text$ THEN RETURN								' skip empty file
	IF IsBinary (@text$) THEN RETURN		' skip binary files
	INC searchFilesScanned							' update scanned files counter

	' display filename in statusbar
	SendMessageA (hStatusbar, $$SB_SETTEXT, 4 , &fileName$)
	DoEvents ()

	DO
	LOOP UNTIL XstReplace (@find$, $$DOUBLE_SPACE, $$SINGLE_SPACE, 0) <= 0
	XstParseStringToStringArray (find$, " ", @buf$[])
	IFZ buf$[] THEN RETURN
	upp = UBOUND (buf$[])

	FOR i = 0 TO upp

    Exclude = $$FALSE
    ORflag = $$FALSE

    cell$ = buf$[i]

    IF cell${0} = '-' THEN
      Exclude = $$TRUE
      cell$ = MID$(cell$, 2)
    END IF

    IF cell${0} = '|' THEN
      ORflag = $$TRUE
      cell$ = MID$(cell$, 2)
    END IF

		fFullWord = IsChecked (hSearchButton5)	' is Full Word search checkbox enabled
    rc = StringSearch (text$, cell$, fFullWord, @pos)

    IF !rc && ORflag THEN DO NEXT     ' tolerate 1st missed OR term

    IF rc && ORflag  THEN 						' found 1st OR term -- there is no compelling
      INC i                 					' need to find the 2nd term, so we'll skip it
      DO NEXT
    END IF

    IF !rc && Exclude THEN DO NEXT    ' tolerate unfound exclusions
    IF rc && Exclude THEN RETURN    	' we found an unwanted match
    IFZ rc THEN RETURN    						' search term not found
	NEXT i

	' found a match
	INC searchFilesMatched

	s$ = fileName$ + "(-1): Match found at(" + STRING$(pos) + ")"
	Listbox_AddString (hListBox, s$)

END FUNCTION
'
' #########################
' #####  OnSearchNow  #####
' #########################
'
'
'
FUNCTION OnSearchNow (hWnd)

	SHARED searchFilesScanned, searchFilesMatched
	SHARED hListBox, hSplitter, hStatusbar
	RECT rc

	searchFilesScanned = 0
	searchFilesMatched = 0

	' get text from edit controls
	startFolder$ = TRIM$(GetWindowText$ (GetDlgItem (hWnd, $$IDC_SEARCH_EDIT1)))
	srchText$    = TRIM$(GetWindowText$ (GetDlgItem (hWnd, $$IDC_SEARCH_EDIT2)))
	fileMask$    = TRIM$(GetWindowText$ (GetDlgItem (hWnd, $$IDC_SEARCH_EDIT3)))

	DO
	LOOP UNTIL XstReplace (@fileMask$, $$DOUBLE_SPACE, $$SINGLE_SPACE, 0) <= 0
	XstParseStringToStringArray (fileMask$, " ", @ext$[])
	maskCount = UBOUND(ext$[])
'PRINT "maskCount="; maskCount

	IF startFolder$ = "" || fileMask$ = "" || srchText$ = "" THEN
		SED_MsgBox (hWnd, "Search Error. Missing Search Parameter.", 0, "Find in Files Error")
		RETURN
	END IF

	ClearConsole ()
	GetClientRect (hSplitter, &rc)
	SendMessageA (hSplitter, $$WM_UNDOCK_SPLITTER, 0, 0)
	SendMessageA (hSplitter, $$WM_SET_SPLITTER_POSITION, 0, rc.bottom - $$INITIAL_CONSOLE_HEIGHT)

	s$ = "> Starting search for: " + srchText$
	Listbox_AddString (hListBox, s$)

	DO
	LOOP UNTIL XstReplace (@srchText$, $$DOUBLE_SPACE, $$SINGLE_SPACE, 0) <= 0

	XstParseStringToStringArray (srchText$, " ", @terms$[])
	terms = UBOUND(terms$[])
'PRINT "terms="; terms, terms$[0]
	srchText$ = ""

	FOR i = 0 TO terms
		IF terms$[i] = "|" || LCASE$(terms$[i]) = "or" THEN
			terms$[i-1] = "|" + terms$[i-1]
			terms$[i] = ""
		END IF

		IF LCASE$(terms$[i]) = "and" || terms$[i] = "+" THEN
			terms$[i] = " "
		END IF

		IF LCASE$(terms$[i]) = "not" THEN
			terms$[i+1] = "-" + terms$[i+1]
			terms$[i] = ""
		END IF

		IF LEN(terms$[i]) > 2 && LEFT$(terms$[i], 1) = "+" THEN
			terms$[i] = MID$(terms$[i], 2)
		END IF

	NEXT i

	FOR i = 0 TO terms
		IF terms$[i] THEN srchText$ = srchText$ + " " + terms$[i]
	NEXT
	srchText$ = TRIM$(srchText$)

	' recurse through subfolders
	fRecurse = IsChecked (GetDlgItem (hWnd, $$IDC_SEARCH_BUTTON4))

	' disable window
	EnableWindow (hWnd, 0)

	FOR i = 0 TO maskCount
		fileMask$ = ext$[i]
'? startfolder$, fileMask$, fRecurse, srchText$
		FindFile (startFolder$, fileMask$, fRecurse, srchText$)
	NEXT i

	' enable window
	EnableWindow (hWnd, 1)

	' add final search info to listbox
	s$ = "> Search done."
	Listbox_AddString (hListBox, s$)
	s$ = "> " + STRING$(searchFilesMatched) + " matching files found."
	Listbox_AddString (hListBox, s$)
	s$ = "> " + STRING$(searchFilesScanned) + " files searched."
	Listbox_AddString (hListBox, s$)

	' clear filename in statusbar
	s$ = ""
	SendMessageA (hStatusbar, $$SB_SETTEXT, 4 , &s$)

END FUNCTION

FUNCTION SetCheckBox (hButton)
  SendMessageA (hButton, $$BM_SETCHECK, 1, 0)
END FUNCTION

FUNCTION IsChecked (hButton)
  RETURN SendMessageA (hButton, $$BM_GETCHECK, 0, 0)
END FUNCTION

FUNCTION UnCheckBox (hButton)
  SendMessageA (hButton, $$BM_SETCHECK, 0, 0)
END FUNCTION
'
'
' ###########################
' #####  SetTooltip ()  #####
' ###########################
'
FUNCTION  SetTooltip (hWnd, tip$)

TOOLINFO ti

' create tooltip control
	hTooltip = NewTooltipControl (GetParent (hWnd))
	IFZ hTooltip THEN RETURN

' fill TOOLINFO struct ti
	ti.cbSize   = SIZE (ti)
	ti.uFlags   = $$TTF_SUBCLASS | $$TTF_IDISHWND
	ti.hwnd     = GetParent (hWnd)
	ti.uId      = hWnd

' if tooltip already exists, then delete it
	IF SendMessageA (hTooltip, $$TTM_GETTOOLINFO, 0, &ti) THEN
		SendMessageA (hTooltip, $$TTM_DELTOOL, 0, &ti)
	END IF

' add new tooltip
	ti.cbSize   = SIZE(ti)
	ti.uFlags   = $$TTF_SUBCLASS | $$TTF_IDISHWND
	ti.hwnd     = GetParent (hWnd)
	ti.uId      = hWnd
	ti.lpszText = &tip$
	ret = SendMessageA (hTooltip, $$TTM_ADDTOOL, 0, &ti)

	IF ret THEN RETURN hTooltip

END FUNCTION
'
'
' ##################################
' #####  NewTooltipControl ()  #####
' ##################################
'
FUNCTION  NewTooltipControl (hWnd)

	SHARED hInst
	IFZ hWnd THEN RETURN
	className$ = $$TOOLTIPS_CLASS
	text$ = ""
	RETURN CreateWindowExA (0, &className$, &text$, 0, 0, 0, 0, 0, hWnd, 0, hInst, 0)

END FUNCTION
'
' ######################
' #####  DoEvents  #####
' ######################
'
' Process all messages in queue
'
FUNCTION DoEvents ()

	USER32_MSG msg

	DO																		' enter the message loop
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN		' grab a message
			SELECT CASE msg.message
				CASE $$WM_CLOSE, $$WM_QUIT, $$WM_DESTROY, $$WM_SYSCOMMAND :
				CASE ELSE :
					TranslateMessage (&msg)				' translate virtual-key messages into character messages
					DispatchMessageA (&msg)				' send message to window callback function WndProc()
			END SELECT
		ELSE
			EXIT DO														' no more messages
		END IF
	LOOP

END FUNCTION

'
' ###########################
' #####  KBHookProc ()  #####
' ###########################
'
' Capture key strokes in pop-up character map
'
FUNCTION KBHookProc (code, wParam, lParam)

	SHARED hKeyHook, hWndDialog
	SHARED selection
	USHORT state

	$OFFSET = 1024

	IF nCode < 0 THEN RETURN CallNextHookEx (hKeyHook, code, wParam, lParam)

	SELECT CASE code
		CASE $$HC_ACTION :						' message from keyboard
			virtKey = wParam						' wParam specifies virtual-key code
			state = HIWORD (lParam)
			IF  !(state & $$KF_UP) && !(state & $$KF_REPEAT) THEN
				prevSelection = selection
				SELECT CASE virtKey
					CASE $$VK_LEFT		: DEC selection
					CASE $$VK_RIGHT		: INC selection
					CASE $$VK_UP			: selection = selection - 16
					CASE $$VK_DOWN		: selection = selection + 16
					CASE $$VK_HOME		: selection = (((selection - $OFFSET) \ 16) * 16) + $OFFSET
					CASE $$VK_END			: selection = (((selection - $OFFSET) \ 16) * 16 + 15) + $OFFSET
					CASE $$VK_PRIOR		: selection = ((selection - $OFFSET) MOD 16) + $OFFSET
					CASE $$VK_NEXT		: selection = ((selection - $OFFSET) MOD 16 + 240) + $OFFSET
				END SELECT
				IF selection > $OFFSET + 255 || selection < $OFFSET THEN
					selection = prevSelection
				ELSE
					hs = GetDlgItem (hWndDialog, selection)
					hp = GetDlgItem (hWndDialog, prevSelection)
					InvalidateRect (hs, NULL, 1)
					InvalidateRect (hp, NULL, 1)
				END IF
			END IF
	END SELECT

	RETURN CallNextHookEx (hKeyHook, code, wParam, lParam)

END FUNCTION

FUNCTION DrawLineStatic (hWnd, x1, y1, x2, y2, color)

	' for color use $$Black, $$White, or $$Gray
	SELECT CASE color
		CASE $$Black: style = $$SS_BLACKRECT
		CASE $$White: style = $$SS_WHITERECT
		CASE $$Grey:	style = $$SS_GRAYRECT
		CASE ELSE:		style = $$SS_BLACKRECT
	END SELECT
	NewChild ("static", "", style | $$WS_VISIBLE, x1, y1, x2-x1+1, y2-y1+1, hWnd, -1, 0)

END FUNCTION

'
'
' ###########################
' #####  MsgBoxProc ()  #####
' ###########################
'
FUNCTION MsgBoxProc (hDlg, msg, wParam, lParam)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE
	SHARED hImlHot   ' image list handle

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			' set dialog caption
			SetWindowTextA (hDlg, &$$MBB_CAPTION)

			' add child controls to dialog box
			' order of creation determines tab order
			NewChild ("button", "Caption", $$BS_GROUPBOX | $$WS_GROUP, 8, 6, 234, 42, hDlg, $$grpCAPTION, 0)
			NewChild ("edit", "text", $$ES_LEFT | $$ES_AUTOHSCROLL | $$WS_TABSTOP | $$WS_BORDER, 16, 24, 218, 18, hDlg, $$editCAPTION, 0)
			NewChild ("button", "Message {Use | for tab}", $$BS_GROUPBOX, 8, 56, 234, 86, hDlg, $$grpMESSAGE, 0)
			NewChild ("edit", "Message", $$ES_LEFT | $$ES_AUTOVSCROLL | $$WS_TABSTOP | $$ES_MULTILINE | $$ES_WANTRETURN | $$WS_VSCROLL | $$WS_BORDER, 16, 74, 218, 58, hDlg, $$editMESSAGE, 0)

			NewChild ("button", "Buttons", $$BS_GROUPBOX, 8, 148, 234, 82, hDlg, $$grpBUTTONS, 0)
			NewChild ("button", "&Ok ", $$BS_AUTORADIOBUTTON | $$WS_TABSTOP, 18, 166, 84, 18, hDlg, $$rbtnOK, 0)
			NewChild ("button", "Ok-&Cancel ", $$BS_AUTORADIOBUTTON , 18, 186, 84, 18, hDlg, $$rbtnOKCANCEL, 0)
			NewChild ("button", "Abort-Retry-I&gnore ", $$BS_AUTORADIOBUTTON , 18, 206, 120, 18, hDlg, $$rbtnA_R_I, 0)
			NewChild ("button", "Ye&s-No ", $$BS_AUTORADIOBUTTON, 142, 166, 84, 18, hDlg, $$rbtnYESNO, 0)
			NewChild ("button", "Yes-No-Cance&l ", $$BS_AUTORADIOBUTTON, 142, 186, 94, 18, hDlg, $$rbtnYESNOCANCEL, 0)
			NewChild ("button", "Retr&y-Cancel ", $$BS_AUTORADIOBUTTON, 142, 206, 94, 18, hDlg, $$rbtnRETRYCANCEL, 0)

			NewChild ("button", "Icon", $$BS_GROUPBOX, 254, 6, 138, 136, hDlg, $$grpICON, 0)
			NewChild ("static", "", $$SS_ICON, 258, 24, 32, 32, hDlg, 101, 0)
			hIcon1 = LoadIconA (NULL, $$IDI_ASTERISK)
			SendMessageA (GetDlgItem (hDlg, 101), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon1)

			NewChild ("static", "", $$SS_ICON, 290, 24, 32, 32, hDlg, 102, 0)
			hIcon2 = LoadIconA (NULL, $$IDI_EXCLAMATION)
			SendMessageA (GetDlgItem (hDlg, 102), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon2)

			NewChild ("static", "", $$SS_ICON, 322, 24, 32, 32, hDlg, 103, 0)
			hIcon3 = LoadIconA (NULL, $$IDI_QUESTION)
			SendMessageA (GetDlgItem (hDlg, 103), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon3)

			NewChild ("static", "", $$SS_ICON, 356, 24, 32, 32, hDlg, 104, 0)
			hIcon4 = LoadIconA (NULL, $$IDI_HAND)
			SendMessageA (GetDlgItem (hDlg, 104), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon4)

			NewChild ("button", "&No icon ", $$BS_AUTORADIOBUTTON | $$TABGROUP, 262, 82, 80, 18, hDlg, $$rbtnNO_ICON, 0)
			NewChild ("button", "&i ", $$BS_AUTORADIOBUTTON, 262, 62, 30, 18, hDlg, $$rbtnINFORMATION, 0)
			NewChild ("button", "&! ", $$BS_AUTORADIOBUTTON, 296, 62, 30, 18, hDlg, $$rbtnEXCLAMATION, 0)
			NewChild ("button", "&? ", $$BS_AUTORADIOBUTTON, 328, 62, 30, 18, hDlg, $$rbtnQUESTION, 0)
			NewChild ("button", "&x ", $$BS_AUTORADIOBUTTON, 362, 62, 28, 18, hDlg, $$rbtnERROR, 0)
			NewChild ("button", "&Resource icon ", $$BS_AUTORADIOBUTTON, 262, 102, 120, 18, hDlg, $$rbtnUSER_ICON, 0)
			EnableWindow (GetDlgItem (hDlg, $$rbtnUSER_ICON), 0)

			NewChild ("button", "Copy and &Paste", $$BS_PUSHBUTTON | $$TABGROUP, 254, 156, 138, 22, hDlg, $$pbtnSAVE, 0)
			NewChild ("button", "&Try", $$BS_PUSHBUTTON | $$TABGROUP, 254, 182, 138, 22, hDlg, $$pbtnTEST, 0)
			NewChild ("button", "Exit", $$BS_PUSHBUTTON | $$TABGROUP, 254, 208, 138, 22, hDlg, $$pbtnEXIT, 0)

			NewChild ("button", "Default", $$BS_GROUPBOX, 8, 242, 136, 86, hDlg, $$grpDEFAULT, 0)
			NewChild ("button", "&Button one ", $$BS_AUTORADIOBUTTON | $$TABGROUP, 18, 260, 120, 18, hDlg, $$rbtnDefButton1, 0)
			NewChild ("button", "Button t&wo ", $$BS_AUTORADIOBUTTON, 18, 280, 120, 18, hDlg, $$rbtnDefButton2, 0)
			NewChild ("button", "Button t&hree ", $$BS_AUTORADIOBUTTON, 18, 300, 120, 18, hDlg, $$rbtnDefButton3, 0)

			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 0)
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 0)

			NewChild ("button", "Behavior", $$BS_GROUPBOX, 156, 242, 136, 86, hDlg, $$grpBEHAVIOR, 0)
			NewChild ("button", "&ApplModal ", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 174, 260, 110, 18, hDlg, $$rbtnDefStyle1, 0)
			NewChild ("button", "SystemMo&dal ", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 174, 280, 110, 18, hDlg, $$rbtnDefStyle2, 0)
			NewChild ("button", "Top&Most ", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 174, 300, 110, 18, hDlg, $$rbtnDefStyle3, 0)

			NewChild ("button", "Result", $$BS_GROUPBOX, 304, 242, 88, 86, hDlg, $$grpRESULT, 0)
			NewChild ("static", "", $$SS_CENTER, 314, 280, 68, 18, hDlg, $$lblRESULT, 0)

			NewChild ("button", "Type", $$BS_GROUPBOX, 8, 338, 384, 44, hDlg, $$grpTYPE, 0)
			NewChild ("button", "MessageBo&x ", $$BS_AUTORADIOBUTTON | $$TABGROUP, 18, 356, 100, 18, hDlg, $$rbtnMSB, 0)
			NewChild ("button", "MessageBo&xIndirect ", $$BS_AUTORADIOBUTTON, 120, 356, 130, 18, hDlg, $$rbtnMSBI, 0)

			NewChild ("button", "Code", $$BS_GROUPBOX, 8, 388, 384, 144, hDlg, $$grpCODE, 0)
			NewChild ("edit", "Output code", $$ES_MULTILINE | $$ES_WANTRETURN | $$ES_AUTOVSCROLL | $$WS_BORDER | $$WS_VSCROLL | $$WS_TABSTOP, 16, 406, 368, 116, hDlg, $$ViewMsgBoxText, 0)

			' set gui font in all controls
			hFont = GetStockObject ($$DEFAULT_GUI_FONT)
			FOR i = $$MBB_START TO $$MBB_END
				SetNewFont (GetDlgItem (hDlg, i), hFont)
			NEXT i

			' set default selections
			SetCheckBox (GetDlgItem(hDlg, $$rbtnOK))
			WHICH_BUTTONS = $$rbtnOK
			SetCheckBox (GetDlgItem(hDlg, $$rbtnNO_ICON))
			WHICH_ICON = $$rbtnNO_ICON
			SetCheckBox (GetDlgItem(hDlg, $$cbtnCONSTANTS))
			SetCheckBox (GetDlgItem(hDlg, $$rbtnDefButton1))
			SetCheckBox (GetDlgItem(hDlg, $$rbtnMSB))
			WHICH_TYPE = $$rbtnMSB

			' set icon in title bar
			hIconApp = ImageList_GetIcon (hImlHot, 121, $$ILD_TRANSPARENT)
			SendMessageA (hDlg, $$WM_SETICON, $$ICON_SMALL, hIconApp)
			SendMessageA (hDlg, $$WM_SETICON, $$ICON_BIG, hIconApp)

			MsgBoxBuildString$ (hDlg, msg$, caption$, style)

			SetFocus (GetDlgItem (hDlg, $$editCAPTION))

			RETURN ($$FALSE)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			ID         = LOWORD(wParam)
			hCtl    	 = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SetCheckBox (hCtl)
					SELECT CASE ID :

						CASE $$IDCANCEL, $$pbtnEXIT :			' window close/exit button pressed
							EndDialog (hDlg, ID)

						CASE $$rbtnOK, $$rbtnOKCANCEL, $$rbtnA_R_I, $$rbtnYESNO, $$rbtnYESNOCANCEL, $$rbtnRETRYCANCEL:
							MsgBoxButtonType (hDlg, ID)

						CASE $$rbtnINFORMATION, $$rbtnEXCLAMATION, $$rbtnQUESTION, $$rbtnERROR, $$rbtnNO_ICON, $$rbtnUSER_ICON :
							MsgBoxIcon (hDlg, ID)

						CASE $$rbtnDefButton1, $$rbtnDefButton2, $$rbtnDefButton3 :
							MsgBoxButtonDefault (hDlg, ID)

						CASE $$rbtnDefStyle1, $$rbtnDefStyle2, $$rbtnDefStyle3 :
							MsgBoxBehavior (hDlg, ID)

						CASE $$rbtnMSB, $$rbtnMSBI :
							MsgBoxType (hDlg, ID)

						CASE $$pbtnSAVE :
							MsgBoxToClipBoard (hDlg)

						CASE $$pbtnTEST :
							MsgBoxTry (hDlg)

					END SELECT
			END SELECT

		CASE ELSE :	RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

END FUNCTION

FUNCTION MsgBoxButtonType (hDlg, ID)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

	WHICH_BUTTONS = ID

  SELECT CASE ID
    CASE $$rbtnOK :
			SetCheckBox (GetDlgItem(hDlg, $$rbtnDefButton1))
			UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton2))
			UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton3))
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 0)
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 0)

    CASE $$rbtnOKCANCEL, $$rbtnYESNO, $$rbtnRETRYCANCEL
			IF IsChecked (GetDlgItem (hDlg, $$rbtnDefButton3)) THEN
				SetCheckBox (GetDlgItem(hDlg, $$rbtnDefButton2))
				UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton1))
				UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton3))
			END IF
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 1)
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 0)

    CASE $$rbtnA_R_I, $$rbtnYESNOCANCEL
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 1)
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 1)
  END SELECT

	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
	SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION

FUNCTION MsgBoxBuildString$ (hDlg, msg$, caption$, style)
' builds code & saves to the clipboard

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

	$CRLF = "\\r\\n"
	$TAB = "\\t"
	$DQ = "\""

	style$ = ""
	style = 0

	caption$ = NULL$(256)
	GetWindowTextA (GetDlgItem (hDlg, $$editCAPTION), &caption$, LEN(caption$))
	caption$ = CSIZE$(caption$)

	msg$ = NULL$(4096)
	GetWindowTextA (GetDlgItem (hDlg, $$editMESSAGE), &msg$, LEN(msg$))
	msg$ = TRIM$(CSIZE$(msg$))

	' Handle multiline message CRLF and Tabs
	DO
	LOOP UNTIL XstReplace (@msg$, "\r\n", $CRLF, 0) <= 0

	DO
	LOOP UNTIL XstReplace (@msg$, "|", $TAB, 0) <= 0

	GOSUB GetConstants

	SELECT CASE WHICH_TYPE
		CASE $$rbtnMSB :
      to_clipboard$ = "ret = MessageBoxA (hWnd, " + "&" + $DQ + msg$ + $DQ + ", " + "&" + $DQ + caption$ + $DQ + ", "
      IF style$ THEN
				to_clipboard$ = to_clipboard$ + style$ + ")"
			ELSE
				to_clipboard$ = to_clipboard$ + "0" + ")"
			END IF

    CASE $$rbtnMSBI   		' MessageBoxIndirect
      IF WHICH_ICON = $$rbtnUSER_ICON THEN
        buffer$ = "  mbp.dwStyle            = " + style$ + "\r\n" + _
			            "  mbp.lpszIcon           = $ID_ICON"
				id$ = "  $ID_ICON = 100"
      ELSE
        buffer$ = "  mbp.dwStyle            = " + style$ + "\r\n" + _
                  "  mbp.lpszIcon           = 0"
				id$ = ""
      END IF

      to_clipboard$ = _
                  "  MSGBOXPARAMS mbp"                    + "\r\n" + _
		              id$                                     + "\r\n" + _
                  "  caption$ = " + $DQ + caption$  + $DQ + "\r\n" + _
                  "  message$ = " + $DQ + msg$      + $DQ + "\r\n" + _
                  "  mbp.cbSize             = SIZE (mbp)" + "\r\n" + _
									"  mbp.hwndOwner          = hWnd"       + "\r\n" + _
                  "  mbp.hInstance          = GetModuleHandle (0)" + "\r\n" + _
                  "  mbp.lpszCaption        = &caption$"  + "\r\n" + _
                  "  mbp.lpszText           = &message$"  + "\r\n" + _
                  buffer$ + "\r\n" + _
                  "  mbp.dwContextHelpId    = 0"          + "\r\n" + _
                  "  mbp.lpfnMsgBoxCallback = 0"          + "\r\n" + _
                  "  mbp.dwLanguageId       = 0"          + "\r\n" + _
									"  ret = MessageBoxIndirect (&mbp)"

	END SELECT

	SetWindowTextA (GetDlgItem (hDlg, $$ViewMsgBoxText), &to_clipboard$)

	RETURN to_clipboard$

SUB GetConstants

	SELECT CASE WHICH_ICON
		CASE $$rbtnINFORMATION :
			style$ = "$$MB_ICONINFORMATION"
			style = $$MB_ICONINFORMATION
    CASE $$rbtnEXCLAMATION :
      style$ = "$$MB_ICONEXCLAMATION"
			style = $$MB_ICONEXCLAMATION
    CASE $$rbtnQUESTION :
      style$ = "$$MB_ICONQUESTION"
			style = $$MB_ICONQUESTION
    CASE $$rbtnERROR :
      style$ = "$$MB_ICONERROR"
			style = $$MB_ICONERROR
    CASE $$rbtnNO_ICON :
      style$ = ""
			style = 0
    CASE $$rbtnUSER_ICON :
      style$ = "$$MB_USERICON"
			style = $$MB_USERICON
	END SELECT

	IF style$ THEN AddOr$ = " | " ELSE AddOr$ = ""

	SELECT CASE WHICH_BUTTONS
		CASE $$rbtnOK :
			style$ = style$ + AddOr$ + "$$MB_OK"
			style = style | $$MB_OK
		CASE $$rbtnOKCANCEL :
			style$ = style$ + AddOr$ + "$$MB_OKCANCEL"
			style = style | $$MB_OKCANCEL
		CASE $$rbtnA_R_I :
			style$ = style$ + AddOr$ + "$$MB_ABORTRETRYIGNORE"
			style = style | $$MB_ABORTRETRYIGNORE
		CASE $$rbtnYESNO :
			style$ = style$ + AddOr$ + "$$MB_YESNO"
			style = style | $$MB_YESNO
		CASE $$rbtnYESNOCANCEL :
			style$ = style$ + AddOr$ + "$$MB_YESNOCANCEL"
			style = style | $$MB_YESNOCANCEL
		CASE $$rbtnRETRYCANCEL :
			style$ = style$ + AddOr$ + "$$MB_RETRYCANCEL"
			style = style | $$MB_RETRYCANCEL
	END SELECT

  IF style$ THEN AddOr$ = " | " ELSE AddOr$ = ""

	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefButton2)) THEN
		style$ = style$ + AddOr$ + "$$MB_DEFBUTTON2"
		style = style | $$MB_DEFBUTTON2
	END IF

	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefButton3)) THEN
		style$ = style$ + AddOr$ + "$$MB_DEFBUTTON3"
		style = style | $$MB_DEFBUTTON3
	END IF

	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefStyle1)) THEN
		style$ = style$ + AddOr$ + "$$MB_APPLMODAL"
		style = style | $$MB_APPLMODAL
	END IF

	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefStyle2)) THEN
		style$ = style$ + AddOr$ + "$$MB_SYSTEMMODAL"
		style = style | $$MB_SYSTEMMODAL
	END IF

	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefStyle3)) THEN
		style$ = style$ + AddOr$ + "$$MB_TOPMOST"
		style = style | $$MB_TOPMOST
	END IF
END SUB

END FUNCTION

FUNCTION MsgBoxIcon (hDlg, ID)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

  WHICH_ICON = ID

	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION

FUNCTION MsgBoxButtonDefault (hDlg, ID)

	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION

FUNCTION MsgBoxBehavior (hDlg, ID)

	IF ID = $$rbtnDefStyle1 THEN UnCheckBox (GetDlgItem (hDlg, $$rbtnDefStyle2))
	IF ID = $$rbtnDefStyle2 THEN UnCheckBox (GetDlgItem (hDlg, $$rbtnDefStyle1))
	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION


FUNCTION MsgBoxType (hDlg, ID)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

	WHICH_TYPE = ID

  IF WHICH_TYPE = $$rbtnMSBI THEN
		EnableWindow (GetDlgItem (hDlg, $$rbtnUSER_ICON), 1)
  ELSE
	  EnableWindow (GetDlgItem (hDlg, $$rbtnUSER_ICON), 0)
    IF WHICH_ICON = $$rbtnUSER_ICON THEN
      WHICH_ICON = $$rbtnNO_ICON
      UnCheckBox (GetDlgItem (hDlg, $$rbtnUSER_ICON))
      SetCheckBox (GetDlgItem (hDlg, $$rbtnNO_ICON))
    END IF
  END IF

 	MsgBoxBuildString$ (hDlg, msg$, caption$, style)

END FUNCTION

FUNCTION MsgBoxToClipBoard (hDlg)

	UBYTE image[]

	' copy text to clipboard
	m$ = MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	XstSetClipboard (1, @m$, @image[])

	' paste text to current cursor location
	pos = SendMessageA (GetEdit (), $$SCI_GETCURRENTPOS, 0, 0)
	SendMessageA (GetEdit (), $$SCI_INSERTTEXT, pos, &m$)
	SendMessageA (GetEdit (), $$SCI_SETCURRENTPOS, pos+1, 0)

END FUNCTION

FUNCTION MsgBoxTry (hDlg)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE
	$CRLF = "\\r\\n"
	$TAB = "\\t"

 ' Displays msgbox as currently designed

	MSGBOXPARAMS mbp
	$ID_ICON = 100

	MsgBoxBuildString$ (hDlg, @msg$, @caption$, @style)

	DO
	LOOP UNTIL XstReplace (@msg$, $CRLF, "\r\n", 0) <= 0

	DO
	LOOP UNTIL XstReplace (@msg$, $TAB, "\t", 0) <= 0


	SELECT CASE WHICH_TYPE

		CASE $$rbtnMSB :
			ret = MessageBoxA (hDlg, &msg$, &caption$, style)

		CASE $$rbtnMSBI :
			mbp.cbSize      				= SIZE(mbp)
			mbp.hwndOwner   				= hDlg
			mbp.hInstance   				= GetModuleHandleA (0)
			mbp.lpszCaption 				= &caption$
			mbp.lpszText    				= &msg$
			IF WHICH_ICON = $$rbtnUSER_ICON THEN 			' $$MB_USERICON
				mbp.lpszIcon 						= $ID_ICON
			ELSE
				mbp.lpszIcon 						= 0
			END IF
			mbp.dwStyle 						= style
			mbp.dwContextHelpId    	= 0
			mbp.lpfnMsgBoxCallback 	= 0
			mbp.dwLanguageId       	= 0
			ret = MessageBoxIndirectA (&mbp)

  END SELECT

  SELECT CASE ret
    CASE $$IDOK     :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDOK")
    CASE $$IDCANCEL :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDCANCEL")
    CASE $$IDABORT  :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDABORT")
    CASE $$IDRETRY  :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDRETRY")
    CASE $$IDIGNORE :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDIGNORE")
    CASE $$IDYES    :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDYES")
    CASE $$IDNO     :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDNO")
  END SELECT

END FUNCTION
'
' ################################
' #####  RecordMacroCommand  #####
' ################################
'
'
'
FUNCTION RecordMacroCommand (SCNotification scn)

		t$ = ""
		t$ = CSTRING$(scn.lParam)
		IF t$ THEN
			' format : "<message>;<wParam>;1;<text>"
			szMessage$ = NULL$(50 + LEN(t$) + 4)
			sprintf (&szMessage$, &"%d,%ld,1,%s", scn.message, scn.wParam, &t$)
		ELSE
			' format : "<message>;<wParam>;0;"
			szMessage$ = NULL$(50)
			sprintf (&szMessage$, &"%d,%ld,0", scn.message, scn.wParam)
		END IF
		szMessage$ = CSIZE$(szMessage$)
		RETURN OnMacro ("record", szMessage$)

END FUNCTION
'
' #####################
' #####  OnMacro  #####
' #####################
'
'
'
FUNCTION OnMacro (command$, params$)

'	PRINT "OnMacro: "; command$, params$

	IF command$ THEN
		SELECT CASE command$
			CASE "record" 		: MacroAppend (params$)
			CASE "run" 				: MacroIterate ()
		END SELECT
	RETURN ($$TRUE)
	END IF

END FUNCTION
'
' #########################
' #####  MacroAppend  #####
' #########################
'
'
'
FUNCTION MacroAppend (params$)

	SHARED macro$[], macroCount

	IF params$ THEN
		INC macroCount
		REDIM macro$[macroCount]
		macro$[macroCount] = params$
	END IF

END FUNCTION
'
'
' ##########################
' #####  MacroIterate  #####
' ##########################
'
'
'
FUNCTION MacroIterate ()

	SHARED macro$[]

	IFZ macro$[] THEN RETURN

	' begin undo action
	hEdit = GetEdit ()
	IF hEdit THEN
		SendMessageA (hEdit, $$SCI_BEGINUNDOACTION, 0, 0)

		upp = UBOUND(macro$[])
		FOR i = 0 TO upp
			msg$ = macro$[i]
			MacroGetParams (msg$, @message, @wParam, @lParam, @text$)
			IF lParam THEN
				SendMessageA (hEdit, message, wParam, &text$)
			ELSE
				SendMessageA (hEdit, message, wParam, 0)
			END IF
		NEXT i

		' end undo action
		SendMessageA (hEdit, $$SCI_ENDUNDOACTION, 0, 0)
	END IF


END FUNCTION
'
' ############################
' #####  MacroGetParams  #####
' ############################
'
'
'
FUNCTION MacroGetParams (msg$, @message, @wParam, @lParam, @text$)

' format : "<message>;<wParam>;1;<text>"  ' when lParam is 1, then text is available
' or
' format : "<message>;<wParam>;0					' lParam is 0

	message = 0
	wParam = 0
	lParam = 0
	text$ = ""

	message$ = XstNextItem$ (msg$, @index, @term, @done)
	IF !done THEN wParam$ = XstNextItem$ (msg$, @index, @term, @done)
	IF !done THEN lParam$ = XstNextItem$ (msg$, @index, @term, @done)
	IF lParam$ = "1" THEN
		IF !done THEN text$ = RIGHT$ (msg$, LEN(msg$) - (index - 1))
	END IF

	IF message$ THEN message = XLONG(message$)
	IF wParam$ THEN wParam = XLONG(wParam$)
	IF lParam$ THEN lParam = XLONG(lParam$)

END FUNCTION
'
' #######################
' #####  MacroInit  #####
' #######################
'
'
'
FUNCTION MacroInit ()

	SHARED macro$[], macroCount

	macroCount = -1
	DIM macro$[]

END FUNCTION
'
' ############################
' #####  MacroCheckMenu  #####
' ############################
'
'
'
FUNCTION MacroCheckMenu ()

	SHARED fRecording

	EnableAMenuItem ($$IDM_MACROPLAY, !fRecording)
	EnableAMenuItem ($$IDM_MACRORECORD, !fRecording)
	EnableAMenuItem ($$IDM_MACROSTOPRECORD, fRecording)

END FUNCTION
'
' #############################
' #####  EnableAMenuItem  #####
' #############################
'
'
'
FUNCTION EnableAMenuItem (IDItem, val)

	SHARED hWndMain

	IF (val) THEN
		EnableMenuItem (GetMenu (hWndMain), IDItem, $$MF_ENABLED | $$MF_BYCOMMAND)
	ELSE
		EnableMenuItem (GetMenu (hWndMain), IDItem, $$MF_DISABLED | $$MF_GRAYED | $$MF_BYCOMMAND)
	END IF

END FUNCTION

'
'
' ################################
' #####  AddTreeViewItem ()  #####
' ################################
'
FUNCTION AddTreeViewItem (hwndCtl, hParent, label$, idxImage, idxSelectedImage, hInsertAfter, data)

	TV_INSERTSTRUCT tvis
	TV_ITEM tvi

	tvi.mask 						= $$TVIF_TEXT | $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_PARAM
	tvi.pszText 				= &label$
	tvi.cchTextMax 			= LEN(label$)
	tvi.iImage 					= idxImage
	tvi.iSelectedImage 	= idxSelectedImage
	tvi.lParam          = data

	tvis.hParent 				= hParent
	tvis.hInsertAfter 	= hInsertAfter
	tvis.item 					= tvi

	RETURN SendMessageA (hwndCtl, $$TVM_INSERTITEM, 0, &tvis)

END FUNCTION
'
'
' #####################################
' #####  GetTreeViewSelection ()  #####
' #####################################
'
FUNCTION GetTreeViewSelection (hwndCtl)

RETURN SendMessageA (hwndCtl, $$TVM_GETNEXTITEM, $$TVGN_CARET, 0)

END FUNCTION
'
'
' ####################################
' #####  GetTreeViewItemText ()  #####
' ####################################
'
FUNCTION GetTreeViewItemText (hwndCtl, hItem, @text$)

	TV_ITEM	tvi

	tvi.mask = $$TVIF_TEXT | $$TVIF_HANDLE
	tvi.hItem = hItem
	text$ = NULL$(256)
	tvi.pszText = &text$
	tvi.cchTextMax = 256

	SendMessageA (hwndCtl, $$TVM_GETITEM, 0, &tvi)
	text$ = CSIZE$(text$)

END FUNCTION
'
' ##############################
' #####  ResetTreeBrowser  #####
' ##############################
'
'
'
FUNCTION ResetTreeBrowser ()

	SHARED hTreeBrowser
	DeleteAllTreeViewItems (hTreeBrowser)

END FUNCTION
'
' ################################
' #####  SelectTreeViewItem  #####
' ################################
'
'
'
FUNCTION SelectTreeViewItem (hTree, hItem)

	RETURN SendMessageA (hTree, $$TVM_SELECTITEM, $$TVGN_CARET, hItem)

END FUNCTION
'
' #################################
' #####  GetTreeViewNextItem  #####
' #################################
'
' Return the handle to an item based on its index in tree
'
FUNCTION GetTreeViewNextItem (hTree, index)

	' use 0 index for root
	hItem = SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_ROOT, 0)
	IF index = 0 THEN RETURN hItem

	FOR i = 1 TO index
		hItem = SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_NEXT, hItem)
	NEXT i

	RETURN hItem

END FUNCTION
'
' #################################
' #####  GetTreeViewItemData  #####
' #################################
'
'
'
FUNCTION GetTreeViewItemData (hwndCtl, hItem, @data)

	TV_ITEM	tvi

	tvi.mask = $$TVIF_PARAM	 | $$TVIF_HANDLE
	tvi.hItem = hItem

	SendMessageA (hwndCtl, $$TVM_GETITEM, 0, &tvi)
	data = tvi.lParam

END FUNCTION
'
' ####################################
' #####  DeleteAllTreeViewItems  #####
' ####################################
'
'
'
FUNCTION DeleteAllTreeViewItems (hTree)

	IFZ hTree THEN RETURN

	' don't redraw the control until all nodes are deleted
	SendMessageA (hTree, $$WM_SETREDRAW, 0, 0 )

	' delete all treeview nodes
	DO
    hItem = SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_ROOT, 0)
    IF hItem > 0 THEN
      SendMessageA (hTree, $$TVM_DELETEITEM, 0, hItem)
    ELSE
      EXIT DO
    END IF
  LOOP

	' redraw control
	SendMessageA (hTree, $$WM_SETREDRAW, 1, 0)

END FUNCTION
'
' ##############################
' #####  FindTreeViewNode  #####
' ##############################
'
' Search for text$ in treeview nodes
'
FUNCTION FindTreeViewNode (hTree, hItem, text$)

	TV_ITEM item

  IF (hItem == NULL) THEN
    hItem = SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_ROOT, 0)
	END IF

  DO WHILE (hItem != NULL)
    szBuffer$ = NULL$(128)
    item.hItem = hItem
    item.mask = $$TVIF_TEXT | $$TVIF_CHILDREN
    item.pszText = &szBuffer$
    item.cchTextMax = LEN(szBuffer$)
    SendMessageA (hTree, $$TVM_GETITEM, 0, &item)

		szBuffer$ = CSIZE$(szBuffer$)
		IF szBuffer$ = text$ THEN RETURN hItem

    ' Check whether we have child items.
    IF (item.cChildren) THEN
'     mb("1");  //Messagebox function - need something else really...
'     SendMessageA (hTree, $$TVM_EXPAND, $$TVE_EXPAND, hItem)
      ' Recursively traverse child items.
      hItemChild = SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_CHILD, hItem)
      hItemFound = FindTreeViewNode (hTree, hItem, text$)
      ' Did we find it?
      IF (hItemFound != NULL) THEN RETURN hItemFound
    END IF
    ' Go to next sibling item.
    hItem = SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_NEXT, hItem)
  LOOP
  ' Not found.
  RETURN
END FUNCTION
'
' #################################
' #####  SetTreeViewItemData  #####
' #################################
'
' Set the lParam data member of treeview item
'
FUNCTION SetTreeViewItemData (hTree, hItem, data)

	TV_ITEM	tvi

	tvi.mask = $$TVIF_PARAM	 | $$TVIF_HANDLE
	tvi.hItem = hItem
	tvi.lParam = data

	SendMessageA (hTree, $$TVM_SETITEM, 0, &tvi)
END FUNCTION

END PROGRAM
