Class constructor($windowRef : Integer; $pdfPath : Text; $trace : Boolean)
	
	This:C1470.windowRef:=$windowRef
	This:C1470.pdfPath:=$pdfPath
	This:C1470.trace:=$trace
	
	This:C1470.peoplePagination:=cs:C1710.PaginateTable.new(ds:C1482.People.all())
	This:C1470.EntitySelection:=This:C1470.peoplePagination.Next()
	
	This:C1470.autoQuit:=False:C215
	// When you use a timer, the timeout must be bigger that the timer
	This:C1470.timer:=60
	This:C1470.timeout:=This:C1470.timer*3  //miyako:make it easier to adjust the imer
	This:C1470.isWaiting:=False:C215
	
	CALL FORM:C1391(This:C1470.windowRef; "ProgressBarAdvancement"; 0; "Initializing custom functions")
	
Function onEvent
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			This:C1470.allowDataStoreFields()
			CALL FORM:C1391(This:C1470.windowRef; "ProgressBarAdvancement"; 25; "Loading document")
			
		: (FORM Event:C1606.code=On VP Ready:K2:59)
			If (This:C1470.trace)
				TRACE:C157
			End if 
			// Document import
			VP IMPORT DOCUMENT(This:C1470.area; Get 4D folder:C485(Current resources folder:K5:16)+"hdi.4vp")
			CALL FORM:C1391(This:C1470.windowRef; "ProgressBarAdvancement"; 50; "Waiting for end of calculations")
			
			This:C1470.isWaiting:=True:C214
			// Starts a timer to verify if all calculations are finished.
			// If during this period the "On VP Range Changed" is thrown, the timer will be restarted
			// The time must be defined according to the computer configuration.
			SET TIMER:C645(This:C1470.timer)
			
		: (FORM Event:C1606.code=On VP Range Changed:K2:61)
			// End of calculation detected. Restarts the timer 
			If (This:C1470.isWaiting)
				SET TIMER:C645(This:C1470.timer)
			End if 
			
		: (FORM Event:C1606.code=On Timer:K2:25)
			// To be sure to not restart the timer because the VP commands used after could throw the "On VP Range Changed" event again
			
			SET TIMER:C645(30000)  // miyako:can not stop the timer with SET TIMER(0), so make it really long
			
			If (This:C1470.isWaiting)  //miyako:avoid double jeopardy
				
				This:C1470.isWaiting:=False:C215
				
				// Defines the options of the pdf document
				var $printInfo : Object
				$printInfo:=New object:C1471
				$printInfo.orientation:=vk print page orientation landscape:K89:89
				$printInfo.headerCenter:="Customer details"
				$printInfo.centering:=vk print centering both:K89:85
				$printInfo.showBorder:=False:C215
				VP SET PRINT INFO(This:C1470.area; $printInfo)
				
				CALL FORM:C1391(This:C1470.windowRef; "ProgressBarAdvancement"; 75; "PDF creation")
				// Starts the pdf creation. The VP offscreen will be closed in the callback method called at the end of the export
				VP EXPORT DOCUMENT(This:C1470.area; This:C1470.pdfPath; New object:C1471("formula"; Formula:C1597(PDFCallback); "windowRef"; This:C1470.windowRef))
				
			Else 
				TRACE:C157  //miyako:something is wrong
			End if 
			
		: (FORM Event:C1606.code=On URL Loading Error:K2:48)
			CANCEL:C270
			
	End case 
	
Function allowDataStoreFields
	// Initializes the list of fields used in the document
	// ----------------------------------------------------
	
	var $customFunctions; $entitySelection : Object
	
	$customFunctions:=New object:C1471
	
	$entitySelection:=This:C1470.EntitySelection
	
	$customFunctions.People_Portrait_S:=New object:C1471
	$customFunctions.People_Portrait_S.formula:=Formula:C1597($entitySelection[$1].Portrait_S)
	$customFunctions.People_Portrait_S.parameters:=New collection:C1472
	$customFunctions.People_Portrait_S.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_Title:=New object:C1471
	$customFunctions.People_Title.formula:=Formula:C1597($entitySelection[$1].Title)
	$customFunctions.People_Title.parameters:=New collection:C1472
	$customFunctions.People_Title.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_Firstname:=New object:C1471
	$customFunctions.People_Firstname.formula:=Formula:C1597($entitySelection[$1].Firstname)
	$customFunctions.People_Firstname.parameters:=New collection:C1472
	$customFunctions.People_Firstname.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_Lastname:=New object:C1471
	$customFunctions.People_Lastname.formula:=Formula:C1597($entitySelection[$1].Lastname)
	$customFunctions.People_Lastname.parameters:=New collection:C1472
	$customFunctions.People_Lastname.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_Address:=New object:C1471
	$customFunctions.People_Address.formula:=Formula:C1597($entitySelection[$1].Address)
	$customFunctions.People_Address.parameters:=New collection:C1472
	$customFunctions.People_Address.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_ZipCode:=New object:C1471
	$customFunctions.People_ZipCode.formula:=Formula:C1597($entitySelection[$1].ZipCode)
	$customFunctions.People_ZipCode.parameters:=New collection:C1472
	$customFunctions.People_ZipCode.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_City:=New object:C1471
	$customFunctions.People_City.formula:=Formula:C1597($entitySelection[$1].City)
	$customFunctions.People_City.parameters:=New collection:C1472
	$customFunctions.People_City.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_Country:=New object:C1471
	$customFunctions.People_Country.formula:=Formula:C1597($entitySelection[$1].Country)
	$customFunctions.People_Country.parameters:=New collection:C1472
	$customFunctions.People_Country.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_Phone:=New object:C1471
	$customFunctions.People_Phone.formula:=Formula:C1597($entitySelection[$1].Phone)
	$customFunctions.People_Phone.parameters:=New collection:C1472
	$customFunctions.People_Phone.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	$customFunctions.People_email:=New object:C1471
	$customFunctions.People_email.formula:=Formula:C1597($entitySelection[$1].email)
	$customFunctions.People_email.parameters:=New collection:C1472
	$customFunctions.People_email.parameters.push(New object:C1471("name"; "num"; "type"; Is integer:K8:5))
	
	VP SET CUSTOM FUNCTIONS(This:C1470.area; $customFunctions)