#include <stdio.h>

/* The XBasic dynamic memory ('heap') is a linked list, beginning
 * with __DYNO and ending with __DYNOX. */
extern unsigned char *__DYNO;
extern unsigned char *__DYNOX;

struct TMemBlock
{
	/** The distance (in bytes) to the next TMemBlock.
	 * It is 0 for the last block in the chain (__DYNOX).
	 */
	unsigned long	lAddrUp;
	/** ?? */
	unsigned long	lAddrDown;
	/** ?? */
	unsigned long	lSizeUp;
	/** ?? */
	unsigned long	lSizeDown;
};
typedef struct TMemBlock TMemBlock;

/** Check the consistency of the XBasic heap.
 * @return	0: Heap is ok; -1: Heap is corrupted.
 * NOTE: Right now this function only checks the list of memory-blocks. It
 * should be enhanced to detect corruption in the memoryblocks themselves
 * (e.g. strings, arrays, ...).
 */
int xb_checkmem(void)
{
	unsigned char	*p;
	TMemBlock	*pMB;

	p = __DYNO;
	for (;;)
	{
		pMB = (TMemBlock *)p;

		/* TODO: Perform checks on memory-block. */
		if (pMB->lAddrUp == 0)
			break;
		p += pMB->lAddrUp;
		if (p >= __DYNOX)
			break;
	}
	/* If the heap is consistent we should end exactly on __DYNOX. */
	if (p != __DYNOX)
		return (-1);
	return (0);
}
