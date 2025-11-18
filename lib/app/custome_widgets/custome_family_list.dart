// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wahat_al_shifa/app/custome_widgets/custome_no_data.dart';
// import 'package:wahat_al_shifa/app/helpers/date_helper.dart';
// import '../custome_widgets/custome_textbox_label.dart';
// import '../helpers/shared_preferences.dart';
// import '../theme/app_theme.dart';

// class CommonFamilyListController extends GetxController {
//   //final repository = AppointmentRepository();

//   RxBool isLoading = false.obs;

//   final ScrollController scrollController = ScrollController();
//   int currentPage = 1;
//   bool hasMoreData = true;
//   RxString searchkey = "".obs;

//   RxList familyList = [].obs; // this is Used to store the filtered from response list
//   RxList familyListOriginal = [].obs; // this is Used to store response list for first time
//   // RxList familyListByString = [].obs; // this is Used to store the response list when search count is 3 char
//   RxString prevThreeCharString = "".obs;

//   final TextEditingController searchController = TextEditingController();

//   RxString contactTypeId = "".obs;
//   RxBool onlyEmployeesList = false.obs;
//   int totalReamingCount = 0;

//   @override
//   void onInit() async {
//     super.onInit();

//     await postGetMobFamilyMembers();
//     searchController.text = "";
//   }

//   void pagination({String? leadTypeKeyId}) async {
//     // ignore: invalid_use_of_protected_member
//     if (!scrollController.hasListeners) {
//       scrollController.addListener(() async {
//         if (scrollController.position.pixels == scrollController.position.maxScrollExtent && hasMoreData) {
//           currentPage++;
//           // if (searchkey.value.isEmpty && searchkey.value.length < 3) {
//           await postGetMobFamilyMembers();
//           // }
//         }
//       });
//     }
//   }

//   Future<void> postGetMobFamilyMembers() async {
//     try {
//       isLoading.value = true;
//       String accountId = await SharedPrefsHelper.getString(SharedPrefsHelper.accountId);
//       var data = {"locationId": 1, "patientId": accountId};
//       var resp = await repository.postGetMobFamilyMembers(data);

//       if (resp.data != null) {
//         var getApiData = FamilyMembersModel.fromJson(resp.data);

//         familyListOriginal.assignAll(getApiData.data!.loadFamilyMember);
//         // familyList.assignAll(getApiData.data!.loadFamilyMember);
//         familyList.assignAll(getApiData.data!.loadFamilyMember);
//       } else {}
//       isLoading.value = false;
//     } catch (error) {
//       isLoading.value = false;
//       print("Error in postGetMobFamilyMembers: $error");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void localFilter(String value) {
//     if (value.isEmpty) {
//       familyList.assignAll(familyListOriginal);
//     } else {
//       final filtered = familyListOriginal.where((item) {
//         final name = item.patientName?.toLowerCase() ?? '';
//         return name.contains(value.toLowerCase());
//       }).toList();

//       familyList.assignAll(filtered); // Show only matching items
//     }
//   }
// }

// class CommonFamilyListSearch extends StatelessWidget {
//   // const CommonDialogContactSearch({super.key});

//   // final CommonDialogContactSearchController controller = Get.put(CommonDialogContactSearchController());
//   // final String leadTypeKeyId;

//   // const CommonDialogContactSearch({super.key, required this.leadTypeKeyId});
//   final CommonFamilyListController controller;
//   final String patientId;

//   CommonFamilyListSearch({
//     super.key,
//     this.patientId = "",
//   }) : controller = Get.put(CommonFamilyListController());

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final dialogWidth = screenWidth * 0.85;
//     final dialogHeight = screenHeight * 0.75;
//     final customTheme = CustomTheme.of(context);
//     final textTheme = Theme.of(context).textTheme;

//     // controller.leadTypeId.value = leadTypeKeyId;
//     // if (leadTypeKeyId == Constants.contactEmp) {
//     //   // If Only Employees - 11
//     //   controller.onlyEmployeesList.value = true;
//     // }
//     // controller.getAllContacts(leadTypeKeyId: leadTypeKeyId);

//     return Dialog(
//       child: Container(
//         width: dialogWidth,
//         height: dialogHeight,
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12), // Optional: Adjust the border radius
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: CustomeTextBoxLabel(
//                       hintText: "Search Member".tr,
//                       controller: controller.searchController,
//                       onChanged: (value) {
//                         controller.localFilter(value ?? "");
//                         controller.searchkey.value = value ?? "";
//                         return null;
//                       },
//                       onTap: () {
//                         // onSearchChanged();
//                       },
//                       suffixIcon: Icon(
//                         Icons.search_outlined,
//                         color: customTheme.textDefault,
//                       )),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     Icons.close,
//                     size: 25,
//                     color: customTheme.textLightGray,
//                   ),
//                   onPressed: () {
//                     Get.back();
//                     // Get.back(result: 'Hello from Screen B');
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       Get.delete<CommonFamilyListController>();
//                     });

//                     // Get.delete<CommonDialogContactSearchController>();
//                   },
//                 ),
//               ],
//             ),
//             const Divider(),
//             Expanded(
//               child: Obx(
//                 () => controller.isLoading.value
//                     ? const Center(child: CircularProgressIndicator())
//                     : (controller.familyList.isNotEmpty)
//                         ? ListView.separated(
//                             controller: controller.scrollController,
//                             separatorBuilder: (context, index) {
//                               return const Divider();
//                             },
//                             itemCount: controller.familyList.length, //controller.familyList.length,
//                             itemBuilder: (context, index) {
//                               if (index == controller.familyList.length) {
//                                 if (controller.searchkey.value.isEmpty) {
//                                   return const Center(child: CircularProgressIndicator());
//                                 }
//                               }
//                               if (index >= 0 && index < controller.familyList.length) {
//                                 LoadFamilyMember item = controller.familyList[index];
//                                 // final key = item.contactId;
//                                 final patientId = item.patientId;
//                                 final patientName = item.patientName;
//                                 final nationalityId = item.nationalityId;
//                                 final nationality = item.nationality;
//                                 final dob = item.dob;
//                                 final mobile = item.mobile;
//                                 final relation = item.relation;
//                                 final gender = item.gender;

//                                 return InkWell(
//                                   onTap: () {
//                                     Get.back(result: item);
//                                     Get.delete<CommonFamilyListController>();
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.all(5),
//                                     child: InkWell(
//                                       onTap: () {
//                                         Get.back(result: item);
//                                         Get.delete<CommonFamilyListController>();
//                                       },
//                                       child: Row(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Flexible(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   patientName ?? '',
//                                                   style: TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight: FontWeight.w500,
//                                                     color: customTheme.textLightGray,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 3),
//                                                 Row(
//                                                   children: [
//                                                     Text(
//                                                       gender,
//                                                       style: TextStyle(
//                                                         fontSize: textTheme.labelMedium?.fontSize,
//                                                         fontWeight: FontWeight.w400,
//                                                         color: customTheme.textLightGray,
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       ",  DOB: ${dateWithFormat(dob.toString(), dateToShow)}",
//                                                       style: TextStyle(
//                                                         fontSize: textTheme.labelMedium?.fontSize,
//                                                         fontWeight: FontWeight.w400,
//                                                         color: customTheme.textLightGray,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return null;
//                             },
//                           )
//                         : Center(
//                             child: noDataAvailable(),
//                           ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FamilyMembersModel {
//   FamilyMembersModel({
//     this.message = '',
//     this.emessage = '',
//     this.statusCode = 200,
//     this.data,
//   });

//   String message = '';
//   String emessage = '';
//   int statusCode = 200;
//   FamilyMember? data;

//   factory FamilyMembersModel.fromJson(Map<String, dynamic> json) {
//     return FamilyMembersModel(
//       message: json["message"] ?? "",
//       emessage: json["emessage"] ?? "",
//       statusCode: json["statusCode"] ?? 0,
//       data: json["data"] == null ? null : FamilyMember.fromJson(json["data"]),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "message": message,
//         "emessage": emessage,
//         "statusCode": statusCode,
//         "data": data?.toJson(),
//       };
// }

// class FamilyMember {
//   FamilyMember({
//     required this.loadFamilyMember,
//   });

//   final List<LoadFamilyMember> loadFamilyMember;

//   factory FamilyMember.fromJson(Map<String, dynamic> json) {
//     return FamilyMember(
//       loadFamilyMember: json["loadFamilyMember"] == null ? [] : List<LoadFamilyMember>.from(json["loadFamilyMember"]!.map((x) => LoadFamilyMember.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "loadFamilyMember": loadFamilyMember.map((x) => x.toJson()).toList(),
//       };
// }

// class LoadFamilyMember {
//   LoadFamilyMember({
//     this.patientId = 0,
//     this.id = 0,
//     this.patientName = "",
//     this.nationalityId = 0,
//     this.nationality = "",
//     this.dob = "",
//     this.mobile = "",
//     this.relation = "",
//     this.gender = "",
//     this.nationalIdTypeId = 0,
//     this.relationId = 0,
//   });

//   int patientId = 0;
//   int id = 0;
//   String patientName = '';
//   int nationalityId = 0;
//   String nationality = '';
//   String? dob = '';
//   String mobile = '';
//   String relation = '';
//   String gender = '';
//   int nationalIdTypeId = 0;
//   int relationId = 0;

//   factory LoadFamilyMember.fromJson(Map<String, dynamic> json) {
//     return LoadFamilyMember(
//       patientId: json["patientId"] ?? 0,
//       id: json["id"] ?? 0,
//       patientName: json["patientName"] ?? "",
//       nationalityId: json["nationalityId"] ?? 0,
//       nationality: json["nationality"] ?? "",
//       dob: (json["dob"] ?? ""),
//       mobile: json["mobile"] ?? "",
//       relation: json["relation"] ?? "",
//       gender: json["gender"] ?? "",
//       nationalIdTypeId: json["nationalIdTypeId"] ?? 0,
//       relationId: json["relationId"] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "patientId": patientId,
//         "id": id,
//         "patientName": patientName,
//         "nationalityId": nationalityId,
//         "nationality": nationality,
//         "dob": dob,
//         "mobile": mobile,
//         "relation": relation,
//         "gender": gender,
//         "nationalIdTypeId": nationalIdTypeId,
//         "relationId": relationId,
//       };
// }
