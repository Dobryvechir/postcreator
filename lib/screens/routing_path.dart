import '../homepage/home_router.dart';
import '../routing/route_info.dart';

const routingPathSignIn = '/signin';
const routingPathInitial = '/home';
const routingPathFirstForSigned = '/home';

var routingPathMap = <String, RouteInfo>{
  '/signin': RouteInfo.named('signin'),
  '/gallery/:id': RouteInfo.named('galleryShow'),
  '/home': RouteInfo(
    'home',
    routeHome,
  ),
  '/home/text': RouteInfo(
    'home-text',
    routeHomeText,
  ),
  '/home/image': RouteInfo(
    'home-image',
    routeHomeImage,
  ),
  '/home/audio': RouteInfo(
    'home-audio',
    routeHomeAudio,
  ),
  '/home/video': RouteInfo(
    'home-video',
    routeHomeVideo,
  ),
  '/home/start': RouteInfo(
    'home-start',
    routeHomeStart,
  ),
};
