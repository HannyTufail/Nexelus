

#define CLIENT_FIELD_CHARACTERS_LIMIT 40
#define JOB_FIELD_CHARACTERS_LIMIT 40
#define AUTHENTICATION_KEY_CHARACTERS_LIMIT 40
#define USER_ID_CHARACTERS_LIMIT 40
#define PASSWORD_CHARACTERS_LIMIT 40
#define COMMENTS_FIELD_LIMIT 2999
#define ADD_SCREEN_ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-/:;(,?!)'@&$~<|>{[#}]=*^%"
#define LOGIN_ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-"
#define PASSWORD_ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\\-/:;(&@[{#]}%^*+=\".,?!'_~`<|>)$£¥"

#define IPHONE_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define IPHONE_SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height


#define kSyncCompletionNotification     @"syncCompletionNotification"


#define kFVApplicationTitle             @"TimeLine"
#define kTL_HOST_URL                    @"https://services.nexelus.net/App/NexelusService.svc"
#define kTL_PING                        @"/ping"
#define kTL_LOGIN                       @"/Login"

#define kTL_LEVEL_2_GET                 @"/level2/get"
#define kTL_LEVEL_3_GET                 @"/level3/get"
#define kTL_LEVEL_2_CUSTOMER_GET        @"/Level2Customer/Get"
#define kTL_PERMANENT_LINE_GET          @"/PermanentLine/Get"
#define kTL_RES_USAGE_GET               @"/ResUsage/Get"
#define kTL_TASK_GET                    @"/Task/Get"
#define kTL_TRANSACTION_GET             @"/Transaction/Get"
#define kTL_SYS_NAMES_GET               @"/SysNames/Get"
#define kTL_USER_SETTINGS_GET           @"/UserSetting/Get"

#define kTL_TRANSACTION_SET             @"/Transaction/Set"
#define kTL_PERMANENT_LINE_SET          @"/PermanentLine/Set"
#define kTL_CHANGE_PASSWORD             @"/ChangePassword"


// AlertView Titles and Messages
#define ERROR_TITLE                             @"Error!"
#define CONFIRMATION_REQUIRED_TITLE             @"Confirmation Required!"

#define LOGIN                                   @"Login"
#define USER_ID_REQUIRED                        @"Please enter User ID"
#define PASSWORD_REQUIRED                       @"Please enter Password"
#define LOGIN_INVALID_PASSWORD                  @"Please enter valid Password"
#define SWITCH_USER                             @"You are trying to login with different user, all unsaved data will be lost"

#define LOG_OUT_TITLE                           @"User signed out"
#define LOG_OUT_MESSAGE                         @"Please note that you may have pending transaction(s) to synchronize, these transaction(s) will be synchorinzed with the server on next sign-in when you have internet connectivity."

#define DELETE                                  @"Deleting Transaction(s)"
#define SURE_TO_DELETE                          @"Are you sure you want to delete transaction(s)?"

#define AUTHENTICATION_KEY_TITLE                @"Authentication Key"
#define AUTHENTICATION_KEY_MESSAGE              @"Enter client ID"

#define BILLABLE_HOURS_CHECK_TITLE              @"No Billable Hours Found!"
#define BILLABLE_HOURS_CHECK_MESSAGE            @"There are no valid billable hours for chart"

#define SUBMIT_CHECK_TITLE                      @"Selected Transaction(s)"
#define SUBMIT_SUCCESSFULLY                     @"Submitted successfully"
#define SUBMIT_CHECK_MESSAGE                    @"Please select Transaction(s) first"
#define SUBMIT_MESSAGE                          @"Submitting, Please wait..."
#define SUBMIT_PINNED_CHECK_MESSAGE             @"Action cannot be performed on zero line(s)"

#define SUBMIT_ALL_NO_TRANSACTION               @"No transaction(s) found"
#define SUBMIT_ALREADY_SUBMITTED                @"Transaction(s) already submitted"


#define DELETE_CHECK_TITLE                      @"Selected Transaction(s)"
#define DELETE_CHECK_MESSAGE                    @"Please select transaction(s) first"
#define DELETE_SUCCESSFULLY                     @"Deleted successfully"
#define DELETE_MESSAGE                          @"Deleting, Please wait..."


#define COPY_CHECK_TITLE                        @"No Selected Transactions Found"
#define COPY_CHECK_MESSAGE                      @"Please select transaction(s) first"
#define COPIED_SUCCESSFULLY                     @"Copied successfully"

#define PASTE_CHECK_TITLE                       @"Selected Transaction(s)"
#define PASTE_CHECK_MESSAGE                     @"Please copy transaction(s) first"
#define PASTED_SUCCESSFULLY                     @"Pasted successfully"
#define PASTE_MESSAGE                           @"Pasting, Please wait..."


#define ADD_SCREEN_MISSING_FIELD_TITLE          @"Required Fields Missing"
#define ADD_SCREEN_MISSING_FIELD_MESSAGE        @"Please fill in the required fields"

#define ADD_SCREEN_WRONG_CLIENT_FIELD_MESSAGE   @"This client doesnot exist in the database"

#define EDIT_SCREEN_UNSAVED_CHANGES_TITLE       @"Unsaved Changes"
#define EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE     @"You have made some changes. Are you sure you want to discard?"

#define SETTINGS_OLD_PASSWORD_CHECK_MESSAGE           @"Please enter old password"
#define SETTINGS_NEW_PASSWORD_CHECK_MESSAGE           @"Please enter new password"
#define SETTINGS_CONFIRM_PASSWORD_CHECK_MESSAGE       @"Please enter confirm password"

#define  SETTINGS_OLD_INVALID_MESSAGE           @"Please enter valid old password"
#define  SETTINGS_NEW_INVALID_MESSAGE           @"New and confirm password doesnot match"
#define  SETTINGS_CONFIRM_INVALID_MESSAGE       @"New and confirm password doesnot match"

#define SETTING_UPDATING_PASSWORD               @"Updating, Please wait..."
#define SETTING_PASSWORD_UPDATED                @"Password updated successfully"

#define INTERNET_NOT_AVAILABLE                  @"Limited or no connectivity: Please check your internet connection and try later"
#define NO_SYNCING_MESSAGE                      @"Your application won't synchronize to server unless you sign in again."


// Service/DB Error Messages shown in AlertView
#define  ERROR_MESSAGE_TITLE                    @"ERROR"
#define  WEBSERVICE_CALL_STATUS                 @"Please wait..."
#define  WEBSERVICE_UPDATING_TRANSACTION_STATUS @"Updating transaction"
#define  TRANSACTION_NOT_SAVED_IN_DB            @"Could not save transaction(s) in database"
#define  TRANSACTION_NOT_UPDATED_IN_DB          @"Could not update transaction(s) in database"
#define  TRANSACTION_NOT_DELETED_IN_DB          @"Could not delete transaction(s) from database"
#define  PERMANENT_LINE_NOT_SAVED_IN_DB         @"Could not save permanent line(s) in database"
#define  PERMANENT_LINE_NOT_DELETED_IN_DB       @"Could not delete permanent line(s) from database"

// UDKey means UserDefaults Key
#define UDKEY_COMPANY_CODE                              @"CompanyCode"
#define UDKEY_AUTHENTICATION_KEY                        @"AuthenticationKey"
#define UDKEY_HAS_FETCHED_ENTIRE_DATA                   @"HasFetchEntireData"
#define UDKEY_HAS_PROVIDED_CLIENT_ID                    @"HasProvidedClientID"
#define UDKEY_CLIENT_USERNAME                           @"Username"
#define UDKEY_PASSWORD                                  @"Password"
#define UDKEY_CLIENT_NAME                               @"ClientName"
#define UDKEY_SETTINGS_CUSTOMER_OPTION                  @"SelectedOptionForCustomer"
#define UDKEY_SETTINGS_PROJECT_OPTION                   @"SelectedOptionForProject"
#define UDKEY_RESOURCE_ID                               @"ResourceID"
#define UDKEY_ORG_UNIT_CODE                             @"OrgUnitCode"
#define UDKEY_LOCATION_CODE                             @"LocationCode"
#define UDKEY_RES_USAGE_CODE                            @"ResUsageCode"
#define UDKEY_SHOW_TASKS                                @"ShowTasks"
#define UDKEY_SHOW_RES_USAGE                            @"ShowResUsage"
#define UDKEY_USER_HAS_LOGGED_IN                        @"UserHasLoggedIn"
#define UDKEY_REMEMBER_ME                               @"RememberMe"
#define UDKEY_MAX_HOURS_DAY                             @"MaxHrsDay"
#define UDKEY_MAX_HOURS_WEEK                            @"MaxHrsWeek"
#define UDKEY_SORT_BY                                   @"SortBy"
#define UDKEY_IS_USING_ACTIVE_DIRECTORY                 @"isUsingAD"
#define UDKEY_LAST_SYNC_DATE                            @"lastSyncDateForSync"


// filed Names for SysNames
#define FIELD_APP_NAME                                 @"app_name"
#define FIELD_CUSTOMER_DESCRIPTION                     @"cust_descr"
#define FIELD_EMPLOYEE_ID                              @"emp_id"
#define FIELD_LEVEL2_DESCRIPTION                       @"Level2_descr"
#define FIELD_LEVEL3_DESCRIPTION                       @"Level3_descr"
#define FIELD_LOCATION_DESCRIPTION                     @"location_descr"
#define FIELD_ORG_UNIT                                 @"org_unit"
#define FIELD_RESOURCE_ID                              @"Resource ID"
#define FIELD_RESOURCE_USAGE                           @"Resource_Usage"
#define TIME_BASED_LEVEL2_DESCRIPTION                  @"TIME_BASED_Level2_descr"
#define TIME_BASED_LEVEL3_DESCRIPTION                  @"TIME_BASED_Level3_descr"



