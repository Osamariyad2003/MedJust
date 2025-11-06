import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/routes/routers.dart';
import 'package:med_just/core/shared/themes/app_colors.dart';
import 'package:med_just/features/guidies/presentation/screens/chat_screen.dart';
import 'package:med_just/features/resourses/presentation/widgets/file_webview_screen.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_bloc.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_event.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_state.dart';
import 'package:med_just/features/sidebar/presentation/widgets/nav_button.dart';
import 'package:shimmer/shimmer.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double padding = screenWidth * 0.04;
    double iconSize = screenHeight * 0.04;
    double avatarRadius =
        screenHeight * 0.06; // 6% of screen height for avatar radius
    double fontSize =
        screenHeight * 0.022; // 2.2% of screen height for font size

    return Drawer(
      child: BlocConsumer<SideBarBloc, SideBarStates>(
        listener: (BuildContext context, state) async {},
        builder: (context, state) {
          var bloc = context.read<SideBarBloc>();
          String selectedMenu =
              state is MenuSelectedState ? state.selectedMenu : 'Home';
          return SingleChildScrollView(
            child: Column(
              children: [
                ConditionalBuilder(
                  condition: bloc.name != null,
                  builder:
                      (context) => Container(
                        height: screenHeight * 0.25,
                        color: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: padding,
                          horizontal: padding,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  bloc.imagePath != null
                                      ? NetworkImage("${bloc.imagePath}")
                                      : null,
                              child:
                                  bloc.imagePath == null
                                      ? Icon(
                                        Icons.person,
                                        size: iconSize,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            SizedBox(width: padding),
                            Text(
                              '${bloc.name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  fallback:
                      (context) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade600,
                        highlightColor: Colors.grey.shade100,
                        enabled: true,
                        child: Container(
                          height:
                              screenHeight *
                              0.25, // 25% of screen height for header
                          color: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: padding,
                            horizontal: padding,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(radius: avatarRadius),
                              SizedBox(width: padding),
                              SizedBox(height: fontSize),
                            ],
                          ),
                        ),
                      ),
                ),

                SizedBox(height: padding), // Space below header
                Divider(thickness: 1, color: Colors.grey.shade300),
                SizedBox(height: padding), // Space above first button
                // Navigation Buttons
                NavButton(
                  title: 'Home',
                  icon: Icons.home,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Home',
                  onTap: () {
                    bloc.add(SelectMenuEvent("Home"));
                    Navigator.pushNamed(context, Routers.homeRoute);
                  },
                ),
                SizedBox(height: padding * 0.7),

                NavButton(
                  title: 'Notes',
                  icon: Icons.note,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Notes',
                  onTap: () {
                    bloc.add(SelectMenuEvent('Notes'));
                    Navigator.pushNamed(context, Routers.gpaCalculatorRoute);
                  },
                ),
                SizedBox(height: padding * 0.7),

                NavButton(
                  title: 'Professors',
                  icon: Icons.favorite_border,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Professors',
                  onTap: () {
                    bloc.add(SelectMenuEvent("Professors"));
                    Navigator.pushNamed(context, Routers.professorsRoute);
                  },
                ),
                SizedBox(height: padding * 0.7),

                NavButton(
                  title: 'Guidelines',
                  icon: Icons.favorite_border,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Guidelines',
                  onTap: () {
                    bloc.add(SelectMenuEvent("Guidelines"));
                    Navigator.pushNamed(context, Routers.guide);
                  },
                ),
                SizedBox(height: padding * 0.7),
                NavButton(
                  title: 'Pomodoro',
                  icon: Icons.timer,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Pomodoro',
                  onTap: () {
                    bloc.add(SelectMenuEvent("Pomodoro"));
                    Navigator.pushNamed(context, Routers.pomodoro);
                  },
                ),
                SizedBox(height: padding * 0.7),

                NavButton(
                  title: 'Azkar',
                  icon: Icons.save,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Azkar',
                  onTap: () {
                    bloc.add(SelectMenuEvent("Azkar"));
                    Navigator.pushNamed(context, Routers.azkarRoute);
                  },
                ),
                SizedBox(height: padding * 0.7),
                NavButton(
                  title: 'Research Form',
                  icon: Icons.save,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Research Form',
                  onTap: () {
                    bloc.add(SelectMenuEvent("Research Form"));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FileWebViewScreen(
                              url:
                                  "https://docs.google.com/forms/d/e/1FAIpQLSex39HJNnVm8BVXTjT94W0S8kSRNJtDjMrcHYH1AgIuVXtrHg/viewform",
                              title: 'Research Form',
                            ),
                      ),
                    );
                  },
                ),
                SizedBox(height: padding * 0.7),

                NavButton(
                  title: 'University Map',
                  icon: Icons.map,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'University Map',
                  onTap: () {
                    bloc.add(SelectMenuEvent("University Map"));
                    Navigator.pushNamed(context, Routers.universityMapRoute);
                  },
                ),
                SizedBox(height: padding * 0.7),
                NavButton(
                  title: 'GPA Calculator',
                  icon: Icons.calculate,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'GPA Calculator',
                  onTap: () {
                    bloc.add(SelectMenuEvent("GPA Calculator"));
                    Navigator.pushNamed(context, Routers.gpaCalculatorRoute);
                  },
                ),
                SizedBox(height: padding * 2),
                NavButton(
                  // Extra space at bottom
                  title: 'Sign Out',
                  icon: Icons.logout,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  isSelected: selectedMenu == 'Sign Out',
                  onTap: () {
                    bloc.add(SignOutEvent());
                    Navigator.pushNamed(context, Routers.loginRoute);
                  },
                ),
                SizedBox(height: padding * 2), // Extra space at bottom
              ],
            ),
          );
        },
      ),
    );
  }
}
