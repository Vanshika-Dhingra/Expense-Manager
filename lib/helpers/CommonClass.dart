import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonClass {
  static Widget getNavigatorRowItem({ String rowTitle = "", bool isLastItem = false, IconData icon = Icons.chevron_right }) {
    return Container(
      padding: const  EdgeInsets.symmetric(vertical: UIConstants.padding8, horizontal: UIConstants.padding12),
      decoration: BoxDecoration(
          border: !isLastItem ? Border(bottom: BorderSide(color: Colors.grey.shade300)) : null
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            rowTitle,
            style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500
            ),
          ),
          Icon(
            icon,
            color: icon == Icons.chevron_right ? Colors.grey.shade400 : Colors.grey.shade800,
          )
        ],
      ),
    );
  }
  
  void showLoadingErrorModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.1,
        padding: const EdgeInsets.all(UIConstants.padding16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(UIConstants.borderRadius16),
              topLeft: Radius.circular(UIConstants.borderRadius16)
          ),
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(strokeWidth: 2.25,)
            ),
            const SizedBox(width: 12),
            Text(
              "Processing your request. Please wait",
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16
              ),
            )
          ],
        ),
      ),
    );
  }

  static Future<dynamic> openModalBottomSheet(BuildContext context, {
    Widget? child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => child ?? Container(),
    );
  }

  static void openErrorDialog({
    BuildContext? context,
    String message = "",
    bool isPermissionError = false
  }) {
    showDialog(
      context: context!,
      useSafeArea: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius16),
        ),
        child: Container(
          height: isPermissionError ? 350 : 320,
          padding: const EdgeInsets.all(UIConstants.padding8),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 32,
                    width: 32,
                    // padding: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.all(Radius.circular(12))
                    ),
                    child: const Icon(Icons.close, size: 18,),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SvgPicture.asset(
                "assets/svg/error.svg",
                height: 150,
              ),
              const SizedBox(height: 18),
              Text(
                isPermissionError ? "Insufficient Permissions" : "Error!!",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontSize: isPermissionError ? 20 : 28,
                    fontWeight: FontWeight.w700
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.openSans(
                    fontSize: 16
                ),
              ),
              isPermissionError ? const SizedBox(height: 18) : const SizedBox(),
              isPermissionError ? ElevatedButton(
                onPressed: () {
                  openAppSettings();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UIConstants.borderRadius12)
                    )),
                    backgroundColor: MaterialStateProperty.all(Colors.red.shade400)
                ),
                child: Text(
                  "Open Settings",
                  style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600
                  ),
                ),
              ) : Container()
            ],
          ),
        ),
      ),
    );
  }
  
  static Widget emptyScreen() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svg/empty.svg",
            height: 250,
          ),
          const SizedBox(height: 24),
          Text(
            "Sorry! No Records found",
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: 24
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Please add new record",
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey
            ),
          )
        ],
      ),
    );
  }
}