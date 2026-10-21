
{REDUND_ERROR} FUNCTION_BLOCK Generic_Axis (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		PowerON : BOOL;
		DeviceTimer : INT;
		Actual_position : REAL;
		Input_Target_Position : REAL;
		Reached_Postion : BOOL;
		InputSimulateError : BOOL;
		Actual_Command : DWORD;
		DeviceClock : BOOL;
		DeviceFeedback : BOOL;
	END_VAR
	VAR_OUTPUT
		Powered : BOOL;
		Output_Target_Position : REAL;
		InPosition : BOOL;
		InVelocity : BOOL;
		OutputSimulateError : BOOL;
	END_VAR
	VAR
		Generic_Axis_State : GenericAxisType;
		Timer : INT;
		TimeOut : BOOL;
	END_VAR
	VAR_INPUT
		Input_Target_Velocity : REAL;
	END_VAR
	VAR_OUTPUT
		Output_Target_Velocity : REAL;
	END_VAR
END_FUNCTION_BLOCK
