import 'package:expensetracking/screens/authentication/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneScreen extends StatelessWidget {
  PhoneScreen({Key? key}) : super(key: key);
  TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white12,
        centerTitle: true,
        title: Text(
          "Phone Login",
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoSerif(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
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
                      "assets/svg/login.svg",
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  ),
                  const SizedBox(height: 16,),
                  Text(
                    "Enter Phone Number",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Text(
                    "We will send a one time password (via SMS sent message) to your phone number",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 64),
                    child: TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.roboto(),
                      maxLength: 10,
                      onChanged: (value) {
                        // phoneNumberController.text(value);
                      },
                      decoration: InputDecoration(
                        hintText: "+91 99999 ****",
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
                    onTap: () {
                      if(phoneNumberController.text.length == 10) {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: phoneNumberController.text),)
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Invalid phone number!! Please enter valid number"),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                          // backgroundColor: Colors.grey,
                        ));
                      }
                    },
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
                              "Request OTP",
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
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}