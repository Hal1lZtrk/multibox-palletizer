
{REDUND_ERROR} FUNCTION_BLOCK GenericSignalHandler (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		OperationType : INT;
		SignalType : DINT;
		Reset : BOOL;
		KeyReset : BOOL;
		ActivationSignal : BOOL;
		SignalCode : INT;
		SignalOutput : DWORD;
		CondKeyReset : BOOL;
	END_VAR
	VAR_OUTPUT
		NumberOfAlarms : INT;
		NumberOfAnomalies : INT;
		NumberOfWarnings : INT;
		NumberOfInformation : INT;
		ResetEnable : BOOL;
		SignalOutputs : DWORD;
		NumberOfActiveAlarms : INT;
		NumberOfActiveAnomalies : INT := 0;
		NumberOfActiveWarning : INT;
		NumberOfActiveInformation : INT;
		ActiveSignalCodes : ARRAY[0..24] OF INT;
		AuxResetEnable : BOOL;
		AutoCondResetEnable : BOOL;
		LedSignalInformation : BOOL;
		LedSignalAnomaly : BOOL;
		LedSignalWarning : BOOL;
		LedSignalAlarm : BOOL;
		MySignalCode : INT;
	END_VAR
	VAR
		ResetActivation : BOOL;
		ResetOld : BOOL;
		KeyResetOld : BOOL;
		Index : INT;
		BaseIndex : INT;
		Condition : BOOL;
		Signals : {REDUND_UNREPLICABLE} ARRAY[0..24] OF BOOL;
		i : INT;
		AuxResetActivation : BOOL;
		AuxResetOfSignalType : BOOL;
		AutoCondResetOfSignalType : BOOL;
		AutoCondResetActivation : BOOL;
		CondKeyResetOld : BOOL;
	END_VAR
END_FUNCTION_BLOCK
