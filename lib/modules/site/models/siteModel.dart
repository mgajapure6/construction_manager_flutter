class SiteModel {
  String siteType;
  String siteName;
  String siteStartDate;
  String siteEndDate;
  String siteOwnerName;
  String siteBudget;
  String sitePhoto;
  String siteCreateDate;
  String siteUpdateDate;
  String siteCreatedBy;

  SiteModel(this.siteType, this.siteName, this.siteStartDate, this.siteEndDate,
      this.siteOwnerName, this.sitePhoto);

  toJson() {
    return {
      "siteType": siteType,
      "siteName": siteName,
      "siteStartDate": siteStartDate,
      "siteEndDate": siteEndDate,
      "siteOwnerName": siteOwnerName,
      "siteBudget": siteBudget,
      "sitePhoto": sitePhoto,
      "siteCreateDate": siteCreateDate,
      "siteUpdateDate": siteUpdateDate,
      "siteCreatedBy": siteCreatedBy,
    };
  }
}
