const ADMIN = "admin";
const VERIFICATION_PENDING = "Verification Pending";
const VERIFIED = "Verified";
const VERIFICATION_REJECTED = "Rejected";

String appName = 'Sukoon';
var loginSubTxt = "Peace of Mind";
var loginMainTxt = "";
String dateDisplayFormat = 'EEE, MMM d';
String homeScreenMsgTxt =
    "Add the amenities in Apartment or Workplace to your 'favourites' and book a slot anytime.";
String whatsappContactUsMsg = "Hey!!";
String whatsappMessage =
    "Hey!! Did you book your peace of mind, while going out? Are you worried about long waiting in queues?\nQuick Solution - SUKOON. It helps you book your space when visiting any place.\nLess crowded space, More SAFE.";
String qrCodeShareMessage =
    "Hey!! Did you book your peace of mind, while going out? Are you worried about long waiting in queues?\nQuick Solution - SUKOON. It helps you book your space when visiting any place. \nLess crowded space, More SAFE. Just scan QR code and Voila!!";
String locationPermissionMsg =
    'To find nearby places we need access to your current location. Open settings and give permission to access your location.';
String locationAccessDeniedStr = "Sorry, couldn't access current location!!";
String locationAccessDeniedSubStr =
    "Goto location settings in your device and ALLOW Location access";

String contactUsMailId = "care@sukoon.mobi";
String contactUsPageHeadline =
    'We would be happy to help you. Just drop a message to us and we will try our best to address that at earliest.';

String homeScreenMsgTxt2 = "Avoid rush hours";
String homeScreenMsgTxt3 = "Be Safe | Save time.";

String helpPageMainMsg = "We are working on getting best help..";
String defaultSearchMsg = 'Search places by Category or Name!!';
String defaultSearchSubMsg =
    'Add places to favourites, and quickly browse through later!!  ';
String noFavMsg = 'No favourites yet!!';

String tokenHeading = 'Yay!! Your booking is confirmed.';
String tokenTextH1 =
    "Booked your peace of mind. No more long waiting in queues!";
String tokenTextH2 = "Please be on time and maintain social distance while at ";
String tokenTextH3 = "Be Safe !! Save Time !!";

String drawerHeaderTxt11 = 'Stay ';
String drawerHeaderTxt12 = 'Safe!!  ';
String drawerHeaderTxt21 = 'Maintain ';
String drawerHeaderTxt22 = 'Social distance!!  ';
String drawerHeaderTxt31 = 'Avoid ';
String drawerHeaderTxt32 = 'Rush ';
String drawerHeaderTxt33 = 'hours !!  ';
String drawerHeaderTxt41 = 'Save ';
String drawerHeaderTxt42 = 'time !!';
String publicInfo =
    "Public: If this is off - it means your service/facility is restricted to only either your employees or residents.";
String activeInfo =
    "Active: If this is on - it means your service/facility is active and can be searched by other users. You MUST fill all the required details before making it ACTIVE.";
String bookableInfo =
    "Bookable: If your slot for your service/facility can be booked by the user and token can be issued then enable it. For example: Shop or Tennis-court is bookable but Mall or Apartment complex can't be booked.";
String addressInfoStr =
    'The address is using the current location, and same will be used by customers when searching your location.';
String locationInfoStr = 'Current location details.';
String paymentInfoStr = 'Payments details.';

String missingInfoStr = "Some fields are either empty or have invalid details.";
String missingInfoSubStr =
    "Please verify all the information provided and try again.";
String entityUpsertErrStr = "Coold not Save the details!!";
String entityUpsertErrSubStr = "Check your internet connection and try again.";

String missingInfoForShareStr =
    "Important details are missing in entity, Please fill those first.";
String missingInfoForShareSubStr = "Save Entity and then Share!!";
String basicInfoStr =
    'These are important details of the establishment, Same will be shown to customer when they search.';

String adminInfoStr = 'The person who manages the premises.';
String contactInfoStr =
    'The perosn who can be contacted for any queries regarding your s ervices/facitlity.';

enum Role { Manager, Admin, ContactPerson, Employee }
List<String> roleTypes = ['Admin', 'Manager'];
List<String> entityTypes = [
  'Grocery/ Super Market ',
  'Apartment',
  'Office',
  'Mall',
  'Salon',
  'MedicalStore'
];
List<String> subEntityTypes = [
  'Swimming Pool',
  'Gym',
  'Salon',
  'Medical Store',
  'Grocery Store',
  'Library',
  'Game Parlors',
  'Commercial Space',
  'Cafe',
  'Restaurant',
  'Others'
];
List<String> searchTypes = [
  'Search in all categories',
  'Grocery/ Super Market ',
  'Apartment',
  'Office',
  'Mall',
  'Salon',
  'MedicalStore'
];
List<String> mailReasons = [
  'General Enquiry',
  'Special Request',
  'Feedback',
  'Appreciation',
  'Report an Issue',
  'Press'
];
String ourStory =
    '''Entire World has been hit by the Covid-19 pandemic in early 2020 and the governments across the world started taking various measures to control the spread of this deadly disease. Lockdowns are being imposed across all the countries to minimize the interactions between people which was the main cause for the spread.

The challenge in front of the governments is multifold, on one hand, they have to control the community spread of the disease by putting many public restrictions and on the other hand, reduce the damage to the economy by opening up business activity.

TO CHANGE:- lack of change due to prolonged containment and restricted activities have started to impact the mental health of the people.  

This is where we realized that life has to continue, we should do whatever it takes to restore the normalcy but with few extra precautionary measures should be in place to avoid the spread of infection.   

The reason was big enough to motivate us to build the Sukoon App which is available on both Android and iPhone platforms. We believe that technology can help society to maintain social distancing and can still allow us to lead close to a normal life.  

Note: This App is not for any commercial gain, it shall remain free as long as we can support it. We are working on a donation-based model to pay for the operational cost, through which we can continue to help our society and make it a better place for everyone.  

I am a Technologist turned Entrepreneur, who likes to solve problems in the real world. For more details, check out my LinkedIn profile.   

Would love to hear back from you for any feedback/suggestion or even for a simple cheer which will help me know that I am moving in the right direction. ''';

String agreement = '''Welcome to Sukoon mobile application.

Please carefully read the Terms of Use of the Application (here) and Privacy Policy (here)

By clicking on the ‘I Accept & Sign up’ button at the end of this page or accessing or using this Application, you hereby accept the Terms of Use (as amended from time to time) and the Privacy Policy (as amended from time to time) and agree to be bound by their terms.

If you do not agree to be bound by their terms, then please do not access or use the Application.

Further, by clicking on the ‘I Accept & Sign up’ button, you hereby consent to the collection, storage, use, processing, disclosure and transfer of your personal information in accordance with the provisions of the Privacy Policy (as amended from time to time).

If you are accessing the mFine mobile application, then there may be additional terms (such as the terms imposed by application stores) which may also govern the use of the mobile application. By clicking on the ‘I Accept’ button at the end of this page or
 accessing or using the mobile application, you agree to be bound by the aforementioned additional terms as may be amended from time to time as well.''';
String privacy_policy =
    '''We value the trust You (defined below) place in Us (defined below). That’s why We (defined below) insist upon the highest standards for secure transactions and customer information privacy. Please read the following statement to learn about Our (defined below) information gathering and dissemination practices.

Novocura Tech Health Services Private Limited (“NTHS”, which also include its affiliates), having its registered office address at Salarpuria Sattva Supreme, 2nd Floor, West Wing, Sarjapur Outer Ring Road, Marathahalli, Bengaluru 560037.

NTHS is committed to respecting the privacy of every person who shares information with it or whose information it receives. Your (defined below) privacy is important to Us (defined below) and We (defined below) strive to take care and protect the information We (defined below) receive from You (defined below) to the best of Our (defined below) ability.

This Privacy Policy (“Privacy Policy”) applies to the collection, receipt, storage, usage, processing, disclosure, transfer and protection (“Utilization”) of your Personal Information (defined below) when You use the mfine website available at URL: www.mfine.* (where * represents various domain names) operated by NTHS (“Website”) or mobile application of brand name “mfine” available for download at Google Play Store, Apple App Store, Windows App Store (“Application”) operated by NTHS or avail any Services offered by NTHS through the Website or Application.

The terms ‘You’ or ‘Your’ refer to you as the user (registered or unregistered) of the Website, Application or Services and the terms ‘We’, ‘Us” and ‘Our’ refer to NTHS.

The capitalized terms that are used but not defined in this Privacy Policy shall have the same meaning as in our Terms of Use.

CONSENT:
You acknowledge that this Privacy Policy is a part of the Terms of Use of the Website and the other Services, by accessing the Website or Application or by otherwise providing Us Your Personal Information Yourself or through a Primary User or by making use of the Services provided by the Website or Application, You unconditionally signify Your (i) assent to the Privacy Policy, and (ii) consent to the Utilisation of your Personal Information in accordance with the provisions of this Privacy Policy.
You acknowledge that You are providing Your Personal Information out of Your free will. If You use the Services on behalf of someone else (including but not limited to, Your child – minor or major or as a legal representative of an individual with mental illness) or an entity (such as Your employer), You represent that You are authorized by such individual or entity to (i) accept this Privacy Policy on such individual’s or entity’s behalf, and (ii) consent on behalf of such individual or entity to Our collection, use and disclosure of such individual’s or entity’s Personal Information as described in this Privacy Policy. Further, You hereby acknowledge that the Utilization of Your Personal Information by NTHS is necessary for the purposes identified hereunder. You hereby consent that the Utilization of any Personal Information in accordance with the provisions of this Privacy Policy shall not cause any wrongful loss to You.
YOU HAVE THE OPTION NOT TO PROVIDE US THE PERSONAL INFORMATION SOUGHT TO BE COLLECTED. YOU WILL ALSO HAVE AN OPTION TO WITHDRAW YOUR CONSENT AT ANY POINT, PROVIDED SUCH WITHDRAWAL OF THE CONSENT IS INTIMATED TO US IN WRITING. If You do not provide Us Your Personal Information or if You withdraw the consent to provide Us Your Personal Information at any point in time, We shall have the option not to fulfill the purposes for which the said Personal Information was sought and We may restrict You from using the Website, Application or Services.
Our Website or Application are not directed at children and We do not knowingly collect any Personal Information from children. Please contact Us at grievance@mfine.co if You are aware that We may have inadvertently collected Personal Information from a child, and We will delete that information as soon as possible.
CHANGES TO THE PRIVACY POLICY:
We reserve the right to update (change, modify, add and/or delete) this Privacy Policy from time to time at our sole discretion. There is a tab at the end of the Privacy Policy which indicates when the Privacy Policy was last updated.
When We update Our Privacy Policy, we will intimate You of the amendments on Your registered email ID or on the Website or Application. Alternatively, NTHS may cause Your account to be logged-off and make Your subsequent account log-in conditional on acceptance of the Agreement. If You do not agree to the amendments, please do not use the Website, Application or Services any further.
PERSONAL INFORMATION COLLECTED: In order to provide Services to You we might require You to voluntarily provide Us certain information that personally identifies You or Secondary Users related to You. You hereby consent to the collection of such information by NTHS. The information that We may collect from You, about You or Secondary Users related to You, may include but are not limited to, the following:
Patient/Caregiver/Doctor/Health Care Professional Name,
Birth date/age,
Blood group,
Gender,
Address (including country and pin/postal code),
Location information, including Your GPS location,
Phone number/mobile number,
Email address,
Physical, physiological and mental health condition, provided by You and/or Your Healthcare Service provider or accessible from Your medical records,
Personal medical records and history,
Valid financial information at time of purchase of product/Services and/or online payment,
mfine Login ID and password,
User details as provided at the time of registration or thereafter,
Records of interaction with NTHS representatives,
Your usage details such as time, frequency, duration and pattern of use, features used and the amount of storage used,
Master and transaction data and other data stored in Your user account,
Internet Protocol address, browser type, browser language, referring URL, files accessed, errors generated, time zone, operating system and other visitor details collected in Our log files, the pages of our Website or Application that You visit, the time and date of Your visit, the time spent on those pages and other statistics ("Log Data"),
User’s tracking Information such as, but not limited to the device ID, Google Advertising ID and Android ID,
Any other information that is willingly shared by You.
(collectively referred to as “Personal Information”).

HOW WE COLLECT PERSONAL INFORMATION: The methods by which We collect Your Personal Information include but are not limited to the following:
When You register on Our Website or Application,
When You provide Your Personal Information to Us,
During the course of Services provided to You by Us,
When You use the features on Our Website or Application,
Through Your device, once You have granted permissions to Our Application (discussed below),
Through HSP pursuant to consultation on the Website or the Application,
By the use of cookies (also discussed below),
We collect information that Your browser/app sends whenever You visit Our Website or Application, such as, the Log Data. In addition, We may use third party services such as Pixel that collect, monitor and analyze this. This information is kept completely secure.
USE OF PERSONAL INFORMATION: YOUR PERSONAL INFORMATION MAY BE USED FOR VARIOUS PURPOSES INCLUDING BUT NOT LIMITED TO THE FOLLOWING:
To provide effective Services;
To debug customer support related issues;
To operate and improve the Website or Application;
TO PERFORM ACADEMIC/STUDIES, CLINICAL OR OTHER RESEARCH AND ANALYSIS FOR OUR UNDERSTANDING, INFORMATION, ANALYSIS, SERVICES AND TECHNOLOGIES IN ORDER TO PROVIDE ALL USERS IMPROVED QUALITY OF CARE; AND ENSURING THAT THE CONTENT AND ADVERTISING DISPLAYED ARE CUSTOMIZED TO YOUR INTERESTS AND PREFERENCES;
To contact You via phone, SMS, email or third-party communication services such as Whatsapp, etc. for appointments, technical issues, payment reminders, obtaining feedback and other security announcements;
To send promotional and marketing emails from Us or any of Our channel partners via SMS, email, snail mail or third-party communication services such as WhatsApp, Facebook etc.;
To advertise products and Services of NTHS and third parties;
To transfer information about You, if We are acquired by or merged with another company;
To share with Our business partners for provision of specific services You have ordered so as to enable them to provide effective Services to You;
To administer or otherwise carry out Our obligations in relation to any Agreement You have with Us;
To build Your profile on the Website or Application;
To respond to subpoenas, court orders, or legal process, or to establish or exercise Our legal rights or defend against legal claims; 
To investigate, prevent, or take action regarding illegal activities, suspected fraud, violations of Our Terms of Use, breach of Our agreement with You or as otherwise required by law;
TO AGGREGATE PERSONAL INFORMATION FOR RESEARCH FOR ACADEMIC/STUDIES, CLINICAL OR OTHER RESEARCH, , STATISTICAL ANALYSIS AND BUSINESS INTELLIGENCE PURPOSES, AND TO SELL OR OTHERWISE TRANSFER SUCH RESEARCH, STATISTICAL OR INTELLIGENCE DATA IN AN AGGREGATED AND/OR NON-PERSONALLY IDENTIFIABLE FORM TO THIRD PARTIES AND AFFILIATES WITH A PURPOSE OF PROVIDING SERVICES TO THE USERS OR FOR THE ADVANCEMENT OF SCIENTIFIC KNOWLEDGE ABOUT HEALTH AND DISEASE.
(collectively referred to as “Purpose(s)”)

SHARING AND TRANSFERRING OF PERSONAL INFORMATION:
You authorize Us to exchange, transfer, share, part with all or any of Your Personal Information, across borders and from Your country to any other countries across the world with Our affiliates / agents / third party service providers / partners / banks and financial institutions for the Purposes specified under this Policy or as may be required by applicable law.
You hereby consent and authorize Us to publish feedback obtained by You on Our Website or Application.
User’s financial information are transacted upon secure sites of approved payment gateways which are digitally under encryption, thereby providing the highest possible degree of care as per current technology. However, User is advised to exercise discretion while saving the payment details.
You acknowledge that some countries where We may transfer Your Personal Information may not have data protection laws which are as stringent as the laws of Your own country. You acknowledge that it is adequate that when NTHS transfers Your Personal Information to any other entity within or outside Your country of residence, NTHS will place contractual obligations on the transferee which will oblige the transferee to adhere to the provisions of this Privacy Policy. You acknowledge that NTHS may be obligated to by law to disclose or transfer your Personal Information with Courts and Government agencies in certain instances such as for verification of identity, or for prevention, detection, investigation, prosecution, and punishment for offences, or in compliance with laws such as intimation of diagnosis of an epidemic disease. You hereby consent to disclosure or transfer of Your Personal Information in these instances.
Notwithstanding the above, We are not responsible for the confidentiality, security or distribution of Your Personal Information by third-parties outside the scope of Our Agreement with such third-parties. Further, We shall not be responsible for any breach of security or for any actions of any third-parties or events that are beyond the reasonable control of Us including but not limited to, acts of government, computer hacking, unauthorized access to computer data and storage device, computer crashes, breach of security and encryption, poor quality of Internet service or telephone service of the User etc.
We may share Your Personal Information with Our other corporate and/or associate entities and affiliates to (i) help detect and prevent identity theft, fraud and other potentially illegal acts and cyber security incidents, and (ii) help and detect co-related/related or multiple accounts to prevent abuse of Our Services.
PERMISSIONS: Once You download and install Our Application, You may be prompted to grant certain permissions to allow the Application to perform certain actions on Your device. These actions include permission to:
read/write/modify/delete data in relation to the Application on Your device’s storage;
view/access information relating to networks/access networks, including permission to send and receive data through such networks/access networks;
determine Your approximate location from sources like, but not limited to, mobile towers and connected Wi-Fi networks;
determine Your exact location from sources such as, but not limited to, GPS;
view/access device information, including but not limited to the model number, IMEI number, operating system information and phone number of Your device;
access device information including device identification number required to send notification/push notifications.
USE OF COOKIES:
Cookies are files with small amount of data, which may include an anonymous unique identifier. Cookies are sent to You on the Website and/or Application.
We may store temporary or permanent ‘cookies’ on Your computer/device to store certain data (that is not Sensitive Personal Data or Information). You can erase or choose to block these cookies from Your computer. You can configure Your computer’s browser to alert You when We attempt to send You a cookie with an option to accept or refuse the cookie. If You have turned cookies off, You may be prevented from using certain features of the Website or Application.
We do not control the use of Cookies by third parties. 
SECURITY:
The security of Your Personal Information is important to Us. We have adopted reasonable security practices and procedures including role-based access, secure communication, password protection, encryption, etc. to ensure that the Personal Information collected is secure. You agree that such measures are secured and adequate. We restrict access to Your Personal Information to Our and Our affiliates’ employees, agents, third party service providers, partners, and agencies who need to know such Personal Information in relation to the Purposes as specified above in this Policy, provided that such entities agree to abide by this Privacy Policy. 
While We will endeavor to take all reasonable and appropriate steps to keep secure any information which We hold about You and prevent unauthorized access, You acknowledge that the internet is not 100% secure and that We cannot guarantee absolute security of Your Personal Information. Further, if You are Secondary User, You hereby acknowledge and agree that Your Personal Information may be freely accessible by the Primary User and other Secondary Users and that NTHS will not be able to restrict, control or monitor access by Primary User or other Secondary Users to your Personal Information. We will not be liable in any way in relation to any breach of security or unintended loss or disclosure of information caused in relation to Your Personal Information.
THIRD PARTY LINKS: During Your interactions with Us, it may happen that We provide/include links and hyperlinks of third-party websites not owned or managed by Us (“Third-party Websites”). It may also happen that You or other Users may include links and hyperlinks of Third-party Websites. The listing of such Third-Party Websites (by You, other Users or by Us) does not imply endorsement of such Third-party Websites by NTHS. Such Third-party Websites are governed by their own terms and conditions and when You access such Third-party Websites, You will be governed by the terms of such Third-party Websites. You must use Your own discretion while accessing or using Third-party Websites. We do not make any representations regarding the availability and performance of any of the Third-party Websites. We are not responsible for the content, terms of use, privacy policies and practices of such Third-party Websites. We do not bear any liability arising out of Your use of Third-party Websites.
ACCESS: If You need to update or correct Your Personal Information or have any grievance with respect to the processing or use of Your Personal Information, or request that We no longer use Your Personal Information to provide You Services, or opt-out of receiving communications such as promotional and marketing-related information regarding the Services, for any reason, You may send Us an email at grievance@mfine.co and We will take all reasonable efforts to incorporate the changes within a reasonable period of time.
COMPLIANCE WITH LAWS: You are not allowed to use the services of the Website or Application if any of the terms of this Privacy Policy are not in accordance with the applicable laws of Your country.
TERM OF STORAGE OF PERSONAL INFORMATION:
mfine may keep records of communications, including phone calls received and made for making enquiries, orders, feedback or other purposes for rendering services effectively and efficiently. mfine will be the exclusive owner of such data and records. However, all records are regarded as confidential. Therefore, will not be divulged to any third party, unless required by law.
NTHS shall store Your Personal Information at least for a period of three years from the last date of use of the Services, Website or Application or for such period as may be required by law.
GRIEVANCE OFFICER:
We have appointed a grievance officer, whose details are set out below, to address any concerns or grievances that You may have regarding the processing of Your Personal Information. If You have any such grievances, please write to Our grievance officer at grievance@mfine.co and Our officer will attempt to resolve Your issues in a timely manner.

 

Version No. 2.0

Last Updated: 27ththApril 2020''';
