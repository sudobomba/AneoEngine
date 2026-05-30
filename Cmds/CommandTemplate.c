// Template command used by sudobomba
#include "stddef.h"
#include "stdint.h"
#include "stdbool.h" // Do this Himel...

extern void putc(char c);
extern void print(const char *s);
extern void printad(const char *s, uint32_t x);
extern void printadocu(const char *s, uint32_t x1, uint32_t x2);
extern void indprintad(const char *s, uint32_t x);
extern void indprintadocu(const char *s, uint32_t x1, uint32_t x2);
extern void perror(char *line);
extern void printx(uint32_t x);
extern void printint(unsigned int n);
extern void comment(const char *s);

void cmdtmp(void){
	print("Template command\n");
}





/* Just for fun, Let's chat here */
/* No */
