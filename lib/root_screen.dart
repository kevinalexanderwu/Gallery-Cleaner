import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/models.dart';
import 'screens/finished_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/review_by_date_screen.dart';
import 'screens/review_by_location_screen.dart';
import 'screens/review_menu_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/swipe/swipe_screen.dart';
import 'state/app_controller.dart';
import 'widgets/bottom_nav.dart';
import 'screens/delete_queue_screen.dart';

/// Top-level shell: renders the current [AppScreen] and the bottom nav
/// bar when appropriate — the Flutter equivalent of the original
/// `<App />` component's screen switch.
class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);

    Widget body;
    switch (state.screen) {
      case AppScreen.splash:
        body = SplashScreen(onDone: ctrl.finishSplash);
        break;
      case AppScreen.gallery:
        body = GalleryScreen(onReview: ctrl.openReviewFromGallery);
        break;
      case AppScreen.reviewMenu:
        body = ReviewMenuScreen(onSelect: ctrl.selectReviewMode);
        break;
      case AppScreen.reviewDate:
        body = ReviewByDateScreen(onStart: ctrl.startDateGroup, onBack: ctrl.backToReviewMenu);
        break;
      case AppScreen.reviewLocation:
        body = ReviewByLocationScreen(onStart: ctrl.startLocationGroup, onBack: ctrl.backToReviewMenu);
        break;
      case AppScreen.swipe:
        body = state.swipeCtx == null
            ? const SizedBox.shrink()
            : SwipeScreen(ctx: state.swipeCtx!, onDone: ctrl.swipeDone, onBack: ctrl.swipeBack);
        break;
      case AppScreen.finished:
        body = FinishedScreen(
          counts: state.reviewCounts,
          ctx: state.swipeCtx,
          onDone: ctrl.finishedDone,
          onReviewDelete: ctrl.openDeleteQueue,
        );
        break;
      case AppScreen.deleteQueue:
        body = DeleteQueueScreen(
          photos: state.deleteQueue,
          onBack: ctrl.finishedDone,
          onRestore: ctrl.restoreSelected,
          onDelete: ctrl.deleteSelected,
        );
        break;
      case AppScreen.settings:
        body = const SettingsScreen();
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: !state.showNav,
        child: Column(
          children: [
            Expanded(child: body),
            if (state.showNav) BottomNav(active: state.activeTab, onChange: ctrl.changeTab),
          ],
        ),
      ),
    );
  }
}
