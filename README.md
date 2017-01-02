# Alegri.ActionPack.SharePoint.Environment.Powershell
Ein Aktionspaket für das Verbinden und Initialisieren einer SharePoint Umgebung. Sie können es mit dem [Action Flow tool](https://github.com/Campergue/Alegri.ActionFlow.PowerShell.Commands) verwenden.
Das Aktionspaket soll Ihnen das Verbinden mit verschiedene Umgebung mit verschiedene User erleichtern. Nach der Verbindung mit der Umgebung wird die Umgebung entsprechend geladen und stehen als Globale Werte
in der Powershell Sitzung zur Verfügung. Die entsprechenden Passwörter werden Machinenbezogen verschlüsselt in einer Textdatei gespeichert. 

# Abhängigkeiten
Das Aktionspaket verwendet folgende fremde PowershellModule
- [PnP PowerShell Modul](https://github.com/SharePoint/PnP-PowerShell/tree/master/Documentation)
- Alegri ADFS Modul [nicht öffentlich]. Wird nur für ConnectTyp ADFS und ADFS-SecurePin benötigt 

## Hinweis
Alle abhängigen Funktionen sind gekapselt und werden nur aus der separaten Datei DependentFunction.ps1 verwendet. 
Wenn Sie die Abhängigkeit nicht möchten, könnten Sie theoretisch die Funktionen selber ausprogrammieren.

# Aktionen im Paket
Folgende Aktionen stehen Ihnen zur Verfügung.

| Aktion | Beschreibung |
| --- | --- |
| AP_SPEnvironment_Init | Es werden die Umgebungen und User Anmeldeinformationen in die Sitzung geladen |
| AP_SPEnvironment_Connect | Verbindet sich mit der Umgebung |
| AP_SPEnvironment_Disconnect | Trennt die Verbindung mit der Umgebung |
| AP_SPEnvironment_InitWeb | Die angegebene Umgebung wird zur aktuellen Umgebung |

## Beispiel für die Verwendung der Aktionen
![image](https://cloud.githubusercontent.com/assets/6292190/21577764/10f5e8ba-cf67-11e6-86b6-ce356544baac.png)

# AP_SPEnvironment_Init
Es werden die Umgebungen und User Anmeldeinformationen in die Sitzung geladen

## Attribute
| Attribute | Beschreibung | Verwendung |
| --- | --- | --- |
| pathXMLEnvironment | Die Pfadangabe zu der Umgebungen XML. | required |
| pathXMLUserCredential | Die Pfadangabe zu der User Anmeldeinformation XML. | required |

## Umgebung XML
Sie können hier ihre verschiedene Umgebungen hinterlegen. Alle Umgebungen stehen Ihnen nach der Initialisierung in der Variable $Global:AP_SPEnvironment_XmlConfigEnvironment zur Verfügung.
Sobald Sie sich mit einer Umgebung Verbunden haben steht Ihnen die aktuelle Umgebung in der Variable $Global:AP_SPEnvironment_XmlCurrentEnvironment  zur Verfügung.

Das verwendete Schema http://schemas.powershell.ActionFlow.Environment.alegri.eu

### Beispiel XML
![image](https://cloud.githubusercontent.com/assets/6292190/21577249/8abb2a06-cf54-11e6-8af8-94c0579d4001.png)

### EnvironmentConfiguration
Sie können hier die verschiedene Umgebungen definieren.

| Element | Beschreibung | Verwendung |
| --- | --- | --- |
| Environment | Hiermit definieren Sie eine Umgebung | min:0, max:n |

### Environment
| Attribute | Beschreibung | Verwendung |
| --- | --- | --- |
| Designation | Geben Sie der Umgebung einen in der Konfigurationsdatei eindeutigen Namen. Diesen Wert übergeben Sie beim Starten der Provisionierung. | required |
| SiteUrl | Geben Sie hier die Url zu der Umgebung an | required |
| SiteRelUrl |  Geben Sie hier die Site Realtive Url zu der Umgebung an (z.B. /sites/05062/) | optional |
| Credential |  Geben Sie hier den Credential Namen der Credential an, die verwendet werden soll um sich mit der Site zu verbinden. | required |
| ConnectTyp |  Wählen Sie hier bitte den Verbindungstyp aus. Es gibt drei Arten: Teamsite, ADFS, ADFS-SecurePin | required |
| SharePointVersion |  Es gibt zwei SharePoint Versionen 15 und 16. Bitte geben Sie von der Umgebung die korrekte Version an. Diese wird benötigt damit Pages bzw. WebParts in verschiedene Versionen verwendenbar sind. | required |

## User Anmeldeinformation XML
Sie können hier ihre verschiedene User Anmeldeinformation hinterlegen. Alle User Anmeldeinformationen stehen Ihnen nach der Initialisierung in der Variable $Global:AP_SPEnvironment_XmlConfigUserCredential zur Verfügung.
Sobald Sie sich mit einer Umgebung Verbunden haben steht Ihnen der aktuelle User in der Variable $Global:AP_SPEnvironment_XmlCurrentUserCredential zur Verfügung.

Das verwendete Schema http://schemas.powershell.ActionFlow.UserCredential.alegri.eu

### Beispiel XML
![image](https://cloud.githubusercontent.com/assets/6292190/21587518/a26184f4-d0dd-11e6-9470-01e06e94a6a6.png)

### UserCredentialConfiguration
Sie können hier die verschiedene UserCredential definieren.

| Element | Beschreibung | Verwendung |
| --- | --- | --- |
| UserCredential | Hiermit definieren Sie eine User Anmeldeinformation | min:0, max:n |

### UserCredential
| Attribute | Beschreibung | Verwendung |
| --- | --- | --- |
| CredentialName | Geben Sie der UserCredential einen eindeutigen Namen. Dieses Namen können Sie an einer anderen Stelle als Referenz verwenden. | required |
| UserName | Den UserNamen mit dem sich verbinden möchten (z.B. campergue@campergue.de) | required |

# AP_SPEnvironment_Connect
Verbindet sich mit der Umgebung

## Attribute
| Attribute | Beschreibung | Verwendung |
| --- | --- | --- |
| EnvironmentName | Der Name der Umgebung [Designation vom Environment] | required |
| UserCredentialName | Der Name aus dem UserCredential [CredentialName aus UserCredential]. Vorsicht. Wenn Sie hier einen User-Credential angeben, wird das UserCredential von der Umgebung überschrieben. | optional |
| LoadAllWebs | Wenn Sie den Wert auf True setzen, werden alle Webs von der kompletten SiteCollection geladen. | required |

### Geladene Webs
Sie finden die geladen Webs in der Variable $Global:AP_SPEnvironment_Webs als System.Array. 

Der Inhalt ist vom Typ System.Object mit folgenden Eigenschaften

| Eigenschaft | Beschreibung | Typ |
| --- | --- | --- |
| Title | Den Title der Seite | string |
| ParentTitle | Wenn das Web eine SubWeb ist, trägt er den Seiten Title des Elternteils | string |
| Web | Das Web Object | Microsoft.SharePoint.Client.Web |
| IsRoot | Gibt an ob es sich um das Root Web handelt | bool |

# AP_SPEnvironment_Disconnect 
Trennt die Verbindung mit der Umgebung 

## Attribute
| Attribute | Beschreibung | Verwendung |
| --- | --- | --- |
| EnvironmentName | Der Name der Umgebung [Designation aus Environment]| required |

# AP_SPEnvironment_InitWeb 
Die angegebene Umgebung wird zur aktuellen Umgebung und steht Ihnen in der Variable $Global:AP_SPEnvironment_CurrentWeb zur Verfügung.

## Attribute
| Attribute | Beschreibung | Verwendung |
| --- | --- | --- |
| SiteTitle | Bitte geben Sie den Web Titel an, den Sie gerade laden wollen | required |

---

# Alegri.ActionPack.SharePoint.Environment.Powershell
An action pack for connecting and initializing a SharePoint environment. You can use it with the [Action Flow tool](https://github.com/Campergue/Alegri.ActionFlow.PowerShell.Commands).
The Action Packed are designed to help you connect to different environments with different users. After connecting to the environment, the environment is loaded accordingly and is called Global Values
In the Powershell session. The corresponding passwords are stored encrypted in a text file.

# Dependencies
The action package uses the following external Powershell modules
- [PnP PowerShell Modul](https://github.com/SharePoint/PnP-PowerShell/tree/master/Documentation)
- Alegri ADFS Modul [not public]. Required only for ConnectType ADFS and ADFS SecurePin

## Note
All dependent functions are encapsulated and are used only from the separate DependentFunction.ps1 file.
If you do not want the dependency, you could theoretically program the functions yourself.

# Actions in the package
The following Actions are available to you.

| Action | Description |
| --- | --- |
| AP_SPEnvironment_Init | The environments and user credentials are loaded into the session |
| AP_SPEnvironment_Connect | This Connects with the Environment |
| AP_SPEnvironment_Disconnect | Disconnects the connection with the environment |
| AP_SPEnvironment_InitWeb | The specified environment becomes the current environment |

## Example of using the actions
![image](https://cloud.githubusercontent.com/assets/6292190/21577764/10f5e8ba-cf67-11e6-86b6-ce356544baac.png)

# AP_SPEnvironment_Init
The environments and user credentials are loaded into the session

## Attributes
| Attributes | Description | Use |
| --- | --- | --- |
| pathXMLEnvironment | The Path to the XML Environment. | required |
| pathXMLUserCredential | The Path to the XML UserCredential. | required |

## Environment XML
You can deposit their different environments here. After the initialization, all environments are available in the $Global:AP_SPEnvironment_XmlConfigEnvironment variable.
Once you are connected to an environment, the current environment is available in the $Global:AP_SPEnvironment_XmlCurrentEnvironment variable.

The scheme used http://schemas.powershell.ActionFlow.Environment.alegri.eu

### Example XML
![image](https://cloud.githubusercontent.com/assets/6292190/21577249/8abb2a06-cf54-11e6-8af8-94c0579d4001.png)

### EnvironmentConfiguration
You can define different environments here.

| Element | Description | Use |
| --- | --- | --- |
| Environment | Defines an environment. | min:0, max:n |

### Environment
| Attributes | Description | Use |
| --- | --- | --- |
| Designation | Give the environment a unique name in the configuration file. You transfer this value when you start the provisioning process. | required |
| SiteUrl | Enter the url to the environment | required |
| SiteRelUrl |  Specify the Relative Url site for the environment. (E.g. / Sites / 05062 /)| optional |
| Credential |  Specify here the credential name of the credential to be used to connect to the site. | required |
| ConnectTyp |  Please select the connection type.There are three types: Teamsite, ADFS, ADFS-SecurePin | required |
| SharePointVersion |  There are two SharePoint versions 15 and 16. Please specify the correct version from the environment.This is required for pages or WebParts to be used in different versions. | required |

## User Credential XML
You can deposit their different user credentials here. All user credentials are available after the initialization of the variable $Global:AP_SPEnvironment_XmlConfigUserCredential available.
As soon as you are connected to an environment, the current user is available in the variable $Global:AP_SPEnvironment_XmlCurrentUserCredential.

The scheme used http://schemas.powershell.ActionFlow.UserCredential.alegri.eu

### Example XML
![image](https://cloud.githubusercontent.com/assets/6292190/21577294/4950b7c8-cf56-11e6-8ef5-54d903fbe2ad.png)

### UserCredentialConfiguration
You can define different UserCredential here.

| Element | Description | Use |
| --- | --- | --- |
| UserCredential | Lets you define a User Credential | min:0, max:n |

### UserCredential
| Attributes | Description | Use |
| --- | --- | --- |
| CredentialName | Give the UserCredential a unique name. You can use this name in a different place as a reference. | required |
| UserName | The user name with which you want to connect (E.g. campergue@campergue.de) | required |

# AP_SPEnvironment_Connect
This Connects with the Environment

## Attribute
| Attributes | Description | Use |
| --- | --- | --- |
| EnvironmentName | The Name from the Environment[Designation from Environment] | required |
| UserCredentialName | The Name from the UserCredential[CredentialName from UserCredential]. Caution. If you place a user credential here, the userCredential is overwritten from the environment | optional |
| LoadAllWebs | If you set the value to True, all Webs will be loaded by the complete SiteCollection. | required |

### Loaded Webs
You will find the loaded webs in the $Global:AP_SPEnvironment_Webs variable as System.Array. 

The content is of type System.Object with the following properties

| properties | Description | Typ |
| --- | --- | --- |
| Title | The title of the page | string |
| ParentTitle | If the web is a subweb, he wears the title of the parent's web | string |
| Web | The Web Object | Microsoft.SharePoint.Client.Web |
| IsRoot | Specifies whether the web is RootWeb	 | bool |

# AP_SPEnvironment_Disconnect 
Disconnects the connection with the environment 

## Attribute
| Attributes | Description | Use |
| --- | --- | --- |
| EnvironmentName | The Name from the Environment[Designation from Environment]| required |

# AP_SPEnvironment_InitWeb 
The specified environment becomes the current environment 

This is available to you in the $Global:AP_SPEnvironment_CurrentWeb variable.

## Attributes
| Attributes | Description | Use |
| --- | --- | --- |
| SiteTitle | Please specify the web title you are currently loading | required |