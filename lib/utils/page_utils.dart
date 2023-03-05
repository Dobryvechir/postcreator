const pageShift = 8;
const pageMax = 1 << pageShift;
const pageMask = pageMax - 1;

int primaryPage(int page) => page & pageMask;

int secondaryPage(int page) => (page >> pageShift) & pageMask;

int page2level(int prim, int sec) => (sec << pageShift) | prim;
