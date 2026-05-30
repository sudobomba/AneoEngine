// GDT.c copied/inspired from Nanobyte OS
// How many time we got arrested again?

#include "stdint.h"
#include "stddef.h"
#include "stdbool.h"

#define LLOW(a) ((a)&0xffff)
#define BLOW(a) ((a)&0xffff)
#define BMID(a) ((a>>16)&0xFF)
#define FLHI(a,b) (((a>>16)&0xF)|(b&0xF0))
#define BHIGH(a) ((a>>24)&0xFF)
#define ENT(a,b,c,d) { \
	LLOW(b), \
	BLOW(a), \
	BMID(a), \
	(c), \
	FLHI(b,d), \
	BHIGH(a) \
}

#define GDT_CODE_SEGMENT 0x08
#define GDT_DATA_SEGMENT 0x10

typedef struct{
    	uint16_t LimitLow;
    	uint16_t BaseLow;
   	uint8_t MiddleLow;
    	uint8_t Access;
    	uint8_t FlagLmitHi;
    	uint8_t BaseHight;
} __attribute__((packed))GDTEntry;

typedef struct{
    	uint16_t Limit;
    	GDTEntry* Ptr;
} __attribute__((packed))GDTDescriptor;

typedef enum{
    	GDT_ACCESS_CODE_READABLE=0x02,
    	GDT_ACCESS_DATA_WRITEABLE=0x02,
    	GDT_ACCESS_CODE_CONFORMING=0x04,
    	GDT_ACCESS_DATA_DIRECTION_NORMAL=0x00,
    	GDT_ACCESS_DATA_DIRECTION_DOWN=0x04,
    	GDT_ACCESS_DATA_SEGMENT=0x10,
    	GDT_ACCESS_CODE_SEGMENT=0x18,
    	GDT_ACCESS_DESCRIPTOR_TSS=0x00,
    	GDT_ACCESS_RING0=0x00,
    	GDT_ACCESS_RING1=0x20,
    	GDT_ACCESS_RING2=0x40,
    	GDT_ACCESS_RING3=0x60,
    	GDT_ACCESS_PRESENT=0x80,
}GDT_ACCESS;

typedef enum{
    	GDT_FLAG_64BIT=0x20,
    	GDT_FLAG_32BIT=0x40,
    	GDT_FLAG_16BIT=0x00,
    	GDT_FLAG_GRANULARITY_1B=0x00,
    	GDT_FLAG_GRANULARITY_4K=0x80,
}GDT_FLAGS;

GDTEntry g_GDT[]={
    	ENT(0,0,0,0),
    	ENT(0,0xFFFFF,GDT_ACCESS_PRESENT|GDT_ACCESS_RING0|GDT_ACCESS_CODE_SEGMENT|GDT_ACCESS_CODE_READABLE,GDT_FLAG_32BIT|GDT_FLAG_GRANULARITY_4K),
	ENT(0,0xFFFFF,GDT_ACCESS_PRESENT|GDT_ACCESS_RING0|GDT_ACCESS_DATA_SEGMENT|GDT_ACCESS_DATA_WRITEABLE,GDT_FLAG_32BIT|GDT_FLAG_GRANULARITY_4K),
};

GDTDescriptor g_GDTDescriptor={sizeof(g_GDT)-1,g_GDT};

extern void GDTLoad(GDTDescriptor* descriptor,uint16_t codeSegment,uint16_t dataSegment);

void gdt_init(void){GDTLoad(&g_GDTDescriptor,GDT_CODE_SEGMENT,GDT_DATA_SEGMENT);}
