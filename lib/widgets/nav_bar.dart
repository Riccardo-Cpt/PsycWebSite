import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'nav_drawer.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final double scrollOffset;
  final bool drawerOpen;
  final VoidCallback onToggleDrawer;

  const NavBar({
    super.key,
    this.scrollOffset = 0,
    this.drawerOpen = false,
    required this.onToggleDrawer,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final t = (scrollOffset / 80.0).clamp(0.0, 1.0);
    final bgColor =
        Color.lerp(const Color(0x00EBEBEB), const Color(0xF0EBEBEB), t)!;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      elevation: t * 2.0,
      scrolledUnderElevation: 0,
      toolbarHeight: 60,
      title: InkWell(
        onTap: () => context.go('/'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/firma.png',
              width: 270,  // Desired width
              fit: BoxFit.fitWidth,  // Scales to fill width, height follows aspect ratio
              errorBuilder: (_, _, _) => const Text(
                'Dr.ssa Maria Bianchi',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (MediaQuery.of(context).size.width >= 600)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Center(
              child: Text(
                'Naviga nel sito',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
          child: IconButton(
            key: ValueKey(drawerOpen),
            icon: Icon(drawerOpen ? Icons.close : Icons.menu),
            tooltip: drawerOpen ? 'Chiudi menu' : 'Menu',
            onPressed: onToggleDrawer,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// Convenience wrapper: Scaffold + custom animated NavDrawer overlay.
class NavScaffold extends StatefulWidget {
  final Widget body;
  final Color? backgroundColor;
  const NavScaffold({super.key, required this.body, this.backgroundColor});

  @override
  State<NavScaffold> createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<NavScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideAnim;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_ctrl.isCompleted) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
  }

  void _close() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final offset = notification.metrics.pixels.clamp(0.0, 80.0);
        if ((offset - _scrollOffset).abs() > 0.5) {
          setState(() => _scrollOffset = offset);
        }
        return false;
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Scaffold(
          appBar: NavBar(
            scrollOffset: _scrollOffset,
            drawerOpen: _ctrl.value > 0.01,
            onToggleDrawer: _toggle,
          ),
          backgroundColor: const Color(0xFFFFFFF0),
          body: Stack(
            children: [
              widget.body,
              // Scrim
              if (_ctrl.value > 0)
                GestureDetector(
                  onTap: _close,
                  child: Container(
                    color: Colors.black
                        .withValues(alpha: 0.3 * _ctrl.value),
                  ),
                ),
              // Slide-in panel from right
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _slideAnim,
                  child: NavDrawer(onClose: _close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
