
(* TODO: Add your comment here *)
FUNCTION_BLOCK GenericSignalHandler
	
	
	CASE OperationType OF
		
		INIT:
		
		START_CONFIGURATION: (* Reset signals counts *)
			
			NumberOfAlarms := 0;
			NumberOfAnomalies := 0;
			NumberOfWarnings := 0;
			NumberOfInformation := 0;
			
			
			
			
		CONFIGURATION: (* counting signals *)
			
			CASE (SignalType AND SIGNAL_TYPE_MASK) OF
				ALARM:
					NumberOfAlarms := NumberOfAlarms + 1;
				ANOMALY:
					NumberOfAnomalies := NumberOfAnomalies + 1;
				WARNING:
					NumberOfWarnings := NumberOfWarnings + 1;
				INFORMATION:
					NumberOfInformation := NumberOfInformation + 1;
			END_CASE
			
		START_GENERATION: (* Prepare for generation *)
			
			ResetEnable := FALSE;
			SignalOutputs := NONE;
			ResetActivation := Reset AND NOT ResetOld;
			ResetOld := Reset;
			AuxResetActivation := KeyReset AND NOT KeyResetOld;
			KeyResetOld := KeyReset;
			AutoCondResetActivation := CondKeyReset AND NOT CondKeyResetOld;
			
			CondKeyResetOld := CondKeyReset;			
		GENERATION:
			CASE (SignalType AND SIGNAL_TYPE_MASK) OF
				ALARM:
					Index := NumberOfActiveAlarms;
					BaseIndex := 0;
					Condition := TRUE;
				ANOMALY:
					Index := NumberOfActiveAnomalies;
					BaseIndex := NumberOfAlarms;
					Condition := TRUE;
				WARNING:
					Index := NumberOfActiveWarning;
					BaseIndex := NumberOfAlarms + NumberOfAnomalies;
					Condition := FALSE;
				INFORMATION:
					Index := NumberOfActiveInformation;
					BaseIndex := NumberOfAlarms + NumberOfAnomalies + NumberOfWarnings;
					Condition := FALSE;
			END_CASE
			
			IF ActivationSignal AND NOT Signals[SignalCode] THEN
				Signals[SignalCode] := TRUE;
				Index := Index + 1;
				ActiveSignalCodes[BaseIndex + Index] := SignalCode;
			END_IF
			
			
			
			// Autoconditioned reset
			AutoCondResetOfSignalType := ((SignalType AND AUTO_CONDITIONED_RESET) = AUTO_CONDITIONED_RESET);
			
			
			IF Condition AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode) AND AutoCondResetOfSignalType THEN
				AutoCondResetEnable := TRUE;
				
			END_IF
			
			// Auxiliary reset
			AuxResetOfSignalType := ((SignalType AND AUX_RESET) = AUX_RESET);
			IF Condition AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode) AND AuxResetOfSignalType AND NOT AutoCondResetOfSignalType THEN
				AuxResetEnable := TRUE;
				
			END_IF
			
			//Direct reset
			IF Condition AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode) AND NOT
				AuxResetOfSignalType  AND NOT AutoCondResetOfSignalType THEN
				ResetEnable := TRUE;
			END_IF
			
			IF (ResetActivation OR NOT Condition) AND Signals[SignalCode] AND NOT ActivationSignal AND
				(ActiveSignalCodes[BaseIndex + 1] = SignalCode)  AND NOT AutoCondResetOfSignalType AND NOT AuxResetOfSignalType THEN
				Signals[SignalCode] := FALSE;
				
				FOR i := 2 TO Index DO
					ActiveSignalCodes[BaseIndex + i-1] := ActiveSignalCodes[BaseIndex + i];
				END_FOR;
				ActiveSignalCodes[BaseIndex + Index] := 0;
				Index := Index - 1;
				ResetActivation := FALSE; (* COMMENT THIS LINE TO GO BACK TO CUMULATIVE RESET *)
				
			END_IF
			// Auxiliary reset
			IF (AuxResetActivation OR NOT Condition) AND Signals[SignalCode] AND NOT ActivationSignal AND
				(ActiveSignalCodes[BaseIndex + 1] = SignalCode) AND AuxResetOfSignalType  AND NOT AutoCondResetOfSignalType THEN
				Signals[SignalCode] := FALSE;
				
				FOR i := 2 TO Index DO
					ActiveSignalCodes[BaseIndex + i-1] := ActiveSignalCodes[BaseIndex + i];
				END_FOR;
				ActiveSignalCodes[BaseIndex + Index] := 0;
				Index := Index - 1;
				AuxResetActivation := FALSE; (* COMMENT THIS LINE TO GO BACK TO CUMULATIVE RESET *)
				
			END_IF
			// Autoconditioned reset
			IF (AutoCondResetActivation OR NOT Condition) AND Signals[SignalCode] AND NOT ActivationSignal AND
				(ActiveSignalCodes[BaseIndex + 1] = SignalCode) AND AuxResetOfSignalType AND AutoCondResetOfSignalType THEN
				Signals[SignalCode] := FALSE;
				
				FOR i := 2 TO Index DO
					ActiveSignalCodes[BaseIndex + i-1] := ActiveSignalCodes[BaseIndex + i];
				END_FOR;
				ActiveSignalCodes[BaseIndex + Index] := 0;
				Index := Index - 1;
				AutoCondResetActivation := FALSE; (* COMMENT THIS LINE TO GO BACK TO CUMULATIVE RESET *)
				
	
			END_IF
			
			CASE (SignalType AND SIGNAL_TYPE_MASK) OF
				ALARM:
					NumberOfActiveAlarms := Index;
				ANOMALY:
					NumberOfActiveAnomalies := Index;
				WARNING:
					NumberOfActiveWarning := Index;
				INFORMATION:
					NumberOfActiveInformation := Index;
			END_CASE
			IF Signals[SignalCode] THEN
				SignalOutputs := SignalOutputs OR SignalOutput;
				MySignalCode := SignalCode;
				
			END_IF
			
		RUN:
		(* UPDATE THE USER INTERFACE LED *)

			IF NumberOfActiveInformation >0 THEN

				LedSignalInformation	:= TRUE;
				
			ELSE
				LedSignalInformation	:= FALSE;
			END_IF
			
			IF NumberOfActiveAnomalies >0 THEN
				
				LedSignalAnomaly	:= TRUE;
				
			ELSE
				LedSignalAnomaly	:= FALSE;
			END_IF
			
			IF NumberOfActiveWarning >0 THEN
				
				LedSignalWarning	:= TRUE;
				
			ELSE
				LedSignalWarning	:= FALSE;
			END_IF
				
			IF NumberOfActiveAlarms >0 THEN
				
				LedSignalAlarm	:= TRUE;
				
			ELSE
				LedSignalAlarm	:= FALSE;
			END_IF
		
	END_CASE
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
END_FUNCTION_BLOCK
