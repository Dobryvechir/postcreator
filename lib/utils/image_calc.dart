const coordShift = 15;
const coordMask = (1 << coordShift) - 1;

int coordinateX(int coord) => coord & coordMask;
int coordinateY(int coord) => (coord >> coordShift) & coordMask;

int coordPair(int x, int y) => (y << coordShift) | x;

int calculateProportionalImage(int maxX, int maxY, int boxX, int boxY) {
  if (maxX <= boxX && maxY <= boxY || boxX <= 0 || boxY <= 0) {
    return coordPair(maxX, maxY);
  }
  int fx = maxX * boxY;
  int fy = maxY * boxX;
  if (fx > fy) {
    return coordPair(boxX, fy ~/ maxX);
  }
  return coordPair(fx ~/ maxY, boxY);
}
