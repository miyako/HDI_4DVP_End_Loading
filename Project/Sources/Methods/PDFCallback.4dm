//%attributes = {"invisible":true}
// Method called at the end of the PDF export
#DECLARE ($areaName : Text; $filePath : Text; $paramObj : Object; $status : Object)

If ($status.success)
	CALL FORM:C1391($paramObj.windowRef; "ProgressBarAdvancement"; 100; "")
	ACCEPT:C269
	OPEN URL:C673($filePath)
Else 
	ALERT:C41("Error: "+$status.errorMessage)
	CANCEL:C270
End if 