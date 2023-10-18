//
//
// #################################  Interface routines for
// #####  C Library Interface  #####  some C library routines.
// #################################
// 
// This interface tries to be compatible with different versions
// of libc (libc5 and glibc AKA libc6) and different versions of
// the Linux kernel.
//
// Functions xb_stat(), xb_sigaction(), xb_readdr() in this file
// provide the same function-interface and behavior as functions
// stat(), sigaction(), readdr() in libc5.  The function-interface
// and/or behavior of these functions changed from libc5 to libc6,
// which requires the following solution or changes to XBasic code.
//
// This file was created by Eddie Penninkhof to make Linux XBasic
// work on his Linux system and other releases of Linux based on
// the libc6 function libraries.  Thanks Eddie!
//
// PROGRAM "xbiface"
// VERSION "0.0004"
//
//
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>
#include <dirent.h>
#include <limits.h>
//
// this is the stat struct recognized by XBasic
//
struct xb_newustat {
	unsigned short     st_dev;
	unsigned short     st_pad1;
	unsigned long      st_ino;
	unsigned short     st_mode;
	unsigned short     st_nlink;
	unsigned short     st_uid;
	unsigned short     st_gid;
	unsigned short     st_rdev;
	unsigned short     st_pad;
	unsigned long      st_size;
	unsigned long      st_blksize;
	unsigned long      st_blocks;
	unsigned long      st_atime;
	unsigned long      st_unused1;
	unsigned long      st_mtime;
	unsigned long      st_unused2;
	unsigned long      st_ctime;
	unsigned long      st_unused3;
	unsigned long      st_unused4;
	unsigned long      st_unused5;
};
//
// this is the stat struct previously recognized by XBasic
//
struct xb_oldustat {
	short							st_dev;
	unsigned short		st_ino;
	unsigned short		st_mode;
	short							st_nlink;
	unsigned short		st_uid;
	unsigned short		st_gid;
	short							st_rdev;
	unsigned short		st_pad;
	long							st_size;
	unsigned long			st_atime;
	unsigned long			st_mtime;
	unsigned long			st_ctime;
};
//
// this is the sigaction struct recognized by XBasic
//
struct xb_sigaction {
	long	xb_sa_handler;
	long	xb_sa_mask;
	long	xb_sa_flags;
};
//
// this is the dirent struct recognized by XBasic
//
struct xb_dirent {
	long						d_ino;
	long						d_off;
	unsigned short	d_reclen;
	unsigned short	d_pad;
	char						d_name[256];
};
//
//
// #######################
// #####  xb_stat()  #####
// #######################
//
int xb_stat(char *filename, struct xb_oldustat *xb_stat_buf) {
	int ret = 0;
	struct stat stat_buf;

/*
	printf ("\n");
	printf ("&stat_buf   = %8x : %8x\n", (int)&stat_buf, (int)&stat_buf - (int)&stat_buf);
	printf (".st_dev     = %8x : %8x\n", (int)&stat_buf.st_dev - (int)&stat_buf, (int)&stat_buf.__pad1 - (int)&stat_buf.st_dev);
	printf (".__pad1     = %8x : %8x\n", (int)&stat_buf.__pad1 - (int)&stat_buf, (int)&stat_buf.st_ino - (int)&stat_buf.__pad1);
	printf (".st_ino     = %8x : %8x\n", (int)&stat_buf.st_ino - (int)&stat_buf, (int)&stat_buf.st_mode - (int)&stat_buf.st_ino);
	printf (".st_mode    = %8x : %8x\n", (int)&stat_buf.st_mode - (int)&stat_buf, (int)&stat_buf.st_nlink - (int)&stat_buf.st_mode);
	printf (".st_nlink   = %8x : %8x\n", (int)&stat_buf.st_nlink - (int)&stat_buf, (int)&stat_buf.st_uid - (int)&stat_buf.st_nlink);
	printf (".st_uid     = %8x : %8x\n", (int)&stat_buf.st_uid - (int)&stat_buf, (int)&stat_buf.st_gid - (int)&stat_buf.st_uid);
	printf (".st_gid     = %8x : %8x\n", (int)&stat_buf.st_gid - (int)&stat_buf, (int)&stat_buf.st_rdev - (int)&stat_buf.st_gid);
	printf (".st_rdev    = %8x : %8x\n", (int)&stat_buf.st_rdev - (int)&stat_buf, (int)&stat_buf.__pad2 - (int)&stat_buf.st_rdev);
	printf (".__pad2     = %8x : %8x\n", (int)&stat_buf.__pad2 - (int)&stat_buf, (int)&stat_buf.st_size - (int)&stat_buf.__pad2);
	printf (".st_size    = %8x : %8x\n", (int)&stat_buf.st_size - (int)&stat_buf, (int)&stat_buf.st_blksize - (int)&stat_buf.st_size);
	printf (".st_blksize = %8x : %8x\n", (int)&stat_buf.st_blksize - (int)&stat_buf, (int)&stat_buf.st_blocks - (int)&stat_buf.st_blksize);
	printf (".st_blocks  = %8x : %8x\n", (int)&stat_buf.st_blocks - (int)&stat_buf, (int)&stat_buf.st_atime - (int)&stat_buf.st_blocks);
	printf (".st_atime   = %8x : %8x\n", (int)&stat_buf.st_atime - (int)&stat_buf, (int)&stat_buf.__unused1 - (int)&stat_buf.st_atime);
	printf (".__unused1  = %8x : %8x\n", (int)&stat_buf.__unused1 - (int)&stat_buf, (int)&stat_buf.st_mtime - (int)&stat_buf.__unused1);
	printf (".st_mtime   = %8x : %8x\n", (int)&stat_buf.st_mtime - (int)&stat_buf, (int)&stat_buf.__unused2 - (int)&stat_buf.st_mtime);
	printf (".__unused2  = %8x : %8x\n", (int)&stat_buf.__unused2 - (int)&stat_buf, (int)&stat_buf.st_ctime - (int)&stat_buf.__unused2);
	printf (".st_ctime   = %8x : %8x\n", (int)&stat_buf.st_ctime - (int)&stat_buf, (int)&stat_buf.__unused3 - (int)&stat_buf.st_ctime);
	printf (".__unused3  = %8x : %8x\n", (int)&stat_buf.__unused3 - (int)&stat_buf, (int)&stat_buf.__unused4 - (int)&stat_buf.__unused3);
	printf (".__unused4  = %8x : %8x\n", (int)&stat_buf.__unused4 - (int)&stat_buf, (int)&stat_buf.__unused5 - (int)&stat_buf.__unused4);
	printf (".__unused5  = %8x\n", (int)&stat_buf.__unused5 - (int)&stat_buf);
*/

	ret = stat(filename, &stat_buf);

	if (ret == 0) {
		xb_stat_buf->st_dev = stat_buf.st_dev;
//	xb_stat_buf->st_pad1 = 0
		xb_stat_buf->st_ino = stat_buf.st_ino;
		xb_stat_buf->st_mode = stat_buf.st_mode;
		xb_stat_buf->st_nlink = stat_buf.st_nlink;
		xb_stat_buf->st_uid = stat_buf.st_uid;
		xb_stat_buf->st_gid = stat_buf.st_gid;
		xb_stat_buf->st_rdev = stat_buf.st_rdev;
		xb_stat_buf->st_pad = 0;
		xb_stat_buf->st_size = stat_buf.st_size;
//	xb_stat_buf->st_blksize = stat_buf.st_blksize;
//	xb_stat_buf->st_blocks = stat_buf.st_blocks;
		xb_stat_buf->st_atime = stat_buf.st_atime;
//	xb_stat_buf->st_unused1 = 0;
		xb_stat_buf->st_mtime = stat_buf.st_mtime;
//	xb_stat_buf->st_unused2 = 0;
		xb_stat_buf->st_ctime = stat_buf.st_ctime;
//	xb_stat_buf->st_unused3 = 0;
//	xb_stat_buf->st_unused4 = 0;
//	xb_stat_buf->st_unused5 = 0;
	} else {
		memset(xb_stat_buf, 0, sizeof(*xb_stat_buf));
	}
	return (ret);
}
//
//
// ############################
// #####  xb_sigaction()  #####
// ############################
//
// The number of possible signals is extended from 32 to 1024,
// so sa_mask does not fit any longer in a long variable.
// This interface function converts the long into a sigset_t.
//
int xb_sigaction(int signum, const struct xb_sigaction *act, struct xb_sigaction *oldact) {
	struct sigaction oldact1;
	struct sigaction act1;
	long sigmask;
	int ret;
	int i;

	act1.sa_handler = (void (*)(int))act->xb_sa_handler;
	sigemptyset(&act1.sa_mask);
	sigmask = 1;
//
// we assume signal-numbering has not changed.
// somebody needs to make sure this is/stays true.
//
	for (i = 0; i < 32; ++i) {
		if ((act->xb_sa_mask & sigmask) != 0) { sigaddset(&act1.sa_mask, i + 1); }
		sigmask <<= 1;
	}

	act1.sa_flags = act->xb_sa_flags;
	act1.sa_restorer = NULL;
	ret = sigaction(signum, &act1, &oldact1);

	if (oldact != NULL) {
		oldact->xb_sa_handler = (long)oldact1.sa_handler;
		oldact->xb_sa_mask = 0;
		sigmask = 1;

		for (i = 0; i < 32; ++i) {
			if (sigismember(&oldact1.sa_mask, i + 1)) { oldact->xb_sa_mask |= sigmask; }
			sigmask <<= 1;
		}

		oldact->xb_sa_flags = oldact1.sa_flags;
	}
	return (ret);
}
//
//
// #########################
// #####  xb_readdr()  #####
// #########################
//
int xb_readdir(DIR *dirp, struct xb_dirent *dirent) {
	struct dirent	*dirent1;
	unsigned short* pu16;
	unsigned long* pu32;

	dirent1 = readdir(dirp);
	if (dirent1 == NULL) { return (0); }

/*
struct dirent {
	long							d_ino;
	__kernel_off_t		d_off;
	unsigned short		d_reclen;
	char							d_name[256];
};
*/
//
// What wankers designed the dirent structure?
// The following proves dirent.d_name starts 3 bytes above d_reclen
// !!!  PURE INSANITY  !!!
//
/*
	printf ("\n");
	printf ("&dirent1    = %8x : %8x\n", (int)&dirent1, (int)&dirent1 - (int)&dirent1);
	printf (".d_ino      = %8x : %8x\n", (int)&dirent1->d_ino - (int)dirent1, (int)&dirent1->d_off - (int)&dirent1->d_ino);
	printf (".d_off      = %8x : %8x\n", (int)&dirent1->d_off - (int)dirent1, (int)&dirent1->d_reclen - (int)&dirent1->d_off);
	printf (".d_reclen   = %8x : %8x\n", (int)&dirent1->d_reclen - (int)dirent1, (int)&dirent1->d_name[0] - (int)&dirent1->d_reclen);
	printf (".d_name     = %8x : %8x\n", (int)&dirent1->d_name[0] - (int)dirent1, (int)&dirent1->d_name[255] - (int)&dirent1->d_name[0] + 1);

	pu32 = (unsigned long*)dirent1;
	printf (".d_ino      = %8x : %8x\n", *pu32, pu32); pu32++;
	printf (".d_off      = %8x : %8x\n", *pu32, pu32); pu32++; pu16 = (unsigned short*)pu32;
	printf (".d_reclen   =     %4x : %8x\n", *pu16, pu16); pu16++; pu16 = (unsigned short*)((int)pu16 + (int)1);
	printf (".d_name     =          : %8x\n", pu16);
	printf (".d_name     = %s\n", (void*)pu16);
*/

	dirent->d_ino = dirent1->d_ino;
	dirent->d_off = dirent1->d_off;
	dirent->d_reclen = dirent1->d_reclen;
	dirent->d_pad = 0;

	memcpy(dirent->d_name, dirent1->d_name, 256);
	return (1);
}

/** Retrieve the full path and filename of the current process.
 * @param filename	Buffer in which the filename will be returned.
 * @param maxlen		The size of the filename buffer.
 * @return					The length of the returned filename.
 * Note: as this function uses /proc, it is pretty Linux-specific. */
int xb_getpfn(char *filename, int maxlen)
{
	char buf[PATH_MAX];
	pid_t	pid;
	int	n;
	
	pid = getpid();
	/* /proc/<pid>/exe is a symbolic link to the executable. */
	sprintf(buf, "/proc/%ld/exe", pid);
	n = readlink(buf, filename, maxlen);
	if (n < 0)
		/* An error occurred. */
		return (-1);
	return (n);
}
