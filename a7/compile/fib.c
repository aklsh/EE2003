#define BASE 0x34560
#define WRITE_OFFSET 0x00

int main()
{
    int *p;
    p = BASE+WRITE_OFFSET;
    *p = 72; // h in ascii
	return 0;
}
