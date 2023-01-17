// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login failed`
  String get loginFail {
    return Intl.message(
      'Login failed',
      name: 'loginFail',
      desc: '',
      args: [],
    );
  }

  /// `Total Contacts: {stat}`
  String contactStat(Object stat) {
    return Intl.message(
      'Total Contacts: $stat',
      name: 'contactStat',
      desc: '',
      args: [stat],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Multi-Language`
  String get multiLanguage {
    return Intl.message(
      'Multi-Language',
      name: 'multiLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message(
      'Sign Out',
      name: 'signOut',
      desc: '',
      args: [],
    );
  }

  /// `Confirm exit account`
  String get signOutInfo {
    return Intl.message(
      'Confirm exit account',
      name: 'signOutInfo',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Register failed`
  String get registerFail {
    return Intl.message(
      'Register failed',
      name: 'registerFail',
      desc: '',
      args: [],
    );
  }

  /// `Failed to retrieve`
  String get retrieveFail {
    return Intl.message(
      'Failed to retrieve',
      name: 'retrieveFail',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phoneNumber {
    return Intl.message(
      'Phone',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Select country or region`
  String get selectCountry {
    return Intl.message(
      'Select country or region',
      name: 'selectCountry',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get nickName {
    return Intl.message(
      'Nickname',
      name: 'nickName',
      desc: '',
      args: [],
    );
  }

  /// `Contacts`
  String get contacts {
    return Intl.message(
      'Contacts',
      name: 'contacts',
      desc: '',
      args: [],
    );
  }

  /// `Me`
  String get me {
    return Intl.message(
      'Me',
      name: 'me',
      desc: '',
      args: [],
    );
  }

  /// `send success`
  String get sendSuccess {
    return Intl.message(
      'send success',
      name: 'sendSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message(
      'Message',
      name: 'message',
      desc: '',
      args: [],
    );
  }

  /// `Team`
  String get team {
    return Intl.message(
      'Team',
      name: 'team',
      desc: '',
      args: [],
    );
  }

  /// `work`
  String get work {
    return Intl.message(
      'work',
      name: 'work',
      desc: '',
      args: [],
    );
  }

  /// `Add friends`
  String get addFriends {
    return Intl.message(
      'Add friends',
      name: 'addFriends',
      desc: '',
      args: [],
    );
  }

  /// `Add group chat`
  String get addGroupChat {
    return Intl.message(
      'Add group chat',
      name: 'addGroupChat',
      desc: '',
      args: [],
    );
  }

  /// `Join team`
  String get joinTeam {
    return Intl.message(
      'Join team',
      name: 'joinTeam',
      desc: '',
      args: [],
    );
  }

  /// `QRC`
  String get qrc {
    return Intl.message(
      'QRC',
      name: 'qrc',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get teamSearch {
    return Intl.message(
      'Search',
      name: 'teamSearch',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get teamCreate {
    return Intl.message(
      'Create',
      name: 'teamCreate',
      desc: '',
      args: [],
    );
  }

  /// `Nearby Team`
  String get teamNearbyTitle {
    return Intl.message(
      'Nearby Team',
      name: 'teamNearbyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create Team`
  String get teamCreateTitle {
    return Intl.message(
      'Create Team',
      name: 'teamCreateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Is join or create a team?`
  String get teamJoinConfirmTitle {
    return Intl.message(
      'Is join or create a team?',
      name: 'teamJoinConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can join a team organization or create a new one.`
  String get teamJoinConfirmContent {
    return Intl.message(
      'You can join a team organization or create a new one.',
      name: 'teamJoinConfirmContent',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirmTitle {
    return Intl.message(
      'Confirm',
      name: 'confirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelText {
    return Intl.message(
      'Cancel',
      name: 'cancelText',
      desc: '',
      args: [],
    );
  }

  /// `Historical keywords`
  String get historyKeyWord {
    return Intl.message(
      'Historical keywords',
      name: 'historyKeyWord',
      desc: '',
      args: [],
    );
  }

  /// `Search for team name`
  String get teamSearchHintText {
    return Intl.message(
      'Search for team name',
      name: 'teamSearchHintText',
      desc: '',
      args: [],
    );
  }

  /// `Apply To Join`
  String get teamApplyTitle {
    return Intl.message(
      'Apply To Join',
      name: 'teamApplyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Real name`
  String get teamApplyLabel1 {
    return Intl.message(
      'Real name',
      name: 'teamApplyLabel1',
      desc: '',
      args: [],
    );
  }

  /// `validation message`
  String get teamApplyLabel2 {
    return Intl.message(
      'validation message',
      name: 'teamApplyLabel2',
      desc: '',
      args: [],
    );
  }

  /// `Enter your real name`
  String get teamApplyHintText1 {
    return Intl.message(
      'Enter your real name',
      name: 'teamApplyHintText1',
      desc: '',
      args: [],
    );
  }

  /// `Enter validation message`
  String get teamApplyHintText2 {
    return Intl.message(
      'Enter validation message',
      name: 'teamApplyHintText2',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get finish {
    return Intl.message(
      'Done',
      name: 'finish',
      desc: '',
      args: [],
    );
  }

  /// `Create a new Org and invite friends to join the Org`
  String get teamCreateMark {
    return Intl.message(
      'Create a new Org and invite friends to join the Org',
      name: 'teamCreateMark',
      desc: '',
      args: [],
    );
  }

  /// `Org LOGO`
  String get teamOrgLogoLabel {
    return Intl.message(
      'Org LOGO',
      name: 'teamOrgLogoLabel',
      desc: '',
      args: [],
    );
  }

  /// `Org Name`
  String get teamOrgNameLabel {
    return Intl.message(
      'Org Name',
      name: 'teamOrgNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Org Profile`
  String get teamOrgIntro {
    return Intl.message(
      'Org Profile',
      name: 'teamOrgIntro',
      desc: '',
      args: [],
    );
  }

  /// `Org Type`
  String get teamOrgType {
    return Intl.message(
      'Org Type',
      name: 'teamOrgType',
      desc: '',
      args: [],
    );
  }

  /// `Enter Org name`
  String get teamOrgNameHintText {
    return Intl.message(
      'Enter Org name',
      name: 'teamOrgNameHintText',
      desc: '',
      args: [],
    );
  }

  /// `Enter Org profile`
  String get teamOrgIntroHintText {
    return Intl.message(
      'Enter Org profile',
      name: 'teamOrgIntroHintText',
      desc: '',
      args: [],
    );
  }

  /// `Add Member`
  String get teamAddMember {
    return Intl.message(
      'Add Member',
      name: 'teamAddMember',
      desc: '',
      args: [],
    );
  }

  /// `Member Verify`
  String get teamMemberVerify {
    return Intl.message(
      'Member Verify',
      name: 'teamMemberVerify',
      desc: '',
      args: [],
    );
  }

  /// `Add new members to the Org`
  String get teamAddMemberMark {
    return Intl.message(
      'Add new members to the Org',
      name: 'teamAddMemberMark',
      desc: '',
      args: [],
    );
  }

  /// `Enter phone number`
  String get teamOperateByPhone {
    return Intl.message(
      'Enter phone number',
      name: 'teamOperateByPhone',
      desc: '',
      args: [],
    );
  }

  /// `From phone contacts`
  String get teamOperateByContacts {
    return Intl.message(
      'From phone contacts',
      name: 'teamOperateByContacts',
      desc: '',
      args: [],
    );
  }

  /// `QR Code invite`
  String get teamOperateByQrcode {
    return Intl.message(
      'QR Code invite',
      name: 'teamOperateByQrcode',
      desc: '',
      args: [],
    );
  }

  /// `Invite via CoBiz`
  String get teamOperateByCobiz {
    return Intl.message(
      'Invite via CoBiz',
      name: 'teamOperateByCobiz',
      desc: '',
      args: [],
    );
  }

  /// `Create or Join Organization`
  String get teamNoneTitle {
    return Intl.message(
      'Create or Join Organization',
      name: 'teamNoneTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set up a team to work`
  String get teamNoneLabel1 {
    return Intl.message(
      'Set up a team to work',
      name: 'teamNoneLabel1',
      desc: '',
      args: [],
    );
  }

  /// `Data encryption storage`
  String get teamNoneLabel2 {
    return Intl.message(
      'Data encryption storage',
      name: 'teamNoneLabel2',
      desc: '',
      args: [],
    );
  }

  /// `Safe and fast chat`
  String get teamNoneLabel3 {
    return Intl.message(
      'Safe and fast chat',
      name: 'teamNoneLabel3',
      desc: '',
      args: [],
    );
  }

  /// `Create or Join`
  String get teamCreateOrJoin {
    return Intl.message(
      'Create or Join',
      name: 'teamCreateOrJoin',
      desc: '',
      args: [],
    );
  }

  /// `My Department`
  String get teamMyDepartment {
    return Intl.message(
      'My Department',
      name: 'teamMyDepartment',
      desc: '',
      args: [],
    );
  }

  /// `My Groups`
  String get myDiscussGroup {
    return Intl.message(
      'My Groups',
      name: 'myDiscussGroup',
      desc: '',
      args: [],
    );
  }

  /// `Org`
  String get teamMyOrganization {
    return Intl.message(
      'Org',
      name: 'teamMyOrganization',
      desc: '',
      args: [],
    );
  }

  /// `My Contacts`
  String get teamMyContacts {
    return Intl.message(
      'My Contacts',
      name: 'teamMyContacts',
      desc: '',
      args: [],
    );
  }

  /// `Friend Verify`
  String get friendVerify {
    return Intl.message(
      'Friend Verify',
      name: 'friendVerify',
      desc: '',
      args: [],
    );
  }

  /// `Switch Team`
  String get teamSwitch {
    return Intl.message(
      'Switch Team',
      name: 'teamSwitch',
      desc: '',
      args: [],
    );
  }

  /// `Switch default team to {name}`
  String teamSwitchTip(Object name) {
    return Intl.message(
      'Switch default team to $name',
      name: 'teamSwitchTip',
      desc: '',
      args: [name],
    );
  }

  /// `Switch Failed`
  String get switchFailed {
    return Intl.message(
      'Switch Failed',
      name: 'switchFailed',
      desc: '',
      args: [],
    );
  }

  /// `Team Settings`
  String get teamSettings {
    return Intl.message(
      'Team Settings',
      name: 'teamSettings',
      desc: '',
      args: [],
    );
  }

  /// `Team Members`
  String get teamMembers {
    return Intl.message(
      'Team Members',
      name: 'teamMembers',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get personUnit {
    return Intl.message(
      'People',
      name: 'personUnit',
      desc: '',
      args: [],
    );
  }

  /// `department`
  String get deptUnit {
    return Intl.message(
      'department',
      name: 'deptUnit',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get myCreated {
    return Intl.message(
      'Created',
      name: 'myCreated',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get myJoined {
    return Intl.message(
      'Member',
      name: 'myJoined',
      desc: '',
      args: [],
    );
  }

  /// `My Groups`
  String get myGroups {
    return Intl.message(
      'My Groups',
      name: 'myGroups',
      desc: '',
      args: [],
    );
  }

  /// `Collaborative Work`
  String get collaborativeWork {
    return Intl.message(
      'Collaborative Work',
      name: 'collaborativeWork',
      desc: '',
      args: [],
    );
  }

  /// `Add Sub Dept`
  String get addSubDept {
    return Intl.message(
      'Add Sub Dept',
      name: 'addSubDept',
      desc: '',
      args: [],
    );
  }

  /// `Dept Setting`
  String get setSubDept {
    return Intl.message(
      'Dept Setting',
      name: 'setSubDept',
      desc: '',
      args: [],
    );
  }

  /// `Members Limit`
  String get teamMemberLimit {
    return Intl.message(
      'Members Limit',
      name: 'teamMemberLimit',
      desc: '',
      args: [],
    );
  }

  /// `Refuse`
  String get refuse {
    return Intl.message(
      'Refuse',
      name: 'refuse',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get agree {
    return Intl.message(
      'Agree',
      name: 'agree',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Refuse`
  String get confirmRefuse {
    return Intl.message(
      'Confirm Refuse',
      name: 'confirmRefuse',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Agree`
  String get confirmAgree {
    return Intl.message(
      'Confirm Agree',
      name: 'confirmAgree',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Completion`
  String get confirmCompletion {
    return Intl.message(
      'Confirm Completion',
      name: 'confirmCompletion',
      desc: '',
      args: [],
    );
  }

  /// `Agreed`
  String get agreed {
    return Intl.message(
      'Agreed',
      name: 'agreed',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get rejected {
    return Intl.message(
      'Rejected',
      name: 'rejected',
      desc: '',
      args: [],
    );
  }

  /// `Passed`
  String get passed {
    return Intl.message(
      'Passed',
      name: 'passed',
      desc: '',
      args: [],
    );
  }

  /// `Review`
  String get review {
    return Intl.message(
      'Review',
      name: 'review',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Dissolve Org`
  String get dissolveOrg {
    return Intl.message(
      'Dissolve Org',
      name: 'dissolveOrg',
      desc: '',
      args: [],
    );
  }

  /// `After the team is dissolved, the server no longer retains any team data, including but not limited to team members, data generated by team applications, team group messages, etc.`
  String get teamDissolveConfirmContent {
    return Intl.message(
      'After the team is dissolved, the server no longer retains any team data, including but not limited to team members, data generated by team applications, team group messages, etc.',
      name: 'teamDissolveConfirmContent',
      desc: '',
      args: [],
    );
  }

  /// `Add new friends for yourself`
  String get addFriendMark {
    return Intl.message(
      'Add new friends for yourself',
      name: 'addFriendMark',
      desc: '',
      args: [],
    );
  }

  /// `Scan to add`
  String get scanToAdd {
    return Intl.message(
      'Scan to add',
      name: 'scanToAdd',
      desc: '',
      args: [],
    );
  }

  /// `Edit Member`
  String get teamEditMember {
    return Intl.message(
      'Edit Member',
      name: 'teamEditMember',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Dept Name`
  String get departmentName {
    return Intl.message(
      'Dept Name',
      name: 'departmentName',
      desc: '',
      args: [],
    );
  }

  /// `Dept Head`
  String get departmentHead {
    return Intl.message(
      'Dept Head',
      name: 'departmentHead',
      desc: '',
      args: [],
    );
  }

  /// `Higher Dept`
  String get departmentHigher {
    return Intl.message(
      'Higher Dept',
      name: 'departmentHigher',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get yearSuffix {
    return Intl.message(
      '',
      name: 'yearSuffix',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get monthSuffix {
    return Intl.message(
      '',
      name: 'monthSuffix',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get daySuffix {
    return Intl.message(
      '',
      name: 'daySuffix',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message(
      'Full Name',
      name: 'fullName',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Position`
  String get position {
    return Intl.message(
      'Position',
      name: 'position',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get department {
    return Intl.message(
      'Department',
      name: 'department',
      desc: '',
      args: [],
    );
  }

  /// `Date of Entry`
  String get dateOfEntry {
    return Intl.message(
      'Date of Entry',
      name: 'dateOfEntry',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get remark {
    return Intl.message(
      'Remark',
      name: 'remark',
      desc: '',
      args: [],
    );
  }

  /// `Job Number`
  String get jobNumber {
    return Intl.message(
      'Job Number',
      name: 'jobNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter a name`
  String get hintFullName {
    return Intl.message(
      'Enter a name',
      name: 'hintFullName',
      desc: '',
      args: [],
    );
  }

  /// `Enter a phone`
  String get hintPhone {
    return Intl.message(
      'Enter a phone',
      name: 'hintPhone',
      desc: '',
      args: [],
    );
  }

  /// `Enter a position`
  String get hintPosition {
    return Intl.message(
      'Enter a position',
      name: 'hintPosition',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message(
      'Optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Delete Member`
  String get deleteStaff {
    return Intl.message(
      'Delete Member',
      name: 'deleteStaff',
      desc: '',
      args: [],
    );
  }

  /// `Set Department`
  String get setSuperDepartment {
    return Intl.message(
      'Set Department',
      name: 'setSuperDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Set Department Head`
  String get setDepartmentHead {
    return Intl.message(
      'Set Department Head',
      name: 'setDepartmentHead',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `Search Result`
  String get searchResultText {
    return Intl.message(
      'Search Result',
      name: 'searchResultText',
      desc: '',
      args: [],
    );
  }

  /// `Creator`
  String get creator {
    return Intl.message(
      'Creator',
      name: 'creator',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Create Group`
  String get createGroup {
    return Intl.message(
      'Create Group',
      name: 'createGroup',
      desc: '',
      args: [],
    );
  }

  /// `Group Name`
  String get groupName {
    return Intl.message(
      'Group Name',
      name: 'groupName',
      desc: '',
      args: [],
    );
  }

  /// `Enter group name`
  String get groupNameHint {
    return Intl.message(
      'Enter group name',
      name: 'groupNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Friend`
  String get friend {
    return Intl.message(
      'Friend',
      name: 'friend',
      desc: '',
      args: [],
    );
  }

  /// `Manager`
  String get manager {
    return Intl.message(
      'Manager',
      name: 'manager',
      desc: '',
      args: [],
    );
  }

  /// `Administrator`
  String get administrator {
    return Intl.message(
      'Administrator',
      name: 'administrator',
      desc: '',
      args: [],
    );
  }

  /// `Set Manager`
  String get setManager {
    return Intl.message(
      'Set Manager',
      name: 'setManager',
      desc: '',
      args: [],
    );
  }

  /// `Billing Information`
  String get billingInformation {
    return Intl.message(
      'Billing Information',
      name: 'billingInformation',
      desc: '',
      args: [],
    );
  }

  /// `Billing Header`
  String get billingHeader {
    return Intl.message(
      'Billing Header',
      name: 'billingHeader',
      desc: '',
      args: [],
    );
  }

  /// `Enter billing header`
  String get billingHeaderHintText {
    return Intl.message(
      'Enter billing header',
      name: 'billingHeaderHintText',
      desc: '',
      args: [],
    );
  }

  /// `Tax ID`
  String get taxID {
    return Intl.message(
      'Tax ID',
      name: 'taxID',
      desc: '',
      args: [],
    );
  }

  /// `Enter tax ID`
  String get taxIDHintText {
    return Intl.message(
      'Enter tax ID',
      name: 'taxIDHintText',
      desc: '',
      args: [],
    );
  }

  /// `Bank Account`
  String get bankAccount {
    return Intl.message(
      'Bank Account',
      name: 'bankAccount',
      desc: '',
      args: [],
    );
  }

  /// `Enter bank account`
  String get bankAccountHintText {
    return Intl.message(
      'Enter bank account',
      name: 'bankAccountHintText',
      desc: '',
      args: [],
    );
  }

  /// `Bank Of Deposit`
  String get bankOfDeposit {
    return Intl.message(
      'Bank Of Deposit',
      name: 'bankOfDeposit',
      desc: '',
      args: [],
    );
  }

  /// `Enter bank of deposit`
  String get bankOfDepositHintText {
    return Intl.message(
      'Enter bank of deposit',
      name: 'bankOfDepositHintText',
      desc: '',
      args: [],
    );
  }

  /// `Registered Address`
  String get registeredAddress {
    return Intl.message(
      'Registered Address',
      name: 'registeredAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter registered address`
  String get registeredAddressHintText {
    return Intl.message(
      'Enter registered address',
      name: 'registeredAddressHintText',
      desc: '',
      args: [],
    );
  }

  /// `Enter remark`
  String get remarkHintText {
    return Intl.message(
      'Enter remark',
      name: 'remarkHintText',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get member {
    return Intl.message(
      'Member',
      name: 'member',
      desc: '',
      args: [],
    );
  }

  /// `Generate exclusive QR code to invite `
  String get qrcodeRemark {
    return Intl.message(
      'Generate exclusive QR code to invite ',
      name: 'qrcodeRemark',
      desc: '',
      args: [],
    );
  }

  /// `Added`
  String get added {
    return Intl.message(
      'Added',
      name: 'added',
      desc: '',
      args: [],
    );
  }

  /// `Phone Contacts`
  String get phoneContacts {
    return Intl.message(
      'Phone Contacts',
      name: 'phoneContacts',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get photo {
    return Intl.message(
      'Photo',
      name: 'photo',
      desc: '',
      args: [],
    );
  }

  /// `Audio`
  String get audio {
    return Intl.message(
      'Audio',
      name: 'audio',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `Emoji`
  String get emoji {
    return Intl.message(
      'Emoji',
      name: 'emoji',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Invite`
  String get teamJoinTypeInvite {
    return Intl.message(
      'Invite',
      name: 'teamJoinTypeInvite',
      desc: '',
      args: [],
    );
  }

  /// `Invite successful`
  String get teamInviteSuccess {
    return Intl.message(
      'Invite successful',
      name: 'teamInviteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Invite {num} people successfully`
  String teamInviteSuccessNum(Object num) {
    return Intl.message(
      'Invite $num people successfully',
      name: 'teamInviteSuccessNum',
      desc: '',
      args: [num],
    );
  }

  /// `Invite failed`
  String get teamInviteFail {
    return Intl.message(
      'Invite failed',
      name: 'teamInviteFail',
      desc: '',
      args: [],
    );
  }

  /// `Create failure`
  String get createTeamFailure {
    return Intl.message(
      'Create failure',
      name: 'createTeamFailure',
      desc: '',
      args: [],
    );
  }

  /// `Operation failed`
  String get operateFailure {
    return Intl.message(
      'Operation failed',
      name: 'operateFailure',
      desc: '',
      args: [],
    );
  }

  /// `Network anomaly`
  String get networkAnomaly {
    return Intl.message(
      'Network anomaly',
      name: 'networkAnomaly',
      desc: '',
      args: [],
    );
  }

  /// `Name duplicated`
  String get nameDuplicated {
    return Intl.message(
      'Name duplicated',
      name: 'nameDuplicated',
      desc: '',
      args: [],
    );
  }

  /// `Don't disturb`
  String get doNotDisturb {
    return Intl.message(
      'Don\'t disturb',
      name: 'doNotDisturb',
      desc: '',
      args: [],
    );
  }

  /// `Delete the dept`
  String get deptDelete {
    return Intl.message(
      'Delete the dept',
      name: 'deptDelete',
      desc: '',
      args: [],
    );
  }

  /// `After deleting the Department, the Department data cannot be recovered, and the member's Department data will also be deleted.`
  String get deptDeleteConfirmContent {
    return Intl.message(
      'After deleting the Department, the Department data cannot be recovered, and the member\'s Department data will also be deleted.',
      name: 'deptDeleteConfirmContent',
      desc: '',
      args: [],
    );
  }

  /// `Is sure to delete the member?`
  String get memberDeleteConfirmTitle {
    return Intl.message(
      'Is sure to delete the member?',
      name: 'memberDeleteConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `After deleting the member, the data cannot be recovered.`
  String get memberDeleteConfirmContent {
    return Intl.message(
      'After deleting the member, the data cannot be recovered.',
      name: 'memberDeleteConfirmContent',
      desc: '',
      args: [],
    );
  }

  /// `No Requests`
  String get noTeamRequestsTitle {
    return Intl.message(
      'No Requests',
      name: 'noTeamRequestsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Invite members to join you Organization. New requests to join are displayed here.`
  String get noTeamRequestsContent {
    return Intl.message(
      'Invite members to join you Organization. New requests to join are displayed here.',
      name: 'noTeamRequestsContent',
      desc: '',
      args: [],
    );
  }

  /// `No Requests`
  String get noFriendRequestsTitle {
    return Intl.message(
      'No Requests',
      name: 'noFriendRequestsTitle',
      desc: '',
      args: [],
    );
  }

  /// `After inviting friends, new applications will appear here. After approval, you can become friends.`
  String get noFriendRequestsContent {
    return Intl.message(
      'After inviting friends, new applications will appear here. After approval, you can become friends.',
      name: 'noFriendRequestsContent',
      desc: '',
      args: [],
    );
  }

  /// `Invite`
  String get invite {
    return Intl.message(
      'Invite',
      name: 'invite',
      desc: '',
      args: [],
    );
  }

  /// `Clear success`
  String get clearSuccess {
    return Intl.message(
      'Clear success',
      name: 'clearSuccess',
      desc: '',
      args: [],
    );
  }

  /// `OK to exit`
  String get areYouSureExitThisChannel {
    return Intl.message(
      'OK to exit',
      name: 'areYouSureExitThisChannel',
      desc: '',
      args: [],
    );
  }

  /// `Exit success`
  String get exitSuccess {
    return Intl.message(
      'Exit success',
      name: 'exitSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Pined to top`
  String get pinedToTop {
    return Intl.message(
      'Pined to top',
      name: 'pinedToTop',
      desc: '',
      args: [],
    );
  }

  /// `Disable notification`
  String get disableNotification {
    return Intl.message(
      'Disable notification',
      name: 'disableNotification',
      desc: '',
      args: [],
    );
  }

  /// `Clear history`
  String get clearHistory {
    return Intl.message(
      'Clear history',
      name: 'clearHistory',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get haveRead {
    return Intl.message(
      'Read',
      name: 'haveRead',
      desc: '',
      args: [],
    );
  }

  /// `Save to local`
  String get saveToLocal {
    return Intl.message(
      'Save to local',
      name: 'saveToLocal',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get photograph {
    return Intl.message(
      'Camera',
      name: 'photograph',
      desc: '',
      args: [],
    );
  }

  /// `Select from phone album`
  String get photoAlbum {
    return Intl.message(
      'Select from phone album',
      name: 'photoAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Save success`
  String get saveSuccess {
    return Intl.message(
      'Save success',
      name: 'saveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Save failed`
  String get saveFailed {
    return Intl.message(
      'Save failed',
      name: 'saveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR Code and join our team`
  String get qrcodeTeamRemark {
    return Intl.message(
      'Scan the QR Code and join our team',
      name: 'qrcodeTeamRemark',
      desc: '',
      args: [],
    );
  }

  /// `Scan code to accept my card`
  String get qrcodeContactRemark {
    return Intl.message(
      'Scan code to accept my card',
      name: 'qrcodeContactRemark',
      desc: '',
      args: [],
    );
  }

  /// `Edit photo`
  String get editPhoto {
    return Intl.message(
      'Edit photo',
      name: 'editPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Tap to turn on`
  String get tapToTurnOn {
    return Intl.message(
      'Tap to turn on',
      name: 'tapToTurnOn',
      desc: '',
      args: [],
    );
  }

  /// `Tap to turn off`
  String get tapToTurnOff {
    return Intl.message(
      'Tap to turn off',
      name: 'tapToTurnOff',
      desc: '',
      args: [],
    );
  }

  /// `Only CoBiz QR code is supported`
  String get onlyForCoBizQrCode {
    return Intl.message(
      'Only CoBiz QR code is supported',
      name: 'onlyForCoBizQrCode',
      desc: '',
      args: [],
    );
  }

  /// `General Approval`
  String get generalApproval {
    return Intl.message(
      'General Approval',
      name: 'generalApproval',
      desc: '',
      args: [],
    );
  }

  /// `Approver`
  String get approver {
    return Intl.message(
      'Approver',
      name: 'approver',
      desc: '',
      args: [],
    );
  }

  /// `Notifier`
  String get notifier {
    return Intl.message(
      'Notifier',
      name: 'notifier',
      desc: '',
      args: [],
    );
  }

  /// `Send time`
  String get sendTime {
    return Intl.message(
      'Send time',
      name: 'sendTime',
      desc: '',
      args: [],
    );
  }

  /// `Work Report`
  String get workReport {
    return Intl.message(
      'Work Report',
      name: 'workReport',
      desc: '',
      args: [],
    );
  }

  /// `Sender`
  String get sender {
    return Intl.message(
      'Sender',
      name: 'sender',
      desc: '',
      args: [],
    );
  }

  /// `Revoke`
  String get revoke {
    return Intl.message(
      'Revoke',
      name: 'revoke',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get noData {
    return Intl.message(
      'No data',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Todo`
  String get todo {
    return Intl.message(
      'Todo',
      name: 'todo',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Initiated`
  String get initiated {
    return Intl.message(
      'Initiated',
      name: 'initiated',
      desc: '',
      args: [],
    );
  }

  /// `Cc me`
  String get copyMe {
    return Intl.message(
      'Cc me',
      name: 'copyMe',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get typeOfLeave {
    return Intl.message(
      'Type',
      name: 'typeOfLeave',
      desc: '',
      args: [],
    );
  }

  /// `Begin time`
  String get beginTime {
    return Intl.message(
      'Begin time',
      name: 'beginTime',
      desc: '',
      args: [],
    );
  }

  /// `End time`
  String get endTime {
    return Intl.message(
      'End time',
      name: 'endTime',
      desc: '',
      args: [],
    );
  }

  /// `Apply content`
  String get applyContent {
    return Intl.message(
      'Apply content',
      name: 'applyContent',
      desc: '',
      args: [],
    );
  }

  /// `Apply detail`
  String get applyDetail {
    return Intl.message(
      'Apply detail',
      name: 'applyDetail',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get expenseTotal {
    return Intl.message(
      'Total',
      name: 'expenseTotal',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get expenseType {
    return Intl.message(
      'Type',
      name: 'expenseType',
      desc: '',
      args: [],
    );
  }

  /// `Expense detail`
  String get expenseDetail {
    return Intl.message(
      'Expense detail',
      name: 'expenseDetail',
      desc: '',
      args: [],
    );
  }

  /// `Initiate approval`
  String get initiateApproval {
    return Intl.message(
      'Initiate approval',
      name: 'initiateApproval',
      desc: '',
      args: [],
    );
  }

  /// `Originating Task`
  String get initiateTask {
    return Intl.message(
      'Originating Task',
      name: 'initiateTask',
      desc: '',
      args: [],
    );
  }

  /// `Issue Task`
  String get issueTask {
    return Intl.message(
      'Issue Task',
      name: 'issueTask',
      desc: '',
      args: [],
    );
  }

  /// `Task`
  String get task {
    return Intl.message(
      'Task',
      name: 'task',
      desc: '',
      args: [],
    );
  }

  /// `Tasks initiated by {name}`
  String taskTitle(Object name) {
    return Intl.message(
      'Tasks initiated by $name',
      name: 'taskTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Work report submitted by {name}`
  String logTitle(Object name) {
    return Intl.message(
      'Work report submitted by $name',
      name: 'logTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Meeting minutes posted by {name}`
  String meetingMinTitle(Object name) {
    return Intl.message(
      'Meeting minutes posted by $name',
      name: 'meetingMinTitle',
      desc: '',
      args: [name],
    );
  }

  /// `{name} Announcement`
  String teamNotice(Object name) {
    return Intl.message(
      '$name Announcement',
      name: 'teamNotice',
      desc: '',
      args: [name],
    );
  }

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Max.`
  String get maxSelect {
    return Intl.message(
      'Max.',
      name: 'maxSelect',
      desc: '',
      args: [],
    );
  }

  /// `View all`
  String get viewAll {
    return Intl.message(
      'View all',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Cc to`
  String get copyTo {
    return Intl.message(
      'Cc to',
      name: 'copyTo',
      desc: '',
      args: [],
    );
  }

  /// `Approval Workflow`
  String get approvalWorkflow {
    return Intl.message(
      'Approval Workflow',
      name: 'approvalWorkflow',
      desc: '',
      args: [],
    );
  }

  /// `Follow-up examination and approval`
  String get lineUpToApproval {
    return Intl.message(
      'Follow-up examination and approval',
      name: 'lineUpToApproval',
      desc: '',
      args: [],
    );
  }

  /// `AM`
  String get morning {
    return Intl.message(
      'AM',
      name: 'morning',
      desc: '',
      args: [],
    );
  }

  /// `PM`
  String get afternoon {
    return Intl.message(
      'PM',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `My QR code`
  String get myQrc {
    return Intl.message(
      'My QR code',
      name: 'myQrc',
      desc: '',
      args: [],
    );
  }

  /// `Invite friends`
  String get inviteFriends {
    return Intl.message(
      'Invite friends',
      name: 'inviteFriends',
      desc: '',
      args: [],
    );
  }

  /// `Contact us`
  String get contactUs {
    return Intl.message(
      'Contact us',
      name: 'contactUs',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR code to add friends`
  String get scanQrcAddFriends {
    return Intl.message(
      'Scan QR code to add friends',
      name: 'scanQrcAddFriends',
      desc: '',
      args: [],
    );
  }

  /// `QR code business card`
  String get qrCodeCard {
    return Intl.message(
      'QR code business card',
      name: 'qrCodeCard',
      desc: '',
      args: [],
    );
  }

  /// `Notification settings`
  String get notificationSettings {
    return Intl.message(
      'Notification settings',
      name: 'notificationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Group chat`
  String get groupChat {
    return Intl.message(
      'Group chat',
      name: 'groupChat',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `Everyone`
  String get everyone {
    return Intl.message(
      'Everyone',
      name: 'everyone',
      desc: '',
      args: [],
    );
  }

  /// `Privacy security`
  String get privacySecurity {
    return Intl.message(
      'Privacy security',
      name: 'privacySecurity',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message(
      'Privacy',
      name: 'privacy',
      desc: '',
      args: [],
    );
  }

  /// `User blocked`
  String get userBlocked {
    return Intl.message(
      'User blocked',
      name: 'userBlocked',
      desc: '',
      args: [],
    );
  }

  /// `Online status`
  String get onlineStatus {
    return Intl.message(
      'Online status',
      name: 'onlineStatus',
      desc: '',
      args: [],
    );
  }

  /// `Avatar`
  String get avatar {
    return Intl.message(
      'Avatar',
      name: 'avatar',
      desc: '',
      args: [],
    );
  }

  /// `Citation forwarding source`
  String get citationForwardingSource {
    return Intl.message(
      'Citation forwarding source',
      name: 'citationForwardingSource',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get call {
    return Intl.message(
      'Call',
      name: 'call',
      desc: '',
      args: [],
    );
  }

  /// `Secure chat`
  String get secureChat {
    return Intl.message(
      'Secure chat',
      name: 'secureChat',
      desc: '',
      args: [],
    );
  }

  /// `2-step verification`
  String get twoStepVerification {
    return Intl.message(
      '2-step verification',
      name: 'twoStepVerification',
      desc: '',
      args: [],
    );
  }

  /// `Active session`
  String get activeSession {
    return Intl.message(
      'Active session',
      name: 'activeSession',
      desc: '',
      args: [],
    );
  }

  /// `Empty cloud contacts`
  String get emptyCloudContacts {
    return Intl.message(
      'Empty cloud contacts',
      name: 'emptyCloudContacts',
      desc: '',
      args: [],
    );
  }

  /// `Sync contacts`
  String get syncContacts {
    return Intl.message(
      'Sync contacts',
      name: 'syncContacts',
      desc: '',
      args: [],
    );
  }

  /// `Push frequent contacts`
  String get pushFrequentContacts {
    return Intl.message(
      'Push frequent contacts',
      name: 'pushFrequentContacts',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get advanced {
    return Intl.message(
      'Advanced',
      name: 'advanced',
      desc: '',
      args: [],
    );
  }

  /// `Delete all favorites`
  String get deleteAllFavorites {
    return Intl.message(
      'Delete all favorites',
      name: 'deleteAllFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Delete my account if away for`
  String get deleteMyAccountIfAwayFor {
    return Intl.message(
      'Delete my account if away for',
      name: 'deleteMyAccountIfAwayFor',
      desc: '',
      args: [],
    );
  }

  /// `Link preview`
  String get linkPreview {
    return Intl.message(
      'Link preview',
      name: 'linkPreview',
      desc: '',
      args: [],
    );
  }

  /// `Real name verify`
  String get realNameVerify {
    return Intl.message(
      'Real name verify',
      name: 'realNameVerify',
      desc: '',
      args: [],
    );
  }

  /// `Storage and network usage`
  String get storageAndNetworkUsage {
    return Intl.message(
      'Storage and network usage',
      name: 'storageAndNetworkUsage',
      desc: '',
      args: [],
    );
  }

  /// `Storage usage`
  String get storageUsage {
    return Intl.message(
      'Storage usage',
      name: 'storageUsage',
      desc: '',
      args: [],
    );
  }

  /// `Cellular data usage`
  String get cellularDataUsage {
    return Intl.message(
      'Cellular data usage',
      name: 'cellularDataUsage',
      desc: '',
      args: [],
    );
  }

  /// `Download media automatically`
  String get downloadMediaAutomatically {
    return Intl.message(
      'Download media automatically',
      name: 'downloadMediaAutomatically',
      desc: '',
      args: [],
    );
  }

  /// `When cellular used`
  String get whenUsedCellular {
    return Intl.message(
      'When cellular used',
      name: 'whenUsedCellular',
      desc: '',
      args: [],
    );
  }

  /// `When wifi used`
  String get whenUsedWifi {
    return Intl.message(
      'When wifi used',
      name: 'whenUsedWifi',
      desc: '',
      args: [],
    );
  }

  /// `Auto play`
  String get autoPlay {
    return Intl.message(
      'Auto play',
      name: 'autoPlay',
      desc: '',
      args: [],
    );
  }

  /// `Git picture`
  String get gitPicture {
    return Intl.message(
      'Git picture',
      name: 'gitPicture',
      desc: '',
      args: [],
    );
  }

  /// `Data store`
  String get dataStore {
    return Intl.message(
      'Data store',
      name: 'dataStore',
      desc: '',
      args: [],
    );
  }

  /// `Change language`
  String get changeLanguage {
    return Intl.message(
      'Change language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `System settings`
  String get systemSettings {
    return Intl.message(
      'System settings',
      name: 'systemSettings',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Forward`
  String get forward {
    return Intl.message(
      'Forward',
      name: 'forward',
      desc: '',
      args: [],
    );
  }

  /// `Favorite`
  String get favorite {
    return Intl.message(
      'Favorite',
      name: 'favorite',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Forward to:`
  String get forwardTo {
    return Intl.message(
      'Forward to:',
      name: 'forwardTo',
      desc: '',
      args: [],
    );
  }

  /// `Failure`
  String get failure {
    return Intl.message(
      'Failure',
      name: 'failure',
      desc: '',
      args: [],
    );
  }

  /// `Data usage`
  String get dataUsage {
    return Intl.message(
      'Data usage',
      name: 'dataUsage',
      desc: '',
      args: [],
    );
  }

  /// `Media retention time`
  String get mediaRetentionTime {
    return Intl.message(
      'Media retention time',
      name: 'mediaRetentionTime',
      desc: '',
      args: [],
    );
  }

  /// `To save storage space, expired files will be deleted`
  String get dataUsageTip {
    return Intl.message(
      'To save storage space, expired files will be deleted',
      name: 'dataUsageTip',
      desc: '',
      args: [],
    );
  }

  /// `Keep forever`
  String get keepForever {
    return Intl.message(
      'Keep forever',
      name: 'keepForever',
      desc: '',
      args: [],
    );
  }

  /// `Three days`
  String get threeDays {
    return Intl.message(
      'Three days',
      name: 'threeDays',
      desc: '',
      args: [],
    );
  }

  /// `One week`
  String get oneWeek {
    return Intl.message(
      'One week',
      name: 'oneWeek',
      desc: '',
      args: [],
    );
  }

  /// `One month`
  String get oneMonth {
    return Intl.message(
      'One month',
      name: 'oneMonth',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get clearCache {
    return Intl.message(
      'Clear cache',
      name: 'clearCache',
      desc: '',
      args: [],
    );
  }

  /// `Local database`
  String get localDatabase {
    return Intl.message(
      'Local database',
      name: 'localDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Half an hour ago`
  String get halfHourAgo {
    return Intl.message(
      'Half an hour ago',
      name: 'halfHourAgo',
      desc: '',
      args: [],
    );
  }

  /// `1 hour ago`
  String get oneHourAgo {
    return Intl.message(
      '1 hour ago',
      name: 'oneHourAgo',
      desc: '',
      args: [],
    );
  }

  /// ` hours ago`
  String get hoursAgo {
    return Intl.message(
      ' hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [],
    );
  }

  /// `Task Name`
  String get taskName {
    return Intl.message(
      'Task Name',
      name: 'taskName',
      desc: '',
      args: [],
    );
  }

  /// `Enter task name`
  String get enterTaskName {
    return Intl.message(
      'Enter task name',
      name: 'enterTaskName',
      desc: '',
      args: [],
    );
  }

  /// `Task Detail`
  String get taskDetail {
    return Intl.message(
      'Task Detail',
      name: 'taskDetail',
      desc: '',
      args: [],
    );
  }

  /// `Enter task detail`
  String get enterTaskDetail {
    return Intl.message(
      'Enter task detail',
      name: 'enterTaskDetail',
      desc: '',
      args: [],
    );
  }

  /// `Executor`
  String get executor {
    return Intl.message(
      'Executor',
      name: 'executor',
      desc: '',
      args: [],
    );
  }

  /// `Finish Time`
  String get finishTime {
    return Intl.message(
      'Finish Time',
      name: 'finishTime',
      desc: '',
      args: [],
    );
  }

  /// `Reminder Time`
  String get reminderTime {
    return Intl.message(
      'Reminder Time',
      name: 'reminderTime',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get publish {
    return Intl.message(
      'Publish',
      name: 'publish',
      desc: '',
      args: [],
    );
  }

  /// `Folder`
  String get folder {
    return Intl.message(
      'Folder',
      name: 'folder',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get approve {
    return Intl.message(
      'Approve',
      name: 'approve',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Common`
  String get commonlyUsed {
    return Intl.message(
      'Common',
      name: 'commonlyUsed',
      desc: '',
      args: [],
    );
  }

  /// `Recording time is too short`
  String get recordTimeShort {
    return Intl.message(
      'Recording time is too short',
      name: 'recordTimeShort',
      desc: '',
      args: [],
    );
  }

  /// `Hold to Talk`
  String get holdDownToSpeak {
    return Intl.message(
      'Hold to Talk',
      name: 'holdDownToSpeak',
      desc: '',
      args: [],
    );
  }

  /// `Release to cancel`
  String get cancelSend {
    return Intl.message(
      'Release to cancel',
      name: 'cancelSend',
      desc: '',
      args: [],
    );
  }

  /// `Swipe up to cancel`
  String get fingerUp {
    return Intl.message(
      'Swipe up to cancel',
      name: 'fingerUp',
      desc: '',
      args: [],
    );
  }

  /// `Release send`
  String get releaseSend {
    return Intl.message(
      'Release send',
      name: 'releaseSend',
      desc: '',
      args: [],
    );
  }

  /// `Release cancel`
  String get releaseCancel {
    return Intl.message(
      'Release cancel',
      name: 'releaseCancel',
      desc: '',
      args: [],
    );
  }

  /// `Please try again later`
  String get tryAgainLater {
    return Intl.message(
      'Please try again later',
      name: 'tryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Send failed`
  String get sendFail {
    return Intl.message(
      'Send failed',
      name: 'sendFail',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Enter phone number`
  String get plzEnterPhone {
    return Intl.message(
      'Enter phone number',
      name: 'plzEnterPhone',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get sendSms {
    return Intl.message(
      'Send',
      name: 'sendSms',
      desc: '',
      args: [],
    );
  }

  /// `Resend`
  String get reSendSms {
    return Intl.message(
      'Resend',
      name: 'reSendSms',
      desc: '',
      args: [],
    );
  }

  /// `{time}s`
  String verifyTimerStr(Object time) {
    return Intl.message(
      '${time}s',
      name: 'verifyTimerStr',
      desc: '',
      args: [time],
    );
  }

  /// `Registration means consent`
  String get loginAndAgree {
    return Intl.message(
      'Registration means consent',
      name: 'loginAndAgree',
      desc: '',
      args: [],
    );
  }

  /// `User Agreement`
  String get userAgreement {
    return Intl.message(
      'User Agreement',
      name: 'userAgreement',
      desc: '',
      args: [],
    );
  }

  /// `Enter verification code`
  String get plzEnterVfiCode {
    return Intl.message(
      'Enter verification code',
      name: 'plzEnterVfiCode',
      desc: '',
      args: [],
    );
  }

  /// `&`
  String get and {
    return Intl.message(
      '&',
      name: 'and',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `(This software is prohibited to be registered for use by users under the age of 18)`
  String get warning {
    return Intl.message(
      '(This software is prohibited to be registered for use by users under the age of 18)',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginBtn {
    return Intl.message(
      'Login',
      name: 'loginBtn',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get wallet {
    return Intl.message(
      'Wallet',
      name: 'wallet',
      desc: '',
      args: [],
    );
  }

  /// `Select region`
  String get selectRegion {
    return Intl.message(
      'Select region',
      name: 'selectRegion',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Enter nickname`
  String get enterNickname {
    return Intl.message(
      'Enter nickname',
      name: 'enterNickname',
      desc: '',
      args: [],
    );
  }

  /// `Upload Avatar`
  String get enterAvatar {
    return Intl.message(
      'Upload Avatar',
      name: 'enterAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Improve Data`
  String get improveData {
    return Intl.message(
      'Improve Data',
      name: 'improveData',
      desc: '',
      args: [],
    );
  }

  /// `Region`
  String get region {
    return Intl.message(
      'Region',
      name: 'region',
      desc: '',
      args: [],
    );
  }

  /// `New Friends`
  String get newFriends {
    return Intl.message(
      'New Friends',
      name: 'newFriends',
      desc: '',
      args: [],
    );
  }

  /// `No content`
  String get noContent {
    return Intl.message(
      'No content',
      name: 'noContent',
      desc: '',
      args: [],
    );
  }

  /// `Search chat`
  String get searchChat {
    return Intl.message(
      'Search chat',
      name: 'searchChat',
      desc: '',
      args: [],
    );
  }

  /// `Search for contacts`
  String get searchContact {
    return Intl.message(
      'Search for contacts',
      name: 'searchContact',
      desc: '',
      args: [],
    );
  }

  /// `Search country / area code`
  String get searchCode {
    return Intl.message(
      'Search country / area code',
      name: 'searchCode',
      desc: '',
      args: [],
    );
  }

  /// `Search team members`
  String get searchTeamMember {
    return Intl.message(
      'Search team members',
      name: 'searchTeamMember',
      desc: '',
      args: [],
    );
  }

  /// `Enter the correct content`
  String get plzEnterRight {
    return Intl.message(
      'Enter the correct content',
      name: 'plzEnterRight',
      desc: '',
      args: [],
    );
  }

  /// `Can't add myself`
  String get cantAddMine {
    return Intl.message(
      'Can\'t add myself',
      name: 'cantAddMine',
      desc: '',
      args: [],
    );
  }

  /// `Search phone number`
  String get searchPhone {
    return Intl.message(
      'Search phone number',
      name: 'searchPhone',
      desc: '',
      args: [],
    );
  }

  /// `No results found for “{s}”`
  String searchNothing(Object s) {
    return Intl.message(
      'No results found for “$s”',
      name: 'searchNothing',
      desc: '',
      args: [s],
    );
  }

  /// `Choose area code`
  String get chooseAreaCode {
    return Intl.message(
      'Choose area code',
      name: 'chooseAreaCode',
      desc: '',
      args: [],
    );
  }

  /// `The message is successfully sent but rejected by the receiver.`
  String get blockedTip {
    return Intl.message(
      'The message is successfully sent but rejected by the receiver.',
      name: 'blockedTip',
      desc: '',
      args: [],
    );
  }

  /// `[The message type is not currently supported]`
  String get notSupportThisMsg {
    return Intl.message(
      '[The message type is not currently supported]',
      name: 'notSupportThisMsg',
      desc: '',
      args: [],
    );
  }

  /// `You have added {who} as contact. Start chatting!`
  String addedContactToChat(Object who) {
    return Intl.message(
      'You have added $who as contact. Start chatting!',
      name: 'addedContactToChat',
      desc: '',
      args: [who],
    );
  }

  /// `I invited {them}`
  String invitedThem(Object them) {
    return Intl.message(
      'I invited $them',
      name: 'invitedThem',
      desc: '',
      args: [them],
    );
  }

  /// `invited me`
  String get inviteMeToGroupChat {
    return Intl.message(
      'invited me',
      name: 'inviteMeToGroupChat',
      desc: '',
      args: [],
    );
  }

  /// `{who} invited {them}`
  String whoInvitedThem(Object who, Object them) {
    return Intl.message(
      '$who invited $them',
      name: 'whoInvitedThem',
      desc: '',
      args: [who, them],
    );
  }

  /// `{who} left the group`
  String leftTheGroup(Object who) {
    return Intl.message(
      '$who left the group',
      name: 'leftTheGroup',
      desc: '',
      args: [who],
    );
  }

  /// `Announcement updated`
  String get issuedNewNotice {
    return Intl.message(
      'Announcement updated',
      name: 'issuedNewNotice',
      desc: '',
      args: [],
    );
  }

  /// `Someone @Me`
  String get hasAtMe {
    return Intl.message(
      'Someone @Me',
      name: 'hasAtMe',
      desc: '',
      args: [],
    );
  }

  /// `Group Notice`
  String get groupAnnouncement {
    return Intl.message(
      'Group Notice',
      name: 'groupAnnouncement',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `You've been removed`
  String get removeGroup {
    return Intl.message(
      'You\'ve been removed',
      name: 'removeGroup',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to delete this chat?`
  String get sureDeleteTheChat {
    return Intl.message(
      'Are you sure to delete this chat?',
      name: 'sureDeleteTheChat',
      desc: '',
      args: [],
    );
  }

  /// `@`
  String get atTa {
    return Intl.message(
      '@',
      name: 'atTa',
      desc: '',
      args: [],
    );
  }

  /// `Group chat details`
  String get groupDetail {
    return Intl.message(
      'Group chat details',
      name: 'groupDetail',
      desc: '',
      args: [],
    );
  }

  /// `Group Name`
  String get groupChatName {
    return Intl.message(
      'Group Name',
      name: 'groupChatName',
      desc: '',
      args: [],
    );
  }

  /// `Save group chat`
  String get saveGroupChat {
    return Intl.message(
      'Save group chat',
      name: 'saveGroupChat',
      desc: '',
      args: [],
    );
  }

  /// `Complaints`
  String get complaints {
    return Intl.message(
      'Complaints',
      name: 'complaints',
      desc: '',
      args: [],
    );
  }

  /// `Posting inappropriate content is harassing me`
  String get harass {
    return Intl.message(
      'Posting inappropriate content is harassing me',
      name: 'harass',
      desc: '',
      args: [],
    );
  }

  /// `Fraudulent money`
  String get cheatMoney {
    return Intl.message(
      'Fraudulent money',
      name: 'cheatMoney',
      desc: '',
      args: [],
    );
  }

  /// `This account may have been compromised`
  String get misappropriation {
    return Intl.message(
      'This account may have been compromised',
      name: 'misappropriation',
      desc: '',
      args: [],
    );
  }

  /// `Infringement`
  String get infringement {
    return Intl.message(
      'Infringement',
      name: 'infringement',
      desc: '',
      args: [],
    );
  }

  /// `Publish counterfeit information`
  String get counterfeit {
    return Intl.message(
      'Publish counterfeit information',
      name: 'counterfeit',
      desc: '',
      args: [],
    );
  }

  /// `Impersonate others`
  String get impersonate {
    return Intl.message(
      'Impersonate others',
      name: 'impersonate',
      desc: '',
      args: [],
    );
  }

  /// `other`
  String get other {
    return Intl.message(
      'other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Enter the complaint description`
  String get complaintsInfo {
    return Intl.message(
      'Enter the complaint description',
      name: 'complaintsInfo',
      desc: '',
      args: [],
    );
  }

  /// `Complaint successful`
  String get complaintSuccessful {
    return Intl.message(
      'Complaint successful',
      name: 'complaintSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Feedback success`
  String get feedbackSuccess {
    return Intl.message(
      'Feedback success',
      name: 'feedbackSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Receive info notice`
  String get receiveNotice {
    return Intl.message(
      'Receive info notice',
      name: 'receiveNotice',
      desc: '',
      args: [],
    );
  }

  /// `Show notice details`
  String get showDetails {
    return Intl.message(
      'Show notice details',
      name: 'showDetails',
      desc: '',
      args: [],
    );
  }

  /// `Receive chat notice`
  String get receiveChatNotice {
    return Intl.message(
      'Receive chat notice',
      name: 'receiveChatNotice',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic notice`
  String get dynamicNotive {
    return Intl.message(
      'Dynamic notice',
      name: 'dynamicNotive',
      desc: '',
      args: [],
    );
  }

  /// `Don't receive new message alerts after closing`
  String get receiveNoticeLabel {
    return Intl.message(
      'Don\'t receive new message alerts after closing',
      name: 'receiveNoticeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Message details will not be displayed in push after shutdown`
  String get showDetailsLabel {
    return Intl.message(
      'Message details will not be displayed in push after shutdown',
      name: 'showDetailsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Don't receive private chat messages after closing`
  String get receiveChatNoticeLabel {
    return Intl.message(
      'Don\'t receive private chat messages after closing',
      name: 'receiveChatNoticeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Don't prompt for new dynamic notification after closing`
  String get dynamicNotiveLabel {
    return Intl.message(
      'Don\'t prompt for new dynamic notification after closing',
      name: 'dynamicNotiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sound`
  String get voice {
    return Intl.message(
      'Sound',
      name: 'voice',
      desc: '',
      args: [],
    );
  }

  /// `Voice settings for In-App notifications`
  String get voiceTip {
    return Intl.message(
      'Voice settings for In-App notifications',
      name: 'voiceTip',
      desc: '',
      args: [],
    );
  }

  /// `Vibrate`
  String get vibration {
    return Intl.message(
      'Vibrate',
      name: 'vibration',
      desc: '',
      args: [],
    );
  }

  /// `Vibrate settings for In-App notifications`
  String get vibrationTip {
    return Intl.message(
      'Vibrate settings for In-App notifications',
      name: 'vibrationTip',
      desc: '',
      args: [],
    );
  }

  /// `Choose up to eight`
  String get max8photo {
    return Intl.message(
      'Choose up to eight',
      name: 'max8photo',
      desc: '',
      args: [],
    );
  }

  /// `Choose up to six`
  String get max6photo {
    return Intl.message(
      'Choose up to six',
      name: 'max6photo',
      desc: '',
      args: [],
    );
  }

  /// `Delete and exit`
  String get deleteAndExit {
    return Intl.message(
      'Delete and exit',
      name: 'deleteAndExit',
      desc: '',
      args: [],
    );
  }

  /// `Chat with Ta`
  String get chatWithTa {
    return Intl.message(
      'Chat with Ta',
      name: 'chatWithTa',
      desc: '',
      args: [],
    );
  }

  /// `Delete friend`
  String get deleteFriend {
    return Intl.message(
      'Delete friend',
      name: 'deleteFriend',
      desc: '',
      args: [],
    );
  }

  /// `After deleting the friend, the chat history will be cleared`
  String get deleteFriendHint {
    return Intl.message(
      'After deleting the friend, the chat history will be cleared',
      name: 'deleteFriendHint',
      desc: '',
      args: [],
    );
  }

  /// `Set Notes`
  String get setNotes {
    return Intl.message(
      'Set Notes',
      name: 'setNotes',
      desc: '',
      args: [],
    );
  }

  /// `Enter the remark name`
  String get plzFillRemarkName {
    return Intl.message(
      'Enter the remark name',
      name: 'plzFillRemarkName',
      desc: '',
      args: [],
    );
  }

  /// `Signature`
  String get signature {
    return Intl.message(
      'Signature',
      name: 'signature',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Burned immediately`
  String get burnedImmediately {
    return Intl.message(
      'Burned immediately',
      name: 'burnedImmediately',
      desc: '',
      args: [],
    );
  }

  /// `20 second`
  String get s20 {
    return Intl.message(
      '20 second',
      name: 's20',
      desc: '',
      args: [],
    );
  }

  /// `1 minute`
  String get m1 {
    return Intl.message(
      '1 minute',
      name: 'm1',
      desc: '',
      args: [],
    );
  }

  /// `5 minute`
  String get m5 {
    return Intl.message(
      '5 minute',
      name: 'm5',
      desc: '',
      args: [],
    );
  }

  /// `1 hour`
  String get h1 {
    return Intl.message(
      '1 hour',
      name: 'h1',
      desc: '',
      args: [],
    );
  }

  /// `24 hour`
  String get h24 {
    return Intl.message(
      '24 hour',
      name: 'h24',
      desc: '',
      args: [],
    );
  }

  /// `Burn Msg`
  String get burnAfterReading {
    return Intl.message(
      'Burn Msg',
      name: 'burnAfterReading',
      desc: '',
      args: [],
    );
  }

  /// `Blacklist`
  String get blacklist {
    return Intl.message(
      'Blacklist',
      name: 'blacklist',
      desc: '',
      args: [],
    );
  }

  /// `Add To Blacklist`
  String get addToBlacklist {
    return Intl.message(
      'Add To Blacklist',
      name: 'addToBlacklist',
      desc: '',
      args: [],
    );
  }

  /// `Join the blacklist, you will no longer receive messages from each other`
  String get putBlockUwill {
    return Intl.message(
      'Join the blacklist, you will no longer receive messages from each other',
      name: 'putBlockUwill',
      desc: '',
      args: [],
    );
  }

  /// `I am {who}`
  String iAmWho(Object who) {
    return Intl.message(
      'I am $who',
      name: 'iAmWho',
      desc: '',
      args: [who],
    );
  }

  /// `Friend requests`
  String get friendRequests {
    return Intl.message(
      'Friend requests',
      name: 'friendRequests',
      desc: '',
      args: [],
    );
  }

  /// `Already friends`
  String get alreadyFriends {
    return Intl.message(
      'Already friends',
      name: 'alreadyFriends',
      desc: '',
      args: [],
    );
  }

  /// `Friend application sent successfully`
  String get applicationSentOk {
    return Intl.message(
      'Friend application sent successfully',
      name: 'applicationSentOk',
      desc: '',
      args: [],
    );
  }

  /// `Verify Message`
  String get verifyMessage {
    return Intl.message(
      'Verify Message',
      name: 'verifyMessage',
      desc: '',
      args: [],
    );
  }

  /// `After leaving the group chat, the chat history will be cleared`
  String get deleteAndExitHint {
    return Intl.message(
      'After leaving the group chat, the chat history will be cleared',
      name: 'deleteAndExitHint',
      desc: '',
      args: [],
    );
  }

  /// `Select Contact`
  String get chooseFriend {
    return Intl.message(
      'Select Contact',
      name: 'chooseFriend',
      desc: '',
      args: [],
    );
  }

  /// `Group chat with at least three people`
  String get groupMin3 {
    return Intl.message(
      'Group chat with at least three people',
      name: 'groupMin3',
      desc: '',
      args: [],
    );
  }

  /// `Select up to 50 people when starting a group chat`
  String get groupMax50 {
    return Intl.message(
      'Select up to 50 people when starting a group chat',
      name: 'groupMax50',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `New Group`
  String get newGroup {
    return Intl.message(
      'New Group',
      name: 'newGroup',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get create {
    return Intl.message(
      'Start',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `selected ({number})`
  String selectedNum(Object number) {
    return Intl.message(
      'selected ($number)',
      name: 'selectedNum',
      desc: '',
      args: [number],
    );
  }

  /// `Only Cobiz QR code is supported`
  String get onlyForCobizQrCode {
    return Intl.message(
      'Only Cobiz QR code is supported',
      name: 'onlyForCobizQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter a group name`
  String get plzFillGroupName {
    return Intl.message(
      'Enter a group name',
      name: 'plzFillGroupName',
      desc: '',
      args: [],
    );
  }

  /// `Delete members`
  String get deleteGroupPerson {
    return Intl.message(
      'Delete members',
      name: 'deleteGroupPerson',
      desc: '',
      args: [],
    );
  }

  /// `Invite History`
  String get inviteHistory {
    return Intl.message(
      'Invite History',
      name: 'inviteHistory',
      desc: '',
      args: [],
    );
  }

  /// `Invite Code`
  String get inviteCode {
    return Intl.message(
      'Invite Code',
      name: 'inviteCode',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLinkShare {
    return Intl.message(
      'Copy link',
      name: 'copyLinkShare',
      desc: '',
      args: [],
    );
  }

  /// `Save picture`
  String get savePicturesShare {
    return Intl.message(
      'Save picture',
      name: 'savePicturesShare',
      desc: '',
      args: [],
    );
  }

  /// `Copy Successfully`
  String get copySuccess {
    return Intl.message(
      'Copy Successfully',
      name: 'copySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Start your chat tour now`
  String get startChat {
    return Intl.message(
      'Start your chat tour now',
      name: 'startChat',
      desc: '',
      args: [],
    );
  }

  /// `Confirm call {phone}`
  String confirmCallPhone(Object phone) {
    return Intl.message(
      'Confirm call $phone',
      name: 'confirmCallPhone',
      desc: '',
      args: [phone],
    );
  }

  /// `No messages selected`
  String get noMessagesSelected {
    return Intl.message(
      'No messages selected',
      name: 'noMessagesSelected',
      desc: '',
      args: [],
    );
  }

  /// `Cobiz does not have permission to access the microphone. Do you want to turn it on?`
  String get recordPermissionDenied {
    return Intl.message(
      'Cobiz does not have permission to access the microphone. Do you want to turn it on?',
      name: 'recordPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Select message`
  String get selectMsg {
    return Intl.message(
      'Select message',
      name: 'selectMsg',
      desc: '',
      args: [],
    );
  }

  /// `No more records`
  String get noMoreMsg {
    return Intl.message(
      'No more records',
      name: 'noMoreMsg',
      desc: '',
      args: [],
    );
  }

  /// `No more data`
  String get noMoreData {
    return Intl.message(
      'No more data',
      name: 'noMoreData',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get collectionBackup {
    return Intl.message(
      'Favorites',
      name: 'collectionBackup',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteMsg {
    return Intl.message(
      'Delete',
      name: 'deleteMsg',
      desc: '',
      args: [],
    );
  }

  /// `Checkbox`
  String get checkbox {
    return Intl.message(
      'Checkbox',
      name: 'checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Choose one chat`
  String get chooseOntChat {
    return Intl.message(
      'Choose one chat',
      name: 'chooseOntChat',
      desc: '',
      args: [],
    );
  }

  /// `Select contact`
  String get selectContact {
    return Intl.message(
      'Select contact',
      name: 'selectContact',
      desc: '',
      args: [],
    );
  }

  /// `Recent chat`
  String get recentChat {
    return Intl.message(
      'Recent chat',
      name: 'recentChat',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to delete the selected message?`
  String get sureDeleteSelectMsg {
    return Intl.message(
      'Are you sure to delete the selected message?',
      name: 'sureDeleteSelectMsg',
      desc: '',
      args: [],
    );
  }

  /// `Choose up to 100`
  String get max100selected {
    return Intl.message(
      'Choose up to 100',
      name: 'max100selected',
      desc: '',
      args: [],
    );
  }

  /// `Edit announcement`
  String get editAnnouncement {
    return Intl.message(
      'Edit announcement',
      name: 'editAnnouncement',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get afterToTalk {
    return Intl.message(
      'Later',
      name: 'afterToTalk',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade`
  String get experienceNow {
    return Intl.message(
      'Upgrade',
      name: 'experienceNow',
      desc: '',
      args: [],
    );
  }

  /// `Installing...`
  String get installApp {
    return Intl.message(
      'Installing...',
      name: 'installApp',
      desc: '',
      args: [],
    );
  }

  /// `Downloading {percent}%`
  String downloading(Object percent) {
    return Intl.message(
      'Downloading $percent%',
      name: 'downloading',
      desc: '',
      args: [percent],
    );
  }

  /// `Enter the msg content`
  String get enterTheMessageContent {
    return Intl.message(
      'Enter the msg content',
      name: 'enterTheMessageContent',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get idNum {
    return Intl.message(
      'ID',
      name: 'idNum',
      desc: '',
      args: [],
    );
  }

  /// `Please input your ID card number`
  String get plzEnterIdNum {
    return Intl.message(
      'Please input your ID card number',
      name: 'plzEnterIdNum',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a description`
  String get plzEnterDes {
    return Intl.message(
      'Please enter a description',
      name: 'plzEnterDes',
      desc: '',
      args: [],
    );
  }

  /// `Cobiz does not have the permission to access the address book. Do you want to open it?`
  String get contactPermission {
    return Intl.message(
      'Cobiz does not have the permission to access the address book. Do you want to open it?',
      name: 'contactPermission',
      desc: '',
      args: [],
    );
  }

  /// `Search group`
  String get searchGroup {
    return Intl.message(
      'Search group',
      name: 'searchGroup',
      desc: '',
      args: [],
    );
  }

  /// `The network is disconnected, please connect to the network!`
  String get noNetwork {
    return Intl.message(
      'The network is disconnected, please connect to the network!',
      name: 'noNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Daily record`
  String get dailyRecord {
    return Intl.message(
      'Daily record',
      name: 'dailyRecord',
      desc: '',
      args: [],
    );
  }

  /// `Write log`
  String get writeLog {
    return Intl.message(
      'Write log',
      name: 'writeLog',
      desc: '',
      args: [],
    );
  }

  /// `Logging`
  String get logging {
    return Intl.message(
      'Logging',
      name: 'logging',
      desc: '',
      args: [],
    );
  }

  /// `Meeting`
  String get meeting {
    return Intl.message(
      'Meeting',
      name: 'meeting',
      desc: '',
      args: [],
    );
  }

  /// `Conference theme`
  String get meetingTitle {
    return Intl.message(
      'Conference theme',
      name: 'meetingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Meeting description`
  String get meetingDes {
    return Intl.message(
      'Meeting description',
      name: 'meetingDes',
      desc: '',
      args: [],
    );
  }

  /// `Participants`
  String get participants {
    return Intl.message(
      'Participants',
      name: 'participants',
      desc: '',
      args: [],
    );
  }

  /// `Host`
  String get host {
    return Intl.message(
      'Host',
      name: 'host',
      desc: '',
      args: [],
    );
  }

  /// `To-do list`
  String get toDo {
    return Intl.message(
      'To-do list',
      name: 'toDo',
      desc: '',
      args: [],
    );
  }

  /// `Select executor`
  String get selectExecutor {
    return Intl.message(
      'Select executor',
      name: 'selectExecutor',
      desc: '',
      args: [],
    );
  }

  /// `Leave`
  String get leave {
    return Intl.message(
      'Leave',
      name: 'leave',
      desc: '',
      args: [],
    );
  }

  /// `Evection`
  String get evection {
    return Intl.message(
      'Evection',
      name: 'evection',
      desc: '',
      args: [],
    );
  }

  /// `Universal`
  String get universal {
    return Intl.message(
      'Universal',
      name: 'universal',
      desc: '',
      args: [],
    );
  }

  /// `Reimbursement`
  String get reimbursement {
    return Intl.message(
      'Reimbursement',
      name: 'reimbursement',
      desc: '',
      args: [],
    );
  }

  /// `Leave application submitted by {name}`
  String leaveTitle(Object name) {
    return Intl.message(
      'Leave application submitted by $name',
      name: 'leaveTitle',
      desc: '',
      args: [name],
    );
  }

  /// `General approval submitted by {name}`
  String universalTitle(Object name) {
    return Intl.message(
      'General approval submitted by $name',
      name: 'universalTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Reimbursement application submitted by {name}`
  String reimbursementTitle(Object name) {
    return Intl.message(
      'Reimbursement application submitted by $name',
      name: 'reimbursementTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Edit employee profile`
  String get editMemberInfo {
    return Intl.message(
      'Edit employee profile',
      name: 'editMemberInfo',
      desc: '',
      args: [],
    );
  }

  /// `Reimbursement application`
  String get reimbursementApplication {
    return Intl.message(
      'Reimbursement application',
      name: 'reimbursementApplication',
      desc: '',
      args: [],
    );
  }

  /// `Leave a message`
  String get leaveAMessage {
    return Intl.message(
      'Leave a message',
      name: 'leaveAMessage',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a message`
  String get pEnterMessage {
    return Intl.message(
      'Please enter a message',
      name: 'pEnterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a detailed description of the cost`
  String get pEnterMoneyDetail {
    return Intl.message(
      'Please enter a detailed description of the cost',
      name: 'pEnterMoneyDetail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the reimbursement category`
  String get pEnterReimbursementType {
    return Intl.message(
      'Please enter the reimbursement category',
      name: 'pEnterReimbursementType',
      desc: '',
      args: [],
    );
  }

  /// `(E.g. activity funding)`
  String get egAcFunding {
    return Intl.message(
      '(E.g. activity funding)',
      name: 'egAcFunding',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the amount`
  String get pEnterMoney {
    return Intl.message(
      'Please enter the amount',
      name: 'pEnterMoney',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the correct amount`
  String get pEnterRightMoney {
    return Intl.message(
      'Please enter the correct amount',
      name: 'pEnterRightMoney',
      desc: '',
      args: [],
    );
  }

  /// `Please enter application content`
  String get pApplicationContent {
    return Intl.message(
      'Please enter application content',
      name: 'pApplicationContent',
      desc: '',
      args: [],
    );
  }

  /// `Please enter approval details`
  String get pApplyDetail {
    return Intl.message(
      'Please enter approval details',
      name: 'pApplyDetail',
      desc: '',
      args: [],
    );
  }

  /// `OA approval`
  String get oaApproval {
    return Intl.message(
      'OA approval',
      name: 'oaApproval',
      desc: '',
      args: [],
    );
  }

  /// `hour`
  String get hour {
    return Intl.message(
      'hour',
      name: 'hour',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get day {
    return Intl.message(
      'day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `Leave application`
  String get leaveApplication {
    return Intl.message(
      'Leave application',
      name: 'leaveApplication',
      desc: '',
      args: [],
    );
  }

  /// `Reason for leave`
  String get reasonForLeave {
    return Intl.message(
      'Reason for leave',
      name: 'reasonForLeave',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the reason for the leave`
  String get pEnterreasonForLeave {
    return Intl.message(
      'Please enter the reason for the leave',
      name: 'pEnterreasonForLeave',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the duration`
  String get pEnterDuration {
    return Intl.message(
      'Please enter the duration',
      name: 'pEnterDuration',
      desc: '',
      args: [],
    );
  }

  /// `duration({duration})`
  String duration(Object duration) {
    return Intl.message(
      'duration($duration)',
      name: 'duration',
      desc: '',
      args: [duration],
    );
  }

  /// `Title`
  String get announcementTitle {
    return Intl.message(
      'Title',
      name: 'announcementTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the announcement title`
  String get pEnterAnnouncementTitle {
    return Intl.message(
      'Please enter the announcement title',
      name: 'pEnterAnnouncementTitle',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message(
      'Author',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the author (optional)`
  String get pEnterAuthor {
    return Intl.message(
      'Please enter the author (optional)',
      name: 'pEnterAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Announcement content`
  String get announcementContent {
    return Intl.message(
      'Announcement content',
      name: 'announcementContent',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the announcement content`
  String get pEnterAnnouceContent {
    return Intl.message(
      'Please enter the announcement content',
      name: 'pEnterAnnouceContent',
      desc: '',
      args: [],
    );
  }

  /// `Notify staff`
  String get notifyStaff {
    return Intl.message(
      'Notify staff',
      name: 'notifyStaff',
      desc: '',
      args: [],
    );
  }

  /// `Notify friends`
  String get notifyFriends {
    return Intl.message(
      'Notify friends',
      name: 'notifyFriends',
      desc: '',
      args: [],
    );
  }

  /// `Announcement details`
  String get announcementDetails {
    return Intl.message(
      'Announcement details',
      name: 'announcementDetails',
      desc: '',
      args: [],
    );
  }

  /// `{num} people have read, `
  String haveReadNum(Object num) {
    return Intl.message(
      '$num people have read, ',
      name: 'haveReadNum',
      desc: '',
      args: [num],
    );
  }

  /// `unread`
  String get unread {
    return Intl.message(
      'unread',
      name: 'unread',
      desc: '',
      args: [],
    );
  }

  /// `{num} people `
  String howManyPeople(Object num) {
    return Intl.message(
      '$num people ',
      name: 'howManyPeople',
      desc: '',
      args: [num],
    );
  }

  /// `Announcement`
  String get announcement {
    return Intl.message(
      'Announcement',
      name: 'announcement',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get weekly {
    return Intl.message(
      'Weekly',
      name: 'weekly',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `Monthly report`
  String get monthlyReport {
    return Intl.message(
      'Monthly report',
      name: 'monthlyReport',
      desc: '',
      args: [],
    );
  }

  /// `Send to group chat`
  String get sendToGroupChat {
    return Intl.message(
      'Send to group chat',
      name: 'sendToGroupChat',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the work to be coordinated`
  String get pEnterCoordinated {
    return Intl.message(
      'Please enter the work to be coordinated',
      name: 'pEnterCoordinated',
      desc: '',
      args: [],
    );
  }

  /// `Need to coordinate work`
  String get coordinate {
    return Intl.message(
      'Need to coordinate work',
      name: 'coordinate',
      desc: '',
      args: [],
    );
  }

  /// `Please enter unfinished work`
  String get pEnterUnfinished {
    return Intl.message(
      'Please enter unfinished work',
      name: 'pEnterUnfinished',
      desc: '',
      args: [],
    );
  }

  /// `Unfinished work`
  String get unfinishedWork {
    return Intl.message(
      'Unfinished work',
      name: 'unfinishedWork',
      desc: '',
      args: [],
    );
  }

  /// `Please enter completed work`
  String get pEnterCompletedWork {
    return Intl.message(
      'Please enter completed work',
      name: 'pEnterCompletedWork',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the meeting subject`
  String get pEnterMeetingTitle {
    return Intl.message(
      'Please enter the meeting subject',
      name: 'pEnterMeetingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the meeting description`
  String get pEnterMeetingContent {
    return Intl.message(
      'Please enter the meeting description',
      name: 'pEnterMeetingContent',
      desc: '',
      args: [],
    );
  }

  /// `Work done`
  String get workDone {
    return Intl.message(
      'Work done',
      name: 'workDone',
      desc: '',
      args: [],
    );
  }

  /// `Updating files`
  String get updatingFiles {
    return Intl.message(
      'Updating files',
      name: 'updatingFiles',
      desc: '',
      args: [],
    );
  }

  /// `Upload picture`
  String get uploadPicture {
    return Intl.message(
      'Upload picture',
      name: 'uploadPicture',
      desc: '',
      args: [],
    );
  }

  /// `To be consulted`
  String get toBeConsulted {
    return Intl.message(
      'To be consulted',
      name: 'toBeConsulted',
      desc: '',
      args: [],
    );
  }

  /// `Reviewed`
  String get reviewed {
    return Intl.message(
      'Reviewed',
      name: 'reviewed',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `Comment`
  String get comment {
    return Intl.message(
      'Comment',
      name: 'comment',
      desc: '',
      args: [],
    );
  }

  /// `Comment Failed`
  String get replyFail {
    return Intl.message(
      'Comment Failed',
      name: 'replyFail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your comment`
  String get entReply {
    return Intl.message(
      'Please enter your comment',
      name: 'entReply',
      desc: '',
      args: [],
    );
  }

  /// `Team information`
  String get teamInfo {
    return Intl.message(
      'Team information',
      name: 'teamInfo',
      desc: '',
      args: [],
    );
  }

  /// `Team invitation code`
  String get teamInviteQrCode {
    return Intl.message(
      'Team invitation code',
      name: 'teamInviteQrCode',
      desc: '',
      args: [],
    );
  }

  /// `View invoice`
  String get viewInvoice {
    return Intl.message(
      'View invoice',
      name: 'viewInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Exit the team`
  String get leaveTeam {
    return Intl.message(
      'Exit the team',
      name: 'leaveTeam',
      desc: '',
      args: [],
    );
  }

  /// `Personal Leave`
  String get personalLeave {
    return Intl.message(
      'Personal Leave',
      name: 'personalLeave',
      desc: '',
      args: [],
    );
  }

  /// `Exchanging Holiday`
  String get exchangingHoliday {
    return Intl.message(
      'Exchanging Holiday',
      name: 'exchangingHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Sick Leave`
  String get sickLeave {
    return Intl.message(
      'Sick Leave',
      name: 'sickLeave',
      desc: '',
      args: [],
    );
  }

  /// `Annual Leave`
  String get annualLeave {
    return Intl.message(
      'Annual Leave',
      name: 'annualLeave',
      desc: '',
      args: [],
    );
  }

  /// `Maternity Leave`
  String get maternityLeave {
    return Intl.message(
      'Maternity Leave',
      name: 'maternityLeave',
      desc: '',
      args: [],
    );
  }

  /// `Paternity Leave`
  String get paternityLeave {
    return Intl.message(
      'Paternity Leave',
      name: 'paternityLeave',
      desc: '',
      args: [],
    );
  }

  /// `Marriage Holiday`
  String get marriageHoliday {
    return Intl.message(
      'Marriage Holiday',
      name: 'marriageHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Period Holiday`
  String get periodHoliday {
    return Intl.message(
      'Period Holiday',
      name: 'periodHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Bereavement Leave`
  String get bereavementLeave {
    return Intl.message(
      'Bereavement Leave',
      name: 'bereavementLeave',
      desc: '',
      args: [],
    );
  }

  /// `Lactation Leave`
  String get lactationLeave {
    return Intl.message(
      'Lactation Leave',
      name: 'lactationLeave',
      desc: '',
      args: [],
    );
  }

  /// `Leave by hour`
  String get leaveByHour {
    return Intl.message(
      'Leave by hour',
      name: 'leaveByHour',
      desc: '',
      args: [],
    );
  }

  /// `Request a leave by half day`
  String get requestALeaveByHalfDay {
    return Intl.message(
      'Request a leave by half day',
      name: 'requestALeaveByHalfDay',
      desc: '',
      args: [],
    );
  }

  /// `Leave by whole day`
  String get leaveByWholeDay {
    return Intl.message(
      'Leave by whole day',
      name: 'leaveByWholeDay',
      desc: '',
      args: [],
    );
  }

  /// `No Notice`
  String get noNotice {
    return Intl.message(
      'No Notice',
      name: 'noNotice',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to delete this notice?`
  String get sureDeleteTheNotice {
    return Intl.message(
      'Are you sure to delete this notice?',
      name: 'sureDeleteTheNotice',
      desc: '',
      args: [],
    );
  }

  /// `Enter Notice title`
  String get noticeTitleHint {
    return Intl.message(
      'Enter Notice title',
      name: 'noticeTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter Notice content`
  String get noticeContentHint {
    return Intl.message(
      'Enter Notice content',
      name: 'noticeContentHint',
      desc: '',
      args: [],
    );
  }

  /// `Choose a host`
  String get setHost {
    return Intl.message(
      'Choose a host',
      name: 'setHost',
      desc: '',
      args: [],
    );
  }

  /// `Publishing failed`
  String get publishingFailed {
    return Intl.message(
      'Publishing failed',
      name: 'publishingFailed',
      desc: '',
      args: [],
    );
  }

  /// `About us`
  String get aboutUs {
    return Intl.message(
      'About us',
      name: 'aboutUs',
      desc: '',
      args: [],
    );
  }

  /// `Current version {version} v`
  String currentVersion(Object version) {
    return Intl.message(
      'Current version $version v',
      name: 'currentVersion',
      desc: '',
      args: [version],
    );
  }

  /// `Is the version up to date`
  String get isTheLatestVersion {
    return Intl.message(
      'Is the version up to date',
      name: 'isTheLatestVersion',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get cheackUpdate {
    return Intl.message(
      'Check for updates',
      name: 'cheackUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Checking The Version`
  String get checkingTheVersion {
    return Intl.message(
      'Checking The Version',
      name: 'checkingTheVersion',
      desc: '',
      args: [],
    );
  }

  /// `Currently The Latest Version`
  String get currentlyTheLatestVersion {
    return Intl.message(
      'Currently The Latest Version',
      name: 'currentlyTheLatestVersion',
      desc: '',
      args: [],
    );
  }

  /// `Publishing Success`
  String get publishingSuccess {
    return Intl.message(
      'Publishing Success',
      name: 'publishingSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Enter Feedback`
  String get pleaseInputFeedback {
    return Intl.message(
      'Enter Feedback',
      name: 'pleaseInputFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your support. Please describe your feedback...`
  String get opinionHintext {
    return Intl.message(
      'Thank you for your support. Please describe your feedback...',
      name: 'opinionHintext',
      desc: '',
      args: [],
    );
  }

  /// `Confirm add`
  String get sureAdd {
    return Intl.message(
      'Confirm add',
      name: 'sureAdd',
      desc: '',
      args: [],
    );
  }

  /// `You are already a member of the team`
  String get uAreTeamMember {
    return Intl.message(
      'You are already a member of the team',
      name: 'uAreTeamMember',
      desc: '',
      args: [],
    );
  }

  /// `Added successfully`
  String get addOk {
    return Intl.message(
      'Added successfully',
      name: 'addOk',
      desc: '',
      args: [],
    );
  }

  /// `The number of members exceeds the limit`
  String get memberIsMax {
    return Intl.message(
      'The number of members exceeds the limit',
      name: 'memberIsMax',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied`
  String get noPermisson {
    return Intl.message(
      'Permission denied',
      name: 'noPermisson',
      desc: '',
      args: [],
    );
  }

  /// `Set successfully`
  String get settingOk {
    return Intl.message(
      'Set successfully',
      name: 'settingOk',
      desc: '',
      args: [],
    );
  }

  /// `Edit successfully`
  String get editOk {
    return Intl.message(
      'Edit successfully',
      name: 'editOk',
      desc: '',
      args: [],
    );
  }

  /// `Team/Dept/Group not exist`
  String get currentNoExistent {
    return Intl.message(
      'Team/Dept/Group not exist',
      name: 'currentNoExistent',
      desc: '',
      args: [],
    );
  }

  /// `Not a group member/group chat does not exist`
  String get noGroupMembers {
    return Intl.message(
      'Not a group member/group chat does not exist',
      name: 'noGroupMembers',
      desc: '',
      args: [],
    );
  }

  /// `Disband the team`
  String get disbandTheTeam {
    return Intl.message(
      'Disband the team',
      name: 'disbandTheTeam',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disband the group?`
  String get disbandTheGroup {
    return Intl.message(
      'Are you sure you want to disband the group?',
      name: 'disbandTheGroup',
      desc: '',
      args: [],
    );
  }

  /// `After disbanding the group, the group will be deleted and the chat history will be cleared`
  String get disbandTheGroupTip {
    return Intl.message(
      'After disbanding the group, the group will be deleted and the chat history will be cleared',
      name: 'disbandTheGroupTip',
      desc: '',
      args: [],
    );
  }

  /// `Please select start time`
  String get selectStartTime {
    return Intl.message(
      'Please select start time',
      name: 'selectStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Please select the end time`
  String get selectEndTime {
    return Intl.message(
      'Please select the end time',
      name: 'selectEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Please select the completion time`
  String get selectCompletionTime {
    return Intl.message(
      'Please select the completion time',
      name: 'selectCompletionTime',
      desc: '',
      args: [],
    );
  }

  /// `Please select an approver`
  String get selectApprover {
    return Intl.message(
      'Please select an approver',
      name: 'selectApprover',
      desc: '',
      args: [],
    );
  }

  /// `After leaving the team, the server no longer retains any team data, including but not limited to team members, data generated by team applications, team group messages, etc.`
  String get leaveTeamHint {
    return Intl.message(
      'After leaving the team, the server no longer retains any team data, including but not limited to team members, data generated by team applications, team group messages, etc.',
      name: 'leaveTeamHint',
      desc: '',
      args: [],
    );
  }

  /// `Did not scan anything`
  String get nothingToScan {
    return Intl.message(
      'Did not scan anything',
      name: 'nothingToScan',
      desc: '',
      args: [],
    );
  }

  /// `Sponsor`
  String get sponsor {
    return Intl.message(
      'Sponsor',
      name: 'sponsor',
      desc: '',
      args: [],
    );
  }

  /// `go Chat`
  String get goToChat {
    return Intl.message(
      'go Chat',
      name: 'goToChat',
      desc: '',
      args: [],
    );
  }

  /// `Please choose notifiers`
  String get seletctCopyTo {
    return Intl.message(
      'Please choose notifiers',
      name: 'seletctCopyTo',
      desc: '',
      args: [],
    );
  }

  /// `Please select participants`
  String get seletctParticipants {
    return Intl.message(
      'Please select participants',
      name: 'seletctParticipants',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in the work report`
  String get fillWorkReport {
    return Intl.message(
      'Please fill in the work report',
      name: 'fillWorkReport',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get processing {
    return Intl.message(
      'Processing',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Revoked`
  String get revoked {
    return Intl.message(
      'Revoked',
      name: 'revoked',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the reason`
  String get enterReason {
    return Intl.message(
      'Please enter the reason',
      name: 'enterReason',
      desc: '',
      args: [],
    );
  }

  /// `Confirm cancellation`
  String get confirmCancellation {
    return Intl.message(
      'Confirm cancellation',
      name: 'confirmCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Image upload failed`
  String get imageUploadFailed {
    return Intl.message(
      'Image upload failed',
      name: 'imageUploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to revoke the record, the data cannot be restored after revoking`
  String get revokeHint {
    return Intl.message(
      'Are you sure to revoke the record, the data cannot be restored after revoking',
      name: 'revokeHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm message`
  String get approveMessage {
    return Intl.message(
      'Confirm message',
      name: 'approveMessage',
      desc: '',
      args: [],
    );
  }

  /// `Initiator`
  String get initiateApplication {
    return Intl.message(
      'Initiator',
      name: 'initiateApplication',
      desc: '',
      args: [],
    );
  }

  /// `Leave details`
  String get leaveDetail {
    return Intl.message(
      'Leave details',
      name: 'leaveDetail',
      desc: '',
      args: [],
    );
  }

  /// `Reimbursement details`
  String get reimbursementDetails {
    return Intl.message(
      'Reimbursement details',
      name: 'reimbursementDetails',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get detail {
    return Intl.message(
      'Details',
      name: 'detail',
      desc: '',
      args: [],
    );
  }

  /// `General details`
  String get generalDetails {
    return Intl.message(
      'General details',
      name: 'generalDetails',
      desc: '',
      args: [],
    );
  }

  /// `Card`
  String get contactCard {
    return Intl.message(
      'Card',
      name: 'contactCard',
      desc: '',
      args: [],
    );
  }

  /// `Send to:`
  String get sendTo {
    return Intl.message(
      'Send to:',
      name: 'sendTo',
      desc: '',
      args: [],
    );
  }

  /// `Personal Card`
  String get personalCard {
    return Intl.message(
      'Personal Card',
      name: 'personalCard',
      desc: '',
      args: [],
    );
  }

  /// `My Alias`
  String get myGroupNickname {
    return Intl.message(
      'My Alias',
      name: 'myGroupNickname',
      desc: '',
      args: [],
    );
  }

  /// `No team`
  String get noTeam {
    return Intl.message(
      'No team',
      name: 'noTeam',
      desc: '',
      args: [],
    );
  }

  /// `The information sent in this conversation has been end-to-end encrypted`
  String get endToEndEncryption {
    return Intl.message(
      'The information sent in this conversation has been end-to-end encrypted',
      name: 'endToEndEncryption',
      desc: '',
      args: [],
    );
  }

  /// `Work Notice`
  String get workNotice {
    return Intl.message(
      'Work Notice',
      name: 'workNotice',
      desc: '',
      args: [],
    );
  }

  /// `{name} sent an approval`
  String needU(Object name) {
    return Intl.message(
      '$name sent an approval',
      name: 'needU',
      desc: '',
      args: [name],
    );
  }

  /// `{name} submitted the log`
  String upLog(Object name) {
    return Intl.message(
      '$name submitted the log',
      name: 'upLog',
      desc: '',
      args: [name],
    );
  }

  /// `You have a new message`
  String get newMsg {
    return Intl.message(
      'You have a new message',
      name: 'newMsg',
      desc: '',
      args: [],
    );
  }

  /// `{who} commented on {name}'s work log`
  String someRev(Object who, Object name) {
    return Intl.message(
      '$who commented on $name\'s work log',
      name: 'someRev',
      desc: '',
      args: [who, name],
    );
  }

  /// `{who} commented on tasks initiated by {name}`
  String someRevTask(Object who, Object name) {
    return Intl.message(
      '$who commented on tasks initiated by $name',
      name: 'someRevTask',
      desc: '',
      args: [who, name],
    );
  }

  /// `{who} commented on the approval initiated by {name}`
  String someRevAppr(Object who, Object name) {
    return Intl.message(
      '$who commented on the approval initiated by $name',
      name: 'someRevAppr',
      desc: '',
      args: [who, name],
    );
  }

  /// `{who} commented on meeting minutes posted by {name}`
  String someRevMeeting(Object who, Object name) {
    return Intl.message(
      '$who commented on meeting minutes posted by $name',
      name: 'someRevMeeting',
      desc: '',
      args: [who, name],
    );
  }

  /// `Please enter password`
  String get plzEnterPwd {
    return Intl.message(
      'Please enter password',
      name: 'plzEnterPwd',
      desc: '',
      args: [],
    );
  }

  /// `Retrieve Password`
  String get findPwd {
    return Intl.message(
      'Retrieve Password',
      name: 'findPwd',
      desc: '',
      args: [],
    );
  }

  /// `Forget Password?`
  String get forgotPwd {
    return Intl.message(
      'Forget Password?',
      name: 'forgotPwd',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get rigister {
    return Intl.message(
      'Register',
      name: 'rigister',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password (6-20)`
  String get checkPwd {
    return Intl.message(
      'Confirm password (6-20)',
      name: 'checkPwd',
      desc: '',
      args: [],
    );
  }

  /// `Confirm new password (6-20)`
  String get checkNewPwd {
    return Intl.message(
      'Confirm new password (6-20)',
      name: 'checkNewPwd',
      desc: '',
      args: [],
    );
  }

  /// `Set password (6-20)`
  String get setPwd {
    return Intl.message(
      'Set password (6-20)',
      name: 'setPwd',
      desc: '',
      args: [],
    );
  }

  /// `Set a new password (6-20)`
  String get setNewPwd {
    return Intl.message(
      'Set a new password (6-20)',
      name: 'setNewPwd',
      desc: '',
      args: [],
    );
  }

  /// `registration success`
  String get regOk {
    return Intl.message(
      'registration success',
      name: 'regOk',
      desc: '',
      args: [],
    );
  }

  /// `Successfully retrieved`
  String get findOk {
    return Intl.message(
      'Successfully retrieved',
      name: 'findOk',
      desc: '',
      args: [],
    );
  }

  /// `Please enter more than 6 digits password`
  String get sixPwd {
    return Intl.message(
      'Please enter more than 6 digits password',
      name: 'sixPwd',
      desc: '',
      args: [],
    );
  }

  /// `Password input is inconsistent`
  String get pwdDiff {
    return Intl.message(
      'Password input is inconsistent',
      name: 'pwdDiff',
      desc: '',
      args: [],
    );
  }

  /// `Please check whether the relevant parameters are correct or try again later`
  String get checkData {
    return Intl.message(
      'Please check whether the relevant parameters are correct or try again later',
      name: 'checkData',
      desc: '',
      args: [],
    );
  }

  /// `Click again to exit Cobiz`
  String get leaveApp {
    return Intl.message(
      'Click again to exit Cobiz',
      name: 'leaveApp',
      desc: '',
      args: [],
    );
  }

  /// `Show all members`
  String get lookAllgGroupPeople {
    return Intl.message(
      'Show all members',
      name: 'lookAllgGroupPeople',
      desc: '',
      args: [],
    );
  }

  /// `↑ {unreadNumber} msgs`
  String unreadMsg(Object unreadNumber) {
    return Intl.message(
      '↑ $unreadNumber msgs',
      name: 'unreadMsg',
      desc: '',
      args: [unreadNumber],
    );
  }

  /// `You have a group message`
  String get groupMsg {
    return Intl.message(
      'You have a group message',
      name: 'groupMsg',
      desc: '',
      args: [],
    );
  }

  /// `You have a group announcement`
  String get groupNoticeMsg {
    return Intl.message(
      'You have a group announcement',
      name: 'groupNoticeMsg',
      desc: '',
      args: [],
    );
  }

  /// `You have a team announcement`
  String get teamNoticeMsg {
    return Intl.message(
      'You have a team announcement',
      name: 'teamNoticeMsg',
      desc: '',
      args: [],
    );
  }

  /// `Remove from ({dept}) department`
  String deleteFromDept(Object dept) {
    return Intl.message(
      'Remove from ($dept) department',
      name: 'deleteFromDept',
      desc: '',
      args: [dept],
    );
  }

  /// `The primary administrator or administrator cannot be deleted`
  String get deleteManage {
    return Intl.message(
      'The primary administrator or administrator cannot be deleted',
      name: 'deleteManage',
      desc: '',
      args: [],
    );
  }

  /// `Customer Service`
  String get kf {
    return Intl.message(
      'Customer Service',
      name: 'kf',
      desc: '',
      args: [],
    );
  }

  /// `Quote`
  String get quote {
    return Intl.message(
      'Quote',
      name: 'quote',
      desc: '',
      args: [],
    );
  }

  /// `Browser opens`
  String get openbyBr {
    return Intl.message(
      'Browser opens',
      name: 'openbyBr',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyUrl {
    return Intl.message(
      'Copy link',
      name: 'copyUrl',
      desc: '',
      args: [],
    );
  }

  /// `Send to friends`
  String get sendToF {
    return Intl.message(
      'Send to friends',
      name: 'sendToF',
      desc: '',
      args: [],
    );
  }

  /// `Open in Safari`
  String get openBySafari {
    return Intl.message(
      'Open in Safari',
      name: 'openBySafari',
      desc: '',
      args: [],
    );
  }

  /// `Open in browser`
  String get openByBrower {
    return Intl.message(
      'Open in browser',
      name: 'openByBrower',
      desc: '',
      args: [],
    );
  }

  /// `This page is provided by {url}`
  String whoProvideUrl(Object url) {
    return Intl.message(
      'This page is provided by $url',
      name: 'whoProvideUrl',
      desc: '',
      args: [url],
    );
  }

  /// `Team invitation`
  String get teamInvite {
    return Intl.message(
      'Team invitation',
      name: 'teamInvite',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Team Invitation`
  String get teamInvitation {
    return Intl.message(
      'Team Invitation',
      name: 'teamInvitation',
      desc: '',
      args: [],
    );
  }

  /// `draft`
  String get draft {
    return Intl.message(
      'draft',
      name: 'draft',
      desc: '',
      args: [],
    );
  }

  /// `The team does not exist`
  String get teamNotExist {
    return Intl.message(
      'The team does not exist',
      name: 'teamNotExist',
      desc: '',
      args: [],
    );
  }

  /// `applies to join`
  String get applyJoin {
    return Intl.message(
      'applies to join',
      name: 'applyJoin',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch {url}`
  String cantLanuh(Object url) {
    return Intl.message(
      'Could not launch $url',
      name: 'cantLanuh',
      desc: '',
      args: [url],
    );
  }

  /// `The current network is unavailable, please check your network settings`
  String get checkInternet {
    return Intl.message(
      'The current network is unavailable, please check your network settings',
      name: 'checkInternet',
      desc: '',
      args: [],
    );
  }

  /// `Failed to connect to the Internet`
  String get noInternet {
    return Intl.message(
      'Failed to connect to the Internet',
      name: 'noInternet',
      desc: '',
      args: [],
    );
  }

  /// `Your device is not enabled for mobile network or Wi-Fi network`
  String get noInternet1 {
    return Intl.message(
      'Your device is not enabled for mobile network or Wi-Fi network',
      name: 'noInternet1',
      desc: '',
      args: [],
    );
  }

  /// `If you need to connect to the Internet, you can refer to the following method:`
  String get noInternet2 {
    return Intl.message(
      'If you need to connect to the Internet, you can refer to the following method:',
      name: 'noInternet2',
      desc: '',
      args: [],
    );
  }

  /// `On the device `
  String get noInternet3 {
    return Intl.message(
      'On the device ',
      name: 'noInternet3',
      desc: '',
      args: [],
    );
  }

  /// `"Settings"-"Wi-Fi Network" `
  String get noInternet4 {
    return Intl.message(
      '"Settings"-"Wi-Fi Network" ',
      name: 'noInternet4',
      desc: '',
      args: [],
    );
  }

  /// `Select an available Wi-Fi hotspot access in the settings panel.`
  String get noInternet5 {
    return Intl.message(
      'Select an available Wi-Fi hotspot access in the settings panel.',
      name: 'noInternet5',
      desc: '',
      args: [],
    );
  }

  /// `"Settings"-"Network" `
  String get noInternet6 {
    return Intl.message(
      '"Settings"-"Network" ',
      name: 'noInternet6',
      desc: '',
      args: [],
    );
  }

  /// `Enable network data in the settings panel (the operator may charge data communication fees after enabling).`
  String get noInternet7 {
    return Intl.message(
      'Enable network data in the settings panel (the operator may charge data communication fees after enabling).',
      name: 'noInternet7',
      desc: '',
      args: [],
    );
  }

  /// `If you are connected to a Wi-Fi network:`
  String get noInternet8 {
    return Intl.message(
      'If you are connected to a Wi-Fi network:',
      name: 'noInternet8',
      desc: '',
      args: [],
    );
  }

  /// `Please check whether the Wi-Fi hotspot you are connected to is connected to the Internet, or whether the hotspot allows your device to access the Internet.`
  String get noInternet9 {
    return Intl.message(
      'Please check whether the Wi-Fi hotspot you are connected to is connected to the Internet, or whether the hotspot allows your device to access the Internet.',
      name: 'noInternet9',
      desc: '',
      args: [],
    );
  }

  /// `If you are still unable to connect, please make sure the network connection is normal and restart the Cobiz client`
  String get noInternet10 {
    return Intl.message(
      'If you are still unable to connect, please make sure the network connection is normal and restart the Cobiz client',
      name: 'noInternet10',
      desc: '',
      args: [],
    );
  }

  /// `Cobiz does not have the permission to access the camera, do you want to open it?`
  String get cameraPermission {
    return Intl.message(
      'Cobiz does not have the permission to access the camera, do you want to open it?',
      name: 'cameraPermission',
      desc: '',
      args: [],
    );
  }

  /// `Cobiz does not have the permission to access the album/read and write storage. Do you want to open it?`
  String get photosPermission {
    return Intl.message(
      'Cobiz does not have the permission to access the album/read and write storage. Do you want to open it?',
      name: 'photosPermission',
      desc: '',
      args: [],
    );
  }

  /// `You have closed the notification of Cobiz in the system. If you need to open it, please find the application "Cobiz" in the "Settings"-"Notifications" function of iPhone, and turn on "Allow Notifications".`
  String get noNotificationHintIos {
    return Intl.message(
      'You have closed the notification of Cobiz in the system. If you need to open it, please find the application "Cobiz" in the "Settings"-"Notifications" function of iPhone, and turn on "Allow Notifications".',
      name: 'noNotificationHintIos',
      desc: '',
      args: [],
    );
  }

  /// `You have closed the notification of Cobiz in the system. To open it, please find the application "Cobiz" in the "Settings"-"Notifications" function of your phone, and turn on "Allow Notifications".`
  String get noNotificationHintAndroid {
    return Intl.message(
      'You have closed the notification of Cobiz in the system. To open it, please find the application "Cobiz" in the "Settings"-"Notifications" function of your phone, and turn on "Allow Notifications".',
      name: 'noNotificationHintAndroid',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get connecting {
    return Intl.message(
      'Connecting...',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `Text size`
  String get fontSize {
    return Intl.message(
      'Text size',
      name: 'fontSize',
      desc: '',
      args: [],
    );
  }

  /// `Drag the slider below, the font size will be previewed`
  String get fontSizeH1 {
    return Intl.message(
      'Drag the slider below, the font size will be previewed',
      name: 'fontSizeH1',
      desc: '',
      args: [],
    );
  }

  /// `After setting, it will change the font size of the text in chat, menu, etc. everywhere. If you have any questions or comments during the use process, you can send feedback to Cobiz.`
  String get fontSizeH2 {
    return Intl.message(
      'After setting, it will change the font size of the text in chat, menu, etc. everywhere. If you have any questions or comments during the use process, you can send feedback to Cobiz.',
      name: 'fontSizeH2',
      desc: '',
      args: [],
    );
  }

  /// `After setting, Cobiz will adjust the font size to your preferred font size for you`
  String get fontSizeH3 {
    return Intl.message(
      'After setting, Cobiz will adjust the font size to your preferred font size for you',
      name: 'fontSizeH3',
      desc: '',
      args: [],
    );
  }

  /// `Delete for me and {name}`
  String deleteOther(Object name) {
    return Intl.message(
      'Delete for me and $name',
      name: 'deleteOther',
      desc: '',
      args: [name],
    );
  }

  /// `identifying...`
  String get identifying {
    return Intl.message(
      'identifying...',
      name: 'identifying',
      desc: '',
      args: [],
    );
  }

  /// `No QR code found`
  String get noQr {
    return Intl.message(
      'No QR code found',
      name: 'noQr',
      desc: '',
      args: [],
    );
  }

  /// `Touch the screen to continue scanning`
  String get touchBack {
    return Intl.message(
      'Touch the screen to continue scanning',
      name: 'touchBack',
      desc: '',
      args: [],
    );
  }

  /// `Scan result`
  String get scanRes {
    return Intl.message(
      'Scan result',
      name: 'scanRes',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}