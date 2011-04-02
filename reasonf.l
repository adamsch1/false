%{
#include "reasonf.h"
#include "y.tab.h"
#include <string.h>
#include <time.h>
#include <stdlib.h>

void cpp_comment();
void c_comment();
void perl_comment();
extern unsigned line_number;
extern  struct spool_t nodepool;

inline struct node * make_op( int op )  {
  struct node *n = 0;

/*  if( trash )  {
    n = (struct node*) trash;
    memset(n, 0, sizeof(struct node));
    trash = trash->next;
  } else {
    n = calloc( 1, sizeof( struct node ) );
  }
*/
  SPMALLOC_GET( n, nodepool );

  n->op = op;
  return n;
}

inline struct node * make_dupe( struct node *no )  {
  if( no == NULL )  {
    return make_op( NIL );
  } else if( no->op == INT )  {
    return make_int( no->i );
  } else {
    struct node *n = make_op( no->op );
    memcpy( n, no, sizeof( struct node ));
    return n;
  }
}

struct node * make_cons( struct node *car, struct node *cdr )  {
  struct node *n = make_op( OPEN );
  n->lambda = make_dupe( car );
  n->lambda->next = make_dupe( cdr );
  return n;
}

inline struct node * make_int( int value )  {
  struct node *n = make_op( INT );
  n->i = value;
  return n;
}

struct node * make_float( float value )  {
  struct node *n = make_op( FLOAT );
  n->f = value;
  return n;
}

struct node * make_name( char * name )  {
  struct node *n = make_op( NAME );
  n->name = strdup(name);
  return n;
}

struct node * make_open( struct node *no )  {
  struct node *n = make_op( OPEN );
  n->lambda = no;
  return n;
}
%}


%%

"//" { cpp_comment(); }
"/*" { c_comment(); }

(([-+])?[0-9]+)  {
    yylval.n = make_int( atoi(yytext ));
		return INT;
	}

([0-9]+|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?) {
    yylval.n = make_float( atof(yytext ));
		return FLOAT;
	}
"."             {  yylval.n = make_op( DOT ); return DOT; }
"!"							{  yylval.n = make_op( ASSIGN ); return ASSIGN; }
":"							{  yylval.n = make_op( FETCH ); return FETCH; }
"@"							{  yylval.n = make_op( APPLY ); return APPLY; }
"+"							{  yylval.n = make_op( PLUS ); return PLUS; }
"-"							{  yylval.n = make_op( MINUS ); return MINUS; }
"*"							{  yylval.n = make_op( MULTIPLY ); return MULTIPLY; }
"/"							{  yylval.n = make_op( DIVIDE ); return DIVIDE; }
"_"							{  yylval.n = make_op( UMINUS ); return UMINUS; }
"="							{  yylval.n = make_op( EQUAL ); return EQUAL; }
"<"							{  yylval.n = make_op( LT ); return LT; }
">"							{  yylval.n = make_op( GT ); return GT; }
"<="						{  yylval.n = make_op( LTE ); return LTE; }
">="						{  yylval.n = make_op( GTE ); return GTE; }
"["							{  yylval.n = make_op( OPEN ); return OPEN; }
"]"							{  yylval.n = make_op( CLOSE ); return CLOSE; }
"get"           {  yylval.n = make_op( FETCH ); return FETCH; }
"set"           {  yylval.n = make_op( ASSIGN ); return ASSIGN; }
"seq"           {  yylval.n = make_op( APPLY ); return APPLY; }
"#"           	{  yylval.n = make_op( WHILE ); return WHILE; }
"while"        	{  yylval.n = make_op( WHILE ); return WHILE; }
"$"           	{  yylval.n = make_op( DUP ); return DUP; }
"dup"          	{  yylval.n = make_op( DUP ); return DUP; }
"?"          		{  yylval.n = make_op( IF ); return IF; }
"if"         		{  yylval.n = make_op( IF ); return IF; }
"~"          		{  yylval.n = make_op( NOT ); return NOT; }
"car"        		{  yylval.n = make_op( CAR ); return CAR; }
"cdr"        		{  yylval.n = make_op( CDR ); return CDR; }
"nil"        		{  yylval.n = make_op( NIL ); return NIL; }
"cons"       		{  yylval.n = make_op( CONS ); return CONS; }
[A-Za-z_]+ { 
                yylval.n = make_name( yytext );
								if( sym_get( yytext ) == NULL )  {
                  sym_add( yytext );
                }
                return NAME; 
        }

[\n]    ;       { line_number++; }  /* ignore newline */
[ \t]	;	 /* ignore white space */


. { return yytext[0]; }

%%

void cpp_comment()  {
  char c;
  while((c=input()) != '\n' && c != 0 ) {}
  if( c != 0 )  { 
    unput(c); 
  }
}

void c_comment()  {
  char c, c1;
loop:
  while((c = input()) != '*' && c != 0)  {
    if( c == '\n' ) line_number++;
  }

  if((c1 = input()) != '/' && c != 0) {
    unput(c1);
    goto loop;
  } 
}

void perl_comment()  {
  char c;
  while((c=input()) != '\n' && c != 0 ) {}
  if( c != 0 )  { 
    unput(c); 
  }
}

