#include <stdlib.h>
#include <sys/queue.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <sys/queue.h>
#include <event.h>


/**
 * Poor man's slab allocator - foo better be smaller than slabsize
 * and larger or equal to size of struct trash_t;
 *
 * struct foo {
 *   int bar;
 * };
 *
 * SPMALLOC_DECLARE( foopool, 1024*1024, sizeof(struct foo))
 *
 * struct foo *p;
 *
 * SPMALLOC_GET( p, foopool );
 *
 * p->bar = 1234;
 *
 * SPMALLOC_FREE(p, foopool );
 * (thanks freebsd)
 *
 * staight malloc of 150 foo's was 79,000 usec.  With slab 45,000 with 
 * using the trash_t, 8000 usec.
 *
 **/

/* Define list type for slab allocations */
LIST_HEAD(slablist_t,slab_t);

//-- Cast our items to this and link em cast back when we want a freed one
struct trash_t {
  struct trash_t *next;
};

struct spool_t {
  struct slablist_t head; //-- list of slabs
	int ssize; //-- slab size
	int isize; //-- item size
	struct trash_t *trashp; //-- Free ones are linked back here
};

struct slab_t {
  LIST_ENTRY(slab_t) entries; //-- link of slabs
	char *p; //-- offset in data
	char data[]; //-- the rest of the slab
};

//-- Define slab structure and initialize it
#define SPMALLOC_DECLARE( name, slab_size, item_size ) \
  struct spool_t name = { {0}, slab_size, item_size }  \


//-- Alloca a slab
#define __GET_SLAB( name )  \
  do { \
	  struct slab_t *s = (struct slab_t *)calloc(1,sizeof(struct slab_t)+name.ssize ); \
		s->p = s->data; \
		LIST_INSERT_HEAD( &name.head, s, entries ); \
	} while(0) \

/** Check if we have free ones available and reutrn that
 *  Check if we have space in slab
 *  no space - get new slab
 *  increment slab->p to next free locaiton, return previous location
 **/

#define SPMALLOC_GET( variable,name ) \
  do { \
	  if( name.trashp )  { \
		  struct trash_t *p = name.trashp; \
			name.trashp = p->next; \
			variable = (void*)p; \
			break; \
		} else if( LIST_EMPTY(&name.head) || (name.head.lh_first->p - name.head.lh_first->data) + name.isize >= name.ssize  ) { \
		  __GET_SLAB(name); \
		} \
		struct slab_t *s = LIST_FIRST( &name.head ); \
		s->p += name.isize; \
		variable = (void*)s->p - name.isize; \
	} while(0) \

#define SPMALLOC_FREE( variable, name ) \
  do { \
	  struct trash_t *p = (struct trash_t *)variable; \
    p->next = name.trashp; \
		name.trashp = p; \
	} while(0) \

#if 0
struct thing {
  int a;
	char foo[96];
};

SPMALLOC_DECLARE( thingpool, 1024*1024, sizeof(struct thing));

int main() {
  struct timeval tv1,tv2,tv3;
  int k;
  struct thing *a;  
	printf("%d\n", thingpool.ssize );
	printf("%d\n", thingpool.head.lh_first );

  gettimeofday( &tv1, NULL );
	for( k=0;k<150000; k++)  {
	  SPMALLOC_GET( a, thingpool );
 //   a = malloc(sizeof(struct thing));
		a->a = k;
	//	free(a);
  	SPMALLOC_FREE( a, thingpool );
  }
  gettimeofday( &tv2, NULL );
   timeval_subtract(&tv3, &tv2,&tv1);
  printf("%ld\n",  tv3.tv_usec );
  return 0;
}
#endif
