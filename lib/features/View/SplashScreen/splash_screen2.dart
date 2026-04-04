import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mathsolving/core/AppText/app_text.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../AuthScreen/singin_screen.dart';
import '../LanguageScreen/language_screen.dart';



class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen2> {
  int activeIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // Center content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.logo7, height: 500,width: 380,),
                const SizedBox(height: 8,),
                Text(AppStrings.splashmaintext,style: TextStyle(fontSize: 24,color: Color(0xFF2B3A5D),),),
                const SizedBox(height: 12,),
                Text(AppStrings.splashsecoundtext,
                  style: TextStyle(fontSize: 17,color: Color(0xFF2B3A5D),),
                  textAlign: TextAlign.center,

                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SelectLanguageScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B3A5D),// button color
                      elevation: 0, // default shadow off
                      shadowColor: Colors.black.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      shadowColor: WidgetStateProperty.all(
                        const Color(0x40000000), // #00000040
                      ),
                      elevation: WidgetStateProperty.all(10),
                    ),
                    child:  Text(
                      AppStrings.Continue,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                // Dot Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: index == activeIndex
                            ? Colors.black12  // active dot
                            : AppColors.instance.mainBtnColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}