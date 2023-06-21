package oracle.adf.share.security.identitymanagement;

import java.io.Serializable;
import java.security.Principal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.logging.Level;
import oracle.adf.share.codesharing.audit.annotation.CodeSharingSafe;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.share.security.ADFSecurityRuntimeException;
import oracle.adf.share.security.ADFSecurityUtil;
import oracle.adf.share.security.AllowUntrustedScriptAccess;

@AllowUntrustedScriptAccess(allowConstructor=false, methodNames={"getBusinessCity", "getBusinessCountry", "getBusinessEmail", "getBusinessFax", "getBusinessMobile", "getBusinessPOBox", "getBusinessPager", "getBusinessPhone", "getBusinessPostalAddr", "getBusinessPostalCode", "getBusinessState", "getBusinessStreet", "getDateofBirth", "getDateofHire", "getDefaultGroup", "getDepartment", "getDepartmentNumber", "getDescription", "getDisplayName", "getEmployeeNumber", "getEmployeeType", "getFirstName", "getGUID", "getGivenName", "getHomeAddress", "getHomePhone", "getInitials", "getJpegPhoto", "getLastName", "getMaidenName", "getManager", "getMiddleName", "getName", "getNameSuffix", "getOrganization", "getOrganizationalUnit", "getPreferredLanguage", "getPrinciple", "getProperties", "getProperty", "getTimeZone", "getTitle", "getUIAccessMode", "getUniqueName", "getUserID", "getUserName", "getWirelessAccountNumber"})
public class UserProfile
  implements Serializable
{
  private static final String CLASS_NAME = UserProfile.class.getName();
  private static final long serialVersionUID = -8483385872960671970L;
  private String _userName = null;
  private HashMap _values = new HashMap();
  private HashMap _internalMap = new HashMap();
  private static final ADFLogger _adfSecLogger = ADFSecurityUtil.getADFLogger();
  @CodeSharingSafe("MutableStaticField")
  private static final UserManager _userMgr = new UserManager();
  private HashMap _modifiedProps = null;
  
  public UserProfile() {}
  
  public UserProfile(String userName)
  {
    String METHOD_NAME = "UserProfile Constructor";
    if (_adfSecLogger.isFinest()) {
      _adfSecLogger.log(Level.FINEST, CLASS_NAME + "." + "UserProfile Constructor" + " userName: " + userName);
    }
    if (userName == null) {
      throw new ADFSecurityRuntimeException(ADFSecurityUtil.getMessage("EXC_INVALID_USER"));
    }
    this._userName = userName;
    initialize();
  }
  
  private void initialize()
  {
    if (_userMgr != null)
    {
      AttributeFilter filter = new AttributeFilter();
      filter.setValue(this._userName);
      ArrayList list = null;
      list = _userMgr.getUserProfileList(-1, new AttributeFilter[] { filter });
      if ((list != null) && (list.size() > 0)) {
        internalSetProperties(((UserProfile)list.get(0)).getProperties());
      }
    }
  }
  
  public String getBusinessCity()
  {
    return (String)getProperty(UserProfileType.BUSINESS_CITY);
  }
  
  public String getBusinessCountry()
  {
    return (String)getProperty("BUSINESS_COUNTRY");
  }
  
  public String getBusinessEmail()
  {
    return (String)getProperty("BUSINESS_EMAIL");
  }
  
  public String getBusinessFax()
  {
    return (String)getProperty("BUSINESS_FAX");
  }
  
  public String getBusinessMobile()
  {
    return (String)getProperty("BUSINESS_MOBILE");
  }
  
  public String getBusinessPager()
  {
    return (String)getProperty("BUSINESS_PAGER");
  }
  
  public String getBusinessPhone()
  {
    return (String)getProperty("BUSINESS_PHONE");
  }
  
  public String getBusinessPOBox()
  {
    return (String)getProperty("BUSINESS_PO_BOX");
  }
  
  public String getBusinessPostalAddr()
  {
    return (String)getProperty("BUSINESS_POSTAL_ADDR");
  }
  
  public String getBusinessPostalCode()
  {
    return (String)getProperty("BUSINESS_POSTAL_CODE");
  }
  
  public String getBusinessState()
  {
    return (String)getProperty("BUSINESS_STATE");
  }
  
  public String getBusinessStreet()
  {
    return (String)getProperty("BUSINESS_STREET");
  }
  
  public String getDateofBirth()
  {
    return (String)getProperty("DATE_OF_BIRTH");
  }
  
  public String getDateofHire()
  {
    return (String)getProperty("DATE_OF_HIRE");
  }
  
  public String getDefaultGroup()
  {
    return (String)getProperty("DEFAULT_GROUP");
  }
  
  public String getDepartment()
  {
    return (String)getProperty("DEPARTMENT");
  }
  
  public String getDepartmentNumber()
  {
    return getDepartment();
  }
  
  public String getDescription()
  {
    return (String)getProperty("DESCRIPTION");
  }
  
  public String getEmployeeNumber()
  {
    return (String)getProperty("EMPLOYEE_NUMBER");
  }
  
  public String getEmployeeType()
  {
    return (String)getProperty("EMPLOYEE_TYPE");
  }
  
  public String getFirstName()
  {
    return (String)getProperty("FIRST_NAME");
  }
  
  public String getGivenName()
  {
    return (String)getProperty("GIVEN_NAME");
  }
  
  public String getHomeAddress()
  {
    return (String)getProperty("HOME_ADDRESS");
  }
  
  public String getHomePhone()
  {
    return (String)getProperty("HOME_PHONE");
  }
  
  public String getInitials()
  {
    return (String)getProperty("INITIALS");
  }
  
  public byte[] getJpegPhoto()
  {
    return (byte[])getProperty("JPEG_PHOTO");
  }
  
  public String getLastName()
  {
    return (String)getProperty("LAST_NAME");
  }
  
  public String getMaidenName()
  {
    return (String)getProperty("MAIDEN_NAME");
  }
  
  public String getManager()
  {
    return (String)getProperty("MANAGER");
  }
  
  public String getMiddleName()
  {
    return (String)getProperty("MIDDLE_NAME");
  }
  
  public String getNameSuffix()
  {
    return (String)getProperty("NAME_SUFFIX");
  }
  
  public String getOrganization()
  {
    return (String)getProperty("ORGANIZATION");
  }
  
  public String getOrganizationalUnit()
  {
    return (String)getProperty("ORGANIZATIONAL_UNIT");
  }
  
  public String getPreferredLanguage()
  {
    return (String)getProperty("PREFERRED_LANGUAGE");
  }
  
  public String getTimeZone()
  {
    return (String)getProperty("TIME_ZONE");
  }
  
  public String getTitle()
  {
    return (String)getProperty("TITLE");
  }
  
  public String getUserID()
  {
    return (String)getProperty("USER_ID");
  }
  
  public String getUserName()
  {
    return (String)getProperty("USER_NAME");
  }
  
  public String getWirelessAcctNumber()
  {
    return (String)getProperty("WIRELESS_ACCT_NUMBER");
  }
  
  public String getDisplayName()
  {
    return (String)getProperty("DISPLAY_NAME");
  }
  
  public String getGUID()
  {
    return (String)getProperty(UserProfileType.GUID);
  }
  
  public String getName()
  {
    return (String)getProperty(UserProfileType.NAME);
  }
  
  public Principal getPrincipal()
  {
    return _userMgr.getPrincipal(getName());
  }
  
  public String getUniqueName()
  {
    return (String)getProperty("UNIQUE_NAME");
  }
  
  public String getUIAccessMode()
  {
    return (String)getProperty("UI_ACCESS_MODE");
  }
  
  public void setBusinessCity(String businessCity)
  {
    setProperty("BUSINESS_CITY", businessCity);
  }
  
  public void setBusinessCountry(String businessCountry)
  {
    setProperty("BUSINESS_COUNTRY", businessCountry);
  }
  
  public void setBusinessEmail(String businessEmail)
  {
    setProperty("BUSINESS_EMAIL", businessEmail);
  }
  
  public void setBusinessFax(String businessFax)
  {
    setProperty("BUSINESS_FAX", businessFax);
  }
  
  public void setBusinessMobile(String businessMobile)
  {
    setProperty("BUSINESS_MOBILE", businessMobile);
  }
  
  public void setBusinessPager(String businessPager)
  {
    setProperty("BUSINESS_PAGER", businessPager);
  }
  
  public void setBusinessPhone(String businessPhone)
  {
    setProperty("BUSINESS_PHONE", businessPhone);
  }
  
  public void setBusinessPOBox(String businessPOBox)
  {
    setProperty("BUSINESS_PO_BOX", businessPOBox);
  }
  
  public void setBusinessPostalAddr(String businessPostalAddr)
  {
    setProperty("BUSINESS_POSTAL_ADDR", businessPostalAddr);
  }
  
  public void setBusinessPostalCode(String businessPostalCode)
  {
    setProperty("BUSINESS_POSTAL_CODE", businessPostalCode);
  }
  
  public void setBusinessState(String businessState)
  {
    setProperty("BUSINESS_STATE", businessState);
  }
  
  public void setBusinessStreet(String businessStreet)
  {
    setProperty("BUSINESS_STREET", businessStreet);
  }
  
  public void setDateofBirth(String dateofBirth)
  {
    setProperty("DATE_OF_BIRTH", dateofBirth);
  }
  
  public void setDateofHire(String dateofHire)
  {
    setProperty("DATE_OF_HIRE", dateofHire);
  }
  
  public void setDefaultGroup(String defaultGroup)
  {
    setProperty("DEFAULT_GROUP", defaultGroup);
  }
  
  public void setDepartment(String department)
  {
    setProperty("DEPARTMENT", department);
  }
  
  public void setDepartmentNumber(String departmentNumber)
  {
    setDepartment(departmentNumber);
  }
  
  public void setDescription(String description)
  {
    setProperty("DESCRIPTION", description);
  }
  
  public void setDisplayName(String displayName)
  {
    setProperty("DISPLAY_NAME", displayName);
  }
  
  public void setEmployeeNumber(String employeeNumber)
  {
    setProperty("EMPLOYEE_NUMBER", employeeNumber);
  }
  
  public void setEmployeeType(String employeeType)
  {
    setProperty("EMPLOYEE_TYPE", employeeType);
  }
  
  public void setFirstName(String firstName)
  {
    setProperty("FIRST_NAME", firstName);
  }
  
  public void setGivenName(String givenName)
  {
    setProperty("GIVEN_NAME", givenName);
  }
  
  public void setHomeAddress(String homeAddress)
  {
    setProperty("HOME_ADDRESS", homeAddress);
  }
  
  public void setHomePhone(String homePhone)
  {
    setProperty("HOME_PHONE", homePhone);
  }
  
  public void setInitials(String initials)
  {
    setProperty("INITIALS", initials);
  }
  
  public void setJpegPhoto(String jpeg)
  {
    setProperty("JPEG_PHOTO", jpeg);
  }
  
  public void setLastName(String lastName)
  {
    setProperty("LAST_NAME", lastName);
  }
  
  public void setMaidenName(String maidenName)
  {
    setProperty("MAIDEN_NAME", maidenName);
  }
  
  public void setManager(String manager)
  {
    setProperty("MANAGER", manager);
  }
  
  public void setMiddleName(String middleName)
  {
    setProperty("MIDDLE_NAME", middleName);
  }
  
  public void setName(String name)
  {
    setProperty("NAME", name);
  }
  
  public void setNameSuffix(String nameSuffix)
  {
    setProperty("NAME_SUFFIX", nameSuffix);
  }
  
  public void setOrganization(String organization)
  {
    setProperty("ORGANIZATION", organization);
  }
  
  public void setOrganizationalUnit(String organizationalUnit)
  {
    setProperty("ORGANIZATIONAL_UNIT", organizationalUnit);
  }
  
  public void setPreferredLanguage(String preferredLanguage)
  {
    setProperty("PREFERRED_LANGUAGE", preferredLanguage);
  }
  
  public void setTimeZone(String timeZone)
  {
    setProperty("TIME_ZONE", timeZone);
  }
  
  public void setTitle(String title)
  {
    setProperty("TITLE", title);
  }
  
  public void setUniqueName(String uniqueName)
  {
    setProperty("UNIQUE_NAME", uniqueName);
  }
  
  public void setUserID(String userID)
  {
    setProperty("USER_ID", userID);
  }
  
  public void setUserName(String userName)
  {
    setProperty("USER_NAME", userName);
  }
  
  public void setUIAccessMode(String uiAccessMode)
  {
    setProperty("UI_ACCESS_MODE", uiAccessMode);
  }
  
  public void setWirelessAcctNumber(String wirelessAcctNumber)
  {
    setProperty("WIRELESS_ACCT_NUMBER", wirelessAcctNumber);
  }
  
  public void saveProfile()
  {
    String METHOD_NAME = "saveProfile()";
    if ((this._modifiedProps != null) && (this._modifiedProps.size() > 0))
    {
      _userMgr.saveUserProfile(getName(), this._modifiedProps);
      this._modifiedProps.clear();
    }
  }
  
  public Object getProperty(String propName)
  {
    Object value = null;
    if (this._values.containsKey(propName)) {
      return this._values.get(propName);
    }
    if (this._userName != null)
    {
      value = _userMgr.getUserProfilePropertyVal(this._userName, propName);
      this._values.put(propName, value);
    }
    return value;
  }
  
  public void setProperty(String name, Object value)
  {
    this._values.put(name, value);
    if (this._modifiedProps == null) {
      this._modifiedProps = new HashMap();
    }
    this._modifiedProps.put(name, value);
  }
  
  public HashMap getProperties()
  {
    return this._values;
  }
  
  public void setProperties(HashMap props)
  {
    internalSetProperties(props);
    if (this._modifiedProps == null) {
      this._modifiedProps = new HashMap();
    }
    this._modifiedProps.putAll(props);
  }
  
  final void internalSetProperties(HashMap props)
  {
    this._internalMap.clear();
    this._values.clear();
    Iterator iter = props.keySet().iterator();
    while (iter.hasNext())
    {
      Object key = iter.next();
      if ((key instanceof UserProfileType)) {
        this._internalMap.put(key, props.get(key));
      } else {
        this._values.put(key, props.get(key));
      }
    }
  }
  
  Object getProperty(UserProfileType type)
  {
    Object value = null;
    if (this._internalMap.containsKey(type)) {
      return this._internalMap.get(type);
    }
    String propName = type.getAttributeName();
    if (this._values.containsKey(propName)) {
      return this._values.get(propName);
    }
    if (this._userName != null)
    {
      value = _userMgr.getUserProfilePropertyVal(this._userName, type);
      this._values.put(propName, value);
    }
    return value;
  }
}
