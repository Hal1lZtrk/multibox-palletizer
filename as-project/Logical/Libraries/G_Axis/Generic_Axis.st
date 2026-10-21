
(* TODO: Add your comment here *)
FUNCTION_BLOCK Generic_Axis
	IF (DeviceClock AND (Timer > 0))THEN
		Timer := Timer - 1;
			
		END_IF;	
	
	CASE Generic_Axis_State OF
		
		WaitpowerON:
			IF PowerON THEN
				//all output false
				Powered:= FALSE;
				InPosition	:= FALSE;
				InVelocity	:= FALSE;
				Timer		:= DeviceTimer;
	  			Generic_Axis_State:=WaitHoming;
			END_IF;
		WaitHoming:
			
			IF TimeOut THEN
				Powered:= TRUE;
				TimeOut		:= FALSE;
				Output_Target_Position:=0.0;
				Output_Target_Velocity:=0.0;
				Actual_Command := Notbusy;
				IF NOT PowerON THEN
					Generic_Axis_State:= WaitpowerON;
				ELSE
					IF Actual_position=0.0 THEN
						InPosition	:= TRUE;
						InVelocity	:= FALSE;
						Generic_Axis_State:= CheckCommand;
					END_IF;
				END_IF;
			END_IF;
		CheckCommand:
			IF Actual_Command = POWEROFF  THEN
				Actual_Command := Notbusy;
				Generic_Axis_State:= WaitPowerOFF;
			END_IF;
			IF Actual_Command = STOP THEN
				Actual_Command := Notbusy;
				Generic_Axis_State:= WaitStop;
			END_IF;	
			IF Actual_Command = HOMING THEN
				Actual_Command := Notbusy;
				InVelocity	:= TRUE;
				Generic_Axis_State:= WaitHoming;
			END_IF;	
			IF Actual_Command = TARGETPOSITION THEN
				Actual_Command := Notbusy;
				IF Input_Target_Position <> Actual_position THEN
					InVelocity	:= TRUE;
					Timer		:= DeviceTimer;
	  				Generic_Axis_State:= WaitMoveTRG_POS;
				ELSE
					Generic_Axis_State:= CheckCommand;
				END_IF;
			END_IF;		
			InPosition	:= FALSE;
			IF Actual_Command = TARGETVELOCITY THEN
				Actual_Command := Notbusy;
				IF Input_Target_Velocity <> Output_Target_Velocity THEN
					InVelocity	:= TRUE;
					Timer		:= DeviceTimer;
					Generic_Axis_State:= WaitMoveTRG_VEL;
				ELSE
					Generic_Axis_State:= CheckCommand;
				END_IF;
			END_IF;		
		WaitPowerOFF:
			PowerON := FALSE;
			InPosition	:= FALSE;
			InVelocity	:= FALSE;
			Generic_Axis_State:=WaitHoming;
		WaitStop:
			
			IF InVelocity THEN
		  		Output_Target_Position:=Actual_position + 0.1; //bias link to the dealy
				IF Reached_Postion THEN
					
		  			InPosition	:= FALSE;
					InVelocity	:= FALSE;
				END_IF;
			END_IF;
			IF OutputSimulateError THEN
				Generic_Axis_State:= ErrorState;
			ELSE
				Generic_Axis_State:= CheckCommand;
			END_IF;
			
		WaitMoveTRG_POS:
			Output_Target_Position := Input_Target_Position;
			IF TimeOut THEN
				IF DeviceFeedback AND Reached_Postion THEN
					InPosition	:= TRUE;
					InVelocity	:= FALSE;
					TimeOut		:= FALSE;
					Generic_Axis_State:= CheckCommand;
				END_IF;	
				
				IF NOT DeviceFeedback AND (Input_Target_Position = Actual_position)	 THEN
					InPosition	:= TRUE;
					InVelocity	:= FALSE;
					TimeOut		:= FALSE;
					Generic_Axis_State:= CheckCommand;
				END_IF;
				
			END_IF;
		WaitMoveTRG_VEL:
			Output_Target_Velocity := Input_Target_Velocity;
			IF TimeOut THEN
				IF NOT DeviceFeedback THEN
					TimeOut		:= FALSE;
					Generic_Axis_State:= CheckCommand;
				END_IF;
			END_IF;
		
		ErrorState:
			IF NOT InputSimulateError THEN //wait for the Simulated Error to be set back
				OutputSimulateError:=FALSE;
			Generic_Axis_State:= WaitHoming;	
			END_IF;

	END_CASE;
	IF Timer=0 THEN
		TimeOut	:= TRUE;
	END_IF;
	IF InputSimulateError THEN
		OutputSimulateError:=TRUE;
		Generic_Axis_State:= WaitStop;
	END_IF;	

	
END_FUNCTION_BLOCK
