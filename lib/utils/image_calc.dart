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

bool evaluatePointIsInside(double x, double y, List<List<int>> polygon) {
  int count = 0;
  int n = polygon.length;
  int oldX = polygon[n - 1][0];
  int oldY = polygon[n - 1][1];
  for (int i = 0; i < n; i++) {
    var p = polygon[i];
    int newX = p[0];
    int newY = p[1];
    if ((oldY <= y || newY <= y) &&
        (x <= newX && x >= oldX || x >= newX && x <= oldX)) {
      count++;
    }
    oldX = newX;
    oldY = newY;
  }
  return (count & 1) != 0;
}

int calculateSelectedPage(int imageX, int imageY, int originX, int originY,
    double x, double y, List<List<List<int>>> data) {
  x = x * imageX / originX;
  y = y * imageY / originY;
  int n = data.length;
  for (var i = 0; i < n; i++) {
    var block = data[i];
    if (evaluatePointIsInside(x, y, block)) {
      return i + 1;
    }
  }
  return 0;
}
