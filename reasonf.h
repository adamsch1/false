#ifndef __REASONF__H
#define __REASONF__H

#include <time.h>
#include "sglib.h"
#include "slab.h"
#include <err.h>

struct node {
  int i;
  float f;
  int op;
  char *name;
  struct node *lambda;
  struct node *next;
};

typedef struct symbol {
  struct node *n;
  char *name;
  char color_field;
  struct symbol *left;
  struct symbol *right;
} symbol;

int reasonf_main( int argc, char **argv);
void cap( struct node *n );
struct node * make_op( int op );
inline struct node * make_int( int value );
struct node * make_float( float value );
struct node * make_name( char * name );
struct node * make_open( struct node *no );
struct node * make_dupe( struct node *no );
struct node * make_cons( struct node *a, struct node *b );

struct node * sym_get( char *name );
void sym_add( char *name );

#endif
