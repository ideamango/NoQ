//const COVID_BOOKING_FORM_ID = "0ba22050-5347-11eb-929a-87c3b00dc095";
import 'dart:core';

const COVID_VACCINATION_BOOKING_FORM_ID_OLD =
    "COVID_VACCINATION_BOOKING_FORM_ID_OLD";
const COVID_VACCINATION_CLINIC_BOOKING_FORM_ID =
    "COVID_VACCINATION_CLINIC_BOOKING_FORM_ID";
const COVID_VACCINATION_HOSPITAL_BOOKING_FORM_ID =
    "COVID_VACCINATION_HOSPITAL_BOOKING_FORM_ID";
const SCHOOL_GENERAL_NEW_ADMISSION_BOOKING_FORM_ID =
    "SCHOOL_GENERAL_NEW_ADMISSION_BOOKING_FORM_ID";
const SCHOOL_GENERAL_INQUIRY_FORM_ID = "SCHOOL_GENERAL_INQUIRY_FORM_ID";
const SCHOOL_GENERAL_TC_REQUEST_FORM_ID = "SCHOOL_GENERAL_TC_REQUEST_FORM_ID";
const SCHOOL_GENERAL_GRIEVANCE_FORM_ID = "SCHOOL_GENERAL_GRIEVANCE_FORM_ID";
const HOSPITAL_ADMISSION_FORM = "HOSPITAL_ADMISSION_FORM";
const DOCTOR_CONSULTATION_HOSPITAL_FORM = "DOCTOR_CONSULTATION_HOSPITAL_FORM";
const DOCTOR_CONSULTATION_CLINIC_FORM = "DOCTOR_CONSULTATION_CLINIC_FORM";
const MEDICAL_TEST_HOSPITAL_FORM = "MEDICAL_TEST_HOSPITAL_FORM";
const MEDICAL_TEST_DIAGNOSTIC_FORM = "MEDICAL_TEST_DIAGNOSTIC_FORM";

const COVID_BOOKING_FORM_NAME = "Covid-19 Vacination Applicant Form";
const AUTO_APPROVED = "Auto Approved";
const SYSTEM = "SYSTEM";

const TOKEN_COUNTER_PREFIX = "TOKENCOUNTER";
const INFORMATION_MAX_ALLOWED_BOOKING_BY_USER_PER_DAY_1 =
    "You are allowed to make upto ";
const INFORMATION_MAX_ALLOWED_BOOKING_BY_USER_PER_DAY_2 =
    " booking(s) in a day";

const INFORMATION_MAX_ALLOWED_BOOKING_BY_USER_PER_SLOT_1 = "You can book upto ";
const INFORMATION_MAX_ALLOWED_BOOKING_BY_USER_PER_SLOT_2 =
    " token(s) in a slot";

const INFORMATION_RECOMMEND_ONLINE_CONSULTATION =
    "We encourage you to choose ONLINE MODE OF INTERACTION with the Service Provider. Opt-out of Online mode only when it's necessary to visit the place.";

const INFORMATION_ONLY_ONLINE_CONSULTATION =
    "This place only supports Online mode of interaction. Make sure you have active internet and WhatsApp installed on your phone.";

const VERIFICATION_PENDING = "Verification Pending";
const VERIFICATION_VERIFIED = "Verified";
const VERIFICATION_REJECTED = "Rejected";

const ADMIN_INFO_ONLINE_MODE =
    "Your customers will be able select ONLINE MODE OF CONSULTATION when they book a slot. You need to have good Internet connection and WhatsApp installed on the Phone for interaction with your customer.";

const ADMIN_INFO_OFFLINE_MODE =
    "Your customers can walkin (visit in-person based on appointment) to your place to avail the Service.";

const WEEK_DAY_SUNDAY = 'sunday';
const WEEK_DAY_MONDAY = 'monday';
const WEEK_DAY_TUESDAY = 'tuesday';
const WEEK_DAY_WEDNESDAY = 'wednesday';
const WEEK_DAY_THURSDAY = 'thursday';
const WEEK_DAY_FRIDAY = 'friday';
const WEEK_DAY_SATURDAY = 'saturday';

const PLACE_TYPE_REALSTATE = "Real Estate";
const PLACE_TYPE_COVID19_VACCINATION_CENTER = "Covid-19 Vaccination Center";
const PLACE_TYPE_MALL = "Mall";
const PLACE_TYPE_SUPERMARKET = "Super Market";
const PLACE_TYPE_APARTMENT = "Apartment";
const PLACE_TYPE_MEDICAL_CLINIC = "Medical Clinic";
const PLACE_TYPE_SHOP = "Shop";
const PLACE_TYPE_WORSHIP = "Place of Worship";
const PLACE_TYPE_RESTAURANT = "Restaurant";
const PLACE_TYPE_SALON = "Salon";
const PLACE_TYPE_SCHOOL = "School";
const PLACE_TYPE_PUBLIC_OFFICE = "Public Office";
const PLACE_TYPE_PRIVATE_OFFICE = "Private Office";
const PLACE_TYPE_GYM = "Gym";
const PLACE_TYPE_SPORTS = "Sports Center";
const PLACE_TYPE_POPSHOP = "Pop Shop";
const PLACE_TYPE_BANK = "Bank";
const PLACE_TYPE_HOSPITAL = "Hospital";
const PLACE_TYPE_PHARMACY = "Pharmacy";
const PLACE_TYPE_DIAGNOSTICS = "Medical Diagnostics";
const PLACE_TYPE_CAR_SERVICE = "Car Service";
const PLACE_TYPE_BIKE_SERVICE = "Bike Service";
const PLACE_TYPE_PHONE_SERVICE = "Phone Service";
const PLACE_TYPE_LAPTOP_SERVICE = "Laptop Service";
const PLACE_TYPE_OTHERS = "Others";

const SELECT_TYPE_OF_PLACE = "Select Type of Place";
const SEARCH_TYPE_OF_PLACE = "Search by Type of Place";
const SELECT_ROLE_OF_PERSON = "Select the Role of Employee";

String QRMessageInToken =
    "Show this QR code once you reach the place. The manager of the place will scan to view the details of your request.";

String QRMessageInPlaceOwner =
    "Ask your customers to scan this QR code with the LESSs app to add this Place to their favorites.";

String QRMessageInApplicationOnUser =
    "Show this QR code once you reach the place. The manager of the place will scan to view the details of your request.";

String adminLegend = "Admin";
String managerLegend = "Manager";
String executiveLegend = "Executive";

String appName = 'LESSs';
var loginSubTxt = "Peace of Mind";
var loginMainTxt = "";
String dateDisplayFormat = 'EEE, MMM d';
String applicationExistsForToken =
    'This will cancel your Token and respective Application. \nAre you sure you want to cancel?';
String homeScreenMsgTxt =
    "Add the amenities in Apartment or Workplace to your 'favourites' and book a slot anytime.";
String whatsappContactUsMsg = "Hey!!";
String bookNowMsg = "Book now to save time later!";
String yourTurnUserMessage1 = "It's not your time yet!";
String yourTurnUserMessage2 =
    "Start the call 1 minute before your allotted time slot.";
String yourTurnUserMessageWhenTokenIsNotAlloted =
    "Token is not issued yet. \nYou should start the call only when a time-slot is allotted.";
//UPI Payment Page Strings - Start
String paymentDisclaimer =
    "Disclaimer: LESSs App does not process or track any payment you make to the Service Provider.\nNote, you are directly paying through the UPI Apps installed on your phone to the UPI Id of the Service Provider.";
String upiHeaderMsg = 'UPI Payments';
String noUpiAppsFound = 'No UPI Payment Apps found on your device.';
String copyUpiId = 'Copy the UPI Id and pay with any UPI App';
String directUpiPayMsg = 'Pay with any UPI App';
String payUpiQr =
    "Scan the QR code with any UPI payment App \n(Gpay, Paytm, PhonePe, BHIM, etc.)";
String donationMsg1 =
    "Every bit of encouragement matters. \nDonate as per your comfort.";
String fillMandatoryInfo =
    'Please provide all mandatory information and try again.';
String upiPaySuccess = "Payment was Successful";
String upiPaySuccessSub = "Thank You!";
String upiDonationSuccess = "Payment towards Donation was Successful";
String upiDonationSuccessSub = "Thank you for your contribution";
//UPI Payment Page Strings - End
String acceptPaymentInFormMsgMain =
    "Make the UPI payment and attach the screenshot";
String acceptPaymentInFormMsgSub =
    "If already paid, upload the image of receipt";
String whatsappMessageToPlaceOwner = "Hey there! My LESSs Token number is ";
String whatsappVideoToPlaceOwner_1 = "Hey there! My LESSs Token number is ";
String whatsappVideoToUser_1 = "Hey there! Your LESSs Token number is ";
String whatsappVideoToUser_2 =
    "\n\nAre you ready for the Online Consultation. \nShall we start call?";
String whatsappVideoToPlaceOwner_2 =
    "\n\nI am ready for the online consultation. \nShall we start call?";

String whatsappMessageFromUser = "Hello";
String whatsappMessage =
    "Hey!! Are you worried about safety in the crowded place or long waiting in queues? \nNo worries, book your peace of mind with LESSs mobile app. \nBook your slot when it's Less crowded and Stay Safe!!";
String videoCallWhatsappMsg = "LESSs: Video Call ";
String qrCodeShareHeading = "Your Safety and Convenience is a top priority at ";
String applicationShareTitle =
    "View the application details you have submitted";
String applicationShareMessage = "Show this QR when you reach ";
String thatsAllStr = 'That\'s all!';
String qrCodeShareMessage = "Book your Peace of Mind! - LESSs";
String tokenAccessNotAuthorised =
    "You are not authorised to access the Bookings for this Place.";
String contactAdminIfIssue =
    "If you think this is a mistake, please contact Admin of this place.";
String locationPermissionMsg =
    'To find nearby places we need access to your current location. Open Settings and give permission to "LESSs" to access your location.';
String locationAccessDeniedStr =
    "Sorry, couldn't access your current location!!";
String locationAccessDeniedSubStr =
    "Goto location settings in your device and ALLOW Location access";
String activeInfo =
    'Marking a Place as "ACTIVE" requires all mandatory details. Please fill and Save again.';
String pressUseCurrentLocation =
    'Press "Use Current Location" button when you are at your Place and Save the details.';
String shouldSetLocation =
    "You should set Location for your Place, else Users can't find it!";
String whyLocationIsRequired =
    'This will help users/customer to find your Place.';

String userCurrentLoc = 'Use Current Location';
String userAccountHeadingTxt = "You have logged in with ";
String locationMarkingActiveInfo =
    'Note: Users will be able to search/discover your Business/Place based on this location, so ensure that this is correctly saved before you make it "Active"';
String contactUsPageHeadline =
    'We would be happy to help you. Just drop a message to us and we will try our best to address that at the earliest.';
String noListByUser = "Nothing shared by User yet!";
String contactUsLine1 =
    "Do you like our work?  What else can we do?  How can we improve?";
String contactUsLine2 = "  We would love to hear from you!";
String contactUsLine3 = "\n\nEven a simple";
String contactUsLine4 = " Clap";
String contactUsLine5 = " or just a";
String contactUsLine6 = " Hello";
String contactUsLine7 = " from you would be a great motivation for our team :)";
String homeScreenMsgTxt2 = "Avoid rush hours";
String homeScreenMsgTxt3 = "Be Safe | Save time.";

String helpPageMainMsg = "We are working on getting best help..";
String defaultSearchMsg = 'Search places by Category or Name!!';
String defaultSearchSubMsg =
    'Add places to your favourites and quickly browse through later!!';
String notFoundMsg1 = "NO WORRIES.. ";
String notFoundMsg2 = "Contact Us.";
String notFoundMsg3 = "or ";
String notFoundMsg4 = "Share this app ";
String notFoundMsg5 =
    "with the place owner to Register with us at absolutely no charges ";

String noFavMsg = 'No favourites yet!!';
String tokenHeading = 'Yay!! Your booking is confirmed.';
String tokenTextH1 =
    "Booked your peace of mind. No more long waiting in queues!";
String tokenTextH2Walkin =
    "Please be on time and maintain social distancing norms while at ";
String tokenTextH2Online =
    "Please ensure you have working internet connection and WhatsApp installed for the online consultation at ";
String tokenTextH3 = "Be Safe !! Save Time !!";
String drawerHeaderTxt = "You are logged in with ";
String drawerHeaderTxt11 = 'Stay ';
String drawerHeaderTxt12 = 'Safe!!  ';
String drawerHeaderTxt21 = 'Maintain ';
String drawerHeaderTxt22 = 'Social distance!!  ';
String drawerHeaderTxt31 = 'Avoid ';
String drawerHeaderTxt32 = 'Rush ';
String drawerHeaderTxt33 = 'hours !!  ';
String drawerHeaderTxt41 = 'Save ';
String drawerHeaderTxt42 = 'time !!';
//String bundleId = 'net.lesss';
//String appStoreId = '1545296767';
String shareURLPrefix = 'https://in.lesss.net';
String noViewPermission = "It seems you do not have permission to view";
String noEditPermission = "It seems you do not have permission to modify";
String contactAdmin = "Contact Admin of this place.";
String publicInfo =
    "Public: If this is off - it means your Business/Facility is restricted only to either your Employees or the Residents. Example: Office or Apartment.";
String activeDef =
    'Active: If this is on - it means your Business/Facility is Active and can be searched by other users. You MUST fill all the required details before making it "ACTIVE".';
String bookableInfo =
    "Bookable: If a slot of your Business/Facility can be booked by the users and token can be issued then enable it. E.g. Salon or Tennis-court is bookable but Mall or Apartment complex can't be booked.";
String videoInfo =
    "No need to gather crowd at your place, if it can be done Online. Support online(Video/Audio/Chat) consultations by enabling this.";

String addressInfoStr =
    'The address is using the current location, and same will be used by customers when searching your location.';
String locationInfoStr = 'Current location details.';
String paymentInfoStr = 'Payments details.';

String offerInfoStr = 'Offer details.';
String placeDetailNoOffers = "No active offers currently.";

String missingInfoStr = "Some fields are either empty or have invalid details.";
String missingInfoSubStr =
    "Please verify all the information provided and try again.";
String entityUpsertErrStr = "Could not Save the details!!";
String entityUpsertErrSubStr = "Check your internet connection and try again.";

//* Start * Validation error msgs for Token Booking form
String idProofTypeMissingMsg = "Please select Type of ID proof.";
String idProofFileMissingMsg = "Please upload valid ID proof.";
String medCondsTypeMissingMsg = "Please select Type of Medical Conditions";
String medCondsFileMissingMsg =
    "Please upload supporting documents for Medical Conditions";
String frontLineTypeMissingMsg = "Please select Frontline Worker type";
String frontLineFileMissingMsg =
    "Please upload supporting documents for Frontline Worker";

String nameMissingMsg = "Please provide name as per govt. ID proof.";
String dobMissingMsg = "Please provide Date of Birth";
String currLocMissingMsg = "Please select Current Location";

//* End * Validation error msgs for Token Booking form

String missingInfoForShareStr =
    "Important details are missing in entity, Please fill those first.";
String missingInfoForShareSubStr = "Save Entity and then Share!!";
String basicInfoStr =
    'These are important details of the establishment, Same will be shown to customer when they search.';

String bookable =
    '"Bookable" means that time-slots can be booked by the users. For example, places like Mall & Apartment are not bookable but Shop, Solon, Gym, etc. can be booked.';

String adminInfoStr =
    'The person will manage the Place details, Employees, Forms for Requests and  Process Applications/Tokens.';
String execInfoStr =
    'The person can view the Applications and Tokens details for processing.';
String managerInfoStr =
    'The person will be responsible for process the Applications and Tokens';
String ratingMsg = "We really appreciate your time to provide the review.";

String completeDialogMsg =
    "Once you mark the Application completed, no further modifications can be done.";
String approveDialogMsg =
    'A Token will be issued to the user for the selected time slot on approval. \nNote: Approval might fail if the slot is full. In that case, you can select another time slot and approve.';
String cancelDialogMsg =
    "Once you Cancel the Application, the Application can't be processed by the Vendor.";
String onHoldDialogMsg =
    "If you don't want to process this application right now and want to review it later, please put it on-hold. \nNote: If the token is already issued, it will be cancelled.";
String rejectDialogMsg =
    'Please provide details in the below Remark section for the reasons of the Rejections, it will help the user to provide appropriate information in the future. \nNote: If the token is already issued, it will be cancelled.';
String correctQRCode =
    "It's not a valid LESSs QR code. You can only scan a QR code which is generated by the LESSs App.";
String invalidQRCode =
    "Invalid QR code, sorry we can't add this place to your favourites.";
String cameraAccess = "LESSs needs access to the Camera.";
String openCameraAccessSetting = "Open Settings to provide the Camera access.";
String locationNotFound = "Oops.. No location found for this place!";
String entityAlreadyInFav =
    "This place is already present in your Favourites!!";

String managerDashboardFormSelection =
    "To view the details of the requested Applications please select the Form and proceed";

String forgotTimeSlot = "Oops.. You forgot to select a time slot!";
String confirmLogout = "Are you sure you want to logout?";

String tryLater = "Please try again later.";

String cantOpenMaps = "Could not open Maps!";

String cantSearch = "Oops.. Can't Search!";
String searchResultText1 = "Showing search results for places ";
String searchResultText2 = "in ";
String searchResultText3 = " category ";
const SYMBOL_AND = "& ";

String searchResultText4 = "by name ";

String selectEarlierDate = "Please select an earlier date.";

String closedOnDay = "This place is closed on this day.";

String selectDifferentDate = "This place is closed on this day.";

String pageTitleManageEntityList = "Manage your Places";

String giveLocationPermission =
    "Open location settings and give permissions to access current location.";

String shareWithFriends =
    "Share with your Friends & Family to bring them into Safety net.";

String shareWithOwners =
    "You can also Share with people who manage Businesses such as Pop-Shop, Shops, Sport Centers, etc.";

String accessRestricted =
    "Access to this place is restricted to its residents or employees.";

String slotBooking = "Hold tight! We are Booking a slot for you..";

String takingMoment = "This would take a moment.";

String alreadyHaveBooking = "You already have an active booking for same time.";
String timeSlotExpired = "Time-Slot has already expired.";
String wantToBookAnotherSlot =
    "If you wish to book for another time, cancel this one from your bookings in Home Page";
String connectionIssue =
    "Seems to be some problem with internet connection, Please check and try again.";

String allSlotsBookedForDate = 'All slots are booked for this date!!';

String couldNotBookToken = "Oops! Couldn't book the token.";
String maxTokenInDayUserAdmin =
    "The User has already booked allowed maximum number of token for a day.";
String maxTokenInDayUserSubAdmin =
    "Please try a different date OR contact the User";
String maxTokenInSlotUserAdmin =
    "The User has already booked allowed maximum number of tokens in this Time-Slot.";
String tokenAlreadyExistsAdmin =
    "The User already has an active booking for the this Time-Slot.";
String onlineOfflineMsg =
    'Either Online or Offline mode of Bookings should be enabled.';
String maxTokenLimitReached =
    "You have already booked maximum allowed token(s) for a day.";
String maxTokenLimitReachedSub =
    "Please try a different date OR contact the Business";
String maxTokenForTimeReached =
    "You have already booked maximum allowed token(s) in a Time-Slot.";

String couldNotSubmitApplication =
    "Oops! Couldn't submit the application request.";

String slotsAlreadyBooked =
    "Selected time-slot is not available. Please choose a different time or date.";

String tokenAlreadyExists =
    "You already have an active booking for the same time.";
String selectDateSub = 'Please choose a different time or date.';

String bookingExpired = "This booking token has already expired!!";

String tryAgainToBook = "Please try again or choose a different time or date.";
String tryAgainLater = "Please try again later.";

String appShareHeading =
    "Are you worried about your Safety while stepping out or fed up with waiting in long queues?";
String appShareMessage =
    "Fix your appointment well in advance and visit places when the crowd is less.\n\nDownload the LESSs app today and stay safe!";

String appShareWithOwnerHeading =
    "Protect your Customers to Protect your Business!\nProvide Safety and Convenience to regain the confidence of your customers.";

String appShareWithOwnerMessage =
    "Register your Business with the LESSs App at absolutely no cost, give confidence to your customers by providing a safer environment and grow your business.\nDownload the App from ";

//append place name in the last
String entityShareByUserHeading =
    "Don't compromise with your safety while stepping out. \n\nFix your appointment, when the crowd is less for your next visit to ";

String entityShareByUserMessage =
    "Download the LESSs app and start booking your peace of mind!";

String entityShareByOwnerMailSubject =
    " is inviting you to use LESSs app to Book your peace of mind!";
//append place name in start of string
String entityShareByOwnerHeading =
    "Your Safety and Convenience is our top priority!";

String entityShareMessage =
    "Fix your appointment well in advance & Visit us when the crowd is less.\n\nDownload the LESSs app and start booking your peace of mind!";

String upiShareSubject = 'Share UPI Subject';
String upiShareTitle = 'Share UPI title';
String upiShareBody = 'Share UPI body';

String faqHead1 = "How LESSs helps bring Sukoon to your life?";
String faq1 = "Why use LESSs?";
String faqAns1 =
    '''There is not just one, but numerous reasons how this helps you. Here is how - Maintaing social distance is need of the hour. Sometimes just unavoidable when you visit your favourite grocery store for example, you see people standing in queue and wait-time could be anything from 10 mins to an hour. Another problem is, Shopping at place this crowded is not at all advisable. So, Not just you waste your precious time in waiting but also risk exposing yourself to virus(Covid-19).''';

String faq2 = "Where LESSs can be used? ";
String faqAns2 =
    '''We have listed few places where we felt pre-planning and booking time-slot would be help. But owner of any place where crowd is expected and pre-panning would be of help, would definitely can be added here for benefit of all. Few Examples of Places are Shopping Marts, Gaming Zones in Mall, Apartment amenities such as Lawn Tennis Court, Grocery Store, Gym, Local vegetable vendor etc.''';
String faqHead2 = "Registration";
String faq3 = "How do I login? ";
String faqAns3 =
    '''Registering with us is very simple and safe. We just ask for your phone number and NO other details will be asked. After providing your number, you will recieve an OTP on your phone number, just enter that and Done!! ''';

String faq4 = "What are the charges for booking tokens? ";
String faqAns4 =
    '''There is absolutely no charge for registration or for using this app. However, If you like our work, you can always donate any amount as per your wish to keep us motivated.''';
String faqAns4_2 = 'Click here to donate!!';
String faq5 =
    'Can I use same login if I need to book token for a family member? ';
String faqAns5 =
    'Yes, definitely. You can use your login and book tokens for your family. The maximum tokens booked per day would be as per the limit set by the place.';
String faq6 = 'Can I use same mobile number for multiple Profiles/ Users?';
String faqAns6 = 'Each phone number can be associated with one account only. ';

String faqHead3 = "How to Use";
String faq7 = "How to find the place where I am planning to go? ";
String faqAns7 = "";
String faq8 = "Cannot find the place I was planning to visit? ";
String faqAns8 =
    '''You can contact us and leave message about the same. We will try our best to get them onboard.Our ultimate purpose is to help create safe environment for all.''';
String faq9 = "How to book a time-slot? ";
String faqAns9 =
    'You can search for different places using \'Search\' feature. Futher, select date and time when you are planing to visit that place. See how many people have booked that slot, in case, u decide to visit the place when less people are visiting you can just so do it. \nNow, visit store conveniently at booked time and avoid all that rush!!';
String faq10 = "How to contact the Admin of the place? ";
String faqAns10 = "";
String faq11 =
    "Can I share some important notes with the Admin of place, before I visit? ";
String faqAns11 = "";
String faq12 = "How to fill online forms for a place? ";
String faqAns12 = "";
String faqHead4 = "Business";
String faq13 = "Why should I register my Business on LESSs? ";
String faqAns13 = "";
String faq14 = "How do I register my Business? ";
String faqAns14 =
    '''Business can only be added by person who is either owner or authorized to manage the place. Using "Manage your Places" option, you can add the business and all details like opening/closing time, location of the place, number of people allowed in a time-slot to minimise crowd inside place.\nFill all other important details. If your business has whatsapp contact, on-call contact person, please provide that too, that would help customers to contact you.''';
String faqAns14_2 = '\nClick here to register your business!!';
String faq15 =
    "Is it possible to have an idea how many customers/ visitors will be expected in a day or say at one time?";
String faqAns15 = "";
String faq16 =
    "What are application request forms, and how does it help my business? ";
String faqAns16 = "";
String faq17 = "Cannot find the application form in pre-defined templates. ";
String faqAns17 = "";
String faq18 = "Where can I see all the applications submitted by user? ";
String faqAns18 = "";
String faq19 =
    "What if I cannot cater to all the applications received for a day or a given time-slot?";
String faqAns19 = "";
String faq20 =
    "Can I create different profiles for executives and managers for my place?";
String faqAns20 = "";
String faq21 = "What to do if an executive/manager leaves my place?";
String faqAns21 = "";
String faq22 = "How do I publish applications forms for my place?";
String faqAns22 = "";
String faq23 = "What should I do we need to close the place for few days?";
String faqAns23 = "";
String faqHead5 = "Exit LESSs";

String faq24 = "How to delete my profile from LESSs?";
String faqAns24 = "";
String faq25 =
    "How do I delete my place if I do not want to use the platform further?";
String faqAns25 = "";

enum Role { Manager, Admin, ContactPerson, Employee }
List<String> roleTypes = ['Admin', 'Manager'];

List<String> mailReasons = [
  'General Enquiry',
  'Special Request',
  'Feedback',
  'Appreciation',
  'Report an Issue',
  'Press'
];
String ourStory1 = ' "We are changing the world with technology"';

String ourStory2 = ' - said';
String ourStory2_2 = ' Bill Gates,';
String ourStory3 = ' and';
String ourStory3_2 = ' Rumi';
String ourStory3_3 = ' said -';
String ourStory3_4 = ' "What you seek is seeking you!".';
String ourStory4 =
    '\n\nWe, on the other hand, believed that safety and upgraded services would seek us back with advanced technology. \n\nUntil we stumbled upon a quote from';
String ourStory4_2 = ' Arthur C. Clarke';
String ourStory5 =
    ' - "Any sufficiently advanced technology is indistinguishable from magic!\"';
String ourStory6 = '\n\nAnd, In the words of';
String ourStory6_2 = ' Narayan Murthy ';
String ourStory7 =
    ''' - "I believe that we have all at some time eaten the fruit from trees that we did not plant. In the fullness of time, when it is our turn to give, we must in turn plant gardens that we may never eat the fruit of, which willl benefit the generations to come. I believe this is our sacred responsibility, one that I hope you will shoulder in time."''';

String ourStory8 =
    '''\n\nThat was it! Because that’s when we decided on making the move ourselves creating magic with technology and finally finding what we seek!  
\nFounded at the time when the world stood still due to the pandemic in early 2020, BIGPIQ was developed keeping only one thing in mind- REVIVAL! After seeing ration hoarding, long queues, full car parking, and no distancing despite the guidelines, we knew that a solution was required. Not just for us as end-users but also businesses who were incapable of meeting demands and were losing out on the opportunity while others struggled to survive!  
\nSince the pandemic broke, there is loss of work, depressing news, uncertainty about the future, and monotonicity due to prolonged containment and restricted life activities have started to impact the mental health of the people. If people go out there is risk of contracting the virus. Avoiding crowded places and following suggested safety measures is the only thing people can do to bring back the life to normalcy.  
Facing the issues first-hand made it easier for us to work out a solution in the form of a mobile application and named it LESSs. Even though it is the result of long brainstorming sessions, it is worth all the pulled-out hair and sleepless nights. LESSs has the capacity to balance out the business growth opportunity in the current times and give consumers the surety of services without compromising their safety. LESSs means more Satisfaction to consumers and more Opportunity to businesses.\n\nLESSs is the go-to platform that ensures optimum safety for you and your family. If your mind is full of What? Why? How? Read more about ''';
String ourStory8_0 = ' LESSs here.';
String ourStory8_1 =
    ''' \n\nNote: This App is not for any commercial gain, it shall remain free as long as we can support it. We are working on a''';
String ourStory8_2 = ' donation-based model';
String ourStory8_3 =
    ''' to pay for the operational cost, through which we can continue to help our society and make it a better place for everyone.  ''';
String faqHeadline =
    'These are frequently asked questions, still if you didn\'t find the answer you are looking for, feel free to drop a message to us at ';
String agreement1 = '''Welcome to LESSs mobile application.''';
String agreement2 = '\n\nPlease carefully read the';
String agreement3 = ' Terms of Use (here)';
String agreement4 = ' and';
String agreement5 = ' Privacy Policy (here)';
String agreement6 =
    ''' of the Application. \n\nIf you 'Continue', you hereby accept the Terms of Use and the Privacy Policy and agree to be bound by their terms.''';
String privacyPolicy1 = 'We value the trust you place in us.';
String privacyPolicy2 =
    ''' \nThat’s why we insist upon the highest standards for secure transactions and customer information privacy. Please read the following statement to learn about our information gathering and dissemination practices.''';

String ourTeam =
    '''I am a Technologist turned Entrepreneur, who likes to solve problems in the real world. For more details, check out my LinkedIn profile. Would love to hear back from you for any feedback/suggestion or even for a simple cheer which will help me know that I am moving in the right direction. ''';
