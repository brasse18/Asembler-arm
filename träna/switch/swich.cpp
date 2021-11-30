extern "C" int swich(int a,int b);

int foo(void) {
	return swich(0xA0B1C2D3, 0xE0E1E2E3);
}