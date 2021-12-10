let importer_templates_js = [importer_js]


let importer_js = """
/*
  0 userid
  1 anonid
  2 first_name
  3 last_name
  4 email
  5 zip
  6 groupid
  7 groupname
  8 eventname
  9 signupdate
  10 isnew
  11 favorites
  12 source
  13 campaign
  14 ip
  
  var count = 20;
  for (var n = 0; n < count; n = n + 1) { print(n); }
*/

// ** Be sure to set your write key! **
let analytics = new Analytics("{{writeKey}}");

// ** Be sure to set the filename you want to import **
let csv = new CSV("{{csvFile}}");

let rowCount = csv.rowCount();

analytics.track("csvImportStart");

for (var row = 0; row < rowCount; row = row + 1) {
    var anonId = csv.rowValueForColumnName(row, "anonid");
    print("Processing: " + anonId);
    
    var userId = csv.rowValueForColumnName(row, "userid");
    var nameFirst = csv.rowValueForColumnName(row, "first_name");
    var nameLast = csv.rowValueForColumnName(row, "last_name");
    var email = csv.rowValueForColumnName(row, "email");
    var zip = csv.rowValueForColumnName(row, "zip");
    
    var groupId = csv.rowValueForColumnName(row, "groupid");
    var groupName = csv.rowValueForColumnName(row, "groupname");
    
    var eventName = csv.rowValueForColumnName(row, "eventname");
    var signupDate = csv.rowValueForColumnName(row, "signupdate");
    var isNew = csv.rowValueForColumnName(row, "isnew");
    var favorites = csv.rowValueForColumnName(row, "favorites");
    
    analytics.identify(userId, {
        "nameFirst": nameFirst,
        "nameLast": nameLast,
        "email": email,
        "zip": zip
    });
    
    analytics.track(eventName, {
        "nameFirst": nameFirst,
        "nameLast": nameLast,
        "email": email,
        "isNew": isNew,
        "favorites": favorites,
        "signupDate": signupDate
    });
}

analytics.flush();
"""
