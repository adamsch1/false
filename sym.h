#ifndef __SYM__H
#define __SYM__H

void sym_init();

void sym_insert_float( const char *name, float value );
void sym_insert_int( const char *name, int value );
void sym_insert_string( const char *name, const char *value );

// Look up a symbol that may or may not exist
int sym_lookup_int( const char *name, int *value );

// Look up a symbol we know to exist
int sym_get_int( const char *name );
// Look up a symbol we know to exist
float sym_get_float( const char *name );

#endif
