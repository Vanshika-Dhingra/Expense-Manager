import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpScreen extends StatefulWidget {
  final String? phoneNumber;
  const OtpScreen({Key? key, @required this.phoneNumber}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  FirebaseAuth? firebaseAuth;
  TextEditingController? otpController = TextEditingController();

  String? verificationId;

  @override
  void initState() {
    // TODO: implement initState
    firebaseAuth = FirebaseAuth.instance;
    verifyPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white12,
        centerTitle: true,
        title: Text(
          "Verification Code",
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoSerif(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.black, size: 32,),
        ),
      ),
      body: LayoutBuilder(
        builder: (lyContext, constraint) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.minHeight),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/svg/otp.svg",
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  ),
                  const SizedBox(height: 16,),
                  Text(
                    "Enter Code",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Text(
                    "We have send code to your phone number",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Text(
                    "+91 ${widget.phoneNumber ?? ''}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    child: TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.roboto(
                        letterSpacing: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "*****",
                        counterText: "",
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500, width: 1),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        focusColor: Colors.red.shade400,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        hintStyle: GoogleFonts.roboto(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: signUserWithPhoneNumber,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Verify Phone Number",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_double_arrow_right, color: Colors.white,)
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: verifyPhoneNumber,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      width: MediaQuery.of(context).size.width,
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600
                          ),
                          children: [
                            const TextSpan(
                              text: "Didn't Get Code? ",
                            ),
                            TextSpan(
                              text: "Resend Code",
                              style: GoogleFonts.openSans(
                                color: Colors.blue
                              )
                            ),
                          ]
                        ),
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Future<void> verifyPhoneNumber() async {
    return await firebaseAuth?.verifyPhoneNumber(
      phoneNumber: "+91${widget.phoneNumber}",
      timeout: const Duration(seconds: 60),
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrieval,
    );
  }

  _onVerificationCompleted(AuthCredential authCredential) {}

  _onVerificationFailed(FirebaseAuthException error) {
    print(error);
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
  }

  _codeAutoRetrieval(String verificationId) {}

  signUserWithPhoneNumber() {
    AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: otpController!.text);
    CommonClass().showLoadingErrorModalBottomSheet(context);
    firebaseAuth!.signInWithCredential(credential)
      .then((res) async {
        Navigator.pop(context);
        Navigator.pop(context);
    })
      .catchError((error) {
        print(error);
    });
  }
}
