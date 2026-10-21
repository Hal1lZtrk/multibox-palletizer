
{REDUND_ERROR} FUNCTION_BLOCK Generic_Device (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		DeviceClock : {REDUND_UNREPLICABLE} BOOL;
		DeviceDisabledSensor : {REDUND_UNREPLICABLE} BOOL;
		DeviceEnabledSensor : {REDUND_UNREPLICABLE} BOOL;
		DeviceEnabled : {REDUND_UNREPLICABLE} BOOL;
		DeviceDisabled : {REDUND_UNREPLICABLE} BOOL;
		DeviceType : {REDUND_UNREPLICABLE} INT;
		DeviceOperation : {REDUND_UNREPLICABLE} INT;
		DeviceEnablePreset : {REDUND_UNREPLICABLE} BOOL;
		DeviceEnableTime : {REDUND_UNREPLICABLE} INT;
		DeviceDisableTime : {REDUND_UNREPLICABLE} INT;
		DeviceDiagnosticsEnabled : BOOL;
		SimulationDeviceFault : BOOL;
	END_VAR
	VAR_OUTPUT
		EnableDevice : {REDUND_UNREPLICABLE} BOOL;
		DeviceNotInitialized : {REDUND_UNREPLICABLE} BOOL;
		DisableDevice : {REDUND_UNREPLICABLE} BOOL;
		DeviceDisabledSensorFault : {REDUND_UNREPLICABLE} BOOL;
		DeviceEnabledSensorFault : {REDUND_UNREPLICABLE} BOOL;
		DeviceActuatorFault : {REDUND_UNREPLICABLE} BOOL;
		DeviceFault : {REDUND_UNREPLICABLE} BOOL;
	END_VAR
	VAR_IN_OUT
		DeviceEnableRequest : BOOL;
		DeviceDisableRequest : BOOL;
	END_VAR
	VAR
		DeviceTimer : {REDUND_UNREPLICABLE} INT;
	END_VAR
	VAR RETAIN
		DeviceState : {REDUND_UNREPLICABLE} DeviceStateType;
	END_VAR
	VAR
		Timeout : {REDUND_UNREPLICABLE} BOOL := FALSE;
	END_VAR
	VAR CONSTANT
		INIT : INT := 0;
	END_VAR
	VAR
		WaitNominalStateCounter : INT := 20;
		SimulationDeviceActuatorFault : BOOL;
	END_VAR
END_FUNCTION_BLOCK
