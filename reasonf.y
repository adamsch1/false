%{
#include <string.h>
#include <stdio.h>
#include "reasonf.h"

unsigned line_number;
unsigned lambda_depth;

struct node *prog = 0;
struct node *pc = 0;
extern struct node * make_op( int op );
extern struct symbol *sym;
extern struct trash_t *trash;

int si=-1;
struct node *stack[100];

void yyerror( char *errmsg )  {
  fprintf(stderr, "line %d. %s \n", line_number, errmsg );
}

void pop()  {
  struct node *temp = stack[si]->lambda; // get last prog
  stack[si]->lambda = prog;  // old pc is the exec, so tell it what to exec
  prog = temp; // Resture old prog 
  pc = stack[si--]; // Resture old pc which now has lambda of the prog
}

void cap( struct node *n )  {
  if( pc == 0 )  {
    prog = pc = n;
  } else {
    pc = pc->next = n;
  }
}

// Save current prog and pc - reset cause we are starting 
// a new code block.
void push( struct node *n, int o )  {
  cap( make_op( o ) );  // When we exec this is the function call op
  pc->lambda = prog;    // save current prog [start of block]
  stack[++si] = pc;     // push current pc
  pc = prog = 0;        // reset to start building new block
}


%}

%union {
  char *p;
  int   i;
  float f;
  struct node *n;
}

%token <n> IF DOT OPEN PLUS MINUS DIVIDE MULTIPLY
%token <n> LT GT LTE GTE EQUAL ASSIGN APPLY
%token <n> NAME FLOAT FETCH WHILE
%token <n> INT DUP UMINUS NOT CAR CDR NIL CONS DONE WHILE_A WHILE_B

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%nonassoc ELSE


%type <n> op

%%

// This production lets us have multiple lines of code in a block
statement_list: statement //{ $$ = $1; }
              | statement_list statement //{ $$ = $1; }
              ;

// A single statement
statement: FLOAT { cap($1); } 
         | INT  { cap($1); }
         | OPEN { 
             push($1, OPEN);
           }
           statement_list {
             cap(make_op(DONE));
           }
           CLOSE {
             pop();
           }
         | NAME { cap($1); }
         | op { cap($1); }
         ;

op: PLUS | MINUS | DIVIDE | MULTIPLY | LT | GT | LTE | GTE | EQUAL | ASSIGN 
  | APPLY | DOT | FETCH |  WHILE | DUP | UMINUS | IF | NOT | CAR | CDR | NIL
  | CONS ;

%%

int main(int argc, char **argv )  {
  sym = 0;
  trash = 0;
  return reasonf_main( argc, argv );
}
