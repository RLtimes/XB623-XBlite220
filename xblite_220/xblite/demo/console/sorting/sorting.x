'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A Comparison of Various Sorting Algorithms
' ------------------------------------------
' Updated 2001/02 by David Szafranski
' I found this demo on the newsgroup alt.lang.basic
' and have updated it to run on XB. It was
' originally written/posted by Edward Collins.
' I have added several other sorting algorithms.
'--
' This demo compares the times to sort a numeric
' array using a variety of sorting algorithms:
'--
' Bubble Sort, Exchange Sort, Heap Sort,
' Insertion Sort, QSort (iterative),
' Shell Sort, XBasic's XstQuickSort(), QuickSort,
' Comb Sort, Merge Sort, and Radix Sort.
'--
' The number of items to sort is held in
' the variable "nmbrOfItems".
'--
' The program displays the sorting timing
' results to the console.
'--
' The array "test[]" is sorted starting
' with element 0.
'--
' The sorting algorithms are timed using
' the XstGetSystemTime() function
' which has a resolution of around 5 msec.
'--
' If you have an fast PIII+, then you may
' want to increase the number of items to
' be sorted from 100000 to a larger number
' to increase the total calculation time.
'--
' For each algorithm, four types of arrays
' are sorted:
' 1. The "already sorted" array is just
'    that... already sorted.
'
' 2. The "complete opposite" array is in the
'    exact opposite order from what is desired.
'
' 3. The "random mixup" array is like a
'    well-shuffled deck of cards.

' 4. The "nearly sorted" array is sorted for
'    the first 90% of the array.  However, the
'    final 10% that need to be sorted.
'--
'
' To add your own algorithm.... in Entry()...
'----------------------------------------------
'  1) Increase the variable "nmbrOfAlgorithms".
'  2) Add/name your algorithm in algorithm$[].
'  3) Add your own sort function for it. The
'     array named "test[]" holds the data to sort.
'  4) Add/call this new function from the
'     SELECT CASE algorithm.
'--
' Discussion
' -----------------------------------------------------------------
'	Which sorting algorithm is the fastest? Ask
' this question to any group of programmers and
' you'll get an animated discussion. Of course,
' there is no one answer. It depends not only on
' the algorithm, but also on the computer, data,
' and implementation.
'--
' Recursive QuickSorts are very quick sorting
' algorithms. In this group, the fastest seem
' to be FastQSort and RadixSort2. When combined
' with Insertion Sort, MergeSort can be very
' fast as well.
'
PROGRAM	"sorting"
VERSION	"0.0002"
CONSOLE
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"xsx"		' Standard extended library
	IMPORT	"kernel32"

EXPORT
DECLARE FUNCTION  Entry ()

' ***** Sorting Functions *****

DECLARE FUNCTION  BubbleSort (out[])
DECLARE FUNCTION  BubbleSortExt1 (out[])
DECLARE FUNCTION  BubbleSortExt2 (out[])
DECLARE FUNCTION  CombSort (out[])
DECLARE FUNCTION  ExchangeSort (out[])
DECLARE FUNCTION  FastQSort (out[])
DECLARE FUNCTION  HeapSort (out[])
DECLARE FUNCTION  InsertionSort (out[], lo, hi)
DECLARE FUNCTION  MergeSort (out[])
DECLARE FUNCTION  QSort (out[])
DECLARE FUNCTION  QuickSort (out[], inLow, inHi)
DECLARE FUNCTION  RadixSort (ULONG out[])
DECLARE FUNCTION  ShellSort (out[])

END EXPORT

' ***** Supporting Functions *****

INTERNAL FUNCTION  DOUBLE RandomN (n)
INTERNAL FUNCTION  CreateTestArray (type, count, XLONG test[])
INTERNAL FUNCTION  MSort (out[], tmpA[], left, right)
INTERNAL FUNCTION  Radix (SSHORT bitsOffset, XLONG N, XLONG out[], XLONG dest[])
INTERNAL FUNCTION  FQSort (ANY out[], l, r)
DECLARE FUNCTION  IsSorted (ANY array[])
DECLARE FUNCTION  RadixSort2 (ULONG in[], ULONG out[])
DECLARE FUNCTION  XstQuickSort_XLONG (x[], n[], low, high, flags)
DECLARE FUNCTION  MergeSort2 (XLONG out[], XLONG lo, XLONG hi)
DECLARE FUNCTION  MergeSort3 (XLONG out[], XLONG left, XLONG right)
DECLARE FUNCTION  MergeSortVic (XLONG x[], XLONG low, XLONG high)
DECLARE FUNCTION  Merge2 (XLONG x[], XLONG low, XLONG m, XLONG high)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC XLONG test[]
	STATIC XLONG array[]
	STATIC nmbrOfItems
	DOUBLE sum

' Return if compiled as dll
	IF LIBRARY(0) THEN RETURN

	nmbrOfItems      	= 500000     	' change this depending on processor speed
	nmbrOfAlgorithms 	= 17    			' change this if you add another algorithm

	DIM results[3, nmbrOfAlgorithms-1]
	DIM algorithm$[nmbrOfAlgorithms-1]

	algorithm$[0] = "Bubble Sort           "
	algorithm$[1] = "Bubble Sort(Enhanced1)"
	algorithm$[2] = "Bubble Sort(Enhanced2)"
	algorithm$[3] = "Exchange Sort         "
	algorithm$[4] = "Heap Sort             "
	algorithm$[5] = "Insertion Sort        "
	algorithm$[6] = "QSort (iterative)     "
	algorithm$[7] = "Shell Sort            "
	algorithm$[8] = "XstQuickSort          "
	algorithm$[9] = "QuickSort (recursive) "
	algorithm$[10]= "CombSort              "
	algorithm$[11]= "MergeSort             "
	algorithm$[12]= "MergeSort2            "
	algorithm$[13]= "MergeSortVic          "
	algorithm$[14]= "RadixSort             "
	algorithm$[15]= "FastQSort (recursive) "
	algorithm$[16]= "RadixSort2            "

	PRINT "Working...";

	FOR type = 0 TO 3
		CreateTestArray (type, nmbrOfItems, @array[]) 		'create 4 types of arrays to sort
'		GOSUB PrintStartingArray    											'uncomment this to show starting array, do this only if array is small!

  	FOR algorithm = 0 TO nmbrOfAlgorithms-1
			XstCopyArray (@array[], @test[])								'use the same test[] array for all algorithms
			XstGetSystemTime (@start)       								'start timing

			SELECT CASE algorithm
				CASE 0 :	'BubbleSort (@test[])								'very slow, only test the BubbleSort on very small arrays! They are really SLOW!
				CASE 1 :	'BubbleSortExt1 (@test[])						'very slow
				CASE 2 :	'BubbleSortExt2 (@test[])						'very slow
				CASE 3 :	'ExchangeSort (@test[])							'slow
				CASE 4 :	HeapSort (@test[])
				CASE 5 :	'InsertionSort (@test[], 0, UBOUND(test[]))	'very slow except on arrays that are already or almost sorted
				CASE 6 :	QSort (@test[])
				CASE 7 :	ShellSort (@test[])
				CASE 8 :	DIM orderArray[]		' no order array, it's faster without it
									XstQuickSort (@test[], @orderArray[], 0, UBOUND(test[]), 0)
				CASE 9 :	QuickSort (@test[], 0, UBOUND(test[]))
				CASE 10:	CombSort (@test[])
				CASE 11:	MergeSort (@test[])
				CASE 12:	MergeSort2 (@test[], 0, UBOUND(test[]))
				CASE 13:	MergeSortVic (@test[], 0, UBOUND(test[]))
				CASE 14:	RadixSort (@test[])
				CASE 15:	FastQSort (@test[])
				CASE 16:	RadixSort2 (@test[], @out[])
			END SELECT

			XstGetSystemTime (@finish) 											'finish timing
			results[type, algorithm] = finish - start    		'total time elapsed
'			GOSUB PrintResultingArray   										'uncomment this to check the results
'			GOSUB VerifyIsSorted														'verify that resulting array is sorted correctly
      PRINT ".";
     NEXT algorithm
		PRINT ".";
	NEXT type

	PRINT ""
	GOSUB ShowResults

	PRINT
	a$ = INLINE$ ("Press RETURN to QUIT >")
	RETURN

' ***** ShowResults *****
SUB ShowResults

	PRINT " Comparison of Various Sorting Algorithms."
	PRINT " The times listed are the number of seconds that it"
	PRINT " takes to sort an array of "; nmbrOfItems; " elements."

	PRINT "========================================================================="
	PRINT "                         Already   Complete  Random    Nearly"
	PRINT "                         Sorted    Opposite  Mixup     Sorted     AVG"
	PRINT "========================================================================="

	FOR count = 0 TO nmbrOfAlgorithms-1
		PRINT algorithm$[count]; "  ";
		sum = 0
		FOR type = 0 TO 3
			PRINT FORMAT$("##.###", results[type, count]/1000.0);
      PRINT "    ";
      sum = sum + results[type, count]/1000.0
    NEXT type
    PRINT FORMAT$("##.###", sum/4.0);
    PRINT ""
	NEXT count
END SUB

' ***** PrintStartingArray *****
SUB PrintStartingArray
'	IF algorithm <> 13 THEN EXIT SUB
	upper = UBOUND(array[])
	FOR i = 0 TO upper
		PRINT array[i];
	NEXT i
	PRINT
END SUB


' ***** PrintResultingArray *****
SUB PrintResultingArray
'NOTE: it is probably not a good idea to try to print
'out large test arrays > 1000 elements
'	IF algorithm <> 15 THEN EXIT SUB

'	Copy radixsort array results to test[]
	PRINT "Array Type:"; type, "  Algorithm: "; algorithm$[algorithm]
	IF algorithm == 16 || algorithm == 17 THEN
		FOR i = 0 TO UBOUND(test[])
			PRINT out[i];
		NEXT i
	ELSE
		FOR i = 0 TO UBOUND(test[])
			PRINT test[i];
		NEXT i
	END IF
	PRINT
END SUB

' ***** VerifyIsSorted *****
SUB VerifyIsSorted
'	IF algorithm <> 5 THEN EXIT SUB
	IF algorithm == 16 || algorithm == 17 THEN
		IFZ IsSorted (@out[]) THEN
			PRINT algorithm$[algorithm]; " is not sorted correctly."
		END IF
	ELSE
		IFZ IsSorted (@test[]) THEN
			PRINT algorithm$[algorithm]; " is not sorted correctly."
		END IF
	END IF
END SUB


END FUNCTION
'
'
' ###########################
' #####  BubbleSort ()  #####
' ###########################

' ============================== Bubble Sort ===========================
' The Bubble Sort algorithm cycles through the array, comparing adjacent
' elements and swapping pairs that are out of order.
' ======================================================================
'
FUNCTION  BubbleSort (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	FOR a = 0 TO upper-1
		FOR b = 0 TO upper-1
			IF out[b] > out[b + 1] THEN
				SWAP out[b], out[b + 1]
			END IF
		NEXT b
	NEXT a

	RETURN 1
END FUNCTION
'
'
' ###############################
' #####  BubbleSortExt1 ()  #####
' ###############################

' ============================== Bubble Sort Enhanced1 ==================
' The Bubble Sort algorithm cycles through the array, comparing adjacent
' elements and swapping pairs that are out of order.  It continues to
' do this until no pairs are swapped.
' ======================================================================
'
FUNCTION  BubbleSortExt1 (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	flag  = 0

	DO WHILE flag = 0
  	flag = 1            						'this flag is what makes it "enhanced"
		FOR count = 0 TO upper-1
			IF out[count] > out[count + 1] THEN
				SWAP out[count], out[count + 1]
        flag = 0
			END IF
		NEXT count
	LOOP

	RETURN 1
END FUNCTION
'
'
' ###############################
' #####  BubbleSortExt1 ()  #####
' ###############################

' ============================== Bubble Sort Enhanced2 ===============
' The Bubble Sort algorithm cycles through the array, comparing adjacent
' elements and swapping pairs that are out of order.  After the inside
' FOR loop finishes for the first time, the largest element is positioned
' in it's proper place.  Therefore we don't ever have to compare that
' number anymore.  So for that next cycle, we have one less element to
' compare each time.  This is the enhancement over the previous two
' Bubble Sorts.
' ======================================================================
'
FUNCTION  BubbleSortExt2 (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	flag = 0
	FOR a = upper TO 0 STEP -1
		flag = 1
		FOR b = 1 TO a
			IF out[b - 1] > out[b] THEN
				SWAP out[b - 1], out[b]
				flag = 0
			END IF
		NEXT b
		IFT flag THEN EXIT FOR
	NEXT a

	RETURN 1
END FUNCTION
'
'
' #########################
' #####  CombSort ()  #####
' #########################

'========================== CombSort ==================================
' CombSort is a fairly fast algorithm and simpler than
' QuickSort. In the April 1991 issue of BYTE magazine, Stephen Lacey
' and Richard Box show that a simple modification to bubble sort makes
' it a fast and efficient sort method on par with heapsort and quicksort.

' In a bubble sort, each item is compared to the next; if the two are
' out of order, they are swapped. This method is slow because it
' is susceptible to the appearance of what Box and Lacey call turtles.
' A turtle is a relatively low value located near the end of the
' table. During a bubble sort, this element moves only one position
' for each pass, so a single turtle can cause maximal slowing.
' Almost every long table of items contains a turtle.

' Their simple modification of bubble sort which they call `combsort'
' eliminates turtles quickly by allowing the distance between
' compared items to be greater than one. This distance - the JUMP-SIZE -
' is initially set to the TABLE-SIZE. Before each pass,
' the JUMP-SIZE is divided by 1.3 (the shrink factor). If this causes it
' to become less than 1, it is simply set to 1, collapsing
' combsort into bubble sort. An exchange of items moves items by JUMP-SIZE
' positions rather than only one position, causing
' turtles to jump rather than crawl. As with any sort method where the
' displacement of an element can be larger than one position,
' combsort is not stable - like elements do not keep their relative
' positions. This is rarely a problem in practice.

' Successively shrinking the JUMP-SIZE is analogous to combing long,
' tangled hair - stroking first with your fingers alone, then with
' a pick comb that has widely spaced teeth, followed by finer combs
' with progressively closer teeth - hence the name comb sort.
' Lacey and Box came up with a shrink factor of 1.3 empirically by
' testing combsort on over 200,000 random tables. There is at
' present no theoretical justification for this particular value;
' it just works...
'=============================================================
'
FUNCTION  CombSort (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	gap = upper + 1

	DO WHILE (gap > 1 || swapFlag = $$TRUE)			' the list is sorted if gap = 1 and no swap occured

		gap = (10 * gap) / 13											' divide gap by 1.3 - the author says it's an empirical value
		IF gap < 1 THEN gap = 1										' gap must be at least one
		IF (gap = 9 || gap = 10) THEN gap = 11		' another empirical value
		swapFlag = $$FALSE												' no swap so far
		FOR i = 0 TO upper - gap
			IF (out[i]  > out[i + gap]) THEN				' in wrong order ?
				SWAP out[i], out[i+gap]               ' if the items are not in order, swap them
				swapFlag = $$TRUE											' remember that we swapped
			END IF
		NEXT
	LOOP

	RETURN 1
END FUNCTION
'
'
' #############################
' #####  ExchangeSort ()  #####
' #############################

' ============================= Exchange Sort ========================
' The Exchange Sort compares each element in the array, starting with
' the first element, with every following element.  If any of the
' following elements are smaller than the current element, it is
' exchanged with the current element and the process is repeated
' for the next element in the array.
' ====================================================================
'
FUNCTION  ExchangeSort (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	FOR a = 0 TO upper
		less = a
		FOR b = less+1 TO upper
			IF out[b] < out[less] THEN less = b
		NEXT b
		IF less > a THEN
			SWAP out[a], out[less]
		END IF
	NEXT a

	RETURN 1
END FUNCTION
'
'
' ##########################
' #####  FastQSort ()  #####
' ##########################

' This is a generic version of C.A.R Hoare's Quick Sort
' algorithm.  This will handle arrays that are already
' sorted, and arrays with duplicate keys, and also
' extended with TriMedian and InsertionSort.
' It uses TriMedian and InsertionSort for lists shorter than 4.
'
FUNCTION  FastQSort (@out[])

	FQSort(@out[], 0, UBOUND(out[]))
	InsertionSort(@out[], 0, UBOUND(out[]))

END FUNCTION
'
'
' #########################
' #####  HeapSort ()  #####
' #########################

' =============================== Heap Sort ===============================
'  The Heap Sort procedure works by calling two other procedures -
'  PercolateUp and PercolateDown.  PercolateUp turns the array into
'  a "heap," which has the properties outlined in the diagram below:
'
'                               theArray(0)
'                               /          \
'                    theArray(1)           theArray(2)
'                   /          \             /         \
'         theArray(3)   theArray(4)    theArray(5)  theArray(6)
'          /      \       /       \        /      \      /      \
'        ...      ...   ...       ...    ...      ...  ...      ...
'
'
'  where each "parent node" is greater than each of its "child nodes"; for
'  example, array(0) is greater than array(1) or array(2), array(2) is
'  greater than array(5) or array(6), and so forth.
'
'  Therefore, once the first FOR...NEXT loop in the Heap Sort is finished,
'  the largest element is in array(0).
'
'  The second FOR...NEXT loop in Heap Sort swaps the element in array(0)
'  with the element in nmbrOfItems, rebuilds the heap (with PercolateDown)
'  for nmbrOfItems, then swaps the element in array(0) with the element
'  in nmbrOfItems, rebuilds the heap for nmbrOfItems - 2, and
'  continues in this way until the array is sorted.
' =========================================================================
'
FUNCTION  HeapSort (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	FOR i = 1 TO upper
		GOSUB PercolateUp
	NEXT i

	FOR i = upper TO 1 STEP -1
		SWAP out[0], out[i]
		GOSUB PercolateDown
	NEXT i

' ***** PercolateDown *****

SUB PercolateDown
' ============================ Percolate Down ============================
' The PercolateDown procedure restores the elements of the array from 1
' to MaxLevel to a "heap" (see the diagram with the HeapSort procedure)
' ========================================================================
	maxlevel = i-1
	j = 0

' ----------------------------------------------------------------
' Move the value in the array(1) down the heap until it has reached
' its proper node (that is, until it is less than its parent node
' or until it has reached maxlevel, the bottom of the current heap)
' ----------------------------------------------------------------

	DO
		child = 2 * j             ' Get the subscript for the child node.

' Reached the bottom of the heap, so exit this procedure
		IF child > maxlevel THEN EXIT DO

' ----------------------------------------------------------
' If there are two child nodes, find out which one is bigger
' ----------------------------------------------------------
		IF (child + 1) <= maxlevel THEN
			IF out[child + 1] > out[child] THEN
				INC child
			END IF
		END IF

' ---------------------------------------------
' Move the value down if it is still not bigger
' than either one of its children
' ---------------------------------------------

		IF out[j] < out[child] THEN
			SWAP out[j], out[child]
			j = child

' -------------------------------------------
' Otherwise, the array has been restored to a
' heap from 1 to maxlevel, so exit:
' -------------------------------------------
		ELSE
			EXIT DO
		END IF
	LOOP
END SUB

' ***** PercolateUp *****

SUB PercolateUp
' ============================== Percolate Up ==============================
'   The PercolateUp procedure converts the elements from 1 to maxlevel in
'   the array into a "heap" (see the diagram with the HeapSort procedure).
' ==========================================================================
	maxlevel = i
	j = maxlevel

' --------------------------------------------------------------------
' Move the value in the array(maxlevel) up the heap until it has
' reached its proper node (that is, until it is greater than either
' of its child nodes, or until it has reached 1, the top of the heap)
' --------------------------------------------------------------------

	DO
		parent = j / 2            ' Get the subscript for the parent node.

' --------------------------------------------------------------------
' The value at the current node is still bigger than the value at
' its parent node, so swap these two array elements
' --------------------------------------------------------------------
		IF out[j] > out[parent] THEN
			SWAP out[parent], out[j]
			j = parent

' --------------------------------------------------------------------
' Otherwise, the element has reached its proper place in the heap,
' so exit this procedure
' --------------------------------------------------------------------
		ELSE
			EXIT DO
		END IF
	LOOP
END SUB

	RETURN 1

END FUNCTION
'
'
' ##############################
' #####  InsertionSort ()  #####
' ##############################
'
FUNCTION  InsertionSort (@out[], lo, hi)

	FOR i = lo+1 TO hi
		v = out[i]
		j = i
		DO WHILE out[j-1] > v
			out[j] = out[j-1]
			DEC j
			IF j = lo THEN EXIT DO
		LOOP
		out[j] = v
	NEXT i

END FUNCTION
'
'
' ##########################
' #####  MergeSort ()  #####
' ##########################

'========================== MergeSort ======================================
' MergeSort is a recursive sorting procedure that uses O(n log n)
' comparisons in the worst case. To sort an array of n elements,
' we perform the following three steps in sequence:

' * If n<2 then the array is already sorted. Stop now.
' * Otherwise, n>1, and we perform the following three steps in sequence:

'         1. Sort the left half of the the array.
'         2. Sort the right half of the the array.
'         3. Merge the now-sorted left and right halves.
'============================================================================
'
FUNCTION  MergeSort (XLONG out[])

	DIM tmp[UBOUND(out[])]
	MSort (@out[], @tmp[], 0, UBOUND(out[]))
	REDIM tmp[]

END FUNCTION
'
'
' ######################
' #####  QSort ()  #####
' ######################

' ============================== Qsort (iterative) =====================
' This algorithm is iterative instead of recursive, and fairs much better
' than the recursive version.  The algorithm is from Ethan Winer's 'BASIC
' Techniques and Utilities' (WINER.ZIP).
' The Quicksort version presented here avoids recursion, and instead uses
' a local array as a form of stack.  This array stores the upper and lower
' bounds showing which section of the array is currently being considered.
' Another refinement added is to avoid making a copy of elements in the
' array.  As the Quicksort progresses, it examines one element selected
' arbitrarily from the middle of the array, and compares it to the elements
' that lie above and below it.  To avoid assigning a temporary copy this
' version simply keeps track of the selected element number.
' =========================================================================
'
FUNCTION  QSort (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	first = 0
	last = upper
	zed = last/5 + 10
	REDIM QStack[zed]

	stackptr = 0
	DO
  	DO
			xVar = (last/2)+(first/2)
			temp = out[xVar]
			i = first: j = last
			DO
				DO WHILE out[i] < temp
					INC i
				LOOP

				DO WHILE out[j] > temp
					DEC j
				LOOP

				IF i > j THEN EXIT DO
				IF i < j THEN SWAP out[i], out[j]
				INC i
				DEC j

			LOOP WHILE i <= j

			IF i < last THEN
				QStack[stackptr] = i
				QStack[stackptr + 1] = last
				stackptr = stackptr + 2
			END IF

			last = j
		LOOP WHILE first < last

		IF stackptr = 0 THEN EXIT DO
		stackptr = stackptr - 2
		first = QStack[stackptr]
		last = QStack[stackptr + 1]
	LOOP

	REDIM QStack[]
	RETURN 1

END FUNCTION
'
'
' ##########################
' #####  QuickSort ()  #####
' ##########################

' ============================== QuickSort (recursive) ===================
' This is the standard recursive quick sort algorithm.
' Its operation is fairly straightforward: an item is chosen midway
' between two points in array() (called the pivot point). One value
' that is higher and one value that is lower than the pivot point is
' found and swapped, with the function calling itself passing new
' start and stop points. The method continues in this fashion until
' no elements meet these conditions, at which point the array is sorted.
' =========================================================================
'
FUNCTION  QuickSort (@out[], inLow, inHi)

	IFZ out[] THEN RETURN 0

	tmpLow = inLow
	tmpHi = inHi

	pivot = out[(inLow + inHi) / 2]

	DO WHILE (tmpLow <= tmpHi)

		DO WHILE (out[tmpLow] < pivot) && (tmpLow < inHi)
			INC tmpLow
		LOOP

		DO WHILE (pivot < out[tmpHi]) && (tmpHi > inLow)
			DEC tmpHi
		LOOP

		IF (tmpLow <= tmpHi) THEN
			SWAP out[tmpLow], out[tmpHi]
			INC tmpLow
			DEC tmpHi
		END IF

	LOOP

	IF (inLow < tmpHi) THEN QuickSort (@out[], inLow, tmpHi)
	IF (tmpLow < inHi) THEN QuickSort (@out[], tmpLow, inHi)

	RETURN 1

END FUNCTION
'
'
' ##########################
' #####  RadixSort ()  #####
' ##########################

'======================= RadixSort =================================
' Radix Sort is a multiple pass sort algorithm that distributes
' each item to a bucket according to part of the item's key
' beginning with the least significant part of the key.
' After each pass, items are collected from the buckets, keeping
' the items in order, then redistributed according to the next
' most significant part of the key.

' Note: This is the algorithm used by letter-sorting machines
' in the post office. Since keys are not compared against each
' other, sorting time is O(cn), where c depends on the size of
' the key and number of buckets. You have probably used a form
' of this if you sorted lots of papers alphabetically: you put
' each paper in its pile (or bucket), A's, B's, C's, D's, etc.,
' then sort each pile.

' Here is a simple example of the sort. Suppose the input keys
' are 34, 12, 42, 32, 44, 41, 34, 11, 32, and 23. Let's use four
' buckets. The first pass distributes them by the least significant
' digit. After the first pass we have the following, where each
' line is a bucket.

'41 11
'12 42 32 32
'23
'34 44 34

' We collect these up, keeping their relative order:
'41 11 12 42 32 32 23 34 44 34

' Now we distribute by the next most significant digit, in this case,
' the highest digit, and we get the following:

'11 12
'23
'32 32 34 34
'41 42 44

' When we collect them up, they are in order:

' 11 12 23 32 32 34 34 41 42 44.

' We can do better than sorting on one decimal digit at a time (r=10).
' It would likely be faster if we sort on two digits at a time
' (using a radix of r = 100) or even three (using a radix of r = 1000).
' Furthermore, there's no need to use decimal digits at all;
' on computers, it's more natural to choose a power-of-two radix
' like r = 256.  Base-256 "digits" are easier to extract from a key,
' because we can quickly pull out the eight bits (one byte) that we need.
'
' Thus, four byte passes are made for a ULONG integer (32-bits).
'===========================================================================
'
FUNCTION  RadixSort (ULONG out[])

	ULONG temp[], N
	N = UBOUND(out[]) + 1
	DIM temp[N]

	Radix (0, N, @out[], @temp[])
	Radix (8, N, @temp[], @out[])
	Radix (16, N, @out[], @temp[])
	Radix (24, N, @temp[], @out[])

	REDIM temp[]

END FUNCTION
'
'
' ##########################
' #####  ShellSort ()  #####
' ##########################

' =============================== Shell Sort ===============================
' The Shell Sort procedure is similar to the Bubble Sort procedure.
' However, the Shell Sort begins by comparing elements that are far apart
' (separated by the value of the offset variable, which is initially half
' the distance between the first and last element), then comparing elements
' that are closer together. (When offset is one, the last iteration of this
' procedure is merely a bubble sort.)
' =========================================================================
'
FUNCTION  ShellSort (@out[])

	IFZ out[] THEN RETURN 0
	upper = UBOUND(out[])

	center = upper / 2
	DO WHILE center > 0
		boundary = upper - center
		flag = 1
		DO WHILE flag <> 0
			flag = 0
			FOR a = 0 TO boundary
				IF out[a] > out[a + center] THEN
					SWAP out[a], out[a + center]
					flag = a
				END IF
			NEXT a
			boundary = flag - center
		LOOP
		center = center / 2
	LOOP

	RETURN 1

END FUNCTION
'
'
' ########################
' #####  RandomN ()  #####
' ########################

'returns a random whole number between 0 and n (inclusive)
'for example, if n is 9, then the function returns numbers from 0 to 9
'if n is 1, then the function returns 0 or 1
'if n is zero, then it returns a fractional random number between 0 and 1
'USE: rnd = RandomN(1)
'version 0.0003
'
FUNCTION  DOUBLE RandomN (n)

STATIC DOUBLE seed
STATIC DOUBLE t, return
STATIC STRING flag

	$c1=24298!
	$c2=99991!
	$c3=199017!

	IFZ flag THEN GOSUB InitialiseRNG

	t = ($c1 * seed + $c2)/$c3
	return = t - INT(t)
	seed = $c3 * return

	IF n > 0 THEN
		return = INT (return * (n+1))
		RETURN return
	ENDIF

	RETURN return

' ***** InitialiseRNG *****
SUB InitialiseRNG
	flag="RNG Initialised."
	XstGetDateAndTime ( @year, @month, @day, @weekDay, @hour, @minute, @second, @nanos)
	msec# = nanos/1.0d+6
	timeSeed# = ((((hour*60.0) + minute) * 60.0 + second) * 1000 + msec#) / 86400000.0
	seed = timeSeed# * $c3
END SUB
END FUNCTION
'
'
' ################################
' #####  CreateTestArray ()  #####
' ################################
'
FUNCTION  CreateTestArray (type, count, @test[])

	IFZ count THEN RETURN 0

'create 4 different types of test arrays

	nmbrOfItems = count
	upper = nmbrOfItems-1
	DIM test[upper]

	SELECT CASE type
		CASE 0 : GOSUB Type0
		CASE 1 : GOSUB Type1
		CASE 2 : GOSUB Type2
		CASE 3 : GOSUB Type3
		CASE ELSE : RETURN 0
	END SELECT

' ***** Type0 *****

SUB Type0
' ----------------------------------------
' Best case scenario.  The array is already
' in the order that we want.
' ----------------------------------------
	FOR count = 0 TO upper
		test[count] = count
	NEXT count
END SUB


' ***** Type1 *****

SUB Type1
' ----------------------------------------
' Worst case scenario. The array is in the
' exact opposite order of what we want!
' ----------------------------------------
	position = 0
	FOR count = upper TO 0 STEP -1
		test[position] = count
		INC position
	NEXT count
END SUB

' ***** Type2 *****

SUB Type2
' ----------------------------------------
' A completely random scenario, like a
' well shuffled deck of cards.
' ----------------------------------------
'	PRINT "Creating Randomly ordered array..."
	FOR count = 0 TO upper
		test[count] = count
	NEXT count

	FOR count = 0 TO upper
		rn = RandomN (upper)
		SWAP test[count], test[rn]
	NEXT count
END SUB


' ***** Type3 *****

SUB Type3
' ----------------------------------------
' The first (nmbrOfItems - x) are in order.
' However the final x items, located all at the
' end of the array, need to be sorted.
' example: 1 2 3 5 6 7 9 10 11 13 14 15 4 12 8
' ----------------------------------------
	PRINT
	PRINT "Creating type 3 array..."
' 10% of end of list is out of sorting order
	x = 0.1 * nmbrOfItems
	FOR count = 0 TO upper
		test[count] = count
	NEXT count

'	start = GetTickCount()

	FOR a = 0 TO x-1
		s = RandomN (upper)
		last = test[s]
		addrS = &test[s+1]
		addrD = &test[s]
		bytes = (upper + 1 - s) * 4
		RtlMoveMemory (addrD, addrS, bytes)		' this is 40% faster than using XstCopyMemory
		test[upper] = last

' this works but is very slow for large arrays
'		SWAP test[s], test[upper]
'		FOR b = s TO (nmbrOfItems - 3)
'			SWAP test[b], test[b + 1]
'		NEXT b

	NEXT a

'	end = GetTickCount() - start
'	PRINT "seconds="; end/1000.0
END SUB

END FUNCTION
'
'
' ##########################
' #####  MergeSort ()  #####
' ##########################
'
FUNCTION  MSort (@out[], @tmpA[], left, right)

	IF (right-left) < 24 THEN InsertionSort(@out[], left, right) : RETURN
'	IF (left == right)  THEN RETURN
	mid = (left + right) / 2
	MSort(@out[], @tmpA[], left, mid)
	MSort(@out[], @tmpA[], mid+1, right)

	FOR i = left TO right
		tmpA[i] = out[i]
	NEXT i

	i1 = left
	i2 = mid + 1

	FOR cur_i = left TO right
		IF (i1 == mid + 1) THEN
			out[cur_i] = tmpA[i2+1]
		ELSE
			IF (i2 > right) THEN
				out[cur_i] = tmpA[i1+1]
			ELSE
				IF (tmpA[i1] < tmpA[i2]) THEN
					out[cur_i] = tmpA[i1+1]
				ELSE
					out[cur_i] = tmpA[i2+1]
				END IF
			END IF
		END IF
	NEXT cur_i

END FUNCTION
'
'
' ######################
' #####  Radix ()  #####
' ######################
'
FUNCTION  Radix (SSHORT bitsOffset, XLONG N, XLONG out[], XLONG dest[])

	XLONG count[256]
  XLONG index[256]

		FOR i = 0 TO N-1
			INC count[(out[i] >> bitsOffset) & 0xFF]
		NEXT i

  	index[0]=0
		FOR i = 1 TO 255
			index[i]=index[i-1]+count[i-1]
		NEXT i

		FOR i = 0 TO N-1
			x = (out[i] >> bitsOffset) & 0xFF
			dest[index[x]] = out[i]
			INC index[x]
		NEXT i

END FUNCTION
'
'
' #######################
' #####  FQSort ()  #####
' #######################
'
FUNCTION  FQSort (@out[], l, r)

	M = 38 																							' set between 7 & 40
	IF  ((r-l) > M) THEN

		i = (r+l)/2
		IF (out[l] > out[i]) THEN SWAP out[l], out[i]			' Tri-Median Method
		IF (out[l] > out[r]) THEN SWAP out[l], out[r]
		IF (out[i] > out[r]) THEN SWAP out[i], out[r]

		j = r-1
		SWAP out[i], out[j]
		i = l
		v = out[j]
		DO
			DO
				INC i
			LOOP WHILE out[i] < v

			DO
				DEC j
			LOOP WHILE out[j] > v

			IF j < i THEN EXIT DO
			SWAP out[i], out[j]

		LOOP
		SWAP out[i], out[r-1]

		FQSort(@out[], l, j)
		FQSort(@out[], i+1, r)
	END IF


END FUNCTION
'
'
' #########################
' #####  IsSorted ()  #####
' #########################
'
FUNCTION  IsSorted (array[])

	IFZ array[] THEN
		PRINT "Error : IsSorted() : Empty Array"
		RETURN 0
	END IF
	FOR i = 0 TO UBOUND(array[])-1
		IF array[i] > array[i+1] THEN
			PRINT "Error : IsSorted() : Array is NOT sorted"
			RETURN 0
		END IF
	NEXT i
	RETURN 1


END FUNCTION
'
'
' ##########################
' #####  RadixSort ()  #####
' ##########################

'======================= RadixSort =========================================
' This variation on the Radix Sort check to see if all four byte passes
' are necessary. If a pass is already sorted or all NUL, then the pass is
' skipped.
'===========================================================================
'
FUNCTION  RadixSort2 (ULONG in[], ULONG out[])

	ULONG count[256]
  ULONG index[256]
	ULONG i

	upper = UBOUND(in[])
	DIM out[upper]

	FOR bitsOffset = 0 TO 24 STEP 8
		FOR i = 0 TO upper
			x = (in[i] >> bitsOffset) & 0xFF
			INC count[x]
		NEXT i

  	index[0]=0
		FOR i = 1 TO 255
			index[i]=index[i-1]+count[i-1]
			IF index[1] = upper + 1 THEN			'current pass is already sorted or is all nulls
				passFlag = $$TRUE
				EXIT FOR
			END IF
		NEXT i

		IFT passFlag THEN
			SWAP in[], out[]
 			EXIT FOR
		END IF

		FOR i = 0 TO upper
			x = (in[i] >> bitsOffset) & 0xFF
			out[index[x]] = in[i]
			INC index[x]
		NEXT i

		SWAP in[], out[]

		DIM count[256]
		DIM index[256]

	NEXT bitsOffset
END FUNCTION
'
'
' ###################################
' #####  XstQuickSort_XLONG ()  #####
' ###################################
'
FUNCTION  XstQuickSort_XLONG (a[], n[], low, high, order)

	IF (low >= high) THEN RETURN								' less than two elements

	IF (order = $$SortDecreasing) THEN
		IF ((high - low) = 1) THEN								' two element left
			IF (a[low] > a[high]) THEN RETURN				' a[] correct order
			IF (a[low] < a[high]) THEN
				SWAP a[low], a[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a[low], a[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF

		midPoint = (high + low) >> 1
		SWAP a[high], a[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition = a[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
'			i = low: j = high									'<<<<<<<<< wrong place, move two lines above
			IFZ n[] THEN
				DO WHILE (i < j) AND (a[i] >= partition)
					INC i
				LOOP
				DO WHILE (j > i) AND (a[j] <= partition)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a[i] < partition) THEN EXIT DO
					IF (a[i] = partition) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a[j] > partition) THEN EXIT DO
					IF (a[j] = partition) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a[i], a[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)

	ELSE

		IF ((high - low) = 1) THEN								' two element left
			IF (a[low] < a[high]) THEN RETURN				' a[] correct order
			IF (a[low] > a[high]) THEN
				SWAP a[low], a[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a[low], a[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF

		midPoint = (high + low) >> 1
		SWAP a[high], a[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition = a[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
'			i = low: j = high								'<<<<<<<<<<<< wrong place, move 2 lines above
			IFZ n[] THEN
				DO WHILE (i < j) AND (a[i] <= partition)
					INC i
				LOOP
				DO WHILE (j > i) AND (a[j] >= partition)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a[i] > partition) THEN EXIT DO
					IF (a[i] = partition) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a[j] < partition) THEN EXIT DO
					IF (a[j] = partition) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a[i], a[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	END IF

	SWAP a[i], a[high]
	IF n[] THEN SWAP n[i], n[high]

'	IF ((i-low) < (high-i)) THEN
'		IF i THEN XstQuickSort_XLONG (@a[], @n[], low, i-1, order)
'		XstQuickSort_XLONG (@a[], @n[], i+1, high, order)
'	ELSE
'		XstQuickSort_XLONG (@a[], @n[], i+1, high, order)
'		IF i THEN XstQuickSort_XLONG (@a[], @n[], low, i-1, order)
'	END IF


	IF i > low + 1  THEN XstQuickSort_XLONG (@a[], @n[], low, i-1,  order)
	IF i < high - 1 THEN XstQuickSort_XLONG (@a[], @n[], i+1, high, order)
END FUNCTION
'
'
' ###########################
' #####  MergeSort2 ()  #####
' ###########################
'
FUNCTION  MergeSort2 (XLONG out[], XLONG lo, XLONG hi)

	XLONG i, j, k, m, n
	XLONG b[]

	IF (hi-lo) < 24 THEN InsertionSort (@out[], lo, hi) : RETURN

	IF lo < hi THEN
		m = (lo + hi) / 2
		MergeSort2 (@out[], lo, m)
		MergeSort2 (@out[], m+1, hi)

		n = hi - lo	+ 1
    DIM b[n]          						' create temporary array

		k = 0
		FOR i = lo TO m   						' copy lower half to array b
			b[k] = out[i]
			INC k
		NEXT i

		FOR j = hi TO m+1 STEP -1 		' copy upper half to array b in opposite order
			b[k] = out[j]
			INC k
		NEXT j

		i = 0 : j = n-1 : k = lo

		DO WHILE  (i <= j)						' copy back next-greatest element at each time until i and j cross
			IF (b[i] <= b[j]) THEN
				out[k] = b[i]
				INC k
				INC i
			ELSE
				out[k] = b[j]
				INC k
				DEC j
			END IF
		LOOP

'		DIM b[]
	END IF

END FUNCTION
'
'
' ###########################
' #####  MergeSort3 ()  #####
' ###########################
'
FUNCTION  MergeSort3 (XLONG out[], XLONG left, XLONG right)

	XLONG middle, i, j, k, ind
	XLONG sorted[]

' Base case: a single element is considered sorted
	IF (left >= right) THEN RETURN

' Split the subarray in two and sort the halves

	mid = (left+right) / 2
	MergeSort3(@out[], left, mid)					' Sort the first half
	MergeSort3(@out[], mid+1, right)			' Sort the second half

' Combine two sorted subarrays.  The first subarray is
' [first, mid], and the second is (mid, right]

	i = left
	j = mid+1

  DIM sorted[right-left]

	FOR ind = 0 TO right-left

' Done with the right subarray, but not the left
		IF (j == right + 1) THEN
			sorted[ind] = out[i]
      INC i
' Done with the left subarray, but not the right
		ELSE
			IF (i == mid + 1) THEN
				sorted[ind] = out[j]
				INC j
' Not done with both subarrays; pick the smaller of the two elts to copy
			ELSE
				IF (out[i] < out[j]) THEN
					sorted[ind] = out[i]
					INC i
				ELSE
					sorted[ind] = out[j]
					INC j
				END IF
			END IF
		END IF
	NEXT ind

' Copy the sorted array into our original array
	FOR k = left TO right
    out[k] = sorted[k-left]
	NEXT k

  REDIM sorted[]


END FUNCTION
'
'
' #############################
' #####  MergeSortVic ()  #####
' #############################
'
FUNCTION  MergeSortVic (XLONG x[], XLONG low, XLONG high)

	XLONG m
	XLONG y[]

	IF (high-low) < 24 THEN InsertionSort(@x[], low, high) : RETURN
' here high-low >= 24 , so sort recursively
	m = (low+high)\2
	MergeSortVic(@x[], low, m)
	MergeSortVic(@x[], m+1, high)
	Merge2(@x[], low, m, high)

END FUNCTION
'
'
' #######################
' #####  Merge2 ()  #####
' #######################
'
FUNCTION  Merge2 (XLONG x[], XLONG low, XLONG m, XLONG high)

	XLONG  r , p , q , i , s
	STATIC XLONG y[]

	IFZ y[] THEN DIM y[UBOUND(x[])]

	FOR i = low TO m
  	y[i] = x[i]
	NEXT i

	p = low  : q = m+1 : r = low

	DO
  	IF y[p] <= x[q] THEN
			x[r] = y[p] : INC r : INC p
			IF p > m THEN RETURN
		ELSE
			x[r] = x[q] : INC r : INC q
			IF q > high THEN
				FOR i = r TO high
					x[i] = y[i + m - high]
				NEXT i
				RETURN
			END IF
		END IF
	LOOP

END FUNCTION
END PROGRAM
