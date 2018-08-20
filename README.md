# AppStoreiOS11Transition

Just another attempt to simulate App Store's Card transition.

![demo](https://raw.githubusercontent.com/aunnnn/AppStoreiOS11InteractiveTransition/master/appstoreios11.gif)

You can also check out my previous approach [here](https://github.com/aunnnn/AppStoreiOS11InteractiveTransition_old). This one is a total rewrite and has better effect/performance/code.

## Overview
All is done with native APIs (`UIViewControllerAnimatedTransitioning`, etc.), no external libraries.

Interesting transitioning stuffs here:
- `PresentCardAnimator`: Animation code for presentation,
- `DismissCardAnimator`: Animation code for dismissal,
- `CardPresentationController`: Blur effect view and overall aspect of the presentation,
- `CardDetailViewController`: Interactive shrinking pan gesture code.

Here are some implementation details:

### HomeViewController
- The card cell needs to be very responsive to touch, so we must set `collectionView.delaysContentTouch = true`,
- Then in `touchesBegan` and `touchesCancellled/Ended` I add highlighting animation code there,
- `.allowsUserInteraction` is needed in highlighting animation, so that you can continue to scroll immediately while the unhighlighted animation is taking place.

### Presentation
- TBD...

### Dismissing
- TBD...
