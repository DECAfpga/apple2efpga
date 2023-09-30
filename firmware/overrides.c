#include "menu.h"
#include "keyboard.h"
#include "interrupts.h"
#include "user_io.h"
#include "statusword.h"
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

/* Override menu_joystick to emulate analogue sticks */

int analoguesensitivity=0x80;
int analogue[4];

__weak void Menu_JoystickToAnalogue(int *ana,int joy, int sensitivity)
{
	int a=*ana;
	int min=-0x7f00,max=0x7f00;
	if(joy&2)
	{
		max=-sensitivity<<4;
		a-=sensitivity;
	}
	else if(joy&1)
	{
		min=sensitivity<<4;
		a+=sensitivity;
	}
	else
		a=(a*15)>>4;
	if(a<min)
		a=min;
	if(a>max)
		a=max;
	*ana=a;
}

void Menu_Joystick(int port,int joymap)
{
	int buttons=HW_JOY(REG_JOY_EXTRA);
	int *a=&analogue[0];
	if(TestKey(KEY_F1))
		analoguesensitivity=0x7f0;
	if(TestKey(KEY_F2))
		analoguesensitivity=0x300;
	if(TestKey(KEY_F3))
		analoguesensitivity=0x100;
	if(TestKey(KEY_F4))
		analoguesensitivity=0x040;
	user_io_digital_joystick_ext(port, joymap);
	Menu_JoystickToAnalogue(&analogue[2*port+0],joymap,analoguesensitivity);
	Menu_JoystickToAnalogue(&analogue[2*port+1],joymap>>2,analoguesensitivity);
	user_io_analogue_joystick(port,a);
}

char *autoboot()
{
	char *result=0; // "Show/hide OSD = key F12";

	initc64keys();

	statusword_cycle(7,1,2); /* Toggle hard reset bit */
	statusword_cycle(7,1,2);

	return(result);
}

