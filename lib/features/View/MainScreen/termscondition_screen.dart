
// ═══════════════════════════════════════════════════
//  TERMS AND PRIVACY POLICY SCREEN
// ═══════════════════════════════════════════════════
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/AppColor/app_color.dart';
import '../../../core/AppText/app_text.dart';

class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.instance;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: c.titleTextColor, size: 20.sp),
        ),
        title: Text(
          AppStrings.policytext,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: c.titleTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _policyHeading('Privacy Policy of [ Pickfair, e.g., www.example.com]', c),
            SizedBox(height: 10.h),
            _policyBody(
              'Effective Date: [Insert Date, e.g., December 29, 2025]\nLast Updated: [Insert Date]',
              c,
            ),
            SizedBox(height: 14.h),
            _policyBody(
              'This Privacy Policy describes how [Your Company Name] ("we," "us," or "our") collects, uses, discloses, and protects your personal information when you visit our website [www.example.com], use our mobile application [App Name], or engage with our services (collectively, the "Services"). We are committed to protecting your privacy and complying with applicable data protection laws worldwide, including but not limited to the General Data Protection Regulation (GDPR) in the European Union, the California Consumer Privacy Act (CCPA) as amended by the California Privacy Rights Act (CPRA), the Brazilian General Data Protection Law (LGPD), and comprehensive consumer privacy laws in various US states (as detailed below). We also adhere to other global frameworks where applicable, such as PIPEDA (Canada), FADP (Switzerland), PDPA (Singapore), POPIA (South Africa), and equivalents in regions like Australia (Privacy Act), Japan (APPI), and India (DPDP Act).',
              c,
            ),
            SizedBox(height: 14.h),
            _policyBody(
              'If you are a resident of a specific jurisdiction, additional provisions may apply as outlined in the sections below. This policy may be updated periodically; we will notify you of significant changes via email or a prominent notice on our Services.',
              c,
            ),
            SizedBox(height: 20.h),
            _policyHeading('1. Contact Information', c),
            SizedBox(height: 8.h),
            _bulletPoint('Data Controller/Owner: [Your Company Name], [Your Company Address, e.g., 123 Main St, Anytown, USA].', c),
            _bulletPoint('Email: [privacy@example.com]', c),
            _bulletPoint('Phone: [Your Phone Number]', c),
            _bulletPoint('Data Protection Officer (if required under GDPR/LGPD): [Name/Email, if applicable]', c),
            SizedBox(height: 20.h),
            _policyHeading('2. Information We Collect', c),
            SizedBox(height: 8.h),
            _policyBody(
              'We collect the following categories of personal information, depending on your interactions with our Services:',
              c,
            ),
            SizedBox(height: 10.h),
            _policyHeading('a. Information You Provide Directly', c),
            SizedBox(height: 6.h),
            _bulletPoint('Account Information: Name, email address, password, phone number, and profile picture when you register.', c),
            _bulletPoint('Payment Information: Credit/debit card details, billing address, processed securely through third-party payment processors (e.g., Stripe, PayPal).', c),
            _bulletPoint('Communications: Messages, feedback, or support requests you send us.', c),
            _bulletPoint('User-Generated Content: Photos, reviews, or other content you submit.', c),
            SizedBox(height: 20.h),
            _policyHeading('3. How We Use Your Information', c),
            SizedBox(height: 8.h),
            _policyBody(
              'We use your information for the following purposes, based on the legal bases indicated:',
              c,
            ),
            SizedBox(height: 10.h),
            _bulletPoint('Service Delivery: To provide, maintain, and improve our Services (Legal Basis: Contract Performance).', c),
            _bulletPoint('Communication: To send transactional emails, updates, and respond to inquiries (Legal Basis: Contract Performance, Legitimate Interests).', c),
            _bulletPoint('Personalization: To tailor content and recommendations (Legal Basis: Legitimate Interests, Consent).', c),
            _bulletPoint('Analytics: To analyze usage patterns and improve user experience (Legal Basis: Legitimate Interests).', c),
            _bulletPoint('Legal Compliance: To meet legal obligations, such as tax reporting (Legal Basis: Legal Obligation).', c),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _policyHeading(String text, AppColors c) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: c.titleTextColor,
        height: 1.4,
        decoration: text.contains('www.') || text.contains('@')
            ? TextDecoration.underline
            : null,
      ),
    );
  }

  Widget _policyBody(String text, AppColors c) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5.sp,
        color: c.normalTextColor,
        height: 1.6,
      ),
    );
  }

  Widget _bulletPoint(String text, AppColors c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5.h, right: 8.w),
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: c.titleTextColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: c.normalTextColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}