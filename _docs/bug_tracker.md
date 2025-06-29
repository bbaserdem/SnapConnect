# Tracker

Tracker for missing and buggy features.

## Bugs

- [x] Wrong password/email handling should be similar in style to invalid email.
- [x] "Username must be 3 characters or longer" message persists even when username is being typed.
- [x] Bio prompt is vertically centered, but jumps to top centering
- [x] Loading spinner in messages is clipped by a square box
- [x] Users can see themselves as valid targets for friend requests in search
- [x] Firestore permission denied errors when not on stories/friends screens
- [x] Missing notification badge on "Requests" tab to indicate incoming friend requests
- [x] Permission denied error when accepting friend requests
- [x] Camera tab inaccessible - redirects to stories when clicked
- [x] Story cards always open from the first story instead of the clicked story
- [x] Snaps remain viewable after being viewed (privacy issue - should expire after one view)
- [x] Permission denied error when marking snaps as viewed due to Firestore rules
- [ ] Snapped pic and image not lining up

### Navigation routing
- [x] After sign up, I'm taken to stories (of the old user if there was one logged in), not to the "complete your profile" page.

```
Unhandled exception that stops navigation:

package:go_router/src/router.dart': Failed assertion: line 525 pos 12: 'inherited != null': No GoRouter found in context
#0 GoRouter.of (package:go_router/src/router.dart:525)
#1 GoRouterHelper.go (...)
#2 routerProvider.<anonymous closure>… (router.dart:68)

This means something tried to call context.go('/someRoute') (or similar) from a BuildContext
that isn't underneath your MaterialApp.router (or GoRouterScope).
Common causes:
Calling context.go() inside initState() or an async callback before the widget is mounted.
A provider/future that triggers navigation before the top-level GoRouter is in place.
The stack points at routerProvider in src/app/router.dart:68. Start there—make sure any
callbacks wait for WidgetsBinding.instance.addPostFrameCallback or check mounted before navigating.
Everything else—memory warnings, locale changes, Input-Method toggles—is normal Android noise.
So the app boots, Firebase works, user creation succeeds, but navigation crashes due to the missing
GoRouter context. Fix that and the rest of the flow should proceed.