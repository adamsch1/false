#include <string.h>
#include "reasonf.h"
#include "y.tab.h"
#include "sglib.h"
#include <stdlib.h>

#define COMPARATOR(x,y) (strcmp(x->name,y->name))
SGLIB_DEFINE_RBTREE_PROTOTYPES( symbol, left, right, color_field, COMPARATOR );
SGLIB_DEFINE_RBTREE_FUNCTIONS( symbol, left, right, color_field, COMPARATOR );

struct symbol *sym;

struct node * sym_get( char *name )  {
  struct symbol e;
  struct symbol *s;
  e.name = name;
  if( (s=sglib_symbol_find_member( sym, &e )) != NULL )  {
    return s->n;
  } else {
    return make_op(NIL);
  }
}

void sym_replace( char *name, struct node *n )  {
  struct symbol e;
  struct symbol *s;
  e.name = name;
  if( (s=sglib_symbol_find_member( sym, &e )) != NULL )  {
    s->n = n;
  } else {
    sym_add( name ); 
    sym_replace( name, n );
  }
}

void sym_add( char *name )  {
  struct symbol *t = malloc(sizeof(struct symbol));
  t->name = strdup(name);
  sglib_symbol_add( &sym, t );
}
