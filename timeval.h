#ifndef __TIMEVAL__H
#define __TIMEVAL__H

#include <sys/time.h>

/*
   From glibc:
   Subtract the `struct timeval' values X and Y,
   storing the result in RESULT.
   Return 1 if the difference is negative, otherwise 0.  */

int
timeval_subtract ( struct timeval *result, struct timeval *x, 
  struct timeval *y );

#endif
