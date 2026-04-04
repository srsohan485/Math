import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // ── Common ───────────────────────────────────────────
      'Continue'                   : 'Continue',
      'Submit'                     : 'Submit',
      'Send OTP'                   : 'Send OTP',
      'Log out'                    : 'Log out',
      'Login or Sign up'           : 'Login or Sign up',
      'cancel'                     : 'Cancel',
      'save'                       : 'Save',
      'delete'                     : 'Delete',
      'rename'                     : 'Rename',
      'today'                      : 'Today',
      'or'                         : 'or',
      'Confirm'                    : 'Confirm',
      'Try Again'                  : 'Try Again',
      'Forgot Password'            : 'Forgot Password',

      // ── Splash ───────────────────────────────────────────
      'Ask. Snap. Learn.'          : 'Ask. Snap. Learn.',
      'splash_sub'                 : 'Type or snap a photo of your math problem and let your AI tutor do the rest',

      // ── Auth ─────────────────────────────────────────────
      'Sign In'                    : 'Sign In',
      'Sign Up'                    : 'Sign Up',
      'Select language'            : 'Select language',
      'Email'                      : 'Email',
      'Password'                   : 'Password',
      'Forgot password?'           : 'Forgot password?',
      "Don't have an account?"     : "Don't have an account?",
      'Username'                   : 'Username',
      'Re-type your password'      : 'Re-type your password',
      'by_clicking'                : 'By clicking the "sign up" button, you accept the terms of the Privacy Policy.',
      'Already have an account?'   : 'Already have an account?',
      'Email Verified !'           : 'Email Verified !',
      'email_confirmed'            : 'Your email address has been successfully verified',
      'Enter OTP'                  : 'Enter OTP',
      'Enter 6 digit OTP'          : 'Enter 6 digit OTP',
      'otp_info'                   : 'We sent a verification code to your email. Please check. If not, resend in 0:22 minutes. Resend',
      'Reset Your Password'        : 'Reset Your Password',
      'signup_otp_subtitle'        : 'We sent a code to verify your email address.',
      'forgot_otp_subtitle'        : 'We sent a code to reset your password.',
      'resend_info_prefix'         : 'We sent a verification code to your email. Please check. If not, resend in ',
      'resend_info_suffix'         : ' minutes. ',
      'Resend'                     : 'Resend',

      // ── Drawer / Navigation ──────────────────────────────
      'New chat'                   : 'New chat',
      'Profile'                    : 'Profile',
      'Terms and privacy policy'   : 'Terms and privacy policy',
      'History'                    : 'History',
      'No chats yet'               : 'No chats yet',
      'chat_hash'                  : 'Chat #',

      // ── Logout dialog ────────────────────────────────────
      'logout_title'               : 'Logout?',
      'logout_confirm'             : 'Are you sure you want to log out of your account?',

      // ── Rename dialog ────────────────────────────────────
      'rename_chat'                : 'Rename Chat',
      'rename_hint'                : 'Enter a chat name...',

      // ── Delete dialog ────────────────────────────────────
      'delete_chat_title'          : 'Delete Chat?',
      'delete_chat_confirm'        : 'This chat will be permanently deleted.',

      // ── Empty / home ─────────────────────────────────────
      'What can I help with ?'     : 'What can I help with ?',

      // ── Input bar ────────────────────────────────────────
      'Ask anything'               : 'Ask anything',

      // ── Image preview ────────────────────────────────────
      'image_ready'                : 'Image ready',

      // ── Audio preview ────────────────────────────────────
      'voice_ready'                : 'Voice message ready',
      'tap_send_upload'            : 'Tap send to upload',

      // ── Audio bubble ─────────────────────────────────────
      'voice_message'              : 'Voice Message',
      'playing'                    : 'Playing...',
      'tap_to_play'                : 'Tap to play',
      'tap_to_stop'                : 'Tap to stop',

      // ── Main (misc) ──────────────────────────────────────
      'Join to save your chats'    : 'Join to save your chats',
      'Privacy Policy of Pickfair' : 'Privacy Policy of Pickfair Such as social media platforms, advertising partners, or payment processors, with',
      'Edit'                       : 'Edit',
      'Delete account'             : 'Delete account',
      'edit_username_hint'         : 'Enter new username',
      'delete_account_confirm'     : 'Are you sure you want to delete your account? This action cannot be undone.',
    },

    'bg': {
      // ── Common ───────────────────────────────────────────
      'Continue'                   : 'Продължи',
      'Submit'                     : 'Изпрати',
      'Send OTP'                   : 'Изпрати OTP',
      'Log out'                    : 'Излез',
      'Login or Sign up'           : 'Вход или Регистрация',
      'cancel'                     : 'Отказ',
      'save'                       : 'Запази',
      'delete'                     : 'Изтрий',
      'rename'                     : 'Преименувай',
      'today'                      : 'Днес',
      'or'                         : 'или',
      'Confirm'                    : 'Потвърди',
      'Try Again'                  : 'Опитайте отново',
      'Forgot Password'            : 'Забравена парола',

      // ── Splash ───────────────────────────────────────────
      'Ask. Snap. Learn.'          : 'Питай. Снимай. Учи.',
      'splash_sub'                 : 'Въведете или снимайте математическата задача и нека вашият AI учител се справи с останалото',

      // ── Auth ─────────────────────────────────────────────
      'Sign In'                    : 'Вход',
      'Sign Up'                    : 'Регистрация',
      'Select language'            : 'Изберете език',
      'Email'                      : 'Имейл',
      'Password'                   : 'Парола',
      'Forgot password?'           : 'Забравена парола?',
      "Don't have an account?"     : 'Нямате акаунт?',
      'Username'                   : 'Потребителско име',
      'Re-type your password'      : 'Въведете паролата отново',
      'by_clicking'                : 'Като щракнете върху бутона "регистрация", вие приемате условията на Политиката за поверителност.',
      'Already have an account?'   : 'Вече имате акаунт?',
      'Email Verified !'           : 'Имейлът е потвърден!',
      'email_confirmed'            : 'Вашият имейл адрес беше успешно потвърден',
      'Enter OTP'                  : 'Въведете OTP',
      'Enter 6 digit OTP'          : 'Въведете 6-цифрен OTP',
      'otp_info'                   : 'Изпратихме код за потвърждение на вашия имейл. Моля, проверете. Ако не, изпратете отново след 0:22 минути. Изпрати отново',
      'Reset Your Password'        : 'Нулирайте паролата си',
      'signup_otp_subtitle'        : 'Изпратихме код за потвърждение на вашия имейл адрес.',
      'forgot_otp_subtitle'        : 'Изпратихме код за нулиране на паролата ви.',
      'resend_info_prefix'         : 'Изпратихме код за потвърждение на вашия имейл. Моля, проверете. Ако не, изпратете отново след ',
      'resend_info_suffix'         : ' минути. ',
      'Resend'                     : 'Изпрати отново',

      // ── Drawer / Navigation ──────────────────────────────
      'New chat'                   : 'Нов чат',
      'Profile'                    : 'Профил',
      'Terms and privacy policy'   : 'Условия и политика за поверителност',
      'History'                    : 'История',
      'No chats yet'               : 'Няма чатове все още',
      'chat_hash'                  : 'Чат #',

      // ── Logout dialog ────────────────────────────────────
      'logout_title'               : 'Изход?',
      'logout_confirm'             : 'Сигурни ли сте, че искате да излезете от акаунта си?',

      // ── Rename dialog ────────────────────────────────────
      'rename_chat'                : 'Преименувай чат',
      'rename_hint'                : 'Въведете име на чата...',

      // ── Delete dialog ────────────────────────────────────
      'delete_chat_title'          : 'Изтриване на чат?',
      'delete_chat_confirm'        : 'Този чат ще бъде изтрит за постоянно.',

      // ── Empty / home ─────────────────────────────────────
      'What can I help with ?'     : 'С какво мога да помогна?',

      // ── Input bar ────────────────────────────────────────
      'Ask anything'               : 'Питайте каквото искате',

      // ── Image preview ────────────────────────────────────
      'image_ready'                : 'Изображението е готово',

      // ── Audio preview ────────────────────────────────────
      'voice_ready'                : 'Гласово съобщение готово',
      'tap_send_upload'            : 'Натиснете изпрати за качване',

      // ── Audio bubble ─────────────────────────────────────
      'voice_message'              : 'Гласово съобщение',
      'playing'                    : 'Възпроизвежда се...',
      'tap_to_play'                : 'Натиснете за пускане',
      'tap_to_stop'                : 'Натиснете за спиране',

      // ── Main (misc) ──────────────────────────────────────
      'Join to save your chats'    : 'Присъединете се, за да запазите чатовете си',
      'Privacy Policy of Pickfair' : 'Политика за поверителност на Pickfair, като платформи за социални медии, рекламни партньори или платежни процесори, с',
      'Edit'                       : 'Редактирай',
      'Delete account'             : 'Изтрий акаунт',
      'edit_username_hint'         : 'Въведете ново потребителско име',
      'delete_account_confirm'     : 'Сигурни ли сте, че искате да изтриете акаунта си? Това действие не може да бъде отменено.',
    },
  };
}