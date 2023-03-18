const pageShift = 8;
const pageMax = 1 << pageShift;
const pageMask = pageMax - 1;

int primaryPage(int page) => page & pageMask;

int secondaryPage(int page) => (page >> pageShift) & pageMask;

String pageHomeRoute(int pageNo) {
  String part;
  switch (pageNo) {
    case 1:
      part = 'text';
      break;
    case 2:
      part = 'image';
      break;
    case 3:
      part = 'audio';
      break;
    case 4:
      part = 'video';
      break;
    case 5:
      part = 'start';
      break;
    default:
      return '';
  }
  return '/home/$part';
}
