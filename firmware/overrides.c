#include "menu.h"
#include "keyboard.h"
#include "interrupts.h"

#include "c64keys.c"


extern unsigned char romtype;

/* Enable long-press for hard-reset */

extern struct menu_entry menu[];
void cycle(int row);
void toggle(int row)
{
	int restore=0;
	if(menu_longpress && menu[row].u.opt.shift==0)
	{
		statusword_cycle(7,1,2); /* Toggle hard reset bit */
		statusword_cycle(7,1,2);
	}
	else
	{
		cycle(row);
		cycle(row);
	}
}

int UpdateKeys(int blockkeys)
{
	handlec64keys();
	return(HandlePS2RawCodes(blockkeys));
}

char *autoboot()
{
	char *result="Show/hide OSD = key F12";

	initc64keys();

	return(result);
}

