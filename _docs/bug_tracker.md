# Tracker

Tracker for missing and buggy features.

## Bugs

- [ ] Wrong password/email handling should be similar in style to invalid email.
- [ ] "Username must be 3 characters or longer" message persists even when username is being typed.
- [ ] Bio prompt is vertically centered, but jumps to top centering

### Navigation routing
- [ ] After sign up, I'm taken to stories (of the old user if there was one logged in), not to the "complete your profile" page.

```
Unhandled exception that stops navigation:

package:go_router/src/router.dart': Failed assertion: line 525 pos 12: 'inherited != null': No GoRouter found in context
#0 GoRouter.of (package:go_router/src/router.dart:525)
#1 GoRouterHelper.go (...)
#2 routerProvider.<anonymous closure>… (router.dart:68)

This means something tried to call context.go('/someRoute') (or similar) from a BuildContext
that isn’t underneath your MaterialApp.router (or GoRouterScope).
Common causes:
Calling context.go() inside initState() or an async callback before the widget is mounted.
A provider/future that triggers navigation before the top-level GoRouter is in place.
The stack points at routerProvider in src/app/router.dart:68. Start there—make sure any
callbacks wait for WidgetsBinding.instance.addPostFrameCallback or check mounted before navigating.
Everything else—memory warnings, locale changes, Input-Method toggles—is normal Android noise.
So the app boots, Firebase works, user creation succeeds, but navigation crashes due to the missing
GoRouter context. Fix that and the rest of the flow should proceed.
```