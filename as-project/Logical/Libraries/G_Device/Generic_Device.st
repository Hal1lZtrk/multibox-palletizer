
(* TODO: Add your comment here *)
FUNCTION_BLOCK Generic_Device
	
	//I-) DEVICE CLOCK HANDLER
	IF (DeviceClock AND (DeviceTimer > 0))THEN
		DeviceTimer := DeviceTimer - 1;
		WaitNominalStateCounter := WaitNominalStateCounter	- 1;
	END_IF;	
	
	
	//II-) DEVICE SENSORS HANDLER
	CASE (DeviceType AND DEVICE_FEEDBACK_MASK) OF
			
		DEVICE_WITH_ENABLE_FEEDBACK:
			
			DeviceDisabledSensor := NOT DeviceEnabledSensor AND	
			((DeviceState = DeviceDisabledState) OR (DeviceState = DeviceDisablePhaseState AND Timeout));
			//Pre-elaborations actuators
			DeviceDisabled := NOT DeviceEnabled AND ((DeviceState = DeviceDisabledState) OR
			(DeviceState = DeviceDisablePhaseState AND Timeout));
			
		DEVICE_WITH_DISABLE_FEEDBACK :
			
			DeviceEnabledSensor := NOT DeviceDisabledSensor AND	
			((DeviceState = DeviceEnabledState) OR (DeviceState = DeviceEnablePhaseState AND Timeout));
			//Pre-elaborations actuators
			DeviceEnabled := NOT DeviceDisabled AND ((DeviceState = DeviceEnabledState) OR
			(DeviceState = DeviceEnablePhaseState AND Timeout));			
			
				
		DEVICE_WITHOUT_FEEDBACK:
			
			DeviceEnabledSensor := (DeviceState = DeviceEnabledState) OR ((DeviceState = DeviceEnablePhaseState) AND Timeout);
			DeviceDisabledSensor := (DeviceState = DeviceDisabledState) OR ((DeviceState = DeviceDisablePhaseState) AND Timeout);
			//Pre-elaborations actuators
			DeviceEnabled := (DeviceState = DeviceEnabledState) OR (DeviceState = DeviceEnablePhaseState AND Timeout);
			DeviceDisabled := (DeviceState = DeviceDisabledState) OR (DeviceState = DeviceDisablePhaseState AND Timeout);

	END_CASE;
	
	//III-) DEVICE INITIALIZATION HANDLER
	IF (DeviceOperation = INIT) THEN
		// Device sensor handler
		CASE (DeviceType AND DEVICE_FEEDBACK_MASK) OF
			
			DEVICE_WITH_ENABLE_FEEDBACK:
				DeviceDisabled := NOT DeviceEnabled;
					
			DEVICE_WITH_DISABLE_FEEDBACK :
				DeviceEnabled := NOT DeviceDisabled;
					
			DEVICE_WITHOUT_FEEDBACK:
				DeviceEnabled := DeviceEnablePreset;
				DeviceDisabled := NOT DeviceEnabled;
			
		END_CASE;
		
		DeviceEnableRequest := FALSE;
		DeviceDisableRequest := FALSE;
		
		IF (DeviceEnablePreset) THEN
			EnableDevice := TRUE;
			DeviceTimer := DeviceEnableTime;
			IF (NOT (DeviceDisabled AND DeviceEnabled)) THEN
				DeviceState := DeviceEnablePhaseState;
			ELSE
				DeviceState := DeviceEnabledState;
			END_IF;
			DeviceNotInitialized := NOT DeviceEnabled OR DeviceDisabled;
		ELSE
			EnableDevice := FALSE;
			DeviceTimer := DeviceDisableTime;
			IF (NOT (DeviceDisabled AND DeviceEnabled)) THEN
				DeviceState := DeviceDisablePhaseState;
			ELSE
				DeviceState := DeviceDisabledState;
			END_IF;
			DeviceNotInitialized := (DeviceEnabled OR NOT DeviceDisabled);
		END_IF;
	END_IF;
	
	IF NOT SimulationDeviceFault THEN
		//IV-) DEVICE CONTROL HANDLER (GENERIC DEVICE FSM IMPLEMENTATION)
		CASE (DeviceState) OF
		
			DeviceDisabledState:
				DeviceDisableRequest := FALSE;
				IF (DeviceEnableRequest) THEN
					EnableDevice := TRUE;
					DeviceTimer := DeviceEnableTime;
					DeviceState := DeviceEnablePhaseState;
				END_IF;
			
			DeviceEnablePhaseState:
				IF DeviceDisableRequest THEN
					DeviceEnableRequest	:= FALSE;
					EnableDevice	:= FALSE;
					DeviceTimer	:= DeviceDisableTime;
					DeviceState	:= DeviceDisablePhaseState;
				END_IF;
				IF DeviceEnabledSensor THEN
					DeviceEnableRequest := FALSE;
					DeviceTimer	:= 0;
					DeviceState := DeviceEnabledState;
				END_IF;
			
			DeviceEnabledState:
				DeviceEnableRequest	:= FALSE;
				IF DeviceDisableRequest THEN
					EnableDevice := FALSE;
					DeviceTimer	:= DeviceDisableTime;
					DeviceState := DeviceDisablePhaseState;
				END_IF;
			
			DeviceDisablePhaseState:
				IF DeviceEnableRequest THEN
					DeviceDisableRequest	:= FALSE;
					EnableDevice	:= TRUE;
					DeviceTimer	:= DeviceEnableTime;
					DeviceState	:= DeviceEnablePhaseState;
				END_IF;
			
				IF DeviceDisabledSensor THEN
					DeviceDisableRequest := FALSE;
					DeviceTimer	:= 0;
					DeviceState := DeviceDisabledState;
				END_IF;
		
		END_CASE;
	  
	END_IF;		
	
	
	
	
	//handler timer
	IF (DeviceTimer = 0) THEN
		Timeout := TRUE ;
	  
	ELSE
		Timeout := FALSE ;

	END_IF;
	
	//V-) DEVICE DIAGNOSTICS HANDLER (GENERATION OF DIAGNOSIS INFORMATION),
	DeviceDisabledSensorFault := (( NOT EnableDevice AND NOT DeviceDisabledSensor AND NOT DeviceEnabledSensor) OR (EnableDevice AND DeviceDisabledSensor AND DeviceEnabledSensor)) AND Timeout;
	
	DeviceEnabledSensorFault := ((NOT EnableDevice AND DeviceDisabledSensor AND DeviceEnabledSensor) OR (EnableDevice AND NOT DeviceDisabledSensor AND NOT DeviceEnabledSensor)) AND Timeout;
	
	DeviceActuatorFault := ((NOT EnableDevice AND NOT DeviceDisabledSensor AND DeviceEnabledSensor AND Timeout) OR (EnableDevice AND DeviceDisabledSensor AND NOT DeviceEnabledSensor AND Timeout)) AND Timeout;
	//DeviceActuatorFault

	
	DeviceFault :=	DeviceDisabledSensorFault OR DeviceEnabledSensorFault OR SimulationDeviceFault ;
	

	
	
	//VI-) DEVICE ACTUATORS HANDLER (Post-elaborations actustors)
	IF (DeviceType AND DEVICE_ACTUATION_MASK)= DEVICE_WITH_SINGLE_ACTUATION THEN
		//Nothing to do, just use EnableDevice
	END_IF;		
	IF	(DeviceType AND DEVICE_ACTUATION_MASK)= DEVICE_WITH_DOUBLE_ACTUATION THEN
		DisableDevice := NOT EnableDevice;
	END_IF;			
	IF	(DeviceType AND DEVICE_ACTUATION_MASK)= DEVICE_WITH_DA_NO_RETAIN THEN
		EnableDevice := EnableDevice AND (DeviceState = DeviceEnablePhaseState);
		DisableDevice := NOT EnableDevice AND (DeviceState = DeviceDisablePhaseState);
	END_IF;	 
	IF	DeviceActuatorFault AND (DeviceTimer = 0) AND WaitNominalStateCounter = 0  THEN
		
		SimulationDeviceActuatorFault := TRUE;
		WaitNominalStateCounter := 20;
		
	ELSE
		SimulationDeviceActuatorFault := FALSE;
	END_IF;	
	
	
	
END_FUNCTION_BLOCK
