import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactScreen extends StatelessWidget {
  bool isVendor = true;
  ContactScreen({Key? key, this.isVendor = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UIConstants.borderRadius16),
          topRight: Radius.circular(UIConstants.borderRadius16)
        )
      ),
      child: FutureBuilder(
        future: ContactsService.getContacts(withThumbnails: true),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return _showContactList(snapshot, context);
        },
      ),
    );
  }

  void _saveUserContactToFirebase(Contact contact, int phoneIdx, BuildContext context) {
    Map<String, dynamic> userContact = {
      'name': contact.displayName,
      'phone': contact.phones!.elementAt(phoneIdx).value!.replaceAll(" ", ""),
      'createdOn': Timestamp.now()
    };
    Navigator.pop(context, userContact);
  }

  Widget _showContactList(AsyncSnapshot<List<Contact>> snapshot, BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.padding16, vertical: UIConstants.padding12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Contacts\n",
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black
                      ),
                    ),
                    TextSpan(
                      text: "Total: ${snapshot.data!.length ?? 0}",
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey
                      ),
                    )
                  ]
                )),
                InkWell(
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
                )
              ],
            ),
          ),
          Expanded(
            child: snapshot.data!.isEmpty ? Container() : ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, mainIdx) {
                Contact contact = snapshot.data!.elementAt(mainIdx);
                if(contact.phones!.isEmpty) return Container();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contact.phones!.length,
                  itemBuilder: (context, phoneIdx) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(UIConstants.borderRadius12),
                      // color: const Color(0xFFF1F1F1)
                    ),
                    child: ListTile(
                      onTap: () => _saveUserContactToFirebase(contact, phoneIdx, context),
                      leading: contact.avatar != null && contact.avatar!.isNotEmpty ?
                        CircleAvatar(backgroundImage: MemoryImage(contact.avatar!)) :
                        CircleAvatar(child: Text(contact.initials(), style: GoogleFonts.openSans()),),
                      title: Text(
                        contact.displayName ?? "",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black
                        ),
                      ),
                      subtitle: Text(
                        contact.phones!.elementAt(phoneIdx).value ?? "",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey.shade500
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
